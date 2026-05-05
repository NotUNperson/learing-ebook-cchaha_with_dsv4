#!/bin/bash
# ============================================================
# 06-多平台联动 - 示例脚本
# 功能：演示一个本地仓库同时关联多个远程平台
#       包括添加多个 remote、分别推送、一次性推送
# ============================================================

set -e

echo "========================================"
echo "  多平台联动演示脚本"
echo "========================================"
echo ""

# -----------------------------------------------------------
# 第一步：创建临时目录和"模拟的远程仓库"
# -----------------------------------------------------------
DEMO_DIR=$(mktemp -d /tmp/multi-remote-demo-XXXXXX)
cd "$DEMO_DIR"
echo "[INFO] 演示目录：$DEMO_DIR"
echo ""

# 创建三个目录，模拟三个不同的托管平台
mkdir remote-github   # 模拟 GitHub
mkdir remote-gitee    # 模拟 Gitee（码云）
mkdir remote-gitlab   # 模拟 GitLab

# 把它们都初始化为裸仓库（bare repo），模拟远程服务器上的仓库
cd remote-github && git init --bare && cd ..
cd remote-gitee  && git init --bare && cd ..
cd remote-gitlab && git init --bare && cd ..

echo "[模拟] 创建了三个"远程平台上的空仓库"："
echo "   remote-github/  → 模拟 GitHub 上的仓库"
echo "   remote-gitee/   → 模拟 Gitee（码云）上的仓库"
echo "   remote-gitlab/  → 模拟 GitLab 上的仓库"
echo ""

# -----------------------------------------------------------
# 第二步：创建本地仓库
# -----------------------------------------------------------
echo ">>> 第一步：创建本地仓库"
echo ""

mkdir my-local-project
cd my-local-project
git init

echo "# 多平台联动练习项目" > README.md
echo "" >> README.md
echo "这个项目同时托管在 GitHub、Gitee 和 GitLab 上。" >> README.md
echo "console.log('Hello from multi-platform project!');" > main.js

git add .
git commit -m "初始提交"

echo ""
echo "   本地仓库创建完毕，目前只有一个初始提交。"
echo "   接下来把它同时关联到三个"平台"。"
echo ""

# -----------------------------------------------------------
# 第三步：添加第一个 remote（origin，指向 GitHub）
# -----------------------------------------------------------
echo ">>> 第二步：添加 origin（指向 GitHub 模拟仓库）"
echo ""

git remote add origin ../remote-github

echo "   命令：git remote add origin ../remote-github"
echo "   真实场景：git remote add origin git@github.com:用户名/项目.git"
echo ""

# -----------------------------------------------------------
# 第四步：添加 gitee remote
# -----------------------------------------------------------
echo ">>> 第三步：添加 gitee remote（指向 Gitee 模拟仓库）"
echo ""

git remote add gitee ../remote-gitee

echo "   命令：git remote add gitee ../remote-gitee"
echo "   真实场景：git remote add gitee git@gitee.com:用户名/项目.git"
echo ""

# -----------------------------------------------------------
# 第五步：添加 gitlab remote
# -----------------------------------------------------------
echo ">>> 第四步：添加 gitlab remote（指向 GitLab 模拟仓库）"
echo ""

git remote add gitlab ../remote-gitlab

echo "   命令：git remote add gitlab ../remote-gitlab"
echo "   真实场景：git remote add gitlab git@gitlab.com:用户名/项目.git"
echo ""

# -----------------------------------------------------------
# 第六步：查看所有 remote 配置
# -----------------------------------------------------------
echo ">>> 第五步：git remote -v —— 查看所有远程地址"
echo ""

git remote -v

echo ""
echo "   现在本地仓库有了三个"朋友"："
echo "   origin  → 推送到 GitHub（主仓库）"
echo "   gitee   → 推送到 Gitee（国内镜像）"
echo "   gitlab  → 推送到 GitLab（备份/公司要求）"
echo ""

# -----------------------------------------------------------
# 第七步：分别推送到各个平台
# -----------------------------------------------------------
echo ">>> 第六步：分别推送到各个平台"
echo ""

# 获取当前分支名
BRANCH=$(git branch --show-current)

echo "--- git push origin $BRANCH ---"
git push origin "$BRANCH"
echo "   [OK] 推送到 GitHub"
echo ""

echo "--- git push gitee $BRANCH ---"
git push gitee "$BRANCH"
echo "   [OK] 推送到 Gitee"
echo ""

echo "--- git push gitlab $BRANCH ---"
git push gitlab "$BRANCH"
echo "   [OK] 推送到 GitLab"
echo ""

echo "   三个平台都已经收到了初始提交。"
echo ""

# -----------------------------------------------------------
# 第八步：修改代码并再次分别推送
# -----------------------------------------------------------
echo ">>> 第七步：修改代码，再次分别推送"
echo ""

