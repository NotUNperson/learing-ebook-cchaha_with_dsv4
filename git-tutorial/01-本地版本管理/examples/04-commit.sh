#!/bin/bash
# =============================================================================
# 04-commit.sh — git commit 实操脚本
# 场景：演示提交操作、提交信息规范、commit -a 的用法、git show 查看提交
# 用法：在 Git Bash 中运行  bash 04-commit.sh
# 该脚本在 /tmp 下创建临时目录，运行结束后自动清理
# =============================================================================

echo "============================================"
echo "  04 正式保存版本（git commit） — 实操脚本"
echo "============================================"
echo ""

# 1. 创建临时实验场地
TEMP_DIR="/tmp/git-learn-04-commit-$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ">>> 实验场地：$TEMP_DIR"
echo ""

# 2. 初始化仓库
git init
echo ""

# 3. 模拟场景：你正在开发一个小项目
echo "============================================"
echo "  场景：模拟一个网站项目的开发过程"
echo "============================================"
echo ""

# 第一次提交：创建项目骨架
echo "第一步：创建项目的基础文件"
echo "<h1>我的网站</h1>" > index.html
echo "body { font-family: sans-serif; }" > style.css
git add .
git commit -m "搭建项目骨架：创建 index.html 和 style.css"
echo ""
echo ">>> 第一次提交完成"
echo ""

# 查看这次提交的详细信息
echo "============================================"
echo "  用 git show 查看刚才的提交"
echo "============================================"
echo ""
git show --stat
echo ""

# 第二次提交：添加功能
echo "============================================"
echo "  第二步：添加导航栏功能"
echo "============================================"
echo ""

# 修改 index.html（追加内容）
cat > index.html << 'INNEREOF'
<nav>
  <a href="/">首页</a>
  <a href="/about">关于</a>
</nav>
<h1>我的网站</h1>
INNEREOF

echo ">>> 修改了 index.html，添加了导航栏代码"
echo ""
echo ">>> git status："
git status
echo ""

# 暂存并提交
git add index.html
git commit -m "feat: 添加导航栏"
echo ""
echo ">>> 第二次提交完成，使用了约定式提交格式（feat: ...）"
echo ""

# 第三次提交：修复一个样式问题
echo "============================================"
echo "  第三步：修复导航栏样式"
echo "============================================"
echo ""

echo "nav { background: #333; color: white; }" >> style.css
echo "nav a { color: white; text-decoration: none; }" >> style.css

# 演示 commit -a 的用法 —— 跳过 git add，直接提交已跟踪的修改文件
echo ">>> 修改了 style.css，添加导航栏样式"
echo ""
echo ">>> 这次用 git commit -a 直接提交（跳过 git add 步骤）："
git commit -a -m "fix: 修复导航栏样式缺失"
echo ""
echo ">>> 第三次提交完成"
echo ""

# 展示 git commit -a 的局限性
echo "============================================"
echo "  演示 git commit -a 的局限性"
echo "============================================"
echo ""

echo "创建新文件 about.html（未被跟踪的文件）"
echo "<h1>关于我们</h1>" > about.html
echo ""
echo ">>> git status："
git status
echo ""
echo ">>> 现在用 git commit -a 尝试提交（期望它不会包含 about.html）："
git commit -a -m "这次应该不会包含 about.html" 2>&1 || true
echo ""
echo ">>> git status："
git status
echo ""
echo "解读：about.html 没有被提交！它仍然在 'Untracked files' 中。"
echo "这说明了 git commit -a 只对已跟踪文件生效。新文件仍然需要 git add。"
echo ""

# 手动 add 新文件
git add about.html
git commit -m "feat: 添加关于页面"
echo ""
echo ">>> 手动 git add about.html 后再次提交，这次成功了。"
echo ""

# 展示好的和不好的提交信息
echo "============================================"
echo "  提交信息的好例子 vs 坏例子"
echo "============================================"
echo ""

echo ">>> 使用 git log 查看所有提交信息："
echo ""
git log --oneline
echo ""
echo "上面的提交信息都清晰地说明了每次提交做了什么。"
echo ""
echo "对比一下不好的提交信息写法："
echo "  - '改了一下'            （改了什么？完全不知道）"
echo "  - 'fix'                 （修复了什么？）"
echo "  - 'update'              （更新了啥？）"
echo "  - '.'                   （只有一个句号？）"
echo ""
echo "记住：3 个月后的你，需要靠这些信息来回忆每次提交的内容。"
echo ""

# 展示 git show 查看某次具体提交
echo "============================================"
echo "  git show 查看某次提交的完整内容"
echo "============================================"
echo ""

echo ">>> 查看第二次提交的详细内容（git show HEAD~2）："
git show HEAD~2 --stat
echo ""

# 清理
echo "============================================"
echo "  脚本执行完毕，清理临时目录..."
echo "============================================"
cd /tmp || exit
rm -rf "$TEMP_DIR"
echo ">>> 已删除 $TEMP_DIR"
echo ""
echo "今天的关键收获："
echo "  1. git commit -m '信息'      —— 把暂存区内容正式存档"
echo "  2. 提交信息要清晰描述'做了什么'"
echo "  3. git commit -a             —— 捷径，但只对已跟踪文件生效"
echo "  4. git show                  —— 查看最近一次提交的详细内容"
echo ""
echo "提交 = 办公桌上的文件经过文件夹（暂存区），最终进入档案柜（仓库）。"
