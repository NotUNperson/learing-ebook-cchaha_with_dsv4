# 05 Fork 工作流深入

## 本节你会学到什么

- 理解 Fork 和 Clone 的根本区别
- 知道什么时候该用 Fork
- 掌握"上游仓库（upstream）"的概念
- 学会保持 Fork 后的仓库与原仓库同步
- 走通 Fork → Clone → 修改 → 提 PR 的完整流程

## 一个生活类比：复印别人的菜谱书

假设你的朋友小明有一本很棒的菜谱书。你有两种方式获得这本书的内容：

**方式一：Clone（借回家抄一遍）**
- 你去小明家，把整本书复印了一份带回家
- 你在自己的复印件上涂涂改改：加批注、改配方、贴便签
- 但这些修改只存在于你的复印件上，小明的原书完全不受影响
- 如果小明在原书上更新了内容（比如修改了红烧肉的配方），你的复印件不会自动同步——除非你再去他家复印一次

**方式二：Fork（在云盘里复制一个独立版本）**
- 小明把菜谱书放在了某个共享云盘上
- 你在云盘上点了一个"复制到我的云盘"按钮
- 现在你的云盘里有了这本书的独立副本——你可以在上面随便改
- 更妙的是，这个副本和原书之间**保持着一种"血缘关系"**——云盘知道你的版本是从小明的书复制过来的
- 如果小明改了原书，云盘可以告诉你"原书更新了，要不要同步？"
- 如果你觉得自己的修改很好（比如发现了更好的红烧肉配方），你可以向小明发起一个"合并请求"（Pull Request），说："小明，看我的改良配方，要不要收到原书里？"

**Clone 只是下载，Fork 是"建立血缘关系的复制"。**

## Clone 和 Fork 的根本区别

| | Clone | Fork |
|------|-------|------|
| **操作位置** | 在终端里执行 `git clone` | 在 GitHub 网页上点击 Fork 按钮 |
| **结果** | 代码下载到你的电脑 | GitHub 上你的账户下多了一个仓库副本 |
| **和原仓库的关系** | 没有固定的关联（你可以设，但默认没有） | 保持着"forked from 原仓库"的关系 |
| **你能做什么** | 本地修改，但不能直接推回原仓库（没权限） | 在你的副本里随便改，可以通过 PR 向原仓库贡献 |
| **典型场景** | 下载自己的或团队的项目来开发 | 参与别人的开源项目 |

## 什么时候用 Fork

Fork 主要用于两种场景：

### 场景一：参与开源项目

你发现一个开源项目有 Bug，想帮忙修复。但你不是那个项目的成员，没有直接推送的权限。这时候：

1. Fork 那个项目 → 你账户下出现了一个副本
2. Clone 你的副本到本地 → 在本地修改
3. Push 回你的副本 → 你有权限（因为这是你的仓库）
4. 从你的副本向原仓库发起 Pull Request → 请求原作者合并你的改动

### 场景二：以别人的项目为基础开发自己的东西

你喜欢某个开源项目，但想改造成自己想要的样子。Fork 一份，在此基础上开发。以后如果原项目有好的更新，你还可以同步过来。

## 上游仓库（Upstream）是什么

### 类比：河流的分叉

一条河流从源头流下来，中间分出一条支流。这条支流是从主流分出来的——主流就是支流的"上游"。

在 Fork 工作流中：
- **上游仓库（Upstream）**：原作者的仓库，也就是你 Fork 的那个仓库
- **下游仓库（Origin）**：你 Fork 后得到的副本，属于你的账户

通常约定，在本地 clone 仓库后，用两个 remote 名称来区分：
- `origin`：指向你的 Fork 副本（你有推送权限）
- `upstream`：指向原作者的仓库（你只有拉取权限）

### 为什么需要 upstream？

因为你的 Fork 副本**不会自动同步原仓库的更新**。如果原仓库在你 Fork 之后又增加了很多新功能，你的副本不会自动获得这些内容。你需要手动从 upstream 拉取更新并合并——这个过程叫"同步上游"。

## 完整 Fork 工作流一步步操作

假设你想参与一个开源项目。一步步来：

### 第一步：在 GitHub 网页上 Fork

1. 打开你想参与的项目仓库页面
2. 点击右上角的 **Fork** 按钮
3. 在弹出的对话框中，选择目标账户（你自己的账户）
4. 等待 GitHub 复制完成（通常几秒钟）

完成后，浏览器会自动跳转到你账户下的 Fork 副本页面。注意看仓库名下面有一行小字：`forked from 原作者/原仓库名`——这就是"血缘关系"的证明。

### 第二步：Clone 到本地

