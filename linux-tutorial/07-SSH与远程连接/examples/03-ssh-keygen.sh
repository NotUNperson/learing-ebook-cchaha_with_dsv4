#!/bin/bash
# ========================================
# 03-ssh-keygen.sh — SSH 密钥认证演示
# ========================================
# 功能：演示 ssh-keygen 生成密钥对、
#       ssh-copy-id 上传公钥、
#       文件权限检查、禁用密码登录说明
# 用法：./03-ssh-keygen.sh
# 注意：本脚本仅演示本地操作，不会实际连接远程服务器
# ========================================

echo "==========================================="
echo "  SSH 密钥认证完整演示"
echo "==========================================="
echo ""

SSH_DIR="$HOME/.ssh"

# --------------------------------------------------
# 一、了解密钥类型
# --------------------------------------------------
echo "--- 1. SSH 密钥类型选择 ---"
echo ""

cat << 'EOF'
常见的密钥类型：

  Ed25519（推荐！）
    - 最现代、最安全、速度最快
    - 密钥短，使用方便
    - 支持的操作系统和 SSH 版本最广泛（OpenSSH 6.5+）
    生成命令：ssh-keygen -t ed25519

  RSA（兼容性最好）
    - 经典算法，几乎所有系统都支持
    - 推荐至少 3072 位（-b 3072），最好 4096 位
    - 密钥文件较大
    生成命令：ssh-keygen -t rsa -b 4096

  ECDSA（中间方案）
    - 比 RSA 快，比 Ed25519 兼容性好
    - 安全性依赖于随机数生成器
    生成命令：ssh-keygen -t ecdsa -b 521

  DSA（不推荐）
    - 已被 OpenSSH 废弃（安全性不足）

密钥文件：
  ~/.ssh/id_ed25519      → 私钥（保密！像银行卡密码）
  ~/.ssh/id_ed25519.pub  → 公钥（可公开，像银行卡号）

带有 .pub 后缀的是公钥。
不带 .pub 的是私钥，要严格保护。
EOF

echo ""

# --------------------------------------------------
# 二、检查已有的密钥
# --------------------------------------------------
echo "--- 2. 检查已有的 SSH 密钥 ---"
echo ""

if [ -d "$SSH_DIR" ]; then
    echo "~/.ssh 目录内容："
    ls -la "$SSH_DIR/"
    echo ""

    # 找出已有的私钥文件
    existing_keys=$(find "$SSH_DIR" -maxdepth 1 \( -name "id_*" ! -name "*.pub" \) 2>/dev/null)
    if [ -n "$existing_keys" ]; then
        echo "已存在的私钥："
        for key in $existing_keys; do
            key_type=$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $4, $2, $1}')
            echo "  $(basename "$key") — $key_type"
        done
    else
        echo "尚未生成过 SSH 密钥对"
    fi
else
    echo "~/.ssh 目录不存在（尚未使用过 SSH 相关功能）"
fi

echo ""

# --------------------------------------------------
# 三、生成密钥的演示（只显示命令，不实际生成）
# --------------------------------------------------
echo "--- 3. 密钥生成命令演示 ---"
echo ""

cat << 'EOF'
生成 Ed25519 密钥对（推荐）：

  ssh-keygen -t ed25519 -C "your_email@example.com"

  参数说明：
    -t ed25519  指定密钥类型
    -C "comment" 添加注释（通常用邮箱，方便识别）
    -f PATH     指定保存路径（可选，默认在 ~/.ssh/）

执行后你会看到：
  1. Enter file in which to save the key (~/.ssh/id_ed25519):
     → 直接回车使用默认路径，或输入自定义路径

  2. Enter passphrase (empty for no passphrase):
     → 输入一个"口令"来保护你的私钥（强烈建议！）
     → 类比：手机锁屏密码。即使手机丢了，别人打不开

  3. Enter same passphrase again:
     → 再次确认口令

生成 RSA 4096 位密钥对（兼容性优先）：

  ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

