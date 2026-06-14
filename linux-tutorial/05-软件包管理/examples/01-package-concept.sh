#!/bin/bash
# ============================================================
# 01-package-concept.sh - 包管理概念示例脚本
# 配套章节：05-01-包管理器的概念.md
#
# 本脚本演示包管理器的基本概念，不执行实际的包管理操作。
# 旨在帮助初学者理解包/依赖/仓库/包管理器的核心概念。
# ============================================================

echo "============================================"
echo "  05-01 包管理器的概念 示例"
echo "============================================"
echo ""

# -----------------------------------------------------------
# 一、什么是包？
# -----------------------------------------------------------
echo "--- 1. 什么是软件包？---"
echo "软件包（Package）是一个压缩文件，包含了："
echo "  - 编译好的二进制程序"
echo "  - 配置文件（或配置模板）"
echo "  - 文档和 man 手册页"
echo "  - 依赖信息（这个包需要哪些其他包才能运行）"
echo "  - 安装/卸载脚本（在安装前后执行的操作）"
echo ""
echo "类比：包就像宜家的平板包装家具。"
echo "  里面有一块块木板（二进制文件）、安装说明书（文档）、"
echo "  螺丝和扳手（依赖），以及注意事项卡片（安装脚本）。"
echo ""

# -----------------------------------------------------------
# 二、查看当前系统的包管理器
# -----------------------------------------------------------
echo "--- 2. 识别当前系统的包管理器 ---"

check_pkg_manager() {
    if command -v apt &>/dev/null; then
        echo "  包管理器：apt (Debian/Ubuntu 系列)"
        echo "  底层工具：dpkg"
        echo "  包格式：.deb"
    elif command -v dnf &>/dev/null; then
        echo "  包管理器：dnf (Fedora/RHEL 8+/CentOS 8+)"
        echo "  底层工具：rpm"
        echo "  包格式：.rpm"
    elif command -v yum &>/dev/null; then
        echo "  包管理器：yum (CentOS 7/RHEL 7)"
        echo "  底层工具：rpm"
        echo "  包格式：.rpm"
    elif command -v pacman &>/dev/null; then
        echo "  包管理器：pacman (Arch Linux)"
        echo "  底层工具：pacman 自身"
        echo "  包格式：.pkg.tar.zst"
    elif command -v zypper &>/dev/null; then
        echo "  包管理器：zypper (openSUSE)"
        echo "  底层工具：rpm"
        echo "  包格式：.rpm"
    else
        echo "  无法识别当前系统的包管理器。"
    fi
    echo ""
}

check_pkg_manager

# -----------------------------------------------------------
# 三、依赖关系演示
# -----------------------------------------------------------
echo "--- 3. 依赖关系概念 ---"
echo "软件之间的依赖就像拼图的互锁关系："
echo ""
echo "  安装 nginx 需要："
echo "    |- libc6       (C 标准库，所有程序都需要)"
echo "    |- libssl3     (SSL/TLS 加密库)"
echo "    |- libpcre3    (正则表达式库)"
echo "    |- zlib1g      (压缩库)"
echo ""
echo "早期 Linux 用户安装软件时的噩梦场景："
echo "  下载 A.rpm -> 提示缺少 B -> 下载 B.rpm -> 提示缺少 C"
echo "  -> 下载 C.rpm -> 提示缺少 D -> ..."
echo "  这种'依赖地狱'正是包管理器的诞生背景。"
echo ""

# -----------------------------------------------------------
# 四、软件仓库概念
# -----------------------------------------------------------
echo "--- 4. 软件仓库（Repository）---"
echo "仓库就是软件包的'云存储'。类比："
echo "  - 本地菜市场 = 本地仓库（Local Repository）"
echo "  - 大型超市 = 官方仓库（Official Repository）"
echo "  - 进口食品店 = 第三方仓库（Third-party Repository / PPA）"
echo ""
echo "仓库配置文件位置："
echo "  Debian/Ubuntu: /etc/apt/sources.list"
echo "  CentOS/RHEL:   /etc/yum.repos.d/*.repo"
echo ""

