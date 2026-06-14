#!/bin/bash
# ============================================================
# 05-systemd.sh - systemd 服务管理示例脚本
# 配套章节：04-05-systemd服务管理.md
# ============================================================

echo "============================================"
echo "  04-05 systemd 服务管理 示例"
echo "============================================"
echo ""

# -----------------------------------------------------------
# 一、systemd 简介
# -----------------------------------------------------------
echo "--- 1. systemd 简介 ---"
echo "systemd 是 Linux 的初始化系统和服务管理器。"
echo "PID=1 的进程就是 systemd，它是所有进程的祖先。"
echo ""
if [ -d /run/systemd/system ]; then
    echo "当前系统使用 systemd。"
else
    echo "当前系统可能没有使用 systemd。"
fi
echo ""

# -----------------------------------------------------------
# 二、systemctl 基本命令速查
# -----------------------------------------------------------
echo "--- 2. systemctl 常用命令速查 ---"
echo ""
echo "查看服务状态："
echo "  systemctl status <服务名>"
echo "  systemctl is-active <服务名>     -- 检查服务是否在运行"
echo "  systemctl is-enabled <服务名>    -- 检查服务是否开机自启"
echo "  systemctl is-failed <服务名>     -- 检查服务是否启动失败"
echo ""
echo "启停服务："
echo "  systemctl start <服务名>         -- 启动服务"
echo "  systemctl stop <服务名>          -- 停止服务"
echo "  systemctl restart <服务名>       -- 重启服务"
echo "  systemctl reload <服务名>        -- 重新加载配置（不中断服务）"
echo "  systemctl try-restart <服务名>   -- 只在服务运行时才重启"
echo ""
echo "开机自启管理："
echo "  systemctl enable <服务名>        -- 设置开机自启"
echo "  systemctl disable <服务名>       -- 取消开机自启"
echo "  systemctl reenable <服务名>      -- 重新建立开机自启的符号链接"
echo ""
echo "查看服务列表："
echo "  systemctl list-units --type=service            -- 所有已加载的 service 单元"
echo "  systemctl list-units --type=service --state=running  -- 正在运行的 service"
echo "  systemctl list-unit-files --type=service       -- 查看所有服务的启用状态"
echo "  systemctl list-units --failed                  -- 查看启动失败的服务"
echo ""

# -----------------------------------------------------------
# 三、查看常见服务的状态
# -----------------------------------------------------------
echo "--- 3. 查看当前系统服务状态 ---"

check_service() {
    local svc="$1"
    if systemctl status "$svc" &>/dev/null; then
        local active=$(systemctl is-active "$svc" 2>/dev/null)
        local enabled=$(systemctl is-enabled "$svc" 2>/dev/null)
        printf "  %-20s  active=%s  enabled=%s\n" "$svc" "$active" "$enabled"
    else
        printf "  %-20s  (未安装)\n" "$svc"
    fi
}

echo "常见服务的状态："
check_service "sshd"
check_service "nginx"
# 在旧版 systemd 中 ssh 服务可能叫 ssh 而不是 sshd
check_service "ssh"
check_service "cron"
check_service "cronie"
check_service "systemd-journald"
echo ""

# -----------------------------------------------------------
# 四、systemctl status 输出详解
# -----------------------------------------------------------
echo "--- 4. systemctl status 输出解读 ---"
echo "以 sshd 为例（如果存在）："
if systemctl status sshd &>/dev/null; then
    systemctl status sshd --no-pager -l 2>/dev/null | head -15
    echo ""
    echo "关键信息解读："
    echo "  Loaded: 服务配置文件路径，是否开机自启"
    echo "  Active: 当前状态（active-running / inactive / failed）"
    echo "  Docs:   相关文档链接"
    echo "  Main PID: 主进程的 PID"
    echo "  Tasks: 该服务有多少个任务/线程"
    echo "  Memory: 该服务占用的内存"
    echo "  CGroup: 该服务在 cgroup 层级中的位置"
else
    echo "  sshd 服务未安装或未找到。"
fi
echo ""

