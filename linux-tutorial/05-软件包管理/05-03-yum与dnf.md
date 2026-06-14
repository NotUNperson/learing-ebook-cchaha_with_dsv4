# 05-03 yum 与 dnf

## 本节你会学到什么

- 理解 yum 和 dnf 的关系，以及为什么 Red Hat 从 yum 迁移到 dnf
- 掌握 dnf 的核心操作：搜索、安装、卸载、升级、查看信息
- 理解 EPEL 仓库的作用以及如何安装它
- 掌握 rpm 底层工具的常用场景
- 知道 dnf 独有的特色功能：事务回滚（history undo）、安全更新、包组管理

---

## 从 yum 到 dnf：一场十年接力赛

如果你在 2015 年接触 CentOS，你学到的是 `yum install`。如果你在 2020 年接触 Fedora 或 RHEL 8，你用的应该是 `dnf install`。它们很像是"父子关系" -- dnf 是 yum 的下一代版本，但它们的命令语法几乎一模一样。

为什么要换？这个故事要从 yum 的"肚子疼"说起。

yum（Yellowdog Updater Modified，名字里的 Yellowdog 是历史上一个 PowerPC 架构的 Linux 发行版）诞生于 2003 年，用 Python 2 编写。它服务了 Red Hat 系发行版将近 20 年，但它的底层依赖解析引擎比较老，处理复杂依赖关系时速度慢、内存占用大。更麻烦的是，Python 2 在 2020 年正式停止维护（End of Life），而 yum 需要 Python 2。

**类比**：yum 就像一辆开了 20 年的老捷达，它确实能送你到目的地，但油耗高、空调不冷、有时候还打不着火。dnf 是一辆换了新发动机、新悬架、新变速箱的新款，外观还保留了老捷达的经典操作方式，所以你坐进去还是知道怎么开。

dnf（Dandified YUM）于 2015 年在 Fedora 22 上首次亮相，2019 年在 RHEL 8 上成为默认包管理器。在 RHEL 8 及以上版本里，你敲 `yum` 命令，系统实际上是在调用 dnf -- `/usr/bin/yum` 已经变成了 dnf 的一个软链接。

### yum 与 dnf 的核心差异

| 维度 | yum | dnf |
|------|-----|-----|
| 依赖解析引擎 | 自己写的（慢且内存大） | libsolv 库（SUSE 开发的工业级引擎） |
| 语言 | Python 2 | Python 3（某些功能用 C/C++ 实现加速） |
| 性能 | 慢，尤其是首次操作 | 快，内存占用大幅降低 |
| 事务回滚 | 有 `yum history undo` | 有 `dnf history undo`（更可靠） |
| 包缓存清理 | 需要手动 `yum clean all` | 默认自动清理 |
| 并行下载 | 不支持 | 支持（`max_parallel_downloads`） |
| 安全更新 | 需要安装 `yum-plugin-security` | 原生支持 `dnf update --security` |

---

## dnf 的核心操作

### 刷新缓存：dnf makecache

```bash
sudo dnf makecache
```

和 `apt update` 的作用一样，将远程仓库的元数据下载到本地。不过 dnf 比 apt 智能的一点是：如果你运行 `dnf install` 时本地缓存已经过期，dnf 会**自动**先更新缓存。所以你有时候可以直接跳过 `makecache` 这一步。

但养成习惯先 `makecache` 是好做法 -- 尤其是在排查"为什么找不到某个包"时，先用 `makecache` 确保你的索引是最新的。

### 搜索包：dnf search

```bash
# 按关键词搜索
dnf search nginx

# 在包名和摘要中搜索
dnf search --name nginx

# 搜索已安装的包
dnf search --installed python3
```

### 查看包信息：dnf info

```bash
dnf info nginx

# 输出示例：
# Name         : nginx
# Version      : 1.20.1
# Release      : 14.el9
# Architecture : x86_64
# Size         : 31 k
# Source       : nginx-1.20.1-14.el9.src.rpm
# Repository   : appstream
# Summary      : A high performance web server and reverse proxy server
# URL          : http://nginx.org/
# License      : BSD
# Description  : Nginx is a web server and a reverse proxy server...
```

注意 `Repository` 行：它告诉你这个包来自哪个仓库（`appstream`、`baseos`、`epel` 等）。这对于排查版本问题非常有用。

### 安装包：dnf install

```bash
sudo dnf install nginx

# 安装多个
sudo dnf install nginx php-fpm mariadb-server

# 自动确认（-y）
sudo dnf install -y nginx

# 安装本地 .rpm 文件（dnf 会自动处理依赖！比 rpm -i 更强大）
sudo dnf install ./package.rpm

# 指定版本
sudo dnf install nginx-1.20.1-14.el9
```

### 卸载包：dnf remove

```bash
sudo dnf remove nginx

# 卸载不再需要的依赖
sudo dnf autoremove
```

### 升级：dnf upgrade

```bash
# 检查哪些包有更新
dnf check-update

# 升级所有可升级的包
sudo dnf upgrade

# 只升级某个包
sudo dnf upgrade nginx
```

