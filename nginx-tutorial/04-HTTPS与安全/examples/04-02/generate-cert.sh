#!/bin/bash
# ===========================================
# 自签名证书生成脚本
# 适用场景：开发环境、内网测试
# 放在 examples/04-02/ 目录下运行
# ===========================================

set -e

DOMAIN="example.test"
DAYS=365
OUTPUT_DIR="."

echo "=== 第 1 步：生成私钥 ==="
openssl genrsa -out "${OUTPUT_DIR}/server.key" 2048
echo "私钥已生成: ${OUTPUT_DIR}/server.key"

echo ""
echo "=== 第 2 步：生成证书签名请求 (CSR) ==="
# -subj 参数批量填写证书信息，避免交互
openssl req -new \
    -key "${OUTPUT_DIR}/server.key" \
    -out "${OUTPUT_DIR}/server.csr" \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=MyCompany/OU=Dev/CN=${DOMAIN}"
echo "CSR 已生成: ${OUTPUT_DIR}/server.csr"

echo ""
echo "=== 第 3 步：用私钥自签名生成证书 ==="
openssl x509 -req \
    -in "${OUTPUT_DIR}/server.csr" \
    -signkey "${OUTPUT_DIR}/server.key" \
    -out "${OUTPUT_DIR}/server.crt" \
    -days ${DAYS}
echo "自签名证书已生成: ${OUTPUT_DIR}/server.crt"

echo ""
echo "=== 第 4 步：查看证书信息 ==="
openssl x509 -in "${OUTPUT_DIR}/server.crt" -text -noout | head -20

echo ""
echo "=== 完成！生成的文件 ==="
ls -la "${OUTPUT_DIR}/server.key" "${OUTPUT_DIR}/server.csr" "${OUTPUT_DIR}/server.crt"
echo ""
echo "文件说明："
echo "  server.key - 私钥（保密，不要泄露）"
echo "  server.csr - 证书签名请求（申请 CA 签名用，自签名场景可删除）"
echo "  server.crt - 自签名证书（配给 Nginx 用）"
