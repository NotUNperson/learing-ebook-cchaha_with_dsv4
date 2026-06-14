# 02-09 .dockerignore 与层缓存优化

## 本节你会学到什么

- 掌握 .dockerignore 文件的写法和作用
- 深入理解 Docker 的层缓存机制和缓存失效条件
- 学会通过编排指令顺序让缓存命中率最大化
- 能用 `docker history` 分析镜像层结构

## 正文

### .dockerignore：别什么垃圾都往镜像里塞

还记得 02-07 讲的构建上下文吗？`docker build` 第一步就是把整个构建上下文打包发给 docker daemon。如果你的项目目录里有 `node_modules`（几百 MB）、`.git` 目录、日志文件、本地环境配置文件——它们全部会被打包发过去，然后在 COPY 指令中可能被复制到镜像里。

`.dockerignore` 就是告诉 Docker："这些东西别发，跟我没关系。"

```
# .dockerignore
node_modules
.git
*.log
.env
.env.local
Dockerfile
.dockerignore
dist
coverage
.vscode
.idea
```

语法和 `.gitignore` 几乎一样：
- 每行一个模式
- `*` 匹配任意字符
- `**` 匹配任意路径
- `#` 开头是注释
- `!` 开头表示排除（即"除了这个"）

一个生产级的 `.dockerignore` 示例：

```
# .dockerignore

# 依赖和构建产物
node_modules
dist
build
coverage
.cache

# 版本控制
.git
.gitignore

# 环境配置（它们应该通过环境变量或配置文件卷挂载传入）
.env
.env.*

# 开发工具配置
.vscode
.idea
*.swp
*.swo

# 日志
*.log
logs/

# Docker 相关
Dockerfile
.dockerignore

# 临时文件
tmp/
temp/

# 操作系统文件
.DS_Store
Thumbs.db

# 但是！保留我们需要的
!dist/
```

最后一行 `!dist/` 是一个"反排除"的例子：如果上面排除了 dist，但某种构建场景下 dist 确实需要被复制（比如本地构建后 COPY 进去），就加一个排除规则的例外。

### 层缓存的工作原理

Docker 的缓存机制是构建加速的核心。原理很简单：

1. Docker 按顺序执行 Dockerfile 的每一行指令。
2. 每执行完一行，Docker 创建一个层并保存其"指纹"。
3. 下次构建时，Docker 检查：这一行的指令和上一层的指纹是否和之前一样？
4. 如果一样，跳过执行，直接用缓存。如果不一样或上一层的指纹变了，从这行开始，之后所有行都得重新执行。

**缓存失效的连锁反应**：

用"多米诺骨牌"来类比：Dockerfile 的指令像一排竖着的骨牌。最上面的（FROM）最不容易倒，越往下越容易倒。一旦某一张牌倒了（缓存失效），它下面所有的牌全部跟着倒（全部重新执行）。

这就是为什么我们在 02-04 中强调：**不常变的放上面，常变的放下面。**

### 优化 COPY 顺序的具体演示

看一个真实的例子——一个典型的 Node.js 应用：

```dockerfile
# 缓存不友好版本
FROM node:20-alpine                    # 几乎从不变
WORKDIR /app                           # 几乎从不变
COPY . .                               # 每次改一行代码都会变！
RUN npm ci                             # 跟着上面一起重跑
CMD ["node", "index.js"]              # 几乎从不变
```

每次你改动一个 JS 文件，`COPY . .` 就失效，然后 `npm ci` 也跟着失效——白白重装一遍依赖。

```dockerfile
# 缓存友好版本
FROM node:20-alpine                    # 几乎从不变
WORKDIR /app                           # 几乎从不变
COPY package.json package-lock.json ./ # 依赖文件更新时才变
RUN npm ci                             # 依赖有变化才重跑
COPY . .                               # 源码常变，但放在 npm ci 后面
CMD ["node", "index.js"]              # 几乎从不变
```

效果对比：改一个 JS 文件后重建。