echo "// 新增功能" >> main.js
echo "console.log('Feature: multi-platform sync');" >> main.js

git add main.js
git commit -m "添加多平台同步功能"

echo "   提交完毕，现在分别推送到三个平台："
echo ""

echo "   日常使用中，你只需要："
echo "   git push origin $BRANCH   → 推主仓库"
echo "   git push gitee $BRANCH    → 顺便推一下国内镜像"
echo ""

# 推送到三个平台
git push origin "$BRANCH"
echo ""
git push gitee "$BRANCH"
echo ""
git push gitlab "$BRANCH"
echo ""

# -----------------------------------------------------------
# 第九步：验证三个远程仓库的内容是否一致
# -----------------------------------------------------------
echo ">>> 第八步：验证三个远程仓库内容一致"
echo ""

echo "--- origin (GitHub) 的提交历史 ---"
git ls-remote origin | head -n 3
echo ""

echo "--- gitee 的提交历史 ---"
git ls-remote gitee | head -n 3
echo ""

echo "--- gitlab 的提交历史 ---"
git ls-remote gitlab | head -n 3
echo ""

echo "   三个平台的提交引用应该不同（因为每个仓库是独立的），"
echo "   但你的代码内容是完全一样的。"
echo ""

# -----------------------------------------------------------
# 第十步：展示 remote 管理命令
# -----------------------------------------------------------
echo ">>> 第九步：remote 管理常用命令"
echo ""

echo "   # 查看所有远程仓库"
echo "   git remote -v"
echo ""
echo "   # 查看某个远程仓库的详细信息"
echo "   git remote show origin"
echo ""
echo "   # 重命名一个远程仓库"
echo "   git remote rename gitee gitee-mirror"
echo ""
echo "   # 删除一个远程仓库"
echo "   git remote remove gitlab"
echo ""
echo "   # 修改远程仓库地址"
echo "   git remote set-url origin git@github.com:新用户名/项目.git"
echo ""

# -----------------------------------------------------------
# 第十一步：展示"叠加 URL"的进阶用法
# -----------------------------------------------------------
echo ">>> 第十步：进阶用法 —— 给 origin 叠加多个 push 地址"
echo ""

cat << 'ADVANCED'
   如果你希望敲一次 git push origin 就同时推到多个平台，
   可以给 origin 叠加额外的 push URL：

   # 给 origin 添加第二个 push 地址
   git remote set-url --add origin git@gitee.com:用户名/项目.git

   # 执行后，git push origin main 会同时推到 GitHub 和 Gitee
   # 查看结果：
   git remote -v
   # origin  git@github.com:用户名/项目.git (fetch)
   # origin  git@github.com:用户名/项目.git (push)
   # origin  git@gitee.com:用户名/项目.git (push)

   注意：fetch 只有一个地址，push 有两个。这很合理——
   下载只从主仓库（GitHub）下，上传同时推两个。

   但对于初学者，建议还是保持独立 remote 名字，清晰不易混。
ADVANCED

echo ""

# -----------------------------------------------------------
# 第十二步：完整流程总结
# -----------------------------------------------------------
echo ">>> 第十一步：完整流程总结"
echo ""

cat << 'SUMMARY'
   多平台联动完整步骤：

   【一次性配置】
   ① 在 Gitee/GitLab 网页上创建同名空仓库
   ② 把 SSH 公钥添加到 Gitee/GitLab
   ③ git remote add gitee  <Gitee SSH 地址>
   ④ git remote add gitlab <GitLab SSH 地址>

   【每次推送】
   ⑤ git add . + git commit -m "..."
   ⑥ git push origin main    → GitHub
   ⑦ git push gitee main     → Gitee（国内镜像）
   ⑧ git push gitlab main    → GitLab（如有需要）

   【拉取代码】
   ⑨ git pull origin main    → 默认从 GitHub 拉取
   ⑩ git pull gitee main     → 从 Gitee 拉取（国内更快）

   推荐配置：
   ┌──────────────────────────────────────────────┐
   │  origin  = GitHub（主仓库，功能最全）         │
   │  gitee   = Gitee（国内镜像，速度快）          │
   │  gitlab  = GitLab（可选，作为备份或公司需要）  │
   └──────────────────────────────────────────────┘
SUMMARY

echo ""

# -----------------------------------------------------------
# 清理
# -----------------------------------------------------------
echo ">>> 清理临时文件"
echo ""

cd /tmp
rm -rf "$DEMO_DIR"

echo "[OK] 演示结束，临时文件已清理。"
echo ""
echo "========================================"
echo "  在真实环境中操作时："
echo "  1. 先在各个平台网页上创建同名空仓库"
echo "  2. 复制每个仓库的 SSH 地址"
echo "  3. git remote add <别名> <地址>"
echo "  4. git push <别名> main"
echo "========================================"
