#!/bin/bash
# ============================================================================
# 02-创建和切换分支 - 示例脚本
# 演示 git branch / git switch / git checkout 的基本操作
# ============================================================================

set -e

# 创建临时目录
WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"
echo "==> 演示仓库：$WORK_DIR"

# 初始化仓库，创建初始提交
git init
# 设置本地用户信息（避免依赖全局配置）
git config user.email "demo@example.com"
git config user.name "Git教程演示"
echo "项目版本 1.0 - 初始代码" > app.py
git add app.py
git commit -m "初始提交：app.py 基础框架" --quiet
git branch -m main  # 将默认分支重命名为 main（兼容不同 Git 版本）

echo ""
echo "=============================="
echo "  1. 查看分支列表"
echo "=============================="
git branch
echo "   目前只有一个 main 分支，* 号表示你在这里"

echo ""
echo "=============================="
echo "  2. 创建一个新分支 feature-login"
echo "=============================="
git branch feature-login
echo "   新分支创建完成，但当前还在 main 上"
git branch
echo "   注意 * 号仍在 main 上"

echo ""
echo "=============================="
echo "  3. 切换到新分支（两种方式）"
echo "=============================="
echo "   方式一：git switch feature-login（推荐）"
git switch feature-login
git branch
echo "   * 号已移到 feature-login"

echo ""
echo "   切回 main，用方式二演示："
git switch main
echo "   方式二：git checkout feature-login（老命令）"
git checkout feature-login
git branch

echo ""
echo "=============================="
echo "  4. 创建并立即切换（快捷方式）"
echo "=============================="
# 先切回 main
git switch main
echo "   git switch -c feature-search  （-c 表示 create + switch）"
git switch -c feature-search
git branch
echo "   一条命令完成：创建 feature-search 并切换过去"

echo ""
echo "=============================="
echo "  5. 在不同分支上提交，观察分叉"
echo "=============================="

# 在 feature-search 上做个提交
echo "def search(): pass" >> app.py
git add app.py
git commit -m "搜索功能：添加 search 函数骨架" --quiet
echo "   [feature-search] 提交了搜索功能骨架"

# 切换到 feature-login
git switch feature-login
echo "def login(): pass" >> app.py
git add app.py
git commit -m "登录功能：添加 login 函数骨架" --quiet
echo "   [feature-login] 提交了登录功能骨架"

# 在 main 上也做个提交
git switch main
echo "# 配置文件" > config.ini
git add config.ini
git commit -m "添加配置文件 config.ini" --quiet
echo "   [main] 提交了配置文件"

echo ""
echo "=============================="
echo "  6. 查看分支图（分叉效果）"
echo "=============================="
git log --oneline --graph --all

echo ""
echo "   观察：三个分支从同一个起点分叉，各自有不同内容"

echo ""
echo "=============================="
echo "  7. 用 git branch -v 查看详情"
echo "=============================="
git branch -v

echo ""
echo "=============================="
echo "  8. 删除分支"
echo "=============================="
# -D 强制删除，因为 feature-search 的内容还未合并（演示用途）
git branch -D feature-search
echo "   feature-search 已删除（强制删除，因为内容未合并）"
git branch
echo ""
echo "   普通删除演示（已合并的分支可以用 -d）："
git branch haha-test
echo "   创建了 haha-test（无新提交）"
git branch -d haha-test
echo "   删除成功（没有新内容，安全删除）"

echo ""
echo "=============================="
echo "  9. 重命名分支"
echo "=============================="
git branch -m feature-login feature-auth
echo "   feature-login 重命名为 feature-auth"
git branch

echo ""
echo "=============================="
echo "  总结："
echo "  - git branch            查看分支"
echo "  - git branch <name>     创建分支"
echo "  - git switch <name>     切换分支"
echo "  - git switch -c <name>  创建并切换"
echo "  - git branch -d <name>  删除分支"
echo "  - git branch -m <old> <new>  重命名分支"
echo "=============================="
echo ""
echo "演示仓库位于：$WORK_DIR"