| 版本 | 缓存命中 | 行为 |
|------|---------|------|
| 不友好 | 只有 FROM 和 WORKDIR 命中 | npm ci 重跑（耗时 30s-2min）|
| 友好 | FROM、WORKDIR、COPY package*.json、npm ci 全部命中 | 只有 COPY . . 和后续步骤重跑（1-2 秒）|

### 缓存失效的具体条件

Docker 判断缓存是否失效的规则：

- **FROM**：基础镜像的 digest 变了（比如你用了 `latest`，仓库里更新了）。
- **RUN**：只要命令字符串没变，上一层的缓存又命中，就用缓存。注意 Docker 不看命令的执行结果，它只看命令字符串本身。所以 `RUN apt-get update` 虽然每次都成功命中缓存，但 apt 源可能已经过时了。
- **COPY/ADD**：复制文件的内容（校验和）变了。哪怕只是改了一个字符，整层失效。
- **ARG**：ARG 的值变了视为失效，但 ARG 本身不影响缓存（它不产生层）。

### docker history：窥探镜像的层

用 `docker history` 可以查看一个镜像是怎么一层一层构建出来的：

```bash
docker history nginx:alpine
```

```
IMAGE          CREATED          SIZE    COMMENT
abc123...     2 weeks ago      0B      CMD ["nginx" "-g" "daemon off;"]
def456...     2 weeks ago      1.5kB   COPY nginx.conf /etc/nginx/
ghi789...     2 weeks ago      45MB    RUN apk add nginx
...
```

每一行对应 Dockerfile 的一条指令。SIZE 告诉你这层增加了多少体积。如果发现某层 SIZE 特别大，那就是优化的目标。

### 缓存不是你想象的那样智能

一个常见误区：你以为你改了某个文件，Docker 会"聪明地"只重跑相关步骤。实际上 Docker **非常笨**——它只看字符串是否一样，不看逻辑相关性。

举个例子：

```dockerfile
RUN apt-get update && apt-get install -y nginx
```

如果你用缓存，这条命令可能被缓存了三个月。三个月前 `apt-get update` 拉下来的包列表早就过时了，安装的 nginx 也可能有安全漏洞。Docker 不会提示你，它会高高兴兴地使用缓存。

解决办法：定期用 `--no-cache` 构建，或者在 CI/CD 中给基础镜像设置定期重建策略。

### 实用的缓存使用策略

**日常开发**：不用 `--no-cache`，充分利用缓存来快速迭代。

**PR 检查/CI 测试**：使用缓存，但加 `--pull` 确保基础镜像是最新的。

**发布构建**：使用 `--no-cache` 确保一切从干净的起点开始。同时也应该使用固定的基础镜像版本号（如 `node:20.11.0-alpine3.19` 而不是 `node:20-alpine`）。

```bash
# 日常开发
docker build -t myapp:dev .

# PR/CI
docker build --pull -t myapp:test .

# 正式发布
docker build --no-cache --pull -t myapp:1.0.0 -t myapp:latest .

# CI 中使用外部缓存
docker build --cache-from myregistry.com/myapp:cache -t myapp:latest .
```

## 动手试试

1. 找一个有 `node_modules` 的项目，先不写 `.dockerignore` 构建一次，查看构建日志开头的 "Sending build context to Docker daemon" 的大小。然后写好 `.dockerignore` 排除 `node_modules` 和 `.git`，再构建一次，对比发送给 daemon 的数据量。
2. 写两个版本的 Dockerfile（COPY 顺序不同），对同一个项目各构建两次（中间改一个源码文件），对比第二次构建的缓存命中情况和耗时。
3. 用 `docker history` 查看一个镜像的层结构，看看哪一层最"胖"。

## 本节小结

`.dockerignore` 阻止不需要的文件进入构建上下文和镜像；合理的指令编排（不常变的放前面）能让层缓存命中率最大化，大幅加速构建。理解缓存的"多米诺骨牌"效应是写好 Dockerfile 的核心技能。

## 下一节预告

下一节是模块 02 的综合练习——为一个 Node.js 应用从零编写生产级 Dockerfile，把前面 9 节学的所有知识整合起来。
