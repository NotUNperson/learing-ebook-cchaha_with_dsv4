#!/bin/bash
# ============================================
# 05-nginx-config.sh — Nginx HTTPS 配置生成演示
# ============================================
# 功能：生成生产级 Nginx HTTPS 配置文件，
#       包含 TLS 1.3、HTTP/2、HSTS、OCSP 等
# 用法：./05-nginx-config.sh [域名]
#       默认域名：example.com
# ============================================

set -e

DOMAIN="${1:-example.com}"
OUTPUT_DIR="/tmp/nginx-https-demo-$$"
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

echo "=========================================="
echo "  Nginx HTTPS 配置生成演示"
echo "  域名: $DOMAIN"
echo "  输出: $OUTPUT_DIR"
echo "=========================================="
echo ""

# --------------------------------------------------
# 1. 生成 DH 参数文件（小尺寸演示）
# --------------------------------------------------
echo "--- 1. 生成 DH 参数（1024 位仅用于演示）---"
echo ""
echo "注意：演示用 1024 位，生产环境请用 2048 位。"
echo "2048 位生成可能需要 2-5 分钟。"
openssl dhparam -out dhparam.pem 1024 2>/dev/null
echo "  DH 参数文件: dhparam.pem"
echo ""

# --------------------------------------------------
# 2. 生成 Nginx HTTPS 配置
# --------------------------------------------------
echo "--- 2. 生成 Nginx 配置 ---"
echo ""

# 生成证书路径（演示用自签名路径）
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
KEY_PATH="/etc/letsencrypt/live/$DOMAIN/privkey.pem"
CHAIN_PATH="/etc/letsencrypt/live/$DOMAIN/chain.pem"

cat > "$DOMAIN.conf" << NGINXCONF
# ============================================
# $DOMAIN — Nginx HTTPS 配置
# 生成日期: $(date +%Y-%m-%d)
# 目标: SSL Labs A+ 评级
# ============================================

# ---- HTTP → HTTPS 重定向 ----
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    # Let's Encrypt HTTP 验证目录（certbot 需要）
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    # 其他所有请求重定向到 HTTPS
    location / {
        return 301 https://\$host\$request_uri;
    }
}

# ---- HTTPS 主站点 ----
server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    # ====== 证书 ======
    ssl_certificate         $CERT_PATH;
    ssl_certificate_key     $KEY_PATH;
    ssl_trusted_certificate $CHAIN_PATH;

    # ====== 协议与加密 ======
    # 只允许 TLS 1.2 和 1.3（禁用 1.0/1.1）
    ssl_protocols TLSv1.2 TLSv1.3;

    # 加密套件（仅安全的 ECDHE 套件）
    ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
    ssl_prefer_server_ciphers off;

    # ECDH 曲线（X25519 优先，最快最安全）
    ssl_ecdh_curve X25519:prime256v1:secp384r1;

    # ====== 性能 ======
    # 会话缓存（减少握手开销）
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;

    # DH 参数（仅 TLS 1.2 需要）
    ssl_dhparam /etc/nginx/dhparam.pem;

    # ====== OCSP Stapling ======
    # 服务器代为查询证书吊销状态，减少客户端延迟
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;

    # ====== 安全响应头 ======
    # HSTS: 强制浏览器使用 HTTPS（2 年有效期）
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    # 禁止 MIME 类型嗅探
    add_header X-Content-Type-Options "nosniff" always;

    # 防止点击劫持（禁止被嵌入 frame）
    add_header X-Frame-Options "SAMEORIGIN" always;

    # 启用浏览器 XSS 过滤器
    add_header X-XSS-Protection "1; mode=block" always;

    # 控制 Referer 信息
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # ====== 网站配置 ======
    root /var/www/$DOMAIN;
    index index.html index.htm;

    # 访问日志
    access_log /var/log/nginx/$DOMAIN.access.log;
    error_log  /var/log/nginx/$DOMAIN.error.log;

    # 主路由
    location / {
        try_files \$uri \$uri/ =404;
    }

    # 禁止访问隐藏文件（.env .git .htaccess 等）
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # 静态资源缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)\$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
NGINXCONF

echo "  配置文件: $DOMAIN.conf"
echo ""

# --------------------------------------------------
# 3. 配置要点说明
# --------------------------------------------------
echo "--- 3. 配置要点说明 ---"
echo ""

