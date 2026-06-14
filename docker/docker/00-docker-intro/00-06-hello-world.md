# 00-06 第一个容器 —— hello-world 逐行解读

## 本节你会学到什么

- 运行你人生中的第一个 Docker 容器
- 理解 `docker run hello-world` 的每一步发生了什么
- 逐行解读 hello-world 的输出内容
- 知道 Docker 在背后自动做了哪些事情

---

## 跑起来

确保 Docker Desktop（或 Docker Engine）已经启动。打开终端，输入：

```bash
docker run hello-world
```

回车。你会看到一串英文输出。如果你还没装 Docker，请先回到第 4 节（Windows）或第 5 节（Mac/Linux）完成安装。

我是这样输出的（你的输出可能略有不同，但核心内容一样）：

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c1ec31eb5944: Pull complete
Digest: sha256:266b191e926f65542fa93d6e4e...（省略）
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
...（省略）
```

让我们一行一行解读，看看 Docker 在背后做了什么。

---

## 逐行解读

### 第 1 行：`Unable to find image 'hello-world:latest' locally`

Docker 首先在你本地找有没有叫 `hello-world` 的镜像（版本为 `latest`）。找到了就直接用，没找到就往下走。这是 Docker 的默认行为——**先本地找，找不到就自动去网上下载**。

类比：你想烤一个蛋糕，先去厨房看看有没有那个模具。有的话直接拿来用，没有的话——去超市买一个。

### 第 2 行：`latest: Pulling from library/hello-world`

Docker 在 Docker Hub（公共镜像仓库）上找到了这个镜像。`library/hello-world` 表示这是 Docker 官方仓库中的镜像（`library` 是官方镜像的命名空间）。

### 第 3 行：`c1ec31eb5944: Pull complete`

镜像是一层一层下载的（还记得第 3 节讲的"分层"概念吗）。`c1ec31eb5944` 是这个镜像层的唯一标识（SHA256 哈希的前 12 位）。`Pull complete` 说明这一层下载完了。hello-world 镜像很小，只有一层，所以这里显示一条。

### 第 4-5 行：`Digest` 和 `Status`

`Digest` 是整镜一个像的完整性校验码，用来确保下载的镜像没有被篡改或损坏。
`Status: Downloaded newer image` 告诉你：镜像下载完成，存到本地了。下次再运行 `docker run hello-world`，第一行就不会再提示 "Unable to find"，因为本地已经有了。

### 第 6 行之后：`Hello from Docker!`

这是容器实际运行后的输出。`hello-world` 镜像的唯一目的就是打印这段欢迎信息，然后自动退出。它的内容翻译过来大致意思是：

> "Hello from Docker！这条消息说明你的 Docker 安装看起来工作正常。
>
> Docker 做了以下事情：
> 1. Docker 客户端联系了 Docker 守护进程
> 2. Docker 守护进程从 Docker Hub 拉取了 hello-world 镜像
> 3. Docker 守护进程从该镜像创建了一个新容器，容器运行后产生了你现在看到的输出
> 4. Docker 守护进程把输出流式传回给 Docker 客户端，客户端再发送到你的终端"

---

## 背后发生了什么：一张流程图

用文字来描述这个流程：

```
你在终端输入 docker run hello-world
        |
        v
Docker 客户端（CLI）收到命令
        |
        v
Docker 客户端向 Docker 守护进程（daemon）发送请求
        |
        v
守护进程检查本地有没有 hello-world 镜像
        |
    +---+---+
    |       |
  有       没有
    |       |
    |       v
    |   去 Docker Hub 下载镜像
    |       |
    +---+---+
        |
        v
守护进程基于镜像创建容器
        |
        v
容器运行，输出内容
        |
        v
守护进程把输出传给客户端
        |
        v
输出显示在你的终端上
        |
        v
容器运行完毕，退出
```

这里面有几个关键角色需要区分：

- **Docker 客户端（docker CLI）**：你在终端里敲的 `docker` 命令，它负责接收你的指令并发送给守护进程。
- **Docker 守护进程（dockerd）**：在后台一直运行的服务进程，负责实际的镜像管理、容器创建、网络配置等脏活累活。
- **Docker Hub**：云端镜像仓库，公共的"模具商店"。

理解这三个角色的分工，对你后续理解 Docker 的架构很有帮助。

---

## 加上 `--rm` 试一试

```bash
docker run --rm hello-world
```

`--rm` 的意思是：容器运行结束后，自动把它删掉。不加 `--rm` 的话，容器退出后会留在那里（状态变为 `Exited`），你可以用 `docker ps -a` 看到它。

运行一下对比：

```bash
# 不带 --rm，容器退出后会保留
docker run hello-world
docker ps -a    # 你会看到一个 Exited 状态的容器

# 带 --rm，容器退出后自动删除
docker run --rm hello-world
docker ps -a    # 刚才那个容器已经不见了
```

---

## 动手试试

1. 运行 `docker run hello-world`，仔细阅读输出中的每一段英文。
2. 运行 `docker images`，看看本地是否有了 `hello-world` 这个镜像。
3. 运行 `docker ps -a`，看看是否有退出的容器。
4. 再次运行 `docker run hello-world`，观察这次输出中第一行是否还有 "Unable to find..." —— 应该没有了，因为镜像已经在本地。
5. 运行 `docker run --rm hello-world`，然后再 `docker ps -a`，确认 `--rm` 确实自动清理了容器。

---

## 本节小结

`docker run hello-world` 看似简单，背后是"本地查找 -> 远程下载 -> 创建容器 -> 运行输出 -> 退出"的一整套自动化流程，Docker 帮你把脏活累活全干了。

---

## 下一节预告

这是模块 00 的最后一节，我们把前面学的内容串起来，做一个综合的环境检查练习——确保你的 Docker 环境万事俱备，为模块 01 动手操作做好准备。
