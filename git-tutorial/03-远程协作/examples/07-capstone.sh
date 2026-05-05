#!/bin/bash
# ============================================================
# 07-综合练习：模拟参与开源项目 — 示例脚本
# 目标：完整走一遍远程协作流程
# 说明：用本地裸仓库模拟"原项目"和"你的 Fork"
#        让你在没有 GitHub 账号的情况下也能练习完整流程
# ============================================================

echo "========================================="
echo "  07 - 综合练习：完整远程协作流程"
echo "  模拟场景：Fork → Clone → 建分支 → 修改 → Push → 提 PR"
echo "========================================="
echo ""

# ----------------------------------------------------------
# 步骤1：创建临时练习目录
# ----------------------------------------------------------
TEMP_DIR="/tmp/git-tutorial-capstone"
echo ">>> 创建临时练习目录: $TEMP_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ""

# ==========================================================
# 场景设定
# ==========================================================
# "原项目"(upstream-project)     -- 模拟 octocat/Spoon-Knife
# "远程原始仓库"(upstream.git)   -- 模拟 GitHub 上的原项目
# "你的 Fork"(my-fork.git)       -- 模拟你 Fork 后的仓库
# ==========================================================

echo "========================================="
echo "  场景：你要参与一个开源项目"
echo "  原项目网址: github.com/maintainer/cool-project"
echo "========================================="
echo ""

# ----------------------------------------------------------
# 步骤2：创建"原项目"——模拟项目维护者的仓库
# ----------------------------------------------------------
echo ">>> 第1步：创建原项目（模拟项目维护者已发布的项目）"
echo "    类比：一个已经在 GitHub 上很成熟的公开项目"
echo ""

mkdir upstream-source
cd upstream-source || exit 1
git init
git branch -m main

echo "<!DOCTYPE html>" > index.html
echo "<html>" >> index.html
echo "<head><title>Cool Project</title></head>" >> index.html
echo "<body>" >> index.html
echo "  <h1>Welcome to Cool Project</h1>" >> index.html
echo "  <!-- 页面主体内容 -->" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html

git add index.html
git commit -m "初始提交: 项目骨架"

echo "* { margin: 0; padding: 0; }" > style.css
echo "body { font-family: sans-serif; }" >> style.css
git add style.css
git commit -m "添加基础样式"

echo "console.log('App loaded');" > app.js
git add app.js
git commit -m "添加 JavaScript 入口文件"

echo ""
echo "原项目的提交历史："
git log --oneline
echo ""

# 创建模拟"GitHub 上的原项目"（裸仓库）
cd "$TEMP_DIR" || exit 1
git clone --bare upstream-source upstream.git
echo ""
echo "原项目的远程仓库创建完毕: upstream.git"
echo "（这模拟的是 GitHub 上 maintainer/cool-project）"
echo ""

# ----------------------------------------------------------
# 步骤3：模拟 Fork ——在本地创建"你的 Fork"
#         在真实场景中，你在 GitHub 点 Fork 按钮
#         这里用 clone --bare 再 clone 来模拟
# ----------------------------------------------------------
echo ">>> 第2步：Fork 原项目到你的账号下"
echo "    类比：在 GitHub 网页上点 Fork 按钮"
echo "    效果：你的账号下多了一个完整的项目副本"
echo ""

# 创建"你的 Fork"（裸仓库模拟你的 GitHub 账号下的仓库）
git clone --bare upstream.git my-fork.git
echo ""
echo "Fork 完成！现在你的账号下有: my-fork.git"
echo "（这模拟的是 GitHub 上 你的用户名/cool-project）"
echo ""

# ----------------------------------------------------------
# 步骤4：Clone 你的 Fork 到本地
#         在真实场景中: git clone https://github.com/你的用户名/cool-project.git
# ----------------------------------------------------------
echo ">>> 第3步：Clone 你的 Fork 到本地电脑"
echo "    类比：git clone https://github.com/你的用户名/cool-project.git"
echo ""

git clone "$TEMP_DIR/my-fork.git" my-local-project
cd my-local-project || exit 1

