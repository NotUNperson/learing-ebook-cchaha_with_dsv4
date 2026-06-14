#!/bin/bash
# ========================================
# 02-ssh-usage.sh — SSH 基本使用演示
# ========================================
# 功能：演示 ssh 命令的基本用法、known_hosts、
#        首次连接指纹确认、远程执行命令
# 用法：./02-ssh-usage.sh [可选：远程主机名或IP]
# 注意：本脚本主要是教学演示，大部分命令不会实际执行
# ========================================

echo "==========================================="
echo "  SSH 基本使用演示"
echo "==========================================="
echo ""

# --------------------------------------------------
# 一、基本连接命令语法
# --------------------------------------------------
echo "--- 1. SSH 连接的基本语法 ---"
echo ""

cat << 'EOF'
最基础的 SSH 连接：

  ssh 用户名@远程主机

示例：
  ssh root@192.168.1.100
  ssh john@myserver.example.com
  ssh user@10.0.0.5

如果本地用户名与远程用户名相同，可以省略用户名：
  ssh 192.168.1.100

指定端口（默认是 22）：
  ssh -p 2222 user@host

使用指定密钥文件：
  ssh -i ~/.ssh/my_key user@host

详细调试模式（排查连接问题必用）：
  ssh -v user@host      # 一级详细
  ssh -vv user@host     # 二级详细
  ssh -vvv user@host    # 三级详细（最详细）
EOF

echo ""

# --------------------------------------------------
# 二、SSH 执行远程命令
# --------------------------------------------------
echo "--- 2. 在远程服务器上执行命令 ---"
echo ""

cat << 'EOF'
SSH 不只是登录，还可以直接在远程服务器上执行命令：

  # 在远程服务器上执行一条命令
  ssh user@host "ls -la /var/log"

  # 执行多条命令（用分号或 && 连接）
  ssh user@host "cd /var/www && git pull && systemctl restart app"

  # 执行本地脚本在远程服务器上（重定向）
  ssh user@host 'bash -s' < local_script.sh

  # 获取远程文件内容到本地变量
  remote_hostname=$(ssh user@host "hostname")
  echo "远程主机名：$remote_hostname"

  # 在远程服务器上执行需要 sudo 的命令（需要 -t）
  ssh -t user@host "sudo systemctl restart nginx"
  # -t 强制分配伪终端，这样 sudo 才能请求密码

  # 批量在多台服务器上执行命令
  for host in server1 server2 server3; do
      echo "=== $host ==="
      ssh user@$host "uptime"
  done
EOF

echo ""

# --------------------------------------------------
# 三、known_hosts 和首次连接指纹确认
# --------------------------------------------------
echo "--- 3. known_hosts 与首次连接确认 ---"
echo ""

# 检查 known_hosts 文件
KNOWN_HOSTS="$HOME/.ssh/known_hosts"
if [ -f "$KNOWN_HOSTS" ]; then
    echo "known_hosts 文件存在：$KNOWN_HOSTS"
    echo "当前记录了 $(wc -l < "$KNOWN_HOSTS") 行主机公钥"
    echo ""
    echo "前 5 条记录："
    head -5 "$KNOWN_HOSTS" 2>/dev/null || echo "  （无记录或不可读）"
else
    echo "known_hosts 文件不存在（尚未进行过任何 SSH 连接）"
    echo ""
    echo "首次连接时会创建此文件。"
fi

echo ""
cat << 'EOF'
首次连接时的提示类似这样：

  The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
  ED25519 key fingerprint is SHA256:abc123def456...
  Are you sure you want to continue connecting (yes/no/[fingerprint])?

这说明：
  1. 你的电脑从未连接过这台服务器
  2. SSH 向你展示了服务器的"指纹"
  3. 你需要确认这个指纹是否正确

指纹验证类比：
  就像你第一次见到一个朋友的朋友。他说他叫"张三"，但你怎么确认这个人
  真的是张三？你打电话问你们共同的朋友："张三的身份证后6位是不是123456？"

  同样，你应该通过安全渠道（当面/电话/已加密渠道）确认服务器的指纹。

