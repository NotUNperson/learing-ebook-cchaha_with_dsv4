#!/bin/bash
# =============================================================================
# 05-final-capstone.sh — 终极综合项目实操脚本
# 场景：三人团队（小明、小红、小李）协作开发"猫猫咖啡馆"网页
#      完整模拟初始化 → 多人分支开发 → 解决冲突 → 合并 → 发布的全流程
# 用法：在 Git Bash 中运行  bash 05-final-capstone.sh
# 注意：该脚本在 /tmp 下创建临时目录，运行结束后自动清理，不污染你的文件
# =============================================================================

echo "============================================"
echo "  05 终极综合项目 — 三人协作开发"
echo "============================================"
echo ""
echo "项目：为「猫猫咖啡馆」开发一个网页"
echo "团队：小明（组长+主页）、小红（样式）、小李（联系我们页）"
echo ""
echo "让我们开始这段旅程..."
echo ""

# ============================================================================
# 准备工作：创建远程仓库和三个开发者的本地目录
# ============================================================================

# 所有临时文件放在一个根目录下
BASE_DIR="/tmp/git-learn-capstone-$(date +%s)"
mkdir -p "$BASE_DIR"

# 远程仓库（bare repo，模拟 GitHub）
REMOTE_DIR="$BASE_DIR/remote-repo.git"
mkdir -p "$REMOTE_DIR"
cd "$REMOTE_DIR" || exit 1
git init --bare
echo ">>> 远程仓库已创建（模拟 GitHub）"
echo ""

# 三个开发者的本地目录
XIAOMING_DIR="$BASE_DIR/xiaoming"
XIAOHONG_DIR="$BASE_DIR/xiaohong"
XIAOLI_DIR="$BASE_DIR/xiaoli"

echo ">>> 团队成员已就位：小明、小红、小李"
echo ""

# ============================================================================
# 场景一：小明初始化项目并创建主页骨架
# ============================================================================
echo "============================================"
echo "  场景一：小明初始化项目"
echo "============================================"
echo ""
echo "小明是项目组长，负责创建项目骨架并推送到远程仓库。"
echo ""

# 小明克隆远程仓库（模拟从 GitHub clone）
git clone "$REMOTE_DIR" "$XIAOMING_DIR"
cd "$XIAOMING_DIR" || exit 1

echo ">>> 小明创建主页骨架 index.html..."
cat > index.html << 'HTML_EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>猫猫咖啡馆</title>
</head>
<body>
    <h1>欢迎来到猫猫咖啡馆</h1>
    <p>这里有好喝的咖啡和可爱的猫咪。</p>
</body>
</html>
HTML_EOF

echo ">>> 小明创建 README.md..."
cat > README.md << 'MD_EOF'
# 猫猫咖啡馆官方网站

这是猫猫咖啡馆的官方网站项目。

## 团队成员

- 小明（组长，主页开发）
- 小红（样式设计）
- 小李（联系我们页面）
MD_EOF

echo ">>> 小明提交并推送到远程仓库..."
git add index.html README.md
git commit -m "feat: 初始化项目，添加主页骨架和 README"
git push -u origin main
echo ""

echo ">>> 小明仓库的提交历史："
git log --oneline
echo ""

# ============================================================================
# 场景二：小红加入项目，添加 CSS 样式
# ============================================================================
echo "============================================"
echo "  场景二：小红加入，为主页添加样式"
echo "============================================"
echo ""
echo "小红把项目克隆到自己的电脑上，开始设计样式。"
echo ""

# 小红克隆仓库
git clone "$REMOTE_DIR" "$XIAOHONG_DIR"
cd "$XIAOHONG_DIR" || exit 1

echo ">>> 小红创建 feature/add-styles 分支..."
git checkout -b feature/add-styles

echo ">>> 小红创建 style.css..."
cat > style.css << 'CSS_EOF'
/* 猫猫咖啡馆 - 主样式表 */
body {
    font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
    background-color: #fff8f0;
    color: #5d4037;
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
    line-height: 1.8;
}

h1 {
    color: #e65100;
    text-align: center;
    font-size: 2.5rem;
    margin-bottom: 1.5rem;
}

p {
    font-size: 1.1rem;
    text-align: center;
}

/* 导航栏样式 */
nav {
    background-color: #ffcc80;
    padding: 1rem;
    border-radius: 8px;
    margin-bottom: 2rem;
    text-align: center;
}

nav a {
    color: #5d4037;
    text-decoration: none;
    margin: 0 1rem;
    font-weight: bold;
}

nav a:hover {
    color: #e65100;
    text-decoration: underline;
}
CSS_EOF

echo ">>> 小红修改 index.html，引入样式表并添加导航栏..."
# 用 sed 在 </head> 前插入样式表引用
sed -i 's|</head>|    <link rel="stylesheet" href="style.css">\n</head>|' index.html

# 在 <body> 后、<h1> 前插入导航栏
sed -i 's|<body>|<body>\n    <nav>\n        <a href="index.html">首页</a>\n        <a href="about.html">关于我们</a>\n        <a href="contact.html">联系我们</a>\n    </nav>|' index.html

