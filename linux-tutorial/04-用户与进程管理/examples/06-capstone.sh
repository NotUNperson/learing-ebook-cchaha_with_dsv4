#!/bin/bash
# ============================================================
# 06-capstone.sh - 综合练习：创建自定义 systemd 服务
# 配套章节：04-06-综合练习.md
#
# 本脚本演示创建一个自定义 systemd 服务的完整流程：
#   1. 编写一个简单的 HTTP 服务器脚本
#   2. 为它创建 systemd unit 文件
#   3. 启动服务、设置开机自启
#   4. 用 journalctl 查看日志
#
# 功能：一个简单的文件下载计数器 HTTP 服务
#      它会响应 HTTP 请求，记录页面访问次数并持久化到文件
# ============================================================

set -e

SERVICE_NAME="linux-demo"
SERVICE_USER="${SUDO_USER:-$USER}"
INSTALL_DIR="/usr/local/bin"
SCRIPT_PATH="${INSTALL_DIR}/${SERVICE_NAME}.sh"
UNIT_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
DATA_DIR="/var/lib/${SERVICE_NAME}"

echo "============================================"
echo "  04-06 综合练习：创建自定义 systemd 服务"
echo "============================================"
echo ""

# 检查 root 权限
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：本脚本需要 root 权限运行。"
    echo "请使用：sudo bash $0"
    exit 1
fi

# -----------------------------------------------------------
# 第 1 步：创建服务脚本
# -----------------------------------------------------------
echo "【第 1 步】创建服务脚本：${SCRIPT_PATH}"
echo "  这个脚本启动一个简单的 HTTP 服务器（使用 nc 工具），"
echo "  监听 8080 端口，返回纯文本的访问统计信息。"
echo ""

cat > "${SCRIPT_PATH}" << 'SERVICE_SCRIPT'
#!/bin/bash
# ============================================================
# linux-demo.sh - Linux 学习用 demo HTTP 服务
# 功能：监听 8080 端口，返回访问统计
# ============================================================

PORT=8080
DATA_FILE="/var/lib/linux-demo/counter.txt"
LOG_FILE="/var/lib/linux-demo/server.log"

# 确保数据目录存在
mkdir -p "$(dirname "$DATA_FILE")"

# 初始化计数器
if [ ! -f "$DATA_FILE" ]; then
    echo "0" > "$DATA_FILE"
fi

# 记录启动时间到日志
echo "$(date '+%Y-%m-%d %H:%M:%S') - 服务启动，PID=$$" >> "$LOG_FILE"

# -------------------- 信号处理 --------------------
# 优雅退出：收到 SIGTERM 时保存数据并退出
cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 收到终止信号，正在退出..." >> "$LOG_FILE"
    exit 0
}
trap cleanup SIGTERM SIGINT

# -------------------- HTTP 响应函数 --------------------
handle_request() {
    # 读取 HTTP 请求（第一行）
    read -r request_line

    # 增加计数器
    local count
    count=$(cat "$DATA_FILE")
    count=$((count + 1))
    echo "$count" > "$DATA_FILE"

    # 获取当前时间
    local now
    now=$(date '+%Y-%m-%d %H:%M:%S')

    # 获取主机名
    local hostname_val
    hostname_val=$(hostname)

    # 构造 HTTP 响应
    local body
    body=$(cat <<EOF
<html>
<head><title>Linux Demo Service</title></head>
<body>
<h1>Linux Demo HTTP 服务</h1>
<p>你好！这是一个通过 systemd 管理的演示服务。</p>
<p>当前时间：${now}</p>
<p>服务器主机名：${hostname_val}</p>
<p>服务已处理的请求数：<strong>${count}</strong></p>
<hr>
<p><small>PID: $$ | 用户: $(whoami) | 服务名: linux-demo</small></p>
</body>
</html>
EOF
)

    local body_len
    body_len=$(echo -n "$body" | wc -c)

    # 输出 HTTP 响应
    printf "HTTP/1.1 200 OK\r\n"
    printf "Content-Type: text/html; charset=utf-8\r\n"
    printf "Content-Length: %s\r\n" "$body_len"
    printf "Connection: close\r\n"
    printf "\r\n"
    printf "%s" "$body"

    # 记录到日志
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 请求来自 ${request_line} (第${count}次访问)" >> "$LOG_FILE"
}

# -------------------- 主循环 --------------------
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始监听端口 ${PORT}..." >> "$LOG_FILE"

while true; do
    # 使用 nc (netcat) 监听端口，每个连接处理一次请求
    # -l: 监听模式  -p: 端口  -q 0: 传输完成后立即关闭连接
    # -c: 使用指定命令处理每个连接（某些 nc 版本可能不支持 -c）
    # 为了兼容性，这里使用 while 循环配合 nc
    nc -l -p "${PORT}" -q 0 -c 'bash -c "read -r line; echo \"\$line\""' 2>/dev/null || \
    nc -l -p "${PORT}" -q 0 -e /bin/bash -c "$(declare -f handle_request); handle_request" 2>/dev/null || \
    {
        # 如果上面两种方式都不支持，降级为简单方式
        echo "$(date '+%Y-%m-%d %H:%M:%S') - nc 不支持 -c/-e，使用简单回显模式" >> "$LOG_FILE"
        (
            handle_request
        )
    }
    sleep 0.5
done
SERVICE_SCRIPT

