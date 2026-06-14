#!/bin/bash
# ============================================================
# 01-user-group.sh - 用户与组管理示例脚本
# 配套章节：04-01-用户与组管理.md
#
# 注意：本脚本中的大部分命令需要 root 权限。
# 请使用 sudo ./01-user-group.sh 或切换到 root 用户执行。
# 部分命令（如查看文件内容）不需要 root 权限。
# ============================================================

set -e  # 遇到错误立即退出

echo "============================================"
echo "  04-01 用户与组管理 示例"
echo "============================================"
echo ""

# -----------------------------------------------------------
# 一、查看用户信息文件 /etc/passwd
# -----------------------------------------------------------
echo "--- 1. 查看 /etc/passwd 的结构 ---"
echo "该文件每行代表一个用户，格式为："
echo "用户名:密码占位符:UID:GID:描述:家目录:登录Shell"
echo ""
echo "查看当前用户的信息："
grep "^$(whoami):" /etc/passwd
echo ""

echo "查看系统内置用户（UID < 1000 的是系统用户）："
awk -F: '$3 < 1000 && $3 > 0 {print $1, "(UID:"$3")"}' /etc/passwd | head -10
echo ""

echo "查看所有普通用户（UID >= 1000）："
awk -F: '$3 >= 1000 {print $1, "(UID:"$3", 家目录:"$6", Shell:"$7")"}' /etc/passwd
echo ""

# -----------------------------------------------------------
# 二、查看影子密码文件 /etc/shadow
# -----------------------------------------------------------
echo "--- 2. 查看 /etc/shadow 的结构 ---"
echo "该文件存储加密后的密码，每行格式为："
echo "用户名:加密密码:上次修改天数:最小修改间隔:最大有效期:警告天数:宽限天数:过期天数:保留"
echo ""
echo "查看当前用户的影子条目（需要 root 权限）："
if [ "$(id -u)" -eq 0 ]; then
    grep "^$(whoami):" /etc/shadow | cut -d: -f1
    echo "（密码字段已隐藏，只显示用户名）"
else
    echo "（需要 root 权限才能查看 /etc/shadow）"
fi
echo ""

# -----------------------------------------------------------
# 三、查看组信息文件 /etc/group
# -----------------------------------------------------------
echo "--- 3. 查看 /etc/group 的结构 ---"
echo "该文件每行格式为：组名:密码占位符:GID:组成员列表"
echo ""
echo "查看当前用户所属的组："
groups
echo ""

echo "查看 wheel/sudo 组（管理员组）的成员："
grep -E "^(wheel|sudo):" /etc/group 2>/dev/null || echo "（未找到 wheel 或 sudo 组）"
echo ""

# -----------------------------------------------------------
# 四、创建新用户 useradd
# -----------------------------------------------------------
echo "--- 4. useradd 命令演示 ---"

# 创建一个测试用户（请确保用 root 运行）
TEST_USER="linuxstudent"
echo "准备创建测试用户: $TEST_USER"

if [ "$(id -u)" -eq 0 ]; then
    # 检查用户是否已存在
    if id "$TEST_USER" &>/dev/null; then
        echo "用户 $TEST_USER 已存在，跳过创建步骤。"
    else
        # 创建用户（同时创建家目录、指定 bash 为登录 shell）
        useradd -m -s /bin/bash "$TEST_USER"
        echo "用户 $TEST_USER 创建成功。"

        # 设置密码（交互式，这里用 chpasswd 做非交互示例）
        echo "${TEST_USER}:LearnLinux123" | chpasswd
        echo "密码已设置。"

        # 查看新用户在 /etc/passwd 中的条目
        echo "新用户在 /etc/passwd 中的条目："
        grep "^${TEST_USER}:" /etc/passwd
    fi
else
    echo "（需要 root 权限才能创建用户，跳过此步骤）"
    echo "你可以用以下命令手动尝试："
    echo "  sudo useradd -m -s /bin/bash $TEST_USER"
    echo "  sudo passwd $TEST_USER"
fi
echo ""

# -----------------------------------------------------------
# 五、修改用户属性 usermod
# -----------------------------------------------------------
echo "--- 5. usermod 命令演示 ---"