echo ">>> 小红提交并推送..."
git add style.css index.html
git commit -m "feat: 添加页面基础样式和导航栏，主题色为暖橘色"
git push -u origin feature/add-styles
echo ""

echo ">>> 小红分支的提交历史："
git log --oneline
echo ""

# 小红在 GitHub 上创建 PR，小明 review 后合并
echo ">>> (模拟) 小红在 GitHub 上提了 Pull Request"
echo ">>> (模拟) 小明 review 了代码，觉得没问题，点击 Merge 合并到 main"
echo ""

# 在本地模拟合并（假设小明在本地执行 merge）
cd "$XIAOMING_DIR" || exit 1
git checkout main
git pull origin main
git merge origin/feature/add-styles --no-edit
git push origin main
echo ">>> 小红的功能已合并到 main 分支"
echo ""

# ============================================================================
# 场景三：小李加入，同时小红继续开发
# ============================================================================
echo "============================================"
echo "  场景三：小李加入 + 小红继续美化"
echo "============================================"
echo ""
echo "小李也从远程仓库克隆了项目，准备写「联系我们」页面。"
echo "同时，小红觉得主标题颜色可以更深一点，又开了新分支。"
echo ""

# --- 小李的工作 ---
echo "--- 小李的视角 ---"
echo ""

git clone "$REMOTE_DIR" "$XIAOLI_DIR"
cd "$XIAOLI_DIR" || exit 1

echo ">>> 小李创建 feature/add-contact-page 分支..."
git checkout -b feature/add-contact-page

echo ">>> 小李创建 contact.html（联系我们页面）..."
cat > contact.html << 'HTML_EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>联系我们 - 猫猫咖啡馆</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav>
        <a href="index.html">首页</a>
        <a href="about.html">关于我们</a>
        <a href="contact.html">联系我们</a>
    </nav>
    <h1>联系我们</h1>
    <p>地址：北京市朝阳区猫咪路 42 号</p>
    <p>电话：010-1234-5678</p>
    <p>邮箱：hello@catcafe.example.com</p>
    <p>营业时间：每天 09:00 - 21:00</p>
</body>
</html>
HTML_EOF

echo ">>> 小李觉得标题颜色跟整体风格不太搭，想改成深蓝..."
# 小李也修改了 style.css 的 h1 颜色
sed -i 's/color: #e65100;/color: #1a237e;/' style.css

git add contact.html style.css
git commit -m "feat: 添加联系页面；style: 将标题色改为深蓝"
git push -u origin feature/add-contact-page
echo ""

echo ">>> 小李分支的提交历史："
git log --oneline
echo ""

# --- 同时，小红的工作 ---
echo "--- 小红的视角 ---"
echo ""

cd "$XIAOHONG_DIR" || exit 1

# 小红拉取最新的 main（包含她之前合并的样式）
git checkout main
git pull origin main

echo ">>> 小红创建 feature/deepen-color 分支..."
git checkout -b feature/deepen-color

echo ">>> 小红觉得 h1 颜色可以更深一点，改成深红棕..."
# 注意：小红也修改了 style.css 的 h1 颜色（同一行！）
sed -i 's/color: #e65100;/color: #bf360c;/' style.css

git add style.css
git commit -m "style: 将标题色从暖橘改为深红棕色，更符合咖啡主题"
git push -u origin feature/deepen-color
echo ""

echo ">>> 小红分支的提交历史："
git log --oneline
echo ""

# 小明先合并了小红的 PR
echo ">>> (模拟) 小红提了 PR，小明先合并了小红的（深红棕）到 main"
cd "$XIAOMING_DIR" || exit 1
git pull origin main
git merge origin/feature/deepen-color --no-edit
git push origin main
echo ""

# ============================================================================
# 场景四：冲突爆发！小李的 PR 和小红的修改冲突了
# ============================================================================
echo "============================================"
echo "  场景四：合并冲突！"
echo "============================================"
echo ""
echo "小明想合并小李的 PR，但 GitHub 显示："
echo "\"This branch has conflicts that must be resolved\""
echo ""
echo "原因：小红把 h1 颜色改成了深红棕 #bf360c，"
echo "      小李把 h1 颜色改成了深蓝 #1a237e。"
echo "      Git 不知道该用哪个，需要人工决定。"
echo ""

echo "--- 小李解决冲突 ---"
echo ""

cd "$XIAOLI_DIR" || exit 1

echo ">>> 小李拉取最新的 main..."
git checkout main
git pull origin main
echo ""

echo ">>> 小李把自己的分支变基（rebase）到最新 main 上..."
git checkout feature/add-contact-page
echo ""
echo ">>> 执行 git rebase main（即将出现冲突）..."
git rebase main 2>&1 || true
echo ""

echo ">>> 查看有冲突的文件："
git status
echo ""

echo ">>> style.css 的冲突内容："
echo "---"
grep -A 2 -B 2 "<<<<<<" style.css 2>/dev/null || echo "(冲突内容可能已被 diff 格式包含)"
echo "---"
echo ""

