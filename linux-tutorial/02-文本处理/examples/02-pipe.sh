#!/bin/bash
# ==============================================================================
# 02-pipe.sh — 管道（pipe）示例脚本
# ==============================================================================
# 用法: bash 02-pipe.sh
# 演示 | 管道、tee 分流、xargs 转换参数、常用管道组合。
# 所有临时文件创建在 /tmp/linux-pipe-demo-$$ 下。
# ==============================================================================

set -e

echo "=========================================="
echo "02-pipe.sh: 管道演示"
echo "=========================================="
echo ""

# ---- 创建临时演示目录 ----
DEMO_DIR="/tmp/linux-pipe-demo-$$"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"
echo "[INFO] 演示目录: $DEMO_DIR"
echo ""

# ============================================================
# 1. 管道基本用法: 连接两个命令
# ============================================================
echo "--- 1. 管道基本用法 ---"
echo "ls -la / | wc -l  —— 统计根目录下的条目数"
ls -la / | wc -l
echo ""

# ============================================================
# 2. 管道 + less: 分页查看
# ============================================================
echo "--- 2. 管道 + less ---"
echo "在脚本中 less 会直接退出，但你可以手动运行: ls -la /usr/bin | less"
echo "试试在终端手动执行，按 q 退出 less"
echo ""

# ============================================================
# 3. grep + wc -l: 统计匹配行数
# ============================================================
echo "--- 3. grep + wc -l ---"
echo "统计 /etc/passwd 中有多少用户使用 bash 作为 shell"
grep bash /etc/passwd | wc -l
echo ""

# ============================================================
# 4. sort + uniq: 去重计数
# ============================================================
echo "--- 4. sort + uniq 配合使用 ---"
echo "准备测试数据..."
cat << EOF > names.txt
Alice
Bob
Alice
Charlie
Bob
Alice
David
Eve
Bob
EOF

echo "原始数据:"
cat names.txt
echo ""

echo "去重并计数 (sort | uniq -c):"
sort names.txt | uniq -c
echo ""

echo "按出现次数排序 (sort | uniq -c | sort -rn):"
sort names.txt | uniq -c | sort -rn
echo ""

# ============================================================
# 5. tee: 管道中间分流保存
# ============================================================
echo "--- 5. tee 分流保存 ---"
echo "把 ls 输出同时显示在屏幕和保存到文件"
ls -la / | tee root_list.txt | wc -l
echo ""
echo "root_list.txt 的前 5 行:"
head -5 root_list.txt
echo ""

echo "tee -a 追加模式:"
echo "追加一行" | tee -a root_list.txt
echo "再次追加" | tee -a root_list.txt
echo "root_list.txt 最后 5 行:"
tail -5 root_list.txt
echo ""

# ============================================================
# 6. xargs: 管道输入转命令行参数
# ============================================================
echo "--- 6. xargs: 管道输入转命令行参数 ---"
echo "创建几个测试文件..."

for f in alpha.txt beta.txt gamma.txt; do
    echo "这是文件 $f 的内容" > "$f"
done

echo "find . -name '*.txt' | xargs wc -l:"
find . -name "*.txt" | xargs wc -l
echo ""

echo "find . -name '*.txt' | xargs cat:"
find . -name "*.txt" | xargs cat
echo ""

# 对比：不用 xargs 会怎样？
echo "对比: find . -name '*.txt' | wc -l (没有 xargs)"
echo "这只是统计 find 找到了多少个文件名:"
find . -name "*.txt" | wc -l
echo "（和上面的结果不一样！上面的结果是统计每个文件内部有多少行）"
echo ""

# xargs 处理带空格的文件名
echo "xargs -0 处理带空格的文件名:"
touch "my file with spaces.txt"
echo "内容" > "my file with spaces.txt"
# 用 find -print0 和 xargs -0 配对处理
find . -name "my file*" -print0 | xargs -0 wc -l
echo ""

# ============================================================
# 7. 管道中的 stderr 处理
# ============================================================
echo "--- 7. 管道中处理 stderr ---"
echo "默认: 管道不传递 stderr"
find /etc /bad_dir 2>&1 | grep "Permission denied" || echo "（可能没捕获到 Permission denied）"
echo ""

# ============================================================
# 8. 长管道示例
# ============================================================
echo "--- 8. 长管道: 统计源码目录中每种文件扩展名的数量 ---"
echo "创建模拟的源码文件..."
mkdir -p src
touch src/main.py src/utils.py src/helper.py
touch src/app.js src/config.js
touch src/readme.md src/style.css
touch src/index.html src/about.html

echo "管道: find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn"
find src -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn
echo ""

# ============================================================
# 9. 管道换行写法
# ============================================================
echo "--- 9. 管道换行写法（用 \\）---"
find src \
  -type f \
  | sed 's/.*\.//' \
  | sort \
  | uniq -c \
  | sort -rn
echo ""

# ============================================================
# 10. 管道 + awk 简单用法
# ============================================================
echo "--- 10. 管道 + awk 提取特定列 ---"
echo "ls -la | awk '{print \$5, \$9}' —— 打印文件大小和文件名:"
ls -la | awk '{print "  大小: "$5"  名字: "$9}' | head -10
echo ""

# ============================================================
# 11. 管道 exit code 检测
# ============================================================
echo "--- 11. 管道的退出码 ---"
# 管道的退出码默认是最后一个命令的退出码
if echo "test" | grep -q "test"; then
    echo "管道执行成功"
else
    echo "管道执行失败"
fi

# 在 bash 中，可以用 PIPESTATUS 数组检查管道中每个命令的退出码
echo "检查每个管道成员的退出码:"
true | false | true
echo "PIPESTATUS: ${PIPESTATUS[*]}"
echo "（注意：第 2 个命令 false 的退出码是 1）"
echo ""

# ============================================================
# 清场
# ============================================================
echo "=========================================="
echo "演示完成！所有临时文件在: $DEMO_DIR"
echo "你可以手动删除: rm -rf $DEMO_DIR"
echo "=========================================="
