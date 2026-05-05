#!/bin/bash
# =============================================================================
# 02-gitignore.sh — .gitignore 实操脚本
# 场景：创建 .gitignore 文件，演示哪些文件被忽略、哪些被跟踪
# 用法：在 Git Bash 中运行  bash 02-gitignore.sh
# 注意：该脚本在 /tmp 下创建临时目录，运行结束后自动清理，不污染你的文件
# =============================================================================

echo "============================================"
echo "  02 .gitignore 和配置文件 — 实操脚本"
echo "============================================"
echo ""

# ---------------------------------------------------------------------------
# 准备实验场地
# ---------------------------------------------------------------------------
TEMP_DIR="/tmp/git-learn-gitignore-$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1

echo ">>> 创建一个新仓库并初始化"
git init
echo ""

# ---------------------------------------------------------------------------
# 第一部分：没有 .gitignore 时的状态
# ---------------------------------------------------------------------------
echo "============================================"
echo "  第一部分：没有 .gitignore 时"
echo "============================================"
echo ""

echo ">>> 创建一些文件和目录（模拟真实项目）："
echo ""

# 创建项目源代码文件
mkdir -p src
echo "console.log('hello');" > src/app.js
echo "h1 { color: blue; }"  > src/style.css
echo "# 项目文档"              > README.md

# 创建那些"不该提交"的文件
echo "DB_PASSWORD=mysecret123" > .env
echo "API_KEY=sk-abcdefg"       > config/secrets.json 2>/dev/null || { mkdir config; echo "API_KEY=sk-abcdefg" > config/secrets.json; }
mkdir -p node_modules/lodash
echo "// lodash code"           > node_modules/lodash/index.js
echo "// lodash utils"          > node_modules/lodash/utils.js
echo "编译后的代码..."           > dist/bundle.js 2>/dev/null || { mkdir dist; echo "编译后的代码..." > dist/bundle.js; }
echo "[2024-01-01] Server started" > server.log
echo "[2024-01-01] Error: something" > error.log
echo ""                          > .DS_Store

echo ">>> 当前目录结构："
find . -not -path './.git/*' | sort
echo ""

echo ">>> 执行 git status（看看 Git 想要跟踪哪些文件）："
git status
echo ""
echo "注意：.env（密码文件）、node_modules（依赖包）、dist/（编译产物）、"
echo "      *.log（日志）、.DS_Store（系统垃圾）全都被 Git 标记为未跟踪。"
echo "     如果这时候执行 git add .，它们都会被提交到仓库！"
echo ""

# ---------------------------------------------------------------------------
# 第二部分：创建 .gitignore
# ---------------------------------------------------------------------------
echo "============================================"
echo "  第二部分：创建 .gitignore"
echo "============================================"
echo ""

echo ">>> 创建 .gitignore 文件，写入忽略规则："
echo ""

# 写入常见的忽略规则
cat > .gitignore << 'GITIGNORE_EOF'
# ---------- 密码和敏感文件 ----------
.env
config/secrets.json

# ---------- 依赖包（体积巨大，可重新安装） ----------
node_modules/

# ---------- 编译产物（可重新生成） ----------
dist/
build/

# ---------- 日志文件 ----------
*.log

# ---------- 操作系统垃圾文件 ----------
.DS_Store
Thumbs.db

# ---------- 例外：important.log 需要跟踪（演示 ! 取反规则） ----------
!important.log
GITIGNORE_EOF

echo ">>> .gitignore 文件内容："
cat .gitignore
echo ""

# ---------------------------------------------------------------------------
# 第三部分：验证 .gitignore 的效果
# ---------------------------------------------------------------------------
echo "============================================"
echo "  第三部分：验证 .gitignore 的效果"
echo "============================================"
echo ""

echo ">>> 再次执行 git status："
git status
echo ""
echo "你会发现：.env、node_modules、dist、*.log、.DS_Store 统统不见了！"
echo "Git 只看到 src/app.js、src/style.css、README.md 和 .gitignore 本身。"
echo ""

# ---------------------------------------------------------------------------
# 第四部分：验证"取反"规则
# ---------------------------------------------------------------------------
echo "============================================"
echo "  第四部分：验证 ! 取反规则"
echo "============================================"
echo ""
echo "我们在 .gitignore 中写了 *.log 忽略所有日志，但又写了 !important.log 例外。"
echo ""

