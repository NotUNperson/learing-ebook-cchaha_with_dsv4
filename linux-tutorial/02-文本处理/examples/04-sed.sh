#!/bin/bash
# ==============================================================================
# 04-sed.sh — sed 流编辑器 示例脚本
# ==============================================================================
# 用法: bash 04-sed.sh
# 演示 sed 的四大核心操作：替换(s)、删除(d)、插入(i/a)、打印(p)。
# 所有临时文件创建在 /tmp/linux-sed-demo-$$ 下。
# ==============================================================================

set -e

echo "=========================================="
echo "04-sed.sh: sed 流编辑器演示"
echo "=========================================="
echo ""

# ---- 创建临时演示目录 ----
DEMO_DIR="/tmp/linux-sed-demo-$$"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"
echo "[INFO] 演示目录: $DEMO_DIR"
echo ""

# ============================================================
# 准备测试数据
# ============================================================
echo "--- 准备测试数据 ---"

# 模拟一个配置文件
cat << EOF > server.conf
# Web Server Configuration
# Do not edit manually

server {
    listen 8080;
    server_name localhost;
    root /var/www/html;

    # SSL settings
    ssl_certificate /etc/ssl/cert.pem;
    ssl_certificate_key /etc/ssl/key.pem;
}

# Database connection
database {
    host = localhost
    port = 3306
    user = db_user
    password = change_me
}
EOF

echo "server.conf 已创建"
echo ""

# 模拟一个 CSV 数据文件
cat << EOF > data.csv
name,age,city
Alice,30,New York
Bob,25,Los Angeles
Charlie,35,Chicago

David,28,Houston

Eve,22,Boston
EOF

echo "data.csv 已创建"
echo ""

# ============================================================
# 1. 替换 (s) -- 基础用法
# ============================================================
echo "--- 1. 替换 (s) 基础 ---"
echo "把 localhost 替换成 127.0.0.1:"
sed 's/localhost/127.0.0.1/' server.conf
echo ""

echo "把 8080 替换成 9090 (全局替换 g):"
sed 's/8080/9090/g' server.conf
echo ""

# ============================================================
# 2. 替换 (s) -- g 标志的重要性
# ============================================================
echo "--- 2. g 标志的重要性 ---"
echo "测试文本: echo 'apple pie and apple juice'"
echo ""
echo "不加 g (只替换每行第一个):"
echo "apple pie and apple juice" | sed 's/apple/orange/'
echo ""
echo "加 g (替换所有):"
echo "apple pie and apple juice" | sed 's/apple/orange/g'
echo ""

# ============================================================
# 3. 替换 (s) -- 不同的分隔符
# ============================================================
echo "--- 3. 使用不同分隔符 ---"
echo "路径中包含 / 时，用 # 或 | 做分隔符会更清晰:"
echo "用 / (需要转义):"
sed 's/\/etc\/ssl\/cert.pem/\/opt\/ssl\/cert.pem/' server.conf | grep ssl_certificate
echo "用 # (简洁):"
sed 's#/etc/ssl/cert.pem#/opt/ssl/cert.pem#' server.conf | grep ssl_certificate
echo ""

# ============================================================
# 4. 删除 (d)
# ============================================================
echo "--- 4. 删除 (d) ---"
echo "删除注释行 (以 # 开头):"
sed '/^#/d' server.conf
echo ""

echo "删除空行:"
sed '/^$/d' data.csv
echo ""

echo "删除第 2 到第 4 行:"
seq 1 10 | sed '2,4d'
echo ""

echo "删除注释行和空行（多重 d 命令，用分号分隔）:"
sed '/^#/d; /^$/d' server.conf
echo ""

# ============================================================
# 5. 插入 (i) 和追加 (a)
# ============================================================
echo "--- 5. 插入 (i) 和追加 (a) ---"
echo "在第 3 行之前插入:"
seq 1 5 | sed '3i\*** 插入的内容 ***'
echo ""

echo "在第 3 行之后追加:"
seq 1 5 | sed '3a\*** 追加的内容 ***'
echo ""

echo "在文件末尾追加:"
sed '$a\# END OF CONFIG' server.conf
echo ""

