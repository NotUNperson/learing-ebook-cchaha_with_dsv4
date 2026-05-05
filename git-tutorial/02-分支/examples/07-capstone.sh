#!/bin/bash
# ============================================================================
# 07-综合练习 - 示例脚本
# 模拟完整的分支开发流程：
#   创建功能分支 -> 开发 -> main 有并行改动 -> 合并产生冲突 ->
#   解决冲突 -> 合并回 main -> 清理分支
# ============================================================================

set -e

WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"
echo "==> 项目目录：$WORK_DIR"
echo "==> 场景：为网站添加导航栏功能"

echo ""
echo "========================================="
echo "  第1步：初始化项目，创建基础页面"
echo "========================================="

git init
# 设置本地用户信息（避免依赖全局配置）
git config user.email "demo@example.com"
git config user.name "Git教程演示"

# 创建初始 HTML 页面
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>我的网站</title>
</head>
<body>
    <h1>欢迎来到我的网站</h1>
    <p>这是网站的主要内容区域。</p>
</body>
</html>
HTMLEOF

git add index.html
git commit -m "初始提交：基础 HTML 页面" --quiet
git branch -m main  # 将默认分支重命名为 main（兼容不同 Git 版本）
echo "   已创建 index.html（基础版本）"

echo ""
echo "========================================="
echo "  第2步：创建功能分支 feature/navbar"
echo "========================================="
git switch -c feature/navbar
echo "   已创建并切换到 feature/navbar"

# 在功能分支上添加导航栏
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>我的网站</title>
</head>
<body>
    <nav>
        <a href="/">首页</a>
        <a href="/about">关于</a>
        <a href="/contact">联系</a>
    </nav>
    <h1>欢迎来到我的网站</h1>
    <p>这是网站的主要内容区域。</p>
</body>
</html>
HTMLEOF

git add index.html
git commit -m "添加导航栏骨架" --quiet

# 为导航栏添加样式
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>我的网站</title>
    <style>
        nav { background: #333; padding: 10px; }
        nav a { color: white; margin-right: 15px; text-decoration: none; }
    </style>
</head>
<body>
    <nav>
        <a href="/">首页</a>
        <a href="/about">关于</a>
        <a href="/contact">联系</a>
    </nav>
    <h1>欢迎来到我的网站</h1>
    <p>这是网站的主要内容区域。</p>
</body>
</html>
HTMLEOF

git add index.html
git commit -m "为导航栏添加样式" --quiet
echo "   在 feature/navbar 上完成了 2 次提交"
echo "   当前分支图："
git log --oneline --graph --all

echo ""
echo "========================================="
echo "  第3步：模拟 main 分支有并行改动"
echo "        (同事对同一文件做了修改)"
echo "========================================="

git switch main

# 同事的改动：把标题用 header 标签包裹，并改写了标题文案
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>我的网站</title>
</head>
<body>
    <header>
        <h1>欢迎来到我的网站（全新改版！）</h1>
    </header>
    <p>这是网站的主要内容区域。</p>
</body>
</html>
HTMLEOF

git add index.html
git commit -m "首页改版：用 header 包裹标题，更新标题文案" --quiet
echo "   在 main 上完成了 1 次提交（模拟同事的改动）"
echo "   合并前的分支图（两个分支都有改动，即将冲突）："
git log --oneline --graph --all

echo ""
echo "========================================="
echo "  第4步：把 main 的最新改动合并到功能分支"
echo "        (预期：index.html 发生冲突！)"
echo "========================================="

git switch feature/navbar

echo "   执行 git merge main..."
git merge main 2>&1 || true

echo ""
echo "   Git 报告冲突！查看冲突文件："
echo "========================================="
echo "   === 冲突标记在 index.html 中 ==="
cat index.html
echo "   === 文件结束 ==="
echo "========================================="

echo ""
echo "   <<<<<<< HEAD        ← feature/navbar 的版本（导航栏 + 原标题）"
echo "   =======             ← 分隔线"
echo "   >>>>>>> main         ← main 的版本（header 包裹 + 新标题）"
echo ""

echo "========================================="
echo "  第5步：手动解决冲突"
echo "       策略：两边都保留（导航栏 + header结构）"
echo "========================================="

# 解决冲突：整合两个版本
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>我的网站</title>
    <style>
        nav { background: #333; padding: 10px; }
        nav a { color: white; margin-right: 15px; text-decoration: none; }
    </style>
</head>
<body>
    <nav>
        <a href="/">首页</a>
        <a href="/about">关于</a>
        <a href="/contact">联系</a>
    </nav>
    <header>
        <h1>欢迎来到我的网站（全新改版！）</h1>
    </header>
    <p>这是网站的主要内容区域。</p>
</body>
</html>
HTMLEOF

echo "   冲突已手动解决（导航栏 + header 结构都保留了）"
echo "   解决后的 index.html："
cat index.html

echo ""
echo "   告诉 Git 冲突已解决："
git add index.html
git commit -m "合并 main：整合导航栏和首页改版，解决冲突" --quiet
echo "   合并提交完成！"

echo ""
echo "========================================="
echo "  第6步：将功能分支合并回 main"
echo "========================================="

git switch main
git merge feature/navbar --no-edit
echo "   功能分支已合并到 main！"

echo ""
echo "========================================="
echo "  第7步：查看完整的分支历史"
echo "========================================="
git log --oneline --graph --all

echo ""
echo "========================================="
echo "  第8步：清理分支"
echo "========================================="
git branch -d feature/navbar
echo "   feature/navbar 已删除"
echo ""
echo "   当前分支列表："
git branch

echo ""
echo "========================================="
echo "  最终 index.html 的内容："
echo "========================================="
cat index.html

echo ""
echo "========================================="
echo "  总结："
echo "  [1] git switch -c feature/xxx   创建功能分支"
echo "  [2] 多次 git add + git commit   在功能分支上开发"
echo "  [3] git switch main             main 有并行改动"
echo "  [4] git merge main              同步改动到功能分支（可能冲突）"
echo "  [5] 编辑文件 → git add → git commit   解决冲突"
echo "  [6] git switch main → git merge  功能合并回主线"
echo "  [7] git branch -d feature/xxx   清理分支"
echo ""
echo "  这就是一次完整的分支开发流程！"
echo "========================================="
echo ""
echo "演示仓库位于：$WORK_DIR"