echo ">>> 创建一个 important.log 文件（这个会被跟踪）："
echo "重要日志内容" > important.log
echo ""

echo ">>> 检查 important.log 是否被忽略："
git check-ignore -v important.log || echo "important.log 没有被忽略（符合预期，因为 !important.log 规则生效了）"
echo ""

echo ">>> 检查 server.log 是否被忽略："
git check-ignore -v server.log
echo ""

# ---------------------------------------------------------------------------
# 第五部分：如果已经提交了不该提交的文件怎么办
# ---------------------------------------------------------------------------
echo "============================================"
echo "  第五部分：补救 — 取消跟踪已提交的文件"
echo "============================================"
echo ""
echo "场景：假设你不小心把 .env 提交到了仓库。"
echo "即使后来加入 .gitignore，它还是会被跟踪（因为 Git 已经"认识"它了）。"
echo ""

# 先提交一个文件（模拟"已经不小心提交了"）
echo ">>> 模拟：先不小心提交了 .env 文件"
cp .env .env.backup   # 备份一下 .env 内容
git add .env
git commit -m "（错误操作）不小心提交了 .env 文件"
echo ""

echo ">>> 现在才发现不该提交，补救步骤："
echo ""

echo "  步骤 1：从 Git 跟踪中移除（但保留文件本身，不删除）："
git rm --cached .env
echo ""

echo "  步骤 2：确认 .env 在 .gitignore 中（我们之前已经加了）："
grep "^\.env$" .gitignore && echo "  -> .env 已在 .gitignore 中 ✓"
echo ""

echo "  步骤 3：提交这次移除操作："
git commit -m "chore: 从版本控制中移除 .env，添加到 .gitignore"
echo ""

echo "  现在 .env 文件仍然在你的文件夹里（内容没丢），"
echo "  但 Git 不再跟踪它了。检查 git status 确认："
git status
echo ""

# 恢复 .env（因为 git rm --cached 后它在工作区还是存在的）
echo "$DB_PASSWORD_VALUE" > .env 2>/dev/null || echo "DB_PASSWORD=mysecret123" > .env

# ---------------------------------------------------------------------------
# 第六部分：全局 .gitignore 配置演示
# ---------------------------------------------------------------------------
echo "============================================"
echo "  第六部分：介绍全局 .gitignore"
echo "============================================"
echo ""
echo "如果你希望在所有仓库里都忽略某些文件（比如 .DS_Store），"
echo "可以配置全局 .gitignore，一条命令永久生效："
echo ""
echo "  方法："
echo "  1. touch ~/.gitignore_global              # 创建全局 gitignore 文件"
echo "  2. echo '.DS_Store' >> ~/.gitignore_global # 写入规则"
echo "  3. git config --global core.excludesfile ~/.gitignore_global  # 让 Git 使用它"
echo ""
echo "（上述命令不在本次脚本中执行，避免修改你的全局 Git 配置）"
echo ""

# ---------------------------------------------------------------------------
# 第七部分：提交项目（只提交该提交的）
# ---------------------------------------------------------------------------
echo "============================================"
echo "  第七部分：正常提交项目"
echo "============================================"
echo ""
echo "配置好 .gitignore 后，可以放心地 git add . 了："

git add .
echo ""
echo ">>> 暂存区内容："
git status
echo ""
echo "注意：只有源代码和 .gitignore 被暂存了，敏感文件和垃圾文件都没进来。"
echo ""

git commit -m "feat: 初始化项目结构，添加基本源文件和 .gitignore"
echo ""

echo ">>> 查看提交的文件列表："
git show --name-only --oneline HEAD
echo ""

# ---------------------------------------------------------------------------
# 清理
# ---------------------------------------------------------------------------
echo "============================================"
echo "  清理临时目录..."
echo "============================================"
cd /tmp || exit
rm -rf "$TEMP_DIR"
echo ">>> 已删除临时目录 $TEMP_DIR"
echo ""
echo "提示：你电脑上的真实文件没有被任何操作影响。"
echo ""
echo "总结记住两句话："
echo "  1. .gitignore 在项目创建第一时间就配好"
echo "  2. 已经跟踪的文件不会被 .gitignore 保护，要用 git rm --cached 救回来"