注意：dnf 用 `upgrade`，而 yum 用 `update`。但实际上 `dnf update` 也能用（它是 `dnf upgrade` 的别名），实现兼容。

---

## yum/dnf 特有的强大功能

### 1. 查找"哪个包提供了某个文件"

这是 yum/dnf 最实用的功能之一。假设你运行一个命令时缺少某个库文件（比如 `libssl.so.1.1`），你不需要 Google 搜索"centos libssl.so.1.1 rpm"，直接用：

```bash
# 查找哪个包提供了 /usr/bin/htop
dnf provides /usr/bin/htop

# 查找哪个包提供了某个共享库
dnf provides "libssl.so*"

# 查找哪个包提供了某个命令（用通配符）
dnf provides "*/bin/ls"

# yum 中等价的命令
yum whatprovides /usr/bin/htop
```

**类比**：`dnf provides` 就像一本"反向电话簿"。普通电话簿是你知道名字找电话号码，而反向电话簿是你看到一个号码能查到是谁的。`dpkg -S` 和 `rpm -qf` 也能做类似的事，但它们只能查**已经安装**的文件。`dnf provides` 可以查**整个仓库**里的文件，不管你有没有安装。

### 2. 事务回滚：dnf history

dnf 会记录你每一次安装/卸载/升级操作，形成一个可回滚的事务日志。

```bash
# 查看历史记录
dnf history

# 输出示例：
# ID | Action(s)      | Altered
# -----------------------------------------------
#  5 | Install        |   12
#  4 | Upgrade        |   45
#  3 | Install        |    3
#  2 | I, U           |  156
#  1 | Install        | 1234

# 查看某次事务的详细信息
dnf history info 5

# 回滚某次事务（撤销那次操作）
sudo dnf history undo 5

# 重做某次事务
sudo dnf history redo 5
```

**类比**：这就像数据库的事务回滚。你执行了一条 `DELETE FROM important_table`，发现删错了，你可以 `ROLLBACK` 撤销。dnf history 提供了类似的功能 -- 只不过粒度是"一次安装/卸载操作"。

这是 apt 没有的功能，也是 dnf 相比 apt 的一个重要优势。

### 3. 包组管理：dnf group

有些软件不是单个包，而是一组相关包的集合。比如"开发工具"这个组包含了 gcc、make、autoconf 等十几个包。

```bash
# 列出所有可用的包组
dnf group list

# 查看某个包组包含哪些包
dnf group info "Development Tools"

# 安装整个包组
sudo dnf group install "Development Tools"

# 卸载整个包组
sudo dnf group remove "Development Tools"
```

在 apt 世界里，类似的功能叫 `tasksel`（一个独立的工具）或 `apt install kde-full` 这种"元包（meta-package）"。但 dnf 的 group 功能是内置的，更加系统化。

### 4. 安全更新

```bash
# 只安装安全更新（不影响功能更新）
sudo dnf update --security

# 查看有哪些安全公告
dnf updateinfo list

# 查看某个安全公告的详情
dnf updateinfo info CVE-2025-1234
```

在企业环境中，这个功能非常重要。你可能不想升级一个功能更新（因为怕引入新 bug），但安全漏洞必须及时修补。`--security` 让你只修漏洞，不换功能。

---

## RPM：Red Hat 系的 dpkg

rpm 是 Red Hat 系的底层包管理工具，对应 Debian 系的 dpkg。大多数时候你用 dnf/yum 就够了，但以下场景你需要 rpm：

```bash
# 安装本地 .rpm 文件（不处理依赖）
sudo rpm -ivh package.rpm

# 卸载包
sudo rpm -e package-name

# 列出所有已安装的包
rpm -qa | grep nginx

# 查看某个包安装了哪些文件
rpm -ql bash

# 查找某个文件属于哪个包
rpm -qf /bin/bash

# 查看包信息
rpm -qi bash

# 查看包的依赖
rpm -qR bash

# 校验包的完整性（文件是否被篡改）
rpm -V bash
# 无输出 = 所有文件完好无损
```

`rpm -V`（verify）非常强大。它会检查包安装的每个文件的大小、权限、MD5 校验和、修改时间等是否和安装时一致。如果某个文件被黑客篡改过，`rpm -V` 可以发现。类比：就像商场安检员核对每件商品的防伪标签是否完好。

输出中每个字符的含义：

```
S  文件大小变了
M  权限变了
5  MD5 校验和变了
D  设备号变了
L  符号链接变了
U  所有者变了
G  组变了
T  修改时间变了
P  能力（capability）变了
.  该项测试通过
```

---

## EPEL：企业版的"社区菜市场"

RHEL 和 CentOS 的官方仓库以"稳定"为最高原则。这意味着里面的软件版本通常比较老（但经过了充分的测试）。如果你想在 CentOS 上装 `htop`、`redis`、`nginx`、`certbot` 这些非常流行但不在官方仓库里的软件，你需要 **EPEL**（Extra Packages for Enterprise Linux）。

