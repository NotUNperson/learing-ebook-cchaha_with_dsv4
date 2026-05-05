#!/bin/bash
# ============================================================
# 03-推送和拉取 — 示例脚本
# 目标：理解 git push 和 git pull 的工作方式
# 说明：用本地裸仓库模拟远程仓库，演示 push/pull 流程
# ============================================================

echo "========================================="
echo "  03 - 推送和拉取：示例脚本"
echo "========================================="
echo ""

# ----------------------------------------------------------
# 步骤1：创建临时练习目录
# ----------------------------------------------------------
TEMP_DIR="/tmp/git-tutorial-push-pull"
echo ">>> 创建临时练习目录: $TEMP_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ""

# ----------------------------------------------------------
# 步骤2：创建一个"模拟远程仓库"
#         用裸仓库（bare repo）模拟 GitHub 上的远程仓库
# ----------------------------------------------------------
echo ">>> 第1步：创建一个模拟远程仓库（裸仓库）"
echo "    类比：在 GitHub 上创建了一个空仓库"
echo ""

# 先创建一个普通仓库
mkdir remote-repo-source
cd remote-repo-source || exit 1
git init
git branch -m main
echo "# 共享项目" > README.md
git add README.md
git commit -m "初始提交"

# 创建裸仓库模拟远程
cd "$TEMP_DIR" || exit 1
git clone --bare remote-repo-source remote-repo.git
echo ""
echo "模拟远程仓库创建完毕: remote-repo.git"
echo ""

# ----------------------------------------------------------
# 步骤3：模拟"小明的电脑"—— clone 远程仓库
# ----------------------------------------------------------
echo ">>> 第2步：小明 clone 远程仓库到自己的电脑"
echo "    类比：小明从云端下载了项目到自己的电脑"
echo ""

git clone "$TEMP_DIR/remote-repo.git" xiaoming-workspace
cd xiaoming-workspace || exit 1
echo ""
echo "小明的工作目录内容："
ls -la
echo ""
echo "小明的提交历史："
git log --oneline
echo ""
echo "小明的远程仓库配置："
git remote -v
echo ""

# ----------------------------------------------------------
# 步骤4：小明做一些修改，然后推送
#         用"发信"类比
# ----------------------------------------------------------
echo ">>> 第3步：小明修改代码并推送到远程（发信）"
echo "    类比：小明写了一封信，发给了云端的信箱"
echo ""

echo "小明添加了一个新文件..."
echo "def add(a, b): return a + b" > calculator.py
git add calculator.py
git commit -m "小明: 添加计算器模块"

echo ""
echo "小明推送前，查看本地提交："
git log --oneline
echo ""

echo "小明执行推送：git push origin main"
git push origin main
echo ""
echo "推送成功！远程仓库现在有了小明的提交"
echo ""

# ----------------------------------------------------------
# 步骤5：模拟"小美的电脑"—— clone 同一份远程仓库
# ----------------------------------------------------------
echo ">>> 第4步：小美 clone 同一份远程仓库到自己的电脑"
echo "    类比：小美也从云端下载了同一个项目"
echo ""

cd "$TEMP_DIR" || exit 1
git clone "$TEMP_DIR/remote-repo.git" xiaomei-workspace
cd xiaomei-workspace || exit 1
echo ""
echo "小美的提交历史（已经包含小明的提交了哦！）："
git log --oneline
echo ""
echo "注意：小美 clone 的时候，小明的提交已经在远程了"
echo "所以小美直接拿到了小明的 calculator.py"
echo ""

# ----------------------------------------------------------
# 步骤6：小美也做修改，推送到远程
# ----------------------------------------------------------
echo ">>> 第5步：小美也修改代码并推送"
echo ""

echo "小美修改了 README..."
echo "# 共享项目 - 两人协作" > README.md
git add README.md
git commit -m "小美: 更新 README 标题"
echo ""

echo "小美推送：git push origin main"
git push origin main
echo ""

# ----------------------------------------------------------
# 步骤7：小明想推送新修改，但远程已经有小美的新提交了
#         这就是 "push 被拒绝" 的场景
# ----------------------------------------------------------
echo ">>> 第6步：小明又做了修改，尝试推送，但远程已有小美的更新"
echo "    类比：小明想往信箱里放信，但信箱里已经有一封小美的信了"
echo ""

