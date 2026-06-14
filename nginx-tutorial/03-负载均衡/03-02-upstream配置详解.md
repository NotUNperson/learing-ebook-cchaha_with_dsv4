# 03-02 upstream 配置详解

## 本节你会学到什么

- 掌握 `upstream` 块的语法和结构
- 理解 `server` 指令中的 `weight`、`max_fails`、`fail_timeout` 参数
- 配置轮询和加权轮询两种策略
- 搭建一个多后端服务器的负载均衡环境

## 正文

### upstream 块是什么

`upstream` 是 Nginx 中定义一个"后端服务器组"的配置块。它给一组后端服务器取一个名字，后续在 `proxy_pass` 中直接用这个名字引用。

```nginx
upstream 组名 {
    server 服务器地址 [参数];
    server 服务器地址 [参数];
    ...
}
```

用一个**外包团队名单**来类比。你是一个项目经理（Nginx），有一个外包开发人员名单（upstream）。名单上写着每个人的联系方式（IP:Port）和能力评级（weight）。来了新需求（请求），你从名单里按规则选一个人去执行。

```nginx
# 定义一个后端组，叫 "myapp"
upstream myapp {
    server 192.168.1.10:3000;
    server 192.168.1.11:3000;
    server 192.168.1.12:3000;
}

# 在 location 中引用
location /api/ {
    proxy_pass http://myapp;  # 注意：这里写 upstream 的名字
}
```

关键点：`proxy_pass` 中的地址 `http://myapp` 必须和 upstream 定义的组名一致。

### server 指令的参数

`server` 指令除了指定后端地址，还能带多个参数来控制行为：

```nginx
upstream backend {
    server 192.168.1.10:3000 weight=3 max_fails=2 fail_timeout=30s;
    server 192.168.1.11:3000 weight=1 max_fails=2 fail_timeout=30s;
    server 192.168.1.12:3000 backup;
}
```

**weight（权重）**

默认值为 1。权重越高的服务器，分到的请求越多。在加权轮询算法中，权重为 3 的服务器处理的请求大约是权重为 1 的服务器的 3 倍。

用**团队分工**来类比：一个三人团队，老张经验丰富能同时处理 3 个任务（weight=3），小李正常水平处理 1 个（weight=1），小王刚入职也处理 1 个（weight=1）。一共 5 份权重，老张承担 3/5=60% 的任务量。

**max_fails 和 fail_timeout（故障判定）**

这两个参数配合使用，定义了 Nginx 如何判断一个后端"挂了"：

- `max_fails`：在 `fail_timeout` 时间内，最多允许的失败次数
- `fail_timeout`：这个时间窗口，同时也是故障后的冷却时间

```nginx
server 192.168.1.10:3000 max_fails=2 fail_timeout=30s;
```

这段配置的意思是：在 30 秒内，如果和后端通信失败达到 2 次，Nginx 就认为这个后端不可用，在接下来的 30 秒内不再向它发送请求。30 秒后，Nginx 会再次尝试——如果还是失败，继续拉黑 30 秒；如果恢复了，重新加入工作队列。

用**外卖骑手的信誉系统**来类比：一个骑手 30 分钟内送了 2 次超时的单（max_fails=2），平台就暂时不给他派单了（标记为不可用），让他休息 30 分钟（fail_timeout）再重新上岗。如果回来后又超时，继续停。如果表现正常，恢复派单。

**backup（备用服务器）**

```nginx
server 192.168.1.12:3000 backup;
```

标记为 `backup` 的服务器平时不接收请求，只有当所有非 backup 服务器都不可用时，它才顶上。

用**消防通道**来类比：平时没人走消防通道，但一旦正门和侧门都堵死了，消防通道就成了唯一的出口。备用服务器平时处理零请求，但在主服务器全部宕机时，它保证服务不至于完全中断。

**down（手动下线）**

```nginx
server 192.168.1.13:3000 down;
```

标记为 `down` 的服务器永远不会接收请求。这在你要主动摘掉一台服务器做维护时很有用——改配置、加 `down`、reload，该服务器就逐步退出服务，已有的连接处理完后不再接新的。

### 轮询配置示例

默认的轮询（最简单）：

```nginx
upstream backend {
    server 192.168.1.10:3000;
    server 192.168.1.11:3000;
    server 192.168.1.12:3000;
}

server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

请求分配规律：请求 1 -> 10 号，请求 2 -> 11 号，请求 3 -> 12 号，请求 4 -> 10 号……

### 加权轮询配置示例

```nginx
upstream backend {
    server 192.168.1.10:3000 weight=6;   # 好机器，60%
    server 192.168.1.11:3000 weight=3;   # 中等，30%
    server 192.168.1.12:3000 weight=1;   # 差机器，10%

    # 故障判定
    # 30 秒内失败 3 次则标记为不可用，冷却 60 秒
    # server 指令中各自的 max_fails/fail_timeout 会覆盖这里的默认值
}

server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 本地测试：一台机器模拟多台后端

在实际开发环境中，你可能只有一台电脑。没关系，可以在不同端口启动多个后端进程来模拟：

```bash
# 启动三个后端进程，分别监听不同端口
node server.js 3001 &
node server.js 3002 &
node server.js 3003 &
```

然后 upstream 配置使用 `localhost` 加不同端口：

```nginx
upstream backend {
    server localhost:3001 weight=2;
    server localhost:3002 weight=2;
    server localhost:3003 weight=1;
}
```

这在一台电脑上完整模拟了负载均衡的行为。

### 完整配置示例

```nginx
upstream app_backend {
    # 负载均衡算法（默认轮询，这里显式指定）
    # 可选：least_conn, ip_hash, hash $request_uri 等

    # 三台后端服务器
    server localhost:3001 weight=3 max_fails=2 fail_timeout=30s;
    server localhost:3002 weight=2 max_fails=2 fail_timeout=30s;
    server localhost:3003 weight=1 max_fails=2 fail_timeout=30s;

    # 备用服务器（所有主服务器都挂了才启用）
    server localhost:3004 backup;
}

server {
    listen 80;
    server_name api.local;

    location / {
        proxy_pass http://app_backend;

        # 完整的请求头传递
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 超时和重试
        proxy_connect_timeout 5s;
        proxy_read_timeout 10s;
        proxy_next_upstream error timeout http_502 http_503;
        proxy_next_upstream_tries 3;
    }
}
```

## 动手试试

1. 准备一个能返回自己端口号的后端程序（下一节会提供完整代码，你也可以先自己写：用 Node.js 创建一个 HTTP 服务器，返回一句话包含自身的端口号）。
2. 在同一台机器上以不同端口启动 3 个后端进程。
3. 配置 Nginx 的 upstream 块，指向这 3 个端口。
4. 配置使用加权轮询（权重分别为 3、2、1）。
5. 用 `curl` 连续访问 10 次代理地址，统计每个后端被分配了几次。看看分配比例是否接近 3:2:1。
6. 把其中一个后端的 `weight` 改成 5，重载后再测 10 次，对比变化。

## 本节小结

`upstream` 定义后端服务器组，`server` 指令配置每个后端的地址和参数（weight 分配权重、max_fails/fail_timeout 控制故障判定、backup 做备用）。proxy_pass 引用 upstream 组名即可启用负载均衡。

## 下一节预告

下一节我们学习会话保持（Session Persistence）的问题——为什么同一个用户的请求需要打到同一台服务器？IP 哈希怎么用？它有什么坑？cookie 黏连又是怎么回事？
