# 02 本地仓库推送到 GitHub

## 本节你会学到什么

- 在 GitHub 网页上创建一个全新的仓库
- 把本地已存在的 Git 仓库和 GitHub 远程仓库"配对"
- 理解 `git remote`、`origin`、`git push -u` 的含义
- 把本地代码推送到 GitHub 并在网页上看到它
- 理解"本地仓库"和"远程仓库"的关系

## 一个生活类比：搬家

想象你要搬家。过程是这样的：

1. **找房东，租一个空房子** → 在 GitHub 上创建一个空的远程仓库
2. **拿到新房子的地址** → 从 GitHub 网页上复制仓库的 SSH 地址
3. **告诉搬家公司"新地址是什么"** → `git remote add origin <地址>`，把"去向"告诉 Git
4. **把家具搬上车** → `git add` 和 `git commit`（你已经会了）
5. **货车开去新家，把家具搬进去** → `git push`

GitHub 上的空仓库就像一间空房子——你的代码搬进去之后，这间房子才真正有了"家"的样子。

## 第一步：在 GitHub 网页上创建仓库

打开 [GitHub](https://github.com)，确保已登录。

1. 点击页面右上角的 **"+"** 号，选择 **New repository**
2. 在 "Repository name" 栏填你的项目名，例如 `my-first-project`
3. "Description" 是可选的，写一句简单描述即可
4. 选择 **Public**（公开）或 **Private**（私有）。初学者建议选 Public
5. 其他的选项（README、.gitignore、license）**都不要勾选**——我们要一个完全空白的仓库，这样才能顺利地把本地仓库推上去
6. 点击绿色按钮 **Create repository**

创建完成后，GitHub 会显示一个"空仓库指引"页面。你会看到三个选项：
- "…or create a new repository on the command line"
- "…or push an existing repository from the command line"  ← 我们要用的是这个
- "…or import code from another repository"

## 第二步：拿到仓库的 SSH 地址

在刚才创建的空仓库页面上，有一个 "Quick setup" 区域，里面有一个地址框。点击 **SSH** 按钮（不要选 HTTPS），你会看到类似这样的地址：

```
git@github.com:你的用户名/my-first-project.git
```

复制这个地址。这就是你的"房子地址"——Git 通过这个地址找到你 GitHub 上的仓库。

## 第三步：本地准备

现在切换到本地。假设你本地已经有了一个 Git 仓库（哪怕是上一章创建的练习仓库也行）。打开 Git Bash，进入这个仓库的目录。

```bash
cd ~/我的项目路径
```

如果你还没有本地仓库，先快速创建一个：

```bash
mkdir ~/my-first-project
cd ~/my-first-project
git init
echo "# 我的第一个项目" > README.md
git add README.md
git commit -m "第一个提交"
```

## 第四步：把本地仓库和远程仓库"配对"

这一步就是告诉 Git："以后 push 的时候，把代码发到这个地址去"。

```bash
# git remote add <别名> <远程地址>
git remote add origin git@github.com:你的用户名/my-first-project.git
```

逐词解释：
- **`git remote`**：管理远程仓库相关的设置
- **`add`**：添加一个新的远程地址
- **`origin`**：给这个远程地址起一个"小名"。`origin` 是 Git 社区约定俗成的默认名字，意思是"源头"——你的本地仓库就是从那里来的，也应该推送到那里去。你可以叫它 `github` 甚至 `zhangsan`，但大家都用 `origin`，你也跟着用就好
- **最后的 SSH 地址**：就是你刚复制的那一串

### 检查是否配对成功

```bash
# 查看已配置的远程仓库
git remote -v
```

输出应该是：

```
origin  git@github.com:你的用户名/my-first-project.git (fetch)
origin  git@github.com:你的用户名/my-first-project.git (push)
```

`fetch` 表示你从这里**下载**代码的地址，`push` 表示你向这里**上传**代码的地址。通常这两个地址是一样的。

## 第五步：推送！

```bash
# git push -u <远程别名> <分支名>
git push -u origin main
```

逐词解释：
- **`git push`**：把本地代码推送到远程仓库
- **`-u`**：`--set-upstream` 的缩写。它的作用是"建立追踪关系"——告诉 Git："以后在这个分支上，我每次说 `git push`，默认就是推到 `origin` 的 `main` 分支，不用再重复指定"。这样配置完之后，下次推送只需要 `git push` 三个字
- **`origin`**：目标远程仓库的别名（就是刚才 `git remote add` 起的那个名字）
- **`main`**：要推送的本地分支名。你的默认分支可能是 `main` 也可能是 `master`，取决于 Git 版本和配置

### 预期输出

```
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Writing objects: 100% (3/3), 241 bytes | 241.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
To github.com:你的用户名/my-first-project.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

关键信息：
- `Writing objects`：正在上传数据
- `main -> main`：本地的 main 分支推到了远程的 main 分支
- `set up to track`：追踪关系建立成功

## 第六步：去 GitHub 网页上验证

刷新刚才那个 GitHub 仓库页面，你会看到：
- 刚才还是空的页面现在有了你的文件
- `README.md` 的内容显示在页面下方
- 仓库顶部显示着分支名 `main` 和提交次数

恭喜！你的代码已经成功"上云"了。

## 未雨绸缪：如果你的默认分支名是 master

Git 的新版本默认分支名是 `main`，旧版本可能是 `master`。不确定的话，用下面命令查看：

```bash
git branch
```

输出中前面带星号 `*` 的就是当前分支名。如果是 `master`，推送命令就改成：

```bash
git push -u origin master
```

你也可以选择把本地分支重命名为 `main`（与时俱进）：

```bash
git branch -M main
```

## 之后每次推送

因为用了 `-u` 建立了追踪关系，之后你每次修改代码后只需要：

```bash
git add .
git commit -m "做了某某修改"
git push        # 不再需要指定 origin 和分支名！
```

简单到只需要敲 8 个字母。

## 类比总结

| 搬家步骤 | Git 操作 |
|----------|----------|
| 租空房子 | 在 GitHub 网页上 Create new repository |
| 拿到新房子地址 | 复制仓库的 SSH 地址 |
| 告诉搬家公司目的地 | `git remote add origin <地址>` |
| 家具打包 | `git add` + `git commit` |
| 货车运过去 | `git push` |
| 以后添家具 | 改代码 → add → commit → push |

## 动手试试

1. 在 GitHub 上创建一个全新的空仓库（不要勾选 README 等任何选项）
2. 在本地创建一个新目录，用 `git init` 初始化，添加一两个文件并提交
3. 用 `git remote add origin` 把本地仓库和 GitHub 仓库配对
4. 用 `git push -u origin main` 推送上去
5. 去 GitHub 网页刷新，确认文件出现了
6. 修改一个文件，再次 add / commit / push（第二次推送只需要 `git push`）
7. 刷新 GitHub 页面，确认修改出现了

## 本节小结

`git remote add origin <地址>` 就像把新家地址告诉搬家公司，`git push` 就是把家具运过去。配好之后，以后每次推送只需要 `git push` 三个字。

## 下一节预告

代码上了云端，但项目不只是代码。别人怎么给你提建议？你怎么管理要做的事情？接下来我们学习 GitHub 的"便签系统"——Issues。
