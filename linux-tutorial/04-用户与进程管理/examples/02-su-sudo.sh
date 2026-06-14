#!/bin/bash
# ============================================================
# 02-su-sudo.sh - 切换身份示例脚本
# 配套章节：04-02-切换身份.md
#
# 注意：本脚本仅做命令演示和说明，不会实际执行 su/sudo 操作。
# su 和 sudo 需要交互式环境，不适合在脚本中自动执行。
# 请在终端中手动练习这些命令。
# ============================================================

echo "============================================"
echo "  04-02 切换身份 -- su 与 sudo"
echo "============================================"
echo ""

# -----------------------------------------------------------
# 一、理解当前身份
# -----------------------------------------------------------
echo "--- 1. 当前身份信息 ---"
echo "当前用户: $(whoami)"
echo "UID: $(id -u)"
echo "所属组: $(groups)"
echo ""
echo "当前是否为 root？"
if [ "$(id -u)" -eq 0 ]; then
    echo "  是，你正在以 root 身份运行本脚本。"
else
    echo "  否，你是普通用户。执行特权操作需要 sudo。"
fi
echo ""

# -----------------------------------------------------------
# 二、sudo 配置检查
# -----------------------------------------------------------
echo "--- 2. sudo 配置检查 ---"
echo "检查当前用户是否在 sudo/wheel 组中："
if groups | grep -qw "sudo\|wheel"; then
    echo "  当前用户拥有 sudo 权限。"
else
    echo "  当前用户可能没有 sudo 权限。"
    echo "  管理员可以用以下命令授权："
    echo "    sudo usermod -aG sudo $(whoami)   # Debian/Ubuntu"
    echo "    sudo usermod -aG wheel $(whoami)  # CentOS/RHEL"
fi
echo ""

# -----------------------------------------------------------
# 三、sudoers 文件说明
# -----------------------------------------------------------
echo "--- 3. sudoers 配置文件 ---"
echo "sudoers 文件控制谁可以用 sudo、可以用哪些命令。"
echo "位置：/etc/sudoers"
echo "编辑工具：sudo visudo  （不要直接用 vim 编辑！）"
echo ""
echo "sudoers 常见配置行："
echo "  root    ALL=(ALL:ALL) ALL    -- root 可以在任何主机以任何用户身份执行任何命令"
echo "  %sudo   ALL=(ALL:ALL) ALL    -- sudo 组的所有成员拥有完整权限"
echo "  %wheel  ALL=(ALL:ALL) ALL    -- wheel 组同上（CentOS/RHEL）"
echo ""
echo "格式解读： 谁  在哪台机器=(以谁的身份:以哪个组的身份) 能执行什么命令"
echo ""

# -----------------------------------------------------------
# 四、常用 su/sudo 命令说明
# -----------------------------------------------------------
echo "--- 4. su 与 sudo 常用命令速查 ---"
echo ""
echo "命令                          | 含义"
echo "-----------------------------|----------------------------------"
echo "su -                          | 切换到 root，并加载 root 的环境变量"
echo "su - username                 | 切换到指定用户，并加载其环境变量"
echo "su username                   | 切换到指定用户，但保留当前环境变量"
echo "sudo command                  | 以 root 权限执行单条命令"
echo "sudo -i                       | 以 root 身份开启一个新的登录 Shell"
echo "sudo -s                       | 以 root 身份开启一个 Shell（不加载登录环境）"
echo "sudo -u username command      | 以指定用户的身份执行命令"
echo "sudo -l                       | 查看当前用户有哪些 sudo 权限"
echo "sudo !!                       | 以 sudo 重新执行上一条命令（超实用！）"
echo ""

# -----------------------------------------------------------
# 五、演示：检查环境变量差异
# -----------------------------------------------------------
echo "--- 5. su 与 su - 的环境变量差异 ---"
echo "注意下面两个操作的环境变量差异："
echo ""
echo "  su username"
echo "    -> 保留当前用户的环境变量（HOME 还是 /home/原用户）"
echo "    -> 就像你借了同事的工牌，但还是坐自己的工位"
echo ""
echo "  su - username"
echo "    -> 完全加载目标用户的环境变量（HOME 变成 /home/目标用户）"
echo "    -> 就像你完全坐到同事的工位上，用他的电脑、他的配置"
echo ""
echo "当前用户的 HOME 目录：$HOME"
echo "当前 PATH："
echo "$PATH" | tr ':' '\n' | head -5
echo ""

# -----------------------------------------------------------
# 六、visudo 安全编辑说明
# -----------------------------------------------------------
echo "--- 6. visudo 安全编辑机制 ---"
echo "为什么必须用 visudo 而不是直接 vim /etc/sudoers？"
echo ""
echo "1. 语法检查：visudo 在保存时会检查语法。如果写错了，"
echo "   它会提示你重新编辑，而不是保存一个有语法错误的文件。"
echo "   一旦 sudoers 文件有语法错误，整个 sudo 系统可能瘫痪，"
echo "   root 是唯一还能用的救火渠道。"
echo ""
echo "2. 文件锁：visudo 使用了文件锁机制，防止两个人同时编辑"
echo "   sudoers 导致修改互相覆盖。"
echo ""
echo "使用方式："
echo "  sudo visudo              # 编辑主配置文件"
echo "  sudo visudo -f /etc/sudoers.d/myconf  # 编辑插件配置文件"
echo ""
echo "推荐做法：不要直接改 /etc/sudoers，而是在 /etc/sudoers.d/"
echo "目录下创建单独的文件。系统会自动加载该目录下所有文件。"
echo ""

# -----------------------------------------------------------
# 七、实用技巧
# -----------------------------------------------------------
echo "--- 7. sudo 实用技巧 ---"
echo ""

echo "技巧1 - 免密码 sudo（仅限信任的机器，生产环境慎用）："
echo "  sudo visudo"
echo "  添加：yourname ALL=(ALL:ALL) NOPASSWD: ALL"
echo ""

echo "技巧2 - 限制某个用户只能执行特定命令："
echo "  sudo visudo"
echo "  添加：restartuser ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx"
echo "  这样 restartuser 只能重启 nginx，不能做别的。"
echo ""

echo "技巧3 - 查看 sudo 使用记录："
echo "  sudo journalctl -u sudo"
echo "  或查看 /var/log/auth.log (Ubuntu) / /var/log/secure (CentOS)"
echo ""

echo "技巧4 - sudo 执行一连串命令："
echo "  sudo bash -c 'cd /root && ls -la && cat secret.txt'"
echo "  而不是：sudo cd /root && ls ...  （sudo cd 是无效的，cd 是 Shell 内建命令）"
echo ""

echo "============================================"
echo "  示例脚本执行完毕"
echo "  请在终端中实际练习 su 和 sudo 命令！"
echo "============================================"