chmod +x "${SCRIPT_PATH}"
echo "  服务脚本已创建并设置为可执行。"
echo ""

# -----------------------------------------------------------
# 第 2 步：创建数据和日志目录
# -----------------------------------------------------------
echo "【第 2 步】创建数据目录：${DATA_DIR}"
mkdir -p "${DATA_DIR}"
# 设置权限，让服务用户能读写
chown "${SERVICE_USER}:${SERVICE_USER}" "${DATA_DIR}" 2>/dev/null || true
echo ""

# -----------------------------------------------------------
# 第 3 步：创建 systemd unit 文件
# -----------------------------------------------------------
echo "【第 3 步】创建 systemd unit 文件：${UNIT_FILE}"

cat > "${UNIT_FILE}" << UNITEOF
[Unit]
Description=Linux 学习用 Demo HTTP 服务
Documentation=https://example.com/docs
After=network.target

[Service]
Type=simple
ExecStart=${SCRIPT_PATH}
ExecStop=/bin/kill -SIGTERM \$MAINPID
Restart=on-failure
RestartSec=5

# 安全加固（可选）
User=${SERVICE_USER}
Group=${SERVICE_USER}
WorkingDirectory=${DATA_DIR}

# 限制资源使用
MemoryMax=50M
CPUQuota=20%

# 日志会自动进入 journal
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNITEOF

echo "  Unit 文件已创建。"
echo ""
echo "  关键配置解读："
echo "    After=network.target     -- 等网络就绪后再启动"
echo "    Type=simple              -- 简单类型，ExecStart 启动的就是主进程"
echo "    Restart=on-failure       -- 异常退出时自动重启"
echo "    RestartSec=5             -- 重启前等 5 秒"
echo "    MemoryMax=50M            -- 限制最多用 50MB 内存"
echo "    CPUQuota=20%             -- 限制最多用 20% CPU"
echo "    StandardOutput=journal   -- 标准输出送到 systemd 日志"
echo ""

# -----------------------------------------------------------
# 第 4 步：重新加载 systemd 配置
# -----------------------------------------------------------
echo "【第 4 步】重新加载 systemd 配置"
systemctl daemon-reload
echo "  daemon-reload 完成。"
echo ""

# -----------------------------------------------------------
# 第 5 步：启动服务
# -----------------------------------------------------------
echo "【第 5 步】启动服务"
systemctl start "${SERVICE_NAME}"
sleep 2

if systemctl is-active --quiet "${SERVICE_NAME}"; then
    echo "  服务 ${SERVICE_NAME} 启动成功！"
else
    echo "  服务 ${SERVICE_NAME} 启动可能失败，请检查状态。"
fi
echo ""

# -----------------------------------------------------------
# 第 6 步：查看服务状态
# -----------------------------------------------------------
echo "【第 6 步】查看服务状态"
systemctl status "${SERVICE_NAME}" --no-pager -l
echo ""

# -----------------------------------------------------------
# 第 7 步：设置开机自启
# -----------------------------------------------------------
echo "【第 7 步】设置开机自启"
systemctl enable "${SERVICE_NAME}"
echo "  开机自启已设置。"
echo ""

# -----------------------------------------------------------
# 第 8 步：测试服务
# -----------------------------------------------------------
echo "【第 8 步】测试 HTTP 服务"
echo "  尝试访问 http://localhost:8080 ..."
echo ""

# 用 curl 测试（如果安装了的话）
if command -v curl &>/dev/null; then
    echo "  curl 测试结果："
    echo "  ----------------------------------------"
    curl -s http://localhost:8080 2>/dev/null || echo "  （连接失败，可能需要手动测试）"
    echo ""
    echo "  ----------------------------------------"
else
    echo "  curl 未安装，你可以手动用浏览器访问 http://localhost:8080"
    echo "  或者安装 curl: sudo apt install curl"
fi
echo ""

# -----------------------------------------------------------
# 第 9 步：查看日志
# -----------------------------------------------------------
echo "【第 9 步】查看服务日志"
journalctl -u "${SERVICE_NAME}" --no-pager -n 15
echo ""

# -----------------------------------------------------------
# 第 10 步：使用总结
# -----------------------------------------------------------
echo "============================================"
echo "  综合练习完成！下面是本服务的常用操作："
echo ""
echo "  查看状态："
echo "    systemctl status ${SERVICE_NAME}"
echo ""
echo "  查看日志（实时）："
echo "    journalctl -u ${SERVICE_NAME} -f"
echo ""
echo "  停止服务："
echo "    systemctl stop ${SERVICE_NAME}"
echo ""
echo "  重启服务："
echo "    systemctl restart ${SERVICE_NAME}"
echo ""
echo "  禁用开机自启："
echo "    systemctl disable ${SERVICE_NAME}"
echo ""
echo "  删除服务（彻底清理）："
echo "    systemctl stop ${SERVICE_NAME}"
echo "    systemctl disable ${SERVICE_NAME}"
echo "    rm ${UNIT_FILE}"
echo "    rm ${SCRIPT_PATH}"
echo "    rm -rf ${DATA_DIR}"
echo "    systemctl daemon-reload"
echo ""
echo "  文件位置："
echo "    服务脚本：${SCRIPT_PATH}"
echo "    Unit 文件：${UNIT_FILE}"
echo "    数据目录：${DATA_DIR}"
echo "============================================"
