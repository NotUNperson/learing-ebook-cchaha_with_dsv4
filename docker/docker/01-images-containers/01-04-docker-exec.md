# 01-04 docker exec —— 进入容器的"任意门"

## 本节你会学到什么

- 理解 `docker exec` 和 `docker run` 的区别
- 掌握 `-it` 参数的含义——什么是交互模式和 TTY
- 学会用 `docker exec -it <容器> bash` 进入容器内部
- 知道 alpine 容器为什么没有 bash，以及如何应对

---

## 你开了一家餐厅，想进去看看

你的容器（餐厅）在后台运行得好好的。某天你想知道里面在发生什么——厨师在做什么菜？冰箱里有什么食材？有没有哪个灶台坏了？

你需要一扇"任意门"——进去了，可以在里面走动、查看、操作，出来的时候还不影响餐厅正常运营。

这扇任意门就是 `docker exec`。

---

## docker run vs docker exec

新手很容易搞混这两个命令：

| 命令 | 作用 | 类比 |
|------|------|------|
| `docker run` | 基于镜像**创建新容器**并启动 | 按照图纸新开一家餐厅 |
| `docker exec` | 在**已有的运行中的容器**里执行命令 | 走进已经在营业的餐厅里，做点什么 |

一句话区分：`run` 是创造新生命，`exec` 是进入已有生命的体内。

---

## 基本用法：在容器里执行命令

```bash
# 先启动一个后台容器
docker run -d --name my-nginx nginx

# 在容器里执行一条命令
docker exec my-nginx ls /usr/share/nginx/html
# 输出：index.html  50x.html

# 再执行一条
docker exec my-nginx cat /etc/nginx/nginx.conf
# 输出：nginx 主配置文件的内容
```

不进入容器内部，只是让容器"帮我跑个命令，把结果告诉我"。就像你通过对讲机跟餐厅后厨说："帮我看一下冰箱里还有多少鸡蛋"，厨师告诉你结果。

---

## -it：真正的"进入"

```bash
docker exec -it my-nginx bash
```

回车后，你会发现终端提示符变了——你成功进入了容器内部！现在你可以在容器里自由操作：

```bash
# 你现在在容器里了
root@a1b2c3d4e5f6:/# whoami
root

root@a1b2c3d4e5f6:/# ls /
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

root@a1b2c3d4e5f6:/# cat /etc/os-release
# 能看到容器使用的操作系统信息

root@a1b2c3d4e5f6:/# exit
# 退出来，回到宿主机的终端
```

### -it 到底是什么？

`-it` 其实是两个参数的组合：`-i` + `-t`。

- **`-i`（interactive，交互模式）**：保持 STDIN（标准输入）打开，这样你才能向容器里打字。如果不加 `-i`，你敲键盘容器完全不理你。
- **`-t`（TTY，终端模拟）**：给容器分配一个伪终端（pseudo-TTY），让容器的命令行表现得像一个正常的终端——比如有提示符、能显示颜色、支持 Tab 补全。

类比：`-i` 是"打开对讲机的通话按钮"（让你能说话），`-t` 是"把对讲机换成可视电话"（让你看到对方的表情和环境）。

**如果不加 `-it` 会怎样？**

```bash
# 不加 -it，bash 启动后立刻退出
docker exec my-nginx bash
# 什么都没发生，bash 启动后因为没有输入源，直接退出了
```

---

## alpine 容器没有 bash！

这是一个新手常踩的坑。你尝试进入 alpine 容器：

```bash
docker run -d --name my-alpine alpine sleep 3600

docker exec -it my-alpine bash
# 报错：exec: "bash": executable file not found in $PATH
```

为什么？因为 Alpine Linux 为了极致的精简，没有安装 `bash`，它默认的 shell 是 `ash`（一个更小的 POSIX shell）。改一下就行了：

```bash
docker exec -it my-alpine sh
# 或者
docker exec -it my-alpine ash
# 或者直接用绝对路径
docker exec -it my-alpine /bin/sh
```

进去了！Alpine 容器虽然小，但该有的都有，只是命令名称跟 Ubuntu/Debian 稍微不同。

安全做法：进入你不熟悉的容器时，先用 `/bin/sh` 而不是 `bash`——`sh` 几乎在所有 Linux 发行版上都存在。

---

## 实用场景

### 场景 1：调试——你的应用在容器里跑不起来

```bash
# 进容器查看文件
docker exec -it my-app bash
ls /app
cat /app/config.yml    # 看看配置文件对不对
env                     # 看看环境变量传进来没有
```

### 场景 2：临时操作数据库

```bash
# 进入 MySQL 容器，用 mysql 命令行操作
docker exec -it mysql-db mysql -u root -p
```

### 场景 3：安装临时调试工具

```bash
# 进容器装个 curl 来测试网络
docker exec -it my-nginx bash
apt-get update && apt-get install -y curl
curl http://localhost:80
# 注意：容器重启后这些临时安装的包会消失！
```

### 场景 4：不用进入容器，直接执行命令

```bash
# 查看 Nginx 的错误日志
docker exec my-nginx cat /var/log/nginx/error.log

# 重启 Nginx（不用 stop/start 整个容器）
docker exec my-nginx nginx -s reload
```

---

## 退出容器

在容器内部，有三种方式退出：

```bash
# 方式 1：输入 exit 命令
exit

# 方式 2：按 Ctrl + D（发送 EOF）
# 在终端里按 Ctrl + D

# 方式 3：先按 Ctrl + P，再按 Ctrl + Q
# 这个组合键让你"脱离"容器但不退出它
# 容器内的程序继续运行，你退回到宿主机终端
```

Ctrl+P + Ctrl+Q 是个很酷的技巧，但在 `docker exec` 场景中用得不多——因为 `exec` 启动的是新进程，退出它不会影响容器主进程。

---

## 动手试试

1. 启动一个后台容器并进入它：

```bash
# 启动一个 alpine 容器，让它先别死（sleep 一会儿）
docker run -d --name explore-me alpine sleep 3600

# 进入容器
docker exec -it explore-me sh
```

2. 在容器里探索一下：
   - 用 `ls /` 看看根目录
   - 用 `cat /etc/os-release` 看看系统信息
   - 用 `whoami` 看看你是谁（应该是 root）
   - 用 `env` 看看有哪些环境变量
   - 用 `exit` 退出来

3. 换个镜像试试：

```bash
# 启动一个 nginx 容器
docker run -d --name explore-nginx nginx

# 进入它
docker exec -it explore-nginx bash

# 看看 nginx 的网页文件在哪
ls /usr/share/nginx/html/
cat /usr/share/nginx/html/index.html

# 退出来
exit
```

4. 清理：

```bash
docker rm -f explore-me explore-nginx
```

---

## 本节小结

`docker exec -it <容器> bash` 就是你进入容器内部的任意门——`-i` 让你能说话（交互），`-t` 让你看到表情（终端），进去后跟操作一个普通 Linux 系统一样方便。

---

## 下一节预告

你已经知道怎么用 `-p` 映射端口了（第 2 节简单提过）。下一节专门深入端口映射——`-p 8080:80` 的含义是什么、多个端口怎么映射、宿主机端口冲突了怎么办。
