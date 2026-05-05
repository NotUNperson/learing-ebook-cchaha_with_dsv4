#!/bin/bash
# =============================================================================
# 03-troubleshoot.sh — 常见问题排查实操脚本
# 场景：逐个复现五大常见问题，然后演示正确的补救方法
# 用法：在 Git Bash 中运行  bash 03-troubleshoot.sh
# 注意：该脚本在 /tmp 下创建临时目录，运行结束后自动清理，不污染你的文件
# =============================================================================

echo "============================================"
echo "  03 常见问题排查 — 实操脚本"
echo "============================================"
echo ""
echo "本脚本将带你逐个经历 Git 的五个常见问题，并演示正确的解决办法。"
echo "每个问题都是独立的小场景，别怕，跟着走一遍你就胸有成竹了。"
echo ""

TEMP_DIR="/tmp/git-learn-troubleshoot-$(date +%s)"
mkdir -p "$TEMP_DIR"

# ============================================================================
# 场景一：忘记 add 就 commit
# ============================================================================
echo "============================================"
echo "  场景一：忘记 add 就 commit"
echo "============================================"
echo ""

SCENE1="$TEMP_DIR/scene1"
mkdir -p "$SCENE1"
cd "$SCENE1" || exit 1

git init
echo "第一版内容" > file.txt
git add file.txt
git commit -m "第一次提交：创建 file.txt"
echo ""

echo ">>> 现在修改 file.txt，但"不小心"忘记了 git add："
echo "第二版内容——我修改了但没有 add" > file.txt
echo ""

echo ">>> 直接 commit（假装忘了 add）："
git commit -m "第二次提交：更新 file.txt"
echo ""
echo "注意：Git 提示 'nothing to commit' —— 因为暂存区是空的。"
echo "你的修改还在工作区，没有被提交，但也没有丢失。"
echo ""

echo ">>> 补救步骤："
echo "  1. 补上 git add："
git add file.txt
echo "  2. 用 --amend 追加到上一次提交："
git commit --amend -m "第二次提交：更新 file.txt（已补上遗忘的修改）"
echo ""

echo ">>> 验证：查看最后一次提交的内容"
git show --stat HEAD
echo ""
echo ">>> 结论：忘记 add 不要紧，用 git add + git commit --amend 补救。"
echo ""

# ============================================================================
# 场景二：commit 到错误分支
# ============================================================================
echo "============================================"
echo "  场景二：commit 到错误分支"
echo "============================================"
echo ""

SCENE2="$TEMP_DIR/scene2"
mkdir -p "$SCENE2"
cd "$SCENE2" || exit 1

git init
echo "# 项目" > README.md
git add README.md
git commit -m "初始化项目"
echo ""

echo ">>> 假设你应该在 feature/login 分支上开发，但你不小心在 main 上写了代码："
echo ""

# 在 main 上"错误地"写代码并提交
echo "function login() { /* 登录逻辑 */ }" > login.js
git add login.js
git commit -m "添加登录功能"
echo ""

echo ">>> 当前在 main 分支上，但 login.js 应该在 feature/login 分支上。"
echo ">>> 最新的提交是（注意它的哈希值）："
git log --oneline -1
echo ""

echo ">>> 补救方案：在当前提交上创建正确的分支，然后把 main 回退一步"
echo ""

# 步骤1：在"错误"提交上创建正确的分支
echo "  1. 创建 feature/login 分支（指向当前这个本该属于它的提交）："
git branch feature/login
echo ""

# 步骤2：把 main 回退到犯错之前
echo "  2. 把 main 分支回退一个提交（HEAD~1 表示"上一个提交"）："
git reset --hard HEAD~1
echo ""

echo ">>> 验证：看看两个分支各自的情况"
echo ""
echo "--- main 分支的提交历史（login.js 不在 main 上了）："
git log --oneline
echo ""
echo "--- feature/login 分支的提交历史（login.js 正确地在 feature/login 上）："
git checkout feature/login
git log --oneline
echo ""

# 切回 main 继续演示
git checkout main
echo ">>> 结论：用 git branch <分支名> + git reset --hard HEAD~1 可以把错误的提交"转移"到正确的分支。"
echo ""

# ============================================================================
# 场景三：合并冲突
# ============================================================================
echo "============================================"
echo "  场景三：合并冲突"
echo "============================================"
echo ""

SCENE3="$TEMP_DIR/scene3"
mkdir -p "$SCENE3"
cd "$SCENE3" || exit 1

git init

# 创建初始文件并提交
echo "第一句：月亮代表我的心" > song.txt
git add song.txt
git commit -m "添加歌曲文件，第一句歌词"
echo ""

echo ">>> 模拟两个分支修改了同一行："
echo ""

# 分支 version-a：改成摇滚版
echo "  创建 version-a 分支，改成摇滚版："
git checkout -b version-a
echo "第一句：月亮代表我的心（摇滚版）" > song.txt
git add song.txt
git commit -m "version-a: 摇滚版歌词"
echo ""

# 分支 main：改成抒情版
echo "  回到 main 分支，改成抒情版："
git checkout main
echo "第一句：月亮代表我的心（抒情版）" > song.txt
git add song.txt
git commit -m "main: 抒情版歌词"
echo ""

# 合并，触发冲突
echo ">>> 执行合并（即将出现冲突）："
git merge version-a 2>&1 || true
echo ""

echo ">>> 查看冲突状态："
git status
echo ""

echo ">>> song.txt 的内容（注意 <<<<<<<、=======、>>>>>>> 标记）："
cat -n song.txt
echo ""

