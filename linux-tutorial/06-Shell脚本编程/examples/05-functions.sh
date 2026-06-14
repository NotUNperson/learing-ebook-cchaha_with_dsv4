#!/bin/bash
# ========================================
# 05-functions.sh — Shell 函数
# ========================================
# 功能：演示函数的定义、调用、参数、返回值、
#        local 局部变量及函数库的引入
# 用法：./05-functions.sh
# ========================================

# --------------------------------------------------
# 一、定义和调用函数
# --------------------------------------------------
echo "========================================="
echo "  一、函数的定义和调用"
echo "========================================="

# 定义函数（两种写法效果相同）

# 写法一：function 关键字（类似 JavaScript）
function say_hello {
    echo "你好，$1！"
}

# 写法二：函数名+括号（更常见、更简洁）
greet() {
    echo "欢迎你，$1！"
    echo "今天是 $(date +%Y-%m-%d)"
}

# 调用函数：直接写函数名，后面跟参数（不用括号）
say_hello "小明"
echo ""
greet "小红"

# --------------------------------------------------
# 二、函数参数：$1 $2 $@ 在函数内部
# --------------------------------------------------
echo ""
echo "========================================="
echo "  二、函数参数"
echo "========================================="

# 函数内部的 $1 $2 和脚本的 $1 $2 是不同的！
# 函数内部的 $1 是传给函数的第一个参数

show_info() {
    echo "  函数名：${FUNCNAME[0]}"
    echo "  第1个参数：$1"
    echo "  第2个参数：$2"
    echo "  所有参数：$@"
    echo "  参数个数：$#"
}

show_info "苹果" "香蕉" "橘子"

# 注意区分：$0 永远是脚本名，不是函数名
echo ""
echo "  脚本名 \$0：$0"

# --------------------------------------------------
# 三、返回值：return vs echo
# --------------------------------------------------
echo ""
echo "========================================="
echo "  三、返回值机制"
echo "========================================="

# 方式一：return — 返回退出码（0-255 的整数）
is_even() {
    if (( $1 % 2 == 0 )); then
        return 0    # 0 表示"是"（成功）
    else
        return 1    # 非 0 表示"否"（失败）
    fi
}

number=42
if is_even "$number"; then
    echo "  $number 是偶数（通过 return 码判断）"
else
    echo "  $number 是奇数（通过 return 码判断）"
fi

# 方式二：echo — 返回任意数据（字符串、多个值等）
add() {
    local result=$(( $1 + $2 ))
    echo "$result"     # echo 的内容可以被外面捕获
}

sum=$(add 15 27)
echo "  15 + 27 = $sum"

# 进阶：返回多个值（用空格分隔）
get_system_info() {
    echo "$(hostname) $(whoami) $(date +%Y-%m-%d)"
}

info=$(get_system_info)
read -r hostname current_user today <<< "$info"
echo "  主机：$hostname，用户：$current_user，日期：$today"

# --------------------------------------------------
# 四、局部变量 local
# --------------------------------------------------
echo ""
echo "========================================="
echo "  四、局部变量 local"
echo "========================================="

global_name="全局变量"
echo "  函数外全局变量：$global_name"

test_local() {
    local local_name="我是 local 变量"   # local 关键字
    global_name="我修改了全局变量"        # 没有 local，会修改全局的
    echo "  函数内 local 变量：$local_name"
}
test_local

echo "  回到函数外："
echo "    全局变量 global_name：$global_name"
echo "    局部变量 local_name：${local_name:-<不可访问>}"

# --------------------------------------------------
# 五、函数库：把函数放在独立文件里
# --------------------------------------------------
echo ""
echo "========================================="
echo "  五、函数库导入"
echo "========================================="

# 假设我们有一个 lib-utils.sh 文件，里面写了一些工具函数
LIB_FILE="${0%/*}/lib-utils.sh"

if [ -f "$LIB_FILE" ]; then
    # source 或 . 都可以导入文件
    source "$LIB_FILE"
    echo "  已加载函数库：$LIB_FILE"
else
    echo "  函数库 lib-utils.sh 不存在，跳过导入（这是预期的）"
    echo "  实际使用时可以创建它："
    echo "    # lib-utils.sh"
    echo "    log() { echo \"[\$(date)] \$1\"; }"
    echo "    check_root() { [ \$EUID -eq 0 ]; }"
fi

# --------------------------------------------------
# 六、实战：综合函数示例
# --------------------------------------------------
echo ""
echo "========================================="
echo "  六、综合示例：日志管理工具"
echo "========================================="

# 日志输出函数（带时间戳）
log() {
    local level="${1:-INFO}"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message"
}

# 检查目录是否存在，不存在则创建
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log "INFO" "创建目录：$dir"
    else
        log "INFO" "目录已存在：$dir"
    fi
}

# 检查磁盘使用率
check_disk() {
    local threshold="${1:-80}"   # 默认阈值 80%
    local mount_point="${2:-/}"
    local usage
    usage=$(df -h "$mount_point" | awk 'NR==2 {print $5}' | tr -d '%')

    if [ "$usage" -gt "$threshold" ]; then
        log "WARNING" "磁盘使用率 ${usage}% 超过阈值 ${threshold}%"
        return 1
    else
        log "INFO" "磁盘使用率 ${usage}%，正常"
        return 0
    fi
}

# 使用这些函数
log "INFO" "开始系统检查..."

ensure_dir "/tmp/test_func_$$"

check_disk 90 "/"
echo "  磁盘检查退出码：$?"

log "INFO" "系统检查完成"

# 清理
rmdir "/tmp/test_func_$$" 2>/dev/null

# --------------------------------------------------
# 七、函数参数的默认值技巧
# --------------------------------------------------
echo ""
echo "========================================="
echo "  七、参数默认值"
echo "========================================="

# 使用 ${参数:-默认值} 给函数参数设置默认值
backup() {
    local source="${1:-/var/www}"
    local dest="${2:-/backup}"
    local keep_days="${3:-7}"

    echo "  备份源：$source"
    echo "  备份目标：$dest"
    echo "  保留天数：$keep_days"
}

backup                           # 全部使用默认值
echo "  ---"
backup "/home/user/data"         # 指定一个参数
echo "  ---"
backup "/opt/app" "/mnt/backup"  # 指定两个参数

echo ""
echo "========================================="
echo "  函数设计原则"
echo "========================================="
echo "  1. 一个函数只做一件事"
echo "  2. 函数名用动词开头，见名知意（如 check_disk）"
echo "  3. 使用 local 避免污染全局变量"
echo "  4. return 返回退出码，echo 返回数据"
echo "  5. 关键参数提供合理的默认值"

exit 0
