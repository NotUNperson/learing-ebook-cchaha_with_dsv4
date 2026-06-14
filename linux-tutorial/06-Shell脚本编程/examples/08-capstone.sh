#!/bin/bash
# ========================================
# 08-capstone.sh — 综合练习：备份脚本
# ========================================
# 功能：将指定目录打包备份，支持：
#   - 命令行参数解析（源目录、目标目录、保留天数）
#   - 目录存在性检查
#   - tar.gz 打包 + 日期命名
#   - 错误处理与日志记录
#   - 旧备份自动清理
# 用法：
#   ./08-capstone.sh -s /path/to/source -d /path/to/backup -k 7
#   ./08-capstone.sh -h  (查看帮助)
# ========================================

set -euo pipefail

# --------------------------------------------------
# 全局配置
# --------------------------------------------------
SCRIPT_NAME=$(basename "$0")
LOG_DIR="/tmp/backup_logs"
LOG_FILE="${LOG_DIR}/backup_$(date +%Y%m%d).log"
BACKUP_PREFIX="backup"
DATE_STAMP=$(date +%Y%m%d_%H%M%S)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 默认值
SOURCE_DIR=""
DEST_DIR=""
KEEP_DAYS=7

# --------------------------------------------------
# 函数：日志输出
# --------------------------------------------------
log() {
    local level="$1"
    local message="$2"

    # 确保日志目录存在
    mkdir -p "$LOG_DIR" 2>/dev/null || true

    case "$level" in
        INFO)  echo -e "[${TIMESTAMP}] [INFO]  $message" | tee -a "$LOG_FILE" ;;
        WARN)  echo -e "[${TIMESTAMP}] [WARN]  $message" | tee -a "$LOG_FILE" >&2 ;;
        ERROR) echo -e "[${TIMESTAMP}] [ERROR] $message" | tee -a "$LOG_FILE" >&2 ;;
    esac
}

# --------------------------------------------------
# 函数：清理函数（trap 触发）
# --------------------------------------------------
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR" "脚本异常退出，退出码：$exit_code"
    fi
    log "INFO" "备份脚本结束"
    log "INFO" "日志文件：$LOG_FILE"
    echo "============================================" >> "$LOG_FILE"
}

trap cleanup EXIT INT TERM

# --------------------------------------------------
# 函数：显示帮助信息
# --------------------------------------------------
show_help() {
    cat << EOF
用法：$SCRIPT_NAME [选项]

选项：
  -s <目录>   源目录（要备份的目录）
  -d <目录>   目标目录（备份文件存放位置）
  -k <天数>   保留最近几天的备份（默认：7 天）
  -h          显示此帮助信息

示例：
  $SCRIPT_NAME -s /var/www -d /backup -k 7
  $SCRIPT_NAME -s /home/user/data -d /mnt/backups

说明：
  1. 源目录会被打包为 .tar.gz 文件
  2. 文件名格式：backup_目录名_日期时间.tar.gz
  3. 超过保留天数的旧备份会被自动删除
  4. 日志保存在 ${LOG_DIR}/ 目录
EOF
}

# --------------------------------------------------
# 函数：解析命令行参数
# --------------------------------------------------
parse_args() {
    while getopts "s:d:k:h" opt; do
        case "$opt" in
            s) SOURCE_DIR="$OPTARG" ;;
            d) DEST_DIR="$OPTARG" ;;
            k) KEEP_DAYS="$OPTARG" ;;
            h) show_help; exit 0 ;;
            ?) show_help; exit 2 ;;
        esac
    done

    # 参数验证
    if [ -z "$SOURCE_DIR" ]; then
        log "ERROR" "未指定源目录（-s）"
        show_help
        exit 2
    fi

    if [ -z "$DEST_DIR" ]; then
        log "ERROR" "未指定目标目录（-d）"
        show_help
        exit 2
    fi

    # 验证保留天数是正整数
    if ! [[ "$KEEP_DAYS" =~ ^[0-9]+$ ]]; then
        log "ERROR" "保留天数必须是正整数：$KEEP_DAYS"
        exit 2
    fi
}

# --------------------------------------------------
# 函数：检查源目录
# --------------------------------------------------
check_source() {
    log "INFO" "检查源目录：$SOURCE_DIR"

    if [ ! -e "$SOURCE_DIR" ]; then
        log "ERROR" "源目录不存在：$SOURCE_DIR"
        exit 1
    fi

    if [ ! -d "$SOURCE_DIR" ]; then
        log "ERROR" "源路径不是目录：$SOURCE_DIR"
        exit 1
    fi

    if [ ! -r "$SOURCE_DIR" ]; then
        log "ERROR" "源目录不可读：$SOURCE_DIR"
        exit 1
    fi

    # 获取源目录大小
    local size
    size=$(du -sh "$SOURCE_DIR" 2>/dev/null | cut -f1)
    log "INFO" "源目录大小：$size"

    # 统计文件数量
    local file_count
    file_count=$(find "$SOURCE_DIR" -type f 2>/dev/null | wc -l)
    log "INFO" "源目录包含 $file_count 个文件"
}

