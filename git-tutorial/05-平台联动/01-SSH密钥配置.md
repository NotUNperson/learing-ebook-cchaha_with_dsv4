# 01 SSH 密钥配置

## 本节你会学到什么

- 理解什么是 SSH Key 以及它为什么比密码更安全
- 区分 HTTPS 和 SSH 两种连接方式，知道各自的优缺点
- 在 Windows 上生成自己的 SSH 密钥对
- 把公钥上传到 GitHub 和 Gitee
- 验证连接是否配置成功

## 为什么要学 SSH

在前面的章节里，我们用 `git clone` 下载过别人的仓库，也用 `git push` 推送过自己的代码。但你有没有想过一个问题：**GitHub 怎么知道是你本人在操作？**

如果不做任何配置，每次 `git push` 都要输入用户名和密码。这不仅麻烦，而且密码在网络上传送还存在风险。更麻烦的是，2021 年 8 月起，GitHub 已经禁止了直接用密码进行 Git 操作——你必须用更安全的方式。

这个"更安全的方式"就是 SSH。

## 什么是 SSH Key

### 类比：你家门的钥匙

想象你家有一扇防盗门。这扇门有两把钥匙：

- **一把是"公钥"**：你把它交给快递员、邻居、物业。他们可以用这把钥匙把一个箱子锁上，但打不开。这把钥匙本身不值钱，丢了也没关系。
- **一把是"私钥"**：你自己装在兜里，绝不外传。只有这把钥匙能打开上面那把公钥锁上的箱子。

SSH 密钥对就是这样一个机制：

- **私钥（Private Key）**：存放在你的电脑上，绝对不能泄露。它是你身份的唯一证明。
- **公钥（Public Key）**：你把它上传到 GitHub/Gitee 的服务器上。它是公开的，谁看都没关系。

当你执行 `git push` 时：
1. GitHub 用你的公钥加密一个"挑战"发送给你
2. 你的电脑用私钥解密这个"挑战"并回应
3. GitHub 验证回应正确，确认你就是你——连接建立

整个过程不需要传输密码，而且即使有人截获了通信内容，没有私钥也解不开。

### 另一个类比：银行的手写签名

你去银行办业务，柜员会对照你在银行预留的签名（公钥）和你当场写的签名（私钥签名）是否一致。SSH 的原理类似——服务器上有你的"签名样本"（公钥），你每次连接时"当场签名"证明身份。

## HTTPS vs SSH：两种连接方式

当你 `git clone` 一个仓库时，有两种地址可以选：

| 特性 | HTTPS | SSH |
|------|-------|-----|
| 地址格式 | `https://github.com/用户名/仓库.git` | `git@github.com:用户名/仓库.git` |
| 首次配置 | 不需要配置，直接用 | 需要生成密钥并上传公钥 |
| 每次推送 | 需要输入账号密码（或用凭证管理器记住） | 无需输入，自动验证 |
| 安全性 | 依赖 GitHub 账号密码 | 依赖密钥对，更安全 |
| 推荐场景 | 临时下载别人的代码看一看 | 自己开发项目，频繁推送 |

简单来说：**临时看看用 HTTPS，长期开发用 SSH**。

## 在 Windows 上生成 SSH 密钥

### 第一步：打开 Git Bash

我们已经安装过 Git，Git 自带了一个叫 Git Bash 的终端。点击 Windows 开始菜单，搜索 "Git Bash" 并打开。

> 注意：下面这些命令要在 Git Bash 里运行，不要用 Windows 的 CMD 或 PowerShell，因为 `ssh-keygen` 命令在 Git Bash 里才最好用。

### 第二步：生成密钥对

```bash
# 生成一份新的 SSH 密钥对
# -t ed25519：使用 Ed25519 算法（现代、安全、快速）
# -C 后面跟你的邮箱，作为备注标签
ssh-keygen -t ed25519 -C "your_email@example.com"
```

执行后会出现三个问题，**全部直接按回车**（使用默认设置）：

```
Generating public/private ed25519 key pair.
Enter file in which to save the key (/c/Users/你的用户名/.ssh/id_ed25519):
    → 直接回车，使用默认路径
Enter passphrase (empty for no passphrase):
    → 直接回车，不设密码（初学者推荐）
Enter same passphrase again:
    → 再次回车确认
```

> 关于 passphrase：它是在私钥上再加一层密码保护。设了之后，每次用这个私钥都要输入这个密码。对初学者来说，先用空密码上手更快。正式工作中的重要项目建议设置。

### 第三步：查看生成的密钥

```bash
# 进入 .ssh 目录
cd ~/.ssh

# 看看里面有什么
ls -la
```