echo ""
echo "当前目录内容："
ls -la
echo ""

echo "提交历史（来自原项目的完整历史！）："
git log --oneline
echo ""

echo "远程仓库配置："
git remote -v
echo "（origin 指向你的 Fork，不是原项目）"
echo ""

# ----------------------------------------------------------
# 步骤5：添加 upstream（原项目地址）
#         好习惯：方便以后同步原项目的最新代码
# ----------------------------------------------------------
echo ">>> 第4步：添加 upstream（原项目的地址）"
echo "    好习惯！这样以后可以同步原项目的更新"
echo ""

git remote add upstream "$TEMP_DIR/upstream.git"
echo "现在远程仓库配置如下："
git remote -v
echo ""
echo "  origin   -> 你的 Fork（你可以 push）"
echo "  upstream -> 原项目（你只能 pull）"
echo ""

# ----------------------------------------------------------
# 步骤6：创建功能分支
#         永远不要在 main 分支上直接改！
# ----------------------------------------------------------
echo ">>> 第5步：创建功能分支"
echo "    黄金法则：永远不要在 main 分支上直接修改！"
echo ""

git checkout -b add-html-description
echo ""
echo "当前分支："
git branch
echo ""

# ----------------------------------------------------------
# 步骤7：修改代码并提交
#         模拟你为项目做出贡献
# ----------------------------------------------------------
echo ">>> 第6步：修改代码"
echo "    你要在 index.html 中添加一段描述注释"
echo ""

# 在 index.html 的注释中增加内容
# 先把文件读出来，修改，再写回去
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head><title>Cool Project</title></head>
<body>
  <h1>Welcome to Cool Project</h1>
  <!-- 页面主体内容 -->
  <!-- 项目描述：这是一个演示项目，用于展示 Git 远程协作流程 -->
</body>
</html>
HTMLEOF

echo "修改后的 index.html："
cat index.html
echo ""

echo "查看改动 (git diff)："
echo "----------------------------------------"
git diff
echo "----------------------------------------"
echo ""

echo "提交修改："
git add index.html
git commit -m "在 index.html 中添加项目描述注释"
echo ""

# ----------------------------------------------------------
# 步骤8：推送到你的远程仓库（你的 Fork）
# ----------------------------------------------------------
echo ">>> 第7步：推送到你的远程仓库（你的 Fork）"
echo "    类比：git push -u origin add-html-description"
echo ""

git push -u origin add-html-description
echo ""
echo "推送成功！你的分支现在在你自己的远程仓库中了"
echo "（在真实场景中，打开 GitHub 你的 Fork 页面就能看到这个分支）"
echo ""

# ----------------------------------------------------------
# 步骤9：模拟 "在 GitHub 上创建 PR"
#         实际操作中你在网页上点按钮
#         这里用命令行 fetc 来模拟"原项目看到你的改动"
# ----------------------------------------------------------
echo ">>> 第8步：模拟创建 Pull Request"
echo "    在真实场景中，你会在 GitHub 网页上操作："
echo "    1. 进入你的 Fork 页面"
echo "    2. 点击 'Compare & pull request'"
echo "    3. 填写 PR 标题和描述"
echo "    4. 点击 'Create pull request'"
echo ""
echo "    此时原项目的维护者就能看到你的改动了"
echo ""

# 模拟：让"原项目"那边能看到你的分支
# 维护者可以通过 git fetch 来检查你的 PR
echo "模拟维护者视角——查看你的 PR 内容："
echo ""
echo "# 维护者执行: git fetch <你的Fork地址> add-html-description"
cd "$TEMP_DIR" || exit 1
git clone upstream.git maintainer-view
cd maintainer-view || exit 1
git remote add contributor "$TEMP_DIR/my-fork.git"
git fetch contributor add-html-description
echo ""

echo "维护者可以看到你的分支:"
git branch -a | grep contributor
echo ""

