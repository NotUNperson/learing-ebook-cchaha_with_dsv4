#!/bin/bash
# ============================================================
# 04-远程分支管理 — 示例脚本
# 目标：理解本地分支和远程分支的关系、跟踪分支
# 说明：用本地裸仓库模拟远程，演示远程分支的各种操作
# ============================================================

echo "========================================="
echo "  04 - 远程分支管理：示例脚本"
echo "========================================="
echo ""

# ----------------------------------------------------------
# 步骤1：创建临时练习目录
# ----------------------------------------------------------
TEMP_DIR="/tmp/git-tutorial-remote-branches"
echo ">>> 创建临时练习目录: $TEMP_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ""

# ----------------------------------------------------------
# 步骤2：创建一个"模拟远程仓库"
#         这个仓库有多个分支
# ----------------------------------------------------------
echo ">>> 第1步：创建模拟远程仓库（包含多个分支）"
echo ""

# 创建原始项目
mkdir project-source
cd project-source || exit 1
git init
git branch -m main
echo "# 项目" > README.md
git add README.md
git commit -m "初始提交"

# 创建 dev 分支
git checkout -b dev
echo "v0.1" > version.txt
git add version.txt
git commit -m "dev: 添加版本文件"

# 创建 feature 分支
git checkout -b feature-login
echo "login page placeholder" > login.html
git add login.html
git commit -m "feature: 添加登录页占位"

# 回到 main
git checkout main

# 创建裸仓库
cd "$TEMP_DIR" || exit 1
git clone --bare project-source remote-repo.git
echo ""
echo "模拟远程仓库创建完毕，它有这些分支："
git --git-dir=remote-repo.git branch
echo ""

# ----------------------------------------------------------
# 步骤3：clone 远程仓库，观察远程分支
# ----------------------------------------------------------
echo ">>> 第2步：clone 远程仓库，查看所有分支"
echo ""

git clone "$TEMP_DIR/remote-repo.git" my-workspace
cd my-workspace || exit 1

echo ""
echo "执行 git branch（只显示本地分支）："
echo "----------------------------------------"
git branch
echo "----------------------------------------"
echo "只看到 main —— 因为 clone 默认只 checkout 默认分支"
echo ""

echo "执行 git branch -r（只显示远程跟踪分支）："
echo "----------------------------------------"
git branch -r
echo "----------------------------------------"
echo "现在能看到 origin/main, origin/dev, origin/feature-login"
echo ""

echo "执行 git branch -a（显示所有分支）："
echo "----------------------------------------"
git branch -a
echo "----------------------------------------"
echo ""

echo "执行 git branch -vv（显示跟踪关系）："
echo "----------------------------------------"
git branch -vv
echo "----------------------------------------"
echo "可以看到 main 跟踪了 origin/main"
echo ""

# ----------------------------------------------------------
# 步骤4：从远程分支创建本地分支
#         图书馆借书类比
# ----------------------------------------------------------
echo ">>> 第3步：从远程分支 checkout 一个本地分支"
echo "    类比：你去图书馆看到一个书架上有本感兴趣的书，"
echo "          你把它借回家，放在自己书架上"
echo ""

echo "直接 checkout dev（Git 自动创建本地 dev 并跟踪 origin/dev）："
git checkout dev
echo ""

echo "现在查看本地分支："
git branch
echo ""

echo "查看跟踪关系："
git branch -vv
echo ""
echo "本地 dev 自动跟踪了 origin/dev"
echo ""

# ----------------------------------------------------------
# 步骤5：在本地创建新分支，推送到远程
# ----------------------------------------------------------
echo ">>> 第4步：本地创建新分支，推送到远程"
echo ""

git checkout -b feature-about-page
echo "<h1>About</h1>" > about.html
git add about.html
git commit -m "添加关于页面"
echo ""

echo "第一次推送，使用 -u 建立跟踪关系："
git push -u origin feature-about-page
echo ""

echo "推送后，远程仓库也有了 feature-about-page 分支"
echo ""

# 检查远程分支
echo "查看远程分支（-r）："
git branch -r
echo ""

# ----------------------------------------------------------
# 步骤6：本地和远程分支的 "ahead / behind"
#         这就是本地和远程的差异
# ----------------------------------------------------------
echo ">>> 第5步：观察本地和远程的差异"
echo "    类比：你家的书上有笔记（本地提交），"
echo "          图书馆的书还没有这些笔记（远程没收到）"
echo ""

