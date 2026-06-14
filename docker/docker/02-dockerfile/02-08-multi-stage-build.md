# 02-08 多阶段构建

## 本节你会学到什么

- 理解多阶段构建解决的核心问题：编译依赖 vs 运行依赖的分离
- 掌握多阶段构建的语法：AS 别名、--from 引用、--target 部分构建
- 能够编写包含构建和运行两个（或多个）阶段的 Dockerfile
- 学会用多阶段构建处理前端、Go、Java 等场景

## 正文

### 问题：你的镜像为什么这么胖？

看一个常见场景。你要用 Node.js 写一个网站。构建时需要：

1. 安装 npm 依赖（包括 devDependencies）
2. 运行 webpack/vite 把源码打包成 dist 目录
3. 用 nginx 来托管 dist 下的静态文件

如果不做优化，你可能会写一个这样的 Dockerfile：

```dockerfile
FROM node:20
WORKDIR /app
COPY . .
RUN npm ci                    # 装了所有依赖，包括 devDependencies
RUN npm run build             # 生成 dist/
CMD ["npx", "serve", "dist"]  # 用 node 的 serve 来托管
```

这个镜像有多大？`node:20` 镜像本身就有 1.1GB，加上 `node_modules` 里几百 MB 的依赖——最终镜像可能是 1.5GB。但你运行的时候只需要 `dist/` 目录下的几个 HTML/JS/CSS 文件！

这就是典型的问题：**构建时需要的工具和依赖，运行时根本用不到，但它们都留在了最终镜像里。**

### 解决方案：搬家装修类比

想象你要搬进一套毛坯房：

1. **装修阶段**：工人进场，水泥、电钻、涂料满屋子都是。灰尘满天，工具满地。这时候房子不能住人。
2. **入住阶段**：装修队撤了，工具带走，房间打扫干净，家具搬进来。这时候房子干净整洁，可以住了。

在这个类比里：
- **装修阶段** = 多阶段构建的第一个阶段（builder）。你有所有工具（编译器、devDependencies），但产物（dist/）才是你真正需要的。
- **入住阶段** = 多阶段构建的第二个阶段（runner）。你只把装修完的成果（dist/）带过来，放一个干净的房子里（nginx），源材料和工具都不要。

### 多阶段构建的基本语法

```dockerfile
# 阶段一：构建（装修）
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# 阶段二：运行（入住）
FROM nginx:alpine AS runner
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

关键点：
- `AS builder` 给阶段命名，方便后续引用。
- `COPY --from=builder` 从 builder 阶段复制文件到当前阶段。
- 最终镜像只有第二个阶段的内容——nginx alpine 加上 dist 目录，大概 50MB。

对比单阶段构建的 1.5GB，多阶段构建把镜像缩小了 **30 倍**。

### 更复杂的例子：三阶段构建

有些场景需要三个阶段。比如 Go 应用：

```dockerfile
# 阶段一：下载依赖（缓存友好）
FROM golang:1.22-alpine AS deps
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

# 阶段二：编译（用上一阶段的缓存）
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY --from=deps /go/pkg/mod /go/pkg/mod
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .

# 阶段三：运行（极简镜像）
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
```

最终镜像只有编译好的二进制文件，可能才 10MB。

### 多阶段构建的几个实用技巧

**1. 只从前面阶段拿你需要的文件**

```dockerfile
FROM node:20-alpine AS builder
RUN npm run build
# 生成了 dist/ 和 report.html

FROM nginx:alpine
# 只拿 dist，不拿 report.html（那是给开发者看的构建报告）
COPY --from=builder /app/dist /usr/share/nginx/html
```

**2. 多阶段同时支持开发和生产**

```dockerfile
FROM node:20-alpine AS dev
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
CMD ["npm", "run", "dev"]

FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine AS prod
COPY --from=build /app/dist /usr/share/nginx/html
```

你可以分别构建：

```bash
# 开发镜像
docker build --target dev -t myapp:dev .

# 生产镜像
docker build --target prod -t myapp:prod .
```

**3. 从前一阶段复制工具**

有时候你没有安装某个工具，但前一个阶段有：

```dockerfile
FROM golang:1.22 AS builder
RUN go install github.com/some/tool@latest
COPY . .
RUN tool build -o app .

FROM alpine
# 从前一阶段借工具来用
COPY --from=builder /go/bin/tool /usr/local/bin/tool
COPY --from=builder /app/app /app
```

### 不需要多阶段构建的情况

不是所有项目都需要多阶段构建。以下情况单阶段就够了：

- 解释型语言（Python、Node.js 非编译），运行时也需要解释器和依赖，没有"编译产物"可以单独拎出来。
- 应用本身就很小，优化意义不大。
- 你用的是虚拟环境 + 依赖缓存，构建环境就是运行环境。

不过即使对 Python/Node.js 应用，多阶段也可以用来跑测试：

```dockerfile
FROM python:3.12 AS test
COPY . .
RUN pip install pytest && pytest

FROM python:3.12-slim AS prod
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
CMD ["python", "app.py"]
```

测试失败则构建失败，测试结果也不会进入生产镜像。

### 常见语言的多阶段构建模板

**前端（React/Vue/Angular）**：

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
```

**Java (Spring Boot)**：

```dockerfile
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM eclipse-temurin:21-jre-alpine
COPY --from=build /app/target/*.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

**Rust**：

```dockerfile
FROM rust:1.77 AS build
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
COPY --from=build /app/target/release/myapp /usr/local/bin/myapp
ENTRYPOINT ["/usr/local/bin/myapp"]
```

Rust 的例子有个有趣的技巧：利用一个空的 main.rs 先编译依赖（依赖变化少），再复制真正的源码编译主程序。这样改代码时能复用依赖编译的缓存。

## 动手试试

找一个你之前用过的前端或 Node.js 项目（或创建一个简单的 React/Vue 项目）：

1. 写一个单阶段的 Dockerfile，构建后记下镜像大小。
2. 改为多阶段构建（build 阶段 + nginx 或 node:slim 运行阶段），构建后对比镜像大小。
3. 用 `--target` 只构建到 builder 阶段，`docker run` 进去看看构建产物是否正确。

## 本节小结

多阶段构建把"编译"和"运行"分离：第一阶段用重型镜像 + 完整工具链来做构建，第二阶段只拿构建产物放进轻量镜像运行。这是减小生产镜像体积最有效的方法。

## 下一节预告

下一节我们学习 .dockerignore 和层缓存优化——了解 Docker 的缓存机制，让你的构建快上加快。
