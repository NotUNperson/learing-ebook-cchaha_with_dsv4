# 07-02 容器资源限制：管好 CPU 和内存

## 本节你会学到什么

- 理解为什么需要限制容器资源
- 掌握 `--memory` 和 `--cpus` 参数精确限制资源
- 学会用 `docker stats` 实时监控资源使用
- 在 Compose 中配置资源限制

---

## 不加限制的"贪吃蛇"

Docker 默认情况下不会限制容器的资源使用。这句话换一种说法就是：**一个容器可以吃光你整台机器的 CPU 和内存**。

想象一个合租房。你跟三个室友一起租房，房东说："冰箱随便用，没有限制。"结果某个室友把他家乡特产塞满了整个冰箱，你买的牛奶都放不进去。你的容器就是那个室友——默认情况下，它可以占用所有能用的 CPU 和内存。

生产环境中，这非常危险。一个内存泄漏的应用可能拖垮整个宿主机，影响上面跑的所有服务。

---

## CPU 限制

### --cpus：按核心数限制

这是最推荐的方式，用小数指定最多能用多少 CPU 核心：

```bash
# 限制最多用 0.5 个核心（即 50% 的单个核心）
docker run -d --cpus="0.5" --name myapp myapp:latest

# 限制最多用 1.5 个核心
docker run -d --cpus="1.5" --name myapp myapp:latest

# 多核机器上限制用 2 个核心
docker run -d --cpus="2" --name myapp myapp:latest
```

类比：`--cpus="0.5"` 意思是"你最多只能占用半个灶台"。锅够大的话你也可以用 1.5 个灶台。但绝不会让你占满整个厨房。

### --cpuset-cpus：绑定到指定核心

更精细的控制——指定只能跑在哪些 CPU 核心上：

```bash
# 只允许在 CPU 0 和 CPU 1 上运行
docker run -d --cpuset-cpus="0,1" --name myapp myapp:latest

# 只允许在 CPU 2 上运行
docker run -d --cpuset-cpus="2" --name myapp myapp:latest
```

这适合对 CPU 亲和性有要求的场景，比如把关键任务绑定到固定核心避免上下文切换开销。

### 更新运行中容器的 CPU 限制

```bash
docker update --cpus="1" myapp
```

不需要重启容器。方便你在高峰期动态调整。

---

## 内存限制

### --memory / -m：硬限制

```bash
# 限制最多用 256MB 内存
docker run -d --memory="256m" --name myapp myapp:latest

# 限制最多用 1GB 内存
docker run -d --memory="1g" --name myapp myapp:latest
```

当容器内存超过限制时，Docker 会直接杀掉（OOM Kill）容器内的进程。就像自助餐厅——你交了 100 块钱的餐费，吃超标了服务员会把你的盘子收走。

### --memory-swap：交换空间限制

这个参数控制"内存 + swap"的总量。

```bash
# --memory="256m" --memory-swap="256m"  → 禁用 swap，只能用物理内存
# --memory="256m" --memory-swap="512m"  → 256M 物理内存 + 256M swap
# --memory="256m" --memory-swap="-1"    → 无限制 swap（不推荐）
# 只设 --memory="256m"（不设 swap）    → swap 默认为内存的 2 倍，即 512M
```

建议：**生产环境将 swap 设为与内存等值，即禁用 swap**。因为容器里的应用一旦开始用 swap，性能就会暴跌。

---

## 实时监控：docker stats

```bash
docker stats
```

输出类似：

```
CONTAINER ID   NAME    CPU %   MEM USAGE / LIMIT     MEM %   NET I/O
a1b2c3d4e5f6   myapp   2.35%   45.2MiB / 256MiB      17.66%  1.2kB / 0B
```

按 `Ctrl+C` 退出。加上 `--no-stream` 只输出一次快照：

```bash
docker stats --no-stream
```

这就好比你在中央厨房的监控室，可以实时看到每个灶台上在炒什么、用了多少燃气。

---

## Compose 中的资源限制

```yaml
services:
  api:
    image: myapp:latest
    deploy:
      resources:
        limits:
          cpus: "0.5"
          memory: "256m"
        reservations:
          cpus: "0.25"
          memory: "128m"
```

- **limits**：硬上限，容器不能超过（跨过就 OOM）
- **reservations**：软预留，调度时保证的最低资源量

有了 Compose，你不需要记住每个容器的资源参数——配置都写在文件里，一目了然。

---

## 动手试试

1. 运行一个没有限制的 Nginx 容器：`docker run -d --name nginx-test nginx`
2. 用 `docker stats --no-stream` 查看它占了多少资源
3. 用 `docker update --cpus="0.5" --memory="128m" nginx-test` 施加限制
4. 再用 `docker stats --no-stream` 确认限制已生效
5. `docker rm -f nginx-test` 清理

---

## 本节小结

不给容器加资源限制就像让客人随便拿自助餐——不加约束一定会出问题。`--cpus` 和 `--memory` 是最重要的两个资源参数，生产环境必须设置。

---

## 下一节预告

下一节我们来聊聊 WSL 与 Docker Desktop 的关系——为什么 Windows 上的 Docker 需要 WSL 2，以及如何在 WSL 里直接管理 Docker。
