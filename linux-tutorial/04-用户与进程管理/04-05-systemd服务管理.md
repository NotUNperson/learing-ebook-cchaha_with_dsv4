# 04-05 systemd 服务管理

## 本节你会学到什么

- 理解 systemd 是什么，以及它在 Linux 系统中的角色（PID=1）
- 掌握 `systemctl` 的核心操作：启停服务、查看状态、设置开机自启
- 理解 systemd unit 文件的基本结构和配置位置
- 使用 `journalctl` 查看和管理系统日志
- 理解 `restart` 和 `reload` 的区别

---

## systemd 是什么？大楼的物业管理系统

想象一栋现代化写字楼。每天早上，物业管理员要依次打开：
- 中央空调
- 电梯系统
- 门禁系统
- 消防报警系统
- 停车场的道闸

这些系统必须按正确的顺序启动（消防系统得先启动，电梯后启动），而且如果某个系统中途出了故障，整栋楼的运作都会受影响。

Linux 服务器也是类似的。系统启动后，有几十上百个后台服务需要启动：网络服务、SSH、日志系统、数据库、Web 服务器、定时任务调度器……谁来统一管理这些服务的启动顺序、依赖关系、运行状态？

在早期的 Linux 里，这个角色由 **SysV init** 担任。它是 PID=1 的进程，所有其他进程的祖先。但它有个很大的缺点：启动服务是串行的（一个接一个），启动速度慢，而且管理服务的脚本（`/etc/init.d/` 下的 Shell 脚本）写得支离破碎，缺乏统一标准。

于是 **systemd** 诞生了，它在 2010 年前后由 Red Hat 的工程师 Lennart Poettering 开发，现在几乎被所有主流 Linux 发行版采用（包括 Debian、Ubuntu、Fedora、CentOS、RHEL、Arch 等）。

**类比**：SysV init 像一位老派的物业管理员，他拿着一本手写的清单，按顺序一间间去敲机房门，等这台启动完了才去下一台。systemd 则像一个智能楼宇管理系统，中央控制器可以并发启动服务，知道每个服务的依赖关系，自动处理故障，还能实时给你看状态面板。

---

## systemd 的核心概念

### Unit（单元）

在 systemd 的世界里，一切被管理的东西都叫 **Unit**。Unit 有不同的类型：

| Unit 类型 | 文件后缀 | 含义 | 类比 |
|-----------|---------|------|------|
| Service | `.service` | 一个后台服务 | 一台服务器的电源开关 |
| Socket | `.socket` | 网络套接字 | 一个端口的监听器 |
| Timer | `.timer` | 定时器 | 闹钟，替代 cron |
| Mount | `.mount` | 挂载点 | 文件系统的接入开关 |
| Target | `.target` | 一组 unit 的集合 | 楼层配电总开关 |
| Device | `.device` | 硬件设备 | 某个设备的管理单元 |

我们这一节重点关注 **Service Unit** -- 也就是后台服务。

### Target（目标）

Target 是一个"运行级别"的概念。它表示系统应该达到的某种状态。常见的 target：

| Target | 含义 | 类比 |
|--------|------|------|
| `multi-user.target` | 多用户命令行模式（最常见的服务器状态） | 办公楼正常运行模式 |
| `graphical.target` | 多用户图形界面模式（桌面系统） | 前台大厅开着，还打了灯光 |
| `rescue.target` | 救援模式（单用户，基本服务） | 大楼只开应急电源 |
| `emergency.target` | 紧急模式（最精简，只有 root shell） | 大楼消防模式，只留安全通道 |

用 `systemctl get-default` 查看当前默认的 target，用 `systemctl set-default multi-user.target` 设置默认启动 target。

---

## systemctl：你的服务遥控器

`systemctl` 是管理 systemd 服务的主要命令。就像你用电视遥控器换台，用 `systemctl` 控制服务的启停。

### 查看服务状态

