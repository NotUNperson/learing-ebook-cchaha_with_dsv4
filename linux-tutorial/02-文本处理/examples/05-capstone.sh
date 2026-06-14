#!/bin/bash
# ==============================================================================
# 05-capstone.sh — Nginx access.log 综合分析脚本
# ==============================================================================
# 用法: bash 05-capstone.sh
#
# 本脚本分两部分：
#   1. 自动生成模拟的 Nginx access.log（50 行）
#   2. 对这个日志做完整分析：统计 IP、找 404、提取 User-Agent
#
# 所有文件创建在 /tmp/linux-capstone-demo-$$ 下。
# ==============================================================================

set -e

DEMO_DIR="/tmp/linux-capstone-demo-$$"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

echo "=========================================="
echo "05-capstone.sh: Nginx 日志分析综合演示"
echo "=========================================="
echo ""
echo "[INFO] 演示目录: $DEMO_DIR"
echo ""

# ============================================================
# 第一部分：生成模拟的 Nginx access.log
# ============================================================
echo "=========================================="
echo "第一部分: 生成模拟 Nginx 访问日志"
echo "=========================================="
echo ""

# 模拟数据数组
IPS=(
    "192.168.1.100"
    "10.0.0.5"
    "172.16.0.23"
    "8.8.8.8"
    "10.0.0.5"
    "192.168.1.100"
    "203.0.113.45"
    "198.51.100.22"
    "192.168.1.100"
    "10.0.0.99"
)

URLS=(
    "/index.html"
    "/about"
    "/contact"
    "/api/users"
    "/nonexistent-page"
    "/images/logo.png"
    "/css/style.css"
    "/js/app.js"
    "/old-url"
    "/api/login"
    "/api/data"
    "/favicon.ico"
    "/robots.txt"
    "/admin"
    "/wp-admin"
)

CODES=(
    "200"
    "200"
    "200"
    "200"
    "200"
    "200"
    "200"
    "301"
    "304"
    "404"
    "403"
    "500"
)

METHODS=("GET" "GET" "GET" "GET" "GET" "POST" "HEAD")

AGENTS=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (X11; Linux x86_64; rv:121.0) Gecko/20100101 Firefox/121.0"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
    "curl/7.68.0"
    "python-requests/2.28.0"
    "Wget/1.21"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0"
)

# 根据状态码生成对应的响应体大小
get_size() {
    local code=$1
    local url=$2
    case $code in
        200) echo $((RANDOM % 50000 + 500)) ;;
        301) echo $((RANDOM % 200 + 100)) ;;
        304) echo 0 ;;
        404) echo $((RANDOM % 200 + 50)) ;;
        403) echo $((RANDOM % 100 + 30)) ;;
        500) echo $((RANDOM % 200 + 50)) ;;
        *)   echo $((RANDOM % 1000 + 100)) ;;
    esac
}

LOG_FILE="access.log"
> "$LOG_FILE"  # 清空或创建日志文件

NUM_LINES=50
echo "正在生成 $NUM_LINES 行模拟日志..."

