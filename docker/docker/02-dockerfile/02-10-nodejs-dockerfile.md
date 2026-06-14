# 02-10 综合练习：编写生产级 Node.js Dockerfile

## 本节你会学到什么

- 将前 9 节学到的所有知识整合到一个实际项目中
- 为 Node.js 应用编写从开发到生产的完整 Dockerfile
- 掌握 .dockerignore、多阶段构建、缓存优化、安全加固的实际运用
- 能够独立为真实项目编写生产级 Dockerfile

## 正文

前面九节我们分别学了 Dockerfile 的各个部件。这一节我们把所有知识串起来，为一个真实的 Node.js Express 应用编写一套生产级的 Docker 配置。

### 我们的应用

假设我们有一个简单的 Express API 服务器，它有一个 `/api/hello` 接口返回 JSON，还有一个 `/health` 健康检查接口。应用用 TypeScript 编写，需要编译成 JavaScript 才能运行。

项目结构：

```
02-10-nodejs-dockerfile/
  src/
    index.ts                 # Express 应用入口
  package.json               # 依赖声明
  tsconfig.json              # TypeScript 配置
  .dockerignore              # 排除不需要的文件
  Dockerfile                 # 生产级多阶段构建
```

### 第一步：写 .dockerignore

打开 `examples/02-10/` 目录，你会看到完整的项目文件。我们先看 `.dockerignore`，它必须在写 Dockerfile 之前就定好，否则 COPY 时可能把 `node_modules` 等垃圾带进去。

```
node_modules
dist
.git
.env
.env.*
*.log
npm-debug.log*
coverage
.vscode
.idea
Dockerfile
.dockerignore
README.md
```

### 第二步：分析并设计 Dockerfile 的结构

用多阶段构建（02-08），分三个阶段：

- **base**（基础层）：安装生产依赖。被 dev 和 prod 共用。
- **dev**（开发层）：继承 base，安装所有依赖，用 ts-node 直接跑 TypeScript。
- **prod**（生产层）：继承 base，编译 TypeScript，只保留生产依赖和编译产物。

这样设计的好处：base 层的 `npm ci --only=production` 在 dev 和 prod 之间共享，开发和生产用的依赖是一致的。

### 第三步：编写 Dockerfile

```dockerfile
# ===== 阶段一：基础 =====
# 安装生产依赖，被 dev 和 prod 共用
FROM node:20.11.0-alpine3.19 AS base

# 安装 dumb-init 处理信号转发
RUN apk add --no-cache dumb-init

WORKDIR /app

# 元数据
LABEL maintainer="dev@myapp.com" \
      description="Express API server"

# 声明构建参数
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# 先拷贝依赖文件（缓存友好）
COPY package.json package-lock.json ./

# 安装所有依赖（包括 devDependencies，builder 阶段要用）
RUN npm ci && npm cache clean --force

# 创建非 root 用户
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app

# ===== 阶段二：开发 =====
FROM base AS dev

# 覆盖环境变量
ENV NODE_ENV=development

# 安装 nodemon 用于热重载
RUN npm install --save-dev nodemon

# 复制源码
COPY --chown=appuser:appgroup tsconfig.json ./
COPY --chown=appuser:appgroup src/ ./src/

USER appuser

EXPOSE 3000
CMD ["npx", "nodemon", "--exec", "ts-node", "src/index.ts"]

# ===== 阶段三：生产构建 =====
FROM base AS builder

COPY tsconfig.json ./
COPY src/ ./src/

# 编译 TypeScript
RUN npm run build

# ===== 阶段四：生产运行 =====
FROM node:20.11.0-alpine3.19 AS prod

RUN apk add --no-cache dumb-init

WORKDIR /app

LABEL maintainer="dev@myapp.com" \
      version="1.0.0"

ENV NODE_ENV=production \
    APP_PORT=3000

# 从 builder 阶段拷贝编译产物
COPY --from=builder /app/dist ./dist

# 从 base 阶段拷贝 node_modules（只有生产依赖）
COPY --from=base /app/node_modules ./node_modules

# 拷贝 package.json 作为参考
COPY package.json package-lock.json ./

# 创建非 root 用户
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

# dumb-init 作为入口，确保信号正确转发
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

### 设计思路解析

这个 Dockerfile 值得解释的几个设计决策：

**1. 为什么用 dumb-init？**

Node.js 进程默认不响应 SIGTERM 信号（除非你手动写处理代码），`docker stop` 时会有 10 秒超时然后被强杀。dumb-init 是一个极小的 init 进程，它能正确地把信号转发给子进程，让你的应用可以优雅退出。

**2. 为什么 base 层要装 devDependencies？**

builder 阶段继承 base，需要 TypeScript 编译器（它是 devDependency）。如果不装 devDependencies，`npm run build` 会直接报错。

**3. USER 指令放在最后？**

尽可能让前面的层以 root 执行（安装包、编译），只在最后的运行阶段切换到非 root 用户。这样既安全又不影响构建过程。

**4. CMD 用 exec 形式？**

是的。exec 形式确保 node 进程成为 PID 1（在 dumb-init 之后），能正确接收信号。

### 构建和运行

```bash
# 进入示例目录
cd examples/02-10

