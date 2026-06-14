# 04-01 Docker 网络基础

## 本节你会学到什么

- 理解 Docker 网络的核心概念和默认的 bridge 网络
- 掌握 `docker network ls` 和 `docker network inspect` 命令
- 看懂容器之间如何通过 bridge 网络互相通信
- 理解端口映射（`-p`）和 bridge 网络的隔离机制

---

你家公司的内部电话系统，想想看：销售部拨 101 能找到财务部，财务部拨 102 能找到技术部，大家都连在同一台交换机上，拨分机号就能通话。可是公司外面的人，打 101、102 是打不进来的，除非你主动给客户留了一个"前台总机号"，前台再转接。

Docker 的 **bridge 网络** 就是这台"内部电话交换机"。每个容器连到这个网络上，就自动获得一个内部 IP，容器之间可以通过这个 IP 互相访问。但默认情况下，宿主机之外的世界访问不到容器，除非你做了端口映射——也就是对外公布了一个"总机号码"。

Docker 安装后默认会创建三个网络：

```bash
$ docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
abc123def456   bridge    bridge    local
def456ghi789   host      host      local
ghi789jkl012   none      null      local
```

这三个网络分别是什么角色呢？

- **bridge**：默认网络。如果你 `docker run` 时不指定 `--network`，容器就连到这个网络。它就是那台"内部电话交换机"。
- **host**：容器直接使用宿主机的网络栈，不做隔离。
- **none**：容器没有任何网络，完全与世隔绝。

咱们先聚焦 bridge。

---

## 看看 bridge 网络里有什么

用 `docker network inspect bridge` 一探究竟：

```bash
$ docker network inspect bridge
[
    {
        "Name": "bridge",
        "Driver": "bridge",
        "Containers": {
            "1a2b3c": {
                "Name": "my-nginx",
                "IPv4Address": "172.17.0.2/16"
            }
        }
    }
]
```

输出里你能看到：这个网络叫什么名字、用的是什么驱动、当前连着哪些容器、每个容器的内部 IP 是多少。

---

## 两个容器通过 bridge 通信

我们来实际动手看看。在第一个终端运行一个容器，在第二个终端跑另一个容器去 ping 它：

```bash
# 启动第一个容器（给它起个名字）
$ docker run -d --name app1 nginx:alpine

# 看一眼它的内部 IP
$ docker inspect app1 | grep IPAddress
            "IPAddress": "172.17.0.2",

# 启动第二个容器，进入它的 shell，ping 第一个容器的 IP
$ docker run -it --name app2 alpine:latest sh
/ # ping 172.17.0.2
PING 172.17.0.2 (172.17.0.2): 56 data bytes
64 bytes from 172.17.0.2: seq=0 ttl=64 time=0.123 ms
```

通了！app2 通过 bridge 网络找到了 app1 的内部 IP，两个容器之间可以自由通信。

但注意，这里我们用的是 **IP 地址**，不是容器名。默认 bridge 网络 **不支持 DNS 解析容器名**，你得记 IP——这就像公司内部电话还没有通讯录，大家只能靠背号码。

---

## 端口映射：给外界一个"总机号"

容器之间互访没问题，但你在浏览器里怎么访问 nginx 呢？`http://172.17.0.2` ？打不开。因为 172.17.0.2 是 Docker 内部 IP，只有宿主机和其他容器能看到。你需要端口映射：

```bash
# -p 宿主机端口:容器端口
$ docker run -d --name web -p 8080:80 nginx:alpine
```

现在访问 `http://localhost:8080`，等于在"前台"拨了总机号 8080，然后 Docker 给你转接到容器的 80 端口。别人打不通 101、102，但他们能拨总机号，然后你说"转 102"就行。

你可以同时跑多个 nginx，每个映射到不同的宿主机端口：

```bash
$ docker run -d --name web1 -p 8081:80 nginx:alpine
$ docker run -d --name web2 -p 8082:80 nginx:alpine
```

---

## 动手试试

1. 启动三个容器：两个 nginx，一个 alpine
2. 用 `docker network inspect bridge` 查看这三个容器的内部 IP
3. 从 alpine 容器里分别 ping 两个 nginx 容器的 IP
4. 用 `-p` 将其中一个 nginx 的 80 端口映射到宿主机的 9090，用浏览器或 curl 访问 `localhost:9090`

---

## 本节小结

bridge 网络就像公司内线电话交换机，容器之间能用 IP 互访，但外界需要端口映射才能进来。

---

## 下一节预告

bridge 网络虽然能通信，但只能靠 IP，太不方便了。下一节我们创建自定义网络，让容器"能用名字找到彼此"，就像给内线电话配上了通讯录。