# --------------------------------------------------
# 函数：准备目标目录
# --------------------------------------------------
prepare_dest() {
    log "INFO" "检查目标目录：$DEST_DIR"

    if [ ! -d "$DEST_DIR" ]; then
        log "INFO" "目标目录不存在，尝试创建..."
        if ! mkdir -p "$DEST_DIR"; then
            log "ERROR" "无法创建目标目录：$DEST_DIR"
            exit 1
        fi
        log "INFO" "目标目录创建成功"
    fi

    if [ ! -w "$DEST_DIR" ]; then
        log "ERROR" "目标目录不可写：$DEST_DIR"
        exit 1
    fi

    # 获取目标目录可用空间
    local available
    available=$(df -h "$DEST_DIR" | awk 'NR==2 {print $4}')
    log "INFO" "目标目录可用空间：$available"
}

# --------------------------------------------------
# 函数：执行备份
# --------------------------------------------------
do_backup() {
    # 生成备份文件名
    local dir_basename
    dir_basename=$(basename "$SOURCE_DIR")
    local backup_file="${DEST_DIR}/${BACKUP_PREFIX}_${dir_basename}_${DATE_STAMP}.tar.gz"

    log "INFO" "开始打包备份..."
    log "INFO" "备份文件：$backup_file"

    # 使用 tar 打包压缩
    # -c: 创建归档
    # -z: gzip 压缩
    # -f: 指定文件名
    # -C: 切换到指定目录（让归档中的路径是相对路径）
    local tar_start
    tar_start=$(date +%s)

    if tar -czf "$backup_file" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>&1; then
        local tar_end
        tar_end=$(date +%s)
        local elapsed=$((tar_end - tar_start))

        # 获取备份文件大小
        local backup_size
        backup_size=$(du -sh "$backup_file" | cut -f1)

        log "INFO" "备份完成！耗时 ${elapsed} 秒，大小：$backup_size"
        log "INFO" "备份文件：$backup_file"
    else
        log "ERROR" "备份失败（tar 命令出错）"
        exit 1
    fi
}

# --------------------------------------------------
# 函数：清理旧备份
# --------------------------------------------------
cleanup_old_backups() {
    log "INFO" "清理 ${KEEP_DAYS} 天前的旧备份..."

    local dir_basename
    dir_basename=$(basename "$SOURCE_DIR")

    # 查找匹配的备份文件
    local old_count=0
    while IFS= read -r old_file; do
        if [ -n "$old_file" ] && [ -f "$old_file" ]; then
            log "INFO" "删除旧备份：$(basename "$old_file")"
            rm -f "$old_file"
            ((old_count++))
        fi
    done < <(find "$DEST_DIR" -name "${BACKUP_PREFIX}_${dir_basename}_*.tar.gz" -mtime +"${KEEP_DAYS}" -type f 2>/dev/null)

    if [ "$old_count" -eq 0 ]; then
        log "INFO" "没有需要清理的旧备份"
    else
        log "INFO" "已清理 ${old_count} 个旧备份文件"
    fi
}

# --------------------------------------------------
# 函数：生成备份报告
# --------------------------------------------------
generate_report() {
    echo ""
    echo "========================================="
    echo "         备份报告"
    echo "========================================="
    echo "  执行时间：$TIMESTAMP"
    echo "  源目录：  $SOURCE_DIR"
    echo "  目标目录：$DEST_DIR"
    echo "  保留天数：$KEEP_DAYS 天"
    echo "  日志文件：$LOG_FILE"
    echo "-----------------------------------------"

    # 列出目标目录中的备份文件
    local dir_basename
    dir_basename=$(basename "$SOURCE_DIR")
    echo "  现有备份："
    find "$DEST_DIR" -name "${BACKUP_PREFIX}_${dir_basename}_*.tar.gz" -type f \
        -printf "    %p  (%s 字节, %T+)\n" 2>/dev/null | sort -r | head -10

    echo "========================================="
}

# --------------------------------------------------
# 主流程
# --------------------------------------------------
main() {
    log "INFO" "============================================"
    log "INFO" "备份脚本启动"
    log "INFO" "============================================"

    # 1. 解析参数
    parse_args "$@"

    # 2. 打印配置
    log "INFO" "--- 备份配置 ---"
    log "INFO" "源目录：  $SOURCE_DIR"
    log "INFO" "目标目录：$DEST_DIR"
    log "INFO" "保留天数：$KEEP_DAYS 天"

    # 3. 检查源目录
    check_source

    # 4. 准备目标目录
    prepare_dest

    # 5. 执行备份
    do_backup

    # 6. 清理旧备份
    cleanup_old_backups

    # 7. 生成报告
    generate_report

    log "INFO" "脚本执行成功！"
    exit 0
}

# 执行主函数，传入脚本收到的所有参数
main "$@"
