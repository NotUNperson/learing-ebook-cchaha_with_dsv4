#!/bin/bash
# ============================================================================
# 05-变基入门 - 示例脚本
# 演示 git rebase 的基本操作和 rebase vs merge 的区别
# ============================================================================

set -e

WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"
echo "==> 演示仓库：$WORK_DIR"

git init
# 设置本地用户信息（避免依赖全局配置）
git config user.email "demo@example.com"
git config user.name "Git教程演示"

# 创建初始提交
echo "// 第一个功能：用户登录" > app.js
git add app.js
git commit -m "功能：用户登录" --quiet

echo "// 第二个功能：用户退出" >> app.js
git add app.js
git commit -m "功能：用户退出" --quiet

# 创建一个独立文件用于后续演示
echo "// 配置文件：默认设置" > config.js
git add config.js
git commit -m "添加配置文件" --quiet
git branch -m main  # 将默认分支重命名为 main（兼容不同 Git 版本）

echo ""
echo "========================================="
echo "  初始状态：main 上有 3 次提交"
echo "========================================="
git log --oneline --graph --all

# 创建 feature 分支，修改 app.js
git switch -c feature-theme

echo "// 主题功能：深色模式基础结构" >> app.js
git add app.js
git commit -m "主题：深色模式基础结构" --quiet

echo "// 主题功能：深色模式颜色配置" >> app.js
git add app.js
git commit -m "主题：深色模式颜色配置" --quiet

echo ""
echo "========================================="
echo "  feature-theme 分支上有 2 次提交"
echo "========================================="
echo "当前分支图："
git log --oneline --graph --all

# 回到 main，让 main 也往前走（修改独立文件，避免冲突）
git switch main

echo "// 搜索结果分页配置" >> config.js
git add config.js
git commit -m "功能：搜索结果分页" --quiet

echo ""
echo "========================================="
echo "  main 分支也新增了 1 次提交"
echo "  现在两边都有新内容"
echo "========================================="
echo "rebase 前的分支图："
git log --oneline --graph --all
echo ""
echo "解读："
echo "  main 分支：登录 -> 退出 -> 分页"
echo "  feature-theme：登录 -> 退出 -> 深色模式基础 -> 深色模式颜色"
echo "  它们从'退出'之后分叉了"

echo ""
echo "========================================="
echo "  执行 git rebase main"
echo "  把 feature-theme 的提交'搬'到 main 最新提交之后"
echo "========================================="

# 切换到 feature-theme
git switch feature-theme

# 执行 rebase
git rebase main

echo ""
echo "rebase 后的分支图："
git log --oneline --graph --all
echo ""
echo "观察：feature-theme 的两次提交现在'挂'在 main 的分页提交之后"
echo "历史变成了一条直线！"

echo ""
echo "========================================="
echo "  对比：如果当初用 merge 会怎样"
echo "========================================="

# 先回到 rebase 之前的状态，然后干净地演示 merge 方式的对比
git switch main
# 删除旧的 feature 分支，重建干净的演示环境
git branch -D feature-theme 2>/dev/null || true
git branch -D feature-theme-merge-demo 2>/dev/null || true
# 回到只有初始提交的状态
git reset --hard HEAD~1  # 回到只有 3 个初始提交
# 删除多余的旧分支
git branch -D feature-theme 2>/dev/null || true
git branch -D feature-theme-merge-demo 2>/dev/null || true

# 创建 feature-merge-demo
git switch -c feature-merge-demo
echo "// 合并演示：功能A 第一部分" >> app.js
git add app.js
git commit -m "合并演示：功能A-1" --quiet
echo "// 合并演示：功能A 第二部分" >> app.js
git add app.js
git commit -m "合并演示：功能A-2" --quiet

# main 也往前走（修改不同的文件，确保合并顺利不冲突）
git switch main
echo "// 合并演示：config 新选项" >> config.js
git add config.js
git commit -m "合并演示：config 功能" --quiet

# 用 merge 合并
git merge feature-merge-demo --no-edit

echo ""
echo "用 merge 后的分支图（注意有分叉和合并提交）："
git log --oneline --graph --all

echo ""
echo "========================================="
echo "  rebase vs merge 的可视化对比："
echo ""
echo "  merge 会产生：               rebase 会产生："
echo "  A--B--C--D--M               A--B--C--D--E'--F'"
echo "       \     /                    (一条直线)"
echo "        E--F"
echo ""
echo "  merge 保留分叉历史            rebase 让历史变直线"
echo "========================================="

echo ""
echo "========================================="
echo "  总结："
echo "  - git rebase <目标分支>   把当前分支的提交搬到目标分支末尾"
echo "  - rebase 让历史变成一条直线，但会生成新提交ID"
echo "  - merge 保留分叉历史，更安全"
echo "  - 黄金法则：不要 rebase 已推送的提交"
echo "========================================="
echo ""
echo "演示仓库位于：$WORK_DIR"
