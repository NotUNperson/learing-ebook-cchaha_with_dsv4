# 01-01 从 Docker Hub 拉取镜像 —— 你的模具商店

## 本节你会学到什么

- 理解 Docker Hub 是什么，它跟 GitHub 有什么不同
- 掌握 `docker pull` 命令的用法
- 理解 tag（标签）的概念——为什么 `nginx:alpine` 和 `nginx:latest` 不一样
- 学会在 Docker Hub 上搜索和选择合适的镜像

---

## Docker Hub：全球最大的模具商店

还记得第 00-03 节我们说的"模具商店"吗？Docker Hub 就是那个商店——它是 Docker 官方维护的公共镜像仓库，上面有数百万个别人打包好的镜像，免费供你下载使用。

网址是：https://hub.docker.com

你可以把它理解成"Docker 世界的 GitHub"。不过有一点区别：GitHub 上存的是源代码，Docker Hub 上存的是打包好的、可以直接运行的镜像。就好比 GitHub 是"菜谱书城"（卖食谱），Docker Hub 是"预制菜超市"（卖已经做好的半成品，你热一下就能吃）。

### Docker Hub 上有什么？

打开 Docker Hub 网站，你会看到这些分类：

- **官方镜像（Official Images）**：Docker 公司和相关厂商共同维护的高质量镜像，比如 `nginx`、`mysql`、`redis`、`python`、`node`。这些镜像经过安全审计，建议优先使用。
- **社区镜像（Community Images）**：全世界开发者上传的镜像，质量参差不齐。用之前要看看下载量、评分和最后更新日期。
- **认证发行商（Verified Publisher）**：像微软、Oracle 这样的公司发布并维护的镜像，质量有保障。

---

## docker pull：从商店取模具

### 基本用法

```bash
docker pull <镜像名>:<tag>
```

如果省略 tag，默认使用 `latest`：

```bash
# 这两条命令等价
docker pull nginx
docker pull nginx:latest
```

### 实际操作

```bash
# 拉取 nginx 官方镜像
docker pull nginx

# 查看拉取的镜像
docker images nginx
```

你应该能看到类似这样的输出：

```
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
nginx        latest    abc123def456   2 weeks ago   187MB
```

### 拉取指定版本（tag）

```bash
# 拉取 nginx 的 alpine 版本（更小，只有约 40MB）
docker pull nginx:alpine

# 拉取 nginx 的 1.25 版本
docker pull nginx:1.25

# 拉取特定小版本
docker pull nginx:1.25.3
```

现在再看镜像列表：

```bash
docker images nginx
```

你会看到三个不同 tag 的 nginx 镜像，它们的 IMAGE ID 和 SIZE 各不相同。

---

## Tag 到底是什么？

Tag（标签）就是你给镜像版本贴的标牌。同一个镜像名（比如 `nginx`）可以有多个 tag。

类比：你去书店买《三体》，店员问你："要哪一版？第一版？精装修订版？还是英文翻译版？"这里的"第一版""精装修订版""英文翻译版"就是 tag。书是同一本（同一个 repo），但版本不同（不同的 tag）。

常用的 tag 命名习惯：

| Tag 格式 | 含义 | 例子 |
|----------|------|------|
| `latest` | 最新稳定版（默认） | `nginx:latest` |
| `x.y` | 主版本号 | `python:3.12` |
| `x.y.z` | 精确版本号 | `python:3.12.3` |
| `alpine` | 基于 Alpine Linux 的精简版 | `nginx:alpine` |
| `slim` | Debian 精简版 | `python:3.12-slim` |
| `-alpine` | 带具体版本的精简版 | `python:3.12-alpine` |

**重要的提醒**：`latest` 不一定是"最新的版本号"，而是"镜像维护者标记为默认的那个版本"。不要盲目相信 `latest`，生产环境最好用精确的版本号。

---

## 为什么 alpine 这么小？

你可能会注意到 `nginx:alpine` 比 `nginx:latest` 小很多——从 187MB 降到 40MB 左右。这是因为：

- `nginx:latest` 基于 Debian 完整发行版，包含了很多你可能用不上的系统工具和库。
- `nginx:alpine` 基于 Alpine Linux——一个为容器场景设计的超精简 Linux 发行版，只保留最核心的东西。

类比：`latest` 像是你买一个全套工具箱（虽然你可能只用到一把螺丝刀），`alpine` 像是你只买那把螺丝刀。后者当然轻便得多。

对于学习和小型项目，推荐优先使用 `alpine` 版本——下载更快，磁盘占用更少，安全攻击面也更小。

---

## 在 Docker Hub 上搜索镜像

除了用网站搜索，你也可以在命令行里搜索：

```bash
# 搜索 mysql 相关镜像
docker search mysql

# 搜索并限制只显示官方镜像
docker search mysql --filter is-official=true

# 搜索星标数超过 100 的镜像
docker search mysql --filter stars=100
```

不过命令行的搜索结果信息比较有限，建议还是去 https://hub.docker.com 网站上浏览——那里你能看到镜像的详细说明、支持的 tag、Dockerfile 源码、使用文档等。

---

## 删除不需要的镜像

镜像占磁盘空间。不需要了就删掉：

```bash
# 删除指定镜像
docker rmi nginx:1.25.3

# 删除所有未使用的镜像（谨慎！）
docker image prune -a
```

---

## 动手试试

1. 打开 https://hub.docker.com，搜索 `redis`，找到它的官方镜像页面。
2. 看看 `redis` 有哪些 tag 可用？`alpine` 版本的有多大？
3. 在终端执行以下命令：

```bash
# 拉取 redis 的 alpine 版本
docker pull redis:alpine

# 拉取 redis 的 latest 版本
docker pull redis:latest

# 对比两个镜像的大小
docker images redis
```

4. 注意到大小的差距了吗？这就是 alpine 精简版的优势。
5. 挑选一个你平时编程时用到的数据库或者中间件（MySQL、MongoDB、RabbitMQ 等），去 Docker Hub 上找到它的官方镜像，看看有哪些 tag。

---

## 本节小结

`docker pull` 就是从 Docker Hub 这个"模具商店"里把你需要的模具（镜像）拿回家，tag 帮你选择具体拿哪个版本。

---

## 下一节预告

镜像拿到了，怎么用它来启动容器？下一节讲 `docker run` 的常用参数——`-d` 后台运行、`--name` 起名字、`-p` 端口映射、`-e` 环境变量等等。我们用"开餐厅"的类比来理解这些参数。
