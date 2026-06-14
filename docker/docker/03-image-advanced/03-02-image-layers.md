# 03-02 镜像层的工作原理

## 本节你会学到什么

- 理解镜像层的本质和 UnionFS（联合文件系统）的基本概念
- 掌握写时复制（Copy-on-Write）机制
- 理解多个容器如何共享同一个镜像的层
- 能够用 `docker history` 和 `docker inspect` 分析镜像层结构

## 正文

### 镜像层是什么

在模块 02 中我们多次提到"层"这个词。每一行 Dockerfile 指令都会产生一个层。但层到底是什么？

用**透明胶片叠加**来类比最能说明问题。想象你有一叠透明的胶片：

- 第一张胶片：画了一个基础 Linux 文件系统（FROM alpine）
- 第二张胶片：在上面增加了一些软件包（RUN apk add nginx）
- 第三张胶片：修改了一个配置文件（COPY nginx.conf /etc/nginx/）
- 第四张胶片：写了容器启动说明（CMD ["nginx"]）

把四张胶片叠在一起，从上往下看，你看到的就是一个完整的镜像。每张胶片就是一个"层"。

这种技术叫 **UnionFS（联合文件系统）**。Docker 支持多种 UnionFS 实现（Overlay2、AUFS 等），默认使用 Overlay2。

### 镜像层 vs 容器层

理解镜像层和容器层的区别是理解 Docker 运行时的关键：

- **镜像层**：只读。由 `docker build` 创建，不可修改。
- **容器层**：可读写。由 `docker run` 创建（从镜像"派生"），容器运行时所有修改都发生在这里。

用"共享图书馆"来类比：
- 镜像层 = 图书馆里的藏书。大家都在看同样的书，书本身不会因为某个人"读"而改变。
- 容器层 = 你手里的笔记本。你可以把书上的内容抄下来，在笔记本上涂改、增加、删除。别人看不到你的笔记本，图书馆的书也没变。

当你 `docker rm` 容器时，相当于把你的笔记本销毁了。图书馆的藏书（镜像层）完好无损。

### 写时复制（Copy-on-Write）

容器启动后，如果你要修改镜像里的某个文件，Docker 不会在镜像层里改（因为镜像是只读的），而是：

1. 把要修改的文件从镜像层"复制"到容器层。
2. 在容器层里修改它。
3. 以后读取这个文件时，容器层挡在镜像层上面，读到的就是容器层的版本（修改后的）。

这就是"写时复制"——你不写它，它就一直用镜像层的；你一旦要写，Docker 就把它拷到容器层，之后你读的就是你自己的拷贝了。

这个机制的好处是**极度节省磁盘空间**。假设你有 10 个容器都在跑同一个 nginx 镜像（45MB），实际磁盘占用不是 10 x 45MB = 450MB，而是 45MB（镜像层）+ 10 个容器各自的"增量修改"（通常很小，几 KB 到几 MB）。因为那 45MB 的镜像层被 10 个容器共享了。

### 层的共享与复用

多个镜像之间也可以共享层。因为 Docker 每一层都有唯一的 ID，如果你有两个镜像都基于 `FROM node:20-alpine`，那么 alpine 那一层在磁盘上只存一份。

```bash
# 查看层的共享关系
docker image ls
docker history node:20-alpine
docker history myapp:latest
```

你会看到 `myapp:latest` 的底层和 `node:20-alpine` 是一样的——它们共享了 FROM 的所有层。

### docker history：查看镜像层的"配方"

`docker history` 就像看一道菜的"配料和步骤"：

```bash
docker history myapp:latest
```

输出示例：

```
IMAGE          CREATED BY                                      SIZE
<missing>      CMD ["node" "dist/index.js"]                    0B
<missing>      EXPOSE map[3000/tcp:{}]                         0B
<missing>      USER appuser                                    0B
<missing>      RUN /bin/sh -c addgroup -S appgroup...          5kB
<missing>      COPY dist/ /app/dist/ # buildkit                2.5MB
<missing>      COPY node_modules/ /app/node_modules/           45MB
<missing>      RUN /bin/sh -c npm ci && npm cache clean        0B
<missing>      COPY package*.json /app/                        2kB
<missing>      WORKDIR /app                                    0B
<missing>      LABEL maintainer=...                            0B
<missing>      ENV NODE_ENV=production                         0B
<missing>      ARG NODE_ENV=production                         0B
<missing>      RUN /bin/sh -c apk add --no-cache dumb-init     1.2MB
<missing>      FROM node:20.11.0-alpine3.19                    130MB
```

