#!/bin/bash
# ============================================================================
# 04-view-files.sh
# 演示查看文件内容的各类命令
# cat -- 快速查看小文件
# less -- 翻页浏览大文件
# head/tail -- 只看头尾
# nl -- 加行号
# wc -- 统计行数/单词数/字节数
# ============================================================================

echo "=============================================="
echo "  Linux 查看文件内容命令演示"
echo "  cat     -- 一口气看完（适合小文件）"
echo "  less    -- 翻页浏览（适合大文件）"
echo "  head    -- 只看开头"
echo "  tail    -- 只看结尾"
echo "  nl      -- 给文件加行号"
echo "  wc      -- 统计文件信息"
echo "=============================================="
echo ""

# ============================================================================
# 创建演示用的示例文件
# ============================================================================
DEMO_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t viewfiles 2>/dev/null || echo "/tmp/viewfiles-demo-$$")
if [ "$DEMO_DIR" = "/tmp/viewfiles-demo-$$" ]; then
    mkdir -p "$DEMO_DIR"
fi
echo "演示目录: $DEMO_DIR"
cd "$DEMO_DIR"

# 创建一个小文件用于演示 cat
cat > small.txt << 'EOF'
第一行：Hello, Linux!
第二行：这是一行中文内容
第三行：pwd 显示当前目录
第四行：ls 列出文件
第五行：cd 切换目录
EOF
echo "已创建 small.txt（5 行）"

# 创建一个稍大的文件用于演示
for i in $(seq 1 50); do
    echo "第 $i 行 - 这是用于演示各种查看命令的示例文本内容" >> medium.txt
done
echo "已创建 medium.txt（50 行）"

echo ""

# ============================================================================
# 第一部分：cat -- 查看小文件
# ============================================================================
echo "=============================================="
echo "【第一部分】cat -- 查看小文件"
echo ""

echo "1. cat small.txt -- 查看小文件:"
echo "---"
cat small.txt
echo "---"
echo ""

echo "2. cat -n small.txt -- 带行号显示:"
echo "---"
cat -n small.txt
echo "---"
echo ""

echo "3. 用 cat 拼接两个文件:"
echo "额外的一行" > extra.txt
echo "---"
cat small.txt extra.txt
echo "---"
echo "   注意：small.txt 和 extra.txt 的内容被拼接在一起输出"
echo ""

echo "4. 用 cat 合并文件为新文件:"
cat small.txt extra.txt > combined.txt
echo "   cat small.txt extra.txt > combined.txt"
echo "   新文件 combined.txt 的行数:"
wc -l combined.txt
echo "   原 small.txt 有 5 行，extra.txt 有 1 行，合并后共 6 行"
echo ""

# ============================================================================
# 第二部分：less -- 翻页浏览
# ============================================================================
echo "=============================================="
echo "【第二部分】less -- 翻页浏览大文件"
echo ""
echo "less 的操作方式（模拟演示，不实际打开 less）:"
echo ""
echo "  命令: less medium.txt"
echo "  进入 less 后的操作:"
echo "  ┌─────────────────────────────────────────────┐"
echo "  │ 空格键        向下翻一页                     │"
echo "  │ b             向上翻一页                     │"
echo "  │ j / 下箭头    向下滚动一行                   │"
echo "  │ k / 上箭头    向上滚动一行                   │"
echo "  │ g             跳到文件开头                   │"
echo "  │ G (大写)      跳到文件末尾                   │"
echo "  │ /关键词       向下搜索                       │"
echo "  │ ?关键词       向上搜索                       │"
echo "  │ n             跳到下一个搜索结果             │"
echo "  │ N (大写)      跳到上一个搜索结果             │"
echo "  │ q             退出 less                      │"
echo "  └─────────────────────────────────────────────┘"
echo ""
echo "  示例：less /var/log/syslog"
echo "  在 less 中按 /error 可以搜索所有包含 'error' 的行"
echo ""

# 演示通过管道使用 less 的场景
echo "演示：通过管道将长输出传给 less（本脚本用 head 模拟）"
echo "命令实际效果: ls -la /etc | less"
echo "---"
# 不实际打开 less，用 head 展示效果
ls -la /etc 2>/dev/null | head -15
echo "... (按 q 退出 less)"
echo ""

# ============================================================================
# 第三部分：head -- 只看开头
# ============================================================================
echo "=============================================="
echo "【第三部分】head -- 查看文件开头"
echo ""

echo "1. head medium.txt -- 默认显示前 10 行:"
echo "---"
head medium.txt
echo "---"
echo ""

echo "2. head -n 3 medium.txt -- 只显示前 3 行:"
echo "---"
head -n 3 medium.txt
echo "---"
echo ""

echo "3. head -3 medium.txt -- -n 可以省略（-3 = -n 3）:"
echo "---"
head -3 medium.txt
echo "---"
echo ""

echo "4. 实用场景：查看 /etc/passwd 的前几行:"
echo "---"
head -5 /etc/passwd 2>/dev/null || echo "  (无法读取 /etc/passwd)"
echo "---"
echo ""

# ============================================================================
# 第四部分：tail -- 只看结尾
# ============================================================================
echo "=============================================="
echo "【第四部分】tail -- 查看文件结尾"
echo ""

