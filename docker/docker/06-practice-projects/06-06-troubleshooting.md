# 06-06 常见问题排查指南

## 本节你会学到什么

- 掌握容器启动即退出的五类常见原因及其解决方案
- 诊断端口冲突和网络不通的系统性方法
- 清理磁盘空间的完整命令组合（别再用 rm -rf 了）
- 解决权限问题（Permission denied）的根因分析思路
- 使用 --progress=plain 调试构建失败的技巧

---

## 排错心法

遇到容器问题，很多人第一反应是：重启试试。

这个习惯在物理机时代也许管用，但在容器领域，重启往往解决不了问题——因为容器是"不可变基础设施"，每次重启都是从同一个镜像重新创建。如果镜像有问题，重启一百次也没用。

**正确的排错思路是三板斧：看状态、看日志、进容器。**

```bash
docker ps -a          # 第一板斧：看容器状态
docker logs <name>    # 第二板斧：看日志输出
docker exec -it <name> sh  # 第三板斧：进容器内部排查
```

下面按最常见的五类问题，逐一讲症状、原因、解决方案。

---

## 问题一：容器启动就退出（Exited immediately）

**症状：**

```bash
$ docker ps -a
CONTAINER ID   STATUS                     ...
a1b2c3d4       Exited (0) 2 seconds ago   ...
e5f6g7h8       Exited (1) 5 seconds ago   ...
```

启动就退出，`docker ps` 看不到，只有 `docker ps -a` 能看到遗体。

**原因 1：前台进程退出**

Docker 容器的生命周期和 PID 1 进程绑定。PID 1 进程退出，容器就退出。如果你的启动命令是一个执行完就退出的命令（比如 `ls`、`echo`、shell 脚本没阻塞），容器自然就完了。

```bash
# 错误示范：echo 执行完就退出了
docker run alpine echo "hello"  # 容器瞬间退出
```

**原因 2：应用崩溃（exit code 非 0）**

进程因为异常退出，exit code 非 0。常见于数据库连不上、端口绑定失败、语法错误。

```bash
# 查看退出码
docker inspect <container> --format='{{.State.ExitCode}}'
```

**原因 3：前台进程变成后台进程**

某些应用（比如某些启动脚本）会把进程 fork 到后台然后自己退出，Docker 看到前台进程退出就以为服务结束了。

**类比：** Docker 的生命周期机制就像一个导演盯着舞台——只要主角还在表演，戏就继续；主角一下台，幕布就落下来。哪怕后台有很多配角在忙，导演只看主角在不在。

**排查步骤：**

```bash
# 1. 查看容器为什么退出
docker logs <container>

# 2. 如果一瞬间就退出了，来不及看日志，用 --rm 和 attach
docker run --rm -it <image> sh   # 手动启动看看

# 3. 检查启动命令是否有问题
docker inspect <image> | grep -A5 Cmd
```

**解决方案：**

```bash
# 对于需要持续运行的服务，确保前台运行
# Nginx：daemon off
CMD ["nginx", "-g", "daemon off;"]

# Node.js：直接 node，不要用 pm2/runtime（除非你理解它的行为）
CMD ["node", "index.js"]

# Python：gunicorn 默认前台运行，无需特殊处理
```

---

## 问题二：端口已被占用（Port already in use）

**症状：**

```
Error response from daemon: driver failed programming external connectivity
on endpoint ... Bind for 0.0.0.0:3000 failed: port is already allocated.
```

**原因：** 你或别人已经在这个端口上跑了一个服务（可能是另一个容器，也可能是宿主机的进程）。

**排查步骤：**

```bash
# 查宿主机端口占用
# Linux/Mac
lsof -i :3000
netstat -tlnp | grep 3000

# Windows
netstat -ano | findstr :3000

# 查是否有容器占用了这个端口
docker ps --filter "publish=3000"
```

这个命令输出类似：