cd "$TEMP_DIR/xiaoming-workspace" || exit 1

echo "小明修改了 README..."
echo "# 共享项目 - 小明改的标题" > README.md
git add README.md
git commit -m "小明: 更新 README 标题"
echo ""

echo "小明尝试推送：git push origin main"
echo "----------------------------------------"
git push origin main 2>&1 || true
echo "----------------------------------------"
echo ""
echo "推送被拒绝了！因为远程有小明本地没有的新提交（小美的）"
echo ""

# ----------------------------------------------------------
# 步骤8：小明先拉取，解决冲突或自动合并，再推送
#         这就是 "先收信，再发信"
# ----------------------------------------------------------
echo ">>> 第7步：小明先 pull（收信），再 push（发信）"
echo "    类比：先取出信箱里别人的信，再放入自己的信"
echo ""

echo "小明拉取远程更新：git pull origin main"
git pull origin main 2>&1 || true
echo ""

# 如果有冲突，这里会提示。本脚本中会产生冲突，我们需要解决
# 查看冲突状态
echo "查看合并状态："
git status 2>&1 || true
echo ""

echo "如果有冲突，解决冲突..."
# 手动编辑 README.md 解决冲突
echo "# 共享项目 - 两人协作修改" > README.md
git add README.md
# 完成合并提交（git pull 自动产生的 merge commit）
# 如果冲突已解决，完成合并
git commit -m "解决合并冲突" 2>&1 || echo "可能已经是干净状态"

echo ""
echo "现在再推送：git push origin main"
git push origin main 2>&1 || true
echo ""
echo "推送成功！"
echo ""

# ----------------------------------------------------------
# 步骤9：演示 git fetch vs git pull
# ----------------------------------------------------------
echo ">>> 第8步：演示 git fetch 和 git pull 的区别"
echo ""

cd "$TEMP_DIR/xiaomei-workspace" || exit 1

# 先在远程做变更（通过小明那边 push）
cd "$TEMP_DIR/xiaoming-workspace" || exit 1
echo "print('v2.0')" > version.py
git add version.py
git commit -m "小明: 添加版本文件"
git push origin main

echo ""
echo "小明推送了新的提交到远程"
echo ""

# 小美先 fetch
cd "$TEMP_DIR/xiaomei-workspace" || exit 1

echo "小美执行 git fetch（只下载，不合并）："
git fetch origin
echo ""

echo "fetch 之后，小美的本地 main 分支没有变化："
git log --oneline -3
echo ""

echo "但远程分支 origin/main 有了新提交："
git log --oneline origin/main -3
echo ""

echo "小美查看了远程的更新，决定合并："
git merge origin/main
echo ""

echo "合并后，小美的本地 main 也有了新提交："
git log --oneline -3
echo ""

echo ""
echo "对比："
echo "  git fetch     = 从邮局取了信，但没拆开（只下载，不合并）"
echo "  git pull      = 从邮局取了信，直接拆开读了（下载 + 合并）"
echo ""

# ----------------------------------------------------------
# 总结
# ----------------------------------------------------------
echo "========================================="
echo "  概念总结"
echo "========================================="
echo ""
echo "  工作流速查："
echo ""
echo "  1. git add . && git commit -m \"...\"  （本地提交）"
echo "  2. git pull origin main              （先拉取远程更新）"
echo "  3. git push origin main              （推送到远程）"
echo ""
echo "  记住口诀：先拉后推，避免冲突"
echo "  类比：先收信，再发信，信箱不打架"
echo ""

# ----------------------------------------------------------
# 清理提示
# ----------------------------------------------------------
echo "========================================="
echo "  练习完成！"
echo "========================================="
echo ""
echo "本脚本的练习文件在: $TEMP_DIR"
echo "你可以探索各个目录："
echo "  $TEMP_DIR/xiaoming-workspace   -- 小明的本地仓库"
echo "  $TEMP_DIR/xiaomei-workspace    -- 小美的本地仓库"
echo "  $TEMP_DIR/remote-repo.git      -- 模拟的远程仓库"
echo ""
echo "想清理的话，执行: rm -rf $TEMP_DIR"
echo ""
echo "下一节: 04-远程分支管理"