echo "1. tail medium.txt -- 默认显示最后 10 行:"
echo "---"
tail medium.txt
echo "---"
echo ""

echo "2. tail -n 3 medium.txt -- 只显示最后 3 行:"
echo "---"
tail -n 3 medium.txt
echo "---"
echo ""

echo "3. tail -f -- 实时追踪文件更新（最重要的功能）:"
echo "   用法: tail -f /var/log/syslog"
echo "   效果: 每当有新的日志写入，会立刻显示在屏幕上"
echo "   退出: 按 Ctrl+C"
echo "   类比: 站在打印机出纸口旁边，每打印一张立刻看到"
echo ""

# 演示 tail -f 的效果（模拟）
echo "4. 模拟 tail -f 的效果:"
echo "   创建文件 watch_demo.log..."
echo "初始行" > watch_demo.log
echo "   当前文件内容:"
tail watch_demo.log
echo ""
echo "   追加新内容到文件..."
echo "新增的第一行" >> watch_demo.log
echo "新增的第二行" >> watch_demo.log
echo "   最新 5 行（模拟 tail -f 会看到的效果）:"
tail -5 watch_demo.log
echo "   真实 tail -f 会自动显示新增内容，不需要手动执行 tail"
echo ""

# head + tail 组合技
echo "5. head + tail 组合技 -- 查看文件中间部分:"
echo "   查看 medium.txt 的第 25 行到第 35 行:"
echo "   命令: head -35 medium.txt | tail -11"
echo "---"
head -35 medium.txt | tail -11
echo "---"
echo "   解释: head 取前 35 行 -> tail 从这 35 行里取最后 11 行 = 第 25-35 行"
echo ""

# ============================================================================
# 第五部分：nl -- 加行号
# ============================================================================
echo "=============================================="
echo "【第五部分】nl -- 给文件加行号"
echo ""

# 创建一个包含空行的文件
cat > with_blanks.txt << 'EOF'
第一行：这不是空行
第二行：这也不是空行

第四行：第三行是空行（上面那个空行）
第五行：内容行

第七行：第六行是空行
EOF

echo "演示文件 with_blanks.txt 的内容（原始）:"
cat with_blanks.txt
echo ""

echo "1. nl with_blanks.txt -- 默认只给非空行编号:"
echo "---"
nl with_blanks.txt
echo "---"
echo "   注意：空行没有编号"
echo ""

echo "2. nl -b a with_blanks.txt -- 给所有行（包括空行）编号:"
echo "---"
nl -b a with_blanks.txt
echo "---"
echo ""

echo "3. cat -n 和 nl 的对比:"
echo "   cat -n -- 简单直接，给所有行编号（包括空行）"
echo "   nl     -- 更灵活，可以只给非空行编号"
echo ""

# ============================================================================
# 第六部分：wc -- 统计文件信息
# ============================================================================
echo "=============================================="
echo "【第六部分】wc -- 统计行数/单词数/字节数"
echo ""

echo "1. wc medium.txt -- 显示行数、单词数、字节数:"
wc medium.txt
echo "   输出格式: 行数  单词数  字节数  文件名"
echo ""

echo "2. wc -l medium.txt -- 只统计行数:"
wc -l medium.txt
echo ""

echo "3. wc -w small.txt -- 只统计单词数:"
wc -w small.txt
echo ""

echo "4. wc -c small.txt -- 只统计字节数:"
wc -c small.txt
echo ""

echo "5. wc -m small.txt -- 只统计字符数（多字节字符如中文，这里可能 > 字节数）:"
wc -m small.txt
echo "   注意：对于纯英文文件，字符数通常等于字节数"
echo "         对于中文文件，一个中文字符占 3 个字节（UTF-8），字符数 < 字节数"
echo ""

echo "6. 实用场景:"
echo "   统计 /etc 下有多少个配置文件:"
ls -1 /etc 2>/dev/null | wc -l
echo ""

echo "   统计系统有多少个用户:"
wc -l /etc/passwd 2>/dev/null || echo "   (无法读取)"
echo ""

echo "   统计某个目录下所有 .txt 文件的总行数:"
wc -l *.txt 2>/dev/null
echo ""

# ============================================================================
# 总结
# ============================================================================
echo "=============================================="
echo "  总结 -- 什么时候用什么命令:"
echo ""
echo "  cat file          -- 小文件（几十行），快速看完"
echo "  cat -n file       -- 带行号查看"
echo "  less file         -- 大文件，需要翻页和搜索"
echo "                      按 q 退出，按 / 搜索"
echo "  head file         -- 只看开头 10 行"
echo "  head -20 file     -- 只看开头 20 行"
echo "  tail file         -- 只看结尾 10 行"
echo "  tail -f file      -- 实时追踪（日志监控利器）"
echo "  head -30 f|tail-11-- 看第 20-30 行（组合技）"
echo "  nl file           -- 加行号查看"
echo "  wc -l file        -- 统计行数"
echo "  wc -w file        -- 统计单词数"
echo "=============================================="

# 清理演示目录
cd /
rm -rf "$DEMO_DIR"
echo ""
echo "已清理演示目录: $DEMO_DIR"
