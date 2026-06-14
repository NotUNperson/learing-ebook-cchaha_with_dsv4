#!/bin/bash
# ============================================
# 06-capstone.sh — HTTPS 站点搭建全流程演示
# ============================================
# 功能：从零搭建一个本地 HTTPS 测试站点，
#       整合自签名 CA、证书签发、Nginx 配置
# 用法：./06-capstone.sh [setup|start|stop|clean]
#
#   setup  - 创建 CA、签发证书、生成 Nginx 配置
#   start  - 启动 Nginx 测试站点
#   stop   - 停止 Nginx 测试站点
#   clean  - 清理所有生成的文件
#   test   - 运行 HTTPS 连接测试
# ============================================

set -e

DOMAIN="localhost"
PORT=8443
WORK_DIR="/tmp/https-demo"
NGINX_CONF="$WORK_DIR/nginx.conf"
NGINX_PID="$WORK_DIR/nginx.pid"
LOG_DIR="$WORK_DIR/logs"
WEB_ROOT="$WORK_DIR/www"

# --------------------------------------------------
# 帮助信息
# --------------------------------------------------
usage() {
    cat << EOF
用法: $0 <命令>

命令:
  setup   从零搭建 HTTPS 测试站点（生成 CA、签发证书、配置 Nginx）
  start   启动 Nginx 测试站点
  stop    停止 Nginx 测试站点
  test    运行连接测试
  status  查看站点状态
  clean   清理所有生成文件

示例:
  $0 setup    # 首次搭建
  $0 start    # 启动服务
  $0 test     # 测试连接
  $0 stop     # 停止服务
EOF
    exit 0
}