```bash
# 使用 Fork 副本的 SSH 地址 clone（因为这是你的仓库，你有权限）
git clone git@github.com:你的用户名/仓库名.git
cd 仓库名
```

### 第三步：添加上游仓库

```bash
# 把原作者的仓库添加为 upstream
git remote add upstream git@github.com:原作者/原仓库名.git
```

验证一下：

```bash
git remote -v
```

应该看到四个地址：

```
origin    git@github.com:你的用户名/仓库名.git (fetch)
origin    git@github.com:你的用户名/仓库名.git (push)
upstream  git@github.com:原作者/原仓库名.git (fetch)
upstream  git@github.com:原作者/原仓库名.git (push)
```

### 第四步：创建分支，写代码

```bash
# 永远不要在 main 分支上直接改别人的代码
# 为你的修改单独创建一个分支
git checkout -b fix-typo-in-readme
```

在分支上修改代码，然后提交：

```bash
# 修改文件...
git add .
git commit -m "修复 README 中的拼写错误"
```

### 第五步：推送你的分支到 Fork 副本

```bash
# 推送到 origin（你的 Fork 副本），不是 upstream（原仓库）
git push -u origin fix-typo-in-readme
```

### 第六步：创建 Pull Request

1. 打开你 GitHub 上的 Fork 副本页面
2. 你会看到一条黄色提示条："fix-typo-in-readme had recent pushes..."
3. 点击 **Compare & pull request** 按钮
4. 填写 PR 标题和描述，解释你做了什么、为什么要做
5. 点击 **Create pull request**

你的 PR 就提交给原作者了。原作者可以查看、评论、要求修改、或者合并。

## 保持 Fork 副本与原仓库同步

原作者可能在你 Fork 之后又合并了很多更新。你需要定期同步上游的改动到你的 Fork 副本：

```bash
# 步骤1：拉取原仓库的最新代码（不会影响你的工作区）
git fetch upstream

# 步骤2：切换到本地 main 分支
git checkout main

# 步骤3：把 upstream/main 合并到本地的 main
git merge upstream/main

# 步骤4：把同步后的 main 推到你的 Fork 副本
git push origin main
```

如果合并过程中有冲突（你改了同一个地方），Git 会提示你手动解决冲突。解决后 `git add` + `git commit` 即可。

### 同步到功能分支

如果你正在一个功能分支上开发，同步的流程稍微不同：

```bash
# 方法一：先把 main 更新，再把 main 合并到功能分支
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

git checkout 你的功能分支
git merge main            # 把更新后的 main 合并到功能分支

# 方法二：直接在功能分支上 rebase
git fetch upstream
git rebase upstream/main  # 把你功能分支的提交"搬到"更新后的 main 上
```

对初学者来说，先用方法一（merge），更直观易懂。

## Fork 工作流的完整图解

```
原作者仓库 (原书)              你的 Fork 副本 (云盘副本)         你的本地 (书房)
┌─────────────┐              ┌─────────────┐              ┌─────────────┐
│             │   Fork      │             │   Clone      │             │
│  上游仓库   │ ─────────→  │   origin    │ ─────────→  │   本地仓库   │
│ (upstream)  │             │  (你的副本)  │             │             │
│             │  ←───────  │             │  ←───────  │             │
│             │  Pull Req  │             │    Push    │             │
└─────────────┘              └─────────────┘              └─────────────┘
       ↑                                                    │
       │                                                    │
       └────── fetch upstream / merge ─────────────────────┘
              (定期从原仓库同步更新)
```

## 动手试试

1. 找一个简单的开源仓库（可以是朋友的、或者 GitHub 上搜索 "good first issue" 找到的）
2. Fork 这个仓库到你自己的 GitHub 账户下
3. Clone 你的 Fork 副本到本地
4. 运行 `git remote add upstream` 添加原仓库为上游
5. 用 `git remote -v` 确认有两个远程地址
6. 在本地创建一个新分支，做一些简单修改（比如修改 README 中的一个词）
7. Push 这个分支到你的 Fork 副本
8. 在 GitHub 网页上创建一个 Pull Request（如果原作者允许的话；练习时最好用你朋友或你自己另一个账号的仓库，避免打扰陌生开发者）

## 本节小结

Fork 是 GitHub 上的"血缘复制"——你在自己的账户下创建一个独立副本，和原仓库保持关联。用 upstream 跟上原仓库的更新，用 Pull Request 把你的贡献推回给原作者。

## 下一节预告

一个项目只放在一个平台够不够？GitHub 虽然好，但国内的 Gitee 访问更快。能不能一个仓库同时推送到多个平台？下节揭晓。
