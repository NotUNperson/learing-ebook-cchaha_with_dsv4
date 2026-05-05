#!/bin/bash
# =============================================================================
# 07-undo.sh — 撤销和回退操作实操脚本
# 场景：演示 git restore、git restore --staged、git reset（三种模式）、git revert
# 用法：在 Git Bash 中运行  bash 07-undo.sh
# 该脚本在 /tmp 下创建临时目录，运行结束后自动清理
# =============================================================================

echo "============================================"
echo "  07 撤销和回退操作 — 实操脚本"
echo "============================================"
echo ""

# 1. 创建临时实验场地
TEMP_DIR="/tmp/git-learn-07-undo-$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ">>> 实验场地：$TEMP_DIR"
echo ""

# 2. 初始化仓库，建立基线
git init > /dev/null 2>&1
echo "原始内容：这是重要的文件" > important.txt
echo "版本 1 的内容" > changelog.txt
git add .
git commit -m "初始提交：建立基线版本" > /dev/null 2>&1
echo ">>> 已完成初始提交，建立了基线版本"
echo ""

# ===========================================================================
# 场景一：轻度后悔 —— git restore（撤销工作区的修改）
# ===========================================================================
echo "============================================"
echo "  场景一：轻度后悔 —— git restore"
echo "  情景：你改了一个文件，还没 add，但改错了，想恢复"
echo "============================================"
echo ""

echo "不小心覆盖了重要文件的内容"
echo "不小心写错的内容！！！" > important.txt
echo ""
echo ">>> important.txt 现在的错误内容："
cat important.txt
echo ""

echo ">>> git status："
git status
echo ""
echo ">>> 后悔了！执行 git restore important.txt"
git restore important.txt
echo ""

echo ">>> important.txt 恢复到原始内容："
cat important.txt
echo ""
echo ">>> git status："
git status
echo ""
echo "解读：文件恢复了！工作区重新变得干净。"
echo "这就好比用橡皮擦擦掉了刚写的错字。"
echo ""

# ===========================================================================
# 场景二：撤销暂存 —— git restore --staged
# ===========================================================================
echo "============================================"
echo "  场景二：撤销暂存 —— git restore --staged"
echo "  情景：你 add 了文件，但临时决定这个文件先不提交"
echo "============================================"
echo ""

echo "对文件做了有用的修改"
echo "版本 2 的内容：添加了新功能说明" > changelog.txt
git add changelog.txt
echo ">>> 修改并暂存了 changelog.txt"
echo ""

echo ">>> git status："
git status
echo ""
echo ">>> 突然决定先不提交 changelog.txt，把它从暂存区拿出来："
echo "    执行 git restore --staged changelog.txt"
git restore --staged changelog.txt
echo ""

echo ">>> git status："
git status
echo ""
echo "解读：changelog.txt 回到 'Changes not staged'（红色，在工作区）"
echo "文件修改内容还在，只是从'准备提交'变成了'还没暂存'。"
echo ""

# 恢复干净状态，把 changelog 改回去
git restore changelog.txt

# ===========================================================================
# 场景三：重置提交 —— git reset --soft
# ===========================================================================
echo "============================================"
echo "  场景三：重置提交（温柔版）—— git reset --soft"
echo "  情景：刚提交完，发现提交信息写错了"
echo "============================================"
echo ""

echo "版本 2 的更新" >> changelog.txt
git add changelog.txt
git commit -m "这系一条有错别字的提交信息" > /dev/null 2>&1
echo ">>> 创建了一次提交，但提交信息有错别字..."
echo ""

echo ">>> 提交历史："
git log --oneline -2
echo ""

echo ">>> 后悔了！执行 git reset --soft HEAD~1"
git reset --soft HEAD~1
echo ""

echo ">>> 提交历史（刚才那条提交消失了）："
git log --oneline -2
echo ""

echo ">>> git status（修改内容回到暂存区，可以重新提交）："
git status
echo ""

echo ">>> 现在重新提交，用正确的信息："
git commit -m "这是一条没有错别字的提交信息" > /dev/null 2>&1
echo "    已完成。"
echo ""

echo ">>> 提交历史："
git log --oneline -3
echo ""
echo "解读：git reset --soft HEAD~1 撤销了提交，但修改留在暂存区。"
echo "你可以修改提交信息后重新提交，就像什么都没发生过。"
echo ""

# ===========================================================================
# 场景四：重置提交 —— git reset --mixed（默认）
# ===========================================================================
echo "============================================"
echo "  场景四：重置提交（标准版）—— git reset（默认 --mixed）"
echo "  情景：提交了，但想重新组织这次的修改"
echo "============================================"
echo ""

echo "版本 3 的复杂改动" >> changelog.txt
echo "一些零散的笔记" > notes.txt
git add .
git commit -m "一堆杂七杂八的改动" > /dev/null 2>&1
echo ">>> 创建了一次提交，包含 changelog.txt 和 notes.txt"
echo ""

