#!/bin/bash
# ============================================================
# 05-Fork工作流深入 - 示例脚本
# 功能：在本地模拟 Fork 工作流的完整操作
#       包括 clone → 添加上游 → 创建分支 → 合并 → 同步上游
# ============================================================

set -e

echo "========================================"
echo "  Fork 工作流完整演示脚本"
echo "========================================"
echo ""

# -----------------------------------------------------------
# 第一步：创建临时目录，模拟整个工作环境
# -----------------------------------------------------------
DEMO_DIR=$(mktemp -d /tmp/fork-demo-XXXXXX)
cd "$DEMO_DIR"
echo "[INFO] 演示目录：$DEMO_DIR"
echo ""

# -----------------------------------------------------------
# 第二步：模拟"上游仓库"（原作者的项目）
# -----------------------------------------------------------
echo ">>> 第一步：模拟创建一个"上游仓库"（原作者的项目）"
echo ""

mkdir upstream-repo
cd upstream-repo
git init

echo "# 开源项目" > README.md
echo "这是一个很棒的开源项目。" >> README.md
echo "console.log('Hello');" > app.js

git add .
git commit -m "初始提交：项目骨架"

echo ""
echo "   [模拟] 这是原作者在 GitHub 上的仓库。"
echo "   仓库路径：$DEMO_DIR/upstream-repo"
echo ""

cd "$DEMO_DIR"

# -----------------------------------------------------------
# 第三步：模拟"Fork"操作（创建原仓库的一个副本）
# -----------------------------------------------------------
echo ">>> 第二步：模拟 Fork —— 创建原仓库的副本"
echo ""

# 在真实场景中，Fork 是 GitHub 网页上的操作（点击 Fork 按钮）
# 在这里，我们用 git clone --bare + git clone 来模拟 Fork 的效果
git clone --bare upstream-repo fork-bare.git
git clone fork-bare.git my-fork

echo ""
echo "   [模拟] 这是你 GitHub 账户下的 Fork 副本。"
echo "   仓库路径：$DEMO_DIR/my-fork"
echo ""

cd "$DEMO_DIR/my-fork"

# -----------------------------------------------------------
# 第四步：添加 upstream
# -----------------------------------------------------------
echo ">>> 第三步：git remote add upstream —— 添加上游仓库"
echo ""

# 在真实场景中，upstream 指向原作者的 GitHub 仓库地址
git remote add upstream ../upstream-repo

echo "   命令：git remote add upstream ../upstream-repo"
echo "   (真实场景中是：git remote add upstream git@github.com:原作者/原仓库.git)"
echo ""

echo ">>> 第四步：git remote -v —— 查看所有远程地址"
echo ""

git remote -v

echo ""
echo "   origin    → 你的 Fork 副本（你有推送权限）"
echo "   upstream  → 原作者的仓库（你通常只能拉取）"
echo ""

# -----------------------------------------------------------
# 第五步：创建功能分支，写代码
# -----------------------------------------------------------
echo ">>> 第五步：创建功能分支 —— 永远不在 main 上直接改"
echo ""

git checkout -b fix-typo

echo "   命令：git checkout -b fix-typo"
echo "   分支 fix-typo 已创建并切换。现在所有修改都在这个分支上。"
echo ""

# 修改文件
echo "# 开源项目（修正了标题）" > README.md
echo "这是一个很棒的开源项目。" >> README.md
echo "贡献指南请看 CONTRIBUTING.md" >> README.md

git status

echo ""

# 暂存并提交
git add README.md
git commit -m "修复 README 标题拼写并补充贡献指南"

echo ""
echo "   命令：git commit -m '修复 README 标题拼写并补充贡献指南'"
echo ""

# -----------------------------------------------------------
# 第六步：推送功能分支到 origin
# -----------------------------------------------------------
echo ">>> 第六步：git push origin —— 推送到你的 Fork 副本"
echo ""

git push origin fix-typo

echo ""
echo "   命令：git push origin fix-typo"
echo "   推送到 origin（你的副本），不是 upstream（原仓库）。"
echo "   真实场景中，推完后去 GitHub 网页点击 "Compare & pull request"。"
echo ""

# -----------------------------------------------------------
# 第七步：模拟原仓库在这期间有了更新
# -----------------------------------------------------------
echo ">>> 第七步：模拟上游仓库在你 Fork 之后又有了新提交"
echo ""

cd "$DEMO_DIR/upstream-repo"

# 原作者在主分支上加了新功能
echo "" >> app.js
echo "console.log('新功能：Goodbye too');" >> app.js
git add app.js
git commit -m "原仓库增加新功能：告别功能"