你会看到两个文件：
- `id_ed25519` —— 这是私钥，**保护好它，不要发给任何人**
- `id_ed25519.pub` —— 这是公钥，可以放心分享

```bash
# 查看公钥内容（待会要复制到 GitHub）
cat ~/.ssh/id_ed25519.pub
```

输出的内容大概长这样（一串以 `ssh-ed25519` 开头、以你的邮箱结尾的字符）：

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your_email@example.com
```

### 如果你的系统不支持 Ed25519

某些非常老的系统可能不支持 Ed25519，这时候可以用 RSA 算法（同样安全）：

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

## 把公钥添加到 GitHub

### 第一步：复制公钥

在 Git Bash 中运行下面命令，公钥内容会自动复制到剪贴板：

```bash
# Windows Git Bash 专用
cat ~/.ssh/id_ed25519.pub | clip
```

如果是其他终端，可以用 `cat` 命令手动复制输出内容。

### 第二步：在 GitHub 网页上操作

1. 打开浏览器，登录 [GitHub](https://github.com)
2. 点击右上角你的头像，选择 **Settings（设置）**
3. 在左侧菜单中点击 **SSH and GPG keys**
4. 点击绿色按钮 **New SSH key**
5. 在 "Title" 栏填一个名字，如 "我的Windows电脑"（方便以后辨认是哪台机器的密钥）
6. 在 "Key" 栏粘贴刚才复制的公钥（按 Ctrl+V）
7. 点击 **Add SSH key**
8. GitHub 会让你输入一次密码以确认身份

### 把公钥添加到 Gitee（码云）

Gitee 的操作流程几乎一样：

1. 登录 [Gitee](https://gitee.com)
2. 点击右上角头像 → **设置**
3. 左侧菜单 → **SSH 公钥**
4. 粘贴公钥 → 起个名字 → 确定

## 验证连接是否成功

配置完成后，运行下面命令测试连接：

```bash
# 测试 GitHub 连接
ssh -T git@github.com

# 测试 Gitee 连接
ssh -T git@gitee.com
```

如果配置成功，你会看到类似的输出：

```
# GitHub 的成功信息
Hi 你的用户名! You've successfully authenticated, but GitHub does not provide shell access.

# Gitee 的成功信息
Hi 你的用户名! You've successfully authenticated, but Gitee.com does not provide shell access.
```

看到 "successfully authenticated" 就说明一切配置正确了！

> 注意：首次连接时系统会问 "Are you sure you want to continue connecting (yes/no)?"，输入 `yes` 并回车即可。这个提示只会出现一次。

## 常见问题处理

### "Permission denied (publickey)" 怎么办？

这个错误说明 GitHub 没有认出你的密钥。按顺序排查：

1. **公钥确实上传了吗？** 去 GitHub Settings → SSH keys 检查，确认列表里有你刚才添加的密钥。
2. **SSH agent 有没有运行？** 在 Git Bash 中运行：
   ```bash
   # 启动 ssh-agent
   eval $(ssh-agent -s)
   # 添加私钥
   ssh-add ~/.ssh/id_ed25519
   ```
3. **是不是用了多个 GitHub 账号？** 这是进阶话题，初学者通常不会遇到。如果确实需要，可以搜索 "GitHub multiple SSH keys"。

### 每次重启电脑都要重新 ssh-add？

是的，如果你设了 passphrase 或者遇到了这个问题。一个简单的解决办法是让 Git Bash 启动时自动加载密钥。在 `~/.bashrc` 文件末尾添加：

```bash
eval $(ssh-agent -s) 2>/dev/null
ssh-add ~/.ssh/id_ed25519 2>/dev/null
```

如果 `~/.bashrc` 文件不存在，创建一个即可。

## 动手试试

1. 按照上面的步骤，生成你自己的 SSH 密钥对
2. 把公钥添加到 GitHub
3. 用 `ssh -T git@github.com` 验证连接
4. 如果有 Gitee 账号，也把公钥添加到 Gitee 并验证
5. 完成后，试着用 SSH 地址（格式为 `git@github.com:用户名/仓库.git`）clone 你自己的一个仓库

整个过程应该在 5 分钟内完成。

## 本节小结

SSH 密钥就像你家的门钥匙——公钥给 GitHub 留底，私钥自己保管。配置一次之后，以后所有 `git push` 和 `git pull` 都不需要再输密码。

## 下一节预告

密钥配好了，接下来我们要真正地把本地代码"推上云端"——在 GitHub 上创建仓库，然后用 `git push` 把本地项目发上去。
