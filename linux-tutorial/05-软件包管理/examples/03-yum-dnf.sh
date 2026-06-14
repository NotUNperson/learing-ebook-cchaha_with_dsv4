#!/bin/bash
# ============================================================
# 03-yum-dnf.sh - yum 与 dnf 包管理示例脚本
# 配套章节：05-03-yum与dnf.md
#
# 适用于 RHEL 7/CentOS 7 (yum) 或 RHEL 8+/Fedora (dnf)
# 在非 RPM 系统上会自动跳过实际操作。
# ============================================================

echo "============================================"
echo "  05-03 yum 与 dnf 包管理 示例"
echo "============================================"
echo ""

# 确定当前系统使用哪个包管理器
PKG_CMD=""
if command -v dnf &>/dev/null; then
    PKG_CMD="dnf"
    echo "检测到包管理器：dnf (RHEL 8+/Fedora)"
elif command -v yum &>/dev/null; then
    PKG_CMD="yum"
    echo "检测到包管理器：yum (RHEL 7/CentOS 7)"
else
    echo "当前系统不支持 yum 或 dnf。"
    echo "本节内容适用于 RHEL/CentOS/Fedora 系列。"
    echo "以下是命令说明和示例。"
fi
echo ""

# -----------------------------------------------------------
# 一、仓库配置
# -----------------------------------------------------------
echo "--- 1. 仓库配置 ---"
echo "Red Hat 系的仓库配置在 /etc/yum.repos.d/ 目录下，"
echo "每个 .repo 文件定义一个或多个仓库。"

