#!/bin/bash
# ============================================
# 03-self-signed-ca.sh — 自建微型 CA 完整演示
# ============================================
# 功能：从零创建根 CA、签发服务器证书、
#       验证证书链、导出需要的文件
# 用法：./03-self-signed-ca.sh
# ============================================

set -e

CA_DIR="/tmp/my-ca-$$"
mkdir -p "$CA_DIR"
cd "$CA_DIR"

echo "=========================================="
echo "  自建微型 CA 完整演示"
echo "  工作目录: $CA_DIR"
echo "=========================================="
echo ""

# ============================================
# 步骤 1：创建根 CA
# ============================================

echo "========================================"
echo "  步骤 1: 创建根 CA"
echo "========================================"
echo ""

# 生成 CA 私钥
echo "[1.1] 生成 CA 私钥 (RSA 4096)..."
openssl genrsa -out ca.key 4096 2>/dev/null
chmod 400 ca.key
echo "  CA 私钥: ca.key"

echo ""

# 自签名 CA 根证书
echo "[1.2] 自签名 CA 根证书..."
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=MyOrg/OU=Security/CN=MyOrg Root CA" \
    2>/dev/null

echo "  CA 证书: ca.crt"
echo ""

# 查看 CA 证书信息
echo "[1.3] CA 证书信息："
openssl x509 -in ca.crt -subject -issuer -dates -noout 2>/dev/null
echo ""

echo "注意：Issuer 和 Subject 相同 → 这是自签名证书（信任链顶端）"
echo ""

# ============================================
# 步骤 2：创建服务器证书的 SAN 配置文件
# ============================================

echo "========================================"
echo "  步骤 2: 准备服务器证书配置"
echo "========================================"
echo ""

# 创建 CSR 配置文件（含 SAN）
cat > server.cnf << 'CNF'
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[dn]
C  = CN
ST = Beijing
L  = Beijing
O  = MyOrg
OU = IT
CN = www.example.local

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = www.example.local
DNS.2 = example.local
DNS.3 = localhost
DNS.4 = *.example.local
IP.1  = 127.0.0.1
IP.2  = ::1
CNF

echo "  已创建: server.cnf (含 SAN 配置)"
echo ""

# ============================================
# 步骤 3：签发服务器证书
# ============================================

echo "========================================"
echo "  步骤 3: 签发服务器证书"
echo "========================================"
echo ""

# 生成服务器私钥
echo "[3.1] 生成服务器私钥 (ECDSA)..."
openssl ecparam -genkey -name prime256v1 -out server.key 2>/dev/null
chmod 600 server.key
echo "  服务器私钥: server.key"
echo ""

# 生成 CSR
echo "[3.2] 生成服务器 CSR..."
openssl req -new -key server.key -out server.csr -config server.cnf 2>/dev/null
echo "  服务器 CSR: server.csr"
echo ""

# 查看 CSR 中的 SAN
echo "[3.3] CSR 中的 SAN 信息："
openssl req -in server.csr -text -noout 2>/dev/null | grep -A10 "Subject Alternative"
echo ""

# 创建签发用的扩展配置
cat > server-ext.cnf << 'CNF'
basicConstraints       = CA:FALSE
keyUsage               = digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth, clientAuth
subjectAltName         = @alt_names
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer

[alt_names]
DNS.1 = www.example.local
DNS.2 = example.local
DNS.3 = localhost
DNS.4 = *.example.local
IP.1  = 127.0.0.1
IP.2  = ::1
CNF

echo "  已创建: server-ext.cnf (签发用扩展配置)"
echo ""

# CA 签发证书
echo "[3.4] CA 签发服务器证书..."
openssl x509 -req \
    -in server.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out server.crt \
    -days 365 \
    -sha256 \
    -extfile server-ext.cnf \
    2>/dev/null

echo "  服务器证书: server.crt"
echo ""

echo "[3.5] 服务器证书信息："
openssl x509 -in server.crt -subject -issuer -dates -noout 2>/dev/null
echo ""

# ============================================
# 步骤 4：验证
# ============================================

echo "========================================"
echo "  步骤 4: 验证"
echo "========================================"
echo ""

# 验证证书链
echo "[4.1] 证书链验证："
VERIFY_RESULT=$(openssl verify -CAfile ca.crt server.crt 2>&1)
echo "  $VERIFY_RESULT"
echo ""

# 确认私钥/证书匹配
echo "[4.2] 私钥与证书配对检查："
MOD_KEY=$(openssl ec -in server.key -pubout 2>/dev/null | openssl md5 2>/dev/null)
MOD_CRT=$(openssl x509 -in server.crt -modulus -noout 2>/dev/null | md5sum)

echo "  私钥公钥 MD5: $MOD_KEY"
echo "  证书公钥 MD5: $MOD_CRT"
echo ""

# 查看完整证书内容
echo "[4.3] 证书 SAN 确认："
openssl x509 -in server.crt -text -noout 2>/dev/null | grep -A10 "Subject Alternative"
echo ""

# ============================================
# 步骤 5：输出可用文件总结
# ============================================

echo "========================================"
echo "  步骤 5: 文件总结"
echo "========================================"
echo ""

cat << EOF
生成的完整文件清单：

  根 CA:
    ca.key  — CA 私钥（保密！权限 400）
    ca.crt  — CA 根证书（需要安装到系统信任库）

  服务器:
    server.key  — 服务器私钥（保密！权限 600）
    server.crt  — 服务器证书
    server.csr  — 服务器 CSR（签发后可删除）

  配置文件（参考用）:
    server.cnf      — CSR 配置（含 SAN）
    server-ext.cnf  — 签发扩展配置

Nginx 使用方式：
  ssl_certificate     $CA_DIR/server.crt;
  ssl_certificate_key $CA_DIR/server.key;
  ssl_trusted_certificate $CA_DIR/ca.crt;

安装 CA 到系统信任库：
  Debian/Ubuntu:
    sudo cp ca.crt /usr/local/share/ca-certificates/myorg-ca.crt
    sudo update-ca-certificates

  CentOS/RHEL/Fedora:
    sudo cp ca.crt /etc/pki/ca-trust/source/anchors/myorg-ca.crt
    sudo update-ca-trust

  macOS:
    sudo security add-trusted-cert -d -r trustRoot \\
        -k /Library/Keychains/System.keychain ca.crt

浏览器测试：
  Python 快速起 HTTPS 服务：
  python3 -c "
  import http.server, ssl
  ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
  ctx.load_cert_chain('server.crt', 'server.key')
  httpd = http.server.HTTPServer(('localhost', 4443),
           http.server.SimpleHTTPRequestHandler)
  httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)
  print('访问 https://localhost:4443')
  httpd.serve_forever()
  "

EOF

echo "=========================================="
echo "  演示完成！"
echo "=========================================="
echo ""
echo "所有文件保存在: $CA_DIR"
echo ""
echo "动手练习建议："
echo "  1. 运行上面的 Python HTTPS 服务命令测试证书"
echo "  2. 用 curl --cacert ca.crt https://localhost:4443 测试"
echo "  3. 浏览器访问 https://localhost:4443，观察"不安全"警告"
echo "  4. 安装 ca.crt 到系统信任库后，刷新浏览器看绿色小锁"
echo "  5. 签发一个通配符证书 *.example.local 给多个子域名用"
