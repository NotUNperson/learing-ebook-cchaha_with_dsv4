#!/bin/bash
# ========================================
# 05-ssh-config.sh — SSH 配置文件演示
# ========================================
# 功能：演示 ~/.ssh/config 文件的创建和配置，
#        包括 Host 别名、跳板机 ProxyJump、
#        常用配置项的说明
# 用法：./05-ssh-config.sh
# 注意：本脚本创建的是演示配置，不会覆盖已有文件
# ========================================

echo "==========================================="
echo "  SSH 配置文件 ~/.ssh/config 演示"
echo "==========================================="
echo ""

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"
DEMO_CONFIG="/tmp/ssh_config_demo_$$.txt"

# --------------------------------------------------
# 一、配置文件的作用
# --------------------------------------------------
echo "--- 1. 为什么需要 SSH 配置文件？---"
echo ""

cat << 'EOF'
不写配置文件时的痛苦：

  ssh -p 2222 -i ~/.ssh/id_ed25519_prod deploy@10.0.0.50
  scp -P 2222 -i ~/.ssh/id_ed25519_prod file.txt deploy@10.0.0.50:/tmp/
  rsync -avz -e "ssh -p 2222 -i ~/.ssh/id_ed25519_prod" ./dir/ deploy@10.0.0.50:/dir/

每次都要记住：
  - 端口是 2222
  - 密钥是 ~/.ssh/id_ed25519_prod
  - 用户名是 deploy
  - IP 是 10.0.0.50

写了配置文件之后：

  ssh prod-server          # 就这一句！
  scp file.txt prod-server:/tmp/
  rsync -avz ./dir/ prod-server:/dir/
  sftp prod-server

SSH 配置文件就像电话通讯录：
  你不需要记住每个人的号码，存一个名字就行。
EOF

echo ""

# --------------------------------------------------
# 二、配置文件基本结构
# --------------------------------------------------
echo "--- 2. 配置文件的基本结构 ---"
echo ""

cat << 'EOF'
~/.ssh/config 文件结构：

  Host <别名>
      <配置项1>  <值>
      <配置项2>  <值>

  - Host 定义了一个"配置块"的起点
  - 下面的配置项要缩进（约定俗成用 2 或 4 个空格）
  - 空行分隔不同的 Host 块
  - 第一个匹配的配置生效（从上到下）

通配符模式：
  Host *.example.com    匹配所有 .example.com 域名
  Host 10.0.*           匹配所有 10.0.x.x IP
  Host *                匹配所有（通常放在文件末尾做全局默认值）
EOF

echo ""

# --------------------------------------------------
# 三、完整示例配置
# --------------------------------------------------
echo "--- 3. 完整示例配置 ---"
echo ""

cat > "$DEMO_CONFIG" << 'ENDCONFIG'
# ==========================================
# SSH 配置文件示例
# 位置：~/.ssh/config
# 权限：chmod 600 ~/.ssh/config
# ==========================================

# ---------- 生产服务器 ----------
Host prod-web
    HostName 10.0.0.50
    User deploy
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_prod
    # 连接超时时间（秒）
    ConnectTimeout 10
    # 保持连接活跃（防断开）
    ServerAliveInterval 60

# ---------- 数据库服务器 ----------
Host prod-db
    HostName 10.0.0.51
    User dbadmin
    Port 22
    IdentityFile ~/.ssh/id_ed25519_prod

# ---------- 通过跳板机连接内网机器 ----------
Host internal-*
    # 所有 internal- 开头的机器都通过跳板机连接
    ProxyJump bastion@gateway.example.com
    User admin
    IdentityFile ~/.ssh/id_ed25519_internal

Host internal-web
    HostName 172.16.0.10

Host internal-api
    HostName 172.16.0.11

# ---------- GitHub ----------
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    # 只用密钥认证，不尝试密码
    PreferredAuthentications publickey

# ---------- 云服务器（匹配多个）----------
Host *.compute.amazonaws.com
    User ec2-user
    IdentityFile ~/.ssh/aws_key.pem
    StrictHostKeyChecking accept-new