if [ -d /etc/yum.repos.d ]; then
    echo ""
    echo "当前系统中的仓库文件："
    ls -la /etc/yum.repos.d/*.repo 2>/dev/null || echo "  （未找到 .repo 文件）"
    echo ""
    if ls /etc/yum.repos.d/*.repo &>/dev/null; then
        echo "查看第一个仓库文件的内容（前 30 行）："
        head -30 "$(ls /etc/yum.repos.d/*.repo | head -1)"
    fi
else
    echo "  目录 /etc/yum.repos.d/ 不存在。"
fi
echo ""

# 仓库配置格式说明
echo "一个典型的 .repo 文件格式："
cat << 'REPOEXAMPLE'
[baseos]
name=CentOS Stream $releasever - BaseOS
baseurl=http://mirror.centos.org/centos/$releasever-stream/BaseOS/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[appstream]
name=CentOS Stream $releasever - AppStream
baseurl=http://mirror.centos.org/centos/$releasever-stream/AppStream/$basearch/os/
gpgcheck=1
enabled=1
REPOEXAMPLE
echo ""

# -----------------------------------------------------------
# 二、yum / dnf 常用命令对照
# -----------------------------------------------------------
echo "--- 2. 常用命令对照表 ---"
echo ""
echo "操作           | yum                    | dnf                    | apt (对比)"
echo "--------------|------------------------|------------------------|-----------------"
echo "刷新索引       | yum makecache          | dnf makecache          | apt update"
echo "搜索包         | yum search <关键词>    | dnf search <关键词>    | apt search"
echo "安装包         | yum install <包名>     | dnf install <包名>     | apt install"
echo "卸载包         | yum remove <包名>      | dnf remove <包名>      | apt remove"
echo "升级所有包     | yum update             | dnf upgrade            | apt upgrade"
echo "查看包信息     | yum info <包名>        | dnf info <包名>        | apt show"
echo "列出已安装     | yum list installed     | dnf list installed     | apt list --installed"
echo "列出可更新     | yum list updates       | dnf list upgrades      | apt list --upgradable"
echo "查看仓库列表   | yum repolist           | dnf repolist           | (无直接对应)"
echo "查看依赖       | yum deplist <包名>     | dnf deplist <包名>     | apt-cache depends"
echo "查看历史       | yum history            | dnf history            | (查看日志文件)"
echo "清理缓存       | yum clean all          | dnf clean all          | apt clean"
echo "下载包(不安装) | yumdownloader <包名>   | dnf download <包名>    | apt download"
echo "本地安装rpm    | yum localinstall <rpm> | dnf install <本地rpm>  | dpkg -i"
echo "查找文件所属包 | yum whatprovides <文件>| dnf provides <文件>    | dpkg -S"
echo "组安装         | yum groupinstall <组>  | dnf group install <组> | (无直接对应)"
echo ""

# -----------------------------------------------------------
# 三、yum 到 dnf 的演进
# -----------------------------------------------------------
echo "--- 3. yum 与 dnf 的区别 ---"
echo ""
echo "dnf (Dandified YUM) 是 yum 的下一代替代品，Fedora 22+ 和 RHEL 8+ 默认使用。"
echo ""
echo "dnf 相比 yum 的改进："
echo "  1. 依赖解析使用 libsolv 库（更快、更准确、更低内存）"
echo "  2. 原生支持 Python 3（yum 依赖 Python 2）"
echo "  3. 事务历史更加完善，支持回滚"
echo "  4. 更好的并行下载性能"
echo "  5. 更清晰的 CLI 输出（带进度条、表格式结果）"
echo "  6. dnf 命令和 yum 命令高度兼容（/usr/bin/yum 是 dnf 的软链接）"
echo ""
echo "迁移提示：如果从 CentOS 7 迁移到 8/9，你仍然可以敲 'yum'，"
echo "系统会自动转发到 dnf。"
echo ""

# -----------------------------------------------------------
# 四、实际操作演示
# -----------------------------------------------------------
echo "--- 4. 实际操作演示 ---"

if [ -n "$PKG_CMD" ]; then
    echo ""
    echo "查看已安装的包总数："
    rpm -qa | wc -l
    echo ""

    echo "搜索 nginx 相关包："
    $PKG_CMD search nginx 2>/dev/null | head -15 || echo "  搜索未返回结果。"
    echo ""

    echo "查看 nginx 的详细信息："
    $PKG_CMD info nginx 2>/dev/null | head -20 || echo "  nginx 在仓库中未找到。"
    echo ""

    echo "列出可更新的包（前 10 个）："
    $PKG_CMD list updates 2>/dev/null | head -10 || echo "  所有包都是最新的。"
    echo ""

    echo "查看仓库列表："
    $PKG_CMD repolist 2>/dev/null | head -20
    echo ""
else
    echo "  （跳过实际操作）"
fi
echo ""

# -----------------------------------------------------------
# 五、EPEL 仓库
# -----------------------------------------------------------
echo "--- 5. EPEL（Extra Packages for Enterprise Linux）---"
echo "EPEL 是 Fedora 社区维护的额外软件仓库，提供 RHEL/CentOS 官方仓库没有的软件。"
echo ""
echo "安装 EPEL："
echo "  RHEL/CentOS 7:  sudo yum install epel-release"
echo "  RHEL/CentOS 8+: sudo dnf install epel-release"
echo "  Fedora:         不需要，Fedora 本身已经包含了大部分软件"
echo ""
echo "EPEL 提供的常见软件：htop, nginx, certbot, redis, ..."
echo ""
echo "检查 EPEL 是否已安装："
if command -v rpm &>/dev/null; then
    rpm -q epel-release 2>/dev/null && echo "  EPEL 已安装。" || echo "  EPEL 未安装。"
fi
echo ""

# -----------------------------------------------------------
# 六、rpm 底层工具
# -----------------------------------------------------------
echo "--- 6. rpm -- 底层包管理 ---"
echo "rpm 是 Red Hat 系的底层包管理工具，类似于 Debian 系的 dpkg。"
echo ""
echo "  rpm -ivh <包文件.rpm>     # 安装本地 rpm 包（不处理依赖）"
echo "  rpm -e <包名>             # 卸载包"
echo "  rpm -qa                   # 列出所有已安装的包"
echo "  rpm -ql <包名>            # 列出包的安装文件列表"
echo "  rpm -qf /path/to/file     # 查询文件属于哪个包"
echo "  rpm -qi <包名>            # 查看包信息"
echo "  rpm -qR <包名>            # 查看包的依赖"
echo "  rpm --verify <包名>       # 校验包的完整性（检查文件是否被修改）"
echo ""

if command -v rpm &>/dev/null; then
    echo "演示：bash 包安装了哪些文件（前 10 个）："
    rpm -ql bash 2>/dev/null | head -10
    echo ""
    echo "演示：查看 /bin/bash 属于哪个包："
    rpm -qf /bin/bash 2>/dev/null
fi
echo ""

# -----------------------------------------------------------
# 七、dnf history 事务回滚
# -----------------------------------------------------------
echo "--- 7. dnf history -- 事务历史与回滚 ---"
echo "dnf 的一个独特功能是可以回滚到之前的状态。"
echo ""
echo "  dnf history                     # 查看安装/卸载历史"
echo "  dnf history info <事务ID>        # 查看某次事务的详情"
echo "  dnf history undo <事务ID>        # 回滚某次事务（撤销那次安装/卸载）"
echo "  dnf history redo <事务ID>        # 重做某次事务"
echo ""
echo "示例场景：你装了 10 个包，结果发现其中某个包和现有软件冲突。"
echo "你不用手动把这 10 个包一个个卸掉，直接 'dnf history undo' 就行。"
echo ""
echo "注意：apt 没有内置的历史回滚功能，这对 dnf 用户来说是独享福利。"
echo ""

# -----------------------------------------------------------
# 八、dnf 独有特性
# -----------------------------------------------------------
echo "--- 8. dnf 的独有特性 ---"
echo ""
echo "1. 自动清理："
echo "   dnf 默认会在安装/更新后自动删除下载的包缓存"
echo "   （yum 需要手动 yum clean all）"
echo ""
echo "2. 安全更新："
echo "   dnf update --security           # 只安装安全更新"
echo "   dnf updateinfo list             # 查看可用的安全公告"
echo ""
echo "3. 跳过损坏的包："
echo "   dnf upgrade --skip-broken       # 跳过依赖无法满足的包，继续升级其他"
echo ""
echo "4. 包组管理："
echo "   dnf group list                  # 列出所有包组"
echo "   dnf group install 'Development Tools'  # 安装开发工具组"
echo ""

echo "============================================"
echo "  示例脚本执行完毕"
echo "============================================"
