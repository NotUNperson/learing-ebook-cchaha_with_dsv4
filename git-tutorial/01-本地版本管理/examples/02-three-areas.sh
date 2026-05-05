#!/bin/bash
# =============================================================================
# 02-three-areas.sh — Git 三个区域实操脚本
# 场景：通过创建文件、暂存、提交的过程，直观展示三个区域的概念
# 用法：在 Git Bash 中运行  bash 02-three-areas.sh
# 该脚本在 /tmp 下创建临时目录，运行结束后自动清理
# =============================================================================

echo "============================================"
echo "  02 Git 的三个区域 — 实操脚本"
echo "============================================"
echo ""

# 1. 创建临时实验场地
TEMP_DIR="/tmp/git-learn-02-areas-$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ">>> 实验场地已创建：$TEMP_DIR"
echo ""

# 2. 初始化仓库
echo ">>> 第一步：初始化空仓库"
git init
echo ""

# 3. 初始状态 —— 三个区域都是空的
echo ">>> 初始 git status（三个区域都没有内容）："
git status
echo ""
echo "解读：nothing to commit = 暂存区为空，no commits yet = 仓库为空"
echo ""

# 4. 在工作区创建文件 —— 文件进入"办公桌"
echo "============================================"
echo "  第二步：在工作区创建文件（模拟在办公桌上写字）"
echo "============================================"
echo ""

echo "hello world" > readme.txt
echo "print('hello')" > app.py
echo "TODO: finish this" > notes.txt

echo ">>> 创建了三个文件：readme.txt, app.py, notes.txt"
echo ""
echo ">>> 查看文件列表："
ls -la
echo ""

# 5. 查看状态 —— 文件在"工作区"（办公桌上），还没被跟踪
echo ">>> git status —— 看看 Git 怎么说："
git status
echo ""
echo "解读：这三个文件都是 Untracked files（未跟踪文件）。"
echo "它们只在工作区（办公桌上），暂存区（文件夹）和仓库（档案柜）里都还没有。"
echo ""

# 6. 用 git add 把 readme.txt 放入暂存区 —— "把这张纸放进文件夹"
echo "============================================"
echo "  第三步：git add readme.txt —— 只把一个文件放入暂存区"
echo "============================================"
echo ""

git add readme.txt
echo ">>> 执行了：git add readme.txt"
echo ""
echo ">>> 再次 git status："
git status
echo ""
echo "解读：readme.txt 显示为 'Changes to be committed'（绿色），意思是在暂存区里。"
echo "app.py 和 notes.txt 还在 'Untracked files'（红色），意思是在工作区但没进暂存区。"
echo ""

# 7. 把所有文件放入暂存区
echo "============================================"
echo "  第四步：git add . —— 把所有文件都放入暂存区"
echo "============================================"
echo ""

git add .
echo ">>> 执行了：git add ."
echo ""
echo ">>> 再次 git status："
git status
echo ""
echo "解读：所有文件都变成 'Changes to be committed'（绿色）了。"
echo "现在暂存区（文件夹）里有三份文件，等待被提交到仓库（档案柜）。"
echo ""

# 8. 提交到仓库 —— "把文件夹里的内容正式归档"
echo "============================================"
echo "  第五步：git commit —— 把暂存区的内容存入仓库"
echo "============================================"
echo ""

git commit -m "第一次提交：创建了三个初始文件"
echo ""
echo ">>> git status 现在："
git status
echo ""
echo "解读：nothing to commit, working tree clean —— 三个区域都同步了！"
echo "工作区、暂存区、仓库的内容一致。"
echo ""

# 9. 修改工作区中的文件 —— 证明工作区独立于仓库
echo "============================================"
echo "  第六步：修改工作区文件 —— 工作区可以独立于仓库变化"
echo "============================================"
echo ""

echo "更新了内容" >> readme.txt
echo ""
echo ">>> 在 readme.txt 末尾追加了一行文字"
echo ""
echo ">>> git status："
git status
echo ""
echo "解读：readme.txt 显示为 'modified'（修改过的文件）。"
echo "这个修改目前只存在于工作区（办公桌上），暂存区和仓库还没有。"
echo "这就是三个区域独立运作的最好证明！"
echo ""

# 10. 清理
echo "============================================"
echo "  脚本执行完毕，清理临时目录..."
echo "============================================"
cd /tmp || exit
rm -rf "$TEMP_DIR"
echo ">>> 已删除 $TEMP_DIR"
echo ""
echo "回顾一下今天看到的流程："
echo "  新建文件        → 工作区（Untracked）"
echo "  git add        → 暂存区（Changes to be committed）"
echo "  git commit     → 仓库（已永久保存）"
echo "  修改已提交文件  → 工作区再次变脏（Modified）"
echo ""
echo "办公桌 → 文件夹 → 档案柜，这个类比多默念几遍就牢了。"
