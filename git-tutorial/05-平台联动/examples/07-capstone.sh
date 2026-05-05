#!/bin/bash
# ============================================================
# 07-综合练习-从本地到云端 - 示例脚本
# 功能：模拟完整的"本地到云端"工作流
#       包括 init → add → commit → remote → push →
#       branch → merge → Actions 配置等全流程
# 注意：push 到真实 GitHub 的部分需要替换为实际地址
# ============================================================

set -e

echo "========================================"
echo "  综合练习：从本地到云端 完整演示"
echo "========================================"
echo ""

# -----------------------------------------------------------
# 第一步：创建临时目录作为工作空间
# -----------------------------------------------------------
DEMO_DIR=$(mktemp -d /tmp/capstone-demo-XXXXXX)
cd "$DEMO_DIR"
echo "[INFO] 演示目录：$DEMO_DIR"
echo ""

# 创建模拟的"远程 GitHub 仓库"
mkdir remote-github
cd remote-github && git init --bare && cd "$DEMO_DIR"

# 创建模拟的"远程 Gitee 仓库"
mkdir remote-gitee
cd remote-gitee && git init --bare && cd "$DEMO_DIR"

echo "[模拟] 已创建两个"远程平台"仓库用于演示推送。"
echo ""

# ============================================================
# 阶段一：本地初始化项目
# ============================================================
echo "========================================"
echo "  阶段一：本地初始化项目"
echo "========================================"
echo ""

mkdir todo-app
cd todo-app
git init

echo ""
echo "   git init 完成！现在创建项目文件..."
echo ""

# 创建 README.md
cat > README.md << 'README_CONTENT'
# Todo App

一个简单的待办事项管理应用，用于学习 Git 平台联动。

## 功能
- 添加待办事项
- 列出所有待办
- 删除待办事项
- 标记完成

## 安装
```bash
node src/index.js
```
README_CONTENT

echo "   [OK] README.md 创建完毕"

# 创建 .gitignore
cat > .gitignore << 'GITIGNORE_CONTENT'
node_modules/
.env
*.log
GITIGNORE_CONTENT

echo "   [OK] .gitignore 创建完毕"

# 创建源代码目录和文件
mkdir src

cat > src/index.js << 'JS_CONTENT'
// Todo App 主入口
console.log('=== Todo App 启动！===');

const todos = [];

// 添加待办事项
function addTodo(text) {
    todos.push({ text, done: false });
    console.log(`[添加] ${text}`);
}

// 列出所有待办事项
function listTodos() {
    console.log('\n待办列表：');
    if (todos.length === 0) {
        console.log('  （空）');
        return;
    }
    todos.forEach((t, i) => {
        console.log(`  ${i + 1}. [${t.done ? 'x' : ' '}] ${t.text}`);
    });
}

// 删除待办事项
function deleteTodo(index) {
    if (index >= 0 && index < todos.length) {
        const removed = todos.splice(index, 1);
        console.log(`[删除] ${removed[0].text}`);
    } else {
        console.log('[错误] 无效的待办编号');
    }
}

// 标记完成
function markDone(index) {
    if (index >= 0 && index < todos.length) {
        todos[index].done = true;
        console.log(`[完成] ${todos[index].text}`);
    } else {
        console.log('[错误] 无效的待办编号');
    }
}

// 测试
addTodo('学习 Git 平台联动');
addTodo('完成综合练习');
addTodo('配置 GitHub Actions');
listTodos();

deleteTodo(1);
console.log('\n删除第二个待办后：');
listTodos();

markDone(2);
console.log('\n标记最后一个待办为完成后：');
listTodos();
JS_CONTENT

echo "   [OK] src/index.js 创建完毕"
echo ""

# 第一次提交
echo "--- git status ---"
git status
echo ""

echo "--- git add . ---"
git add .
echo ""

echo "--- git commit ---"
git commit -m "初始化 todo-app 项目骨架"
echo ""

echo "--- git log --oneline ---"
git log --oneline
echo ""

# ============================================================
# 阶段二和三：连接远程仓库并推送
# ============================================================
echo "========================================"
echo "  阶段二/三：连接远程仓库并推送"
echo "========================================"
echo ""

echo "--- git remote add origin ---"
git remote add origin ../remote-github
echo "   命令：git remote add origin ../remote-github"
echo "   真实场景：git remote add origin git@github.com:用户名/todo-app.git"
echo ""

