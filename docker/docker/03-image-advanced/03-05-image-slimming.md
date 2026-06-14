# 03-05 镜像瘦身技巧

## 本节你会学到什么

- 掌握减小 Docker 镜像体积的多种实用方法
- 了解 dive 工具的使用——逐层分析镜像的"赘肉"
- 能够诊断和优化一个"胖"镜像
- 理解镜像大小对部署速度和安全性的影响

## 正文

### 瘦身的意义

你可能会想："镜像大点就大点呗，反正硬盘便宜。"但镜像体积的影响远不止磁盘占用：

- **拉取速度**：1.5GB 的镜像在 CI 流水线里每次拉取需要 30 秒，50MB 只需要 2 秒。一天跑 50 次构建，时间差距是实实在在的。
- **安全风险**：越大越复杂，攻击面越大。每个包都是一个潜在漏洞。
- **分发成本**：在 Kubernetes 集群里，如果某个节点挂了 Pod 要重建，大镜像拉取慢会导致服务恢复慢。
- **存储成本**：私有仓库按存储量收费，大镜像积少成多。

用"行军背包"来类比：你要去登山，背包重量直接影响你的速度和体力。不必要的工具、多余的罐头、看完的书——统统不该装在包里。镜像瘦身就是帮你的"容器行军"减负。

### 方法一：选择正确的基础镜像

这是瘦身的第一步，也是最见效的一步。选择原则：

```
alpine > slim > 完整版 > 非官方花里胡哨版
```

| 选择 | 典型大小 | 适用场景 |
|------|---------|----------|
| alpine | 5MB | 通用首选，注意 musl 兼容性 |
| slim | 70-80MB | alpine 有兼容问题时 |
| 完整版 | 200MB+ | 仅在开发和调试时 |
| scratch | 0MB | 静态编译的二进制 |

对比一下三个 Node.js 基础镜像的体积：

```bash
docker pull node:20           # ~1.1 GB
docker pull node:20-slim      # ~250 MB
docker pull node:20-alpine    # ~130 MB
```

能用 alpine 就用 alpine，有兼容问题就降级到 slim。基本没有理由用完整版作为生产镜像。

### 方法二：减少层数

如 02-03 所讲，每条 RUN 产生一层。合并相关命令：

```dockerfile
# 不好：三个层
RUN apk update
RUN apk add nginx curl vim
RUN rm -rf /var/cache/apk/*

# 好：一个层，且会清理
RUN apk update && \
    apk add --no-cache nginx curl vim
```

`--no-cache` 是 Alpine 专用参数，等价于 `apk update && apk add xxx && rm -rf /var/cache/apk/*`，一行搞定。

### 方法三：在同一层内清理

这是极容易犯错的地方：

```dockerfile
# BAD：清理无效——临时文件已经固化在前一层了
RUN apk add --no-cache nginx        # 这一层可能留下了下载缓存
RUN rm -rf /var/cache/apk/*         # 缓存在前一层，这一层只标记"隐藏"

# GOOD：安装和清理在同一层
RUN apk add --no-cache nginx
# 或者
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*
```

记住一条铁律：**删除操作必须和产生临时文件的操作放在同一条 RUN 里。**

### 方法四：包管理器优化

#### apt（Debian/Ubuntu）

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

- `--no-install-recommends`：不装推荐的附加包，通常能省几十 MB。
- `apt-get clean`：清理已下载的 .deb 包。
- `rm -rf /var/lib/apt/lists/*`：删除包列表，节省约 20-40MB。

#### apk（Alpine）

```dockerfile
RUN apk add --no-cache nginx
```

`--no-cache` 一步到位——在线更新索引、安装、删除本地缓存。不需要额外的 `rm` 步骤。

#### pip（Python）

```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
```

`--no-cache-dir` 不缓存下载的包，能省几十 MB。

#### npm（Node.js）

```dockerfile
RUN npm ci --only=production && npm cache clean --force
```

`--only=production` 跳过 devDependencies，`npm cache clean --force` 清理 npm 缓存。

### 方法五：.dockerignore

至少排除以下内容：

```
node_modules
.git
*.log
.env*
.gitignore
Dockerfile
.dockerignore
README.md
```

### 方法六：删除安装后不需要的文件

有些包带了文档、示例、测试文件——运行时根本不需要：

```dockerfile
RUN apk add --no-cache python3 && \
    find /usr/lib/python* -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null; \
    find /usr/lib/python* -type d -name 'test' -exec rm -rf {} + 2>/dev/null; \
    find /usr/lib/python* -type d -name 'tests' -exec rm -rf {} + 2>/dev/null
```

删除 `.pyc` 缓存文件和测试目录，能省 5-20MB。

### 使用 dive 工具分析镜像

dive 是一个开源工具，可以逐层查看镜像的内容变化，帮助你找到"赘肉"在哪里。

**安装：**

```bash
# macOS
brew install dive

# Linux
curl -L https://github.com/wagoodman/dive/releases/latest/download/dive_linux_amd64.deb -o dive.deb
sudo apt install ./dive.deb

# Docker 方式运行（无需安装）
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest nginx:latest
```

**使用：**

```bash
dive myapp:latest
```

dive 会显示：
- 每一层增加了多少数据（Added）、删除了多少数据（Deleted）、浪费了多少空间（Wasted）。
- 如果某层的 "Wasted" 很大，说明那一层里有"先增加又通过后续层删除"的文件——这就是优化目标。

在 dive 的交互界面里，你可以逐层浏览文件树，看看每个文件是在哪一层引入的。

### 瘦身前后对比示例

一个典型的 Node.js Express 应用：

| 阶段 | 措施 | 镜像大小 |
|------|------|---------|
| 初始 | FROM node:20 + npm install（含 devDependencies）| ~1.5 GB |
| 优化 1 | FROM node:20-alpine | ~250 MB |
| 优化 2 | npm ci --only=production | ~180 MB |
| 优化 3 | 多阶段构建（builder + runner）| ~150 MB |
| 优化 4 | 添加 .dockerignore，清理 npm 缓存 | ~140 MB |
| 优化 5 | 使用 distroless/nodejs（如果有）| ~130 MB |

经过一系列优化，从 1.5GB 减到 150MB 以下，缩小了 10 倍。

### 不要过度优化

瘦身的反面是过度优化。如果你的 Dockerfile 为了省 5MB 而多写了 20 行难以维护的 hack 代码，那不值得。记住一个原则：

> 优化应该让 Dockerfile 更清晰，而不是更复杂。

如果一个优化手段显著增加了维护成本（比如复杂的 find -exec 删除命令），先想想你的镜像真的需要省那几 MB 吗？

## 动手试试

1. 找一个你自己的"胖"镜像，用 `docker history` 查看最大的层，分析是哪里占了空间。
2. 安装 dive，用它分析同一个镜像，看看哪一层有最多的 "Wasted" 空间。
3. 对 Dockerfile 做优化（改 alpine、合并 RUN、加 --no-cache 参数），对比优化前后的镜像体积。
4. 总结一份你自己的"瘦身清单"，以后每次写 Dockerfile 时用。

## 本节小结

镜像瘦身的三大法宝：选最轻量的基础镜像（alpine）、在同一个 RUN 里安装并清理、用多阶段构建去掉构建工具。dive 工具帮你可视化每一层的增减，精准定位"赘肉"。

## 下一节预告

下一节我们学习 docker save/load 和 docker export/import——如何把镜像导出为文件，以及它们之间的区别和适用场景。
