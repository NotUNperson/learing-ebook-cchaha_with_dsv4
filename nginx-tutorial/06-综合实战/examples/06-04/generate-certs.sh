#!/bin/bash
# ===========================================
# 生产级 HTTPS 全栈部署 - 证书生成脚本
# 配合 06-04-HTTP全栈部署.md 使用
# ===========================================

set -e

DOMAIN="myapp.test"
DAYS=365
CERT_DIR="./certs"
SUBJ="/C=CN/ST=Beijing/L=Beijing/O=MyCompany/OU=Dev/CN=${DOMAIN}"

echo "=== 生成 HTTPS 全栈部署所需证书 ==="
echo "域名: ${DOMAIN}"
echo "有效期: ${DAYS} 天"
echo "输出目录: ${CERT_DIR}"
echo ""

mkdir -p "${CERT_DIR}"

echo "[1/3] 生成 2048 位 RSA 私钥..."
openssl genrsa -out "${CERT_DIR}/server.key" 2048

echo "[2/3] 生成证书签名请求 (CSR)..."
openssl req -new \
    -key "${CERT_DIR}/server.key" \
    -out "${CERT_DIR}/server.csr" \
    -subj "${SUBJ}"

echo "[3/3] 自签名生成证书..."
openssl x509 -req \
    -in "${CERT_DIR}/server.csr" \
    -signkey "${CERT_DIR}/server.key" \
    -out "${CERT_DIR}/server.crt" \
    -days ${DAYS}

rm -f "${CERT_DIR}/server.csr"

echo ""
echo "=== 证书生成完成 ==="
echo "证书: ${CERT_DIR}/server.crt"
echo "私钥: ${CERT_DIR}/server.key"
echo ""
echo "文件列表:"
ls -la "${CERT_DIR}/"
echo ""
echo "注意：这是自签名证书，浏览器会提示'不安全'。"
echo "生产环境请使用 Let's Encrypt 或购买的 CA 签名证书。"
