# 00-04 Windows 上安装 Docker —— 从零到跑起来

## 本节你会学到什么

- 在 Windows 上完成 Docker Desktop 的安装
- 正确配置 WSL2 作为 Docker 的后端引擎
- 识别并解决安装过程中最常见的问题
- 验证 Docker 安装是否成功

---

## 为什么 Windows 上装 Docker 需要 WSL2？

Docker 的底层技术（namespace、cgroup 等）是 Linux 内核原生的功能。Windows 没有 Linux 内核，所以没法直接运行 Linux 容器。

Docker Desktop for Windows 的解决方案是：在后台自动创建一个轻量级的 Linux 虚拟机，让容器跑在这个虚拟机里。而 WSL2（Windows Subsystem for Linux 2）就是微软官方提供的轻量 Linux 虚拟机方案，性能比老式的 Hyper-V 虚拟机好得多。

简单说：**WSL2 就是 Docker 在 Windows 上需要的那个"Linux 内核"**。

## 安装步骤

### 第零步：确认系统要求

- Windows 10 版本 1903 或更高（64 位），或者 Windows 11
- 在 BIOS 中开启了虚拟化支持（Intel VT-x 或 AMD-V）
- 至少 4GB 内存

按下 `Ctrl + Shift + Esc` 打开任务管理器，切换到"性能"标签页，右下角看看"虚拟化"是否显示"已启用"。如果显示"已禁用"，你需要重启电脑进入 BIOS 设置打开它（不同主板的操作方式不同，一般是在开机时按 F2 / Del / F10 进入 BIOS，找到 Virtualization Technology 选项开启）。

### 第一步：安装 WSL2

打开 PowerShell（**以管理员身份运行**），依次执行：

```powershell
# 1. 启用 WSL 功能
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 2. 启用虚拟机平台功能
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 3. 重启电脑（必须！）
# 先别跳过这步，重启后再继续
```

重启后，再次以管理员身份打开 PowerShell：

```powershell
# 4. 下载并安装 WSL2 内核更新包
# 浏览器打开这个链接下载：https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
# 下载后双击安装

# 5. 将 WSL2 设置为默认版本
wsl --set-default-version 2

# 6. 验证 WSL 版本
wsl --version
```

### 第二步：安装 Docker Desktop

1. 访问 Docker Desktop 官方下载页：https://www.docker.com/products/docker-desktop/
2. 下载 Windows 版本（Docker Desktop for Windows）
3. 双击安装包，一路下一步
4. 安装过程中，确保勾选了 "Use WSL 2 instead of Hyper-V" 选项
5. 安装完成后，重启电脑

### 第三步：启动并验证

重启后，Docker Desktop 应该会自动启动（任务栏右下角会出现鲸鱼图标）。打开 PowerShell 或 CMD：

```bash
docker --version
docker run hello-world
```

如果你看到 Docker 版本号和 hello-world 的成功输出，恭喜，安装成功！

如果命令报错说"docker 不是可识别的命令"，试试在 Docker Desktop 图标上右键，选择"Restart"，等鲸鱼图标停止转动后再试。

## 常见坑和解决办法

### 坑 1：WSL2 内核未安装

**错误信息**：`WSL 2 requires an update to its kernel component.`

**解决**：下载并安装 WSL2 内核更新包（上文第一步第 4 小步的链接）。

### 坑 2：虚拟化未开启

**错误信息**：Docker Desktop 启动后提示 "Hardware assisted virtualization is disabled in BIOS"

**解决**：重启进入 BIOS，找到 Virtualization Technology / Intel VT-x / AMD-V，设为 Enabled。

### 坑 3：Docker Desktop 启动后一直转圈

**常见原因**：
- WSL2 没有正确安装。在 PowerShell 中运行 `wsl --list --verbose` 看看有没有发行版在运行。
- Windows 版本太老。确保 Windows Update 已经更新到最新。

**解决**：在 PowerShell 中运行：
```powershell
wsl --update
wsl --shutdown
```
然后重启 Docker Desktop。

### 坑 4：端口被占用

**错误信息**：`port is already allocated`

**解决**：检查是否有其他程序占用了 Docker 需要的端口。可以尝试：
```bash
# 查看端口占用
netstat -ano | findstr :<端口号>
```

### 坑 5：公司电脑有安全软件拦截

很多公司的安全软件（如 McAfee、Symantec、360 等）可能会拦截 Docker 的网络或虚拟化操作。如果一直装不上，联系你的 IT 部门确认 Docker Desktop 是否在公司的允许列表里。

## 动手试试

根据上面的步骤，完成 Docker Desktop 的安装。装完后，在终端依次运行以下三条命令，确认每个都能正常输出：

```bash
# 1. 查看 Docker 版本
docker version

# 2. 查看 Docker 系统信息
docker info

# 3. 运行测试容器
docker run --rm hello-world
```

如果三条都成功了，你的 Docker 环境就准备好了。如果卡在哪一步，回头看对应的坑和解决办法。

## 本节小结

Windows 上安装 Docker Desktop 的关键是配好 WSL2——它是 Docker 在 Windows 上的"隐形 Linux 内核"，配好后安装就是常规的下一步。

## 下一节预告

Mac 和 Linux 用户别急，下一节专门讲你们的安装方法。如果你只用 Windows，可以直接跳到第 6 节（hello-world 详解）。