```bash
# 查看服务的完整状态
systemctl status nginx

# 只看服务是否在运行
systemctl is-active nginx

# 只看服务是否设置了开机自启
systemctl is-enabled nginx

# 列出所有已加载的 service 类型的 unit
systemctl list-units --type=service

# 只看正在运行的 service
systemctl list-units --type=service --state=running

# 查看启动失败的服务
systemctl list-units --failed

# 查看所有服务文件的启用状态（不管是否已加载）
systemctl list-unit-files --type=service
```

`systemctl status` 的输出包含了非常丰富的信息：

```
 nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2026-05-14 08:30:15 CST; 1 day 3h ago
     Docs: man:nginx(8)
 Main PID: 1234 (nginx)
    Tasks: 5 (limit: 4915)
   Memory: 12.3M
   CGroup: /system.slice/nginx.service
           |-1234 nginx: master process /usr/sbin/nginx
           |-1235 nginx: worker process
           |-1236 nginx: worker process
           |-1237 nginx: worker process
           |-1238 nginx: worker process
```

逐行解读：
- **Loaded**：unit 文件有没有被加载，`enabled` 还是 `disabled`
- **Active**：`active (running)` 表示正常运行，`inactive` 表示已停止，`failed` 表示启动失败
- **Docs**：相关帮助文档
- **Main PID**：服务主进程的进程 ID
- **Tasks/Memory**：服务用了多少个线程、多少内存
- **CGroup**：该服务在 cgroup 层级中的位置，下面列出了所有属于这个服务的进程

### 启停服务

```bash
# 启动
sudo systemctl start nginx

# 停止
sudo systemctl stop nginx

# 重启（停止 + 启动，服务会中断）
sudo systemctl restart nginx

# 重新加载配置（不中断服务，服务进程不被杀死）
sudo systemctl reload nginx

# 条件重启（只在服务已经在运行时才重启）
sudo systemctl try-restart nginx

# 条件重新加载（只在服务支持 reload 时才执行）
sudo systemctl reload-or-restart nginx
```

**`restart` vs `reload` 的关键区别**：

- `restart`：完全停掉服务进程，再重新启动。这个过程会导致服务**短暂中断**（几百毫秒到几秒）。类比：你完全关了电视再打开。
- `reload`：告诉正在运行的服务进程去重新读取配置文件，服务本身不停止。类比：你拿着遥控器调了个音量，电视机一直在开着。

不是所有服务都支持 `reload`。Nginx 和 Apache 支持，但很多简单的服务不支持。如果你不确定，用 `reload-or-restart` 让 systemd 帮你判断。

### 开机自启管理

```bash
# 设置开机自启
sudo systemctl enable nginx

# 取消开机自启
sudo systemctl disable nginx

# 重新建立开机自启的符号链接（如果配置变了）
sudo systemctl reenable nginx

# 完全屏蔽服务（链接到 /dev/null，防止被任何方式启动）
sudo systemctl mask nginx

# 取消屏蔽
sudo systemctl unmask nginx
```

`enable` 做了一件很聪明的事情：它在 `/etc/systemd/system/multi-user.target.wants/` 目录下创建了一个**符号链接**，指向 nginx 的 service 文件。当系统进入 `multi-user.target` 状态时（即正常启动完成），就会自动启动这个链接指向的服务。

`mask` 更进一步：它把这个链接指向 `/dev/null`（Linux 的"黑洞"设备）。这样一来，不管谁尝试启动这个服务，都会被导向黑洞，服务根本无法启动。

类比：
- `enable`：在你的日程表里加了"每天 9 点自动打卡"
- `disable`：从日程表里删掉了这条
- `mask`：把打卡机电源线剪了，不让任何人用

---

## systemd unit 文件：服务的配置档案

每个 systemd 服务都由一个 unit 文件来定义。这个文件告诉 systemd：这个服务叫什么名字、运行什么命令、启动前需要先启动哪些其他服务、出故障了怎么处理。

### Unit 文件的存放位置

| 路径 | 用途 | 优先级 |
|------|------|--------|
| `/usr/lib/systemd/system/` | 软件包安装时自带的 unit 文件 | 低（被 /etc 覆盖） |
| `/etc/systemd/system/` | 管理员自定义的 unit 文件 | **最高** |
| `/run/systemd/system/` | 运行时临时创建的 unit 文件 | 中等 |