指定文件名（管理多组密钥）：

  ssh-keygen -t ed25519 -f ~/.ssh/github_key -C "github"
  ssh-keygen -t ed25519 -f ~/.ssh/server_key -C "production"
EOF

echo ""

# --------------------------------------------------
# 四、passphrase 解释
# --------------------------------------------------
echo "--- 4. 关于 passphrase（密钥保护口令）---"
echo ""

cat << 'EOF'
类比：银行保险箱有两层保护
  1. 保险箱本身（你的私钥文件）
  2. 保险箱的密码锁（passphrase）

即使有人偷走了你的私钥文件（比如 U 盘丢了），没有
passphrase 也无法使用它。

但每次都输入 passphrase 很麻烦，可以用 ssh-agent 解决：
  ssh-add ~/.ssh/id_ed25519
  输入一次 passphrase 后，当前会话内不再需要输入。

如果实在不想设置 passphrase（仅限测试环境），直接回车留空。
生产环境强烈建议设置 passphrase！

查看密钥的 fingerprint：
  ssh-keygen -lf ~/.ssh/id_ed25519.pub

查看密钥的随机艺术图像（视觉化指纹）：
  ssh-keygen -lvf ~/.ssh/id_ed25519.pub

修改已有密钥的 passphrase：
  ssh-keygen -p -f ~/.ssh/id_ed25519
EOF

echo ""

# --------------------------------------------------
# 五、上传公钥到远程服务器
# --------------------------------------------------
echo "--- 5. 上传公钥（ssh-copy-id）---"
echo ""

cat << 'EOF'
方法一：ssh-copy-id（最方便）

  ssh-copy-id user@remote_host
  ssh-copy-id -i ~/.ssh/id_ed25519.pub user@remote_host

  执行后：
    1. 输入一次远程用户的密码
    2. 公钥自动追加到远程的 ~/.ssh/authorized_keys
    3. 之后就可以免密码登录了！

方法二：手动上传（适合没有 ssh-copy-id 的情况）

  # 第一步：在远程服务器上创建 .ssh 目录
  ssh user@remote_host "mkdir -p ~/.ssh && chmod 700 ~/.ssh"

  # 第二步：把本地公钥追加到远程的 authorized_keys
  cat ~/.ssh/id_ed25519.pub | ssh user@remote_host "cat >> ~/.ssh/authorized_keys"

  # 第三步：设置正确的权限（非常重要！）
  ssh user@remote_host "chmod 600 ~/.ssh/authorized_keys"

权限要求（缺一不可）：
  ~/.ssh/                  → 700（只有自己可以进入）
  ~/.ssh/authorized_keys   → 600（只有自己能读写）
  ~/.ssh/id_*（私钥）      → 600（只有自己能读写）

  如果权限太宽松，SSH 会拒绝工作！

方法三：scp 拷贝（后面详细讲）

  scp ~/.ssh/id_ed25519.pub user@host:~/
  ssh user@host "mkdir -p ~/.ssh && cat ~/id_ed25519.pub >> ~/.ssh/authorized_keys && rm ~/id_ed25519.pub"
EOF

echo ""

# --------------------------------------------------
# 六、.ssh 目录权限检查
# --------------------------------------------------
echo "--- 6. 检查本地 .ssh 目录权限 ---"
echo ""

if [ -d "$SSH_DIR" ]; then
    dir_perm=$(stat -c "%a" "$SSH_DIR" 2>/dev/null || stat -f "%Lp" "$SSH_DIR" 2>/dev/null)
    echo "~/.ssh 目录权限：$dir_perm (应为 700)"

    # 查找私钥文件并检查权限
    find "$SSH_DIR" -maxdepth 1 \( -name "id_*" ! -name "*.pub" \) 2>/dev/null | while read -r keyfile; do
        key_perm=$(stat -c "%a" "$keyfile" 2>/dev/null || stat -f "%Lp" "$keyfile" 2>/dev/null)
        echo "  $(basename "$keyfile") 权限：$key_perm (应为 600)"
    done

    # 检查 authorized_keys（如果存在）
    if [ -f "$SSH_DIR/authorized_keys" ]; then
        auth_perm=$(stat -c "%a" "$SSH_DIR/authorized_keys" 2>/dev/null || stat -f "%Lp" "$SSH_DIR/authorized_keys" 2>/dev/null)
        echo "  authorized_keys 权限：$auth_perm (应为 600)"
        echo "  authorized_keys 中公钥数量：$(wc -l < "$SSH_DIR/authorized_keys")"
    fi