cat << 'EOF'
每个配置项的意图：

  ssl_protocols TLSv1.2 TLSv1.3;
    → 禁用老旧的 TLS 1.0/1.1，提升安全评级

  ssl_ciphers ECDHE-...
    → 只选择有前向安全性 (ECDHE) 的套件
    → 移除 CBC 模式（曾受 BEAST/Lucky13 攻击）
    → GCM 模式支持 AEAD 认证加密

  ssl_session_cache shared:SSL:10m;
    → 用 10MB 共享内存缓存 TLS 会话
    → 用户再次连接可跳过完整握手

  OCSP Stapling:
    → 服务器替你查询 CA 的吊销列表
    → 减少用户延迟和隐私泄露

  HSTS (Strict-Transport-Security):
    → 告诉浏览器"以后永远用 HTTPS"
    → 防 SSL-stripping 降级攻击
    → max-age=63072000 表示 2 年

  X-Frame-Options: SAMEORIGIN
    → 只允许同域名的页面把你嵌入 frame
    → 防止点击劫持攻击

  X-Content-Type-Options: nosniff
    → 禁止浏览器猜 MIME 类型
    → 防止 MIME 混淆攻击
EOF
echo ""

# --------------------------------------------------
# 4. 配置测试命令
# --------------------------------------------------
echo "--- 4. 配置验证命令 ---"
echo ""

cat << EOF
部署到服务器后的验证步骤：

  1. 检查 Nginx 语法：
     sudo nginx -t

  2. 重载 Nginx：
     sudo systemctl reload nginx

  3. 验证 HTTPS 可访问：
     curl -I https://$DOMAIN

  4. 检查 TLS 版本：
     openssl s_client -connect $DOMAIN:443 -tls1_3

  5. 检查安全头：
     curl -I https://$DOMAIN 2>/dev/null | grep -i strict

  6. SSL Labs 检测：
     https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN

  7. 安全头检测：
     https://securityheaders.com/?q=$DOMAIN

  8. HTTP/2 检查：
     curl -I --http2 https://$DOMAIN 2>&1 | grep HTTP
EOF
echo ""

# --------------------------------------------------
# 5. 常见错误排查
# --------------------------------------------------
echo "--- 5. 常见配置错误 ---"
echo ""

cat << 'EOF'
+------------------------------------+----------------------------------------------+
| 错误信息                           | 解决方法                                     |
+------------------------------------+----------------------------------------------+
| SSL_CTX_use_certificate: no start  | 证书文件路径不对或文件为空                    |
| line                                   | 检查 ssl_certificate 路径                     |
+------------------------------------+----------------------------------------------+
| key values mismatch                | 证书和私钥不配对                              |
|                                    | openssl x509 -modulus / openssl rsa -modulus  |
+------------------------------------+----------------------------------------------+
| SSL3_GET_CLIENT_HELLO: wrong       | 客户端不支持服务器启用的协议版本               |
| version number                     | 检查 ssl_protocols                           |
+------------------------------------+----------------------------------------------+
| OCSP response not yet valid        | 服务器时间不同步                              |
|                                    | sudo ntpdate -u pool.ntp.org                 |
+------------------------------------+----------------------------------------------+
| HSTS 误配置后无法回退 HTTP         | 浏览器已记住 HSTS，需清除                      |
|                                    | Chrome: chrome://net-internals/#hsts         |
+------------------------------------+----------------------------------------------+
EOF
echo ""

# --------------------------------------------------
# 6. 最小化 vs 生产级对比
# --------------------------------------------------
echo "--- 6. 最小化 vs 生产级配置对比 ---"
echo ""

cat << 'EOF'
最小化配置（只有 HTTPS，无优化）：
  server {
      listen 443 ssl;
      ssl_certificate     /path/to/fullchain.pem;
      ssl_certificate_key /path/to/privkey.pem;
  }

生产级配置（A+ 评级）：
  在最小化的基础上增加：
  - http2                → 性能提升
  - ssl_protocols        → 禁用弱协议
  - ssl_ciphers          → 安全套件
  - ssl_session_cache    → 会话复用
  - ssl_dhparam          → DH 参数
  - ssl_stapling         → OCSP 优化
  - add_header HSTS/...   → 安全头
  - resolver             → DNS 解析器
EOF
echo ""

echo "=========================================="
echo "  演示完成"
echo "=========================================="
echo ""
echo "生成的文件在: $OUTPUT_DIR"
echo ""
echo "动手练习建议："
echo "  1. 修改域名变量重新运行脚本"
echo "  2. 将生成的配置部署到测试 Nginx 环境"
echo "  3. 用 SSL Labs 检测站点，争取 A+"
echo "  4. 逐步关掉安全特性再检测，观察评分变化"
echo "  5. 用 testssl.sh 做更深入的本地检测"
