# 02 .gitignore 和配置文件

## 本节你会学到什么

- 用"门禁名单"的类比理解 .gitignore 的作用
- 学会编写 .gitignore 文件，控制哪些文件不被 Git 跟踪
- 掌握几种最常用的忽略规则（文件夹、后缀名、特殊文件）
- 了解全局 gitignore 的用法——一次配置，所有仓库生效
- 知道哪些类型的文件"永远不该提交"以及为什么

---

## 正文

### 一个你迟早会遇到的尴尬场景

假设你正在开发一个网站项目，文件夹里大概有这些东西：

```
my-project/
  ├── index.html        # 项目代码
  ├── style.css         # 项目代码
  ├── node_modules/     # 第三方依赖包（3 万个文件，500MB）
  ├── .env              # 数据库密码等敏感信息
  ├── secret-key.txt    # API 密钥
  └── dist/             # 编译产物（自动生成的）
```

某天你写完代码，心血来潮敲了一句：

```bash
git add .
git commit -m "完成登录功能"
git push
```

结果你发现：
- GitHub 上传了 500MB 的 `node_modules`，仓库爆了
- 你的数据库密码出现在公开仓库里，全世界都看得见
- 自动生成的编译文件也被提交了，其他人拉下来就跟你冲突

这就是没有配置 `.gitignore` 的后果。

### .gitignore 是什么？

**.gitignore 是一份"不用跟踪的文件清单"。** 你在这份清单里写上哪些文件或文件夹 Git 应该假装看不见。Git 在执行 `git add .` 的时候会先读这份清单，清单上有的就跳过。

**类比：** 就像你去超市买东西，在门口拿了一张"今天不用买"的清单。你逛超市的时候，清单上的东西就算看到了也不会往购物车里放。`.gitignore` 就是这样——它告诉 Git："这些东西请你假装没看见，别往仓库里放。"

再换一个类比：**.gitignore 就像夜店门口的门禁名单。** 名单上的人（或文件特征）统统不得入内。别的所有人正常进入（被 git add 追踪）。

### 创建一个 .gitignore 文件

在你的项目根目录下创建一个文件，名字就叫 `.gitignore`（注意开头有一个点，没有后缀名）：

```bash
# 创建 .gitignore 文件
touch .gitignore
```

然后往里面写规则。每行一条规则，比如：

```gitignore
# 忽略 node_modules 整个目录
node_modules/

# 忽略所有 .log 后缀的日志文件
*.log

# 忽略所有 .env 文件（通常存着密码等敏感信息）
.env

# 忽略 dist 编译产物目录
dist/

# 忽略操作系统自动生成的文件
.DS_Store
Thumbs.db
```

### 常用忽略规则速查表

| 写法 | 含义 | 举例 |
|------|------|------|
| `*.log` | 忽略所有 .log 结尾的文件 | `error.log`、`debug.log` |
| `node_modules/` | 忽略整个 node_modules 目录 | `node_modules/` 里的任何内容 |
| `dist/` | 忽略构建输出目录 | `dist/app.js`、`dist/style.css` |
| `.env` | 忽略特定文件 | 项目根目录的 `.env` |
| `**/temp/` | 忽略任意层级下的 temp 目录 | `a/temp/`、`a/b/temp/` |
| `!important.log` | 取反：不忽略这个文件 | 在 `*.log` 规则下依然跟踪它 |

注意：
- `/` 结尾表示这是一个目录
- `*` 是通配符，匹配任意字符
- `#` 开头是注释，不会生效
- `!` 开头表示取反——"除了这个"

### 什么时候创建 .gitignore？

**最佳时机：项目创建的第一时间，在你第一次 `git add .` 之前。**

为什么？因为 `.gitignore` 只对"还没被跟踪的文件"生效。如果某个文件**已经被 Git 跟踪了**，你再把它写进 `.gitignore` 是没用的——Git 会说："我已经认识它了，不能假装不认识。"

如果你已经不小心提交了不该提交的文件，补救方法是：

