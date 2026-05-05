#!/bin/bash
# ============================================================================
# 01-什么是分支 - 示例脚本
# 本脚本创建一个临时 Git 仓库，演示分支的基本概念
# 用途：直观感受"分支就是代码历史的平行线"
# ============================================================================

set -e  # 遇到错误立即退出

# 创建临时目录
WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"
echo "==> 在临时目录创建演示仓库：$WORK_DIR"

# 初始化 Git 仓库
git init
# 设置本地用户信息（避免依赖全局配置）
git config user.email "demo@example.com"
git config user.name "Git教程演示"
echo "==> Git 仓库初始化完成"

# 创建第一个文件，做第一次提交（相当于日记的"周一"）
echo "日记：周一 - 今天天气晴朗" > diary.txt
git add diary.txt
git commit -m "周一：开始写日记" --quiet
git branch -m main  # 将默认分支重命名为 main（兼容不同 Git 版本）
echo "==> 第 1 次提交：周一日记"

# 第二次提交（"周二"）
echo "日记：周二 - 和朋友去爬山" >> diary.txt
git add diary.txt
git commit -m "周二：和朋友去爬山" --quiet
echo "==> 第 2 次提交：周二日记"

# 第三次提交（"周三"）
echo "日记：周三 - 开始写代码学习项目" >> diary.txt
git add diary.txt
git commit -m "周三：开始写代码" --quiet
echo "==> 第 3 次提交：周三日记"

echo ""
echo "+--------------------------------------------------+"
echo "|  当前仓库状态：主分支 main 上有 3 次提交           |"
echo "|  历史线：周一 -- 周二 -- 周三                      |"
echo "+--------------------------------------------------+"
echo ""

# 查看提交历史（一条直线）
echo "==> 查看提交历史（目前是一条直线）："
git log --oneline --graph --all

echo ""
echo "===================================================="
echo "  现在，我们在"周三"之后创建一个新分支 IF线"
echo "  新分支将从这个分叉点开始独立的旅程"
echo "===================================================="
echo ""

# 创建新分支 IF线（相当于游戏的"支线任务"）
git branch IF线
echo "==> 创建了新分支 'IF线'（还没有切换过去）"
echo "    当前仍在 main 分支上"

# 显示所有分支
echo ""
echo "==> 查看所有分支（* 号标记当前所在分支）："
git branch

echo ""
echo "===================================================="
echo "  观察：此时 main 和 IF线 指向同一个位置（周三）"
echo "  它们还没有分叉，因为 IF线上还没有新的提交"
echo "===================================================="
echo ""

# 切换到 IF线 分支
git checkout IF线

# 在 IF线 上做新提交（"周四IF线版"）
echo "日记：周四（IF线）- 今天没有写代码，去钓鱼了" >> diary.txt
git add diary.txt
git commit -m "周四（IF线）：去钓鱼" --quiet
echo "==> 在 IF线 分支上创建了'周四IF线版'的提交"

# 在 IF线 上再做一次提交（"周五IF线版"）
echo "日记：周五（IF线）- 继续钓鱼，钓到了一条大鱼" >> diary.txt
git add diary.txt
git commit -m "周五（IF线）：钓到大鱼" --quiet
echo "==> 在 IF线 分支上创建了'周五IF线版'的提交"

echo ""
echo "==> 现在用 graph 模式查看历史，你会看到分叉："
git log --oneline --graph --all

echo ""
echo "===================================================="
echo "  观察 ASCII 图："
echo "  - main 分支停留在'周三'"
echo "  - IF线 分支从'周三'分叉出去，多了两次提交"
echo "  - 这就是分支的'平行宇宙'效果！"
echo "===================================================="
echo ""

# 回到 main 分支，也做一些不同的事情
git checkout main
echo "日记：周四（主线）- 继续写代码，完成了登录页面" >> diary.txt
git add diary.txt
git commit -m "周四（主线）：完成登录页面" --quiet
echo "==> 回到 main 分支，也创建了不同的'周四'内容"

echo ""
echo "==> 最终的分支图（两条平行的故事线）："
git log --oneline --graph --all

echo ""
echo "===================================================="
echo "  总结："
echo "  - main 和 IF线 从同一个地方（周三）出发"
echo "  - 各自走了不同的路（不同的内容）"
echo "  - 互不影响，就像平行宇宙"
echo "  - 下一节学习如何在这两个分支之间切换"
echo "===================================================="
echo ""
echo "演示仓库位于：$WORK_DIR"
echo "如果想删除，可以手动执行：rm -rf $WORK_DIR"
