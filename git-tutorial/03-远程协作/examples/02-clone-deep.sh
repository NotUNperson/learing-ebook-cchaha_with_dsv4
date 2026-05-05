#!/bin/bash
# ============================================================
# 02-克隆仓库深入 — 示例脚本
# 目标：理解 git clone 到底下载了什么
# 说明：本脚本创建一个"模拟远程仓库"，然后用 clone 拉下来，
#        对比 clone 和直接复制文件（模拟 Download ZIP）的区别。
# ============================================================

echo "========================================="
echo "  02 - 克隆仓库深入：示例脚本"
echo "========================================="
echo ""

# ----------------------------------------------------------
# 步骤1：创建临时练习目录
# ----------------------------------------------------------
TEMP_DIR="/tmp/git-tutorial-clone-deep"
echo ">>> 创建临时练习目录: $TEMP_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ""

# ----------------------------------------------------------
# 步骤2：创建一个"模拟远程仓库"
#         在现实中，远程仓库在 GitHub 服务器上。
#         这里我们用本地的一个裸仓库（bare repo）来模拟。
#         裸仓库就是没有工作目录的仓库，只存 .git 内容。
# ----------------------------------------------------------
echo ">>> 第1步：创建一个模拟远程仓库（裸仓库）"
echo ""
echo "类比：在云端创建了一个空的 Git 仓库"
echo ""

# 创建一个普通仓库当作"原始项目"
mkdir original-project
cd original-project || exit 1
git init
git branch -m main   # 确保默认分支叫 main

# 创建一些文件并提交，模拟一个项目的历史
echo "# 我的开源项目" > README.md
git add README.md
git commit -m "初始提交: 添加 README"

echo "print('Hello')" > main.py
git add main.py
git commit -m "添加主程序"

echo "print('Hello World')" >> main.py
git add main.py
git commit -m "修改问候语"

mkdir utils
echo "def helper(): pass" > utils/helpers.py
git add utils/
git commit -m "添加工具模块"

echo "v1.0.0" > VERSION
git add VERSION
git commit -m "标记版本 v1.0.0"

echo ""
echo "原始项目的提交历史："
git log --oneline
echo ""

cd "$TEMP_DIR" || exit 1

# 用 clone --bare 创建一个裸仓库，模拟远程仓库
echo ">>> 用 --bare 模拟远程仓库"
git clone --bare original-project remote-repo.git
echo ""
echo "注意：remote-repo.git 就是一个模拟的远程仓库"
echo "它里面只有 .git 的内容，没有工作目录"
echo ""

# ----------------------------------------------------------
# 步骤3：模拟 "Download ZIP" — 只复制文件
#         在现实中，你从 GitHub 点 Download ZIP 按钮
#         拿到的就是这个效果
# ----------------------------------------------------------
echo ">>> 第2步：模拟 Download ZIP —— 只复制文件"
echo ""

# 创建一个普通的文件夹复制（不是 clone）
mkdir zip-download
cp -r original-project/* zip-download/       # 复制所有文件
cp original-project/.gitignore zip-download/ 2>/dev/null || true
# 但是 .git 目录不会通过 cp -r * 复制，而且我们故意不复制它
echo "文件已复制到 zip-download/ 目录"

echo ""
echo "在 zip-download 里查看文件："
ls -la zip-download/
echo ""
echo "尝试执行 git log："
echo "----------------------------------------"
cd zip-download || exit 1
git log 2>&1 || true
cd "$TEMP_DIR" || exit 1
echo "----------------------------------------"
echo "报错了！因为 zip-download 不是一个 Git 仓库"
echo "那里没有 .git 目录，没有版本历史"
echo ""
echo "类比：从云相册只下载了最新一张照片的图片文件，"
echo "      但不知道这张照片之前修改过几次"
echo ""

# ----------------------------------------------------------
# 步骤4：用 git clone 完整克隆
#         这才是正确的方式
# ----------------------------------------------------------
echo ">>> 第3步：用 git clone 克隆整个仓库"
echo ""

git clone "$TEMP_DIR/remote-repo.git" cloned-project
echo ""

echo "在 cloned-project 里："
echo "----------------------------------------"
cd cloned-project || exit 1

echo ""
echo "1. 查看文件列表（和 Download ZIP 一样有这些文件）："
ls -la
echo ""

echo "2. 查看提交历史（Download ZIP 做不到！）："
git log --oneline
echo ""

echo "3. 查看远程仓库（自动配置好的！）："
git remote -v
echo ""

echo "4. 查看所有分支（包括远程分支）："
git branch -a
echo ""

cd "$TEMP_DIR" || exit 1

echo "----------------------------------------"
echo ""
echo "对比总结："
echo "  zip-download/   -- 只有文件，没有历史（5个提交全部丢失）"
echo "  cloned-project/ -- 文件 + 完整历史 + 远程仓库关联"
echo ""
echo "类比总结："
echo "  Download ZIP = 只要了一张照片的打印件"
echo "  git clone    = 复制了整个云相册（包括所有修改记录）"
echo ""

# ----------------------------------------------------------
# 步骤5：clone 时可以指定目标目录名
# ----------------------------------------------------------
echo ">>> 第4步：clone 时指定自定义目录名"
echo ""

git clone "$TEMP_DIR/remote-repo.git" my-custom-name
echo ""
echo "查看: ls"
ls -d my-custom-name
echo ""
echo "仓库被克隆到了 my-custom-name/ 目录"
echo ""

# ----------------------------------------------------------
# 步骤6：总结
# ----------------------------------------------------------
echo "========================================="
echo "  概念总结"
echo "========================================="
echo ""
echo "  git clone 下载了这些东西："
echo "  ┌──────────────────────────────────┐"
echo "  │ 1. 所有文件（当前版本）          │"
echo "  │ 2. 整个 .git 目录                │"
echo "  │    - 所有提交历史                │"
echo "  │    - 所有分支信息                │"
echo "  │    - 所有标签                    │"
echo "  │ 3. 自动设置 origin 远程仓库      │"
echo "  │ 4. 自动检出默认分支的代码        │"
echo "  └──────────────────────────────────┘"
echo ""
echo "  Download ZIP 只下载了："
echo "  ┌──────────────────────────────────┐"
echo "  │ 1. 当前版本的文件（仅此而已）    │"
echo "  └──────────────────────────────────┘"
echo ""

# ----------------------------------------------------------
# 清理提示
# ----------------------------------------------------------
echo "========================================="
echo "  练习完成！"
echo "========================================="
echo ""
echo "本脚本的练习文件在: $TEMP_DIR"
echo "你可以进入各个目录看看："
echo "  cd $TEMP_DIR/zip-download       -- Download ZIP 的效果"
echo "  cd $TEMP_DIR/cloned-project     -- git clone 的效果"
echo "  cd $TEMP_DIR/original-project   -- 原始项目"
echo ""
echo "想清理的话，执行: rm -rf $TEMP_DIR"
echo ""
echo "下一节: 03-推送和拉取"
