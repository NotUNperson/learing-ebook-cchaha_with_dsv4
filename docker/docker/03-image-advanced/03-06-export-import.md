# 03-06 docker save/load 与 export/import

## 本节你会学到什么

- 理解 docker save/load 和 docker export/import 的区别
- 掌握镜像备份和迁移的常用操作
- 了解在离线环境中如何传输 Docker 镜像
- 知道什么时候用 save/load，什么时候用 export/import

## 正文

### 问题场景

假设你有一个场景：服务器在隔离网络中，不能直接访问 Docker Hub，你怎么把镜像传上去？或者，你想把本地构建好的镜像发给同事，是不是每次都推 Docker Hub 再让他拉？

这时候你需要把镜像"打包成一个文件"，像 ZIP 一样传过去。Docker 提供了两套工具来做这件事，但它们的用途完全不同。

### docker save / docker load：搬运"完整镜像"

`docker save` 把一个镜像（包括所有层、标签、元数据）导出为一个 tar 文件。`docker load` 从 tar 文件恢复镜像。

用"搬家"类比：`docker save` = 把整栋房子（所有楼层、家具、房本）打包成一个集装箱，`docker load` = 在另一个地方把房子原封不动地拆箱重建。房子一模一样，连房本信息都保留。

```bash
# 把一个镜像保存为文件
docker save -o myapp.tar myapp:1.0.0

# 保存多个镜像到一个文件
docker save -o all-images.tar myapp:1.0.0 nginx:alpine redis:7

# 管道方式（配合 gzip 压缩）
docker save myapp:1.0.0 | gzip > myapp.tar.gz

# 从文件加载镜像
docker load -i myapp.tar

# 管道方式（从压缩文件加载）
gunzip -c myapp.tar.gz | docker load
```

加载完成后验证：

```bash
docker images myapp
docker history myapp:1.0.0    # 层信息完整保留
docker inspect myapp:1.0.0    # 元数据完整保留
```

`docker save/load` 保存的是**完整的镜像**——所有层、所有标签、所有历史、所有元数据。`docker load` 后得到的镜像和原来的一模一样。

### docker export / docker import：搬运"容器快照"

`docker export` 把一个**容器的文件系统**导出为 tar 文件。`docker import` 从 tar 文件创建一个**镜像**（只有一个层，没有历史）。

用"搬家"类比：`docker export` = 把房子里**当前的样子**拍张快照（无论之前怎么装修的，只看现在的样子），`docker import` = 用这张快照还原房子。还原出来的房子只有一层——你没法知道它当初是一层一层盖起来的。

```bash
# 从一个容器导出文件系统
docker export mycontainer -o container.tar

# 或者从运行中的容器导出
docker export mycontainer | gzip > container.tar.gz

# 从 tar 文件创建镜像
docker import container.tar myapp:snapshot

# 从管道导入
gunzip -c container.tar.gz | docker import - myapp:snapshot
```

`docker import` 后得到的镜像：
- 只有一个层（文件系统的快照）。
- 没有 Dockerfile 历史（`docker history` 只显示一行）。
- 丢失了所有元数据：ENV、CMD、EXPOSE、ENTRYPOINT 全没了。你需要手动加：

```bash
# import 时可以指定新的 CMD
docker import container.tar myapp:snapshot --change 'CMD ["node", "app.js"]'
```

### 核心区别对比表

| 特性 | docker save/load | docker export/import |
|------|-----------------|---------------------|
| 操作对象 | 镜像（image） | 容器（container） |
| 导出内容 | 所有层、标签、元数据 | 文件系统快照 |
| 结果层数 | 保留原始层数 | 合并为一层 |
| 保留历史 | 完整保留 | 全部丢失 |
| 保留元数据 | 完整保留 | 丢失（需手动指定） |
| 文件大小 | 较大（保留了层结构） | 较小（合并了，没有层元数据） |
| 典型用途 | 镜像迁移、离线部署 | 制作精简基础镜像 |

### 什么时候用 save/load？

**场景一：离线环境部署**

你有一个完全断网的服务器，需要部署 Docker 应用：

```bash
# 1. 在有网的机器上拉取和保存镜像
docker pull myapp:1.0.0
docker pull nginx:alpine
docker pull redis:7-alpine
docker save -o offline-images.tar myapp:1.0.0 nginx:alpine redis:7-alpine

# 2. 用 U 盘/SCP 把 offline-images.tar 传到离线服务器

# 3. 在离线服务器上加载
docker load -i offline-images.tar
docker run -d myapp:1.0.0
```