echo "当前在 feature-about-page 分支，做一个新提交："
echo "<p>About us page</p>" >> about.html
git add about.html
git commit -m "完善关于页面内容"
echo ""

echo "查看状态：git status"
echo "----------------------------------------"
git status
echo "----------------------------------------"
echo "注意看: Your branch is ahead of 'origin/feature-about-page' by 1 commit."
echo "意思是本地比远程多 1 个提交（还没推送）"
echo ""

echo "查看详细跟踪关系：git branch -vv"
echo "----------------------------------------"
git branch -vv
echo "----------------------------------------"
echo ""

# ----------------------------------------------------------
# 步骤7：删除远程分支
# ----------------------------------------------------------
echo ">>> 第6步：删除远程分支"
echo ""

# 先推送刚才的提交
git push
echo ""

echo "删除远程的 feature-about-page 分支："
git push origin --delete feature-about-page
echo ""

echo "查看远程分支，确认已删除："
git branch -r
echo ""

echo "但本地的 feature-about-page 还在："
git branch
echo ""
echo "注意：删除远程分支不会删除本地分支"
echo ""

# 切回 main，删除本地分支
git checkout main
git branch -d feature-about-page

# ----------------------------------------------------------
# 步骤8：清理过时的远程引用
# ----------------------------------------------------------
echo ">>> 第7步：清理过时的远程引用（git fetch --prune）"
echo ""

echo "执行 fetch --prune 之前，先看看远程引用："
git branch -r
echo ""
echo "（feature-about-page 已经被删除了，所以这里已经没有了）"
echo ""

echo "模拟场景：手动添加一个过时的引用"
# 手动在 .git/refs/remotes/origin/ 下创建一个过期引用文件
mkdir -p .git/refs/remotes/origin
echo "fake-ref" > .git/refs/remotes/origin/old-deleted-branch
echo "已手动添加一个过时的远程引用 origin/old-deleted-branch"

echo ""
echo "git branch -r（现在能看到过期引用）："
git branch -r
echo ""

echo "执行 git fetch --prune："
git fetch --prune origin 2>&1 || true
echo ""

echo "再次查看远程分支（过时的引用被清理了）："
git branch -r
echo ""

# ----------------------------------------------------------
# 概念总结
# ----------------------------------------------------------
echo "========================================="
echo "  概念总结"
echo "========================================="
echo ""
echo "  本地分支 vs 远程分支 vs 远程跟踪分支"
echo ""
echo "  ┌────────────────────────────────────────────────┐"
echo "  │  本地分支 (main)                                │"
echo "  │  - 你日常工作的分支                              │"
echo "  │  - 可以做提交、修改、checkout                     │"
echo "  │  - 类比：你书架上的书，可以随便写笔记               │"
echo "  └────────────────────────────────────────────────┘"
echo "                        │"
echo "                        │ 跟踪关系 (tracking)"
echo "                        ▼"
echo "  ┌────────────────────────────────────────────────┐"
echo "  │  远程跟踪分支 (origin/main)                       │"
echo "  │  - 存在你本地，但反映的是远程的状态（上次同步时）     │"
echo "  │  - 不能直接 checkout 修改                        │"
echo "  │  - 只在 git fetch/pull 时更新                   │"
echo "  │  - 类比：图书馆书目快照，不是实时的                │"
echo "  └────────────────────────────────────────────────┘"
echo "                        │"
echo "                        │ fetch/push
echo "                        ▼"
echo "  ┌────────────────────────────────────────────────┐"
echo "  │  远程分支 (GitHub 上的 main)                      │"
echo "  │  - 存在 GitHub/服务器上                          │"
echo "  │  - 类比：图书馆书架上的书                         │"
echo "  └────────────────────────────────────────────────┘"
echo ""
echo "  记住：origin/main 不是实时更新的！"
echo "  它只是 cache（缓存），就像手机天气预报的缓存"
echo ""

# ----------------------------------------------------------
# 清理提示
# ----------------------------------------------------------
echo "========================================="
echo "  练习完成！"
echo "========================================="
echo ""
echo "本脚本的练习文件在: $TEMP_DIR"
echo "你可以探索："
echo "  cd $TEMP_DIR/my-workspace  进入练习仓库"
echo "  git branch -vv             查看跟踪关系"
echo "  git branch -a              查看所有分支"
echo ""
echo "想清理的话，执行: rm -rf $TEMP_DIR"
echo ""
echo "下一节: 05-GitHub基础操作"
