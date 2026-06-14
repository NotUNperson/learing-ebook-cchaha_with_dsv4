# 03-01 镜像标签策略

## 本节你会学到什么

- 理解 Docker 镜像标签的本质和 latest 标签的陷阱
- 掌握语义化版本标签策略（semver）
- 学会给同一个镜像打多个标签
- 能够制定适合团队的标签命名规范

## 正文

### 标签就是"别名"

Docker 镜像的标签（tag）就像是给镜像起的一个"花名"。每个镜像有一个唯一的 Image ID（12 位的 hash），但这个 ID 太难记了，标签就是让人能看懂的名字。

```bash
docker images
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
nginx        alpine    abc123def456   3 weeks ago    45MB
nginx        latest    abc123def456   3 weeks ago    45MB
nginx        1.25      def789abc012   2 months ago   50MB
```

注意上面：`nginx:alpine` 和 `nginx:latest` 指向了同一个 Image ID。这说明它们是同一个镜像的不同标签。换个说法，标签就像"昵称"——同一个人（同一个镜像），你可以叫他"老王"（latest）、"王工程师"（1.25）、或者"王小明"（alpine）。

### latest 标签的陷阱

`latest` 是 Docker 的默认标签——当你拉镜像不写标签时，Docker 自动给你补一个 `:latest`。但 `latest` 有一个巨大的陷阱：

**latest 不一定是"最新的稳定版"**。它只是"最近一次构建时没有显式指定标签的镜像"。换句话说，latest 指向什么完全取决于镜像维护者的构建流程。

举个例子：

```bash
# 维护者执行了这些构建
docker build -t myapp:1.0.0 .
docker build -t myapp:2.0.0 .
docker build -t myapp .

# 结果
# myapp:latest 指向第三次构建的镜像
# myapp:2.0.0 指向第二次构建的镜像
# myapp:latest 和 myapp:2.0.0 可能根本不一样！
```

更危险的是：就算你今天确定了 latest 的内容，下次你拉取时，latest 可能已经被作者更新成了不同的镜像。这对"可重复性"是致命的。

**生产环境铁律：永远不要用 latest 标签**。写 Dockerfile 时用精确版本号，拉镜像时也别偷偷省略标签。

### 语义化版本标签

社区最常用的标签方案是**语义化版本**（Semantic Versioning，简称 semver）：

```
主版本号.次版本号.修订号  →  2.1.3
```

- **主版本号**：不兼容的 API 修改。大版本更新。
- **次版本号**：向下兼容的功能新增。
- **修订号**：向下兼容的问题修复。

对应的标签策略：

```bash
# 构建一个镜像，打多个标签
docker build -t myapp:2 -t myapp:2.1 -t myapp:2.1.3 -t myapp:latest .
```

这样不同用户可以根据自己的需求锁定不同精度：

- `myapp:2` —— "我要最新的 2.x"
- `myapp:2.1` —— "我要最新的 2.1.x"
- `myapp:2.1.3` —— "我就要这个版本，一点都不能变"
- `myapp:latest` —— "随便，什么最新给我什么"

生产环境应该用 `2.1.3` 这种精确版本。开发环境可以用 `2.1` 或 `2`。

### 标签命名规则

Docker 对标签的命名有一些限制：

- 只能包含小写字母、数字、`.`、`-`、`_`
- 最多 128 个字符
- 不能以 `.` 或 `-` 开头
- 不推荐使用 `:`（它用于分隔仓库和标签）

常见标签模式：

```
# 版本标签
myapp:1.0.0
myapp:1.0.0-alpine
myapp:1.0.0-slim

# 环境标签
myapp:dev
myapp:staging
myapp:prod

# Git 相关标签
myapp:abc1234           # commit hash 短版
myapp:v1.0.0-abc1234    # 版本 + commit 组合

# 构建相关标签
myapp:20240101          # 日期
myapp:build-42          # CI 构建编号
```

### 多标签的实际应用

在 CI/CD 流水线中，一次构建通常会产生多个标签：

```bash
#!/bin/bash
# CI 构建脚本中的标签策略

VERSION=$(cat package.json | jq -r '.version')
COMMIT_SHORT=$(git rev-parse --short HEAD)
BUILD_DATE=$(date +%Y%m%d-%H%M%S)

docker build -t myapp:${VERSION} \
             -t myapp:${VERSION}-${COMMIT_SHORT} \
             -t myapp:${BUILD_DATE} \
             -t myapp:latest \
             .

# 推送到仓库
docker push myapp:${VERSION}
docker push myapp:${VERSION}-${COMMIT_SHORT}
docker push myapp:${BUILD_DATE}
docker push myapp:latest
```

这样做的好处：
- `1.0.0` 标签：固定版本，方便回滚。
- `1.0.0-abc1234` 标签：知道这个镜像是哪个 commit 构建的。
- `20240101-120000` 标签：知道是什么时候构建的。
- `latest` 标签：方便快速拉取最新版本（仅非生产环境）。

### 重新打标签

你可以给已有镜像重新打标签，不需要重新构建：

```bash
# 给某个已有镜像加新标签
docker tag myapp:dev myapp:staging

# 标记镜像要推送到哪个仓库
docker tag myapp:1.0.0 docker.io/username/myapp:1.0.0
docker tag myapp:1.0.0 myregistry.com:5000/myapp:1.0.0

# 查看结果
docker images myapp
```

`docker tag` 仅仅是给 Image ID 加了一个新别名，不产生新的层，也不会复制镜像，几乎零开销。

### 标签的删除与清理

```bash
# 删除一个标签（不是删除镜像，除非这是唯一标签）
docker rmi myapp:old-tag

# 删除所有未打标签的悬挂镜像（dangling images）
docker image prune

# 删除所有未使用的镜像（慎重！）
docker image prune -a
```

### 注意：Docker Hub 和 latest

在 Docker Hub 上，如果你推送一个镜像时某个标签已经存在，新推送会覆盖旧标签。Docker Hub 没有内置的"不可变标签"机制（部分私有仓库如 AWS ECR、GCR 有）。这意味着如果你不小心推送了一个错误的 `1.0.0` 标签覆盖了原来的，用户下次拉取就会拿到错误的镜像。

最佳实践：发布后不要覆盖已推送的版本标签。如果想修复，递增版本号（`1.0.1`）重新构建推送。

## 动手试试

1. 用一个已有的镜像（比如 `docker pull nginx:alpine`），用 `docker tag` 给它打 3 个不同的标签，然后用 `docker images nginx` 确认它们指向同一个 Image ID。
2. 用一个小项目，构建时一次性打 4 个标签（版本号、环境、日期、latest），看看 `docker images` 的输出。
3. 尝试删除其中一个标签（`docker rmi`），再用 `docker images` 确认其他标签还在。

## 本节小结

标签是镜像的别名，latest 是最大的陷阱。生产环境用精确版本号（如 `1.2.3`），一次构建多标签（版本 + commit + 日期），已发布版本标签不要覆盖。

## 下一节预告

下一节我们深入镜像层的工作原理——写时复制、层的共享复用、以及 docker history 的使用。