# ---------- 全局默认值（* 匹配所有）----------
Host *
    # 连接超时 10 秒
    ConnectTimeout 10
    # 每 120 秒发送心跳包
    ServerAliveInterval 120
    # 最多发送多少次心跳无响应才断开
    ServerAliveCountMax 3
    # 压缩传输（慢速网络开启）
    # Compression yes
    # 转发 SSH Agent（谨慎开启）
    # ForwardAgent no
    # 禁用密码认证（只尝试密钥）
    PreferredAuthentications publickey,password
ENDCONFIG

cat "$DEMO_CONFIG"

echo ""
echo "（以上配置已写入 $DEMO_CONFIG 供参考）"
echo ""

# --------------------------------------------------
# 四、常用配置项详解
# --------------------------------------------------
echo "--- 4. 常用配置项详解 ---"
echo ""

cat << 'EOF'
Host ALIAS
  定义连接别名。之后用 ssh ALIAS 即可连接。
  支持通配符 * ? 等。

HostName HOST
  实际的服务器地址（IP 或域名）。
  如果不写 HostName，SSH 会直接用 Host 的值当作地址。

User USERNAME
  登录用户名。等效于 ssh USERNAME@HOST。

Port PORT
  SSH 端口号。默认是 22。
  等效于 ssh -p PORT。

IdentityFile PATH
  指定私钥文件的路径。
  等效于 ssh -i PATH。
  可以写多个（SSH 会依次尝试）。

ProxyJump USER@HOST
  跳板机（堡垒机）。通过一台中间的服务器跳转到最终目标。
  等效于 ssh -J USER@HOST。
  可以串联多个跳板机（用逗号分隔）。

ConnectTimeout SECONDS
  连接超时时间。超过这个时间连不上就放弃。

ServerAliveInterval SECONDS
  发送心跳包的间隔。连接空闲时保持活跃，防止被防火墙断开。

ServerAliveCountMax N
  连续 N 次收不到心跳响应就断开连接。

StrictHostKeyChecking VALUE
  yes       — 严格检查（首次连接必须手动确认）
  no        — 不检查（不安全！不推荐）
  accept-new— 接受新主机但不接受变更（推荐）

UserKnownHostsFile PATH
  指定 known_hosts 文件的位置。
  默认是 ~/.ssh/known_hosts。
  设为 /dev/null 表示不保存（测试环境用）。

PreferredAuthentications ORDER
  指定认证方式的尝试顺序。
  例如：publickey,password

Compression yes|no
  是否在传输时压缩数据。慢速网络（如 4G 热点）建议开启。

ForwardAgent yes|no
  是否把本地的 SSH Agent 转发给远程服务器。
  有安全风险（远程服务器可以冒充你连接其他服务器）。
  除非你清楚在做什么，否则设为 no。

LocalForward [bind_addr:]port host:hostport
  本地端口转发。把远程端口映射到本地。

RemoteForward [bind_addr:]port host:hostport
  远程端口转发。把本地端口映射到远程。
EOF

echo ""

# --------------------------------------------------
# 五、ProxyJump 跳板机详解
# --------------------------------------------------
echo "--- 5. ProxyJump 跳板机（堡垒机）---"
echo ""

cat << 'EOF'
什么是跳板机？
  很多公司的服务器不直接暴露在公网上，只开放一台"跳板机"（也叫
  堡垒机、Bastion Host）给外部访问。你先 SSH 到跳板机，再从跳板机
  SSH 到内网的真正目标服务器。

没有 ProxyJump 时的手动做法：

  # 先跳到跳板机，再跳到目标
  ssh -t bastion@gateway.com "ssh admin@10.0.1.50"

  # 或者建立隧道
  ssh -L 2222:10.0.1.50:22 bastion@gateway.com
  # 在另一个终端：
  ssh -p 2222 admin@localhost

有 ProxyJump 之后：

  ssh -J bastion@gateway.com admin@10.0.1.50

  在 ~/.ssh/config 中配置后更简单：

  Host internal-web
      HostName 10.0.1.50
      User admin
      ProxyJump bastion@gateway.com

  ssh internal-web    # 直接连！SSH 自动处理跳板

多层跳板（串联）：

  Host final-server
      HostName 10.0.2.100
      User admin
      ProxyJump bastion1@gate1.com,bastion2@gate2.com

类比：
  跳板机就像是公寓大楼的门禁。你首先要通过大门（跳板机），
  然后才能走到具体的房间门口（内网服务器）。
  ProxyJump 就是让 SSH 自动帮你完成"先过大门，再进房间"的过程。
EOF

echo ""

