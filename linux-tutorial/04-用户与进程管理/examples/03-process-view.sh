#!/bin/bash
# ============================================================
# 03-process-view.sh - 进程查看示例脚本
# 配套章节：04-03-进程查看.md
# ============================================================

echo "============================================"
echo "  04-03 进程查看 示例"
echo "============================================"
echo ""

# -----------------------------------------------------------
# 一、理解进程：查看当前 Shell 的 PID
# -----------------------------------------------------------
echo "--- 1. 当前 Shell 的进程信息 ---"
echo "当前 Shell 的 PID（进程ID）：$$"
echo "当前 Shell 的父进程 PID（PPID）：$PPID"
echo ""
echo "类比：每个进程有一个"身份证号"（PID），"
echo "它的"父进程"（PPID）是启动它的那个进程。"
echo ""

# -----------------------------------------------------------
# 二、ps aux -- 快照式进程列表
# -----------------------------------------------------------
echo "--- 2. ps aux -- 查看所有进程 ---"
echo "各列含义："
echo "  USER   - 进程属于哪个用户"
echo "  PID    - 进程ID（独一无二的身份证号）"
echo "  %CPU   - CPU 使用百分比"
echo "  %MEM   - 内存使用百分比"
echo "  VSZ    - 虚拟内存大小（KB）"
echo "  RSS    - 实际物理内存大小（KB）"
echo "  TTY    - 关联的终端（? 表示无终端，后台服务）"
echo "  STAT   - 进程状态（R运行 S睡眠 Z僵尸 T停止）"
echo "  START  - 进程启动时间"
echo "  TIME   - 累计使用 CPU 的时间"
echo "  COMMAND - 命令行（含参数）"
echo ""

echo "演示：查看占用内存最多的前 5 个进程："
ps aux --sort=-%mem | head -6
echo ""

echo "演示：查看 CPU 占用最高的前 5 个进程："
ps aux --sort=-%cpu | head -6
echo ""

# -----------------------------------------------------------
# 三、常用 ps 组合技
# -----------------------------------------------------------
echo "--- 3. ps 常用组合 ---"

echo "查看所有进程（BSD 风格）：ps aux"
echo "查看所有进程（Unix 风格）：ps -ef"
echo "查看某个用户的进程：ps -u 用户名"
echo "查看某个程序的进程：ps aux | grep nginx"
echo "查看进程树：ps -ejH"
echo "显示线程：ps -eLf"
echo "自定义输出列：ps -eo pid,ppid,user,cmd,%cpu,%mem --sort=-%cpu | head"
echo ""

echo "演示：自定义输出列（PID, PPID, USER, CMD, %CPU, %MEM）"
ps -eo pid,ppid,user,cmd,%cpu,%mem --sort=-%cpu | head -8
echo ""

# -----------------------------------------------------------
# 四、进程状态详解
# -----------------------------------------------------------
echo "--- 4. 进程状态代码 ---"
echo "  R (Running)        - 正在运行或等待运行"
echo "  S (Sleeping)       - 可中断睡眠（等待某个事件）"
echo "  D (Disk sleep)     - 不可中断睡眠（通常等待 I/O，无法被 kill）"
echo "  Z (Zombie)         - 僵尸进程（已结束但父进程未回收）"
echo "  T (Stopped)        - 被暂停的进程（收到 SIGSTOP）"
echo ""
echo "附加标志："
echo "  <  - 高优先级"
echo "  N  - 低优先级"
echo "  L  - 有页面锁在内存中"
echo "  s  - 会话领导者"
echo "  l  - 多线程"
echo "  +  - 前台进程组"
echo ""

# -----------------------------------------------------------
# 五、pgrep -- 按名字查找进程
# -----------------------------------------------------------
echo "--- 5. pgrep -- 按进程名查找 ---"
echo "pgrep 比 ps aux | grep 更简洁："
echo ""

echo "查找所有名称中含 bash 的进程 PID："
pgrep -a bash 2>/dev/null || echo "（未找到）"
echo ""

echo "查找属于当前用户的 ssh 进程："
pgrep -u "$(whoami)" -a ssh 2>/dev/null || echo "（未找到）"
echo ""

# -----------------------------------------------------------
# 六、pstree -- 进程树
# -----------------------------------------------------------
echo "--- 6. pstree -- 查看进程的父子关系 ---"
echo "Linux 的第一个进程是 systemd（PID=1），"
echo "其他所有进程都是它的后代。"
echo ""

echo "查看当前 Shell 的进程树（向上追溯到 systemd）："
if command -v pstree &>/dev/null; then
    # 显示当前进程的祖先链
    PID="$$"
    echo -n "进程树（PID=$$）："
    while [ "$PID" -ne 1 ]; do
        CMD=$(ps -p "$PID" -o comm= 2>/dev/null)
        echo -n " $CMD($PID) <-"
        PID=$(ps -p "$PID" -o ppid= 2>/dev/null | tr -d ' ')
        [ -z "$PID" ] && break
    done
    echo " systemd(1)"
    echo ""
else
    echo "pstree 未安装，可以用 sudo apt install pstree 安装。"
    echo ""
fi

# -----------------------------------------------------------
# 七、top 命令说明（交互式，此处仅做介绍）
# -----------------------------------------------------------
echo "--- 7. top 命令 ---"
echo "top 是实时更新的进程查看器，就像 Windows 的任务管理器。"
echo "运行：top"
echo ""
echo "常用交互按键："
echo "  q      - 退出"
echo "  h      - 帮助"
echo "  1      - 切换显示每个 CPU 核的使用率"
echo "  M      - 按内存使用排序"
echo "  P      - 按 CPU 使用排序"
echo "  k      - 杀掉一个进程（会提示输入 PID）"
echo "  u      - 只看某个用户的进程"
echo "  f      - 选择要显示的列"
echo "  c      - 切换完整命令行显示"
echo ""

# -----------------------------------------------------------
# 八、htop 说明
# -----------------------------------------------------------
echo "--- 8. htop 命令 ---"
echo "htop 是 top 的升级版，界面更友好，支持鼠标操作。"
echo "运行：htop"
echo ""
if command -v htop &>/dev/null; then
    echo "htop 已安装。"
else
    echo "htop 未安装。安装方法："
    echo "  sudo apt install htop    # Debian/Ubuntu"
    echo "  sudo yum install htop    # CentOS/RHEL"
    echo "  sudo dnf install htop    # Fedora"
fi
echo ""

# -----------------------------------------------------------
# 九、/proc 文件系统
# -----------------------------------------------------------
echo "--- 9. /proc 虚拟文件系统 ---"
echo "/proc 不占磁盘空间，它是内核在内存中虚拟出来的文件系统，"
echo "用来暴露进程和系统信息。每个进程在 /proc 下有一个目录，"
echo "目录名就是 PID。"
echo ""

echo "查看当前 Shell 进程的信息："
echo "  /proc/$$/cmdline   - 启动命令"
echo "  /proc/$$/status    - 进程状态"
echo "  /proc/$$/environ   - 环境变量"
echo "  /proc/$$/fd/       - 打开的文件描述符"
echo ""

echo "演示：查看当前进程的命令行："
cat "/proc/$$/cmdline" 2>/dev/null | tr '\0' ' ' && echo ""
echo ""

echo "演示：查看当前进程的内存占用："
grep -E "VmRSS|VmSize" "/proc/$$/status" 2>/dev/null
echo ""

echo "演示：查看系统 CPU 信息："
head -5 /proc/cpuinfo 2>/dev/null
echo ""

echo "============================================"
echo "  示例脚本执行完毕"
echo "============================================"
