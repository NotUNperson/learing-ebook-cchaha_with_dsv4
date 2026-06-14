# 04-05 Named Volume：把数据装进"外接硬盘"

## 本节你会学到什么

- 创建和管理 Named Volume
- 使用 `-v` 参数将卷挂载到容器
- 掌握 `docker volume ls/inspect/prune` 等管理命令
- 多个容器共享同一个卷

---

上一节我们打了个比方：Named Volume 就像一块**Docker 帮你管理的外接硬盘**。你只需要说"我要一块叫 `my-data` 的硬盘"，Docker 就帮你准备好；你说"把它插到容器的 `/data` 口上"，Docker 帮你连好。你不需要知道这块硬盘物理上在宿主机哪个目录——Docker 替你打理一切。

---

## 创建 Named Volume

```bash
# 创建一块名为 my-data 的"外接硬盘"
$ docker volume create my-data
my-data
```

看看 Docker 给你准备了哪些"硬盘"：

```bash
$ docker volume ls
DRIVER    VOLUME NAME
local     my-data
```

看看这块盘的详细信息：

```bash
$ docker volume inspect my-data
[
    {
        "CreatedAt": "2026-05-15T10:00:00+08:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/my-data/_data",
        "Name": "my-data",
        "Options": null,
        "Scope": "local"
    }
]
```

`Mountpoint` 告诉你数据实际存在宿主机上的哪个目录。不过你不需要直接操作这个目录，交给 Docker 就好。

---

## 将卷挂载到容器

用 `-v 卷名:容器内路径` 的语法：

```bash
# 把 my-data 插到容器的 /app/data 目录
$ docker run -it --name app1 \
  -v my-data:/app/data \
  alpine:latest sh

/ # echo "hello from app1" > /app/data/message.txt
/ # cat /app/data/message.txt
hello from app1
/ # exit
```

现在"拔掉"这块硬盘，插到另一个容器上试试：

```bash
# 删掉 app1（数据还在！）
$ docker rm app1

# 用另一个容器挂载同一个卷
$ docker run -it --name app2 \
  -v my-data:/app/data \
  alpine:latest sh

/ # cat /app/data/message.txt
hello from app1         # 数据完好无损！
```

这就是 Volume 和容器文件系统最本质的区别：**容器的生命是短暂的，卷的生命是独立的**。app1 死了，但它写的数据活了下来，被 app2"继承"了。

---

## 不用预先创建也行

如果你在 `-v` 里写了一个不存在的卷名，Docker 会自动创建：

```bash
# auto-volume 这个卷名字还不存在，Docker 自动帮你建
$ docker run -it --rm \
  -v auto-volume:/data \
  alpine:latest sh
/ # echo "auto-created" > /data/test.txt
/ # exit

$ docker volume ls
DRIVER    VOLUME NAME
local     auto-volume       # 自动创建了
```

---

## 多个容器共享同一个卷

把同一块"硬盘"插到两个容器上，它们就能共享数据——就像两个同事同时往一个共享文件夹里放文件：

```bash
# 终端1：第一个容器写入
$ docker run -it --name writer \
  -v shared-data:/shared \
  alpine:latest sh
/ # echo "from writer" > /shared/msg.txt

# 终端2：第二个容器读取
$ docker run -it --name reader \
  -v shared-data:/shared \
  alpine:latest sh
/ # cat /shared/msg.txt
from writer
```

这个特性在微服务架构中非常实用：多个服务需要共享配置文件、静态资源、日志目录时，一个共享卷就搞定了。

---

## 清理不需要的卷

用久了手上攒了一堆不用的卷，占着磁盘空间。清理一把：

```bash
# 查看所有卷
$ docker volume ls

# 删掉指定的卷（卷不能被任何容器使用，否则报错）
$ docker volume rm my-data

# 一键清理所有未被使用的卷（谨慎！）
$ docker volume prune
WARNING! This will remove all local volumes not used by at least one container.
Are you sure you want to continue? [y/N] y
```

`prune` 是"大扫除"，用之前确保你真的不需要那些数据了。

---

## 动手试试

1. 创建一个 Named Volume 叫 `db-data`
2. 启动一个 MySQL 容器（5.7 版本即可），把 `db-data` 挂载到 `/var/lib/mysql`
3. 连上 MySQL，创建一个数据库和一张表，插入一条数据
4. 删掉 MySQL 容器
5. 重新创建一个 MySQL 容器，挂载同一个 `db-data` 卷
6. 连上去检查：数据还在吗？

---

## 本节小结

Named Volume 由 Docker 管理，生命独立于容器，多容器可共享，就像一块即插即用的外接硬盘。

---

## 下一节预告

Named Volume 很省心，但有时候你想直接指定宿主机上的某个目录，比如开发时让代码文件实时同步进容器。这就是 Bind Mount 的用武之地。