```
COMMAND    PID   USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
node     12345   user   18u  IPv4  ...      0t0  TCP *:3000 (LISTEN)
```

如果 PID 对应的进程是你不需要的，直接 kill 掉。如果是 Docker 容器，停掉那个容器。

**解决方案：**

```bash
# 方案 1：杀掉占用端口的进程
kill <PID>

# 方案 2：用不同端口映射
docker run -p 3001:3000 myapp   # 宿主 3001 映射到容器 3000

# 方案 3：停掉占用的容器
docker stop <container_name_or_id>
```

---

## 问题三：磁盘空间不足（No space left on device）

**症状：**

```
Error: write /var/lib/docker/... : no space left on device
```

或者构建镜像时报错，或者容器无法写入文件。

**原因：** Docker 很能吃磁盘。镜像、容器、卷、构建缓存、未使用的网络都占空间。时间一长，一个开发机上的 Docker 数据可能占 50-100GB。

**分析磁盘使用：**

```bash
# 查看 Docker 磁盘占用总览
docker system df

# 输出示例：
# TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
# Images          15        3         12.5GB    8.2GB (65%)
# Containers      8         2         150MB     120MB (80%)
# Local Volumes   4         2         2.1GB     500MB (23%)
# Build Cache     20        0         3.5GB     3.5GB (100%)
```

重点关注 RECLAIMABLE 那一列——这些都是可以清理的。

**清理方案（从保守到激进）：**

```bash
# 保守：清理悬挂镜像（dangling，没有标签的中间层镜像）
docker image prune

# 中等：清理所有未使用的镜像
docker image prune -a

# 中等：清理停止的容器
docker container prune

# 中等：清理未使用的卷（小心！数据会丢）
docker volume prune

# 中等：清理构建缓存
docker builder prune

# 激进：一键清理所有未使用的东西（镜像、容器、卷、网络、构建缓存）
docker system prune -a --volumes
```

**日常维护建议：**

```bash
# 每周跑一次这个
docker system prune -f

# 每月跑一次这个（包括未使用的卷）
docker system prune -a --volumes -f
```

**类比：** `docker system prune` 就像是给房间做大扫除。你平时往房间里堆各种东西（镜像、容器、卷），久了就堆满了。定期把不用的东西扔掉，房间才能保持整洁。

---

## 问题四：容器间网络不通

**症状：**
- 容器 A 无法 ping 容器 B
- 前端请求后端返回 `connection refused`
- 容器无法访问外网

**诊断方法论：**

```bash
# 步骤 1：确认容器是否在同一个网络里
docker inspect <container> | grep NetworkMode
docker network ls

# 步骤 2：查看容器的 IP 地址
docker inspect <container> | grep IPAddress

# 步骤 3：进入一个容器，测试到另一个容器的连通性
docker exec -it <container_a> sh
ping <container_b_ip>
nc -zv <host> <port>    # 测试端口是否通
wget -O- http://<host>:<port>/api/health

# 步骤 4：检查 DNS 解析（容器名称能否解析为 IP）
docker exec -it <container_a> nslookup <container_b_name>
```

**常见原因及解决：**

| 原因 | 解决 |
|------|------|
| 不在同一个 docker-compose 网络中 | 确保 compose 文件里所有服务在同一个 `networks` 下 |
| 用的 localhost 而不是服务名 | 容器内部用服务名连接（如 `http://backend:3001`），不是 `localhost` |
| 防火墙/安全组拦截 | 检查 iptables 规则或云平台安全组 |
| DNS 缓存问题 | `docker-compose down && docker-compose up` 重建网络 |
| 用了 `network_mode: host` | 改用 bridge 模式 |

**最容易犯的错误：**

```javascript
// 错误：在容器里，localhost 指的是容器自己，不是宿主机
const db = new Pool({ host: 'localhost', ... });

// 正确：用 compose 服务名
const db = new Pool({ host: 'db', ... });
```

