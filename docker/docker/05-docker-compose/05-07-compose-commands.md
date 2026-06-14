# 05-07 Compose 常用命令

## 本节你会学到什么

- 掌握 `up` / `down` / `ps` / `logs` / `exec` 核心命令
- 理解 `build` / `pull` / `restart` 的时机
- 使用 `-d`、`--build`、`--force-recreate` 等关键参数
- 知道怎么用 `docker compose` 完成日常开发循环

---

前面六节我们都在讲怎么写 Compose 文件。现在你的文件写好了，你要学会怎么用它——就像你拿到了驾照，得知道怎么开车。

Compose 的核心命令不到十个，但它们覆盖了开发日常的 90%。咱们一个个过。

---

## docker compose up —— 一键启动

最核心的命令，没有之一：

```bash
docker compose up              # 前台运行，日志直接输出
docker compose up -d           # 后台运行（推荐）
docker compose up -d --build   # 重新构建镜像再启动
docker compose up -d --force-recreate  # 强制重建所有容器
```

`-d`（detach）是最常用的，就像把程序丢到后台，终端还给你。不加 `-d` 则日志会刷屏，关掉终端服务就停了。

---

## docker compose down —— 一键清理

```bash
docker compose down            # 停止 + 删除容器 + 删除默认网络
docker compose down -v         # 还额外删除 volumes 中声明的卷
docker compose down --rmi all  # 连镜像都删了（彻底大扫除）
```

`down` 和 `stop` 的区别：
- `docker compose stop`：只停止容器，不删除。可以 `start` 重新启动
- `docker compose down`：停止并删除容器和网络。下次 `up` 会重新创建

---

## docker compose ps —— 看看谁在跑

```bash
$ docker compose ps
NAME                COMMAND             SERVICE    STATUS    PORTS
05-07-web-1         "nginx -g 'daemon…"  web       running   0.0.0.0:8080->80/tcp
05-07-api-1         "node server.js"     api       running   0.0.0.0:3000->3000/tcp
```

比 `docker ps` 清爽多了——只显示当前 Compose 项目的容器，不掺合其他项目的。

---

## docker compose logs —— 看日志

```bash
docker compose logs             # 所有服务的日志
docker compose logs api         # 只看 api 服务的日志
docker compose logs -f          # 实时跟踪（tail -f 效果）
docker compose logs --tail=50   # 只显示最后 50 行
```

---

## docker compose exec —— 进容器干活

```bash
# 进入 api 容器的 bash（相当于 docker exec -it）
docker compose exec api bash
docker compose exec db psql -U postgres

# 在容器里执行单条命令
docker compose exec api npm test
```

和 `docker exec` 的区别：你只需要写服务名，不用查容器 ID 或容器名。

---

## docker compose build —— 构建镜像

```bash
docker compose build            # 构建所有 service 的镜像
docker compose build api        # 只构建 api 服务
docker compose build --no-cache # 不使用缓存，完全重新构建
```

---

## docker compose restart / pull / start / stop

| 命令                     | 作用                                       |
| ------------------------ | ------------------------------------------ |
| `docker compose restart` | 重启服务（容器还在，只是重启进程）           |
| `docker compose pull`    | 拉取所有服务的最新镜像（但不启动）            |
| `docker compose start`   | 启动已停止的容器（之前 stop 过的）           |
| `docker compose stop`    | 停止容器但不删除（可以 start 恢复）          |

---

## 典型开发工作流

每次改动代码后，你的操作流程通常是：

```bash
# 早晨打开电脑
$ docker compose up -d

# 改了代码（如果用 Dockerfile 构建的话）
$ docker compose build api
$ docker compose up -d

# 下午发现镜像有新版本了
$ docker compose pull
$ docker compose up -d

# 下班前
$ docker compose down

# 周五大扫除
$ docker compose down -v
```

---

## 动手试试

1. 把前面写的任一 `docker-compose.yml` 放入当前目录
2. 依次执行：`docker compose up -d`、`docker compose ps`、`docker compose logs`、`docker compose exec <service名> sh`
3. 尝试 `docker compose stop` 然后用 `docker compose start` 恢复
4. 尝试 `docker compose down` 然后用 `docker compose up -d` 重建
5. 体会 `down`（删容器）和 `stop`（不删）的区别

---

## 本节小结

`up -d` 启动，`down` 清理，`ps` 查看，`logs` 查日志，`exec` 进容器——五个动词覆盖日常开发 90% 的场景。

---

## 下一节预告

开发时最大的痛点是什么？改了代码要重新 build、重新 up。有没有一种方式，代码一存，容器自动同步？下一节我们学习 Compose Watch——真正的开发热重载。