# --------------------------------------------------
# 六、配置文件的优先级
# --------------------------------------------------
echo "--- 6. 配置优先级 ---"
echo ""

cat << 'EOF'
SSH 可以从多个地方读取配置，优先级从高到低：

  1. 命令行选项（如 ssh -p 2222）
     → 最高优先级，覆盖一切

  2. ~/.ssh/config 文件（用户的个人配置）
     → 常用方式，按 Host 块从上到下匹配

  3. /etc/ssh/ssh_config（系统级配置）
     → 对所有用户生效

同一个 Host 块内的配置项也是第一个匹配生效。
所以把更具体的 Host 放上面，通配符放下面。

示例：

  Host myserver           # 具体配置放前面
      Port 2222
      User admin

  Host *.example.com      # 通配符放中间
      User webmaster

  Host *                  # 全局默认放最后
      Port 22
      ServerAliveInterval 60
EOF

echo ""

# --------------------------------------------------
# 七、检查配置
# --------------------------------------------------
echo "--- 7. 检查现有配置 ---"
echo ""

if [ -f "$CONFIG_FILE" ]; then
    echo "现有 SSH 配置文件：$CONFIG_FILE"
    echo "文件权限：$(stat -c '%a' "$CONFIG_FILE" 2>/dev/null || stat -f '%Lp' "$CONFIG_FILE" 2>/dev/null)"
    echo ""
    echo "当前配置中定义的 Host："
    grep -E '^Host ' "$CONFIG_FILE" | head -20
    echo ""
    echo "配置内容（前 30 行）："
    head -30 "$CONFIG_FILE"
else
    echo "尚未创建 ~/.ssh/config 文件"
    echo ""
    echo "创建示例："
    echo ""
    echo "  cat > ~/.ssh/config << 'EOF'"
    echo "  Host myserver"
    echo "      HostName 192.168.1.100"
    echo "      User admin"
    echo "      Port 22"
    echo "  EOF"
    echo ""
    echo "  chmod 600 ~/.ssh/config"
fi

echo ""

# --------------------------------------------------
# 八、测试配置
# --------------------------------------------------
cat << 'EOF'
--- 8. 测试配置是否生效 ---

测试方法：

  # 查看 SSH 对某个 Host 使用的完整配置
  ssh -G myserver

  # 只查看某个具体配置项的值
  ssh -G myserver | grep -i port
  ssh -G myserver | grep -i hostname
  ssh -G myserver | grep -i identityfile

  # 用 -v 查看实际连接时使用的配置
  ssh -v myserver

  # 配置语法检查（非官方方法，但有效）
  # 连接一个故意错误的 Host，看 SSH 是否报配置错误
  ssh -G "nosuchhost" 2>&1 | head -5

权限设置提醒：
  chmod 600 ~/.ssh/config
  如果权限太宽松，SSH 会忽略这个配置文件
EOF

echo ""

# --------------------------------------------------
# 九、创建演示配置文件
# --------------------------------------------------
echo "--- 9. 快速创建你的第一个 SSH 配置 ---"
echo ""

cat << 'EOF'
如果你现在还没有 ~/.ssh/config，可以这样创建：

cat > ~/.ssh/config << 'ENDCONF'
# 我的第一个 SSH 配置
Host myserver
    HostName 你的服务器IP
    User 你的用户名
    Port 22

Host *
    ServerAliveInterval 60
    ConnectTimeout 10
ENDCONF

chmod 600 ~/.ssh/config

然后把 "你的服务器IP" 和 "你的用户名" 替换成实际的值，
就可以用 ssh myserver 直接连接了！
EOF

# 清理演示文件
rm -f "$DEMO_CONFIG"

echo ""
echo "==========================================="
echo "  动手练习建议"
echo "==========================================="
echo ""
echo "  1. 创建 ~/.ssh/config 文件（如已有则检查内容）"
echo "  2. 为你的远程服务器添加一个 Host 别名"
echo "  3. 用 ssh -G 别名 查看 SSH 对这个 Host 使用的完整配置"
echo "  4. 通过别名 SSH 连接，验证配置生效"
echo "  5. 测试 SCP/SFTP 是否也会自动读取配置（会的）"
echo "  6. 添加 Host * 全局配置段，设置心跳间隔"
echo "  7. （如有条件）配置跳板机 ProxyJump"
