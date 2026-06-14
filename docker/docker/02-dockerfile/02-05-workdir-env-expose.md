# 02-05 WORKDIR、ENV、EXPOSE 等配置指令

## 本节你会学到什么

- 掌握 WORKDIR 的使用，避免路径拼接的错误
- 理解 ENV 和 ARG 的区别：运行时环境变量 vs 构建时参数
- 了解 EXPOSE 的文档性质及它和端口映射的关系
- 知道 USER 和 LABEL 的应用场景

## 正文

上一节我们学了 COPY，靠它在镜像里搬文件。但光搬文件不够，你还得告诉 Docker：工作目录在哪、环境变量怎么设、端口是哪个、用哪个用户运行。这些"配置性"的指令虽然不如 RUN 和 COPY 出镜率高，但缺了它们你的 Dockerfile 就很不专业。

### WORKDIR：设置"当前所在的房间"

WORKDIR 告诉 Docker："之后所有的操作，默认在哪个目录下做。"它就像你在命令行里 `cd` 到某个目录一样。

```dockerfile
WORKDIR /app
```

设好 WORKDIR 后，后续的 RUN、COPY、CMD、ENTRYPOINT 都默认在 `/app` 下执行。如果你用相对路径，就是相对这个目录：

```dockerfile
WORKDIR /app
COPY package.json ./         # 等价于 COPY package.json /app/package.json
RUN npm install               # 在 /app 下执行
CMD ["node", "index.js"]      # 在 /app 下启动
```

**WORKDIR 不像 RUN mkdir，它有一些隐藏特性：**

1. 如果目录不存在，Docker 会自动创建。
2. 可以用绝对路径多次调用，每次都在新目录。
3. 相对路径也可以用，每次都基于上一个 WORKDIR。

```dockerfile
WORKDIR /app
WORKDIR src        # 现在在 /app/src
WORKDIR ..         # 回到 /app
RUN pwd            # 输出 /app
```

**常见错误**：不用 WORKDIR，直接写 `RUN cd /app && npm install`。cd 只在那一层 RUN 里有效，下一条指令又回到了根目录。所以别用 `cd`，用 `WORKDIR`。

### ENV：镜像里的"便利贴"

ENV 设置环境变量。镜像构建时生效，容器运行时也生效。经常用于配置数据库地址、时区、语言等：

```dockerfile
ENV NODE_ENV=production \
    APP_PORT=3000 \
    TZ=Asia/Shanghai
```

ENV 的两种写法：

```dockerfile
# 写法一：一条一个（老式）
ENV MY_NAME "John Doe"
ENV MY_DOG Rex

# 写法二：一条多个（推荐，减少层数）
ENV MY_NAME="John Doe" \
    MY_DOG=Rex
```

第二种写法把所有 ENV 放在一条指令里，只产生一层，更好。

### ARG：构建时的"传话纸条"

ARG 和 ENV 很像，但有本质区别：ARG 只在**构建时**存在，容器运行时是看不到的。

```dockerfile
ARG VERSION=1.0.0
RUN echo "Building version ${VERSION}"
```

你可以通过 `--build-arg` 在构建时覆盖它的值：

```bash
docker build --build-arg VERSION=2.0.0 -t myapp .
```

ARG 的典型用途：
- 传递版本号、Git commit SHA。
- 传递构建时的密钥（注意：ARG 的值会留在镜像历史里，不适合放真正的密码！）。
- 控制条件构建（结合 RUN 的 `if` 逻辑）。

**ARG vs ENV 一句话区分**：ARG 是做菜时告诉厨师"少放盐"，只在厨房（构建阶段）知道；ENV 是贴在成品菜上的"微波加热 2 分钟"，菜端上桌（运行时）顾客也能看到。

### EXPOSE：门牌号声明

EXPOSE 告诉 Docker："这个容器里的应用会监听某个端口"。

```dockerfile
EXPOSE 3000
```

但需要注意——**EXPOSE 仅仅是文档性质的声明**，它不会自动做端口映射。你把容器跑起来时还是得用 `docker run -p 3000:3000` 来映射端口。那 EXPOSE 有什么用？

- 它相当于镜像的"说明书"，告诉使用者默认监听哪个端口。
- `docker run -P`（大写 P）会自动映射所有 EXPOSE 声明的端口到宿主机随机端口。
- 在 docker-compose 等服务编排中，EXPOSE 声明可以被其他服务发现。

```bash
# 小写 p：手动指定映射
docker run -p 8080:3000 myapp

# 大写 P：自动映射所有 EXPOSED 端口到随机宿主机端口
docker run -P myapp
```

### USER：不要用 root 跑应用

默认情况下，Docker 容器以 root 用户运行。这不好——万一应用有漏洞被攻破，攻击者就能拿到容器的 root 权限。虽然容器的 root 不等于宿主机的 root（有 namespace 隔离），但配合某些挂载和特权模式，风险依然存在。

```dockerfile
# 创建一个非 root 用户
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

从这一行之后，所有 RUN、CMD、ENTRYPOINT 都以 `appuser` 的身份执行。

注意：USER 要放在 COPY 和 RUN（安装依赖）之后，因为普通用户可能没有权限写系统目录。

### LABEL：给镜像贴标签

LABEL 给镜像添加元数据——作者、版本、描述等。方便查找和管理。

```dockerfile
LABEL maintainer="zhangsan@example.com" \
      version="1.0.0" \
      description="A simple Node.js web app"
```

用 `docker inspect` 可以看到这些标签：

```bash
docker inspect myapp | grep -A 10 Labels
```

### 一个综合示例

把这些指令串起来，看一个完整的基础 Dockerfile：

```dockerfile
FROM node:20-alpine

# 元数据
LABEL maintainer="dev@example.com" \
      version="1.0.0"

# 构建参数（构建时可覆盖）
ARG NODE_ENV=production

# 环境变量（运行时生效）
ENV NODE_ENV=${NODE_ENV} \
    APP_HOME=/app

# 工作目录
WORKDIR ${APP_HOME}

# 复制文件
COPY package*.json ./
RUN npm ci --only=production

COPY . .

# 创建非 root 用户
RUN addgroup -S app && adduser -S app -G app
USER app

# 声明端口
EXPOSE 3000

CMD ["node", "index.js"]
```

## 动手试试

为你在用的一个项目（或随便创建一个）写一个 Dockerfile，用上 WORKDIR、ENV、EXPOSE。特别注意：

1. 设好 WORKDIR 后，用相对路径 COPY 文件，确认能正常工作。
2. 添加 `EXPOSE 3000`，然后用 `docker run -P` 观察自动映射到了哪个端口（用 `docker port <容器名>` 查看）。
3. 尝试用 `--build-arg` 传入自定义参数并在 RUN 中使用。

## 本节小结

WORKDIR 设置工作目录避免 cd 陷阱；ENV 定义运行时环境变量；ARG 传递构建时参数；EXPOSE 声明监听端口；USER 降低安全风险。它们组合使用构成了 Dockerfile 的"骨架"。

## 下一节预告

下一节是重点章节——CMD 与 ENTRYPOINT 的深入对比，以及如何组合使用它们。