不要直接修改 `/usr/lib/systemd/system/` 下的文件 -- 它们会在软件包更新时被覆盖。

### Unit 文件的结构

一个典型的 service unit 文件分为三个段落：

```ini
[Unit]
Description=我的自定义服务
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/myapp
Restart=on-failure
User=myuser
Group=mygroup

[Install]
WantedBy=multi-user.target
```

#### [Unit] 段 -- 服务的基本信息

| 指令 | 含义 |
|------|------|
| `Description` | 服务的描述文字（在 `systemctl status` 中显示） |
| `After=network.target` | 在网络启动之后才启动本服务 |
| `Before=xxx.service` | 在某些服务之前启动 |
| `Requires=xxx.service` | 强依赖，如果依赖的服务启动失败，本服务也失败 |
| `Wants=xxx.service` | 弱依赖，尝试先启动依赖的服务但失败了也不影响 |

`Requires` 和 `Wants` 的区别：`Requires` 是"你必须来，你不来我就罢工"，`Wants` 是"我想让你来，但你要不来我也能凑合过"。大多数情况下用 `Wants` 就够了。

#### [Service] 段 -- 服务的行为定义

| 指令 | 含义 |
|------|------|
| `Type` | 启动类型（见下文） |
| `ExecStart` | 启动服务的命令 |
| `ExecStop` | 停止服务的命令（可选） |
| `ExecReload` | 重新加载配置的命令（可选） |
| `Restart` | 退出后自动重启策略 |
| `User` / `Group` | 服务以哪个用户/组的身份运行 |
| `WorkingDirectory` | 工作目录 |
| `Environment` | 环境变量 |
| `EnvironmentFile` | 从文件加载环境变量 |

**Type 的取值**是最重要的配置之一：

| Type | 含义 | 适用场景 |
|------|------|---------|
| `simple`（默认） | systemd 认为 `ExecStart` 启动的进程就是主进程 | 大多数简单的服务 |
| `forking` | 程序启动时 fork 出一个子进程作为主进程，父进程退出 | 传统守护进程（如 Nginx） |
| `oneshot` | 执行一次就退出的短命任务 | 初始化脚本 |
| `notify` | 服务启动后会主动通知 systemd | 支持 sd_notify 的现代服务 |
| `idle` | 等所有其他任务完成后再启动 | 不重要、不急的服务 |

新手最常踩的坑就是 `Type=forking`。如果你的服务是传统守护进程（程序运行时自己 fork 到后台），必须用 `forking` 类型并加上 `PIDFile` 指令，否则 systemd 可能误以为服务启动失败。

**Restart 策略**：

| 值 | 含义 |
|-----|------|
| `no` | 不自动重启（默认） |
| `on-failure` | 只在异常退出时才重启（返回码非0 或被信号终止） |
| `always` | 不管怎样都重启（即使是正常退出） |
| `on-abnormal` | 只在被信号终止、超时或 watchdog 触发时才重启 |
| `on-watchdog` | 只在 watchdog 触发时重启 |

`Restart=on-failure` 是最推荐的设置。它会在服务崩溃时自动重启，但如果你手动 `systemctl stop` 它，它不会自己活过来。

#### [Install] 段 -- 安装配置

| 指令 | 含义 |
|------|------|
| `WantedBy=multi-user.target` | 在进入多用户模式时自动启动本服务 |
| `RequiredBy=xxx.target` | 强依赖的 target |

`WantedBy=multi-user.target` 是最常见的设置。它等价于"我需要在系统正常启动后被启动"。如果你运行了 `systemctl enable myservice`，systemd 就会在 `multi-user.target` 的 wants 目录下创建一个符号链接。

### 用 systemctl cat 查看已有服务的 unit 文件

```bash
# 查看 SSH 服务的 unit 文件内容
systemctl cat sshd

# 查看 nginx（如果已安装）
systemctl cat nginx
```

### 修改已安装服务的配置

不要直接修改原始 unit 文件，而是用 `systemctl edit` 创建一个覆盖文件：

```bash
# 为 nginx 创建覆盖配置
sudo systemctl edit nginx
```

这会打开编辑器，你可以写入要覆盖的指令：

