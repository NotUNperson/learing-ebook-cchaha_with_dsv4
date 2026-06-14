#!/bin/bash
# ==============================================================================
# 03-grep.sh — grep 文本搜索 示例脚本
# ==============================================================================
# 用法: bash 03-grep.sh
# 演示 grep 的各种选项和搭配用法。
# 所有临时文件创建在 /tmp/linux-grep-demo-$$ 下。
# ==============================================================================

set -e

echo "=========================================="
echo "03-grep.sh: grep 文本搜索演示"
echo "=========================================="
echo ""

# ---- 创建临时演示目录 ----
DEMO_DIR="/tmp/linux-grep-demo-$$"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"
echo "[INFO] 演示目录: $DEMO_DIR"
echo ""

# ============================================================
# 准备测试数据
# ============================================================
echo "--- 准备测试数据 ---"

# 创建一个模拟的日志文件
cat << EOF > app.log
2026-05-15 10:00:01 INFO  Server started on port 8080
2026-05-15 10:00:05 DEBUG Loading configuration from /etc/app.conf
2026-05-15 10:01:12 INFO  User admin logged in from 192.168.1.100
2026-05-15 10:02:30 ERROR Failed to connect to database: timeout
2026-05-15 10:02:31 WARN  Retrying database connection (attempt 1)
2026-05-15 10:02:35 ERROR Failed to connect to database: timeout
2026-05-15 10:02:36 WARN  Retrying database connection (attempt 2)
2026-05-15 10:02:40 ERROR Failed to connect to database: timeout
2026-05-15 10:02:41 FATAL Maximum retries exceeded, shutting down
2026-05-15 10:02:42 INFO  Server shutting down
EOF

echo "模拟日志文件 app.log 已创建"
cat app.log
echo ""

# 创建一个模拟的配置文件
cat << EOF > app.conf
# Application Configuration
# Last modified: 2026-05-15

server.host = 0.0.0.0
server.port = 8080

# Database settings
database.host = localhost
database.port = 3306
database.user = app_user
# database.password = secret  (moved to secrets manager)

# Logging settings
logging.level = INFO
logging.file = /var/log/app.log

# Feature flags
feature.new_ui = true
feature.beta_mode = false
EOF

echo "模拟配置文件 app.conf 已创建"
echo ""

# 创建一些带 TODO 的代码文件
mkdir -p src
cat << EOF > src/main.py
#!/usr/bin/env python3
# TODO: Add error handling for network failures
def main():
    print("Hello, World!")

# FIXME: This function is too slow
def process_data(data):
    result = []
    for item in data:
        # TODO: Optimize this loop
        result.append(item * 2)
    return result

if __name__ == "__main__":
    main()
EOF

cat << EOF > src/utils.py
# Utility functions
import os

# todo: add more validation
def validate_path(path):
    return os.path.exists(path)

# TODO implement caching
def load_config():
    pass
EOF

echo "模拟代码文件已创建 (src/main.py, src/utils.py)"
echo ""

# ============================================================
# 1. grep 基本搜索
# ============================================================
echo "--- 1. grep 基本搜索 ---"
echo "搜索 'ERROR' (大小写敏感):"
grep "ERROR" app.log
echo ""

# ============================================================
# 2. grep -i: 忽略大小写
# ============================================================
echo "--- 2. grep -i: 忽略大小写 ---"
echo "搜索 'error' 忽略大小写 (grep -i error):"
grep -i "error" app.log
echo ""

# ============================================================
# 3. grep -v: 反向匹配
# ============================================================
echo "--- 3. grep -v: 反向匹配 ---"
echo "排除 INFO 行 (只看非 INFO 的日志):"
grep -v "INFO" app.log
echo ""

echo "排除注释行 (#开头) 和空行，看有效配置:"
grep -v "^#" app.conf | grep -v "^$"
echo ""

# ============================================================
# 4. grep -n: 显示行号
# ============================================================
echo "--- 4. grep -n: 显示行号 ---"
echo "搜索 ERROR 并显示行号:"
grep -n "ERROR" app.log
echo ""

# ============================================================
# 5. grep -c: 统计匹配数量
# ============================================================
echo "--- 5. grep -c: 统计匹配数量 ---"
echo "各种日志级别的数量:"
for level in INFO DEBUG WARN ERROR FATAL; do
    count=$(grep -c "$level" app.log)
    echo "  $level: $count 行"
done
echo ""

# ============================================================
# 6. grep -A / -B / -C: 上下文
# ============================================================
echo "--- 6. grep -C: 显示上下文 ---"
echo "搜索 FATAL 及其前后各 2 行 (grep -C 2 FATAL):"
grep -C 2 "FATAL" app.log
echo ""

echo "搜索 ERROR 及其后 1 行 (grep -A 1 ERROR):"
grep -A 1 "ERROR" app.log
echo ""

# ============================================================
# 7. grep -r: 递归搜索
# ============================================================
echo "--- 7. grep -r: 递归搜索 ---"
echo "递归搜索 TODO (显示文件名和行号):"
grep -rn "TODO" src/
echo ""

echo "只显示包含 TODO 的文件名 (-rl):"
grep -rl "TODO" src/
echo ""

# ============================================================
# 8. grep -w: 整词匹配
# ============================================================
echo "--- 8. grep -w: 整词匹配 ---"
echo "创建测试文本..."
echo "log logging blog catalog" > words.txt
echo "grep 'log' (普通匹配):"
grep "log" words.txt
echo "grep -w 'log' (整词匹配):"
grep -w "log" words.txt
echo ""

# ============================================================
# 9. grep -E: 扩展正则表达式
# ============================================================
echo "--- 9. grep -E: 扩展正则 ---"
echo "匹配 ERROR 或 FATAL (grep -E 'ERROR|FATAL'):"
grep -E "ERROR|FATAL" app.log
echo ""

echo "提取 IP 地址 (grep -oE):"
grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" app.log
echo ""

# ============================================================
# 10. grep -q: 静默模式（用于脚本判断）
# ============================================================
echo "--- 10. grep -q: 静默模式 ---"
if grep -q "FATAL" app.log; then
    echo "日志中包含 FATAL 错误！需要检查。"
else
    echo "日志中没有 FATAL 错误。"
fi
echo ""

# ============================================================
# 11. 管道中的 grep
# ============================================================
echo "--- 11. 管道中的 grep ---"
echo "ps aux 中包含 'bash' 的进程:"
ps aux | grep "bash" | head -5
echo ""

# ============================================================
# 12. grep 组合: 排除注释后统计有效配置行数
# ============================================================
echo "--- 12. 组合使用: 有效配置行 ---"
echo "排除注释和空行后的配置:"
grep -v "^#" app.conf | grep -v "^$" | grep -v "^\s*$"
echo ""
echo "有效配置行数:"
grep -v "^#" app.conf | grep -v "^$" | grep -v "^\s*$" | wc -l
echo ""

# ============================================================
# 13. fgrep: 固定字符串搜索（不解析正则）
# ============================================================
echo "--- 13. fgrep: 固定字符串搜索 ---"
echo "搜索包含特殊字符的字符串 (比如包含 . 和 * 的):"
echo "192.168.1.*" > special.txt
fgrep "192.168.1.*" special.txt
echo "对比 grep (不加 -F):  .  会匹配任意字符， *  表示重复"
echo ""

# ============================================================
# 清场
# ============================================================
echo "=========================================="
echo "演示完成！所有临时文件在: $DEMO_DIR"
echo "你可以手动删除: rm -rf $DEMO_DIR"
echo "=========================================="