if [ "$(id -u)" -eq 0 ]; then
    if id "$TEST_USER" &>/dev/null; then
        # 给用户添加备注（全名）
        usermod -c "Linux学习者" "$TEST_USER"
        echo "已为用户 $TEST_USER 添加备注信息。"

        # 将用户加入额外组（wheel 或 sudo 组）
        if getent group wheel &>/dev/null; then
            usermod -aG wheel "$TEST_USER"
            echo "已将 $TEST_USER 加入 wheel 组（管理员组）。"
        elif getent group sudo &>/dev/null; then
            usermod -aG sudo "$TEST_USER"
            echo "已将 $TEST_USER 加入 sudo 组（管理员组）。"
        fi

        # 查看用户当前的组信息
        echo "用户 $TEST_USER 当前所属组："
        groups "$TEST_USER"

        # 锁定用户
        echo ""
        echo "演示锁定用户："
        usermod -L "$TEST_USER"
        echo "用户 $TEST_USER 已锁定（-L 参数在加密密码前添加 ! 前缀）"
        grep "^${TEST_USER}:" /etc/shadow | cut -d: -f1-2

        # 解锁用户
        usermod -U "$TEST_USER"
        echo "用户 $TEST_USER 已解锁。"
    fi
else
    echo "（需要 root 权限才能修改用户，跳过此步骤）"
    echo "你可以用以下命令手动尝试："
    echo "  sudo usermod -aG wheel $TEST_USER"
fi
echo ""

# -----------------------------------------------------------
# 六、删除用户 userdel
# -----------------------------------------------------------
echo "--- 6. userdel 命令演示 ---"
echo "userdel 删除用户，-r 参数同时删除家目录和邮件池。"
echo ""
echo "删除测试用户（保留此注释，实际使用时去掉下面的注释）："
echo "  sudo userdel -r $TEST_USER"
echo ""
echo "本脚本保留测试用户以便后续章节使用。"
echo ""

# -----------------------------------------------------------
# 七、组管理 groupadd / groupdel / groupmod
# -----------------------------------------------------------
echo "--- 7. groupadd 命令演示 ---"

if [ "$(id -u)" -eq 0 ]; then
    TEST_GROUP="linuxstudy"

    if getent group "$TEST_GROUP" &>/dev/null; then
        echo "组 $TEST_GROUP 已存在。"
    else
        groupadd "$TEST_GROUP"
        echo "组 $TEST_GROUP 创建成功。"
    fi

    # 将当前用户加入测试组
    usermod -aG "$TEST_GROUP" "$(whoami)" 2>/dev/null || true
    echo "当前用户所属组：$(groups)"
    echo ""
    echo "查看组信息："
    grep "^${TEST_GROUP}:" /etc/group

    # 删除测试组
    echo ""
    echo "删除测试组 $TEST_GROUP："
    groupdel "$TEST_GROUP" 2>/dev/null && echo "组 $TEST_GROUP 已删除。" || echo "组 $TEST_GROUP 删除失败（可能有用户将此组设为主组）。"
else
    echo "（需要 root 权限才能管理组，跳过此步骤）"
    echo "你可以用以下命令手动尝试："
    echo "  sudo groupadd mygroup"
    echo "  sudo groupdel mygroup"
fi
echo ""

# -----------------------------------------------------------
# 八、id 命令 - 查看用户身份
# -----------------------------------------------------------
echo "--- 8. id 命令 - 查看当前用户身份 ---"
echo "id 命令显示用户 UID、GID 和所属组："
id
echo ""
echo "详细说明："
echo "  uid: 用户ID"
echo "  gid: 主组ID"
echo "  groups: 所有所属组（含附加组）"
echo ""

# -----------------------------------------------------------
# 九、passwd 命令说明
# -----------------------------------------------------------
echo "--- 9. passwd 命令说明 ---"
echo "passwd 用于修改密码："
echo "  passwd           - 修改自己的密码"
echo "  sudo passwd user - 管理员修改指定用户的密码"
echo "  sudo passwd -l user - 锁定用户密码"
echo "  sudo passwd -u user - 解锁用户密码"
echo "  sudo passwd -e user - 强制用户下次登录时修改密码"
echo ""

echo "============================================"
echo "  示例脚本执行完毕"
echo "============================================"
