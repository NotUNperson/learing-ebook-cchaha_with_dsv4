# 07-03 WSL 2 与 Docker Desktop 深度解析

## 本节你会学到什么

- 理解 WSL 2 在 Docker Desktop 中的角色
- 掌握 WSL 2 的常用管理命令
- 学会在 WSL 中直接操作 Docker
- 了解 WSL 2 虚拟磁盘的存放位置与迁移方法

---

## WSL 2：Windows 上的 Linux "虚拟机"

WSL 的全称是 Windows Subsystem for Linux，可以理解为"Windows 内置的 Linux 子系统"。它的第二代（WSL 2）是目前 Docker Desktop 在 Windows 上的默认后端。

类比一下：WSL 2 就像在 Windows 这个大杂居小区里，单独给你隔出了一套精装修的 Linux 公寓。你在这套公寓里拥有一套完整的 Linux 内核，但它又不完全独立于 Windows——你可以从 Windows 命令行直接打开 Linux 的文件，反之亦然。

Docker Desktop 就是在 WSL 2 这套"精装公寓"里跑 Linux 容器。Windows 上的 Docker Desktop 本质上是一个管理界面，真正干活的是 WSL 2 里的 Docker Engine。

---

## 常用 WSL 管理命令

这些命令在 PowerShell 或 CMD 中执行：

```powershell
# 列出所有安装的 WSL 发行版及版本号
wsl -l -v

# 输出示例：
#   NAME                   STATE           VERSION
# * Ubuntu-22.04           Running         2
#   docker-desktop         Running         2
#   docker-desktop-data    Running         2
```

你会看到 `docker-desktop` 和 `docker-desktop-data` 两个发行版：
- `docker-desktop`：Docker Engine 本体
- `docker-desktop-data`：镜像、容器、卷等数据的存储位置

```powershell
# 关闭所有 WSL 发行版（释放内存，进行虚拟磁盘操作前的必要步骤）
wsl --shutdown

# 进入默认发行版的 shell
wsl

# 进入指定发行版
wsl -d Ubuntu-22.04

# 设置默认发行版
wsl --set-default Ubuntu-22.04

# 终止某个发行版
wsl -t docker-desktop-data

# 更新 WSL 内核
wsl --update
```

---

## 在 WSL 中直接使用 Docker

Docker Desktop 安装后，它的 CLI 工具会自动注册到 Windows 的 PATH 中——你在 PowerShell 里直接输入 `docker run` 就能用。但实际上你也可以进入 WSL 的 Linux 环境里使用 Docker。

Docker Desktop 提供了一个 `docker` 上下文（context），让 WSL 里的 Docker CLI 可以连接到 Docker Desktop 的 Engine：

```bash
# 在 WSL 中检查当前 Docker 上下文
docker context ls

# 如果显示了 docker-desktop 上下文，说明已自动连接
```

这意味着：**你可以在 WSL 的 Linux 终端里执行 docker 命令，但容器实际上跑在 Docker Desktop 管理的 WSL 2 后端中**。

---

## 虚拟磁盘的存放位置

了解这些路径很重要，在排查磁盘问题时你会需要：

| 文件 | 路径 | 作用 |
|------|------|------|
| `ext4.vhdx` | `%LOCALAPPDATA%\Docker\wsl\data\ext4.vhdx` | Docker Desktop 的系统数据 |
| `docker_data.vhdx` | `%LOCALAPPDATA%\Docker\wsl\disk\docker_data.vhdx` | 镜像、容器、卷的实际存储 |

（`%LOCALAPPDATA%` 通常等于 `C:\Users\你的用户名\AppData\Local`）

---

## 迁移 Docker Desktop 数据到其他盘

C 盘空间紧张？可以把 Docker 数据迁移到 D 盘：

**方法一：通过 Docker Desktop 设置（最简单）**

打开 Docker Desktop → Settings → Resources → Advanced → Disk image location，修改为 D 盘的路径。然后点 Apply，Docker 会自动迁移。

**方法二：手动迁移 WSL 发行版**

```powershell
# 1. 先关机
wsl --shutdown

# 2. 导出 docker-desktop-data 到 D 盘
wsl --export docker-desktop-data D:\docker-data\docker-desktop-data.tar

# 3. 注销原来的发行版
wsl --unregister docker-desktop-data

# 4. 从导出的文件重新注册到 D 盘
wsl --import docker-desktop-data D:\docker-data\ D:\docker-data\docker-desktop-data.tar

# 5. 对 docker-desktop 重复上述操作
wsl --export docker-desktop D:\docker-data\docker-desktop.tar
wsl --unregister docker-desktop
wsl --import docker-desktop D:\docker-desktop\ D:\docker-data\docker-desktop.tar
```

重启 Docker Desktop 即可。

---

## .wslconfig 配置文件

在你的 Windows 用户目录（`C:\Users\你的用户名\`）下创建 `.wslconfig` 文件，可以限制 WSL 2 的总资源：

```ini
[wsl2]
# 限制 WSL 2 总内存为 8G
memory=8GB

# 限制 WSL 2 使用最多 4 个处理器核心
processors=4

# 限制 swap 为 2G
swap=2GB

# swap 存放位置
swapFile=D:\\wsl-swap.vhdx

# 允许 localhost 转发（默认开启）
localhostForwarding=true
```

保存后执行 `wsl --shutdown` 然后重启 WSL 使配置生效。这相当于给 WSL 2 这座"楼"设定了总体的水电气限额，避免它吃掉整台机器的资源。

---

## 动手试试

1. 在 PowerShell 中执行 `wsl -l -v`，看看当前有哪些 WSL 发行版在运行
2. 找到 `ext4.vhdx` 或 `docker_data.vhdx` 文件，记下它们的大小
3. 如果 C 盘空间紧张，尝试用 Docker Desktop 设置将数据位置迁移到其他盘
4. 创建一个 `.wslconfig` 文件，限制 WSL 2 使用不超过 4G 内存

---

## 本节小结

WSL 2 是 Docker Desktop 在 Windows 上的核心后端，理解它的文件位置、虚拟磁盘特性和管理命令，是解决 Windows 上 Docker 各类问题的关键。

---

## 本模块结束

拓展模块的三节到这里就讲完了。我们覆盖了三个"教程正文容易被忽略但实际用起来经常踩坑"的话题：磁盘空间回收、资源限制、WSL 2 深度理解。掌握这些，你的 Docker 武库会更加完整。

如果你想继续深入，可以回顾模块 06 中的"实战项目"部分开始实际练习，或者参考 06-08 的学习路线规划下一步方向。