**类比：** 在容器里用 localhost 连接数据库，就像你给自己写信——你写信给"我家"，邮递员当然送到你自己家门口，不可能送到邻居家（数据库容器）。

---

## 问题五：权限问题（Permission denied）

**症状：**

```
EACCES: permission denied, open '/app/data/file.txt'
Error: EACCES: permission denied, mkdir '/app/uploads'
```

**原因分析：**

容器内的用户 UID 和宿主机挂载卷的 UID 不匹配。

举例：你的 Dockerfile 里创建了 `appuser (UID=1001)`，但宿主机上挂载的目录属于 `root (UID=0)` 或者你的登录用户 `(UID=1000)`。容器里的进程以 UID 1001 运行，自然没权限读写 UID 1000 的目录。

**排查：**

```bash
# 进容器看看当前用户是谁
docker exec -it <container> id
# 输出: uid=1001(appuser) gid=1001(appgroup)

# 看看目标文件的权限
docker exec -it <container> ls -la /app/data
# 输出: drwxr-xr-x  2 1000 1000  4096 ...  # 1000 不等于 1001，权限不足
```

**解决方案（按推荐顺序）：**

```bash
# 方案 1：修改宿主机目录权限，匹配容器用户 UID
chown -R 1001:1001 /host/data/dir

# 方案 2：在 Dockerfile 里用宿主机的 UID 创建用户
RUN addgroup -g 1000 appgroup && adduser -u 1000 -S appuser -G appgroup

# 方案 3：运行时指定用户（不建议，可能带来新问题）
docker run --user 1000:1000 myapp

# 方案 4：容器启动时用 chown 修改（浪费启动时间）
```

---

## 问题六：构建失败调试

**症状：**

构建过程在某一步报错退出，默认日志信息有限。

**调试技巧：**

```bash
# 使用 --progress=plain 显示详细的逐行输出
docker build --progress=plain -t myapp .

# 使用 --no-cache 禁用缓存，确保看到完整构建过程
docker build --no-cache --progress=plain -t myapp .

# 从失败的那一步启动交互式调试
# 假设构建在第 5 步失败了，用第 4 步的结果启动一个容器
docker build --target builder -t myapp-debug .  # 只构建到指定阶段
docker run --rm -it myapp-debug sh              # 进去看看
```

`--progress=plain` 特别有用——它不像默认模式那样用精简的进度条，而是输出完整的命令输出，让你看清楚到底是哪行命令报的错。

---

## 速查表

| 症状 | 第一反应命令 |
|------|------------|
| 容器起不来 | `docker ps -a && docker logs <name>` |
| 端口冲突 | `lsof -i :<port>` 或 `docker ps --filter publish=<port>` |
| 磁盘满了 | `docker system df` |
| 网络不通 | `docker exec <name> nc -zv <target> <port>` |
| 权限错误 | `docker exec <name> id && ls -la <path>` |
| 构建失败 | `docker build --progress=plain --no-cache .` |

---

## 动手试试

**目标：** 故意制造一个故障，然后用本节学的三板斧定位和修复。

1. 尝试在已经被占用的端口上启动一个容器：`docker run -d -p 80:80 nginx`（如果 80 端口已经有服务）
2. 运行 `docker ps -a` 和 `docker logs` 查看失败原因
3. 用 `lsof -i :80` 找到占用端口的进程
4. 换一个端口重新启动：`docker run -d -p 8081:80 nginx`
5. 最后用 `docker system df` 看看你的 Docker 磁盘使用情况

预计耗时：5 分钟。

---

## 本节小结

排错不是天赋，是方法论：看状态 -> 看日志 -> 进容器 -> 比对现象和预期 -> 锁定根因。遇到任何问题，先走完这个流程再说。

## 下一节预告

解决完本地的问题后，是时候把镜像推到 CI/CD 流水线里了。下一节我们讲 Docker 和 GitHub Actions 的集成——代码推送后自动构建、跑测试、推到镜像仓库，实现真正的持续交付。