```ini
# /etc/systemd/system/nginx.service.d/override.conf
[Service]
Restart=always
RestartSec=5
```

保存后，执行：

```bash
sudo systemctl daemon-reload
sudo systemctl restart nginx
```

这样你的修改在一个独立的 override 文件里，软件包更新不会动它。

---

## journalctl：查看系统日志

systemd 内置了一套日志系统叫 **journal**。它用二进制格式存储日志（比文本文件更高效，支持索引和验证），`journalctl` 是它的查看工具。

### 基本用法

```bash
# 查看所有日志（从旧到新，分页显示）
journalctl

# 从新到旧查看
journalctl -r

# 实时跟踪最新日志（就像 tail -f）
journalctl -f

# 只显示本次启动后的日志
journalctl -b

# 显示上一次启动的日志（用于排查上次为什么启动失败）
journalctl -b -1
```

### 按时间过滤

```bash
# 最近 30 分钟的日志
journalctl --since "30 min ago"

# 指定时间段
journalctl --since "2026-05-15 10:00:00" --until "2026-05-15 11:00:00"

# 从某个时间点到现在
journalctl --since "2026-05-14"
```

### 按服务过滤

```bash
# 只看 nginx 的日志
journalctl -u nginx

# nginx 的实时日志
journalctl -u nginx -f

# nginx 最近 100 条
journalctl -u nginx -n 100

# 同时看多个服务的日志
journalctl -u nginx -u php-fpm
```

### 按严重级别过滤

```bash
# 只看错误及以上（err, crit, alert, emerg）
journalctl -p err

# 只看紧急级别
journalctl -p emerg

# 日志级别从低到高：
# debug(7) > info(6) > notice(5) > warning(4) > err(3) > crit(2) > alert(1) > emerg(0)
```

### 实用组合

```bash
# 查看 sshd 服务今天的错误
journalctl -u sshd --since today -p err

# 查看某个用户的所有日志
journalctl _UID=1000

# 查看内核日志（等于 dmesg）
journalctl -k

# 查看日志占用了多少磁盘空间
journalctl --disk-usage
```

### 日志持久化

默认情况下，journal 日志存储在 `/run/log/journal/`（内存文件系统），重启后会丢失。如果你需要**持久化存储**（重启后还能看到历史日志）：

```bash
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
sudo systemctl restart systemd-journald
```

然后在 `/etc/systemd/journald.conf` 中可以配置日志的最大占用空间：

```
SystemMaxUse=500M
```

---

## 动手试试

**练习：探索和管理你系统上的服务**

1. 查看所有正在运行的服务：
   ```bash
   systemctl list-units --type=service --state=running
   ```

2. 挑一个你认识的服务（比如 `sshd` 或 `cron`），查看它的状态：
   ```bash
   systemctl status sshd    # 或者 ssh, cron, cronie
   ```

3. 观察输出的 Loaded 和 Active 行。Loaded 是 `enabled` 还是 `disabled`？Active 是 `running` 吗？

4. 查看这个服务的 unit 文件内容：
   ```bash
   systemctl cat sshd
   ```

5. 查看这个服务最近的日志：
   ```bash
   journalctl -u sshd -n 20 --no-pager
   ```

6. 查看系统启动失败的服务（如果有的话）：
   ```bash
   systemctl list-units --failed
   ```

7. 查看 journal 占用的磁盘空间：
   ```bash
   journalctl --disk-usage
   ```

---

## 本节小结

systemd 是现代 Linux 的"楼宇管理系统"，通过 `systemctl` 你可以统一管理所有服务的启停、状态、开机自启和依赖关系，通过 `journalctl` 你可以集中查看所有服务的日志，而 unit 文件是定义每个服务行为的配置档案，存放在 `/etc/systemd/system/` 和 `/usr/lib/systemd/system/` 中。

---

## 下一节预告

理论学完了，该动手了！下一节是本章的综合练习：我们将从头创建一个自定义 systemd 服务 -- 写一个简单的脚本，为它写 unit 文件，配置开机自启，然后用 journalctl 查看它的日志。整个过程会让你把前面五节的内容串联起来。
