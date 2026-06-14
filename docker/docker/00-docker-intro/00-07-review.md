# 00-07 综合练习 —— 安装验证与环境检查

## 本节你会学到什么

- 用一个完整的检查清单验证 Docker 环境是否正确安装
- 运行一组命令，确认 Docker 的核心功能都能正常工作
- 学会如何排查 Docker 不工作的常见原因
- 为模块 01 的动手操作做好准备

---

## 环境检查清单

以下是你的 Docker 环境验收清单。逐项检查并打勾：

| 序号 | 检查项 | 验证命令 |
|------|--------|----------|
| 1 | Docker 已安装 | `docker --version` |
| 2 | Docker 守护进程在运行 | `docker info` |
| 3 | 能拉取镜像 | `docker pull alpine` |
| 4 | 能运行容器 | `docker run --rm alpine echo "hello"` |
| 5 | 容器退出后能自动清理 | `docker run --rm alpine echo "test"` |
| 6 | 能查看本地镜像 | `docker images` |
| 7 | 能查看容器列表 | `docker ps -a` |

---

## 逐项操作

在终端中依次执行以下命令。我们使用 `alpine` 镜像来做测试——它是目前最小的 Linux 发行版镜像之一，只有 5MB 左右，下载非常快。

### 1. 检查 Docker 是否已安装

```bash
docker --version
```

**期望输出**：类似 `Docker version 24.0.7, build ...` 这样的一行，显示客户端版本号。

**如果报错**：`command not found` 或 `不是内部或外部命令`，说明 Docker 没有正确安装或没有加到系统 PATH 里。回到第 4 节（Windows）或第 5 节（Mac/Linux）重新检查安装步骤。

### 2. 检查 Docker 守护进程是否在运行

```bash
docker info
```

**期望输出**：一大段系统信息，包括容器数量、镜像数量、存储驱动、操作系统、CPU、内存等。

**如果报错**：`Cannot connect to the Docker daemon`，说明 Docker 守护进程没有在运行。Windows/Mac 用户检查 Docker Desktop 是否启动（状态栏鲸鱼图标是否稳定）。Linux 用户执行 `sudo systemctl start docker`。

### 3. 检查能否拉取镜像

```bash
docker pull alpine
```

**期望输出**：下载进度条，最后显示 `Status: Downloaded newer image for alpine:latest`。

**如果报错**：网络超时或连接错误。检查你的网络是否可以访问 Docker Hub（可能需要科学上网，或者配置国内镜像加速器）。

### 4. 检查能否运行容器

```bash
docker run --rm alpine echo "Docker 环境正常！"
```

**期望输出**：`Docker 环境正常！`

**如果报错**：镜像拉取成功但无法运行，可能是 Docker 引擎配置有问题。试试重启 Docker Desktop 或 `sudo systemctl restart docker`。

### 5. 检查自动清理

```bash
# 运行容器，让它输出后就退出
docker run --rm alpine echo "运行完就清理"

# 查看所有容器（包括已退出的）
docker ps -a | grep alpine
```

**期望结果**：第二个命令应该没有输出（因为 `--rm` 已经自动删掉了容器）。

### 6. 检查本地镜像列表

```bash
docker images
```

**期望输出**：至少能看到 `alpine` 和之前拉取过的 `hello-world` 镜像。

### 7. 检查容器列表

```bash
docker ps          # 正在运行的容器
docker ps -a       # 所有容器（包括已退出的）
```

**期望输出**：`docker ps` 应该没有 alpine 相关的在运行容器。`docker ps -a` 可能有之前留下的 `hello-world` 容器。

---

## 配置国内镜像加速（可选，但强烈建议）

如果你在国内，从 Docker Hub 拉取镜像可能很慢甚至超时。配置镜像加速器可以大幅提升体验。

### 配置步骤

1. 打开 Docker Desktop
2. 点右上角齿轮图标进入 Settings
3. 左侧选择 "Docker Engine"
4. 在 JSON 配置中加入 `registry-mirrors`：

```json
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me"
  ]
}
```

5. 点击 "Apply & Restart"
6. 重启完成后，运行 `docker info`，在输出末尾你应该能看到刚添加的镜像地址。

**Linux 用户**：编辑 `/etc/docker/daemon.json` 文件（如果没有就创建一个），写入上面同样的内容，然后执行 `sudo systemctl restart docker`。

---

## 常见问题速查

### Q: docker info 报错 permission denied
**A:** Linux 用户常见问题。需要把当前用户加入 docker 组：
```bash
sudo usermod -aG docker $USER
# 退出终端重新登录，或者执行
newgrp docker
```

### Q: Windows 上 Docker Desktop 一直卡在 "Starting..."
**A:** 
1. 确认 WSL2 已正确安装：`wsl --version`
2. 如果 WSL2 有问题：`wsl --update`
3. 在 Windows 功能中确保"虚拟机平台"和"适用于 Linux 的 Windows 子系统"都已启用
4. 重启电脑

### Q: Mac 上 Docker Desktop 启动后一直转圈
**A:** 尝试完全退出 Docker Desktop（菜单栏图标 -> Quit Docker Desktop），然后重新打开。如果还是不行，重启 Mac。

### Q: 拉取镜像超时
**A:** 大概率是网络问题。按上文配置国内镜像加速器。

---

## 动手试试

你已经执行了上面的七项检查。现在做一个小结练习：

1. 打开终端，运行以下清理命令，确保你的 Docker 环境是干净的：

```bash
# 删除所有已退出的容器
docker container prune -f

# 查看当前状态（应该很干净）
docker ps -a
docker images
```

2. 如果你在 Windows 上，运行 `wsl --version` 确认 WSL2 版本。

3. 如果你配置了镜像加速器，运行 `docker info | grep -A 5 "Registry Mirrors"`（Linux/Mac）或 `docker info | findstr "mirror"`（Windows CMD）确认已生效。

全部通过后，恭喜你——Docker 基础环境已经准备就绪，可以正式进入模块 01 开始学习镜像和容器的实际操作了。

---

## 本节小结

七项检查 + 镜像加速配置 = 你的 Docker 环境验收完毕，准备好进入实战。

---

## 模块 00 总结

到这里，Docker 导论与安装模块就全部结束了。你在这七个章节里：

- 知道了 Docker 是什么，解决什么问题（"搬家集装箱"类比）
- 区分了容器和虚拟机（"公寓楼 vs 独栋别墅"类比）
- 掌握了镜像、容器、仓库三个核心概念（"蛋糕模具"类比）
- 在 Windows / Mac / Linux 上完成了 Docker 安装
- 运行了第一个容器 hello-world，理解了背后的流程
- 完成了一次完整的环境检查

从现在开始，告别概念，进入实操。模块 01 会带你玩转镜像拉取、容器运行、端口映射、环境变量等日常开发中最常用的操作。

## 下一节预告

下一节是模块 01 的开篇——从 Docker Hub 拉取镜像。你会认识 Docker Hub 是什么，tag 又是什么，以及如何在海量公共镜像中找到你需要的那一个。