else
    echo "  ~/.ssh 目录不存在"
fi

echo ""

# --------------------------------------------------
# 七、禁用密码登录（服务端配置）
# --------------------------------------------------
echo "--- 7. 安全加固：禁用密码登录 ---"
echo ""

cat << 'EOF'
⚠ 重要提醒：
  在禁用密码登录之前，务必先确认密钥登录已经成功！
  否则你会被锁在服务器外面，可能需要物理接触才能恢复。

编辑 /etc/ssh/sshd_config（需要 root 权限）：

  sudo vim /etc/ssh/sshd_config

修改以下配置项：

  # 禁用密码登录
  PasswordAuthentication no

  # 禁用 root 直接登录（可选，但强烈推荐）
  PermitRootLogin no

  # 禁用空密码
  PermitEmptyPasswords no

  # 最大认证尝试次数（防止暴力破解）
  MaxAuthTries 3

  # 只允许密钥认证
  PubkeyAuthentication yes
  AuthenticationMethods publickey

保存后检查配置语法：
  sudo sshd -t

如果显示 "Syntax OK"，重新加载配置：
  sudo systemctl reload sshd

门禁卡 vs 密码锁 的类比：
  密码登录 = 输入一串数字开门
    - 问题：密码可能被偷看、猜到、暴力破解
    - 问题：密码可能被键盘记录器抓取

  密钥认证 = 携带门禁卡
    - 优势：物理密钥（门禁卡）无法被远程猜到
    - 优势：即使有人看到你"刷卡"，也无法复制
    - 优势：可以随时吊销某张卡（从 authorized_keys 删除）
EOF

echo ""

# --------------------------------------------------
# 八、多密钥管理
# --------------------------------------------------
echo "--- 8. 多密钥管理策略 ---"
echo ""

cat << 'EOF'
为什么需要多组密钥？
  - GitHub 一组密钥
  - 公司生产服务器一组密钥
  - 个人云服务器一组密钥
  - 每台设备也有自己的密钥

好处：
  1. 某组密钥泄露不会影响其他服务
  2. 可以针对不同服务设置不同安全级别
  3. 离职时直接吊销公司相关的密钥

管理多密钥的方法：

  1. 生成时指定不同的文件名：
     ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "github"
     ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_work -C "work"

  2. 使用 SSH config 文件指定哪个主机用哪个密钥：
     在 ~/.ssh/config 中配置（第5节会详细讲）

  3. 使用 ssh-agent 管理 passphrase：
     eval $(ssh-agent)
     ssh-add ~/.ssh/id_ed25519_github
     ssh-add ~/.ssh/id_ed25519_work
EOF

echo ""
echo "==========================================="
echo "  动手练习建议"
echo "==========================================="
echo ""
echo "  1. 生成一组 Ed25519 密钥对（带 passphrase）"
echo "  2. 查看公钥内容：cat ~/.ssh/id_ed25519.pub"
echo "  3. 查看密钥指纹：ssh-keygen -lf ~/.ssh/id_ed25519.pub"
echo "  4. 检查 .ssh 目录和文件的权限"
echo "  5. 如果有远程服务器，用 ssh-copy-id 上传公钥"
echo "  6. 验证免密登录：ssh user@host（应该不再提示密码）"
echo "  7. 用 ssh-keygen -p 修改已有密钥的 passphrase"
