#!/bin/bash
# =============================================================================
# 01-init.sh — git init 实操脚本
# 场景：创建一个新的 Git 仓库，探索 .git 目录的结构
# 用法：在 Git Bash 中运行  bash 01-init.sh
# 注意：该脚本会在 /tmp 下创建临时目录，运行结束后会清理，绝不污染你的文件
# =============================================================================

echo "============================================"
echo "  01 创建第一个仓库 — 实操脚本"
echo "============================================"
echo ""

# 1. 创建临时目录作为实验场地
TEMP_DIR="/tmp/git-learn-01-init-$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ">>> 当前工作目录：$TEMP_DIR"
echo ""

# 2. 看看这个空目录里有什么
echo ">>> 初始化前，目录内容："
ls -la
echo ""

# 3. 执行 git init —— 把普通文件夹变成 Git 仓库
echo ">>> 执行 git init："
git init
echo ""

# 4. 再次查看目录 —— 你会发现多了一个 .git 隐藏文件夹
echo ">>> 初始化后，目录内容（注意多了 .git）："
ls -la
echo ""

# 5. 探索 .git 目录的内部结构
echo ">>> .git 目录里面有什么？"
echo ""
echo "--- .git 的顶层内容 ---"
ls -la .git
echo ""

# 6. 看看 HEAD 文件 —— 它指向当前分支
echo "--- HEAD 文件的内容（告诉我当前在哪个分支上）---"
cat .git/HEAD
echo ""

# 7. 看看 config 文件 —— 仓库的本地配置
echo "--- config 文件的内容（这个仓库的设置）---"
cat .git/config
echo ""

# 8. 看看 objects 目录 —— 存放所有版本数据的库房
echo "--- objects 目录（存放版本数据的地方，现在还是空的，只有两个空子目录）---"
ls -la .git/objects
echo ""

# 9. 看看 refs 目录 —— 存放分支和标签的引用
echo "--- refs 目录（存放分支指针的地方）---"
ls -la .git/refs
echo ""

# 10. 验证：再执行一次 git init 会怎样？
echo ">>> 在已经初始化的仓库中再次执行 git init："
git init
echo "（Git 会告诉你这已经是仓库了，不会造成破坏）"
echo ""

# 11. 如果用 git status 看看当前状态（下一节会详细讲）
echo ">>> 查看仓库当前状态："
git status
echo ""

# 清理：删除临时目录
echo "============================================"
echo "  脚本执行完毕，清理临时目录..."
echo "============================================"
cd /tmp || exit
rm -rf "$TEMP_DIR"
echo ">>> 已删除临时目录 $TEMP_DIR"
echo ""
echo "提示：你电脑上的文件完全没有被影响，放心就好。"
