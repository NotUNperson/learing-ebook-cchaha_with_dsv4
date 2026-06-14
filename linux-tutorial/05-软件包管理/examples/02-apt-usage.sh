#!/bin/bash
# ============================================================
# 02-apt-usage.sh - apt 系包管理示例脚本
# 配套章节：05-02-apt系包管理.md
#
# 本脚本适用于 Debian、Ubuntu、Linux Mint 等使用 apt 的系统。
# 在非 apt 系统上运行会自动跳过实际操作，仅做演示说明。
# ============================================================

echo "============================================"
echo "  05-02 apt 系包管理 示例"
echo "============================================"
echo ""

# 检查是否为 apt 系统
if ! command -v apt &>/dev/null; then
    echo "当前系统不支持 apt。"
    echo "apt 适用于 Debian、Ubuntu、Linux Mint 等发行版。"
    echo "如果你的系统使用 yum/dnf，请参考 05-03 节。"
    echo ""
    echo "以下是 apt 的常用命令说明（不做实际操作）："
fi

# -----------------------------------------------------------
# 一、apt update -- 刷新索引
# -----------------------------------------------------------
echo "--- 1. apt update -- 刷新软件包索引 ---"
echo "将本地缓存的包列表与远程仓库同步。"
echo "类比：打开外卖 APP，刷新菜单数据。"
echo ""
echo "命令：sudo apt update"
echo "输出示例："
echo "  Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease"
echo "  Get:2 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [119 kB]"
echo "  ..."
echo "  Reading package lists... Done"
echo ""
echo "注意：apt update 只刷新索引，不会真正更新任何软件。"
echo "必须配合 apt upgrade 才能真正升级软件。"
echo ""

# -----------------------------------------------------------
# 二、apt search -- 搜索包
# -----------------------------------------------------------
echo "--- 2. apt search -- 搜索包 ---"
echo "在包索引中按关键词搜索。"
echo ""
if command -v apt &>/dev/null; then
    echo "搜索 'nginx'："
    apt search nginx 2>/dev/null | head -20
else
    echo "（跳过实际操作，请在 apt 系统上运行）"
fi
echo ""

# -----------------------------------------------------------
# 三、apt show -- 查看包的详细信息
# -----------------------------------------------------------
echo "--- 3. apt show -- 查看包的详细信息 ---"
echo "显示版本号、依赖、描述、大小等信息。"
echo ""
if command -v apt &>/dev/null; then
    echo "查看 nginx 的详细信息（如果存在）："
    apt show nginx 2>/dev/null | head -30 || echo "  nginx 在仓库中未找到。"
else
    echo "（跳过实际操作，请在 apt 系统上运行）"
fi
echo ""

# -----------------------------------------------------------
# 四、apt list -- 列出包
# -----------------------------------------------------------
echo "--- 4. apt list -- 列出包 ---"
echo ""
echo "常用变体："
echo "  apt list --installed              # 列出已安装的包"
echo "  apt list --upgradable             # 列出可升级的包"
echo "  apt list --all-versions nginx    # 列出某包的所有可用版本"
echo ""

if command -v apt &>/dev/null; then
    echo "列出可升级的包（前 10 个）："
    apt list --upgradable 2>/dev/null | head -10 || echo "  所有包都是最新的。"
else
    echo "（跳过实际操作，请在 apt 系统上运行）"
fi
echo ""

# -----------------------------------------------------------
# 五、apt install -- 安装包
# -----------------------------------------------------------
echo "--- 5. apt install -- 安装软件包 ---"
echo ""
echo "命令格式：sudo apt install <包名>"
echo ""
echo "安装过程中的交互提示："
echo "  - 选择 Y/n 确认安装（包括所有依赖）"
echo "  - 如果存在配置文件冲突，会询问保留哪个版本"
echo ""
echo "常用参数："
echo "  apt install -y <包名>            # 自动回答 yes（适合脚本）"
echo "  apt install --no-upgrade <包名>  # 只安装新包，不升级已有的包"
echo "  apt install --reinstall <包名>   # 重新安装（覆盖配置文件）"
echo "  apt install --dry-run <包名>     # 模拟安装，看看会装什么但不实际操作"
echo ""

# 模拟安装演示
echo "演示：模拟安装 nginx（不会真正安装）"
if command -v apt &>/dev/null; then
    apt install --dry-run nginx 2>/dev/null | head -30 || echo "  nginx 在仓库中未找到。"
else
    echo "（跳过实际操作）"
fi
echo ""

# -----------------------------------------------------------
# 六、apt remove / apt purge -- 卸载包
# -----------------------------------------------------------
echo "--- 6. apt remove 与 apt purge -- 卸载包 ---"
echo ""
echo "  sudo apt remove <包名>    # 卸载软件，保留配置文件"
echo "  sudo apt purge <包名>     # 卸载软件 + 删除配置文件"
echo "  sudo apt autoremove       # 删除不再需要的依赖包"
echo ""
echo "类比："
echo "  apt remove   = 把客人送走，但茶杯和椅子还留着（下次来还能坐）"
echo "  apt purge    = 把客人送走，连茶杯椅子桌布全扔了"
echo "  apt autoremove = 客人走了，你发现冰箱里的食材也用不到了，一起扔"
echo ""