注意几点：
- `IMAGE` 列显示 `<missing>` ——因为 BuildKit（新版 Docker 的构建引擎）不再给中间层分配独立的 Image ID 了。这只是数据组织方式的优化，层的概念没变。
- `SIZE` 列告诉你这层增加了多少空间。`0B` 表示这个指令只修改了元数据（CMD、EXPOSE、ENV 等），不产生文件。
- 从下往上看，就是 Dockerfile 从上往下的执行顺序。
- 累积大小 = 130MB（FROM）+ 1.2MB（dumb-init）+ 45MB（node_modules）+ ... ≈ 最高层的大小。

### docker inspect：深入镜像的元数据

```bash
docker inspect myapp:latest
```

输出是一大段 JSON，关键字段：

```json
{
  "Id": "sha256:abc123...",
  "RepoTags": ["myapp:latest"],
  "Created": "2024-01-15T10:30:00Z",
  "Architecture": "amd64",
  "Os": "linux",
  "Size": 178000000,
  "RootFS": {
    "Type": "layers",
    "Layers": [
      "sha256:abc...",
      "sha256:def...",
      "sha256:ghi..."
    ]
  },
  "Config": {
    "Env": ["NODE_ENV=production", "APP_PORT=3000"],
    "Cmd": ["node", "dist/index.js"],
    "ExposedPorts": {"3000/tcp": {}}
  }
}
```

`RootFS.Layers` 数组就是镜像是所有层（从底到顶排列）。每一层的 SHA256 就是你在 `docker history` 里看到的内容对应的哈希值。

### 层的性能特性

理解层的机制可以帮你写出更高效的 Dockerfile：

1. **删除文件不会释放空间**：如果你在第二层 `COPY` 了一个大文件，在第三层删掉它，镜像大小不会减少——因为第二层包含了这个文件，这个数据已经是镜像不可分割的一部分了。删除操作只是在第三层标记"这个文件不可见"，数据还在。这就像你先在胶片上画了一团乱线，然后在上面一张胶片用修正液盖住它——乱线还在，只是你看不到。**这也是为什么要在同一层完成安装和清理**（合并 RUN）。

2. **层的顺序影响缓存命中率**：我们在 02-09 已经详细讲过，这里不再重复。关键是：变动频繁的内容放在 Dockerfile 靠后的位置。

3. **层越多，构建不一定越慢**：Docker 能够并行拉取和缓存各层。但是，层太多会增加 AUFS/Overlay2 的元数据开销。一般建议控制在 10-30 层以内。

### 查看容器当前层的改动

容器运行中，你可以看到容器层相对于镜像做了哪些修改：

```bash
# 查看容器文件系统的改动
docker diff <容器名>
```

```
C /app/logs          # C = 新增的文件/目录
A /app/logs/app.log  # A = 新增
C /tmp               # 新增
C /etc/nginx         # 修改了这个目录下的文件
A /etc/nginx/nginx.conf.tmp  # 新增
D /var/cache/old     # D = 删除了这个文件
```

- `C` = Changed（修改了目录内容）
- `A` = Added（新增）
- `D` = Deleted（删除）

这在你排查容器运行问题时非常有用——看看容器是不是意外写了什么东西导致了问题。

## 动手试试

1. 找到你之前构建的任意镜像，用 `docker history` 查看它的层结构，找出最"胖"的层（SIZE 最大），思考为什么会那么胖。
2. 用 `docker inspect <镜像名>` 查看 `RootFS.Layers` 数组，数数有几层。
3. 启动一个容器，执行 `docker exec` 进去创建几个文件，然后退出用 `docker diff` 查看容器层的变更记录。
4. 创建两个基于不同基础镜像的 Dockerfile，构建后比较 `docker history` 的共享部分——看哪些层被复用了。

## 本节小结

镜像层是只读的，容器层是可读写的。写时复制机制让多个容器共享同一个镜像层却互不干扰。`docker history` 帮你理解镜像是怎么一层层叠起来的，`docker diff` 帮你看到容器在镜像之上做了什么改动。

## 下一节预告

下一节我们学习如何把镜像推送到 Docker Hub——注册账号、docker login、docker push 及注意事项。
