#!/bin/bash
# ============================================================================
# 04-合并冲突及手动解决 - 示例脚本
# 演示如何制造冲突、读懂冲突标记、手动解决冲突
# ============================================================================

set -e

WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"
echo "==> 演示仓库：$WORK_DIR"

# 初始化仓库
git init
# 设置本地用户信息（避免依赖全局配置）
git config user.email "demo@example.com"
git config user.name "Git教程演示"

# 创建初始文件
echo "主题颜色 = 默认白色" > config.txt
echo "字体大小 = 14px" >> config.txt
git add config.txt
git commit -m "初始配置" --quiet
git branch -m main  # 将默认分支重命名为 main（兼容不同 Git 版本）

echo ""
echo "========================================="
echo "  场景：两个人改了同一行配置"
echo "========================================="
echo ""
echo "初始 config.txt 内容："
cat config.txt

echo ""
echo "--- 小明创建 feature-blue 分支，把主题改成蓝色 ---"
git switch -c feature-blue
echo "主题颜色 = 蓝色（小明喜欢的颜色）" > config.txt
echo "字体大小 = 14px" >> config.txt
git add config.txt
git commit -m "小明：改成蓝色主题" --quiet
echo "小明的版本："
cat config.txt

echo ""
echo "--- 你回到 main 分支，把主题改成红色 ---"
git switch main
echo "主题颜色 = 红色（你觉得红色更好看）" > config.txt
echo "字体大小 = 14px" >> config.txt
git add config.txt
git commit -m "你：改成红色主题" --quiet
echo "你的版本："
cat config.txt

echo ""
echo "========================================="
echo "  现在合并 feature-blue 到 main"
echo "  同一行被改成了两个不同的值——冲突！"
echo "========================================="

# 尝试合并，预期会冲突
git merge feature-blue 2>&1 || true

echo ""
echo "========================================="
echo "  Git 报告了冲突！让我们查看 config.txt："
echo "========================================="
echo ""
echo "=== config.txt 内容（含冲突标记）==="
cat config.txt
echo "=== 文件结束 ==="

echo ""
echo "========================================="
echo "  冲突标记解读："
echo "  <<<<<<< HEAD       ← 你当前分支的版本开始"
echo "  主题颜色 = 红色     ← 你的版本（main）"
echo "  =======            ← 分隔线"
echo "  主题颜色 = 蓝色     ← 小明的版本（feature-blue）"
echo "  >>>>>>> feature-blue ← feature-blue 版本结束"
echo "========================================="

echo ""
echo "========================================="
echo "  解决冲突：手动编辑文件"
echo "  我们决定把两个颜色都写上（折中方案）"
echo "========================================="

# 用脚本模拟手动编辑——写入最终版本
echo "主题颜色 = 红蓝渐变（你和小明各让一步）" > config.txt
echo "字体大小 = 14px" >> config.txt

echo "解决后的 config.txt："
cat config.txt

echo ""
echo "将解决好的文件加入暂存区（告诉 Git 冲突已解决）："
git add config.txt
echo "git add config.txt 完成"

echo ""
echo "完成合并提交："
git commit -m "合并：解决主题颜色冲突，采用红蓝渐变方案" --quiet
echo "提交完成！"

echo ""
echo "========================================="
echo "  合并后的分支图："
echo "========================================="
git log --oneline --graph --all

echo ""
echo "========================================="
echo "  额外演示：git merge --abort（放弃合并）"
echo "========================================="

# 先恢复，再重新制造一个冲突来演示 --abort
git reset --hard HEAD~1
echo ""
echo "回到合并前的状态..."

# 修改 main 上的 config.txt，制造新的冲突
echo "主题颜色 = 绿色" > config.txt
echo "字体大小 = 14px" >> config.txt
git add config.txt
git commit -m "你：又改成了绿色" --quiet

# 在 feature-blue 上也改一下
git switch feature-blue
echo "主题颜色 = 橙色" > config.txt
echo "字体大小 = 14px" >> config.txt
git add config.txt
git commit -m "小明：又改成了橙色" --quiet

# 回到 main 尝试合并
git switch main
echo ""
echo "再次触发冲突..."
git merge feature-blue 2>&1 || true

echo ""
echo "这一次我们不想解决了，直接放弃合并："
git merge --abort
echo "git merge --abort 完成，回到合并前的安全状态"

echo ""
echo "验证是否真的回退了："
git status
git log --oneline --graph --all

echo ""
echo "========================================="
echo "  总结："
echo "  - 冲突 = 两个人改了同一行"
echo "  - <<<<<<< ======= >>>>>>> 是冲突标记"
echo "  - 解决 = 删除标记 + 编辑内容 + git add + git commit"
echo "  - git merge --abort = 安全的后悔药"
echo "========================================="
echo ""
echo "演示仓库位于：$WORK_DIR"