**类比**：RHEL 官方仓库是公司的"内部食堂"，菜式固定、安全卫生有保障。EPEL 是公司旁边社区开的"小吃街"，种类丰富，有你爱吃的炸鸡奶茶，但食品安全完全靠摊主自觉。

```bash
# 安装 EPEL
sudo dnf install epel-release        # RHEL 8+ / CentOS 8+ / Fedora
sudo yum install epel-release        # RHEL 7 / CentOS 7

# 查看 EPEL 仓库中的包
dnf --disablerepo="*" --enablerepo="epel" list available

# 从 EPEL 安装软件
sudo dnf install --enablerepo=epel htop
```

EPEL 由 Fedora 社区维护，质量相对可靠。但它仍然是"第三方"的，如果你在银行、政府等对安全要求极高的环境中工作，需要评估后再使用。

---

## 命令行速查：apt vs yum vs dnf 完整对照

这张表是你在两种发行版之间切换时的救命稻草。

| 操作 | Debian/Ubuntu (apt) | RHEL 7 (yum) | RHEL 8+ / Fedora (dnf) |
|------|---------------------|--------------|------------------------|
| 刷新索引 | `apt update` | `yum makecache` | `dnf makecache` |
| 搜索包 | `apt search keyword` | `yum search keyword` | `dnf search keyword` |
| 安装包 | `apt install pkg` | `yum install pkg` | `dnf install pkg` |
| 卸载包(保留配置) | `apt remove pkg` | `yum remove pkg` | `dnf remove pkg` |
| 卸载包(含配置) | `apt purge pkg` | 无直接命令 | 无直接命令 |
| 自动清理依赖 | `apt autoremove` | `yum autoremove` | `dnf autoremove` |
| 升级所有包 | `apt upgrade` | `yum update` | `dnf upgrade` |
| 完全升级 | `apt full-upgrade` | `yum distro-sync` | `dnf distro-sync` |
| 查看包信息 | `apt show pkg` | `yum info pkg` | `dnf info pkg` |
| 列出已安装 | `apt list --installed` | `yum list installed` | `dnf list installed` |
| 查找文件属于哪个包 | `dpkg -S /path/file` | `yum whatprovides /path/file` | `dnf provides /path/file` |
| 查看仓库列表 | 查看 sources.list | `yum repolist` | `dnf repolist` |
| 查看依赖 | `apt-cache depends pkg` | `yum deplist pkg` | `dnf deplist pkg` |
| 下载包(不安装) | `apt download pkg` | `yumdownloader pkg` | `dnf download pkg` |
| 查看事务历史 | 查看 /var/log/apt/ | `yum history` | `dnf history` |
| 事务回滚 | 不支持 | `yum history undo` | `dnf history undo` |
| 清理缓存 | `apt clean` | `yum clean all` | `dnf clean all` |
| 安全更新 | 无内置 | `yum update --security` | `dnf update --security` |
| 包组安装 | 使用 tasksel | `yum groupinstall` | `dnf group install` |

---

## 动手试试

**练习：用 dnf/yum 探索你的系统（或在一个虚拟机/Docker 容器中）**

如果你用的是 Fedora 或 RHEL/CentOS 系统，可以直接操作。如果没有，请使用 `docker run -it rockylinux:9 bash` 或 `docker run -it fedora:latest bash` 来获得一个临时的练习环境。

1. 查看当前有哪些仓库：
   ```bash
   dnf repolist   # 或 yum repolist
   ```

2. 搜索 `htop`：
   ```bash
   dnf search htop
   ```

3. 查看 `htop` 的详细信息：
   ```bash
   dnf info htop
   ```

4. 用 `dnf provides` 查找 `/usr/bin/htop` 属于哪个包：
   ```bash
   dnf provides /usr/bin/htop
   # 对比 rpm -qf（只能找已安装的文件）
   ```

5. 安装 `htop`：
   ```bash
   sudo dnf install htop
   ```

6. 运行 `htop`，感受一下这个 top 增强版的彩色界面。按 `q` 退出。

7. 查看安装历史：
   ```bash
   dnf history
   dnf history info 最后一条的ID
   ```

8. （可选）回滚这次安装：
   ```bash
   sudo dnf history undo 最后一条的ID
   ```

9. 用 rpm 查看 htop 安装了哪些文件（如果还没卸载的话）：
   ```bash
   rpm -ql htop
   ```

---

## 本节小结

yum 和 dnf 是 Red Hat 系发行版的包管理器，dnf 是 yum 的现代化接班人（依赖解析更快、支持事务回滚、原生安全更新），它们与 apt 的核心理念一致（上层工具管理依赖 + 仓库，底层 rpm/dpkg 操作本地包文件）；dnf 的 `history undo`（事务回滚）、`provides`（反向查找文件所属包）和 `group install`（包组管理）是其区别于 apt 的特色功能。

---

## 下一节预告

包管理的最后一节：综合练习。我们将从源码编译安装 Nginx -- 下载 tar.gz、运行 `./configure` 设置编译选项、`make` 编译、`make install` 安装，最后创建一个 systemd 服务文件让它开机自启。这是"自己买菜做饭"的完整体验，也是你 Linux 学习路上的一个重要里程碑。