echo ">>> 小李解决冲突：跟小红商量后，决定用温和的深棕色 #4e342e"
# 先用 sed 清理冲突标记，再替换颜色
# 方法：直接重写 style.css 中 h1 的颜色，清除所有冲突标记
cat > style.css << 'CSS_EOF'
/* 猫猫咖啡馆 - 主样式表 */
body {
    font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
    background-color: #fff8f0;
    color: #5d4037;
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
    line-height: 1.8;
}

h1 {
    color: #4e342e;
    text-align: center;
    font-size: 2.5rem;
    margin-bottom: 1.5rem;
}

p {
    font-size: 1.1rem;
    text-align: center;
}

/* 导航栏样式 */
nav {
    background-color: #ffcc80;
    padding: 1rem;
    border-radius: 8px;
    margin-bottom: 2rem;
    text-align: center;
}

nav a {
    color: #5d4037;
    text-decoration: none;
    margin: 0 1rem;
    font-weight: bold;
}

nav a:hover {
    color: #e65100;
    text-decoration: underline;
}
CSS_EOF

echo ">>> 标记冲突已解决："
git add style.css
echo ""

echo ">>> 继续 rebase："
git rebase --continue 2>&1 || true
echo ""

echo ">>> 推送解决冲突后的分支（需要使用 --force-with-lease，因为历史被改写过）："
git push --force-with-lease origin feature/add-contact-page
echo ""

echo ">>> (模拟) 小明现在可以在 GitHub 上顺利合并小李的 PR 了"
cd "$XIAOMING_DIR" || exit 1
git pull origin main
git merge origin/feature/add-contact-page --no-edit
git push origin main
echo ""

# ============================================================================
# 场景五：完整项目的收尾工作
# ============================================================================
echo "============================================"
echo "  场景五：项目发布准备"
echo "============================================"
echo ""

echo "--- 小明做最终检查和版本发布 ---"
echo ""

cd "$XIAOMING_DIR" || exit 1
git pull origin main

echo ">>> 当前项目文件列表："
ls -la
echo ""

echo ">>> 完整的提交历史（图形化）："
git log --oneline --graph --all
echo ""

echo ">>> 小明给当前版本打标签："
git tag -a v1.0.0 -m "猫猫咖啡馆网站 v1.0.0 - 首个正式版本"
echo ""

echo ">>> 推送标签到远程仓库："
git push origin v1.0.0
echo ""

echo ">>> 所有标签："
git tag -l
echo ""

# ============================================================================
# 场景六：其他团队成员拉取最新版本
# ============================================================================
echo "============================================"
echo "  场景六：所有人同步最新版本"
echo "============================================"
echo ""

echo "--- 小红拉取最新版本 ---"
cd "$XIAOHONG_DIR" || exit 1
git checkout main
git pull origin main
echo ">>> 小红的本地现在是最新的 v1.0.0"
echo ""

echo "--- 小李拉取最新版本 ---"
cd "$XIAOLI_DIR" || exit 1
git checkout main
git pull origin main
echo ">>> 小李的本地现在是最新的 v1.0.0"
echo ""

# ============================================================================
# 总结展示
# ============================================================================
echo "============================================"
echo "  项目完成！最终总结"
echo "============================================"
echo ""

echo "  最终项目文件结构："
echo ""
cd "$XIAOMING_DIR" || exit 1
find . -not -path './.git/*' -type f | sort | while read f; do
    echo "    $f"
done
echo ""

echo "  项目的完整提交历史："
echo ""
git log --oneline --graph --all --decorate
echo ""

echo "============================================"
echo "  这个项目演练了完整的团队 Git 工作流："
echo "============================================"
echo ""
echo "  1. 一人初始化项目（git init + 初始提交 + push）"
echo "  2. 队友克隆仓库（git clone）"
echo "  3. 每个人在自己的功能分支上工作（git checkout -b）"
echo "  4. 功能完成，推送分支到远程（git push -u origin）"
echo "  5. 在 GitHub 上创建 Pull Request"
echo "  6. 组长 review 并合并（merge）"
echo "  7. 遇到冲突时：拉取最新 main → rebase → 手动解决 → push"
echo "  8. 发布版本（git tag）"
echo "  9. 所有人同步最新版（git pull）"
echo ""
echo "  你经历了："
echo "    - 小明（组长）：init、commit、push、merge、tag"
echo "    - 小红（样式）：clone、分支、add、commit、push、PR"
echo "    - 小李（联系页）：clone、rebase、冲突解决、push --force-with-lease"
echo ""
echo "  记住这个节奏，你就能在任何团队中顺畅协作。"
echo ""

# ============================================================================
# 清理
# ============================================================================
echo "============================================"
echo "  清理临时目录..."
echo "============================================"
cd /tmp || exit
rm -rf "$BASE_DIR"
echo ">>> 已删除所有临时目录：$BASE_DIR"
echo ""
echo "恭喜！你完成了 Git 教程的全部内容。"
echo ""
echo "接下来的路，不在教程里，在你的项目里。去用吧。"
