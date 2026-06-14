# 02-07 docker build 详解

## 本节你会学到什么

- 掌握 `docker build` 的核心参数和用法
- 理解构建上下文的概念，避免发送不必要的文件
- 学会用 --build-arg 传递构建参数、--target 进行阶段性构建
- 了解 --no-cache 和 --cache-from 的使用场景

## 正文

前面几节我们一直在写 Dockerfile，但写的目的是为了 `docker build`。这一节我们专门来聊聊 `docker build` 这个命令本身——它的各种参数能让你在构建时更灵活、更高效。

### 基本命令回顾

```bash
docker build -t 镜像名:标签 构建上下文路径
docker build -t myapp:v1.0 .
```

- `-t`（或 `--tag`）：给镜像命名和打标签。格式是 `名称:标签`，如果不写标签默认是 `latest`。
- 最后的 `.`：构建上下文路径，注意不是 Dockerfile 的路径，而是构建时能访问的文件范围的根目录。

### 构建上下文：别把整个家搬过去

`docker build` 时，Docker 做的第一件事不是执行 Dockerfile，而是把构建上下文（就是命令最后的那个路径）打包发送给 Docker 引擎。

假如你在用户目录 `~/` 下执行 `docker build -t myapp .`，Docker 会把你的整个用户目录（可能几十 GB）打包发给 docker daemon。这个过程可能非常慢，而且占用大量内存。

正确的做法：在项目目录下构建，并且用 `.dockerignore` 排除不需要的文件（详见 02-09）。

```bash
# 好：在项目目录下构建
cd /path/to/myapp
docker build -t myapp .

# 也可以用 -f 指定 Dockerfile 位置
docker build -f /path/to/Dockerfile.prod -t myapp:prod .
```

`-f` 参数指定 Dockerfile 的路径，当 Dockerfile 不叫 `Dockerfile` 或者不在当前目录时使用。注意：无论 Dockerfile 在哪，构建上下文还是最后一个参数指定的目录。

### 标签管理：-t 的各种用法

```bash
# 单个标签
docker build -t myapp:v1.0 .

# 多个标签（同一个镜像可以有多个标签）
docker build -t myapp:v1.0 -t myapp:latest -t myapp:abc123 .

# 包含仓库地址（准备推送）
docker build -t docker.io/username/myapp:v1.0 .
docker build -t myregistry.com:5000/myapp:v1.0 .
```

给同一个镜像打多个标签很方便：发布时打上版本号和 latest，方便用户通过不同方式引用。

### --build-arg：构建时传参

还记得 02-05 里讲的 ARG 指令吗？`--build-arg` 就是在构建时给 ARG 赋值的：

```bash
docker build --build-arg NODE_VERSION=20 --build-arg APP_ENV=production -t myapp .
```

Dockerfile 里：

```dockerfile
ARG NODE_VERSION=18
FROM node:${NODE_VERSION}-alpine
ARG APP_ENV
RUN echo "Building for ${APP_ENV}"
```

注意 ARG 的作用域：FROM 之前声明的 ARG 只在 FROM 之前有效。要在 FROM 之后用，需要在 FROM 后面再声明一次（不带默认值也可以，通过 --build-arg 传入）。

### --no-cache：强制重来

Docker 构建会尽可能使用缓存。但有时候缓存会让你用上过时的依赖：

```bash
# 更新 apt 源时会缓存，可能导致你一直用的是旧的包列表
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y nginx
```

这种情况下加 `--no-cache` 强制重新执行所有指令：

```bash
docker build --no-cache -t myapp .
```

适合在以下场景使用：
- CI/CD 流水线的发布构建（确保没有缓存污染）。
- 排查构建问题时（先排除缓存干扰）。
- 需要用最新的外部资源时。

日常开发还是用缓存，节省时间。

### --target：多阶段构建的部分构建

多阶段构建（下一节详细讲）允许你只构建到某个阶段：

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine AS runner
COPY --from=builder /app/dist /usr/share/nginx/html
```

```bash
# 只构建 builder 阶段（调试用）
docker build --target builder -t myapp:builder .

# 构建完整镜像
docker build -t myapp:latest .
```

这在调试多阶段构建时非常有用——你可以停在中间阶段，检查里面的文件是否正确。

### --cache-from：共享缓存

在 CI/CD 环境中，每次构建都是全新的环境，没有本地缓存。可以通过 `--cache-from` 从远程仓库拉取之前的镜像作为缓存：

```bash
# 先拉取上次构建的镜像作为缓存源
docker pull myregistry.com/myapp:cache || true

# 使用拉取的镜像作为缓存
docker build \
  --cache-from myregistry.com/myapp:cache \
  -t myregistry.com/myapp:latest \
  -t myregistry.com/myapp:cache \
  .

# 推送新的缓存镜像
docker push myregistry.com/myapp:cache
```

### --platform：跨平台构建

如果你的机器是 Mac M 系列芯片（ARM）但要构建 x86（AMD64）镜像，或者反过来：

```bash
docker build --platform linux/amd64 -t myapp:amd64 .
```

也可以一次性构建多平台镜像（需要 `docker buildx`）：

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:multi-arch .
```

### 参数速查表

| 参数 | 作用 | 常用度 |
|------|------|--------|
| `-t, --tag` | 镜像名:标签 | 必用 |
| `-f, --file` | 指定 Dockerfile 路径 | 中频 |
| `--build-arg` | 设置构建参数 | 中频 |
| `--no-cache` | 不使用缓存 | 中频 |
| `--target` | 多阶段构建的目标阶段 | 中频 |
| `--cache-from` | 指定外部缓存源 | CI 专用 |
| `--platform` | 指定目标平台 | 低频 |
| `--pull` | 强制拉取最新基础镜像 | 中频 |
| `-q, --quiet` | 只输出镜像 ID | 脚本用 |

### 构建输出解读

当你运行 `docker build` 时，每一行的输出都告诉你当前指令的状态：

```
=> [1/5] FROM node:20-alpine@sha256:abc...
=> CACHED [2/5] WORKDIR /app
=> [3/5] COPY package*.json ./
=> [4/5] RUN npm ci
=> [5/5] COPY . .
=> exporting to image
```

- `=>` 表示正在执行
- `CACHED` 表示使用了缓存，没有重新执行
- `[3/5]` 表示第 3 步，共 5 步

如果某一步失败，错误信息会告诉你具体是哪一步出了问题——这是排查构建错误的起点。

## 动手试试

1. 找一个已有的 Dockerfile，用不同的 `-t` 标签构建同一个镜像，然后用 `docker images` 观察同一个 IMAGE ID 对应多个标签。
2. 在 Dockerfile 中加一个 ARG，然后用 `--build-arg` 传入不同值构建两次，观察 RUN 的输出是否不同。
3. 用 `--no-cache` 构建一次，再不用它构建一次，对比构建耗时。

## 本节小结

`docker build` 是 Dockerfile 的执行引擎。`-t` 打标签，`--build-arg` 传参数，`--no-cache` 控制缓存，`.dockerignore` + 合理的构建上下文路径防止发送垃圾文件到 daemon。

## 下一节预告

下一节是多阶段构建——Dockerfile 进阶最重要的技巧，帮你实现"构建环境脏乱差、运行环境干净小"。
