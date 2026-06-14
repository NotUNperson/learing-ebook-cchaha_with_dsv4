# 00-02 安装 Nginx

## 本节你会学到什么

- 在 Windows 上下载并解压运行 Nginx
- 在 Linux 上使用包管理器安装 Nginx
- 理解 Nginx 安装后的目录结构和每个目录的用途
- 验证 Nginx 是否安装成功

## 正文

### 安装前的准备

Nginx 的安装和运行都非常轻量。它的安装包体积小，运行时占用的内存也很少。无论你用 Windows 开发机还是 Linux 服务器，安装过程都不会超过五分钟。

### Windows 安装

Windows 上的 Nginx 官方不提供 .msi 安装程序，而是提供压缩包。这其实更方便——想删掉直接删文件夹就行，不会在注册表里留垃圾。

**步骤：**

1. 打开浏览器，访问 http://nginx.org/en/download.html
2. 找到 "Mainline version"（主线版本）或 "Stable version"（稳定版），建议选稳定版
3. 下载对应的 .zip 文件
4. 将下载的 zip 文件解压到一个目录，比如 `C:\nginx`

解压之后，你会在 `C:\nginx` 下看到这样的目录结构：

```
C:\nginx\
├── conf\         # 配置文件目录
├── html\         # 默认网页文件
├── logs\         # 日志文件
├── temp\         # 临时文件
├── nginx.exe     # 主程序
```

**启动：** 打开命令提示符（cmd），进入 Nginx 目录，输入：

```
cd C:\nginx
start nginx
```

你会看到命令提示符闪一下，然后立即返回。Nginx 在后台运行了。

**验证：** 打开浏览器，访问 `http://localhost`。如果看到 "Welcome to nginx!" 页面，说明安装成功。

**停止：**

```
nginx -s stop
```

如果你修改了配置文件想让它生效，可以重新加载配置而不停止服务：

```
nginx -s reload
```

### Linux 安装（Ubuntu/Debian）

在 Ubuntu 或 Debian 系统上，直接用包管理器安装是最简单的方式：

```bash
# 更新软件包列表
sudo apt update

# 安装 Nginx
sudo apt install nginx -y
```

安装完成后，Nginx 会自动启动。你可以用以下命令确认：

```bash
# 查看 Nginx 是否在运行
sudo systemctl status nginx
```

### Linux 安装（CentOS/RHEL）

在 CentOS 或 RHEL 系统上，使用 yum：

```bash
# 安装 EPEL 仓库（Nginx 在这个仓库里）
sudo yum install epel-release -y

# 安装 Nginx
sudo yum install nginx -y

# 启动 Nginx
sudo systemctl start nginx

# 设置开机自启
sudo systemctl enable nginx
```

Linux 安装后，Nginx 的文件会分散在系统的标准目录中：

| 路径 | 用途 |
|------|------|
| `/etc/nginx/` | 配置文件主目录 |
| `/etc/nginx/nginx.conf` | 主配置文件 |
| `/etc/nginx/sites-available/` | 各个站点的配置文件 |
| `/etc/nginx/sites-enabled/` | 启用的站点（通常是软链接） |
| `/usr/share/nginx/html/` | 默认网页根目录 |
| `/var/log/nginx/` | 日志文件目录 |
| `/usr/sbin/nginx` | 可执行文件 |

### 目录结构详解

不管是 Windows 还是 Linux，Nginx 都有这几个核心目录。用搬新家来类比：你搬进一个新房子，得知道卧室在哪、厨房在哪、水电总闸在哪。Nginx 的目录布局就是你管理服务器的"户型图"。

**conf 目录（配置文件）：**
这里是 Nginx 的"大脑"。所有关于端口、域名、路由规则的设定都在这里。`nginx.conf` 是主配置文件，其他配置文件可以通过 `include` 指令引入。

**html 目录（网页根目录）：**
默认的网页文件放在这里。你安装完直接访问 localhost 看到的那个欢迎页，就是 `html/index.html`。就像餐厅门口摆的菜单，客人来了先看到什么就由这里决定。

**logs 目录（日志文件）：**
两个重要的日志文件：
- `access.log`：访问日志，记录谁在什么时间访问了什么页面，相当于餐厅的来客登记本
- `error.log`：错误日志，记录 Nginx 运行时出了什么问题，相当于维修记录本

**sbin 目录（可执行文件）：**
Nginx 的主程序就在这里。你启动、停止、重载 Nginx 都是通过这个可执行文件。

### 验证安装成功的几种方式

```bash
# 方式一：查看版本号
nginx -v
# 输出类似：nginx version: nginx/1.24.0

# 方式二：查看版本和编译参数（大写 V）
nginx -V
# 输出更详细，包含编译时开启的模块

# 方式三：测试配置文件语法
nginx -t
# 输出类似：
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful

# 方式四：访问浏览器
# 打开 http://localhost，看到欢迎页面即成功
```

`nginx -t` 是一个非常实用的命令——每次修改配置文件后，在重载之前先用它测试语法，可以避免因为配置写错导致服务挂掉。就像你写完一篇重要的邮件，发出前先检查一遍有没有错别字。

## 动手试试

1. 根据你的操作系统，按照上面的步骤安装 Nginx。
2. 安装完成后，执行 `nginx -v` 和 `nginx -V`，观察输出有什么不同。
3. 找到 Nginx 的 `html` 或 `www` 目录，用文本编辑器打开 `index.html`，看一看默认欢迎页的 HTML 长什么样。
4. 打开浏览器访问 `http://localhost`，确认看到欢迎页面。

## 本节小结

Nginx 的安装非常简单，Windows 上下载解压即可，Linux 上一行命令搞定。安装后了解各目录的用途是后续配置的基础。

## 下一节预告

下一节我们将启动第一个 Nginx 服务器，学习启动、停止、重载等基本操作，并理解 Nginx 的 master/worker 进程模型。
