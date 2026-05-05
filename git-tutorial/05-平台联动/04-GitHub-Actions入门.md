# 04 GitHub Actions 入门

## 本节你会学到什么

- 理解 CI/CD 是什么以及它解决了什么问题
- 看懂一个 GitHub Actions 工作流文件的结构
- 创建自己的第一个 Actions 工作流（每次 push 自动运行）
- 在 GitHub 网页上查看 Actions 运行结果

## 一个生活类比：汽车工厂的质检流水线

想象一家汽车工厂。以前的做法是：工人造完一辆车，再找个老师傅从头到尾检查一遍。这样做有两个问题：

1. **发现太晚**：等老师傅查出问题时，可能已经造了 50 辆有同样问题的车
2. **全靠人工**：老师傅请假了，质检就停摆

现代化的汽车工厂不这样——**流水线上每经过一个工位，机器自动检查一项**：
- 第一个工位：检查螺丝有没有拧紧
- 第二个工位：检查车漆是否均匀
- 第三个工位：检查电路是否正常
- ...

车子一边造，机器一边检查。发现问题立刻报警，整条线停下来修。

**GitHub Actions 就是代码世界的"自动质检流水线"。** 你只管写代码，机器自动帮你做检查、测试、打包这些重复性工作。

## 什么是 CI/CD

你可能会听到 CI/CD 这个词，它分成两部分：

- **CI（Continuous Integration，持续集成）**：持续集成，白话就是"每当你上交代码，机器自动跑一遍检查，确保新代码没有把原来的功能搞坏"。类比：每次有人往图书馆还书，管理员自动检查有没有缺页、涂改。

- **CD（Continuous Delivery / Deployment，持续交付/部署）**：持续交付/部署，白话就是"检查通过后，机器自动把你的代码部署到服务器上，让用户能用上最新版本"。类比：出版社审核完书稿后，自动送去印刷厂印刷。

对于初学者来说，先掌握 CI 这一半就够了——让机器帮你自动检查代码。

## Actions 的核心概念

一个 GitHub Actions 工作流由以下部分构成，我用一场"考试"来类比：

| Actions 概念 | 含义 | 类比：一场考试 |
|-------------|------|---------------|
| **Workflow（工作流）** | 整个自动化流程 | 一场完整的考试 |
| **Event（触发事件）** | 什么情况下启动这个流程 | "老师说：开始考试" |
| **Job（任务）** | 一个大任务，可以包含多个步骤 | "做一张试卷" |
| **Step（步骤）** | 任务中的具体步骤 | "先做选择题，再做填空题" |
| **Action（动作）** | 别人写好的轮子，拿来就用 | "用计算器算数学题" |
| **Runner（运行器）** | 执行任务的虚拟机 | "考试用的课桌" |

这个类比你心里有个印象就好，接下来我们看实际的文件怎么说。

## 你的第一个 Actions 工作流

Actions 的配置文件放在仓库的 `.github/workflows/` 目录下，文件格式是 YAML（`.yml`）。

你现在不需要完全理解 YAML 语法，只要知道它是用缩进来表示层级关系的（像 Python 一样，靠空格对齐）。

### 创建配置文件

在你的仓库根目录下创建以下路径和文件：

```
.github/
  workflows/
    hello.yml
```

`hello.yml` 的内容如下：

```yaml
# 工作流的名字，会显示在 GitHub Actions 页面上
name: Hello Actions

# 触发条件：什么时候自动运行这个工作流
# on: push 表示：每次 push 代码到仓库，就自动运行
on:
  push:
    branches:
      - main        # 只监听 main 分支的 push

# jobs 下面定义要执行的任务
jobs:
  # 任务的名字，可以随便起（这里叫 say-hello）
  say-hello:
    # 运行环境：在 GitHub 提供的 Ubuntu 虚拟机上运行
    runs-on: ubuntu-latest

    # steps 下面列出这个任务要做的每一步
    steps:
      # 第一步：把仓库的代码"搬"到虚拟机上
      # uses 表示使用别人写好的 action
      - name: 签出代码
        uses: actions/checkout@v4

      # 第二步：打印一句话
      - name: 打个招呼
        run: echo "Hello, GitHub Actions! 我的第一次自动运行成功了！"

      # 第三步：查看当前目录有哪些文件
      - name: 看看有什么文件
        run: ls -la
```

逐段解释：

- **`name`**：工作流的显示名称，你可以随便起
- **`on: push: branches: - main`**：当有人 push 代码到 `main` 分支时，自动触发。你也可以改成每次 push 任何分支都触发（去掉 `branches`），或者改成有人创建 Pull Request 时触发（`on: pull_request`）
- **`jobs: say-hello`**：这个工作流里只有一个任务，叫 `say-hello`
- **`runs-on: ubuntu-latest`**：GitHub 会免费提供一台装有 Ubuntu 系统的虚拟机来运行你的任务
- **`steps`**：下面是三个具体步骤
- **`uses: actions/checkout@v4`**：这是 GitHub 官方提供的 action，作用是"把你的代码下载到虚拟机上"，几乎所有工作流的第一步都是这个
- **`run: echo "..."`**：直接在虚拟机的终端里执行一条命令

