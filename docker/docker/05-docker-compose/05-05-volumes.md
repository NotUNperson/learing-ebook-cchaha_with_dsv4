# 05-05 Compose 中的 volumes

## 本节你会学到什么

- 在 Compose 中声明和使用 Named Volume
- 在 Compose 中使用 Bind Mount
- 使用 external 引用外部已存在的卷
- 掌握服务级 volumes 和顶层 volumes 的对应关系

---

模块四里你学了三兄弟：Named Volume、Bind Mount、tmpfs。到了 Compose，这三兄弟换了个写法，但本质完全一样。只是从"命令行参数"变成了"YAML 配置项"而已。

---

## 顶层声明，服务里引用

Compose 里 volumes 有两种出现方式：

1. **顶层 `volumes`**：声明"有哪些卷存在"（相当于 `docker volume create`）
2. **服务内的 `volumes`**：声明"这个服务要用哪个卷，挂到哪里"（相当于 `-v` 参数）

```yaml
services:
  db:
    image: postgres:15
    volumes:
      - db-data:/var/lib/postgresql/data    # 引用下面声明的卷

volumes:
  db-data:                                   # 这是声明卷
```

---

## Named Volume：多种写法

**短格式（最常用）：**

```yaml
services:
  db:
    volumes:
      - db-data:/var/lib/postgresql/data     # 卷名:容器内路径
```

**长格式（要配更多选项时用）：**

```yaml
services:
  db:
    volumes:
      - type: volume
        source: db-data                      # 卷名
        target: /var/lib/postgresql/data     # 容器内路径
        read_only: false                     # 是否只读
```

长格式下 `type` 可以是 `volume`、`bind`、`tmpfs` 三种。

---

## Bind Mount：开发时的好伙伴

**短格式（推荐 `./相对路径`）：**

```yaml
services:
  web:
    image: nginx
    volumes:
      - ./html:/usr/share/nginx/html         # 相对路径 = Bind Mount
      - ./nginx.conf:/etc/nginx/nginx.conf:ro  # :ro 表示只读
```

**长格式：**

```yaml
services:
  web:
    volumes:
      - type: bind
        source: ./html                       # 宿主机路径
        target: /usr/share/nginx/html        # 容器内路径
```

---

## tmpfs：在 Compose 里声明

```yaml
services:
  app:
    image: my-app
    volumes:
      - type: tmpfs
        target: /app/tmp
        tmpfs:
          size: 128M                          # 限制 128MB
```

---

## external 卷：引用已有的

和网络的 `external: true` 一样，有时候你已经手动创建了一个卷，Compose 文件只是想引用它，不想再创建：

```bash
# 先手动创建
$ docker volume create shared-uploads
```

Compose 文件里：

```yaml
services:
  app:
    image: my-app
    volumes:
      - shared-uploads:/app/uploads

volumes:
  shared-uploads:
    external: true
```

---

## 完整示例：开发环境 vs 生产环境

**examples/05-05/docker-compose.yml**

```yaml
services:
  db:
    image: postgres:15
    volumes:
      - pgdata:/var/lib/postgresql/data    # Named Volume，数据持久化
    environment:
      POSTGRES_PASSWORD: secret

  api:
    build: ./api
    ports:
      - "3000:3000"
    volumes:
      - ./api/src:/app/src                  # Bind Mount，代码热更新
      - /app/node_modules                   # 匿名卷，不要覆盖 node_modules
    environment:
      DB_HOST: db
    depends_on:
      - db

volumes:
  pgdata:                                    # 声明 Named Volume
```

注意 `api` 服务里有一个匿名卷 `/app/node_modules`。为什么这么写？

因为 Bind Mount `./api/src:/app/src` 会把宿主机的 `src` 目录挂进去。如果宿主机上还没有安装 `node_modules`，容器里的 `node_modules` 就会被"遮住"导致程序跑不起来。加一行 `/app/node_modules`（匿名卷）告诉 Docker："这个目录你别管，用容器里原来的内容"，就避开了这个问题。

这招在 Node.js 和 Python 开发中特别常用。

---

## 动手试试

1. 创建一个 Compose 文件，含一个 nginx 服务和一个 alpine 服务
2. 给 nginx 配一个 Named Volume 挂载到 `/usr/share/nginx/html`
3. 给 alpine 配一个 Bind Mount，把本地目录挂到 `/data`
4. 用 `docker compose up -d` 启动
5. 用 `docker compose exec alpine sh` 进入 alpine，往 `/data` 写文件，确认宿主机上也能看到

---

## 本节小结

Compose 中的 volumes 分为顶层声明和服务引用两层，Named Volume、Bind Mount、tmpfs 各有对应的短格式和长格式写法。

---

## 下一节预告

你发现了吗，上面的例子里有很多 `${VARIABLE}` 样的东西。环境变量和 .env 文件怎么在 Compose 里用？下一节揭秘。
