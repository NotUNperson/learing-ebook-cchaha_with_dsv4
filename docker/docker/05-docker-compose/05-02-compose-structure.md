# 05-02 docker-compose.yml 文件结构

## 本节你会学到什么

- 掌握 docker-compose.yml 的顶层结构
- 理解 version、services、networks、volumes 各段的作用
- 看懂一个完整的 Compose 文件
- 开始自己写第一个 Compose 文件

---

`docker-compose.yml` 是一份"施工图纸"，描述了你的整个应用架构。就像一栋大楼的设计蓝图，上面标得清清楚楚：每层楼是干嘛的、水电怎么走、哪个部门在哪一层。

整个文件由四个顶层字段构成：

```
docker-compose.yml
 |
 +-- services     （服务：你要跑哪些容器）
 +-- networks     （网络：容器之间怎么连）
 +-- volumes      （卷：数据存在哪里）
 +-- configs / secrets  （高级配置，本教程不涉及）
```

`version` 字段在新版 Compose 中已经不再强制要求，但你在老文件里还会看到。现在写 Compose 文件，**直接顶格写 services** 就行。

---

## 各段职责速览

### services —— "有哪些人在干活"

这是最核心的部分。每个服务对应一个容器。你在这里定义容器的镜像、端口、环境变量、依赖关系等。类比：一份人员分工表，张三负责前端、李四负责数据库。

```yaml
services:
  web:                    # 服务名（也是 DNS 主机名）
    image: nginx:alpine
    ports:
      - "8080:80"

  api:
    build: ./backend      # 也可以从 Dockerfile 构建
    ports:
      - "3000:3000"

  db:
    image: postgres:15
```

### networks —— "各部门之间的走廊"

定义容器之间的网络拓扑。不写的话 Compose 会自动创建一个默认网络。类比：大楼里的走廊和门禁系统，决定哪些房间可以直接串门。

```yaml
networks:
  frontend:               # 前端网络
  backend:                # 后端网络
```

### volumes —— "仓库和保险柜"

定义数据存储。类比：大楼里的仓库，就算某间办公室被拆了（容器被删），仓库里的货物还在。

```yaml
volumes:
  db-data:                # 数据库的数据卷
  uploads:                # 用户上传的文件卷
```

---

## 一个完整的示例

下面是一个"前端 + API + 数据库"三层架构的 Compose 文件：

**examples/05-02/docker-compose.yml**

```yaml
services:
  frontend:
    image: nginx:alpine
    ports:
      - "80:80"
    networks:
      - frontend

  api:
    build: ./api
    ports:
      - "3000:3000"
    networks:
      - frontend
      - backend
    environment:
      DATABASE_URL: postgres://user:pass@db:5432/mydb

  db:
    image: postgres:15
    networks:
      - backend
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb

networks:
  frontend:
  backend:

volumes:
  db-data:
```

注意几个要点：

1. **服务名 = DNS 主机名**。`api` 容器里可以用 `db` 这个名字连接到数据库，`frontend` 里可以用 `api` 调用接口。Compose 自动处理了 DNS 解析。
2. **网络隔离**。`api` 同时连接 `frontend` 和 `backend` 两个网络（相当于它有两张网卡），但 `frontend` 不能直接访问 `db`——这是有意设计的隔离。
3. **卷声明**。`db-data` 在 `volumes` 顶层声明，然后在 `db` 服务里引用，Compose 会自动创建并管理它。

---

## Compose 文件的缩进规则

YAML 靠缩进来表示层级，空格数量必须一致（推荐 2 个空格，不要用 Tab）。一个常见的坑：

```yaml
# 错误！缩进不一致
services:
  web:
  image: nginx    # image 和 web 同级了，应该再缩进一层

# 正确
services:
  web:
    image: nginx  # image 在 web 下缩进 2 格
```

---

## 动手试试

1. 复制上面的 `docker-compose.yml` 到本地
2. 把 `build: ./api` 那一行改为 `image: node:18-alpine`（先用现成镜像测试结构）
3. 运行 `docker compose config`——这个命令会检查 YAML 语法并显示完整的配置
4. 试着运行 `docker compose up -d`，然后 `docker compose ps` 查看服务状态
5. 用完 `docker compose down` 清理

---

## 本节小结

Compse 文件由 services（容器）、networks（网络）、volumes（存储）三大块组成，服务名自动成为 DNS 主机名，缩进规则严格。

---

## 下一节预告

知道了整体结构，下一节我们深入 services 段，逐个击破 image、build、depends_on、restart 等每个字段的含义。
