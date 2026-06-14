# 04-02 自定义网络与容器间通信

## 本节你会学到什么

- 创建自定义 bridge 网络并理解它和默认 bridge 的区别
- 使用 `--network` 参数将容器接入指定网络
- 通过容器名进行 DNS 解析，实现"用名字通信"
- 让已有容器加入或退出某个网络

---

上一节我们用了默认的 bridge 网络，容器之间得靠 IP 地址通信。问题来了：每次重启容器，IP 可能会变。你总不能让同事天天更新通讯录上的分机号吧？

自定义网络解决的就是这个问题。你可以理解成：公司买了一套叫做"内网通讯录"的系统，以后你拨打"张三"就能找到他，而不是拨"172.17.0.5"。这个"通讯录"就是自定义 bridge 网络自带的 **DNS 解析功能**。

---

## 创建自定义网络

一行命令搞定：

```bash
$ docker network create my-net
```

核对一下：

```bash
$ docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
abc123def456   bridge    bridge    local
def456ghi789   host      host      local
ghi789jkl012   none      null      local
789jkl012abc   my-net   bridge    local
```

来 `inspect` 一下看看：

```bash
$ docker network inspect my-net
[
    {
        "Name": "my-net",
        "Driver": "bridge",
        "Containers": {},
        ...
    }
]
```

初始空空荡荡，还没有任何容器加入。

---

## 让容器加入自定义网络

启动容器时用 `--network` 指定：

```bash
# 启动两个容器，都加入 my-net
$ docker run -d --name web1 --network my-net nginx:alpine
$ docker run -d --name web2 --network my-net nginx:alpine
```

现在再从 web2 里去 ping web1——注意，这次用的是**容器名**，不是 IP：

```bash
$ docker exec web2 ping web1
PING web1 (172.18.0.2): 56 data bytes
64 bytes from 172.18.0.2: seq=0 ttl=64 time=0.089 ms
64 bytes from 172.18.0.2: seq=1 ttl=64 time=0.078 ms
```

神奇吧？Docker 内置了一个 DNS 服务器（地址 127.0.0.11），当你在容器里输入 `web1` 时，DNS 自动帮你解析成正确的 IP。就像你翻开通讯录找"张三"，电话系统自动查到他最近的分机号。

---

## 自定义网络 vs 默认 bridge：哪里不一样？

| 特性       | 默认 bridge            | 自定义 bridge          |
| ---------- | --------------------- | ---------------------- |
| DNS 解析   | 不支持容器名            | 支持容器名自动解析       |
| 网络隔离   | 所有容器默认同一网络     | 不同网络之间完全隔离      |
| 配置灵活性 | 无法修改              | 可指定子网、网关等       |
| IP 管理    | 自动分配，无法指定       | 可指定 `--ip`           |

如果你有三个微服务 A、B、C，A 和 B 关系紧密需要互相通信，C 是独立的外围服务不想让 A、B 访问，那你可以把 A、B 放在 `backend-net` 网络里，C 放在 `service-net` 里。backend-net 和 service-net 之间默认不互通——就像公司两个不同部门的专线网络相互隔离。

---

## 把运行中的容器加入网络

容器已经在跑了，不想停掉重建？用 `docker network connect`：

```bash
# 启动一个不在 my-net 里的容器
$ docker run -d --name outsider nginx:alpine

# 把它加入 my-net
$ docker network connect my-net outsider

# 现在 outsider 也能 ping web1 了
$ docker exec outsider ping web1
PING web1 (172.18.0.2): 56 data bytes
```

同一台容器可以同时连接到多个网络，就像一个同事既有公司座机（内线通讯录），又有手机（外线），两边都能接。

退出网络用 `docker network disconnect`：

```bash
$ docker network disconnect my-net outsider
```

---

## 自定义子网和网关

想知道具体怎么配子网？创建网络时可以指定更多细节：

```bash
$ docker network create \
  --driver bridge \
  --subnet 192.168.100.0/24 \
  --gateway 192.168.100.1 \
  custom-subnet
```

这样你就有了一个完全由你掌控 IP 范围的私人电话系统。

---

## 动手试试

1. 创建一个自定义网络叫 `test-net`
2. 启动两个 alpine 容器连接到 `test-net`，名字分别叫 `alpha` 和 `beta`
3. 从 `alpha` 里 ping `beta`（用容器名而不是 IP）
4. 再创建一个新的 `test-net-2`，把 `beta` 也连到 `test-net-2`，验证 `beta` 同时属于两个网络

---

## 本节小结

自定义 bridge 网络自带 DNS 解析，让你可以用容器名互相通信，告别硬编码 IP，就像内线电话配上了通讯录。

---

## 下一节预告

bridge 网络是"内部员工电话"，host 模式则相当于"你直接坐在前台接客户电话"——根本没有交换机。下一节我们看看 host 和 none 网络是什么场景。
