#!/bin/bash
# ========================================
# 07-debug.sh — Shell 调试与错误处理
# ========================================
# 功能：演示 set 选项（-e -u -x -o pipefail）、
#       trap 信号捕获、日志输出、退出码
# 用法：./07-debug.sh [--strict] [--debug]
# ========================================

# --------------------------------------------------
# 根据参数决定是否启用严格模式
# --------------------------------------------------
STRICT_MODE=false
DEBUG_MODE=false

for arg in "$@"; do
    case "$arg" in
        --strict) STRICT_MODE=true ;;
        --debug)  DEBUG_MODE=true ;;
    esac
done

if $STRICT_MODE; then
    echo ">>> 启用严格模式 <<<"
    echo ""

    # ==========================================
    # 一、set -e：遇到错误立即退出
    # ==========================================
    echo "========================================="
    echo "  一、set -e -- 遇错即停"
    echo "========================================="

    set -e  # 任何命令返回非零退出码时，脚本立即停止

    echo "  这条命令会成功："
    ls /tmp > /dev/null 2>&1
    echo "  ls /tmp 成功，脚本继续"

    # 如果下面这行取消注释，脚本会在这里停止
    # echo "  下面是一个会失败的命令："
    # ls /nonexistent_dir    # 脚本会在此停止！
    # echo "  这句话永远不会被打印"

    echo "  set -e 演示完毕（未触发错误）"
    echo ""
fi

# --------------------------------------------------
# 二、set -u：使用未定义变量时报错
# --------------------------------------------------
echo "========================================="
echo "  二、set -u -- 未定义变量报错"
echo "========================================="

if $STRICT_MODE; then
    set -u

    defined_var="我存在"
    echo "  \$defined_var = $defined_var"

    # 如果取消下面注释，脚本会报错：
    # echo "  \$undefined_var = $undefined_var"
    # 错误信息：undefined_var: unbound variable

    echo "  （已跳过未定义变量的演示）"
else
    # 非严格模式下，未定义变量默认为空，不报错
    echo "  未定义变量（空）：${undefined_var:-<空值>}"
    echo "  这可能导致隐蔽的 bug！"
fi
echo ""

# --------------------------------------------------
# 三、set -x：打印每条执行的命令
# --------------------------------------------------
echo "========================================="
echo "  三、set -x -- 命令执行追踪"
echo "========================================="

if $DEBUG_MODE; then
    echo "  启用 set -x，以下命令会被追踪打印："
    set -x
fi

name="调试测试"
echo "  当前 name = $name"
result=$((3 + 5))
echo "  3 + 5 = $result"

if $DEBUG_MODE; then
    set +x  # 关闭追踪
    echo "  （set -x 已关闭）"
fi
echo ""

# --------------------------------------------------
# 四、set -o pipefail：管道中任何一个命令失败就失败
# --------------------------------------------------
echo "========================================="
echo "  四、set -o pipefail -- 管道错误检测"
echo "========================================="

# 没有 pipefail 时的默认行为：只看管道最后一个命令的退出码
echo "  普通模式下的管道："
false | true
echo "  'false | true' 的退出码：$?  （只看最后一个命令 true，所以是 0）"

if $STRICT_MODE; then
    set -o pipefail
    echo ""
    echo "  pipefail 模式下的管道："
    false | true
    echo "  'false | true' 的退出码：$?  （false 导致失败，所以非 0）"
fi
echo ""

# --------------------------------------------------
# 五、严格模式全集
# --------------------------------------------------
echo "========================================="
echo "  五、推荐的严格模式头部"
echo "========================================="

cat << 'EOF'
  推荐在每个脚本的开头加上：

  #!/bin/bash
  set -euo pipefail
  # -e: 遇错即停
  # -u: 未定义变量报错
  # -o pipefail: 管道任何一环失败即失败

  # 或者合并写法：
  set -euo pipefail
EOF

echo ""