指纹类型：
  - SHA256:abc123...   新版 OpenSSH 默认
  - MD5:ab:cd:ef:...   旧版（不太安全）

查看本地 known_hosts 中某个主机的指纹：
  ssh-keygen -lf ~/.ssh/known_hosts

删除某个主机的记录（下次连接会重新提示）：
  ssh-keygen -R 192.168.1.100
  # 或直接编辑 known_hosts 文件删除对应行
EOF

echo ""

# --------------------------------------------------
# 四、常见连接问题排查
# --------------------------------------------------
echo "--- 4. 常见连接问题排查 ---"
echo ""

cat << 'EOF'
问题1：连接超时（Connection timed out）
  原因：目标不可达（IP/端口不对、防火墙拦截、sshd 未启动）
  排查：
    ping 目标IP          # 先确认网络可达
    nc -zv host 22       # 检查 SSH 端口是否开放
    ssh -vvv user@host   # 详细日志看卡在哪一步

问题2：主机指纹变更警告
  WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
  原因：服务器的密钥变了（可能是重装系统/重新生成密钥）
       也可能是中间人攻击！
  解决：
    1. 先确认服务器是否真的重装了
    2. 如果确认安全，删除旧记录：ssh-keygen -R host

问题3：权限拒绝（Permission denied）
  原因：用户名或密码不对、密钥无效、公钥未上传
  排查：
    ssh -v user@host     # 看认证到了哪一步
    # 检查远程服务器的 ~/.ssh 权限（应为 700）
    # 检查远程服务器的 ~/.ssh/authorized_keys 权限（应为 600）

问题4：SSH 密钥权限太宽松
  WARNING: UNPROTECTED PRIVATE KEY FILE!
  原因：私钥文件的权限不对（别人也能读）
  解决：chmod 600 ~/.ssh/私钥文件

问题5：DNS 解析慢（卡在 Connecting to... 很久）
  原因：SSH 在做 DNS 反向解析
  解决：在服务端 /etc/ssh/sshd_config 加：
    UseDNS no
    然后 sudo systemctl reload sshd
EOF

echo ""

# --------------------------------------------------
# 五、SSH 选项速查
# --------------------------------------------------
echo "--- 5. 常用 SSH 选项速查 ---"
echo ""

cat << 'EOF'
常用 SSH 命令选项：

  -p PORT      指定端口（默认 22）
  -i KEY       指定私钥文件
  -v / -vv     调试模式（越详细越容易排查问题）
  -t           强制分配伪终端（需要交互式输入密码时用）
  -T           不分配伪终端（执行命令时用，更快）
  -N           不执行远程命令（纯端口转发时用）
  -f           后台运行（配合 -N 做隧道常驻）
  -L [bind:]port:host:hostport   本地端口转发
  -R [bind:]port:host:hostport   远程端口转发
  -D [bind:]port                 动态端口转发（SOCKS 代理）
  -o OPTION    覆盖配置文件中的选项
  -C           压缩传输（慢速网络有用）
  -A           启用 SSH Agent 转发（谨慎使用）
  -J host      通过跳板机连接（ProxyJump）

示例：
  ssh -p 2222 -i ~/.ssh/custom_key admin@server.com
  ssh -vvv -J bastion@gateway.com final@10.0.1.5
  ssh -L 8080:localhost:80 user@host     # 本地8080转发到远程80
EOF

echo ""
echo "==========================================="
echo "  动手练习建议"
echo "==========================================="
echo ""
echo "  1. 如果你有两台 Linux 机器，试试 ssh user@host"
echo "  2. 观察 ~/.ssh/known_hosts 的变化"
echo "  3. 尝试远程执行命令：ssh user@host 'uptime'"
echo "  4. 用 ssh -v 观察连接的详细过程"
echo "  5. 故意连接一个不存在的端口，观察错误信息"
echo ""
echo "如果没有第二台机器，可以在本机测试："
echo "  ssh localhost      # 连接自己（需要先安装 sshd）"
echo "  ssh 127.0.0.1      # 效果相同"
