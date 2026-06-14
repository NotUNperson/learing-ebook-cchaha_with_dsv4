# 06-05 Docker 性能优化技巧

## 本节你会学到什么

- 掌握 Docker 层缓存机制，把构建时间从 5 分钟压到 10 秒
- 对比不同基础镜像的体积差异：Alpine vs Slim vs 完整版
- 使用多阶段构建的编译缓存（BuildKit cache mount）加速编译型语言
- 配置资源限制（--memory、--cpus）防止一个容器拖垮整台宿主机
- 利用 .dockerignore 减小构建上下文，加速构建的第一步

---

## 1. 层缓存：让构建飞起来

Docker 构建镜像就像烤千层蛋糕，每一层（`RUN`, `COPY`, `ADD`）单独烤。如果你动了某一层的食材，它和它上面的所有层都要重烤，但下面的层可以直接复用。

**层缓存的核心规则：**
- 一旦某层发生变化，它之后的所有层缓存全部失效
- 把不常变的放在前面，常变的放在后面

**反面教材（缓存总是失效）：**

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .              # 改了任何一行代码，这层就失效
RUN npm ci            # 因此这层也失效，每次都要重装依赖
CMD ["node", "index.js"]
```

每次改一行代码，npm ci 都要重跑一遍，100MB 的依赖每次重新下载。

**正面教材（最大化缓存命中）：**

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package.json package-lock.json* ./   # 依赖声明单独复制
RUN npm ci                                  # 只有依赖变时才重装
COPY . .                                    # 代码最后复制
CMD ["node", "index.js"]
```

效果：日常开发 99% 的时间只改源代码不改依赖，前两步命中缓存，构建只需 2 秒。

**类比：** 好比你去咖啡店点拿铁。店家的咖啡豆、牛奶早就准备好了（依赖缓存），你点了之后只需要把咖啡倒进杯子（复制代码），30 秒出杯。如果每次点单都要现磨豆子、现买牛奶，一杯拿铁要等 20 分钟。

---

## 2. 基础镜像体积对比

同一个 Express 应用，用不同基础镜像打包，体积能差多少？我们做个对比实验。

**docker image ls 实测数据（Express 应用 + node_modules）：**

| 基础镜像 | 最终体积 | 说明 |
|----------|---------|------|
| `node:18` | ~950MB | 完整 Debian + 编译器 + git + ... |
| `node:18-slim` | ~250MB | 精简 Debian，去掉编译工具 |
| `node:18-alpine` | ~150MB | Alpine Linux，仅 5MB 基础系统 |

Alpine 比完整版小了 6 倍以上。这意味着：
- 推送到镜像仓库快 6 倍
- CI/CD 流水线快 6 倍
- K8s 拉取镜像快 6 倍
- 磁盘占用少 6 倍

**选择建议：**

```
能用 alpine 就用 alpine
需要 glibc（某些 Python 科学计算包）用 slim
实在不行才用完整版
```

**类比：** 完整版镜像好比搬家时把所有家具、衣服、锅碗瓢盆连同房子地基一起搬走。Alpine 则是只带一个行李箱——够用就行。

---

## 3. .dockerignore 的威力

`.dockerignore` 的作用不只是减少文件数量，更重要的是**影响构建性能**。每次 `docker build`，Docker 客户端会把整个构建上下文（当前目录）打包发送给 Docker 守护进程。如果你有 500MB 的 `node_modules`、几百 MB 的 `.git` 目录，这个传输过程就会成为瓶颈。

**没有 .dockerignore 时：**

```bash
# 构建上下文可能几百 MB
docker build -t myapp .
# Sending build context to Docker daemon  487.2MB   <-- 慢！
```

**有 .dockerignore 后：**

```bash
docker build -t myapp .
# Sending build context to Docker daemon   2.56MB   <-- 快！
```

**一个全面的 .dockerignore：**

```
node_modules
.git
*.log
.env
.DS_Store
coverage
dist
build
.vscode
.idea
*.md
docker-compose*.yml
```

---

## 4. 多阶段构建的编译缓存（BuildKit）

对于编译型语言（Go、Rust、Java、前端），构建阶段要下载依赖、编译代码，这个阶段通常最耗时。BuildKit 提供了一个高级功能：**缓存挂载（cache mount）**，把依赖缓存持久化到宿主机，跨构建复用。

**Go 应用示例（使用缓存挂载）：**

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.21-alpine AS builder
WORKDIR /app

# 缓存 Go 模块下载
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download

COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -o /app/server .

