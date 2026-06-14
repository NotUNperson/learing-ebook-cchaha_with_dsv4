# 05-01 为什么需要 Docker Compose？

## 本节你会学到什么

- 回顾手动管理多容器时的痛苦
- 理解 Docker Compose 解决了什么问题
- 看到从"一堆 docker run 命令"到"一个 YAML 文件"的进化
- 对 Compose 典型工作流有一个整体印象

---

在上一模块的最后一节，我们手动搭建了 WordPress + MySQL。你还记得那四条命令吗？

```bash
docker network create wp-network
docker volume create wp-db-data
docker run -d --name db --network wp-network -v wp-db-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=... -e MYSQL_DATABASE=... -e MYSQL_USER=... -e MYSQL_PASSWORD=... mysql:8.0
docker run -d --name wordpress --network wp-network -p 8080:80 -e WORDPRESS_DB_HOST=... -e WORDPRESS_DB_USER=... -e WORDPRESS_DB_PASSWORD=... -e WORDPRESS_DB_NAME=... wordpress:latest
```

两个容器而已，命令行就已经长到需要横着滚动了。而且每次启动，你都得**严格按顺序**执行：先建网络，再建卷，再启 MySQL，等 MySQL 就绪，最后启 WordPress。漏了一步都不行。

真实项目里，你可能要管五个微服务、一个消息队列、三个数据库——如果靠手动敲命令，光记启动顺序就够你掉头发的。

---

## 餐馆后厨的类比

想象你是一家大餐馆的行政主厨。开业前，你需要：

- 启动炉灶（MySQL）
- 启动排烟系统（Redis 缓存）
- 启动切菜机（后台 Worker）
- 启动传菜系统（API 网关）
- 启动点菜系统（前端服务）

如果没有统筹工具，你只能一个一个手动去开：先走到炉灶那里拧开关，再去开排烟机，再去……哪天换了新师傅，光教他"开机顺序"就得半天。

**Docker Compose 就是你的"后厨总开关"**。你把启动顺序、依赖关系、配置参数全写在一个叫做 `docker-compose.yml` 的文件里。开工时只需要一句：

```bash
docker compose up -d
```

啪！炉灶、排烟、切菜机、传菜系统全部启动，按正确顺序，带着正确的配置。

---

## 对比：手动 vs Compose

假设你要跑一个"前端 API 服务器 + Redis 缓存"的简单组合。

**手动方式：**

```bash
# 先建网络
docker network create app-net

# 启动 Redis
docker run -d --name redis --network app-net redis:alpine

# 启动 API
docker run -d --name api --network app-net -p 3000:3000 \
  -e REDIS_HOST=redis -e REDIS_PORT=6379 \
  my-api:latest

# 查看日志
docker logs api

# 停止一切
docker stop api redis
docker rm api redis
docker network rm app-net
```

**Compose 方式——只用一个文件：**

**examples/05-01/docker-compose.yml**

```yaml
services:
  redis:
    image: redis:alpine

  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      REDIS_HOST: redis
      REDIS_PORT: "6379"
```

然后：

```bash
docker compose up -d    # 启动所有服务
docker compose logs     # 查看日志
docker compose down     # 停止并清理所有相关资源
```

从"敲一串命令还要记顺序"变成"一个文件 + 三个动词（up / logs / down）"——这就是 Compose 的价值。

---

## Compose 不是什么

Compose 不是 Kubernetes 的替代品。它适合单机多容器编排，跑在开发环境、测试环境、小规模生产环境。当你需要跨多台机器的容器编排、自动伸缩、滚动更新时，那应该去看 Kubernetes。

但在那之前，90% 的场景，Compose 够用且好用。

---

## Compose 的两个版本：v1 vs v2

你可能在教程里见过两种写法：

```bash
docker-compose up     # v1 旧版（Python 实现，独立命令）
docker compose up     # v2 新版（Go 实现，集成在 Docker CLI 里）
```

`docker-compose`（带连字符）是老版本；`docker compose`（空格）是新版本，已集成进 Docker CLI。本教程统一使用新版 `docker compose`。

---

## 动手试试

1. 回顾上一节 WordPress + MySQL 的手动部署过程，数一数你一共敲了多少条命令
2. 把这四条命令贴在纸上，闭上眼睛默写一遍——能不能不看纸就写出来？
3. 体会一下：如果项目有 10 个服务呢？

---

## 本节小结

Docker Compose 用一个 YAML 文件替代了冗长的多命令手动操作，就像餐馆后厨的总开关——一个按钮启动所有设备。

---

## 下一节预告

Compose 的核心就是 `docker-compose.yml` 这个文件。下一节我们打开它，把 services、networks、volumes 四大块一个一个拆开看。
