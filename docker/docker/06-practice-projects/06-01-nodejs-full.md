# 06-01 实战一：Node.js 应用容器化全流程

## 本节你会学到什么

- 把一个 Express 应用从零开始打包成 Docker 镜像
- 使用多阶段构建（multi-stage build）把镜像从 900MB 瘦身到 150MB
- 写出有效的 .dockerignore 文件，避免把 node_modules 和日志打包进去
- 使用 docker run 的端口映射、环境变量和挂载卷来调试
- 理解为什么同样的 Dockerfile，换个基础镜像体积能差五六倍

---

想象一下，你是一个外卖骑手。你的任务是取一份餐（你的 Node.js 应用），送到顾客手里（服务器）。如果每次送餐你都要把整个厨房带上（900MB 的 node_modules、构建工具、编译器），你不仅跑得慢，路上还容易洒。

但如果有一个专业的保温箱（Docker 镜像），只装做好的菜（生产依赖），不要锅碗瓢盆（构建工具），这个保温箱又轻又快，而且不管送到哪个顾客手里（任何 Linux 服务器），打开来都是一模一样的热饭菜。

这就是多阶段构建的核心理念：**在厨房里做菜，只把菜打包出去**。

下面我用一个真实的 Express 应用来演示整个过程。你不需要预先安装 Node.js，只需要一台装了 Docker 的机器。

---

## 1. 项目结构

```
06-01/
  Dockerfile
  .dockerignore
  package.json
  src/
    index.js
```

## 2. 应用代码

先看最核心的 Express 应用，简单到只有两个路由。

**package.json**

```json
{
  "name": "docker-express-demo",
  "version": "1.0.0",
  "description": "A simple Express app for Docker demo",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

**src/index.js**

```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ message: 'Hello from Docker!', time: new Date().toISOString() });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

这个应用有两个接口：根路径返回一条消息和时间戳，`/health` 返回健康检查状态，方便后面配合 Docker 的健康检查机制。

## 3. 写好 Dockerfile（多阶段构建）

如果你第一次写 Dockerfile，可能会写成这样：

```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "src/index.js"]
```

这能跑，但镜像体积超过 900MB，因为 `node:18` 包含了完整的操作系统、编译器、git 等一堆你生产环境根本不用的东西。

**正确的做法：多阶段构建。**

类似在餐厅后厨做饭（第一阶段），只把成品端给客人（第二阶段）。第一阶段用臃肿但工具齐全的环境来编译，第二阶段只保留运行需要的最小环境。

```dockerfile
# ========== 第一阶段：构建阶段 ==========
FROM node:18-alpine AS builder

WORKDIR /app

# 先复制依赖描述文件，利用 Docker 的层缓存
# 只要 package.json 没变，RUN npm ci 就会命中缓存，不用重新下载
COPY package.json package-lock.json* ./

# ci 比 install 更快更严格，适合 CI/CD 场景
RUN npm ci --only=production && npm cache clean --force

# ========== 第二阶段：运行阶段 ==========
FROM node:18-alpine

WORKDIR /app

# 创建一个非 root 用户来运行应用
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# 只从构建阶段复制生产依赖
COPY --from=builder /app/node_modules ./node_modules

# 复制应用代码
COPY --chown=nodejs:nodejs . .

# 切换到非 root 用户
USER nodejs

EXPOSE 3000

# 用 node 直接启动，而不是 npm start，减少一层进程包裹
CMD ["node", "src/index.js"]
```

为什么要这样做？逐行解释一下：

**`node:18-alpine`**：Alpine 是极简 Linux 发行版，整个系统才 5MB。用 Alpine 版本的 Node 镜像，基础层就比完整版小了十倍。

**`AS builder`**：给第一阶段起个名字，第二阶段用 `COPY --from=builder` 引用它。

**先 COPY package.json 再 RUN npm ci**：这是 Docker 层缓存的核心技巧。Docker 构建时，每一行 RUN/COPY 都会生成一个缓存层。如果你改了一行代码，它上面所有层都可以复用缓存，但下面所有层都得重新构建。所以把不常变的东西（依赖声明）放上面，经常变的东西（源代码）放下面。

