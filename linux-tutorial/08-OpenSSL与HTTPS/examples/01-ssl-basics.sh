#!/bin/bash
# ============================================
# 01-ssl-basics.sh — SSL/TLS 基础概念演示
# ============================================
# 功能：通过实际连接演示 SSL/TLS 的核心概念
#       包括证书链查看、TLS 版本检查、加密套件
# 用法：./01-ssl-basics.sh [域名]
#       默认域名：www.baidu.com
# ============================================

set -e

DOMAIN="${1:-www.baidu.com}"
PORT="${2:-443}"

echo "=========================================="
echo "  SSL/TLS 基础概念演示"
echo "  目标: $DOMAIN:$PORT"
echo "=========================================="
echo ""

# --------------------------------------------------
# 1. 查看完整证书链
# --------------------------------------------------
echo "--- 1. 证书链 ---"
echo ""
echo "概念：服务器会发送完整的证书链（叶子证书 + 中间 CA）。"
echo "浏览器逐级验证直到根 CA。"
echo ""

# 连接服务器并显示所有证书
echo "正在连接 $DOMAIN:$PORT ..."
CERT_CHAIN=$(echo | openssl s_client -connect "$DOMAIN:$PORT" -showcerts 2>/dev/null)

# 提取证书链中的各级 subject 和 issuer
echo "证书链层级："
echo "$CERT_CHAIN" | grep -E "^(subject|issuer)=" | head -20
echo ""

# --------------------------------------------------
# 2. 查看服务器证书详情
# --------------------------------------------------
echo "--- 2. 服务器证书详情 ---"
echo ""

# 提取叶子证书（第一个证书）
LEAF_CERT=$(echo "$CERT_CHAIN" | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' | head -30)

if [ -n "$LEAF_CERT" ]; then
    echo "$LEAF_CERT" | openssl x509 -text -noout 2>/dev/null | \
        grep -E "(Subject:|Issuer:|Not Before|Not After|Public Key Algorithm|DNS:)" | head -20
fi
echo ""

# --------------------------------------------------
# 3. 测试 TLS 版本支持
# --------------------------------------------------
echo "--- 3. TLS 版本测试 ---"
echo ""

test_tls() {
    local version=$1
    local flag=$2
    local label=$3

    if echo | openssl s_client -connect "$DOMAIN:$PORT" "$flag" 2>/dev/null | grep -q "BEGIN CERTIFICATE"; then
        echo "  [$label] 支持"
    else
        echo "  [$label] 不支持或已禁用"
    fi
}

test_tls "TLS 1.3" "-tls1_3" "TLS 1.3 "
test_tls "TLS 1.2" "-tls1_2" "TLS 1.2 "
test_tls "TLS 1.1" "-tls1_1" "TLS 1.1*"
test_tls "TLS 1.0" "-tls1"   "TLS 1.0*"

echo "  (* = 如果支持，建议在服务器端禁用)"
echo ""

# --------------------------------------------------
# 4. 查看协商的加密套件
# --------------------------------------------------
echo "--- 4. 协商结果 ---"
echo ""

CONN_INFO=$(echo | openssl s_client -connect "$DOMAIN:$PORT" 2>/dev/null)

# 提取协议版本
PROTOCOL=$(echo "$CONN_INFO" | grep "Protocol" | head -1)
echo "  协议版本: $PROTOCOL"

# 提取加密套件
CIPHER=$(echo "$CONN_INFO" | grep "Cipher" | head -1)
echo "  加密套件: $CIPHER"
echo ""

# --------------------------------------------------
# 5. 证书过期日期
# --------------------------------------------------
echo "--- 5. 证书有效期 ---"
echo ""

# 获取服务器证书并查看日期
echo | openssl s_client -connect "$DOMAIN:$PORT" -servername "$DOMAIN" 2>/dev/null | \
    openssl x509 -noout -dates 2>/dev/null

# 计算剩余天数
END_DATE=$(echo | openssl s_client -connect "$DOMAIN:$PORT" -servername "$DOMAIN" 2>/dev/null | \
    openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

if [ -n "$END_DATE" ]; then
    # Linux date 命令计算
    END_EPOCH=$(date -d "$END_DATE" +%s 2>/dev/null || echo 0)
    NOW_EPOCH=$(date +%s)
    if [ "$END_EPOCH" -gt 0 ]; then
        DAYS_LEFT=$(( ($END_EPOCH - $NOW_EPOCH) / 86400 ))
        echo "  剩余天数: $DAYS_LEFT 天"
    fi
fi
echo ""

# --------------------------------------------------
# 6. HTTP vs HTTPS 对比说明
# --------------------------------------------------
echo "--- 6. HTTP vs HTTPS 概念对比 ---"
echo ""

cat << 'EOF'
+---------------------+---------------------------+-----------------------------+
| 特性                | HTTP                      | HTTPS                       |
+---------------------+---------------------------+-----------------------------+
| 默认端口            | 80                        | 443                         |
| 加密                | 无 (明文)                 | TLS 加密                    |
| 证书                | 不需要                    | 需要 SSL/TLS 证书           |
| 浏览器地址栏        | 无锁或警告                | 小锁图标                    |
| 中间人攻击          | 可被窃听和篡改            | 不可（只要证书可信）         |
| 搜索引擎排名        | 较低                      | 更高 (Google 偏好 HTTPS)     |
| URL 格式            | http://...                | https://...                 |
+---------------------+---------------------------+-----------------------------+

核心原理：
  1. 非对称加密 (RSA/ECDSA) 用于交换对称密钥
  2. 对称加密 (AES/ChaCha20) 用于加密实际数据
  3. 证书链确保你连接的是正确的服务器
EOF

echo ""
echo "=========================================="
echo "  演示完成"
echo "=========================================="
echo ""
echo "动手练习建议："
echo "  1. 换不同的域名试试（如 github.com、google.com）"
echo "  2. 比较不同域名的证书颁发者 (Issuer)"
echo "  3. 查看通配符证书：openssl s_client -connect *.example.com:443"
echo "  4. 用 curl -v https://域名 观察 TLS 握手过程"