**场景二：跨机器传输镜像（跳过 Registry）**

同事需要你的镜像，但你们不共享 Registry：

```bash
# 你的机器
docker save myapp:latest | gzip > myapp.tar.gz

# 发给同事（U 盘、局域网共享、微信...）

# 同事的机器
gunzip -c myapp.tar.gz | docker load
```

**场景三：CI 构建缓存**

在 CI 流水线中，把构建好的镜像 save 到缓存：

```bash
docker save myapp:build-${CI_COMMIT_SHA} | gzip > build-cache.tar.gz
# 下次构建时先 load 作为缓存源
gunzip -c build-cache.tar.gz | docker load
docker build --cache-from myapp:build-${CI_COMMIT_SHA} -t myapp:latest .
```

### 什么时候用 export/import？

**场景一：制作精简的 scratch 镜像**

你可以从一个 Alpine + 手动编译的容器导出，得到一个不包含构建工具的精简镜像：

```bash
# 用 Alpine 安装和编译
docker run --name builder alpine:3.19 sh -c "apk add --no-cache gcc musl-dev; echo done"

# 导出容器的文件系统作为新镜像
docker export builder | docker import - my-minimal-image:latest

# 这个镜像没有包管理器、没有构建工具，只有运行时文件
```

**场景二：容器调试快照**

一个正在运行的容器出了问题，你想保留现场供离线分析：

```bash
docker export troubled-container | gzip > investigate.tar.gz
# 发给专家分析，专家 import 后 docker run 进去排查
```

注意：这种做法通常意味着你的应用没有正确使用日志和监控。能用 `docker logs` 解决的问题不要用 export。

### 两种方式的文件大小对比

用一个真实的 myapp 镜像做个实验：

```bash
# save
docker save myapp:1.0.0 -o myapp-save.tar
ls -lh myapp-save.tar            # 约 180MB（包含所有层和元数据）

# export（从容器导出）
docker run --name temp myapp:1.0.0 sleep 1
docker export temp -o myapp-export.tar
ls -lh myapp-export.tar          # 约 150MB（只有文件系统，合并了层）
```

export 通常比 save 小 10-20%，但代价是丢失了全部历史和元数据。

### 一个更实用的脚本

```bash
#!/bin/bash
# backup-all-images.sh
# 备份本地所有镜像

BACKUP_DIR="${1:-./docker-backup}"
DATE=$(date +%Y%m%d)
BACKUP_FILE="${BACKUP_DIR}/all-images-${DATE}.tar.gz"

mkdir -p "${BACKUP_DIR}"

# 获取所有镜像（排除 <none> 标签的悬挂镜像）
IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v '<none>')

if [ -z "$IMAGES" ]; then
    echo "No images to backup."
    exit 0
fi

echo "Backing up images:"
echo "$IMAGES"
echo "---"

# save 所有镜像并压缩
docker save $IMAGES | gzip > "${BACKUP_FILE}"

echo "Backup saved to: ${BACKUP_FILE}"
echo "Size: $(du -h ${BACKUP_FILE} | cut -f1)"

# 恢复命令
echo ""
echo "To restore: gunzip -c ${BACKUP_FILE} | docker load"
```

## 动手试试

1. 用 `docker save` 导出一个你之前构建的镜像为 tar 文件，查看文件大小。然后用 `docker rmi` 删掉本地镜像，再用 `docker load` 恢复回来。验证 `docker history` 是否完整保留。
2. 从同一个镜像启动一个容器，用 `docker export` 导出容器的文件系统。对比 save 和 export 的文件大小。
3. 用 `docker import` 导入 export 的 tar 文件，创建新镜像。用 `docker history` 对比新镜像和原镜像的差异。
4. 尝试在 import 时用 `--change` 指定 CMD，运行容器确认是否生效。

## 本节小结

`docker save/load` 搬运完整镜像（保留所有层和历史），用于镜像迁移和离线部署；`docker export/import` 搬运容器文件系统快照（合并为一层，丢失历史），用于制作特殊精简镜像或保存现场。大多数场景用 save/load。

## 下一节预告

下一节是模块 03 的综合练习——从 Dockerfile 到镜像瘦身再到推送 Docker Hub 的完整流程实操。