echo ">>> 后悔了！想把这次提交拆成两个更清晰的提交。"
echo "    执行 git reset HEAD~1"
git reset HEAD~1
echo ""

echo ">>> git status："
git status
echo ""
echo ">>> 提交历史："
git log --oneline -2
echo ""
echo "解读：提交被撤销了，但文件修改都在工作区（未暂存状态）。"
echo "你可以分批 add 和 commit，把一个大提交拆成几个小提交。"
echo ""

# 演示拆分提交
git add changelog.txt
git commit -m "更新 changelog 到版本 3" > /dev/null 2>&1
git add notes.txt
git commit -m "添加零散笔记" > /dev/null 2>&1
echo ">>> 现在拆成了两个清晰的提交："
git log --oneline -3
echo ""

# ===========================================================================
# 场景五：最彻底的后悔 —— git reset --hard
# ===========================================================================
echo "============================================"
echo "  场景五：最彻底的后悔 —— git reset --hard"
echo "  情景：最近的提交完全搞错了，想彻底回到之前的状态"
echo "  警告：--hard 会丢弃所有未提交的修改！"
echo "============================================"
echo ""

echo "一个完全错误的改动" > mistake.txt
git add mistake.txt
git commit -m "这是一个错误的提交" > /dev/null 2>&1
echo ">>> 创建了一个完全错误的提交"
echo ""

echo ">>> 当前提交历史："
git log --oneline -3
echo ""

echo ">>> 执行 git reset --hard HEAD~1（回退到上一个版本，丢弃所有改动）"
git reset --hard HEAD~1
echo ""

echo ">>> 提交历史（错误的提交消失了）："
git log --oneline -3
echo ""
echo ">>> 工作区文件："
ls -la
echo ""
echo "解读：mistake.txt 彻底消失了，工作区回到了之前的状态。"
echo "--hard 是最强的后悔药，但也是最危险的。请三思而后用。"
echo ""

# ===========================================================================
# 场景六：保留历史的后悔 —— git revert
# ===========================================================================
echo "============================================"
echo "  场景六：保留历史的后悔 —— git revert"
echo "  情景：改动已经分享给别人了，不能改历史，只能'更正'"
echo "============================================"
echo ""

# 先创建一个有问题的提交
echo "这个功能有 bug，但不小心提交了" > feature.txt
git add feature.txt
git commit -m "添加新功能（但后来发现有 bug）" > /dev/null 2>&1

# 获取这个提交的哈希
BAD_COMMIT=$(git log --oneline -1 --format="%h")
echo ">>> 创建了一个有 bug 的提交：$BAD_COMMIT"
echo ""

echo ">>> 提交历史："
git log --oneline -3
echo ""

echo ">>> 执行 git revert $BAD_COMMIT（创建一次'反向提交'来抵消它）"
git revert --no-edit "$BAD_COMMIT"
echo ""

echo ">>> 提交历史（注意多了一条 'Revert' 提交）："
git log --oneline -4
echo ""
echo ">>> feature.txt 的内容："
cat feature.txt 2>/dev/null || echo "(文件已不存在)"
echo ""
echo "解读：feature.txt 被删除了（因为原来的提交是创建它，revert 就删除它）。"
echo "但历史记录里保留了完整的轨迹——原来的提交和取消它的提交都在。"
echo "这种方式适合用在已经推送到远程仓库的场景。"
echo ""

# ===========================================================================
# 总结
# ===========================================================================
echo "============================================"
echo "  三种后悔药总结"
echo "============================================"
echo ""
echo "  轻度（办公桌）：git restore           擦掉草稿纸上的涂改"
echo "  轻度（暂存区）：git restore --staged   把纸张从文件夹拿回办公桌"
echo "  中度（仓库）  ：git reset --soft      从档案柜拿出文件袋，内容回文件夹"
echo "  中度（仓库）  ：git reset（默认）      从档案柜拿出，内容回办公桌"
echo "  重度（仓库）  ：git reset --hard      从档案柜拿出，办公桌和文件夹都清空"
echo "  保留历史      ：git revert            不改历史，新建一次"更正"提交"
echo ""
echo "核心原则：没推送的可以 reset，已推送的必须用 revert。"
echo ""

# 清理
echo "============================================"
echo "  脚本执行完毕，清理临时目录..."
echo "============================================"
cd /tmp || exit
rm -rf "$TEMP_DIR"
echo ">>> 已删除 $TEMP_DIR"
echo ""
echo "建议：在你自己创建的测试仓库中多练习几次，"
echo "尤其是 git reset --hard，在安全环境中感受它的威力。"
echo "只有亲手用过，才能真正理解每种后悔药的效果。"
