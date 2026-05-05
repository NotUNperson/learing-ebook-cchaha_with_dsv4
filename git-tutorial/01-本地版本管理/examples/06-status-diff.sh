#!/bin/bash
# =============================================================================
# 06-status-diff.sh — git status 和 git diff 实操脚本
# 场景：通过一系列操作，演示 git status 和 git diff 如何反映三个区域的变化
# 用法：在 Git Bash 中运行  bash 06-status-diff.sh
# 该脚本在 /tmp 下创建临时目录，运行结束后自动清理
# =============================================================================

echo "============================================"
echo "  06 查看状态和改动（git status / git diff）— 实操脚本"
echo "============================================"
echo ""

# 1. 创建临时实验场地
TEMP_DIR="/tmp/git-learn-06-status-diff-$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ">>> 实验场地：$TEMP_DIR"
echo ""

# 2. 初始化仓库，做一个初始提交
git init > /dev/null 2>&1
echo "第一版内容" > README.md
echo "print('hello')" > app.py
git add .
git commit -m "初始提交" > /dev/null 2>&1
echo ">>> 已完成初始提交，工作区干净"
echo ""

# 3. git status —— 干净状态
echo "============================================"
echo "  git status —— 干净的工作区"
echo "============================================"
echo ""
git status
echo ""
echo "解读：nothing to commit, working tree clean"
echo "意思是：暂存区是空的，工作区和仓库完全一致。"
echo ""

# 4. 修改一个已有文件
echo "============================================"
echo "  修改一个已跟踪的文件"
echo "============================================"
echo ""

echo "在 app.py 末尾追加一行代码"
echo "print('world')" >> app.py
echo ""

echo ">>> git status 现在："
git status
echo ""
echo "解读：app.py 在 'Changes not staged for commit'（红色）"
echo "它是已跟踪文件，修改在工作区，还没进暂存区。"
echo ""

# 5. git diff 看具体改动
echo "============================================"
echo "  git diff —— 看具体改了什么（工作区 vs 仓库）"
echo "============================================"
echo ""
git diff
echo ""
echo "解读：+ 号开头的那行是你加的内容。- 号开头的行（如果有的话）是被删的内容。"
echo "默认 git diff 只看工作区中没暂存的修改。"
echo ""

# 6. 创建一个新文件
echo "============================================"
echo "  创建一个全新的文件"
echo "============================================"
echo ""

echo "这是新文件" > newfile.txt
echo ""

echo ">>> git status 现在："
git status
echo ""
echo "解读：newfile.txt 出现在 'Untracked files'（红色）"
echo "这是 Git 完全不认识的新文件，从未被跟踪过。"
echo ""

# 7. 暂存一个文件，不暂存另一个
echo "============================================"
echo "  只暂存一个文件（模拟挑选式存档）"
echo "============================================"
echo ""

git add app.py
echo ">>> 执行了：git add app.py"
echo ""

echo ">>> git status 现在："
git status
echo ""
echo "解读：app.py 进入 'Changes to be committed'（绿色，在暂存区）"
echo "newfile.txt 仍在 'Untracked files'（红色，在工作区）"
echo "两个文件的状态不一样——这就是选择性暂存的魔力。"
echo ""

# 8. 看看 git diff 现在输出什么
echo "============================================"
echo "  验证：git diff 不显示已暂存的内容"
echo "============================================"
echo ""

echo ">>> git diff（默认比较工作区 vs 仓库）："
git diff
echo ""
echo "解读：新文件 newfile.txt 没有在 git diff 中显示具体改动，"
echo "因为它还没被跟踪，git diff 默认只显示已跟踪文件的修改。"
echo "但它在 git status 中是能看到的（Untracked files）。"
echo ""

# 9. git diff --staged —— 暂存区 vs 仓库
echo "============================================"
echo "  git diff --staged —— 看暂存区里有什么"
echo "============================================"
echo ""
git diff --staged
echo ""
echo "解读：现在能看到 app.py 的改动了！这就是暂存区 vs 仓库的差异。"
echo "使用场景：提交前最后确认一次，'我要提交的这些内容，是我想要的对吗？'"
echo ""

# 10. git diff HEAD —— 全面比较
echo "============================================"
echo "  git diff HEAD —— 从上次存档到现在所有的改动"
echo "============================================"
echo ""
git diff HEAD
echo ""
echo "解读：HEAD 指向仓库最新的一次提交。git diff HEAD 展示工作区 + 暂存区"
echo "和最新提交之间的所有差异。这是最全面的视角。"
echo ""

# 11. git diff --stat
echo "============================================"
echo "  git diff --stat —— 只看统计，不看具体内容"
echo "============================================"
echo ""
git diff --stat
echo ""
git diff --staged --stat
echo ""
echo "解读：--stat 模式只告诉你哪些文件变了，每个文件增加了/删除了多少行。"
echo "适合快速浏览，不需要看具体代码时使用。"
echo ""

# 12. git status -s —— 简写模式
echo "============================================"
echo "  git status -s —— 简写模式"
echo "============================================"
echo ""
git status -s
echo ""
echo "解读：状态简写字母"
echo "  M 在右边（红色） = 工作区有修改，暂存区没有"
echo "  M 在左边（绿色） = 暂存区有修改"
echo "  ??              = 未跟踪文件"
echo "  A               = 新添加到暂存区的文件"
echo ""

# 13. 提交前完整检查流程演示
echo "============================================"
echo "  推荐工作流：提交前的完整检查"
echo "============================================"
echo ""
echo "第 1 步：git status        —— 全局状态一览"
echo "第 2 步：git diff           —— 看看还没暂存的改了什么"
echo "第 3 步：git add ...        —— 把要提交的内容暂存"
echo "第 4 步：git diff --staged  —— 确认暂存区的内容无误"
echo "第 5 步：git commit         —— 正式提交"
echo ""
echo "这个流程确保你不会漏东西，也不会提交不该提交的内容。"
echo ""

# 清理
echo "============================================"
echo "  脚本执行完毕，清理临时目录..."
echo "============================================"
cd /tmp || exit
rm -rf "$TEMP_DIR"
echo ">>> 已删除 $TEMP_DIR"
echo ""
echo "今天的关键命令："
echo "  git status           仪表盘——看三个区域的全局状态"
echo "  git diff             放大镜——看工作区中未暂存的修改"
echo "  git diff --staged    放大镜——看暂存区中的内容"
echo "  git diff HEAD        放大镜——看从上次存档以来的全部改动"
echo "  git diff --stat      统计模式——只看哪些文件改了"
echo ""
echo "建议：每次 add 之前和之后都跑一次 git status，养成习惯。"
