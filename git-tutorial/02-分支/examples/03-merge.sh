#!/bin/bash
# ============================================================================
# 03-合并分支 - 示例脚本
# 演示 git merge 的两种方式：快进合并 和 三路合并
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

# 创建初始提交
echo "第一章：主角在村庄醒来" > story.txt
git add story.txt
git commit -m "第一章：村庄" --quiet

echo "第二章：主角决定踏上冒险" >> story.txt
git add story.txt
git commit -m "第二章：出发冒险" --quiet

echo "第三章：主角穿过森林" >> story.txt
git add story.txt
git commit -m "第三章：穿过森林" --quiet

# 创建另一个文件用于三路合并演示（避免与快进合并的文件冲突）
echo "装备：木剑" > hero_inventory.txt
git add hero_inventory.txt
git commit -m "初始装备：木剑" --quiet
git branch -m main  # 将默认分支重命名为 main（兼容不同 Git 版本）

echo ""
echo "========================================="
echo "  演示一：快进合并（Fast-forward）"
echo "  场景：main 没有新提交，只有 feature 在前进"
echo "========================================="

# 创建 feature 分支并切换过去
git switch -c feature-elixir

# 在 feature 分支上做两次提交
echo "第四章（支线）：发现生命灵药" >> story.txt
git add story.txt
git commit -m "支线：发现生命灵药" --quiet

echo "第五章（支线）：喝下灵药，获得新能力" >> story.txt
git add story.txt
git commit -m "支线：获得新能力" --quiet

echo ""
echo "合并前的分支图："
git log --oneline --graph --all

echo ""
echo "现在把 feature-elixir 合并到 main："
echo "  1. 切换到 main"
git switch main
echo "  2. 执行合并"

# 执行合并
git merge feature-elixir --no-edit

echo ""
echo "合并后的分支图（注意没有新的合并提交，是一条直线）："
git log --oneline --graph --all
echo "这就是'快进合并'——main 直接追上了 feature 的进度"

echo ""
echo "========================================="
echo "  演示二：三路合并（Three-way Merge）"
echo "========================================="

# 清理演示一的分支，保持环境整洁
git branch -D feature-elixir 2>/dev/null || true

# 创建 feature 分支，添加新功能
git switch -c feature-sword

echo "第四章（支线B）：获得魔法剑" >> hero_inventory.txt
git add hero_inventory.txt
git commit -m "支线B：获得魔法剑" --quiet

echo "第五章（支线B）：用魔法剑击败守卫" >> hero_inventory.txt
git add hero_inventory.txt
git commit -m "支线B：击败守卫" --quiet

# 回到 main，同时 main 自己也往前走（修改不同的文件，避免冲突）
git switch main

echo "第四章（主线）：主角在城镇休息" >> story.txt
git add story.txt
git commit -m "主线：城镇休息" --quiet

echo ""
echo "合并前的分支图（两边都有新提交）："
git log --oneline --graph --all

echo ""
echo "现在把 feature-sword 合并到 main："
echo "  两边都有新提交，Git 需要进行三路合并"

# 三路合并
git merge feature-sword --no-edit

echo ""
echo "合并后的分支图（注意新增的合并提交）："
git log --oneline --graph --all
echo ""
echo "观察：合并提交同时连接了 main 和 feature-sword 两条线"

echo ""
echo "========================================="
echo "  查看文件内容："
echo "========================================="
echo "--- story.txt ---"
cat story.txt
echo ""
echo "--- hero_inventory.txt ---"
cat hero_inventory.txt

echo ""
echo "========================================="
echo "  总结："
echo "  - 快进合并：目标分支没有新提交，指针直接'快进'"
echo "  - 三路合并：两边都有新提交，Git 创建一个新的合并提交"
echo "  - 合并命令：git switch 目标分支 -> git merge 源分支"
echo "========================================="
echo ""
echo "演示仓库位于：$WORK_DIR"
