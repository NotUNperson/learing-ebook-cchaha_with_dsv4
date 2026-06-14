# 04-08 卷的备份与迁移

## 本节你会学到什么

- 备份 Named Volume 的数据到 tar 压缩包
- 从备份中恢复数据到新的卷
- 把卷的数据迁移到另一台 Docker 主机
- 理解备份的本质：把数据从卷"拷"出来

---

你家里那块移动硬盘存了五年的照片、文档、项目代码。有一天你打算换一台新电脑，你会怎么做？把移动硬盘里的东西打包成一个 zip 文件，拷到新电脑，解压——齐活。

Docker 卷的备份和迁移也是这样。卷里的数据本质上是宿主机上某个目录里的文件，你要做的就是把它们**压缩打包**，然后拷到新地方。

---

## 备份一个 Named Volume

假设你有一个叫 `db-data` 的卷，里面存着 MySQL 的数据。备份步骤如下：

```bash
# 第一步：确认卷存在
$ docker volume ls
DRIVER    VOLUME NAME
local     db-data

# 第二步：启动一个临时容器，同时挂载源卷和一个备份目录
$ docker run --rm \
  -v db-data:/source \
  -v $(pwd)/backup:/backup \
  alpine:latest \
  tar czf /backup/db-data-$(date +%Y%m%d).tar.gz -C /source .
```

我来拆解这条命令做了什么：

1. `-v db-data:/source` —— 把待备份的卷挂到容器的 `/source` 目录
2. `-v $(pwd)/backup:/backup` —— 把宿主机当前目录下的 `backup/` 挂到容器的 `/backup` 目录
3. `tar czf /backup/db-data-20260515.tar.gz -C /source .` —— 把 `/source`（即卷里的内容）压缩成 tar.gz，存到 `/backup`（即宿主机的 backup 目录）

运行完后，你的当前目录下多了一个 `.tar.gz` 文件——这就是你的备份。

---

## 恢复备份到新卷

当你不小心搞坏了数据，或者要换一台机器时，恢复备份：

```bash
# 第一步：创建新的空卷
$ docker volume create db-data-restored

# 第二步：用临时容器解压备份文件到新卷
$ docker run --rm \
  -v db-data-restored:/target \
  -v $(pwd)/backup:/backup \
  alpine:latest \
  tar xzf /backup/db-data-20260515.tar.gz -C /target
```

这里逻辑是对称的：把备份文件挂进容器，把恢复目标卷也挂进去，解压。就像你把移动硬盘（备份文件）插上旧电脑（临时容器），把新硬盘（新卷）也插上，然后复制过去。

---

## 验证恢复是否成功

```bash
# 把恢复的卷挂到一个容器里看看数据
$ docker run --rm -v db-data-restored:/data alpine:latest ls /data
# 应该看到你备份的文件
```

---

## 跨主机迁移卷

跨主机迁移其实就是在备份和恢复之间多了一步传输：

```
主机A                             主机B
+-----------+                    +-----------+
| db-data   | --备份--> tar.gz --传输--> | db-data   |
| (源卷)    |                    | (目标卷)  |
+-----------+                    +-----------+
```

完整流程：

```bash
# === 在主机A上 ===
$ docker run --rm -v db-data:/source -v $(pwd):/backup \
  alpine tar czf /backup/db-data.tar.gz -C /source .

$ scp db-data.tar.gz user@主机B:/home/user/backups/

# === 在主机B上 ===
$ docker volume create db-data

$ docker run --rm -v db-data:/target -v ~/backups:/backup \
  alpine tar xzf /backup/db-data.tar.gz -C /target
```

---

## 用脚本自动化备份

每次都敲这么长的命令不现实，写个脚本一劳永逸：

**examples/04-08/backup-volume.sh**

```bash
#!/bin/bash
# 用法: ./backup-volume.sh <卷名>

VOLUME_NAME=$1
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -z "$VOLUME_NAME" ]; then
  echo "用法: $0 <卷名>"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

docker run --rm \
  -v ${VOLUME_NAME}:/source \
  -v $(pwd)/${BACKUP_DIR}:/backup \
  alpine:latest \
  tar czf /backup/${VOLUME_NAME}_${TIMESTAMP}.tar.gz -C /source .

echo "备份完成: ${BACKUP_DIR}/${VOLUME_NAME}_${TIMESTAMP}.tar.gz"
```

**examples/04-08/restore-volume.sh**

```bash
#!/bin/bash
# 用法: ./restore-volume.sh <卷名> <备份文件>

VOLUME_NAME=$1
BACKUP_FILE=$2

if [ -z "$VOLUME_NAME" ] || [ -z "$BACKUP_FILE" ]; then
  echo "用法: $0 <卷名> <备份文件路径>"
  exit 1
fi

docker volume create $VOLUME_NAME

docker run --rm \
  -v ${VOLUME_NAME}:/target \
  -v $(dirname $(realpath $BACKUP_FILE)):/backup \
  alpine:latest \
  tar xzf /backup/$(basename $BACKUP_FILE) -C /target .

echo "恢复完成: 卷 ${VOLUME_NAME} 已从 ${BACKUP_FILE} 恢复"
```

---

## 动手试试

1. 创建一个 Named Volume 叫 `test-backup`，启动容器在里面写入一些文件
2. 用本节的备份方法把 `test-backup` 打包成 tar.gz
3. 用 `docker volume rm test-backup` 删掉原卷
4. 用恢复方法把备份恢复到新卷，验证数据回来了
5. （加分）修改脚本，让它支持压缩时排除某些文件（提示：`tar --exclude`）

---

## 本节小结

卷备份的本质是用临时容器充当"搬运工"，把卷数据压缩拷贝到宿主机目录，恢复时反向操作，跨主机迁移只需加上网络传输。

---

## 下一节预告

网络和存储的知识都学完了，是时候把它们组合起来做个真东西了。下一节我们用 Docker 网络+卷搭一个 WordPress + MySQL 双容器应用——真正的"一条龙"。