# 显示当前系统的仓库配置示例
echo "查看当前系统的仓库列表："
if [ -f /etc/apt/sources.list ]; then
    echo "  （Debian/Ubuntu 的 sources.list 前 10 行有效行）："
    grep -v "^#" /etc/apt/sources.list | grep -v "^$" | head -10
elif ls /etc/yum.repos.d/*.repo &>/dev/null; then
    echo "  （CentOS/RHEL 的仓库文件列表）："
    ls /etc/yum.repos.d/*.repo
else
    echo "  （无法在标准位置找到仓库配置）"
fi
echo ""

# -----------------------------------------------------------
# 五、包管理器 vs 源码编译 vs 容器
# -----------------------------------------------------------
echo "--- 5. 三种软件安装方式对比 ---"
echo ""
echo "方式           | 优点                     | 缺点"
echo "--------------|-------------------------|------------------"
echo "包管理器安装    | 自动解决依赖、易于更新    | 版本可能不是最新的"
echo "源码编译安装    | 可定制编译选项、最新版本  | 手动处理依赖、编译耗时"
echo "AppImage/Flatpak| 不依赖系统库、沙箱隔离   | 体积大、启动稍慢"
echo "容器(Docker)   | 完全隔离、可复现         | 额外学习成本、资源开销"
echo ""
echo "类比："
echo "  包管理器    = 去餐厅点菜（现成的、快、标准口味）"
echo "  源码编译    = 自己买菜做饭（自由度高、但费时费力）"
echo "  AppImage    = 自热火锅（自带一切、开盒即食）"
echo "  Docker容器  = 租一个专属厨房（完全独立、想怎么搞都行）"
echo ""

# -----------------------------------------------------------
# 六、包管理器的高级功能
# -----------------------------------------------------------
echo "--- 6. 包管理器的高级功能 ---"
echo "事务回滚："
echo "  dnf history undo <事务ID>   -- 回滚到之前的状态"
echo "  apt 没有内置的回滚机制，但可以通过日志手动回退"
echo ""
echo "包校验："
echo "  包管理器会验证下载的包的 GPG 签名，确保没有被篡改。"
echo "  类比：收到快递时确认封条完好，没有被中间人拆过。"
echo ""
echo "增量更新："
echo "  现代包管理器（如 dnf）支持只下载变更的部分（delta RPM），"
echo "  而不是每次更新都下载完整包。类比：APP Store 的增量更新。"
echo ""

# -----------------------------------------------------------
# 七、实际操作演示：查看一个包的依赖
# -----------------------------------------------------------
echo "--- 7. 演示：查看包的依赖信息 ---"
echo "以 bash 为例，查看它依赖哪些包："

if command -v apt-cache &>/dev/null; then
    echo "  （使用 apt-cache depends bash）："
    apt-cache depends bash 2>/dev/null | head -15
elif command -v rpm &>/dev/null; then
    echo "  （使用 rpm -qR bash）："
    rpm -qR bash 2>/dev/null | head -15
elif command -v pacman &>/dev/null; then
    echo "  （使用 pactree bash）："
    pactree -d 1 bash 2>/dev/null | head -15
fi
echo ""

# -----------------------------------------------------------
# 八、已安装包的数量统计
# -----------------------------------------------------------
echo "--- 8. 系统中已安装的包数量 ---"

if command -v dpkg &>/dev/null; then
    PACKAGE_COUNT=$(dpkg -l | grep "^ii" | wc -l)
    echo "  已安装的 .deb 包数量：${PACKAGE_COUNT}"
elif command -v rpm &>/dev/null; then
    PACKAGE_COUNT=$(rpm -qa | wc -l)
    echo "  已安装的 .rpm 包数量：${PACKAGE_COUNT}"
elif command -v pacman &>/dev/null; then
    PACKAGE_COUNT=$(pacman -Q | wc -l)
    echo "  已安装的包数量：${PACKAGE_COUNT}"
fi
echo ""

echo "============================================"
echo "  示例脚本执行完毕"
echo "============================================"
