#!/bin/bash
# =============================================================================
# 05-log.sh — git log 查看历史实操脚本
# 场景：创建一个有多条提交的项目，然后演示 git log 的各种用法
# 用法：在 Git Bash 中运行  bash 05-log.sh
# 该脚本在 /tmp 下创建临时目录，运行结束后自动清理
# =============================================================================

echo "============================================"
echo "  05 查看历史（git log） — 实操脚本"
echo "============================================"
echo ""

# 1. 创建临时实验场地
TEMP_DIR="/tmp/git-learn-05-log-$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ">>> 实验场地：$TEMP_DIR"
echo ""

# 2. 初始化仓库
git init
echo ""

# 3. 模拟一个项目的历史，做多次提交
echo "============================================"
echo "  场景：模拟一个博客项目的开发历史"
echo "============================================"
echo ""

# 提交 1
echo "# 我的博客" > README.md
git add README.md
git commit -m "初始化项目：创建 README" > /dev/null 2>&1

# 提交 2
mkdir -p posts
echo "这是第一篇博客文章" > posts/first-post.md
git add .
git commit -m "feat: 添加第一篇文章" > /dev/null 2>&1

# 提交 3
echo "这是第二篇博客文章" > posts/second-post.md
git add .
git commit -m "feat: 添加第二篇文章" > /dev/null 2>&1

# 提交 4
echo "header { background: blue; }" > style.css
git add .
git commit -m "feat: 添加样式文件" > /dev/null 2>&1

# 提交 5
# 修改之前的文件
echo "header { background: #333; color: white; }" > style.css
git add style.css
git commit -m "fix: 修复 header 背景色太亮的问题" > /dev/null 2>&1

# 提交 6
echo "## 关于我" >> README.md
echo "我是一名开发者" >> README.md
git add README.md
git commit -m "docs: 在 README 中添加自我介绍" > /dev/null 2>&1

echo ">>> 已完成 6 次提交，模拟了一个博客项目的发展过程。"
echo ""

# 4. 最基本的 git log
echo "============================================"
echo "  用法一：git log（基本格式）"
echo "============================================"
echo ""
git log
echo ""

# 5. git log --oneline
echo "============================================"
echo "  用法二：git log --oneline（紧凑格式，最常用）"
echo "============================================"
echo ""
git log --oneline
echo ""

# 6. git log --oneline --graph
echo "============================================"
echo "  用法三：git log --oneline --graph（带分支图）"
echo "============================================"
echo ""
git log --oneline --graph
echo "（目前只有一个分支，所以图是一条竖线。以后有了多个分支，图会变得更有趣。）"
echo ""

# 7. git log --stat
echo "============================================"
echo "  用法四：git log --stat（显示改了什么文件）"
echo "============================================"
echo ""
git log --stat -3
echo ""

# 8. git log -p
echo "============================================"
echo "  用法五：git log -p（显示具体改动内容，最近 2 条）"
echo "============================================"
echo ""
git log -p -2
echo ""

# 9. 限制条数
echo "============================================"
echo "  用法六：git log -n（限制显示条数）"
echo "============================================"
echo ""
echo ">>> git log --oneline -3（只看最近 3 条）："
git log --oneline -3
echo ""

# 10. 搜索提交信息
echo "============================================"
echo "  用法七：git log --grep（搜索提交信息）"
echo "============================================"
echo ""
echo ">>> 搜索包含 'fix' 的提交："
git log --oneline --grep="fix"
echo ""

# 11. 查看某个文件的历史
echo "============================================"
echo "  用法八：git log -- <文件名>（看某个文件的提交历史）"
echo "============================================"
echo ""
echo ">>> 只看 README.md 的提交历史："
git log --oneline -- README.md
echo ""
echo ">>> 只看 style.css 的提交历史："
git log --oneline -- style.css
echo ""

# 12. 黄金组合
echo "============================================"
echo "  黄金组合：git log --oneline --graph --all"
echo "============================================"
echo ""
git log --oneline --graph --all
echo ""
echo "这个组合让你一眼看到整个项目的全貌。建议你把它记住。"
echo ""

# 13. git show 查看某次提交的详细信息
echo "============================================"
echo "  git show 查看某次提交的详细信息"
echo "============================================"
echo ""

# 获取倒数第三次提交的哈希
COMMIT_HASH=$(git log --oneline --format="%h" | sed -n '3p')
echo ">>> 查看提交 $COMMIT_HASH 的详细信息："
echo ""
git show "$COMMIT_HASH" --stat
echo ""

# 清理
echo "============================================"
echo "  脚本执行完毕，清理临时目录..."
echo "============================================"
cd /tmp || exit
rm -rf "$TEMP_DIR"
echo ">>> 已删除 $TEMP_DIR"
echo ""
echo "今天学到的 git log 常用选项："
echo "  git log                      基本格式"
echo "  git log --oneline            紧凑一行"
echo "  git log --oneline --graph    带分支图"
echo "  git log --stat               看改了哪些文件"
echo "  git log -p                   看具体改动内容"
echo "  git log -3                   只看最近 3 条"
echo "  git log --grep='关键词'       搜索提交信息"
echo "  git log -- <文件名>           看某个文件的历史"
echo ""
echo "建议记住：git log --oneline --graph --all 这个黄金组合。"