# --------------------------------------------------
# setup: 完整搭建流程
# --------------------------------------------------
do_setup() {
    echo "=========================================="
    echo "  HTTPS 测试站点搭建"
    echo "  目标: https://$DOMAIN:$PORT"
    echo "=========================================="
    echo ""

    # 清理旧文件
    rm -rf "$WORK_DIR"
    mkdir -p "$WORK_DIR"/{ca,certs,www,logs,run}

    # ---- 步骤 1: 创建 CA ----
    echo "[步骤 1/6] 创建根 CA..."

    openssl genrsa -out "$WORK_DIR/ca/ca.key" 2048 2>/dev/null
    chmod 400 "$WORK_DIR/ca/ca.key"

    openssl req -new -x509 -days 365 -key "$WORK_DIR/ca/ca.key" \
        -out "$WORK_DIR/ca/ca.crt" \
        -subj "/C=CN/ST=Beijing/L=Beijing/O=Demo/CN=Demo Root CA" \
        2>/dev/null

    echo "  CA 证书: $WORK_DIR/ca/ca.crt"
    echo ""

    # ---- 步骤 2: 创建服务器私钥和 CSR ----
    echo "[步骤 2/6] 生成服务器私钥和 CSR..."

    openssl ecparam -genkey -name prime256v1 \
        -out "$WORK_DIR/certs/server.key" 2>/dev/null
    chmod 600 "$WORK_DIR/certs/server.key"

    # 创建 SAN 配置文件
    cat > "$WORK_DIR/certs/san.cnf" << CNF
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[dn]
CN = localhost

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
IP.1  = 127.0.0.1
IP.2  = ::1
CNF

    openssl req -new -key "$WORK_DIR/certs/server.key" \
        -out "$WORK_DIR/certs/server.csr" \
        -config "$WORK_DIR/certs/san.cnf" \
        2>/dev/null

    echo "  服务器私钥: $WORK_DIR/certs/server.key"
    echo "  服务器 CSR:  $WORK_DIR/certs/server.csr"
    echo ""

    # ---- 步骤 3: CA 签发证书 ----
    echo "[步骤 3/6] CA 签发服务器证书..."

    cat > "$WORK_DIR/certs/ext.cnf" << CNF
basicConstraints       = CA:FALSE
keyUsage               = digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth
subjectAltName         = @alt_names

[alt_names]
DNS.1 = localhost
IP.1  = 127.0.0.1
IP.2  = ::1
CNF

    openssl x509 -req \
        -in "$WORK_DIR/certs/server.csr" \
        -CA "$WORK_DIR/ca/ca.crt" \
        -CAkey "$WORK_DIR/ca/ca.key" \
        -CAcreateserial \
        -out "$WORK_DIR/certs/server.crt" \
        -days 365 -sha256 \
        -extfile "$WORK_DIR/certs/ext.cnf" \
        2>/dev/null

    echo "  服务器证书: $WORK_DIR/certs/server.crt"
    echo ""

    # ---- 步骤 4: 验证 ----
    echo "[步骤 4/6] 验证证书..."

    VERIFY=$(openssl verify -CAfile "$WORK_DIR/ca/ca.crt" "$WORK_DIR/certs/server.crt" 2>&1)
    echo "  证书链: $VERIFY"

    # 确认 SAN
    SAN=$(openssl x509 -in "$WORK_DIR/certs/server.crt" -text -noout 2>/dev/null | grep -A10 "Subject Alternative" || echo "  (SAN 信息)")
    echo "  SAN: $SAN"

    CERT_DATES=$(openssl x509 -in "$WORK_DIR/certs/server.crt" -dates -noout 2>/dev/null)
    echo "  $CERT_DATES"
    echo ""

    # ---- 步骤 5: 创建 Web 页面 ----
    echo "[步骤 5/6] 创建测试网页..."

    cat > "$WEB_ROOT/index.html" << 'HTML'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>HTTPS 测试站点</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #e0e0e0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .card {
            background: #1e293b;
            border: 1px solid #334155;
            border-radius: 1rem;
            padding: 3rem;
            text-align: center;
            max-width: 480px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        .lock {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        h1 { color: #22c55e; margin-bottom: 0.5rem; font-size: 1.5rem; }
        p { color: #94a3b8; margin-bottom: 1.5rem; }
        .info {
            background: #0f172a;
            border-radius: 0.5rem;
            padding: 1rem;
            text-align: left;
            font-family: monospace;
            font-size: 0.85rem;
        }
        .info span { color: #22c55e; }
        .footer { margin-top: 1.5rem; font-size: 0.8rem; color: #64748b; }
    </style>
</head>
<body>
    <div class="card">
        <div class="lock">&#x1f512;</div>
        <h1>HTTPS 配置成功!</h1>
        <p>你正在通过加密连接访问这个站点</p>
        <div class="info">
            <div>协议: <span>TLS 1.3</span></div>
            <div>证书: <span>自签名 (Demo CA)</span></div>
            <div>加密: <span>ECDHE-ECDSA-AES256-GCM</span></div>
            <div>密钥: <span>ECDSA prime256v1</span></div>
        </div>
        <div class="footer">由 OpenSSL 模块综合练习生成</div>
    </div>
</body>
</html>
HTML

    echo "  网页: $WEB_ROOT/index.html"
    echo ""

    # ---- 步骤 6: 创建 Nginx 配置 ----
    echo "[步骤 6/6] 生成 Nginx 配置..."

    # 检查 Nginx 是否可用
    if ! command -v nginx &>/dev/null; then
        echo ""
        echo "  [警告] Nginx 未安装！"
        echo "  安装命令: sudo apt install nginx"
        echo ""
        echo "  安装后运行: $0 start 启动测试站点"
        echo ""

        # 无 Nginx 时提供 Python 替代方案
        cat > "$WORK_DIR/start-https.py" << 'PYEOF'
#!/usr/bin/env python3
"""简易 HTTPS 测试服务器（不依赖 Nginx）"""
import http.server
import ssl
import os

CERT = "/tmp/https-demo/certs/server.crt"
KEY = "/tmp/https-demo/certs/server.key"
PORT = 8443

os.chdir("/tmp/https-demo/www")

ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain(CERT, KEY)
# 只允许 TLS 1.2+
ctx.minimum_version = ssl.TLSVersion.TLSv1_2

httpd = http.server.HTTPServer(('127.0.0.1', PORT),
                                http.server.SimpleHTTPRequestHandler)
httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)

print(f"HTTPS 测试服务器已启动: https://localhost:{PORT}")
print("按 Ctrl+C 停止")
httpd.serve_forever()
PYEOF
        chmod +x "$WORK_DIR/start-https.py"
        echo "  已生成 Python 替代方案: $WORK_DIR/start-https.py"
        echo "  运行: python3 $WORK_DIR/start-https.py"

        return
    fi

    cat > "$NGINX_CONF" << NGINX
# HTTPS 测试站点 Nginx 配置
# 生成于: $(date)

worker_processes 1;
error_log $LOG_DIR/error.log warn;
pid $NGINX_PID;

events {
    worker_connections 128;
}

http {
    access_log $LOG_DIR/access.log;

    server {
        listen 127.0.0.1:$PORT ssl http2;
        server_name localhost;

        ssl_certificate         $WORK_DIR/certs/server.crt;
        ssl_certificate_key     $WORK_DIR/certs/server.key;
        ssl_protocols           TLSv1.2 TLSv1.3;
        ssl_ciphers             ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache       shared:SSL:5m;
        ssl_session_timeout     10m;

        root $WEB_ROOT;
        index index.html;
    }
}
NGINX

    echo "  Nginx配置: $NGINX_CONF"
    echo ""

    echo "=========================================="
    echo "  搭建完成！"
    echo "=========================================="
    echo ""
    echo "启动测试站点:"
    echo "  $0 start"
    echo ""
    echo "然后访问: https://localhost:$PORT"
    echo "用浏览器打开，点击"高级" -> "继续访问""
    echo "(因为是自签名证书，浏览器会警告，这是正常的)"
    echo ""
    echo "信任 CA 后就不会有警告了："
    echo "  Linux:   sudo cp $WORK_DIR/ca/ca.crt /usr/local/share/ca-certificates/demo-ca.crt"
    echo "           sudo update-ca-certificates"
    echo "  macOS:   sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $WORK_DIR/ca/ca.crt"
    echo "  Firefox: 设置 → 隐私与安全 → 证书 → 查看证书 → 导入 $WORK_DIR/ca/ca.crt"
}

# --------------------------------------------------
# start: 启动 Nginx 测试站点
# --------------------------------------------------
do_start() {
    if ! command -v nginx &>/dev/null; then
        # 尝试 Python 方案
        if [ -f "$WORK_DIR/start-https.py" ]; then
            echo "使用 Python 启动 HTTPS 服务..."
            python3 "$WORK_DIR/start-https.py"
        else
            echo "错误: Nginx 未安装且无 Python 替代脚本。请先运行 $0 setup"
            exit 1
        fi
        return
    fi

    if [ ! -f "$NGINX_CONF" ]; then
        echo "错误: 配置文件不存在。请先运行 $0 setup"
        exit 1
    fi

    echo "启动 Nginx 测试站点..."
    nginx -c "$NGINX_CONF" -p "$WORK_DIR" 2>/dev/null || {
        echo "Nginx 启动失败，请检查日志: $LOG_DIR/error.log"
        exit 1
    }
    echo "站点已启动: https://$DOMAIN:$PORT"
    echo ""
    echo "测试命令："
    echo "  curl --cacert $WORK_DIR/ca/ca.crt https://localhost:$PORT"
    echo "  $0 test"
    echo ""
    echo "停止站点: $0 stop"
}

# --------------------------------------------------
# stop: 停止 Nginx 测试站点
# --------------------------------------------------
do_stop() {
    if [ -f "$NGINX_PID" ]; then
        PID=$(cat "$NGINX_PID")
        if kill -0 "$PID" 2>/dev/null; then
            echo "停止 Nginx (PID: $PID)..."
            kill "$PID"
        fi
        rm -f "$NGINX_PID"
        echo "站点已停止"
    else
        echo "站点未运行（未找到 PID 文件）"
        # 尝试杀死残留进程
        pkill -f "nginx.*$WORK_DIR" 2>/dev/null && echo "已杀死残留的 nginx 进程" || true
    fi
}

# --------------------------------------------------
# test: 测试 HTTPS 连接
# --------------------------------------------------
do_test() {
    echo "测试 HTTPS 连接..."
    echo ""

    CA="$WORK_DIR/ca/ca.crt"
    URL="https://localhost:$PORT"

    if [ ! -f "$CA" ]; then
        echo "错误: CA 证书不存在。请先运行 $0 setup"
        exit 1
    fi

    # 测试 1: curl
    echo "--- 测试 1: curl 连接 ---"
    if CURL_OUT=$(curl --cacert "$CA" -sS -o /dev/null -w "HTTP状态码: %{http_code}\nTLS版本: %{ssl_verify_result}\n" "$URL" 2>&1); then
        echo "$CURL_OUT"
        echo "  连接成功！"
    else
        echo "  连接失败: $CURL_OUT"
        echo "  (可能是站点未启动，运行 $0 start)"
    fi
    echo ""

    # 测试 2: OpenSSL s_client
    echo "--- 测试 2: OpenSSL s_client ---"
    if echo | openssl s_client -connect "localhost:$PORT" -tls1_3 2>/dev/null | grep -E "Protocol|Cipher|subject=" | head -5; then
        echo "  TLS 握手成功！"
    else
        echo "  TLS 握手失败（站点可能未启动）"
    fi
    echo ""

    # 测试 3: 证书验证
    echo "--- 测试 3: 证书链验证 ---"
    echo | openssl s_client -connect "localhost:$PORT" -CAfile "$CA" 2>/dev/null | grep "Verify return code" || echo "  (站点可能未启动)"
    echo ""

    # 测试 4: 安全头检查
    echo "--- 测试 4: HTTP 响应头 ---"
    curl --cacert "$CA" -sI "$URL" 2>/dev/null | head -10 || echo "  (无法获取响应头)"
    echo ""
}

# --------------------------------------------------
# status: 查看站点状态
# --------------------------------------------------
do_status() {
    echo "站点目录: $WORK_DIR"
    echo ""

    if [ -f "$NGINX_PID" ]; then
        PID=$(cat "$NGINX_PID")
        if kill -0 "$PID" 2>/dev/null; then
            echo "状态: 运行中 (PID: $PID)"
        else
            echo "状态: 已停止 (PID 文件存在但进程不存在)"
        fi
    else
        echo "状态: 已停止"
    fi
    echo ""

    echo "文件清单:"
    find "$WORK_DIR" -type f -not -path "*/logs/*" 2>/dev/null | sort
}

# --------------------------------------------------
# clean: 清理所有文件
# --------------------------------------------------
do_clean() {
    # 先停止
    do_stop 2>/dev/null || true

    if [ -d "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR"
        echo "已清理: $WORK_DIR"
    else
        echo "没有需要清理的文件"
    fi
}

# --------------------------------------------------
# 主入口
# --------------------------------------------------
case "${1:-}" in
    setup)  do_setup ;;
    start)  do_start ;;
    stop)   do_stop ;;
    test)   do_test ;;
    status) do_status ;;
    clean)  do_clean ;;
    *)      usage ;;
esac
