#!/bin/bash
# ============================================
# 02-openssl-keys.sh — OpenSSL 密钥与 CSR 操作演示
# ============================================
# 功能：演示生成 RSA/ECDSA 私钥、创建 CSR、
#       查看密钥和 CSR 内容、格式转换
# 用法：./02-openssl-keys.sh
# ============================================

set -e

WORK_DIR="/tmp/openssl-demo-$$"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "=========================================="
echo "  OpenSSL 密钥与 CSR 操作演示"
echo "  工作目录: $WORK_DIR"
echo "=========================================="
echo ""

# --------------------------------------------------
# 1. 生成 RSA 私钥
# --------------------------------------------------
echo "--- 1. 生成 RSA 私钥 ---"
echo ""

# 2048 位
echo "生成 RSA 2048 位私钥..."
openssl genrsa -out rsa-2048.key 2048 2>/dev/null
echo "  文件: rsa-2048.key ($(wc -c < rsa-2048.key) 字节)"

# 4096 位
echo "生成 RSA 4096 位私钥..."
openssl genrsa -out rsa-4096.key 4096 2>/dev/null
echo "  文件: rsa-4096.key ($(wc -c < rsa-4096.key) 字节)"

echo ""
echo "注意：RSA 4096 比 2048 更安全但握手更慢。"
echo "对于大多数网站，2048 位足够安全。"
echo ""

# --------------------------------------------------
# 2. 生成 ECDSA 私钥
# --------------------------------------------------
echo "--- 2. 生成 ECDSA 私钥 ---"
echo ""

echo "生成 ECDSA (prime256v1) 私钥..."
openssl ecparam -genkey -name prime256v1 -out ecdsa.key 2>/dev/null
echo "  文件: ecdsa.key ($(wc -c < ecdsa.key) 字节)"

echo ""
echo "对比：ECDSA 私钥文件比 RSA 小很多，但安全性相同！"
echo ""

# --------------------------------------------------
# 3. 查看私钥详情
# --------------------------------------------------
echo "--- 3. 查看私钥详情 ---"
echo ""

echo "=== RSA 私钥结构 ==="
openssl rsa -in rsa-2048.key -text -noout 2>/dev/null | head -15
echo "..."

echo ""
echo "=== ECDSA 私钥结构 ==="
openssl ec -in ecdsa.key -text -noout 2>/dev/null
echo ""

# --------------------------------------------------
# 4. 从私钥提取公钥
# --------------------------------------------------
echo "--- 4. 从私钥提取公钥 ---"
echo ""

openssl rsa -in rsa-2048.key -pubout -out rsa-2048.pub 2>/dev/null
echo "RSA 公钥已提取: rsa-2048.pub"

openssl ec -in ecdsa.key -pubout -out ecdsa.pub 2>/dev/null
echo "ECDSA 公钥已提取: ecdsa.pub"
echo ""

# --------------------------------------------------
# 5. 创建 CSR（证书签名请求）
# --------------------------------------------------
echo "--- 5. 创建 CSR ---"
echo ""

# 用 RSA 私钥创建 CSR
echo "创建 RSA CSR（非交互模式）..."
openssl req -new \
    -key rsa-2048.key \
    -out rsa-server.csr \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=MyOrg/OU=IT/CN=www.example.com" \
    2>/dev/null
echo "  CSR 已创建: rsa-server.csr"
echo ""

# 查看 CSR 内容
echo "=== CSR 内容预览 ==="
openssl req -in rsa-server.csr -text -noout 2>/dev/null | \
    grep -E "Subject:|Public Key|256|DNS" | head -10
echo ""

# --------------------------------------------------
# 6. 验证公钥配对
# --------------------------------------------------
echo "--- 6. 验证私钥与 CSR 配对 ---"
echo ""

MOD_KEY=$(openssl rsa -in rsa-2048.key -modulus -noout 2>/dev/null | md5sum)
MOD_CSR=$(openssl req -in rsa-server.csr -modulus -noout 2>/dev/null | md5sum)

echo "私钥 Modulus MD5:  $MOD_KEY"
echo "CSR  Modulus MD5:  $MOD_CSR"

if [ "$MOD_KEY" = "$MOD_CSR" ]; then
    echo "  ✓ 私钥与 CSR 匹配！"
else
    echo "  ✗ 不匹配！请检查"
fi
echo ""

# --------------------------------------------------
# 7. PEM 与 DER 格式互转
# --------------------------------------------------
echo "--- 7. 格式转换 ---"
echo ""

echo "PEM → DER："
openssl x509 -req -in rsa-server.csr -signkey rsa-2048.key -out rsa-cert.pem -days 30 2>/dev/null
openssl x509 -in rsa-cert.pem -outform der -out rsa-cert.der 2>/dev/null
echo "  PEM: rsa-cert.pem ($(wc -c < rsa-cert.pem) 字节)"
echo "  DER: rsa-cert.der ($(wc -c < rsa-cert.der) 字节)"

echo ""
echo "DER → PEM："
openssl x509 -in rsa-cert.der -inform der -outform pem -out rsa-cert-back.pem 2>/dev/null
echo "  转回 PEM: rsa-cert-back.pem ($(wc -c < rsa-cert-back.pem) 字节)"
echo ""

# --------------------------------------------------
# 8. 文件格式识别表
# --------------------------------------------------
echo "--- 8. 常见文件类型速查 ---"
echo ""

cat << 'EOF'
+-------------------------+----------------------------------+------------------+
| 后缀                    | 通常内容                         | 格式             |
+-------------------------+----------------------------------+------------------+
| .key                    | 私钥 (RSA / ECDSA / Ed25519)     | PEM (文本)       |
| .crt / .cert / .pem     | 证书                             | PEM (文本)       |
| .csr                    | 证书签名请求                     | PEM (文本)       |
| .pub                    | 公钥                             | PEM (文本)       |
| .der / .cer             | 证书                             | DER (二进制)     |
| .pfx / .p12             | 私钥 + 证书 + CA 链 的打包文件   | PKCS#12 (二进制) |
| .p7b                    | 证书链 (不含私钥)                | PKCS#7 (二进制)  |
+-------------------------+----------------------------------+------------------+

识别方法：
  - PEM: cat 文件能看到 "-----BEGIN ...-----"
  - DER: cat 文件是乱码（二进制）
  - PKCS#12: file 命令输出 "PKCS12"
EOF

echo ""
echo "=========================================="
echo "  演示完成"
echo "=========================================="
echo ""
echo "所有演示文件保存在: $WORK_DIR"
echo ""
echo "动手练习建议："
echo "  1. 生成 Ed25519 私钥: openssl genpkey -algorithm Ed25519"
echo "  2. 对比三种密钥的文件大小"
echo "  3. 创建包含 SAN 的 CSR（需要配置文件）"
echo "  4. 格式转换练习: PEM ⇄ DER, 打包为 PKCS#12"

# 清理（可选）
# rm -rf "$WORK_DIR"