echo "维护者查看差异 (git diff main..contributor/add-html-description):"
echo "----------------------------------------"
git diff main..contributor/add-html-description 2>&1 || git diff origin/main..contributor/add-html-description
echo "----------------------------------------"
echo ""

echo "如果维护者觉得改动 OK，就会合并！"
echo ""

# ----------------------------------------------------------
# 步骤10："维护者合并 PR"
#         在真实场景中，维护者点 GitHub 网页上的 Merge 按钮
# ----------------------------------------------------------
echo ">>> 第9步：维护者合并你的 PR"
echo "    类比：维护者在 GitHub 网页上点 Merge 按钮"
echo ""

cd "$TEMP_DIR/maintainer-view" || exit 1
# 模拟维护者合并 PR
git merge contributor/add-html-description -m "Merge PR: 在 index.html 中添加项目描述注释"
echo ""

echo "合并后原项目的提交历史："
git log --oneline
echo ""
echo "你的贡献现在已经进入原项目了！"
echo ""

# ----------------------------------------------------------
# 步骤11：同步——你把原项目的最新代码拉下来
# ----------------------------------------------------------
echo ">>> 第10步：同步你的本地仓库"
echo "    PR 被合并后，你应该从原项目拉取最新代码"
echo ""

cd "$TEMP_DIR/my-local-project" || exit 1

echo "从 upstream（原项目）拉取："
git pull upstream main
echo ""

echo "现在你的本地 main 也有了那个合并提交："
git log --oneline
echo ""

echo "推送到你的 Fork，保持同步："
git push origin main
echo ""

# ----------------------------------------------------------
# 步骤12：清理本地功能分支
# ----------------------------------------------------------
echo ">>> 第11步：清理功能分支"
echo ""

git checkout main

echo "删除本地分支："
git branch -d add-html-description
echo ""

echo "删除远程分支（如果你的 Fork 上不需要了）："
git push origin --delete add-html-description 2>&1 || echo "（可能已经不存在了）"
echo ""

echo "当前分支状态："
git branch -a
echo ""

# ==========================================================
# 完整流程总结
# ==========================================================
echo "========================================="
echo "  完整流程回顾"
echo "========================================="
echo ""
echo "  步骤  你在做什么                   类比"
echo "  ────  ────────────────────────    ──────────────────"
echo "  1.    看到原项目                    在 GitHub 上浏览"
echo "  2.    Fork 到自己的账号            复制一份到云空间"
echo "  3.    git clone 你的 Fork          下载到你的电脑"
echo "  4.    git remote add upstream      记下原项目的地址"
echo "  5.    git checkout -b xxx          创建功能分支"
echo "  6.    修改代码 + git commit        写代码并拍照"
echo "  7.    git push origin xxx          上传到你的远程"
echo "  8.    在 GitHub 创建 PR            请维护者审查"
echo "  9.    审查讨论、修改                根据反馈改进"
echo "  10.   维护者 Merge PR              你的代码进入原项目！"
echo ""
echo "恭喜！你完成了远程协作的完整流程！"
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
echo "  $TEMP_DIR/upstream-source     -- 原项目（工作目录版本）"
echo "  $TEMP_DIR/upstream.git        -- 原项目（裸仓库，模拟 GitHub）"
echo "  $TEMP_DIR/my-fork.git         -- 你的 Fork（模拟 GitHub 上的副本）"
echo "  $TEMP_DIR/my-local-project    -- 你的本地开发目录"
echo "  $TEMP_DIR/maintainer-view     -- 维护者视角的本地仓库"
echo ""
echo "想清理的话，执行: rm -rf $TEMP_DIR"
echo ""
echo "========================================="
echo "  远程协作模块全部学完！"
echo "  你现在可以："
echo "    - 在本地管理版本（add, commit, log, diff）"
echo "    - 使用分支（branch, checkout, merge）"
echo "    - 推送和拉取（push, pull, fetch）"
echo "    - 管理远程分支（remote branches, tracking）"
echo "    - 使用 GitHub（创建仓库, Issues, Star）"
echo "    - 提交 Pull Request"
echo "========================================="
