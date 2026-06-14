# 05-06 环境变量与 .env 文件

## 本节你会学到什么

- 在 Compose 文件中使用 environment 直接设置环境变量
- 使用 env_file 从文件读取环境变量
- 掌握 ${VARIABLE} 变量替换语法
- 理解 .env 文件自动加载机制

---

环境变量对容器来说，就像"事先贴在工位上的便利贴"——容器启动时看一眼，就知道该用哪个数据库、密码是什么、要不要开调试模式。Compose 提供了三种方式来管理这些"便利贴"。

---

## 方式一：environment 硬编码

直接把变量写在 Compose 文件里——简单粗暴，适合练习和快速原型：

```yaml
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: myuser
      POSTGRES_PASSWORD: secret123
      POSTGRES_DB: myapp
```

等价于 `docker run -e POSTGRES_USER=myuser ...`。

---

## 方式二：env_file 读取外部文件

把变量集中放在一个文件里，Compose 自动读取。想象你把所有电话便利贴统一贴在一本手册上，而不是贴得到处都是：

**examples/05-06/db.env**

```
POSTGRES_USER=myuser
POSTGRES_PASSWORD=secret123
POSTGRES_DB=myapp
```

**examples/05-06/docker-compose.yml**

```yaml
services:
  db:
    image: postgres:15
    env_file:
      - db.env              # 从文件读取
```

好处很明显：同一个 Compose 文件，配合不同的 env 文件，就可以切换开发/测试/生产环境。

```bash
# 开发环境
$ docker compose --env-file .env.dev up

# 生产环境
$ docker compose --env-file .env.prod up
```

---

## 方式三：${VARIABLE} 变量替换

这是最灵活的方式。你可以在 Compose 文件中使用 `${VAR}` 占位符，Compose 在运行时从 `.env` 文件或 Shell 环境变量中取值：

**examples/05-06/docker-compose-vars.yml**

```yaml
services:
  web:
    image: nginx:${NGINX_TAG:-alpine}      # NGINX_TAG 默认 alpine
    ports:
      - "${HOST_PORT:-8080}:80"             # HOST_PORT 默认 8080

  db:
    image: postgres:${PG_VERSION:-15}
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD:?err}  # 必须提供，否则报错
```

语法规则：

| 写法                 | 含义                                       |
| -------------------- | ----------------------------------------- |
| `${VAR}`             | 读取 VAR，没有则为空字符串                   |
| `${VAR:-默认值}`      | 读取 VAR，没有则用默认值                     |
| `${VAR:?错误信息}`    | 读取 VAR，没有则报错并显示错误信息            |

---

## .env 文件的自动加载

Compose 有一个贴心机制：如果你在 `docker-compose.yml` 同级目录下放了 `.env` 文件，Compose 会自动加载它，不需要你显式指定。

**examples/05-06/.env**

```
NGINX_TAG=alpine
HOST_PORT=9090
PG_VERSION=15
DB_PASSWORD=super-secret
```

这样 `${DB_PASSWORD}` 直接从 `.env` 拿到值，不需要在 Shell 里 export。

---

## 优先级：谁说了算？

当同一个变量在多个地方出现时，优先级从高到低：

1. Shell 环境变量（`export VAR=value && docker compose up`）
2. `.env` 文件
3. Compose 文件中的默认值（`${VAR:-default}`）
4. Compose 文件中的硬编码值

```bash
# Shell 环境变量会覆盖 .env 文件
$ export HOST_PORT=9999
$ docker compose up   # HOST_PORT 实际是 9999，不是 .env 里的 9090
```

---

## 生产实践：敏感信息怎么办？

`.env` 文件里放数据库密码不安全——很容易被误提交到 Git。真实生产环境中：

1. 用 Docker Swarm 的 **secrets** 管理敏感信息
2. 用第三方密钥管理服务（HashiCorp Vault、AWS Secrets Manager）
3. 最低限度：把 `.env` 加入 `.gitignore`，提供 `.env.example` 作为模板

**.gitignore**

```
.env
*.env
!db.env.example
```

**examples/05-06/.env.example**

```
# 复制本文件为 .env 并填入真实值
NGINX_TAG=alpine
HOST_PORT=8080
PG_VERSION=15
DB_PASSWORD=请修改为你的真实密码
```

---

## 动手试试

1. 创建一个带 `${PORT}` 的 `docker-compose.yml`，再创建一个 `.env` 文件设置 `PORT=9999`
2. `docker compose up -d` 启动，确认服务绑定在 9999 端口
3. 修改 `.env` 中的 `PORT` 值，重新 `docker compose up -d`，确认端口变化
4. 用 `export PORT=7777` 覆盖 `.env`，再次启动，确认 Shell 变量优先级更高
5. 把 `.env` 加入 `.gitignore`，养成敏感信息不落 Git 的习惯

---

## 本节小结

Compose 提供 environment 硬编码、env_file 外部文件、${VAR} 变量替换三种环境变量管理方式，配合 .env 自动加载，灵活又安全。

---

## 下一节预告

文件结构学完了，现在你最需要的是一套肌肉记忆——Compose 的常用命令：up、down、logs、exec、build 等。下一节是实操指南。