echo ""
echo "   [模拟] 原作者在上游仓库新增了功能。"
echo "   你的 Fork 不会自动获得这个更新——需要手动同步。"
echo ""

# -----------------------------------------------------------
# 第八步：同步上游更新到本地
# -----------------------------------------------------------
echo ">>> 第八步：同步上游更新到你的本地仓库"
echo ""

cd "$DEMO_DIR/my-fork"

# 切换到 main 分支
git checkout main

# 从上游拉取最新代码
echo "--- git fetch upstream ---"
git fetch upstream
echo ""

# 查看上游的最新提交
echo "--- 上游仓库的提交历史 ---"
git log upstream/main --oneline
echo ""

# 把上游的 main 合并到本地 main
echo "--- git merge upstream/main ---"
git merge upstream/main -m "同步上游更新"
echo ""

echo "   命令序列："
echo "   git checkout main         → 切换到主分支"
echo "   git fetch upstream        → 从上游拉取最新信息"
echo "   git merge upstream/main   → 把上游合并到本地"
echo ""

# -----------------------------------------------------------
# 第九步：把同步后的 main 推送到 origin
# -----------------------------------------------------------
echo ">>> 第九步：把同步后的 main 推送到你的 Fork 副本"
echo ""

git push origin main

echo ""
echo "   命令：git push origin main"
echo "   现在你的 GitHub Fork 副本也和上游同步了。"
echo ""

# -----------------------------------------------------------
# 第十步：把更新后的 main 合并到功能分支
# -----------------------------------------------------------
echo ">>> 第十步：把 main 的更新合并到功能分支"
echo ""

git checkout fix-typo
git merge main -m "合并上游最新更新到功能分支"

echo ""
echo "   命令序列："
echo "   git checkout fix-typo      → 切换回功能分支"
echo "   git merge main             → 把 main（已包含上游更新）合并进来"
echo ""

# -----------------------------------------------------------
# 第十一步：查看最终状态
# -----------------------------------------------------------
echo ">>> 第十一步：查看最终状态"
echo ""

echo "--- 分支列表 ---"
git branch
echo ""

echo "--- main 分支的提交历史 ---"
git log main --oneline
echo ""

echo "--- fix-typo 分支的提交历史 ---"
git log fix-typo --oneline
echo ""

echo "--- 最终远程配置 ---"
git remote -v
echo ""

# -----------------------------------------------------------
# 第十二步：完整流程回顾
# -----------------------------------------------------------
echo ">>> 第十二步：完整 Fork 工作流回顾"
echo ""

cat << 'STEPS'
   Fork 工作流完整步骤总结

   【一次性配置】
   ① GitHub 网页点击 Fork 按钮         → 在你的账户下创建副本
   ② git clone <你的Fork地址>           → 下载到本地
   ③ git remote add upstream <原仓库地址> → 建立上游关系

   【每次开发新功能】
   ④ git checkout -b 新功能分支名       → 创建功能分支
   ⑤ 写代码 + git add + git commit      → 提交修改
   ⑥ git push origin 新功能分支名       → 推到你的 Fork 副本
   ⑦ 在 GitHub 网页点击 Compare & pull request → 向原作者提交 PR

   【定期同步上游】
   ⑧ git checkout main                  → 切换到主分支
   ⑨ git fetch upstream                 → 拉取上游最新信息
   ⑩ git merge upstream/main            → 合入上游更新
   ⑪ git push origin main               → 推送到你的 Fork 副本
   ⑫ (在功能分支上) git merge main      → 同步到功能分支

   关键记忆点：
   ┌──────────────────────────────────────────────────┐
   │  origin   = 你的 Fork 副本 = 你有推送权限         │
   │  upstream = 原作者的仓库  = 你只有拉取权限        │
   │                                                    │
   │  Fork 在 GitHub 网页上操作（不是命令行）           │
   │  Clone 把代码下载到本地电脑                       │
   │  PR 是把你的修改"提议"给原作者                    │
   └──────────────────────────────────────────────────┘
STEPS

echo ""

# -----------------------------------------------------------
# 清理
# -----------------------------------------------------------
echo ">>> 清理临时文件"
echo ""

cd /tmp
rm -rf "$DEMO_DIR"

echo "[OK] 演示结束，临时文件已清理。"
echo ""
echo "========================================"
echo "  要在真实项目中实践 Fork 工作流："
echo "  1. 在 GitHub 上找一个感兴趣的开源项目"
echo "  2. 点击 Fork 按钮"
echo "  3. Clone 你的 Fork 到本地"
echo "  4. 按上面的步骤走一遍"
echo "========================================"