# 构建生产镜像
docker build --target prod -t myapp:1.0.0 .

# 构建开发镜像
docker build --target dev -t myapp:dev .

# 运行生产容器
docker run -p 3000:3000 myapp:1.0.0

# 测试接口
curl http://localhost:3000/api/hello
# 返回: {"message":"Hello, Docker!"}

curl http://localhost:3000/health
# 返回: {"status":"ok"}

# 运行开发容器（带热重载）
docker run -p 3000:3000 -v "$(pwd)/src:/app/src" myapp:dev
```

### 镜像大小对比

如果不用多阶段构建，用单阶段 `FROM node:20` 一把梭：

- 镜像大小：约 1.2GB（含完整 Debian 系统 + 所有 devDependencies + 源码）

用多阶段构建 + Alpine：

- 生产镜像：约 150MB（Alpine + 生产依赖 + 编译产物）
- 缩小了约 8 倍

### 安全要点

这个 Dockerfile 融入了几个安全实践：
- 非 root 用户运行（USER appuser）
- 固定基础镜像版本（`node:20.11.0-alpine3.19`）
- dumb-init 处理信号
- 生产镜像不含 devDependencies 和源码
- user 命名空间 + 组权限管理

### Dockerfile 检查清单

以后你写 Dockerfile 时，用这个清单自查：

- [ ] 基础镜像用了精确版本号还是 `latest`？
- [ ] `.dockerignore` 排除了 `node_modules`、`.git`、日志文件？
- [ ] COPY 顺序：依赖文件在前，源码在后？
- [ ] RUN 命令是否用 `&&` 合并了相关操作？
- [ ] 包管理器缓存是否在同一层清除了？
- [ ] 是否使用了多阶段构建（如果适用）？
- [ ] 最终镜像是否以非 root 用户运行？
- [ ] CMD/ENTRYPOINT 是否用了 exec 形式？
- [ ] EXPOSE 声明了正确的端口？

## 动手试试

1. 复制 `examples/02-10/` 下的项目，构建并运行验证。
2. 修改 `src/index.ts` 加一个新的路由（比如 `/api/time` 返回当前时间），重建镜像并测试。
3. 用 `docker history myapp:1.0.0` 查看生产镜像的层结构，找出最大的层并思考能否进一步优化。
4. 尝试改为 `FROM node:20-slim` 作为基础镜像，对比体积变化。

## 本节小结

生产级 Dockerfile = 精确版本的基础镜像 + .dockerignore + 缓存友好的 COPY 顺序 + 多阶段构建 + 合并 RUN + 非 root 用户 + exec 形式的 CMD/ENTRYPOINT。这八个要素缺一不可。

## 模块 02 总结

恭喜你完成了 Dockerfile 编写的全部 10 节内容！你现在应该能够：

- 阅读和理解任何 Dockerfile
- 从零编写生产级的 Dockerfile
- 利用多阶段构建减小镜像体积
- 通过层缓存优化加速构建
- 选择合适的 `FROM` 基础镜像

接下来是模块 03：Docker 镜像管理进阶，我们会学习标签管理、镜像仓库、镜像瘦身等实用技能。