# -----------------------------------------------------------
# 七、apt upgrade / full-upgrade -- 升级
# -----------------------------------------------------------
echo "--- 7. apt upgrade 与 apt full-upgrade -- 升级 ---"
echo ""
echo "  sudo apt update && sudo apt upgrade      # 标准升级（安全升级）"
echo "  sudo apt update && sudo apt full-upgrade  # 完全升级（可能卸载冲突包）"
echo ""
echo "区别："
echo "  upgrade：                        只升级已安装的包，不增删包。"
echo "  full-upgrade（旧称 dist-upgrade）：可以删除/安装包以解决依赖冲突。"
echo ""
echo "类比："
echo "  upgrade         = 把厨房里现有的调料瓶换成新的（不增不减）"
echo "  full-upgrade    = 根据需要换掉调料瓶，甚至替换烤箱（允许删除和新增）"
echo ""
echo "建议：服务器上用 upgrade，桌面系统用 full-upgrade。"
echo ""

# -----------------------------------------------------------
# 八、dpkg -- 底层包管理工具
# -----------------------------------------------------------
echo "--- 8. dpkg -- 底层包管理 ---"
echo "dpkg 是 apt 的底层工具，直接操作 .deb 文件。"
echo ""
echo "  dpkg -i xxx.deb          # 安装本地 .deb 包（不处理依赖！）"
echo "  dpkg -r 包名             # 卸载包（保留配置）"
echo "  dpkg -P 包名             # 彻底卸载（含配置）"
echo "  dpkg -l                  # 列出所有已安装的包"
echo "  dpkg -L 包名             # 列出某个包安装了哪些文件"
echo "  dpkg -S /path/to/file    # 查找文件属于哪个包"
echo "  dpkg --configure -a      # 修复未完成的配置（dpkg 中断后的补救）"
echo ""

# dpkg 实际演示
echo "演示：查看 bash 包安装了哪些文件（前 10 个）："
if command -v dpkg &>/dev/null; then
    dpkg -L bash 2>/dev/null | head -10
else
    echo "（跳过实际操作）"
fi
echo ""

# -----------------------------------------------------------
# 九、PPA 添加与管理
# -----------------------------------------------------------
echo "--- 9. PPA（Personal Package Archive）---"
echo "PPA 是 Ubuntu 提供的第三方包托管平台（类似 GitHub 之于代码）。"
echo ""
echo "添加 PPA："
echo "  sudo add-apt-repository ppa:作者/仓库名"
echo "  sudo apt update                        # 添加后必须刷新索引"
echo ""
echo "常见 PPA 示例："
echo "  sudo add-apt-repository ppa:deadsnakes/ppa  # 安装新版 Python"
echo "  sudo add-apt-repository ppa:ondrej/php      # 安装新版 PHP"
echo "  sudo add-apt-repository ppa:git-core/ppa    # 安装新版 Git"
echo ""
echo "查看已添加的 PPA："
echo "  ls /etc/apt/sources.list.d/"
echo "  cat /etc/apt/sources.list.d/*.list"
echo ""
echo "删除 PPA："
echo "  sudo add-apt-repository --remove ppa:作者/仓库名"
echo "  # 或者直接删除 sources.list.d 下的对应文件"
echo ""
echo "注意：PPA 是第三方维护的，安全性没有官方保证。"
echo "在服务器上使用 PPA 前请评估风险。"
echo ""

# -----------------------------------------------------------
# 十、apt clean 与缓存管理
# -----------------------------------------------------------
echo "--- 10. apt 缓存管理 ---"
echo "apt 下载的 .deb 包会缓存在 /var/cache/apt/archives/"
echo "时间长了可能会占几 GB 的空间。"
echo ""
echo "  apt clean          # 清空所有缓存的 .deb 包"
echo "  apt autoclean      # 只删除旧版本/无用的缓存包（保留最新版）"
echo "  du -sh /var/cache/apt/archives/  # 查看缓存占用了多少空间"
echo ""

if [ -d /var/cache/apt/archives ]; then
    echo "当前缓存大小："
    du -sh /var/cache/apt/archives/ 2>/dev/null || echo "  无法读取。"
fi
echo ""

# -----------------------------------------------------------
# 十一、apt 故障排查
# -----------------------------------------------------------
echo "--- 11. 常见故障排查 ---"
echo ""
echo "问题1：dpkg 被中断（强制关机/网络中断）"
echo "  解决："
echo "    sudo dpkg --configure -a"
echo "    sudo apt install -f"
echo ""
echo "问题2：锁文件被占用（另一个 apt 进程在运行）"
echo "  错误信息：Could not get lock /var/lib/dpkg/lock"
echo "  解决："
echo "    ps aux | grep apt      # 找到正在运行的 apt 进程"
echo "    sudo kill PID          # 或等它自己完成"
echo "    # 如果确定没有 apt 在运行，可强制删锁文件（危险操作！）"
echo "    sudo rm /var/lib/dpkg/lock-frontend"
echo "    sudo rm /var/lib/dpkg/lock"
echo "    sudo dpkg --configure -a"
echo ""
echo "问题3：GPG 密钥过期或缺失"
echo "  错误信息：NO_PUBKEY ABCDEF1234567890"
echo "  解决："
echo "    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABCDEF1234567890"
echo ""

echo "============================================"
echo "  示例脚本执行完毕"
echo "============================================"