echo ">>> 解决冲突步骤："
echo "  1. 编辑文件，保留想要的内容，删除冲突标记"
echo "  2. 这里我们用脚本自动解决（保留一个合并后的版本）："

# 手动解决冲突：把两个版本合并成一行
echo "第一句：月亮代表我的心（抒情摇滚版——合并了两种风格）" > song.txt
echo ""

echo "  解决后 song.txt 的内容："
cat song.txt
echo ""

echo "  3. 把解决后的文件标记为已解决："
git add song.txt
echo ""

echo "  4. 完成合并提交："
git commit -m "merge: 合并 version-a 的摇滚版，整合为抒情摇滚版"
echo ""

echo ">>> 验证合并后的提交历史："
git log --oneline --graph
echo ""

echo ">>> 结论：冲突不可怕，编辑冲突文件 -> git add -> git commit 就解决了。"
echo ""

# ============================================================================
# 场景四：push 被拒绝
# ============================================================================
echo "============================================"
echo "  场景四：push 被拒绝"
echo "============================================"
echo ""

SCENE4="$TEMP_DIR/scene4"
REMOTE4="$TEMP_DIR/scene4-remote"

# 创建远程仓库（bare）
mkdir -p "$REMOTE4"
cd "$REMOTE4" || exit 1
git init --bare
echo ""

# 克隆到本地（模拟你的本地仓库）
cd "$TEMP_DIR" || exit
git clone "$REMOTE4" "$SCENE4"
cd "$SCENE4" || exit 1

# 创建初始提交
echo "# 项目" > README.md
git add README.md
git commit -m "初始化项目"
git push -u origin main
echo ""

echo ">>> 模拟场景：你正在开发，同事也在同时推送了代码。"
echo ""

# 模拟"同事"推了新代码（直接在远程仓库里模拟——实际不可能但这里简化演示）
cd "$TEMP_DIR" || exit
git clone "$REMOTE4" "$TEMP_DIR/colleague"
cd "$TEMP_DIR/colleague" || exit 1
echo "同事的重要更新" > update.txt
git add update.txt
git commit -m "同事添加了 update.txt"
git push origin main
echo ""

# 回到"你"的仓库，在旧版本上做改动
cd "$SCENE4" || exit 1
echo "你的改动内容" > your-work.txt
git add your-work.txt
git commit -m "你添加了 your-work.txt"
echo ""

echo ">>> 你尝试 push，但远程已经被同事更新了："
git push origin main 2>&1 || true
echo ""
echo ">>> push 被拒绝了！(rejected)"
echo ""

echo ">>> 标准补救：用 pull --rebase 把你的改动放到同事的改动之后"
git pull --rebase origin main
echo ""

echo ">>> 现在再 push 就成功了："
git push origin main
echo ""

echo ">>> 验证提交历史（你的在同事的上面，历史是一条直线）："
git log --oneline --graph
echo ""

echo ">>> 结论：push 被拒 -> git pull --rebase -> git push 三步解决。"
echo ""

# ============================================================================
# 场景五：git reset --hard 后反悔
# ============================================================================
echo "============================================"
echo "  场景五：git reset --hard 后反悔"
echo "============================================"
echo ""

SCENE5="$TEMP_DIR/scene5"
mkdir -p "$SCENE5"
cd "$SCENE5" || exit 1

git init

# 创建三个提交
echo "第一版" > file.txt
git add file.txt
git commit -m "V1: 第一版"
echo "第二版" > file.txt
git add file.txt
git commit -m "V2: 第二版"
echo "第三版（重要！！！）" > file.txt
git add file.txt
git commit -m "V3: 第三版（重要内容）"
echo ""

echo ">>> 提交历史："
git log --oneline
echo ""

# 记录当前最新提交的哈希值
LATEST_COMMIT=$(git log --oneline -1 | awk '{print $1}')
echo ">>> 现在假设你手滑执行了 git reset --hard HEAD~1（回到 V2）："
git reset --hard HEAD~1
echo ""

echo ">>> 查看 file.txt 的内容（V3 不见了！）："
cat file.txt
echo ""

echo ">>> 别慌！用 git reflog 找回"丢失"的提交："
echo ""
git reflog
echo ""

echo ">>> 在 reflog 中你会看到 V3 的提交哈希值。用它恢复："
echo "    （这里我们直接用之前记录的哈希值 $LATEST_COMMIT）"
git reset --hard "$LATEST_COMMIT"
echo ""

echo ">>> file.txt 恢复了："
cat file.txt
echo ""

echo ">>> 结论：git reset --hard 不是世界末日，git reflog 就是你的"回收站"。"
echo ""

# ============================================================================
# 清理
# ============================================================================
echo "============================================"
echo "  清理临时目录..."
echo "============================================"
cd /tmp || exit
rm -rf "$TEMP_DIR"
echo ">>> 已删除所有临时目录"
echo ""

echo "============================================"
echo "  五大常见问题总结"
echo "============================================"
echo ""
echo "  问题一：忘 add 就 commit"
echo "    -> git add 文件 + git commit --amend"
echo ""
echo "  问题二：commit 到错误分支"
echo "    -> git branch 正确分支名 + git reset --hard HEAD~1"
echo ""
echo "  问题三：合并冲突"
echo "    -> 编辑文件删除 <<< === >>> -> git add -> git commit"
echo ""
echo "  问题四：push 被拒绝"
echo "    -> git pull --rebase -> git push"
echo ""
echo "  问题五：git reset --hard 后反悔"
echo "    -> git reflog 找到目标提交 -> git reset --hard <哈希>"
echo ""
echo "记住核心心态：冷静，先 git status 看清楚，再操作。"