**`--chown=nodejs:nodejs`**：把文件的所有权交给非 root 用户，让应用以受限身份运行。

**`USER nodejs`**：切换运行用户。即使攻击者攻破了你的应用，他们也拿不到 root 权限。

## 4. 写 .dockerignore

`.dockerignore` 的作用和 `.gitignore` 一样：告诉 Docker 构建时哪些文件不要送进构建上下文。没有它，`COPY . .` 会把 node_modules、日志、.git 目录都塞进去，你的构建上下文可能膨胀到几百 MB。

```
node_modules
npm-debug.log
.git
.gitignore
.env
.DS_Store
*.md
dist
coverage
.vscode
.idea
```

有了这个文件，`docker build` 发送给 Docker 守护进程的数据包就很小了，构建速度明显加快。

## 5. 构建镜像

在 `examples/06-01/` 目录下执行：

```bash
# 构建镜像，用 -t 打标签
docker build -t express-app:latest .

# 查看镜像大小
docker images express-app
```

对于这个多阶段 Dockerfile，最终镜像大约 150MB，比直接用 `node:18` 的 900MB+ 小了 6 倍。

你还可以看到构建过程中，哪些步骤命中了缓存：

```
=> [builder 2/4] COPY package*.json ./           CACHED
=> [builder 3/4] RUN npm ci --only=production    CACHED
```

第一次构建最慢，因为要下载依赖。之后只要你不动 package.json，这些层都会直接复用缓存，构建一两秒就完成了。

## 6. 运行与调试

```bash
# 基本运行：前台模式，Ctrl+C 停止
docker run --rm -p 3000:3000 express-app:latest

# 后台运行 + 自定义端口
docker run -d --name my-express -p 8080:3000 -e PORT=3000 express-app:latest

# 查看日志
docker logs -f my-express

# 进入容器里面看看
docker exec -it my-express sh

# 验证健康检查接口
curl http://localhost:8080/health
```

`-p 8080:3000` 的意思是"把宿主机的 8080 端口映射到容器的 3000 端口"。你在浏览器访问 `localhost:8080`，数据流到 Docker 代理层，再转发到容器的 3000 端口。

`-e PORT=3000` 设置环境变量，应用通过 `process.env.PORT` 读取。

`--rm` 代表容器停止后自动删除，不留垃圾。

## 7. 调试技巧：热更新开发模式

生产环境的镜像追求小和稳定，但开发时你希望改了代码立即看到效果。用 bind mount 把本地目录挂进容器：

```bash
docker run --rm -p 3000:3000 \
  -v "$(pwd)/src:/app/src" \
  -e NODE_ENV=development \
  express-app:latest
```

这样你在本地改 `src/index.js`，容器里立刻生效。不过 Node.js 默认不会热重载，你需要装个 `nodemon`，或者在开发 Dockerfile 里单独处理——这就是为什么很多项目同时维护 `Dockerfile`（生产）和 `Dockerfile.dev`（开发）。

---

## 动手试试

**目标：** 完成一次完整的"改代码 -> 构建 -> 运行 -> 验证"循环。

1. 复制 `examples/06-01/` 下的所有文件到你的工作目录
2. 给 `src/index.js` 加一个新路由 `/ping`，返回 `{ "pong": true }`
3. 重新构建镜像：`docker build -t express-app:v2 .`
4. 用 `docker run --rm -p 3000:3000 express-app:v2` 启动
5. 用 `curl http://localhost:3000/ping` 验证

观察第二次构建是否比第一次快（层缓存生效）。

预计耗时：3-5 分钟。

---

## 本节小结

多阶段构建是容器化的"标准答案"：第一阶段编译，第二阶段运行，镜像体积暴降 80%，攻击面同步缩小。

## 下一节预告

下一节用 Python Flask 做同样的事，但加入 Gunicorn 生产服务器和环境变量配置，让你感受 Python 生态的容器化套路。
