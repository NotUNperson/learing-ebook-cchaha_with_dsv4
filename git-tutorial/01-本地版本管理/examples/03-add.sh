#!/bin/bash
# =============================================================================
# 03-add.sh — git add 各种用法实操脚本
# 场景：演示 git add 的多种用法，包括添加单个文件、批量添加、选择性暂存
# 用法：在 Git Bash 中运行  bash 03-add.sh
# 该脚本在 /tmp 下创建临时目录，运行结束后自动清理
# =============================================================================

echo "============================================"
echo "  03 追踪改动（git add） — 实操脚本"
echo "============================================"
echo ""

# 1. 创建临时实验场地
TEMP_DIR="/tmp/git-learn-03-add-$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1
echo ">>> 实验场地：$TEMP_DIR"
echo ""

# 2. 初始化仓库
git init
echo ""

# 3. 创建多个文件，模拟一个真实项目的初始状态
echo "============================================"
echo "  场景：创建多个不同类型的文件"
echo "============================================"
echo ""

echo "项目说明文档" > README.md
echo "print('主程序')" > main.py
echo "print('辅助工具')" > utils.py
echo "一些杂乱的临时笔记" > scratch.txt
echo "登录密码=123456" > .env
mkdir -p images
echo "假图片数据" > images/logo.png

echo ">>> 创建了 5 个文件：README.md, main.py, utils.py, scratch.txt, .env"
echo "    以及 images/ 目录下的 logo.png"
echo ""

# 4. 查看当前状态 —— 全是未跟踪文件
echo ">>> git status —— 所有文件都是未跟踪状态："
git status
echo ""
echo "解读：Git 列出了所有文件，但一个都没跟踪。它们都在办公桌上，Git 不关心。"
echo ""

# 5. 演示：只添加一个文件
echo "============================================"
echo "  用法一：git add <单个文件名> —— 只暂存一个文件"
echo "============================================"
echo ""

git add README.md
echo ">>> 执行了：git add README.md"
echo ""
echo ">>> git status 现在："
git status
echo ""
echo "解读：README.md 进入暂存区（绿色），其他文件仍在工作区（红色）。"
echo "这就是选择性暂存——办公桌上四张纸，我只挑了一张放进文件夹。"
echo ""

# 6. 演示：添加多个指定文件
echo "============================================"
echo "  用法二：git add <文件1> <文件2> —— 一次指定多个文件"
echo "============================================"
echo ""

git add main.py utils.py
echo ">>> 执行了：git add main.py utils.py"
echo ""
echo ">>> git status 现在："
git status
echo ""
echo "解读：main.py 和 utils.py 也进入暂存区了。scratch.txt 和 .env 仍未被跟踪。"
echo ""

# 7. 演示：使用 .gitignore 忽略文件
echo "============================================"
echo "  知识补充：.gitignore —— 让 Git 忽略某些文件"
echo "============================================"
echo ""

echo "*.txt" > .gitignore
echo ".env" >> .gitignore
echo ""
echo ">>> 创建了 .gitignore 文件，内容如下："
cat .gitignore
echo ""
echo ">>> 现在 git status："
git status
echo ""
echo "解读：scratch.txt 和 .env 从 'Untracked files' 列表中消失了！"
echo ".gitignore 就像一份'不招人名单'，被它匹配的文件 Git 会主动忽略。"
echo ""

# 8. 演示：git add . —— 批量添加当前目录
echo "============================================"
echo "  用法三：git add . —— 添加当前目录所有文件"
echo "============================================"
echo ""

git add .
echo ">>> 执行了：git add ."
echo ""
echo ">>> git status："
git status
echo ""
echo "解读：所有未被 .gitignore 忽略的文件都进入了暂存区。"
echo "（.gitignore 自己也被暂存了——这个配置文件你应该提交，让协作的人也遵循同样的忽略规则）"
echo ""

# 9. 提交一次，建立基线
git commit -m "初始提交：项目搭建" > /dev/null 2>&1

# 10. 演示：修改已跟踪文件后需要重新 add
echo "============================================"
echo "  重要概念：修改已跟踪文件后，需要重新 git add"
echo "============================================"
echo ""

echo "添加了新功能代码" >> main.py
echo ""
echo ">>> 在 main.py 末尾追加了一行"
echo ""
echo ">>> git status："
git status
echo ""
echo "解读：main.py 出现在 'Changes not staged for commit'（红色），"
echo "表示它是一个已跟踪文件，但当前修改还在工作区，没有进入暂存区。"
echo ""
echo "这证明了一个关键点：git add 只暂存当时那一刻的快照。"
echo ""

# 11. 再次 add 这个修改过的文件
echo ">>> 执行：git add main.py"
git add main.py
echo ""
echo ">>> git status："
git status
echo ""
echo "现在 main.py 重新进入暂存区了。"
echo ""

# 12. 演示：git add -p 的概念（交互式暂存）
echo "============================================"
echo "  用法四：git add -p —— 交互式暂存（概念展示）"
echo "============================================"
echo ""

# 创建一个有多个修改的文件来展示 -p 的概念
echo "行1：原始内容" > patch-demo.txt
echo "行2：原始内容" >> patch-demo.txt
echo "行3：原始内容" >> patch-demo.txt
git add patch-demo.txt
git commit -m "添加演示文件" > /dev/null 2>&1

# 修改多行
cat > patch-demo.txt << 'INNEREOF'
行1：原始内容
行2：这是修改过的内容
行3：原始内容
行4：这是新增的一行
INNEREOF

echo ">>> 我们修改了 patch-demo.txt 的部分内容："
echo ""
echo "变化如下："
echo "  行2：从 '原始内容' 改为 '这是修改过的内容'"
echo "  行4：新增一行"
echo ""
echo ">>> 运行 git add -p 会逐块询问你是否暂存："
echo "    y = 暂存这一块    n = 跳过这一块    s = 拆分成更小块"
echo "    （实际脚本中我们跳过交互，但你可以自己试试这条命令）"
echo ""
echo ">>> 查看当前差异（git diff）："
git diff patch-demo.txt
echo ""

# 清理
echo "============================================"
echo "  脚本执行完毕，清理临时目录..."
echo "============================================"
cd /tmp || exit
rm -rf "$TEMP_DIR"
echo ">>> 已删除 $TEMP_DIR"
echo ""
echo "今天学到的四种 git add 用法："
echo "  1. git add <文件名>         —— 只加一个文件"
echo "  2. git add <文件1> <文件2>  —— 加多个指定文件"
echo "  3. git add .                —— 加当前目录所有文件"
echo "  4. git add -p               —— 逐块选择，精细控制"
echo ""
echo "核心记住：git add 是把办公桌上的纸张挑好放进文件夹，还没归档。"
