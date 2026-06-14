# 05-03 services 详解

## 本节你会学到什么

- 区分 image 和 build 两种指定服务来源的方式
- 使用 depends_on 控制启动顺序
- 掌握 restart 策略：no / always / on-failure / unless-stopped
- 使用 command 覆盖容器默认命令
- 理解 container_name 和 ports 的正确用法

---

上一节我们把 services 比作"人员分工表"——每个 service 对应一个岗位。现在咱们来看看这张表上有哪些栏目，每个栏目怎么填。

---

## image vs build：镜子还是配方？

这两个字段是互斥的，你只能选其一：

- **image**：直接拉现成的镜像，就像去蛋糕店买个成品蛋糕
- **build**：指定一个目录，Compose 在里面找 Dockerfile 现场构建，就像照菜谱自己烤

```yaml
services:
  cache:
    image: redis:alpine         # 拿来就用

  api:
    build: ./backend             # 先构建再运行
    # 等价于: build:
    #           context: ./backend
    #           dockerfile: Dockerfile
```

`build` 下还能配更多细节：

```yaml
services:
  app:
    build:
      context: ./app           # Dockerfile 所在目录
      dockerfile: Dockerfile.dev  # 指定 Dockerfile 文件名
      args:                     # 构建参数
        NODE_ENV: development
```

---

## depends_on：按顺序上菜

你没法在 MySQL 启动之前就让 WordPress 连上数据库。`depends_on` 告诉 Compose："先等那位准备好了，我再上"。

```yaml
services:
  db:
    image: mysql:8.0
    # MySQL 先启动

  wordpress:
    image: wordpress:latest
    depends_on:
      - db           # 等 db 服务启动后，我才启动
```

**重要提醒**：`depends_on` 只保证**启动顺序**，不保证服务完全就绪。MySQL 容器启动了，不代表 MySQL 进程已经完成初始化、能接收连接。如果你的应用需要在启动时连数据库，建议在应用代码里加**重试机制**。

---

## restart：挂了怎么办？

Docker 容器的默认行为是挂了就停了。`restart` 字段让 Compose 帮你当"医生"：

```yaml
services:
  web:
    image: nginx
    restart: always     # 不管什么原因退出，立刻重启
```

四种策略：

| 值              | 行为                                             | 类比               |
| --------------- | ------------------------------------------------ | ------------------ |
| `no`            | 不重启（默认）                                    | 感冒了，不治         |
| `always`        | 任何情况都重启，连 Docker 重启后也会自动拉起来     | 随身带着呼吸机       |
| `on-failure`    | 仅当容器异常退出（退出码非零）时重启               | 发烧了才给药         |
| `unless-stopped` | 类似 always，但如果手动 stop 了就不再自动重启     | 除非你说"不用管我"   |

生产环境通常选 `unless-stopped`：容器崩溃了会自动恢复，但人为停止后就尊重你的决定。

---

## command 和 entrypoint：改执行动作

覆盖容器默认的启动命令：

```yaml
services:
  debug:
    image: alpine
    command: sleep 3600        # 本来 Alpine 默认是 sh，改为睡一小时
```

如果你的镜像定义了 `ENTRYPOINT`，`command` 会作为参数追加：

```yaml
# Dockerfile 里有 ENTRYPOINT ["python", "app.py"]
services:
  worker:
    build: .
    command: --verbose --port 3000   # 实际运行: python app.py --verbose --port 3000
```

---

## container_name：给容器起名字

```yaml
services:
  web:
    image: nginx
    container_name: my-nginx    # 固定容器名
```

不用 `container_name` 时，Compose 会自动命名为 `<项目名>-<服务名>-<序号>`，比如 `myapp-web-1`。显式指定名字在调试时方便，但**不能同时跑多个实例**（名字会冲突）。

---

## ports：告诉世界

```yaml
services:
  web:
    image: nginx
    ports:
      - "8080:80"           # 宿主机:容器
      - "443:443"           # 可配多条
      - "127.0.0.1:3000:3000"  # 只绑定本地回环
```

长格式（YAML 风格，更清晰）：

```yaml
ports:
  - target: 80
    published: 8080
    protocol: tcp
```

---

## 实战示例

**examples/05-03/docker-compose.yml**

```yaml
services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: my-api
    ports:
      - "3000:3000"
    restart: unless-stopped
    depends_on:
      - redis
      - db
    environment:
      REDIS_HOST: redis
      DB_HOST: db
    command: node server.js

  redis:
    image: redis:alpine
    restart: unless-stopped

  db:
    image: postgres:15
    restart: unless-stopped
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: myapp
```

---

## 动手试试

1. 创建一个 `docker-compose.yml`，含两个服务：一个 nginx，一个 alpine（alpine 用 `command: sleep 3600`）
2. 给 alpine 添加 `depends_on: - web`，观察启动顺序
3. 给 nginx 添加 `restart: always`，然后用 `docker compose up -d` 启动
4. 用 `docker kill` 杀死 nginx 容器（模拟崩溃），观察它是否自动重启
5. 用 `docker compose stop web` 对比 `docker kill` 的区别

---

## 本节小结

services 段是 Compose 的心脏——image/build 选来源，depends_on 定顺序，restart 管健康，ports 开大门。

---

## 下一节预告

services 说完了，网络这块 Compose 有什么花样？下一节我们看看 Compose 中 networks 的自动创建、自定义、外部网络三种玩法。
