# 00-05 Mac / Linux 上安装 Docker

## 本节你会学到什么

- 在 Mac 上安装 Docker Desktop
- 在 Ubuntu / Debian / CentOS 等 Linux 发行版上安装 Docker
- 验证安装是否成功
- 区分 Docker Desktop 和 Docker Engine 这两种安装方式

---

## Mac 和 Linux 谁更"顺"？

先回答一个问题：Docker 原生的技术根基是 Linux 内核功能（namespace、cgroup 等）。所以：

- **Linux 上**：Docker 可以直接利用宿主机内核，性能最好，没有中间层，是 Docker 的"主场"。
- **Mac 上**：macOS 也没有 Linux 内核，所以 Docker Desktop for Mac 会在后台运行一个轻量 Linux 虚拟机。不过 Apple 芯片（M1/M2/M3）的虚拟化效率非常高，日常开发几乎感受不到差异。

不管是哪个平台，安装过程都不复杂。下面我们分开讲。

---

## Mac 上安装 Docker Desktop

### 确认芯片类型

点左上角苹果图标 -> "关于本机"，看看是 Intel 芯片还是 Apple 芯片（M1/M2/M3）。下载对应版本即可。

### 安装步骤

1. 打开 Docker Desktop 下载页：https://www.docker.com/products/docker-desktop/
2. 根据你的芯片类型选择下载：Apple Chip（M 系列）或 Intel Chip
3. 下载完成后，双击 `.dmg` 文件
4. 把 Docker 图标拖到 Applications 文件夹
5. 在"应用程序"中找到 Docker，双击启动
6. 首次启动会要求你授权（输入密码），同意即可
7. 等待菜单栏顶部出现鲸鱼图标，图标稳定后说明启动完成

### 验证安装

打开终端，运行：

```bash
docker --version
docker run --rm hello-world
```

如果你看到了版本号和 hello-world 的输出，安装成功。

### 常用配置建议

启动后，点菜单栏鲸鱼图标 -> "Settings"：

- **Resources**：根据你的电脑配置，适当调整分配给 Docker 的 CPU、内存、磁盘。Mac 上默认值一般够用，但如果你跑多个容器，可以加到 4GB 以上内存。
- **General**：建议勾选 "Start Docker Desktop when you log in"，省得每次开机都要手动启动。

---

## Linux 上安装 Docker

在 Linux 上你有两种选择：
1. **Docker Desktop for Linux**：图形界面，跟 Windows/Mac 体验一致
2. **Docker Engine**：纯命令行，也是生产服务器上的标准安装方式

对于学习来说，两者都可以。下面讲的是 **Docker Engine** 的命令行安装方式（更接近你未来在服务器上的实际使用场景）。

### Ubuntu / Debian

```bash
# 1. 卸载旧版本（如果有的话）
sudo apt-get remove docker docker-engine docker.io containerd runc

# 2. 更新包索引
sudo apt-get update

# 3. 安装依赖
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 4. 添加 Docker 官方 GPG 密钥
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 5. 添加 Docker 官方仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 6. 安装 Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 7. 启动 Docker 并设为开机自启
sudo systemctl enable docker
sudo systemctl start docker

# 8. 把当前用户加入 docker 组（避免每次都用 sudo）
sudo usermod -aG docker $USER

# 9. 重新登录或运行以下命令使组生效
newgrp docker

# 10. 验证
docker run --rm hello-world
```

### CentOS / RHEL / Fedora

```bash
# 1. 卸载旧版本
sudo yum remove docker docker-client docker-client-latest docker-common \
    docker-latest docker-latest-logrotate docker-logrotate docker-engine

# 2. 安装依赖
sudo yum install -y yum-utils

# 3. 添加 Docker 仓库
sudo yum-config-manager --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# 4. 安装 Docker Engine
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 5. 启动并设置开机自启
sudo systemctl enable docker
sudo systemctl start docker

# 6. 加用户到 docker 组
sudo usermod -aG docker $USER
newgrp docker

# 7. 验证
docker run --rm hello-world
```

---

## 生产环境小贴士

如果你是部署到生产环境的 Linux 服务器，建议用 `docker-ce`（社区版）而非 Docker Desktop。服务器不需要图形界面，纯命令行的 Docker Engine 更稳定、更节省资源。

另外，如果你不想用官方脚本手动安装，Docker 也提供了一键安装脚本（但生产环境一般不建议直接用，因为要审计安装内容）：

```bash
curl -fsSL https://get.docker.com | sudo sh
```

不过你刚开始学习的话，按上面步骤一步步来更稳妥，你会更清楚每一步在做什么。

---

## 动手试试

根据你的系统，完成对应的安装步骤。安装完成后运行以下三条命令确认一切正常：

```bash
# 1. 查看 Docker 版本信息（客户端 + 服务端）
docker version

# 2. 查看 Docker 系统状态（存储驱动、容器数量、镜像数量等）
docker info

# 3. 运行官方测试镜像
docker run --rm hello-world
```

三条都跑通，说明你的 Docker 环境已经准备就绪。如果第三条命令报权限错误（`permission denied`），说明你忘记了把用户加入 docker 组——回头看安装步骤的第 8 小步。

---

## 本节小结

Mac 上走 Docker Desktop，下载安装就好；Linux 上走 Docker Engine，几条命令就装完——无论哪个平台，装完后用一个 `docker run hello-world` 验证就行。

---

## 下一节预告

终于到了动手的一刻。下一节我们运行 hello-world，你会第一次看到 Docker 的实际输出。我会逐行解释输出中每一段文字的含义，让你真正理解 `docker run` 背后发生了什么。