for i in $(seq 1 $NUM_LINES); do
    ip=${IPS[$((RANDOM % ${#IPS[@]}))]}
    url=${URLS[$((RANDOM % ${#URLS[@]}))]}
    code=${CODES[$((RANDOM % ${#CODES[@]}))]}
    method=${METHODS[$((RANDOM % ${#METHODS[@]}))]}
    agent=${AGENTS[$((RANDOM % ${#AGENTS[@]}))]}
    size=$(get_size "$code" "$url")

    # 生成时间（模拟 2026-05-15 当天不同时刻）
    day="15"
    hour=$(printf "%02d" $((RANDOM % 24)))
    minute=$(printf "%02d" $((RANDOM % 60)))
    second=$(printf "%02d" $((RANDOM % 60)))

    # 模拟 Referer（约 30% 的请求有 Referer）
    referer="-"
    if [ $((RANDOM % 10)) -lt 3 ]; then
        REF_URLS=("https://www.google.com/" "https://www.bing.com/" "https://github.com/" "-")
        referer="\"${REF_URLS[$((RANDOM % 3))]}\""
    else
        referer='"-"'
    fi

    printf '%s - - [%s/May/2026:%s:%s:%s +0800] "%s %s HTTP/1.1" %s %s %s "%s"\n' \
        "$ip" "$day" "$hour" "$minute" "$second" \
        "$method" "$url" "$code" "$size" "$referer" "$agent" >> "$LOG_FILE"
done

echo "模拟日志已生成: $LOG_FILE ($NUM_LINES 行)"
echo ""

echo "日志文件前 5 行预览:"
head -5 "$LOG_FILE"
echo "..."

# ============================================================
# 第二部分：日志分析
# ============================================================
echo ""
echo "=========================================="
echo "第二部分: 日志数据分析"
echo "=========================================="
echo ""

# --- 分析 1: 基础统计 ---
echo "--- 基础统计 ---"
TOTAL_LINES=$(wc -l < "$LOG_FILE")
echo "请求总数: $TOTAL_LINES"
echo ""

# 各状态码分布
echo "状态码分布:"
awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -rn | while read count code; do
    case $code in
        200) desc="OK" ;;
        301) desc="Moved Permanently" ;;
        304) desc="Not Modified" ;;
        403) desc="Forbidden" ;;
        404) desc="Not Found" ;;
        500) desc="Internal Server Error" ;;
        *)   desc="Unknown" ;;
    esac
    printf "  %s: %d 次 (%s)\n" "$code" "$count" "$desc"
done
echo ""

# --- 分析 2: 访问量 TOP N IP ---
echo "--- 访问量 TOP 10 IP ---"
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10 | while read count ip; do
    printf "  %4d 次  %s\n" "$count" "$ip"
done
echo ""

# --- 分析 3: 404 错误分析 ---
echo "--- 404 错误分析 ---"

NOTFOUND_COUNT=$(grep -c ' 404 ' "$LOG_FILE" || true)
echo "404 请求总数: ${NOTFOUND_COUNT:-0}"
echo ""

if [ "${NOTFOUND_COUNT:-0}" -gt 0 ]; then
    echo "404 请求详情:"
    awk '$9 == "404" {printf "  时间: %s  IP: %-16s  URL: %s\n", $4, $1, $7}' "$LOG_FILE"
    echo ""

    echo "被请求最多的 404 URL (TOP 5):"
    awk '$9 == "404" {print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -5
    echo ""

    echo "触发 404 最多的 IP (TOP 5):"
    awk '$9 == "404" {print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -5
    echo ""
fi

# --- 分析 4: User-Agent 统计 ---
echo "--- User-Agent 统计 ---"
echo "详细的 User-Agent 分布:"
awk -F'"' '{print $6}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
echo ""

# 简化版：只提取浏览器类型
echo "简化版（只提取浏览器类型）:"
awk -F'"' '{print $6}' "$LOG_FILE" \
    | grep -oE '(Chrome|Firefox|Safari|Edge|curl|python-requests|Wget)' \
    | sort | uniq -c | sort -rn
echo ""

# --- 分析 5: 请求方法统计 ---
echo "--- 请求方法统计 ---"
awk -F'"' '{print $2}' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -rn
echo ""

# --- 分析 6: 流量 TOP URL ---
echo "--- 被访问最多的 URL (TOP 10) ---"
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
echo ""

# --- 分析 7: 按小时分布的请求量 ---
echo "--- 按小时分布的请求量 ---"
awk '{
    # 时间格式: [15/May/2026:14:30:45
    match($4, /:([0-9]{2}):[0-9]{2}:[0-9]{2}$/, arr)
    # 备用方法: 直接用 substr
    time = substr($4, 2, 17)
    split(time, parts, ":")
    hour = parts[2]
    print hour
}' "$LOG_FILE" | sort | uniq -c | sort -k2 -n | while read count hour; do
    printf "  %02d:00 - %3d 次请求\n" "$hour" "$count"
done
echo ""

# --- 分析 8: 响应大小的统计 ---
echo "--- 响应大小统计 ---"
awk '{sum += $10; count++} END {
    printf "  总流量: %.2f MB\n", sum / 1024 / 1024
    printf "  平均响应大小: %.0f 字节\n", sum / count
    printf "  最大响应: %d 字节\n", sum
}' "$LOG_FILE"
echo ""

# ============================================================
# 第三部分：生成分析报告
# ============================================================
echo "=========================================="
echo "第三部分: 生成分析报告文件"
echo "=========================================="
echo ""

REPORT_FILE="analysis_report.txt"

{
    echo "=============================================="
    echo "  Nginx 访问日志分析报告"
    echo "  分析时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "  日志文件: $LOG_FILE"
    echo "  日志行数: $TOTAL_LINES"
    echo "=============================================="
    echo ""

    echo "--- 状态码分布 ---"
    awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -rn
    echo ""

    echo "--- 访问量 TOP 10 IP ---"
    awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
    echo ""

    echo "--- 404 错误 ---"
    echo "404 总数: ${NOTFOUND_COUNT:-0}"
    if [ "${NOTFOUND_COUNT:-0}" -gt 0 ]; then
        echo ""
        echo "404 URL TOP 5:"
        awk '$9 == "404" {print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -5
    fi
    echo ""

    echo "--- User-Agent 统计 ---"
    awk -F'"' '{print $6}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
    echo ""

    echo "--- URL 访问量 TOP 10 ---"
    awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
    echo ""

    echo "--- 报告结束 ---"

} > "$REPORT_FILE"

echo "分析报告已生成: $REPORT_FILE"
echo ""

# ============================================================
# 第四部分：额外技巧展示
# ============================================================
echo "=========================================="
echo "第四部分: 额外技巧展示"
echo "=========================================="
echo ""

echo "--- 技巧1: 匿名化 IP (把 IP 前三段替换成 xxx) ---"
echo "原始:"
head -3 "$LOG_FILE"
echo "匿名化后:"
sed -E 's/([0-9]{1,3}\.){3}/xxx.xxx.xxx./' "$LOG_FILE" | head -3
echo ""

echo "--- 技巧2: 只统计 POST 请求 ---"
awk -F'"' '$2 ~ /^POST/ {print $1, $2}' "$LOG_FILE" | head -5
echo ""

echo "--- 技巧3: 统计不同 IP 的数量（独立访客数）---"
UNIQUE_IPS=$(awk '{print $1}' "$LOG_FILE" | sort -u | wc -l)
echo "独立 IP 数量: $UNIQUE_IPS"
echo ""

echo "--- 技巧4: 用 tee 边看边保存 ---"
echo "（这里只演示语法，不实际运行，因为输出较长）"
echo "  awk '{print \$1}' access.log | sort | uniq -c | sort -rn | tee ip_stats.txt"
echo ""

# ============================================================
# 收尾
# ============================================================
echo "=========================================="
echo "演示完成！"
echo "=========================================="
echo ""
echo "生成的文件："
ls -la "$DEMO_DIR"/*.log "$DEMO_DIR"/*.txt 2>/dev/null || echo "  (部分文件未生成)"
echo ""
echo "你可以查看:"
echo "  日志文件:    cat $DEMO_DIR/access.log"
echo "  分析报告:    cat $DEMO_DIR/analysis_report.txt"
echo ""
echo "清理命令:      rm -rf $DEMO_DIR"
echo "=========================================="
