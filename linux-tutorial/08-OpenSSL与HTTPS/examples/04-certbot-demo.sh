#!/bin/bash
# ============================================
# 04-certbot-demo.sh — Let's Encrypt 证书申请演示
# ============================================
# 功能：演示 certbot 安装、运行 dry-run、查看证书、
#       配置自动续期、证书过期检查
# 用法：./04-certbot-demo.sh
#
# 注意：本脚本是演示/教育用途。实际申请证书
#       需要你有公网可访问的域名和服务器。
# ============================================

set -e

echo "=========================================="
echo "  Let's Encrypt 证书申请演示"
echo "=========================================="
echo ""

# --------------------------------------------------
# 1. 检查 certbot 是否安装
# --------------------------------------------------
echo "--- 1. certbot 安装状态 ---"
echo ""

if command -v certbot &>/dev/null; then
    echo "certbot 已安装: $(certbot --version)"
else
    echo "certbot 未安装。安装命令："
    echo ""
    echo "  Ubuntu/Debian:"
    echo "    sudo apt update"
    echo "    sudo apt install certbot"
    echo ""
    echo "  CentOS/RHEL 7:"
    echo "    sudo yum install epel-release"
    echo "    sudo yum install certbot"
    echo ""
    echo "  CentOS/RHEL 8+ / Fedora:"
    echo "    sudo dnf install certbot"
    echo ""
    echo "  snap (通用):"
    echo "    sudo snap install --classic certbot"
    echo "    sudo ln -s /snap/bin/certbot /usr/bin/certbot"
fi
echo ""

# --------------------------------------------------
# 2. Let's Encrypt 工作流程说明
# --------------------------------------------------
echo "--- 2. Let's Encrypt 工作流程 ---"
echo ""

cat << 'EOF'
Let's Encrypt 是免费、自动化的 CA。申请流程：

  1. 安装 certbot（ACME 客户端）
  2. 证明域名所有权（HTTP 验证或 DNS 验证）
  3. certbot 自动生成私钥和 CSR
  4. certbot 向 Let's Encrypt 提交 CSR
  5. Let's Encrypt 签发证书（90 天有效期）
  6. certbot 自动配置续期任务

域名验证的两种方式：

  HTTP 验证 (http-01)：
    - Let's Encrypt 要求你在 http://你的域名/.well-known/acme-challenge/<token>
      放一份随机令牌
    - 需要 80 端口能从公网访问
    - 不支持通配符证书

  DNS 验证 (dns-01)：
    - Let's Encrypt 要求你在 DNS 中添加 _acme-challenge.你的域名 TXT 记录
    - 不需要开放端口
    - 支持通配符证书 (*.example.com)
    - 支持内网服务器
EOF
echo ""

# --------------------------------------------------
# 3. certbot 常用命令速查
# --------------------------------------------------
echo "--- 3. certbot 命令速查 ---"
echo ""

cat << 'EOF'
=== 申请证书 ===

  # 自动配置 Nginx（推荐）
  sudo certbot --nginx -d example.com -d www.example.com

  # 获取通配符证书（DNS 验证）
  sudo certbot certonly --manual --preferred-challenges dns \
      -d "*.example.com" -d example.com

  # 只获取证书，不修改 Web 服务器配置
  sudo certbot certonly --webroot -w /var/www/html \
      -d example.com -d www.example.com

  # 干跑测试（不真正申请，验证流程是否可行）
  sudo certbot certonly --dry-run --webroot -w /var/www/html \
      -d example.com

=== 管理证书 ===

  # 查看所有证书
  sudo certbot certificates

  # 查看指定域名证书
  sudo certbot certificates -d example.com

  # 删除证书
  sudo certbot delete --cert-name example.com

  # 吊销证书（私钥泄露时）
  sudo certbot revoke --cert-path /etc/letsencrypt/live/example.com/cert.pem

=== 续期 ===

  # 测试自动续期
  sudo certbot renew --dry-run

  # 手动续期
  sudo certbot renew

  # 查看续期定时器
  sudo systemctl list-timers | grep certbot
EOF
echo ""

# --------------------------------------------------
# 4. 证书文件位置
# --------------------------------------------------
echo "--- 4. 证书文件结构 ---"
echo ""

cat << 'EOF'
certbot 签发的证书存放在：

  /etc/letsencrypt/
  ├── live/
  │   └── example.com/
  │       ├── fullchain.pem     ← Nginx/Apache 用这个！(证书+中间CA)
  │       ├── privkey.pem       ← 私钥 (保密！)
  │       ├── cert.pem          ← 仅服务器证书
  │       ├── chain.pem         ← 仅中间 CA 证书
  │       └── README            ← 说明文件
  ├── renewal/
  │   └── example.com.conf      ← 续期配置
  └── archive/
      └── example.com/          ← 历史版本备份