### 提交并推到 GitHub

```bash
mkdir -p .github/workflows
# 用编辑器创建 hello.yml（内容见上）
git add .github/workflows/hello.yml
git commit -m "添加第一个 GitHub Actions 工作流"
git push
```

### 查看运行结果

1. 打开你的 GitHub 仓库页面
2. 点击顶部的 **Actions** 标签页
3. 你会看到你的工作流正在运行（或者已经完成）
4. 点击这次运行记录，再点击 `say-hello` 任务
5. 展开每个步骤，查看输出结果

如果看到绿色的勾和 "Hello, GitHub Actions!" 的打印输出，恭喜，你的第一条自动流水线跑通了！

## 一个稍微有用的例子：自动运行测试

前面的 `hello.yml` 只是打个招呼。现在来看一个更实际的例子——每次 push 代码后自动运行项目的测试。

假设你的项目是一个 Node.js 项目（JavaScript），有一个简单的测试：

```yaml
name: 自动测试

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]    # 有人提 PR 时也跑一遍

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: 签出代码
        uses: actions/checkout@v4

      - name: 安装 Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20    # 指定 Node.js 版本

      - name: 安装依赖
        run: npm install

      - name: 运行测试
        run: npm test
```

这个工作流的"工厂流水线"是这样的：
1. 签出代码（把代码搬到虚拟机）
2. 安装 Node.js（给虚拟机装上运行环境）
3. `npm install`（安装项目的依赖包）
4. `npm test`（运行测试）

整个流程完全自动——你只管 `git push`，剩下的 GitHub 帮你做。如果测试失败，GitHub 会发邮件通知你。

## 工作流的触发条件

除了 `push`，你还可以用很多其他事件来触发工作流：

```yaml
# 每次 push 到 main 分支时触发
on:
  push:
    branches: [main]

# 有人创建 Pull Request 时触发
on:
  pull_request:
    branches: [main]

# 定时触发（每天北京时间早上8点自动跑）
on:
  schedule:
    - cron: '0 0 * * *'    # 这是 UTC 时间，需要换算

# 手动触发（在 GitHub 网页上点击按钮运行）
on:
  workflow_dispatch

# 多个事件一起触发
on: [push, pull_request]
```

## Actions 的市场（Marketplace）

GitHub 有一个 Actions 市场，里面有成千上万个别人写好的 action，你可以直接用。常用的包括：

- `actions/checkout`：签出代码（几乎必用）
- `actions/setup-node`：安装 Node.js
- `actions/setup-python`：安装 Python
- `actions/upload-artifact`：上传构建产物（如打包好的文件）
- 各种第三方 action：发微博、发邮件、部署到云服务器……

使用方式是 `uses: 作者/action名@版本号`，比如 `uses: peaceiris/actions-gh-pages@v3`。

## 常见问题

### Actions 要钱吗？

GitHub 对公开仓库的 Actions 完全免费。私有仓库每月有 2000 分钟的免费额度，对个人学习来说绰绰有余。

### Actions 运行太慢怎么办？

首次运行需要等 GitHub 分配虚拟机，可能需要 30 秒到 1 分钟。后续运行通常会快一些。对于学习来说这个速度完全够用。

### 运行失败了怎么排查？

点击 Actions 标签页 → 点击失败的运行记录 → 点击任务 → 展开每个步骤查看日志。绝大多数情况下，日志里都有清晰的错误提示。

## 动手试试

1. 在你推送到 GitHub 的仓库中创建 `.github/workflows/hello.yml`
2. 把上面的简单示例内容复制进去
3. `git add` → `git commit` → `git push`
4. 去 GitHub 仓库的 Actions 页面查看运行结果
5. 试着故意写错一个命令（比如把 `echo` 写成 `echoo`），再 push 一次，看看 Actions 怎么报告失败
6. 尝试把触发条件改成手动触发（`workflow_dispatch`），然后在 GitHub Actions 页面上手动点按钮运行

## 本节小结

GitHub Actions 就像一个自动化的工厂流水线——你只管 push 代码，机器自动帮你检查、测试。只需要在 `.github/workflows/` 下创建一个 `.yml` 文件，定义"什么时候跑"和"跑什么"，剩下的全部自动。

## 下一节预告

到目前为止，我们都在自己的仓库里折腾。但开源世界的精髓是合作——怎么给别人贡献代码？Fork 工作流来了。