# -----------------------------------------------------------
# 五、日志查看 journalctl
# -----------------------------------------------------------
echo "--- 5. journalctl -- systemd 日志查看器 ---"
echo "journalctl 用来查看 systemd 的日志（二进制格式，比文本日志高效）。"
echo ""
echo "常用命令："
echo "  journalctl                      -- 查看所有日志（从旧到新）"
echo "  journalctl -r                   -- 查看所有日志（从新到旧）"
echo "  journalctl -f                   -- 实时跟踪日志（类似 tail -f）"
echo "  journalctl -u <服务名>           -- 查看某个服务的日志"
echo "  journalctl -u nginx -f           -- 实时跟踪 nginx 日志"
echo "  journalctl --since '1 hour ago'  -- 最近 1 小时的日志"
echo "  journalctl --since '2026-05-15' --until '2026-05-15 12:00'"
echo "  journalctl -k                    -- 只看内核日志（dmesg）"
echo "  journalctl -p err                -- 只看错误级别及以上的日志"
echo "  journalctl _UID=1000             -- 只看某个 UID 的日志"
echo "  journalctl --disk-usage          -- 查看日志占用的磁盘空间"
echo ""
echo "日志级别（从低到高）："
echo "  emerg(0) alert(1) crit(2) err(3) warning(4) notice(5) info(6) debug(7)"
echo ""

echo "演示：查看最近的系统日志（最后 10 条）："
journalctl --no-pager -n 10 2>/dev/null | head -10 || echo "（需要 sudo 权限或用户属于 systemd-journal 组）"
echo ""

# -----------------------------------------------------------
# 六、systemctl 高级操作
# -----------------------------------------------------------
echo "--- 6. systemctl 高级操作 ---"

echo "屏蔽服务（防止被手动或依赖启动）："
echo "  systemctl mask <服务名>     -- 将服务链接到 /dev/null，完全阻止启动"
echo "  systemctl unmask <服务名>   -- 取消屏蔽"
echo ""

echo "编辑服务文件："
echo "  systemctl edit <服务名>     -- 创建 override 文件（推荐方式）"
echo "  systemctl edit --full <服务名>  -- 直接编辑完整 unit 文件"
echo "  systemctl cat <服务名>      -- 查看服务的 unit 文件内容"
echo "  systemctl daemon-reload     -- 修改 unit 文件后必须执行，重新加载配置"
echo ""

echo "查看依赖关系："
echo "  systemctl list-dependencies <服务名>       -- 查看服务依赖了谁"
echo "  systemctl list-dependencies --reverse <服务名>  -- 查看谁依赖了这个服务"
echo ""

# -----------------------------------------------------------
# 七、unit 文件的位置
# -----------------------------------------------------------
echo "--- 7. systemd unit 文件存放位置 ---"
echo "/usr/lib/systemd/system/   -- 系统包安装的 unit 文件（不要直接改）"
echo "/etc/systemd/system/       -- 管理员自定义的 unit 文件（优先级最高）"
echo "/etc/systemd/system/xxx.service.d/ -- override 配置目录"
echo ""

echo "查看系统中所有 unit 文件所在目录："
systemctl show --property=UnitPath 2>/dev/null || true
echo ""

# -----------------------------------------------------------
# 八、journalctl 日志持久化
# -----------------------------------------------------------
echo "--- 8. 日志持久化配置 ---"
echo "默认情况下 systemd 日志存在内存（/run/log/journal），重启后丢失。"
echo ""
echo "若需要持久化（重启后仍然能查看历史日志）："
echo "  1. sudo mkdir -p /var/log/journal"
echo "  2. sudo systemd-tmpfiles --create --prefix /var/log/journal"
echo "  3. sudo systemctl restart systemd-journald"
echo ""
echo "配置日志最大占用空间："
echo "  编辑 /etc/systemd/journald.conf"
echo "  设置 SystemMaxUse=500M"
echo "  sudo systemctl restart systemd-journald"
echo ""

echo "============================================"
echo "  示例脚本执行完毕"
echo "============================================"
