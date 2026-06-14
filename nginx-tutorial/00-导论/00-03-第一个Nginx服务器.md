# 00-03 第一个 Nginx 服务器

## 本节你会学到什么

- 掌握 Nginx 的启动、停止、重载命令
- 理解 master 进程和 worker 进程的职责分工
- 修改默认首页并验证配置是否生效
- 学会查看和分析 Nginx 日志文件

## 正文

### 启动 Nginx

安装好 Nginx 之后，启动它的最简单方式就是在命令行输入 `nginx`。没错，就一个单词。在 Linux 上因为需要 root 权限监听 80 端口，所以通常要加 `sudo`：

```bash
# Windows（在 Nginx 目录下）
nginx

# Linux
sudo nginx
```

敲完回车后，它不会输出任何东西，命令行提示符直接返回——这代表 Nginx 已经在后台默默运行了。就像你打开一盏灯，开关拨上去灯就亮了，不会弹出一个对话框说"灯已成功打开"。

如果你不确定 Nginx 是否在运行，可以用以下方式确认：

```bash
# Windows：查看进程列表
tasklist /fi "imagename eq nginx.exe"

# Linux：查看进程
ps aux | grep nginx
```

你会看到类似这样的输出（Linux 下）：

```
root      1234  0.0  0.1  45678  2048 ?  Ss  10:00  0:00 nginx: master process
www-data  1235  0.0  0.2  45900  3072 ?  S   10:00  0:00 nginx: worker process
www-data  1236  0.0  0.2  45900  3072 ?  S   10:00  0:00 nginx: worker process
```

### 理解 master 和 worker 进程

你一定会注意到，刚刚启动 Nginx，但进程列表里不止一个进程，而是一个 master 加好几个 worker。这种设计是 Nginx 高性能的基石。

用**餐厅的店长和店员**来类比：

- **master 进程（店长）**：不直接服务客人。它的工作是读取菜单（配置文件），管理人事（启动 / 关闭 worker），评估工作量。如果配置文件改了，它通知所有人按新规矩办事。
- **worker 进程（店员）**：真正干活的人。每个 worker 都能独立接待客人，而且一个 worker 可以同时处理成百上千个请求。worker 的数量通常等于 CPU 核心数——如果服务器有 4 个 CPU 核心，Nginx 默认启动 4 个 worker，让每个核心负责一个 worker，避免争抢。

你可以通过配置文件调整 worker 数量。打开 `nginx.conf`，找到这一行：

```nginx
worker_processes  auto;
```

`auto` 表示 Nginx 自动检测 CPU 核心数并启动对应数量的 worker。你也可以手动指定，比如 `worker_processes 2;` 表示只要两个 worker。

### 停止 Nginx

有三种方式让 Nginx 停下来：

```bash
# 优雅停止——等当前正在处理的请求完成后再退出
nginx -s quit

# 快速停止——立即停止所有连接
nginx -s stop

# 重载配置——不停服务，重新加载配置文件
nginx -s reload
```

用**商店打烊**来类比这三种方式：

- `quit`（优雅停止）：店门口挂个牌"即将打烊"，已经在店里的顾客继续服务完毕，但不再放新顾客进来。结束后全员下班。
- `stop`（快速停止）：直接拉闸断电，所有顾客请立刻离开，店里一片漆黑。
- `reload`（重载配置）：不停业。店长开会说"从今天开始，收银台换到左边"，现有的顾客不受影响，新的顾客按新规矩来。

`reload` 可能是你最常用的命令之一。每次你修改了配置文件（比如加了一个新域名、改了一个端口），只要执行 `nginx -s reload`，改动就生效了，访问者完全察觉不到服务器曾经"换过规矩"。

**注意：** `nginx -s` 系列命令必须由启动 Nginx 的同一个用户执行，否则 Nginx 会忽略你的信号。在 Linux 上，通常都是用 `sudo` 启动的，所以也要用 `sudo nginx -s reload`。

### 修改默认首页

Nginx 安装后自带一个默认首页，写着 "Welcome to nginx!"。我们把它改成自己的内容。

首先，找到 Nginx 的网页根目录。不同系统的路径：

- Windows：`C:\nginx\html\`
- Linux（apt 安装）：`/usr/share/nginx/html/`
- Linux（yum 安装）：`/usr/share/nginx/html/`

用文本编辑器打开这个目录下的 `index.html`，把所有内容替换成：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>我的第一个 Nginx 网站</title>
</head>
<body>
    <h1>你好，Nginx!</h1>
    <p>如果你能看到这个页面，说明 Nginx 正在正常运行。</p>
    <p>当前时间：<span id="time"></span></p>
    <script>
        document.getElementById('time').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
```

保存文件。现在刷新浏览器中的 `http://localhost`，你会看到自己写的内容出现在页面上。

注意，修改 HTML 文件不需要重载 Nginx——因为 Nginx 是直接从硬盘读取文件内容发送给浏览器的，文件改了，下次请求自然就读到新内容。只有修改了 `nginx.conf` 这类配置文件，才需要 `reload`。

### 查看日志文件

日志是了解服务器运行状况的窗口。就像大楼保安室里的监控屏幕，记录着谁进谁出、有没有异常。

**access.log（访问日志）**

打开 Nginx 的 logs 目录，查看 `access.log`。你会看到类似这样的内容：

```
127.0.0.1 - - [22/May/2026:10:30:45 +0800] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0..."
127.0.0.1 - - [22/May/2026:10:30:46 +0800] "GET /favicon.ico HTTP/1.1" 404 555 "http://localhost/" "Mozilla/5.0..."
```

每一行拆解来看：
- `127.0.0.1`：访问者的 IP 地址
- `[22/May/2026:10:30:45 +0800]`：访问时间
- `"GET / HTTP/1.1"`：请求方法、请求路径和协议
- `200`：HTTP 状态码（200 表示成功）
- `612`：返回给浏览器的内容大小（字节）
- `"Mozilla/5.0..."`：访问者的浏览器信息（User-Agent）

第二行返回了 `404`——这是浏览器在自动请求网站图标 `favicon.ico`，但我们的 HTML 目录里还没有这个文件，所以 Nginx 返回了 404 未找到。

**error.log（错误日志）**

如果 Nginx 出了问题，第一时间就应该看 `error.log`。比如你写了一个语法错误的配置然后 reload，错误信息就会记录在这里。

```bash
# Linux 下实时查看日志的命令（很有用！）
tail -f /var/log/nginx/access.log
```

`tail -f` 会让命令行持续显示日志文件的最新内容，就像开着监控画面一样。当你刷新浏览器时，你能实时看到新的日志条目冒出来。这在调试问题时特别好用。

## 动手试试

1. 启动 Nginx（如果还没启动的话），用 `ps aux | grep nginx`（Linux）或 `tasklist /fi "imagename eq nginx.exe"`（Windows）查看 master 和 worker 进程。
2. 修改默认的 `index.html`，换成你自己写的 HTML 内容，刷新浏览器验证。
3. 打开你的访问日志，观察日志内容。然后刷新几次浏览器页面，看看日志中新增加了哪些条目。
4. 用 `nginx -s reload` 重载配置，然后用 `nginx -s quit` 优雅停止，再重新启动。感受一下整个过程。

## 本节小结

通过 `nginx` 命令启动服务，`nginx -s reload` 热重载配置，`nginx -s quit` 优雅停止；master 进程做管理，worker 进程做服务；日志文件是你了解服务器运行状况的窗口。

## 下一节预告

下一节是导论的回顾篇，我们将用自己的话来复述 Nginx 的核心概念，并做一个综合的小练习来巩固所学内容。