FROM alpine:3.19
COPY --from=builder /app/server /server
CMD ["/server"]
```

`--mount=type=cache` 把 `/go/pkg/mod` 目录缓存到宿主机的 BuildKit 缓存区。第二次构建时，Go 模块下载直接走缓存，编译也因为有缓存的中间产物而大幅加速。

**Node.js 前端的类比用法：**

```dockerfile
# syntax=docker/dockerfile:1
FROM node:18-alpine AS builder
WORKDIR /app

# 缓存 npm 下载
RUN --mount=type=cache,target=/root/.npm \
    npm ci

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

**类比：** 普通构建是每次做饭都去超市买菜；BuildKit 缓存挂载是家里有个冰箱——米面油盐常备，只买新鲜蔬菜即可。

---

## 5. 资源限制：不让一个容器拖垮整台机器

容器共享宿主机的 CPU 和内存。如果不做限制，一个容器里的内存泄漏或 CPU 死循环可能拖垮同宿主机上的所有其他容器。

**内存限制：**

```bash
# 限制最大 256MB 内存，超了就杀进程
docker run --memory=256m --memory-swap=256m myapp

# Docker Compose 中
services:
  app:
    image: myapp
    deploy:
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M   # 软限制（调度建议）
```

- `--memory`：硬限制，超过后容器被 OOM Killer 杀掉
- `--memory-swap`：swap 总量。设为和 memory 一样的值表示禁用 swap
- `reservations`：软限制，Docker 调度时参考，但不强制

**CPU 限制：**

```bash
# 最多使用 1.5 个 CPU 核心
docker run --cpus=1.5 myapp

# Compose 版本
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '1.5'
```

**验证资源限制是否生效：**

```bash
# 创建并启动一个受限的容器
docker run -d --name limited --memory=128m --cpus=0.5 nginx

# 查看容器的实时资源消耗
docker stats limited

# 尝试耗尽内存（会在达到 128MB 时被 kill）
docker exec limited sh -c "stress --vm 1 --vm-bytes 200M"
```

**类比：** 资源限制就像合租房的分摊协议——电费每人每月不超过 200 块。没有这个协议，某个室友开矿机挖比特币，电费暴涨，所有人都得跟着背锅。

---

## 6. 日志轮转：防止日志撑爆磁盘

Docker 默认把容器的 stdout/stderr 写到 JSON 文件中，而且**默认不轮转**。如果你有一个高频输出日志的应用，几天不清理，日志文件可能把磁盘撑满。

**配置日志轮转（daemon.json 全局）：**

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

**单容器配置：**

```bash
docker run --log-opt max-size=10m --log-opt max-file=3 myapp
```

**docker-compose 中：**

```yaml
services:
  app:
    image: myapp
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

这样每个容器的日志最多占用 30MB（3 个文件 x 10MB），旧的自动滚动删除。

---

## 性能清单总结

| 优化手段 | 效果 | 实施成本 |
|----------|------|---------|
| 层缓存排序（依赖放前面） | 构建快 10-100 倍 | 低（改 Dockerfile 就行） |
| Alpine 基础镜像 | 体积减 80% | 低（换个标签） |
| .dockerignore | 构建上下文减 90%+ | 低（写个文件） |
| 多阶段构建 | 体积减 60%+ | 中（重构 Dockerfile） |
| BuildKit 缓存挂载 | 重复构建快 3-10 倍 | 中（需要学习） |
| 资源限制 | 防单点故障 | 低（加几个参数） |
| 日志轮转 | 防磁盘爆满 | 低（配置几行） |

---

## 动手试试

**目标：** 亲身体验 .dockerignore 和基础镜像对构建速度和体积的影响。

1. 进入 `examples/06-01/` 项目目录
2. 临时删除（或重命名）`.dockerignore`，执行 `docker build -t test-big .`，注意构建上下文大小
3. 恢复 `.dockerignore`，再次构建，对比构建上下文大小的差异
4. 修改 Dockerfile，把 `node:18-alpine` 改成 `node:18-slim`，构建并比较 `docker images` 的体积差异

预计耗时：5 分钟。

---

## 本节小结

性能优化的核心只有一句话：能不做的别做（.dockerignore），做过的别重做（层缓存），能分阶段做的分阶段做（多阶段构建），该设上限的设上限（资源限制 + 日志轮转）。

## 下一节预告

不管写得多好，容器总会出问题。下一节我们整理一套完整的排错方法论：症状 - 原因 - 解决方案，覆盖容器启动就退出、端口冲突、磁盘爆满、网络不通、权限问题五大高频故障。
