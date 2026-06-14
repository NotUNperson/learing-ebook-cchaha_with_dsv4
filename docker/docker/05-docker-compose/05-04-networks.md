# 05-04 Compose 中的 networks

## 本节你会学到什么

- 理解 Compose 自动创建网络的机制
- 配置自定义网络（指定驱动、子网）
- 使用 external 引用外部已存在的网络
- 让服务连接多个网络实现分段隔离

---

在模块四里我们手动敲 `docker network create` 来建网络。到了 Compose，你可以在 YAML 里声明网络，Compose 自动帮你创建——就像填了"装修申请单"，物业自动帮你把网线拉好。

---

## 默认网络：不用写也有

如果你完全不写 `networks` 字段，Compose 会做一件贴心的事：自动创建一个名为 `<项目名>_default` 的 bridge 网络，然后把所有服务接上去。

```yaml
# 示例：没有 networks 字段
services:
  web:
    image: nginx
  api:
    image: node:18
```

当你 `docker compose up` 时，Compose 内部做了：
1. 创建网络 `myproject_default`
2. 把 `web` 和 `api` 接进去
3. `web` 里 `ping api` 能通（DNS 解析服务名）

如果你只是跑一个小项目，两个服务之间就靠这个默认网络够了。就像两个人在一个办公室里工作，不需要搞复杂的内部通讯系统。

---

## 自定义网络：自己设计走廊

当服务多了，你需要更精细的网络隔离。下面看一个"两层隔离"的例子：

**examples/05-04/docker-compose.yml**

```yaml
services:
  frontend:
    image: nginx:alpine
    networks:
      - front-net          # 只连前端网络

  api:
    build: ./api
    networks:
      - front-net          # 连前端（和 frontend 通信）
      - back-net           # 连后端（和 db 通信）

  db:
    image: postgres:15
    networks:
      - back-net           # 只连后端网络

networks:
  front-net:               # 自定义网络 1
  back-net:                # 自定义网络 2
```

注意 `api` 服务同时连着两个网络——它就像公司的"前台兼财务"，需要跟客户（frontend）交流，也需要进财务室（db）查账。而 `frontend` 进不去财务室，`db` 也不会直接面对客户。这就实现了网络层的安全隔离。

---

## 自定义网络的高级选项

你可以指定驱动、子网、网关等参数：

```yaml
networks:
  private-net:
    driver: bridge
    ipam:
      config:
        - subnet: 10.5.0.0/16
          gateway: 10.5.0.1
```

这里 `ipam`（IP Address Management）让你手动设计 IP 地址段，就像你给公司的每个办公室预分配了固定门牌号。

---

## external 网络：借用别人家的 WiFi

有时候你不想让 Compose 创建新网络，而是要连到一个已经存在的外部网络。比如你有一个 Nginx 反向代理在其他 Compose 项目里跑着，你想让当前项目的服务接进去。

```bash
# 先手动建一个外部网络
$ docker network create shared-proxy
```

然后在 Compose 文件里声明使用它：

```yaml
services:
  app:
    image: my-app
    networks:
      - shared-proxy

networks:
  shared-proxy:
    external: true      # "别给我建新的，我用外面那个现成的"
```

这就像你搬进了一栋已经装修好的写字楼——不需要重新布线，直接插上网线就能用。

---

## 默认网络 vs 自定义网络：再比一次

| 方面     | 不写 networks                      | 自定义 networks           |
| -------- | --------------------------------- | ------------------------- |
| 网络名   | `<项目名>_default`                 | 你指定的名字               |
| DNS 解析 | 服务名可解析                       | 服务名可解析               |
| 隔离能力 | 所有服务一个网络，无隔离            | 可精确控制谁连哪个网络      |
| 外部连接 | 不能连外部网络                     | 可通过 external 连外部网络  |
| 子网控制 | 自动分配                          | 可指定 IP 段               |

---

## 动手试试

1. 写一个 Compose 文件，三个服务：`web`（nginx）、`app`（alpine, command: sleep 3600）、`db`（alpine, command: sleep 3600）
2. 创建两个网络 `front` 和 `back`，`web` 只连 `front`，`db` 只连 `back`，`app` 同时连两个
3. 启动后，`docker compose exec app ping web` 能通吗？`docker compose exec app ping db` 呢？`docker compose exec web ping db` 呢？
4. 体会：网络隔离就像办公室门禁——没有授权的进不来

---

## 本节小结

Compose 默认创建网络并接上所有服务（省心模式），也可自定义网络实现分层隔离（安全模式），还能通过 external 接入已有网络（拼装模式）。

---

## 下一节预告

网络说透了，轮到 Compose 中的存储管理。Compose 里怎么声明 Named Volume 和 Bind Mount？volumes 段有哪些花样？