echo "--- git remote -v ---"
git remote -v
echo ""

echo "--- git push -u origin main ---"
git push -u origin main
echo ""
echo "   首次推送成功！-u 建立了追踪关系，以后只需 git push。"
echo ""

# ============================================================
# 阶段四：模拟 Issues（打印操作说明）
# ============================================================
echo "========================================"
echo "  阶段四：用 Issues 管理开发计划（网页操作）"
echo "========================================"
echo ""

cat << 'ISSUES_GUIDE'
   在 GitHub 网页上完成以下操作（此处仅展示步骤）：

   ① 进入仓库的 Issues 标签页
   ② 点击 "New issue" 创建三个 Issue：

      Issue #1 — "完善 README 文档"
        标签：documentation
        内容：现在的 README 太简单，需要补充功能介绍

      Issue #2 — "增加删除待办事项的功能"
        标签：enhancement
        内容：需要增加一个 deleteTodo() 方法

      Issue #3 — "增加标记完成的功能"
        标签：enhancement
        内容：需要增加一个 markDone() 方法

   ③ 点击 "Milestones" → "New milestone"
      创建里程碑：v0.1 基础功能
      将上述三个 Issue 分配到这个里程碑

   ④ 回到 Issues 列表，可以给 Issue 分配标签和里程碑
ISSUES_GUIDE

echo ""

# ============================================================
# 阶段五：创建功能分支，写代码修复 Issue
# ============================================================
echo "========================================"
echo "  阶段五：创建功能分支，写代码修复 Issue"
echo "========================================"
echo ""

echo "--- git checkout -b feature-delete-todo ---"
git checkout -b feature-delete-todo
echo "   创建并切换到功能分支 feature-delete-todo"
echo ""

# 修改代码（在这里假设添加 deleteTodo 功能，实际上这个脚本里已经有了）
# 模拟在现有代码基础上做修改
echo "   [模拟] 在 src/index.js 中增加 deleteTodo() 方法..."
echo ""

# 追加一行注释标记修改
echo "" >> src/index.js
echo "// 功能分支修改：优化了删除提示信息" >> src/index.js

echo "--- git add + git commit（使用 closes #编号 自动关闭 Issue）---"
git add src/index.js
git commit -m "增加删除待办事项功能并优化提示信息

- 新增 deleteTodo() 方法
- 添加无效编号的错误处理
- closes #2"

echo ""
echo "   注意提交信息中的 'closes #2'——"
echo "   推送后 GitHub 会自动关闭 Issue #2。"
echo ""

echo "--- git push origin feature-delete-todo ---"
git push -u origin feature-delete-todo
echo ""

# ============================================================
# 阶段六：模拟 Pull Request 流程（打印说明）
# ============================================================
echo "========================================"
echo "  阶段六：创建 Pull Request（网页操作）"
echo "========================================"
echo ""

cat << 'PR_GUIDE'
   在 GitHub 网页上完成以下操作：

   ① 打开你的仓库页面，你会看到黄色提示条
      "feature-delete-todo had recent pushes..."

   ② 点击 "Compare & pull request"

   ③ 填写 PR 信息：
      标题：增加删除待办事项功能
      描述：增加了 deleteTodo() 方法，支持删除指定编号的待办事项。
            Closes #2

   ④ 点击 "Create pull request"

   ⑤ 在 PR 页面内，点击 "Merge pull request"
      然后点击 "Confirm merge"

   ⑥ 删除 feature-delete-todo 分支（合并后可以删了）

   ⑦ 去 Issues 页面确认 Issue #2 是否自动关闭
PR_GUIDE

echo ""

# 模拟合并后回到 main 拉取最新代码
echo "--- 模拟 PR 合并后，本地拉取最新代码 ---"
git checkout main
git pull origin main
echo ""

# ============================================================
# 阶段七：配置 GitHub Actions
# ============================================================
echo "========================================"
echo "  阶段七：配置 GitHub Actions 自动检查"
echo "========================================"
echo ""

echo "--- 创建工作流目录和文件 ---"
mkdir -p .github/workflows

cat > .github/workflows/check.yml << 'ACTIONS_YAML'
# GitHub Actions 工作流：自动检查代码
name: 代码检查

