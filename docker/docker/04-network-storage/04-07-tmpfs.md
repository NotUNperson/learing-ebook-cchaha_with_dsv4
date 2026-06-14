# 04-07 tmpfs：内存中的临时存储

## 本节你会学到什么

- 理解 tmpfs 的本质：只在内存中，不落盘
- 使用 `--tmpfs` 和 `--mount type=tmpfs` 挂载内存文件系统
- 知道什么场景适合用 tmpfs
- 对比 Volume / Bind Mount / tmpfs 三种存储方式

---

前两节讲的 Named Volume 和 Bind Mount 都有一个共同特点：数据写在**磁盘**上。磁盘嘛，速度有限，而且数据会留痕迹。

但有些场景下，你既不需要数据持久化（丢了也无所谓），又不想把数据写到磁盘上（安全考虑），还希望读写速度极快（性能要求）。这时候就该 **tmpfs** 出场了。

---

## tmpfs 是什么？

tmpfs 是 Linux 提供的一种**内存文件系统**。你在系统里看到一个目录，可以对它读写文件，但文件内容实际存在 RAM 里，从不碰磁盘。

这就像什么呢？就像你在桌上放了一叠**便签纸**。你在上面记东西很快（内存速度），但一阵风吹来（容器停止），所有便签纸全飞走了。而且没人能从你的回收站里把这些便签纸找回来——因为根本没写过磁盘，无迹可寻。

---

## 使用 tmpfs

两种写法都可以：

```bash
# 写法一：--tmpfs（简洁版）
$ docker run -it --rm --tmpfs /app/tmp alpine:latest sh

# 写法二：--mount（完整版，可配更多参数）
$ docker run -it --rm \
  --mount type=tmpfs,destination=/app/tmp,tmpfs-size=64m \
  alpine:latest sh
```

进入容器后，你在 `/app/tmp` 下创建的文件都在内存里：

```bash
/ # cd /app/tmp
/ # echo "secret token: xyz123" > secrets.txt
/ # cat secrets.txt
secret token: xyz123
/ # exit        # 容器退出，secrets.txt 永远消失
```

---

## 限制 tmpfs 大小

默认 tmpfs 可以无限增长（直到吃光内存），建议限定大小：

```bash
$ docker run -it --rm \
  --mount type=tmpfs,destination=/cache,tmpfs-size=128m \
  alpine:latest sh
```

如果往里面写超过 128MB 的数据，会收到"磁盘已满"的错误——虽然它根本不在磁盘上。

---

## tmpfs 的典型场景

**场景一：临时缓存**

你的应用需要一个高速缓存目录，但数据丢了无所谓（可以从数据库重建）。比如图片处理服务把缩略图缓存在 tmpfs 里，重启后重新生成就好。

```bash
$ docker run -d \
  --mount type=tmpfs,destination=/tmp/thumbnails,tmpfs-size=256m \
  my-image-processor
```

**场景二：敏感信息存储**

你的容器在运行时会收到一个临时的 API 密钥或会话令牌。你不希望它在任何情况下被写到磁盘上——因为磁盘数据可以被恢复工具扫描。tmpfs 存在内存里，容器一停，数据彻底消失。

```bash
$ docker run -d \
  --mount type=tmpfs,destination=/run/secrets \
  my-api-service
```

**场景三：高性能读写**

如果你的应用需要频繁读写临时文件（例如排序时用到的中间文件），把 tmpfs 挂上去能大幅提升性能——内存的读写速度比磁盘快几个数量级。

---

## 三种存储方式终极对比

| 特性       | Named Volume       | Bind Mount            | tmpfs               |
| ---------- | ------------------ | --------------------- | ------------------- |
| 存储位置   | 宿主机磁盘          | 宿主机磁盘             | 内存                |
| 持久性     | 持久               | 持久                  | 临时，容器停即丢     |
| 管理方     | Docker              | 你自己                | Docker              |
| 速度       | 磁盘速度            | 磁盘速度              | 内存速度（极快）     |
| 安全性     | 数据可恢复          | 数据可恢复             | 数据不可恢复         |
| 适合场景   | 数据库数据、持久文件 | 开发热更新、配置文件     | 缓存、敏感令牌、临时文件 |

---

## 动手试试

1. 启动一个 alpine 容器，用 tmpfs 挂载 `/secure` 目录
2. 在 `/secure` 下创建一个文件，写一些内容
3. 退出容器，重新启动一个挂载了同一目录（Volume）的容器——数据还在吗？（不在了）
4. 对比：用 Named Volume 重复上述操作，数据还在吗？
5. 体会：什么数据值得放 Volume，什么数据只适合放 tmpfs

---

## 本节小结

tmpfs 是纯内存存储，数据不落盘、不可恢复，适合缓存和敏感数据场景——就像桌上的便签纸，用完即弃。

---

## 下一节预告

Volume 很强大，但如果你要把数据从一个 Docker 主机迁移到另一个呢？下一节我们学习卷的备份与迁移——相当于给你的"外接硬盘"做 ghost 克隆。