# --------------------------------------------------
# 六、trap：信号捕获与清理
# --------------------------------------------------
echo "========================================="
echo "  六、trap -- 优雅的信号处理"
echo "========================================="

# 创建一个临时文件用于演示
tempfile="/tmp/debug_demo_$$.txt"
echo "Hello" > "$tempfile"
echo "  创建临时文件：$tempfile"

# trap 的格式：trap '命令' 信号
# EXIT 是脚本退出时触发的"信号"
# INT 是 Ctrl+C
# TERM 是 kill 发送的终止信号

# 注册清理函数：无论脚本正常退出还是被中断，都会执行
cleanup() {
    echo ""
    echo "  [trap] 正在清理临时文件..."
    rm -f "$tempfile"
    echo "  [trap] 临时文件已删除"
}

trap cleanup EXIT INT TERM

echo "  已注册 trap，脚本退出时会自动调用 cleanup"

# 演示：如果你按 Ctrl+C，trap 仍然会执行清理
echo "  尝试按 Ctrl+C 看看（然后重新运行）"
echo "  脚本将在 2 秒后正常退出..."
sleep 2
echo ""

# --------------------------------------------------
# 七、日志输出函数
# --------------------------------------------------
echo "========================================="
echo "  七、结构化日志输出"
echo "========================================="

# 带颜色和级别的日志函数
LOG_FILE="/tmp/script_$$.log"

# 颜色定义（在终端中显示彩色）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # 输出到终端（带颜色）
    case "$level" in
        INFO)
            echo -e "${GREEN}[$timestamp] [INFO]${NC} $message"
            ;;
        WARN)
            echo -e "${YELLOW}[$timestamp] [WARN]${NC} $message"
            ;;
        ERROR)
            echo -e "${RED}[$timestamp] [ERROR]${NC} $message" >&2
            ;;
    esac

    # 同时写入日志文件
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

log "INFO" "脚本开始执行"
log "INFO" "当前用户：$(whoami)"
log "INFO" "工作目录：$(pwd)"

# 模拟一些检查
if [ -d "/etc" ]; then
    log "INFO" "/etc 目录存在"
else
    log "ERROR" "/etc 目录不存在！"
fi

# 模拟一个警告
disk_usage=$(df / | awk 'NR==2 {print $5}')
log "WARN" "根分区使用率：$disk_usage"

echo "  日志已写入：$LOG_FILE"
echo ""

# --------------------------------------------------
# 八、退出码最佳实践
# --------------------------------------------------
echo "========================================="
echo "  八、退出码使用规范"
echo "========================================="

cat << 'EOF'
  退出码约定：
    0   - 成功
    1   - 一般错误
    2   - 参数/用法错误
    126 - 命令不可执行（权限问题）
    127 - 命令未找到
    128 - 无效的退出参数
    130 - 被 Ctrl+C 中断（128+2）

  脚本中应明确使用 exit 设置退出码：
    exit 0    # 一切正常
    exit 1    # 出了点问题
    exit 2    # 参数不对

  函数中应使用 return 设置退出码：
    return 0  # 成功
    return 1  # 失败
EOF

echo ""

# --------------------------------------------------
# 九、防御性编程示例
# --------------------------------------------------
echo "========================================="
echo "  九、防御性编程技巧"
echo "========================================="

echo "  (1) 命令执行前检查前提条件"
echo "  (2) 使用 \${var:?} 确保关键变量已设置"
echo "  (3) cd 或 mkdir 后检查是否成功"

# 示例：安全的目录操作
safe_mkdir() {
    local dir="$1"
    if [ -z "$dir" ]; then
        log "ERROR" "safe_mkdir 需要目录参数"
        return 1
    fi

    if mkdir -p "$dir"; then
        log "INFO" "目录创建成功：$dir"
        return 0
    else
        log "ERROR" "目录创建失败：$dir"
        return 1
    fi
}

safe_mkdir "/tmp/test_debug_demo_$$"
rmdir "/tmp/test_debug_demo_$$" 2>/dev/null

log "INFO" "脚本执行完毕"

exit 0