# 触发条件：push 到 main 分支，或向 main 提 PR
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    # 运行环境
    runs-on: ubuntu-latest

    steps:
      # 第一步：签出代码到虚拟机上
      - name: 签出代码
        uses: actions/checkout@v4

      # 第二步：安装 Node.js
      - name: 安装 Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      # 第三步：检查文件结构
      - name: 检查文件结构
        run: |
          echo "=== 项目文件结构 ==="
          ls -la
          echo ""
          echo "=== src/ 目录内容 ==="
          ls -la src/
          echo ""
          echo "=== 文件结构检查通过！ ==="

      # 第四步：运行代码
      - name: 运行项目代码
        run: node src/index.js
ACTIONS_YAML

echo "   [OK] .github/workflows/check.yml 创建完毕"
echo ""

echo "--- 提交并推送 Actions 配置 ---"
git add .github/workflows/check.yml
git commit -m "添加 GitHub Actions 自动检查工作流"
git push
echo ""

echo "   在真实环境中，push 后去 GitHub 仓库的 Actions 页面，"
echo "   你会看到工作流正在运行。展开每个步骤可以查看输出。"
echo ""

# ============================================================
# 阶段八：添加 Gitee 作为国内镜像
# ============================================================
echo "========================================"
echo "  阶段八：添加 Gitee 作为国内镜像"
echo "========================================"
echo ""

echo "--- git remote add gitee ---"
git remote add gitee ../remote-gitee
echo "   命令：git remote add gitee ../remote-gitee"
echo "   真实场景：git remote add gitee git@gitee.com:用户名/todo-app.git"
echo ""

echo "--- git remote -v（最终状态）---"
git remote -v
echo ""

echo "--- 推送到 GitHub（主仓库）---"
git push origin main
echo ""

echo "--- 推送到 Gitee（国内镜像）---"
git push gitee main
echo ""

# ============================================================
# 最终总结
# ============================================================
echo "========================================"
echo "  完整流程总结"
echo "========================================"
echo ""

cat << 'FINAL_SUMMARY'
   ┌──────────────────────────────────────────────────────────┐
   │                                                          │
   │   从零到云端的完整 Git 工作流（你刚刚走了一遍）          │
   │                                                          │
   │   ① git init                    → 本地初始化仓库         │
   │   ② 写代码 + git add + commit  → 创建版本快照           │
   │   ③ GitHub 网页创建空仓库       → 准备远程"房子"        │
   │   ④ git remote add origin       → 告诉 Git 远程地址      │
   │   ⑤ git push -u origin main     → 首次推送（建立追踪）   │
   │   ⑥ 创建 Issues + Milestone     → 管理开发计划           │
   │   ⑦ git checkout -b 功能分支    → 隔离开发               │
   │   ⑧ 写代码 + commit（fixes #N） → 修复并引用 Issue       │
   │   ⑨ git push origin 功能分支    → 推送分支               │
   │   ⑩ 网页创建 PR + Merge         → 代码审查与合并         │
   │   ⑪ 配置 .github/workflows/     → 设置自动检查           │
   │   ⑫ git remote add gitee        → 添加国内镜像           │
   │                                                          │
   │   你掌握的技能：                                          │
   │   版本管理 → 分支开发 → 远程协作 → 项目管理 → 自动化    │
   │                                                          │
   └──────────────────────────────────────────────────────────┘
FINAL_SUMMARY

echo ""

echo "--- 最终项目的提交历史 ---"
git log --oneline --graph --all
echo ""

echo "--- 最终项目的文件结构 ---"
ls -la
echo ""
find . -not -path './.git/*' -not -name '.git' | sort
echo ""

# ============================================================
# 清理
# ============================================================
echo "========================================"
echo "  清理临时文件"
echo "========================================"
echo ""

cd /tmp
rm -rf "$DEMO_DIR"

echo "[OK] 演示结束，临时文件已清理。"
echo ""
echo "========================================"
echo "  现在你需要用自己的真实账号走一遍："
echo "  1. 在本地创建一个真正的项目"
echo "  2. 在 GitHub 上创建真实仓库"
echo "  3. 按照上面的12个步骤完整走一遍"
echo "  4. 去 GitHub 网页确认每个步骤的结果"
echo ""
echo "  祝你编程愉快！"
echo "========================================"