```bash
# 1. 先从 Git 的跟踪中移除（但不删除文件本身）
git rm --cached 文件名

# 2. 把文件名加入 .gitignore
echo "文件名" >> .gitignore

# 3. 提交这次改动
git add .gitignore
git commit -m "chore: 从版本控制中移除敏感文件，添加到 gitignore"
```

### 哪些文件"永远不该提交"？

分类来说，以下几类文件不要放进 Git：

**第一类：密码和密钥**
- `.env`、`secrets.json`、`private-key.pem`
- 任何包含数据库密码、API 密钥、服务器地址的文件
- 原因：Git 的历史记录是"永远可查"的。你删掉了文件，但历史里还有。骇客翻你的 git log 就能找到密码。

**第二类：自动生成的依赖包**
- `node_modules/`（JavaScript）、`vendor/`（PHP）、`venv/`（Python 虚拟环境）
- 原因：这些文件体积巨大，而且别人可以通过 `npm install` 等命令重新下载，不需要你上传。

**第三类：编译产物**
- `dist/`、`build/`、`*.exe`、`*.class`
- 原因：编译产物可以由源代码随时重新生成，提交到仓库里既占地方又容易产生冲突。

**第四类：操作系统垃圾文件**
- `.DS_Store`（macOS）、`Thumbs.db`（Windows）
- 原因：这些是操作系统自动生成的，跟项目无关。

**第五类：IDE 和个人配置文件**
- `.vscode/`、`.idea/`（如果你用 JetBrains 系列）、`*.swp`（Vim 临时文件）
- 原因：每个人的编辑器配置不同，提交上去会引起不必要的冲突。

### 全局 .gitignore：一劳永逸

有些文件你希望**在所有仓库里都忽略一次**，不用每个项目都写一遍。比如 `.DS_Store`、`Thumbs.db`、以及你自己编辑器生成的临时文件。

这时可以配置一个"全局 .gitignore"：

```bash
# 第一步：在你的用户目录下创建一个全局 gitignore 文件
touch ~/.gitignore_global

# 第二步：往里面写规则
echo ".DS_Store" >> ~/.gitignore_global
echo "Thumbs.db" >> ~/.gitignore_global
echo "*.swp" >> ~/.gitignore_global

# 第三步：告诉 Git 使用这个文件
git config --global core.excludesfile ~/.gitignore_global
```

配置完成后，你电脑上的**所有** Git 仓库都会自动应用这些规则。这叫"一次配置，终身受用"。

**类比：** 项目里的 `.gitignore` 是"这个房间的规则"（比如厨房不准放鞋），全局 `.gitignore` 是"整栋楼的通用规则"（比如整栋楼不准吸烟）。

### .gitignore 不生效怎么办？

这是一个很常见的问题。通常的原因是：你想忽略的文件**已经被 Git 跟踪了**。解决办法上面提到了——用 `git rm --cached` 先解除跟踪。

你可以用这个命令验证 `.gitignore` 是否对某个文件生效：

```bash
git check-ignore -v 文件名
```

如果没输出，说明该文件不在忽略列表中。

---

## 动手试试

1. 找一个你之前练习用的 Git 仓库（或者新建一个）
2. 在仓库里创建一个 `.gitignore` 文件
3. 写入规则：忽略所有 `.log` 后缀的文件
4. 创建一个 `test.log` 文件，里面随便写点东西
5. 执行 `git status` —— 你会发现 `test.log` 没有出现在未跟踪文件列表中
6. 执行 `git check-ignore -v test.log` —— 确认是 `.gitignore` 中的哪条规则生效了
7. 试着在 `.gitignore` 中加一条 `!important.log`，再创建 `important.log` 看看它是否被忽略

---

## 本节小结

`.gitignore` 就像门禁名单，列出"不欢迎进入仓库"的文件。项目创建第一时间就该配好它，帮你避免密码泄露、仓库臃肿和无意义的冲突。

---

## 下一节预告

`.gitignore` 帮你避免了一半的问题，但另一半问题还是要靠你自己——比如忘记 add 就 commit、push 被拒绝、合并冲突心慌意乱。下一节我们专门讲**常见问题的排查和补救**，让你遇事不慌。