echo "在文件开头插入:"
sed '1i\# Auto-generated config' server.conf
echo ""

# ============================================================
# 6. 打印 (p) 配合 -n
# ============================================================
echo "--- 6. 打印 (p) 配合 -n ---"
echo "不加 -n (匹配行会打印两次——sed 默认输出 + p 命令输出):"
seq 1 10 | sed '/5/p' | head -6
echo "（注意第 5 行出现了两次）"
echo ""

echo "加 -n (只打印 p 指定的行):"
seq 1 10 | sed -n '/5/p'
echo ""

echo "打印第 3 到第 7 行:"
seq 1 10 | sed -n '3,7p'
echo ""

echo "打印配置文件中的非注释、非空行:"
sed -n '/^[^#]/p' server.conf | sed -n '/^$/!p'
echo ""

# ============================================================
# 7. 地址 (Address) 用法
# ============================================================
echo "--- 7. 地址 (Address) ---"
echo "只对第 3 行做替换:"
seq 1 5 | sed '3s/[0-9]/X/'
echo ""

echo "对第 2 到第 4 行做替换:"
seq 1 5 | sed '2,4s/[0-9]/#/'
echo ""

echo "对匹配模式的行做替换:"
seq 1 20 | sed '/1/s/[0-9]/Y/'
echo ""

# ============================================================
# 8. 多命令组合
# ============================================================
echo "--- 8. 多命令组合 ---"
echo "先删除注释，然后把 localhost 替换成 127.0.0.1:"
sed -e '/^#/d' -e 's/localhost/127.0.0.1/' server.conf
echo ""

echo "用分号也可以:"
sed '/^#/d; s/8080/9090/g' server.conf
echo ""

# ============================================================
# 9. sed -i: 原地修改（带备份）
# ============================================================
echo "--- 9. sed -i 原地修改 ---"
cp server.conf server.conf.test
echo "修改前 server.conf.test 内容:"
cat server.conf.test
echo ""

echo "执行 sed -i.bak 's/8080/9999/' server.conf.test"
sed -i.bak 's/8080/9999/' server.conf.test
echo ""

echo "修改后 server.conf.test 内容:"
cat server.conf.test
echo ""

echo "备份文件 server.conf.test.bak 内容:"
cat server.conf.test.bak
echo ""

# ============================================================
# 10. 高级替换: & 和分组引用
# ============================================================
echo "--- 10. 高级替换: & 和分组引用 ---"
echo "& 表示整个匹配文本:"
echo "hello world" | sed 's/world/(&)/'
echo ""

echo "分组引用 (交换名和姓):"
echo "John Smith" | sed 's/\([A-Za-z]*\) \([A-Za-z]*\)/\2, \1/'
echo ""

# ============================================================
# 11. sed 在管道中
# ============================================================
echo "--- 11. sed 在管道中使用 ---"
echo "ls -la 输出简化:"
ls -la / | sed 's/  */ /g' | head -10
echo ""

echo "提取 data.csv 中不含空行的有效行，再把逗号替换成 | :"
sed '/^$/d' data.csv | sed 's/,/ | /g'
echo ""

# ============================================================
# 12. 实用案例汇总
# ============================================================
echo "--- 12. 实用案例汇总 ---"

echo "案例1: 删除行尾空格"
echo "   hello   " | sed 's/[ \t]*$//' | cat -A
echo ""

echo "案例2: 给所有行添加编号"
seq 1 5 | sed '=' | sed 'N; s/\n/. /'
echo ""

echo "案例3: 查看文件的第 5 行到第 15 行"
echo "(模拟: seq 1 30 然后提取 5-15):"
seq 1 30 | sed -n '5,15p'
echo ""

echo "案例4: 把所有大写字母转小写 (需要 GNU sed 的 \\L)"
echo "HELLO WORLD" | sed 's/.*/\L&/' 2>/dev/null || echo "  (你的 sed 版本支持此功能)"
echo ""

# ============================================================
# 清场
# ============================================================
echo "=========================================="
echo "演示完成！所有临时文件在: $DEMO_DIR"
echo "你可以手动删除: rm -rf $DEMO_DIR"
echo "=========================================="