实际文件是符号链接：
  fullchain.pem → ../../archive/example.com/fullchain1.pem

这意味着 certbot 续期时只需更新 archive/ 里的文件，
live/ 下的符号链接自动指向新版本。
EOF
echo ""

# --------------------------------------------------
# 5. 自动续期配置说明
# --------------------------------------------------
echo "--- 5. 自动续期配置 ---"
echo ""

cat << 'EOF'
certbot 安装后通常会配置自动续期：

  检查方式一 (systemd timer)：
    sudo systemctl status certbot.timer
    sudo systemctl list-timers | grep certbot

  检查方式二 (cron)：
    sudo ls /etc/cron.d/certbot

续期后自动重载 Nginx 的配置：

  编辑 /etc/letsencrypt/renewal/example.com.conf：
    [renewalparams]
    renew_hook = systemctl reload nginx

  或全局配置 /etc/letsencrypt/cli.ini：
    deploy-hook = systemctl reload nginx

Let's Encrypt 速率限制（注意别撞墙）：
  - 同一域名每周最多 50 张证书
  - 同一域名每 3 小时最多 5 次验证失败
  - 通配符证书只能用 DNS 验证
EOF
echo ""

# --------------------------------------------------
# 6. 证书过期检查脚本生成
# --------------------------------------------------
echo "--- 6. 生成证书过期检查脚本 ---"
echo ""

CHECK_SCRIPT="/tmp/cert-expiry-check-$$.sh"

cat > "$CHECK_SCRIPT" << 'SCRIPT'
#!/bin/bash
# 证书过期检查脚本
# 建议加入 crontab 每天运行

CERT_DIR="/etc/letsencrypt/live"
THRESHOLD_DAYS=14

if [ ! -d "$CERT_DIR" ]; then
    echo "letsencrypt 证书目录不存在: $CERT_DIR"
    exit 0
fi

for domain_dir in "$CERT_DIR"/*/; do
    [ -d "$domain_dir" ] || continue

    DOMAIN=$(basename "$domain_dir")
    CERT_FILE="${domain_dir}cert.pem"

    if [ ! -f "$CERT_FILE" ]; then
        continue
    fi

    # 获取过期日期
    END_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" 2>/dev/null | cut -d= -f2)
    if [ -z "$END_DATE" ]; then
        continue
    fi

    END_EPOCH=$(date -d "$END_DATE" +%s 2>/dev/null || echo 0)
    NOW_EPOCH=$(date +%s)

    if [ "$END_EPOCH" -eq 0 ]; then
        continue
    fi

    DAYS_LEFT=$(( ($END_EPOCH - $NOW_EPOCH) / 86400 ))

    if [ "$DAYS_LEFT" -le "$THRESHOLD_DAYS" ]; then
        echo "WARNING: $DOMAIN 证书 $DAYS_LEFT 天后过期！"
    else
        echo "OK: $DOMAIN 证书还有 $DAYS_LEFT 天"
    fi
done
SCRIPT

chmod +x "$CHECK_SCRIPT"
echo "  脚本已生成: $CHECK_SCRIPT"
echo ""
echo "加入 crontab 每天运行："
echo "  (crontab -l 2>/dev/null; echo \"0 9 * * * $CHECK_SCRIPT >> /var/log/cert-check.log\") | crontab -"
echo ""

# --------------------------------------------------
# 7. 运行 dry-run（如果 certbot 可用）
# --------------------------------------------------
echo "--- 7. 实际环境检查 ---"
echo ""

if command -v certbot &>/dev/null; then
    if [ -d /etc/letsencrypt/live ]; then
        echo "已签发证书列表："
        sudo certbot certificates 2>/dev/null || echo "  (无需 root 权限或没有证书)"
    else
        echo "尚未签发任何证书，或 /etc/letsencrypt/live 不存在"
    fi
else
    echo "certbot 未安装，无法检查现有证书"
fi

echo ""
echo "=========================================="
echo "  演示完成"
echo "=========================================="
echo ""
echo "动手练习建议："
echo "  1. 安装 certbot: sudo apt install certbot"
echo "  2. 用 dry-run 测试流程: sudo certbot certonly --dry-run --webroot -w /var/www/html -d 你的域名"
echo "  3. 在 DNS 服务商后台添加 TXT 记录体验 DNS 验证"
echo "  4. 配置 certbot 的 deploy-hook 让续期后自动重载 Nginx"
echo "  5. 访问 https://crt.sh/?q=你的域名 查看你的证书在 CT 日志中的公开记录"
