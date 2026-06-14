# 01-03 容器的生命周期 —— 启动、停止、重启、删除

## 本节你会学到什么

- 掌握 `docker ps` 查看容器列表的各种用法
- 熟练使用 `stop`、`start`、`restart`、`rm` 管理容器
- 理解容器状态（Running / Exited / Paused）的含义
- 学会批量清理已退出的容器

---

## 一个容器的"一生"

一个 Docker 容器从诞生到消亡，会经历几个状态，就像一个人的一生：

```
创建 (Created)
  |
  v
运行 (Running)  <----->  暂停 (Paused)
  |
  v
退出 (Exited)
  |
  v
删除 (Removed)
```

我们对每个状态逐一讲解，并配合对应的命令。

---

## docker ps：查看容器列表

`ps` 原意是 "process status"（进程状态），这里用来查看容器状态。

### 基本用法

```bash
# 查看正在运行的容器
docker ps

# 查看所有容器（包括已退出的）
docker ps -a

# 查看最近创建的 N 个容器
docker ps -n 5

# 只显示容器 ID
docker ps -q

# 按镜像名过滤
docker ps --filter "ancestor=nginx"

# 按容器状态过滤
docker ps --filter "status=exited"
```

### 输出各列的含义

```
CONTAINER ID   IMAGE     COMMAND                  CREATED       STATUS       PORTS                  NAMES
a1b2c3d4e5f6   nginx     "/docker-entrypoint..."  2 hours ago   Up 2 hours   0.0.0.0:8080->80/tcp   my-web
```

- **CONTAINER ID**：容器的唯一标识（前 12 位）。每个容器有一个完整的 64 位 ID，`docker ps` 只显示前 12 位。
- **IMAGE**：基于哪个镜像创建的。
- **COMMAND**：容器启动时执行的命令。
- **CREATED**：容器是多久前创建的。
- **STATUS**：当前状态（`Up` = 运行中，`Exited` = 已退出）。
- **PORTS**：端口映射信息。
- **NAMES**：容器名字（你起的或 Docker 自动生成的）。

---

## docker stop：优雅地停止

```bash
docker stop <容器名或ID>
```

`docker stop` 会给容器里的主进程发送 `SIGTERM` 信号，然后等待它优雅退出（默认等待 10 秒）。如果 10 秒后还没退出，Docker 会发送 `SIGKILL` 强制杀死。

类比：你去一家餐厅，跟店长说"准备打烊吧"（SIGTERM）——店长开始结账、收拾桌子、关设备。10 秒钟后你回来一看，店长还在磨蹭，于是你直接拉电闸（SIGKILL）。

你可以自定义等待时间：

```bash
# 等 30 秒再强制杀死
docker stop -t 30 my-container
```

---

## docker kill：强制停止（紧急刹车）

```bash
docker kill <容器名或ID>
```

`docker kill` 直接发送 `SIGKILL`，不给你优雅退出的机会。相当于你直接冲进餐厅拉电闸——店长连账都没来得及结。

什么时候用？容器卡死了、不响应了、你不想等了——直接用 `kill`。

---

## docker start：重新启动已退出的容器

```bash
docker start <容器名或ID>
```

`start` 只能启动**已经存在但已经停止**的容器。如果容器已经被 `rm` 删除了，`start` 就没用了。

重要区分：
- `docker start` 启动一个已存在的（已停止的）容器
- `docker run` 创建一个**全新的**容器并启动它

类比：
- `docker run`：你按照餐厅模板（镜像），重新装修一个全新的店。
- `docker start`：昨天打烊的店（已存在的容器），今天重新开门。

重新启动后，容器内的数据还在（除非你用了 `--rm`）。

---

## docker restart：重启正在运行的容器

```bash
docker restart <容器名或ID>
```

`restart` = `stop` + `start` 的组合操作。用于重启一个正在运行的容器，比如配置改了需要重启生效。

---

## docker pause / unpause：暂停和恢复

```bash
# 暂停容器（冻结进程）
docker pause <容器名或ID>

# 恢复容器
docker unpause <容器名或ID>
```

`pause` 会让容器内的所有进程暂停执行（使用 Linux 的 cgroup freezer 功能）。容器还在，但里面的进程完全冻结。适用于临时的资源控制或调试场景。

类比：你按下了餐厅的"暂停"按钮——所有人定格不动，等你按"继续"按钮后一切恢复。

注意：开发中很少用到 `pause`，知道有这个功能就行。

---

## docker rm：删除容器

```bash
# 删除已停止的容器
docker rm <容器名或ID>

# 强制删除（即使容器在运行）
docker rm -f <容器名或ID>

# 删除所有已退出的容器
docker container prune
```

提醒：`docker rm` 删除的是容器，`docker rmi` 删除的是镜像。别搞混。

类比：
- `docker stop`：打烊关门（容器停止，但东西还在）
- `docker rm`：把店拆了（容器删除，店内所有东西没了）
- `docker rmi`：把装修图纸也烧了（镜像删除）

---

## 实际操作流程演示

先创建两个容器来练手：

```bash
# 创建并运行两个 nginx 容器
docker run -d --name web1 nginx
docker run -d --name web2 nginx

# 查看运行中的容器
docker ps
```

输出示例：

```
CONTAINER ID   IMAGE   STATUS        PORTS   NAMES
abc123def456   nginx   Up 10 sec     80/tcp  web2
789ghi012jkl   nginx   Up 20 sec     80/tcp  web1
```

现在操作它们：

```bash
# 停止 web1
docker stop web1

# web1 已经不在运行列表中了
docker ps

# 但在完整列表里能看到它（状态为 Exited）
docker ps -a | grep web1

# 重新启动 web1
docker start web1
docker ps | grep web1    # 又回来了

# 重启 web2
docker restart web2

# 强制删除 web1（先停再删）
docker rm -f web1

# 停止 web2 然后删除
docker stop web2
docker rm web2

# 确认全部清理完毕
docker ps -a
```

---

## 动手试试

1. 启动三个容器，分别模拟不同的状态：

```bash
# 运行中的
docker run -d --name running-1 nginx:alpine

# 运行一两秒就自动退出的
docker run -d --name exited-1 alpine sleep 3

# 再一个后台运行的
docker run -d --name running-2 nginx:alpine
```

2. 依次执行以下观察命令：

```bash
# 只显示在运行的
docker ps

# 显示所有（包括已退出的）
docker ps -a

# 只显示最近两个
docker ps -n 2
```

3. 依次操作：

```bash
# 停止 running-1
docker stop running-1

# 重新启动它
docker start running-1

# 查看 exited-1 的状态（3 秒后应该是 Exited）
docker ps -a --filter "name=exited-1"
```

4. 练习完清理：

```bash
docker rm -f running-1 running-2 exited-1
docker ps -a
```

---

## 本节小结

容器的生命周期就是"创建-运行-暂停-退出-删除"，对应的命令是 `run`-`stop/start`-`pause`-`stop`-`rm`，用 `docker ps -a` 随时查看每个容器处于什么状态。

---

## 下一节预告

容器在外面看着挺好，但我能不能进去看看里面长什么样？能不能在容器里运行命令？下一节讲 `docker exec` 和交互模式——让你像 SSH 一样进入容器内部。
