# 01-05 端口映射 —— 打通容器与外部世界的通道

## 本节你会学到什么

- 深入理解 `-p 8080:80` 的含义和原理
- 掌握多种端口映射方式：单端口、多端口、随机端口、UDP 端口
- 学会排查端口冲突问题
- 理解为什么需要端口映射——容器网络的基本概念

---

## 容器里有个网站，但外面看不到

假设你在容器里启动了一个 Nginx Web 服务器：

```bash
docker run -d --name web nginx
```

Nginx 在容器里监听的是 80 端口。但你现在打开浏览器访问 `http://localhost:80`——什么也看不到。

为什么？因为容器有自己的网络空间——它像一个独立的房间，有自己的网络接口和 IP 地址。容器里的 80 端口只是这个"房间里的 80 端口"，跟宿主机（你的电脑）的 80 端口没有任何关系。

类比：你在商场里租了一个铺位（容器），铺位里面有个内部电话线（80 端口）。但商场外面的顾客（你的浏览器）不知道这个内部电话线的号码，打不进来。你需要商场总机做一个**转接**——顾客拨商场前台的号码 8080，总机自动转接到你的内线 80。

**端口映射（-p）就是这个转接功能。**

---

## -p 的语法

```bash
-p 宿主机端口:容器端口
# 或
-p 宿主机端口:容器端口/协议
```

- **宿主机端口**：外部（你的电脑、局域网、互联网）访问时用的端口
- **容器端口**：容器内部应用监听的端口
- **协议**：tcp（默认）或 udp

---

## 四种常见映射方式

### 方式 1：指定宿主端口 -> 指定容器端口

```bash
# 把宿主机的 8080 端口映射到容器的 80 端口
docker run -d --name web1 -p 8080:80 nginx

# 现在浏览器访问 http://localhost:8080 就能看到 Nginx 欢迎页
```

这是最常用的方式。现在你可以同时运行多个 Nginx，每个映射到不同的宿主机端口：

```bash
docker run -d --name web1 -p 8080:80 nginx
docker run -d --name web2 -p 8081:80 nginx
docker run -d --name web3 -p 8082:80 nginx

# 现在你可以分别访问：
# http://localhost:8080 -> web1 容器
# http://localhost:8081 -> web2 容器
# http://localhost:8082 -> web3 容器
```

三个容器内部都监听 80 端口——这没关系的，因为它们在各自的网络空间里，互不干扰。就像同一栋商场里三家店都可以有内部电话分机号 80，只要商场总机把不同的外线号码转给不同的店就行了。

### 方式 2：多端口映射

一个容器可能需要暴露多个端口。比如一个 Web 应用同时需要 HTTP（80）和 HTTPS（443）：

```bash
docker run -d --name webapp \
  -p 8080:80 \
  -p 8443:443 \
  nginx
```

多个 `-p` 叠加就行，每个对应一组端口映射。

### 方式 3：随机端口

```bash
# 让 Docker 在宿主机上随机选一个可用端口
docker run -d --name web-random -P nginx

# 查看实际分配了什么端口
docker port web-random
# 输出：80/tcp -> 0.0.0.0:32768
```

注意这里是大写的 `-P`（publish-all）。它会读取镜像里 `EXPOSE` 指令声明的端口，然后给每个端口在宿主机上随机映射一个高位端口。

```bash
# 如果要映射到随机端口但只用 -p，可以只写容器端口
docker run -d --name web-random -p 80 nginx
docker port web-random
# 输出：80/tcp -> 0.0.0.0:32769
```

### 方式 4：绑定到特定 IP

```bash
# 只允许本机访问（127.0.0.1）
docker run -d --name web-local -p 127.0.0.1:8080:80 nginx

# 绑定到特定的网卡 IP
docker run -d --name web-lan -p 192.168.1.100:8080:80 nginx
```

默认情况下，`-p 8080:80` 绑定到 `0.0.0.0:8080`，意味着**局域网内任何机器**都能通过你电脑的 IP 访问这个端口。有时候你只想本机访问（调试用），那就指定 `127.0.0.1`。

### 方式 5：UDP 端口

```bash
# DNS 服务器通常用 UDP
docker run -d --name dns-server -p 53:53/udp bind9
```

---

## 端口冲突怎么办？

当你尝试启动一个容器，但宿主机上想要的端口已经被占用时：

```bash
docker run -d -p 8080:80 nginx
# 错误：Bind for 0.0.0.0:8080 failed: port is already allocated
```

排查步骤：

```bash
# 1. 看看哪个容器在用这个端口
docker ps --filter "publish=8080"

# 2. 如果是宿主机进程占用，用对应系统命令查
# Windows:
netstat -ano | findstr :8080

# Mac/Linux:
lsof -i :8080
# 或
ss -tlnp | grep 8080

# 3. 解决方法：
#    - 换一个未被占用的端口
#    - 停掉占用端口的进程
#    - 停掉占用端口的容器
```

---

## 常见端口速查表

| 应用 | 容器内默认端口 | 常见映射 | 说明 |
|------|---------------|----------|------|
| Nginx / Apache | 80 (HTTP), 443 (HTTPS) | 8080:80 | Web 服务器 |
| MySQL | 3306 | 3306:3306 | 关系型数据库 |
| PostgreSQL | 5432 | 5432:5432 | 关系型数据库 |
| Redis | 6379 | 6379:6379 | 缓存数据库 |
| MongoDB | 27017 | 27017:27017 | 文档数据库 |
| Node.js 开发服务器 | 3000 | 3000:3000 | 前端/后端开发 |
| Flask | 5000 | 5000:5000 | Python Web 框架 |
| Tomcat | 8080 | 8888:8080 | Java Web 容器 |

注意：容器内部端口不是随便取的——它是应用本身配置的监听端口。不同镜像的默认端口可能不同，查看镜像文档确认。

---

## 动手试试

1. 启动两个 Nginx，分别映射到不同端口，然后分别访问：

```bash
# 启动两个 nginx
docker run -d --name web-a -p 8080:80 nginx
docker run -d --name web-b -p 8081:80 nginx

# 浏览器分别访问 http://localhost:8080 和 http://localhost:8081
# 两个应该都显示 Nginx 欢迎页

# 查看端口映射情况
docker port web-a
docker port web-b
```

2. 试试随机端口：

```bash
# 启动一个随机端口的 nginx
docker run -d --name web-random -p 80 nginx

# 查看它被分配了哪个端口
docker port web-random
# 用这个端口号去浏览器访问
```

3. 模拟端口冲突：

```bash
# 再启动一个也映射到 8080
docker run -d --name web-conflict -p 8080:80 nginx
# 会报错——端口 8080 已经被 web-a 占用了
```

4. 清理所有：

```bash
docker rm -f web-a web-b web-random
```

---

## 本节小结

`-p 宿主机端口:容器端口` 就是商场总机转接——外部顾客拨外线号码（宿主机端口），总机自动转接给你的内部分机（容器端口），让容器里的服务能被外部访问到。

---

## 下一节预告

端口打通了，但容器里跑的应用怎么配置呢？比如 MySQL 的 root 密码、Node.js 的数据库连接字符串——这些东西不能写死在镜像里。下一节讲环境变量与容器配置。
