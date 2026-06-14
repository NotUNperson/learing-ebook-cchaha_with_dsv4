# 02-06 CMD 与 ENTRYPOINT

## 本节你会学到什么

- 彻底分清 CMD 和 ENTRYPOINT 的区别
- 理解 shell 形式和 exec 形式的差异及其对信号处理的影响
- 掌握 CMD + ENTRYPOINT 组合使用的技巧
- 能够设计支持灵活参数的镜像

## 正文

CMD 和 ENTRYPOINT 是 Dockerfile 里最容易混淆的两个指令。它们都和"容器启动时执行什么命令"有关，但分工不同。这节我们彻底说清楚。

### 用"套餐"来类比

想象你去一家餐厅点餐。菜单上有一个 **"午间定食"**，内容写的是：米饭 + 味增汤 + 炸猪排 + 沙拉。

在这个场景里：
- **ENTRYPOINT** 就是"午间定食"这个**套餐的主体**——米饭、味增汤、炸猪排是固定的，你改不了。
- **CMD** 就是**配菜**——默认给你沙拉，但你可以跟服务员说"沙拉换成蒸蛋"。

所以：
- **ENTRYPOINT**：容器的"入口程序"，是容器启动时必须执行的主程序。
- **CMD**：传给 ENTRYPOINT 的"默认参数"，可以被 `docker run` 后面的命令覆盖。

### 四条规则帮你记住

1. **如果只有 CMD**：CMD 指定的就是容器启动时执行的命令。但 `docker run` 后面的参数可以覆盖它。
2. **如果只有 ENTRYPOINT**：ENTRYPOINT 指定的程序一定会被执行，`docker run` 后面的参数作为它的参数传入。
3. **如果两者都有**：CMD 作为 ENTRYPOINT 的默认参数。`docker run` 后面的参数会覆盖 CMD。
4. **如果什么都没有**：基础镜像的默认命令生效（如果有的话）。

### 两种写法：shell 与 exec（重要！）

这是本节最关键的知识点——shell 形式和 exec 形式不仅仅是写法不同，它们有本质区别。

**Shell 形式**：

```dockerfile
CMD echo "hello"
CMD /start.sh
```

这种写法的底层是：Docker 启动一个 shell（`/bin/sh -c`），然后在 shell 里执行你的命令。你的应用进程不是 PID 1，shell 才是。这意味着：
- Unix 信号（如 SIGTERM）是发给 PID 1（shell）的，shell 不会把它转发给你的应用。
- 结果就是 `docker stop` 时，你的应用收不到优雅退出的信号，10 秒后被 SIGKILL 强杀。
- 但好处是可以用 shell 的特性：环境变量展开、管道、通配符。

**Exec 形式（JSON 数组）**：

```dockerfile
CMD ["echo", "hello"]
CMD ["/start.sh"]
```

这种写法不经过 shell，直接执行你的程序。你的程序就是 PID 1，可以正常接收信号。但你不能用 shell 特性（比如 `$HOME` 不会自动展开）。

**结论：生产环境用 exec 形式。同时注意：exec 形式中，数组的每个元素必须用双引号，不能是单引号。**

### CMD 详解

CMD 有三种写法：

```dockerfile
# 1. exec 形式（推荐）
CMD ["nginx", "-g", "daemon off;"]

# 2. 作为 ENTRYPOINT 的默认参数（推荐）
CMD ["--port", "8080"]

# 3. shell 形式
CMD nginx -g 'daemon off;'
```

看一个被覆盖的例子：

```dockerfile
FROM alpine
CMD ["echo", "hello"]
```

```bash
docker build -t cmd-demo .
docker run cmd-demo              # 输出: hello
docker run cmd-demo echo world   # 输出: world（CMD 被覆盖了）
```

`docker run cmd-demo echo world` 等于把 CMD 从 `["echo", "hello"]` 替换成了 `["echo", "world"]`。

### ENTRYPOINT 详解

ENTRYPOINT 是"不能被覆盖"的命令（除非你显式用 `--entrypoint` 覆盖）。

```dockerfile
FROM alpine
ENTRYPOINT ["echo", "固定前缀"]
```

```bash
docker build -t entrypoint-demo .
docker run entrypoint-demo                # 输出: 固定前缀
docker run entrypoint-demo 你好           # 输出: 固定前缀 你好
docker run entrypoint-demo 你好 世界      # 输出: 固定前缀 你好 世界
```

注意：`docker run` 后面的参数是**追加**到 ENTRYPOINT 后面的，不是覆盖。

### CMD + ENTRYPOINT 黄金组合

这是最强大也最推荐的用法：

```dockerfile
FROM alpine
ENTRYPOINT ["echo"]
CMD ["我是默认参数"]
```

```bash
docker run myimage              # 执行 echo 我是默认参数
docker run myimage 我是自定义   # 执行 echo 我是自定义
```

实用场景：写一个通用的工具镜像。

```dockerfile
FROM python:3.12-alpine
ENTRYPOINT ["python", "-m", "http.server"]
CMD ["8000"]
```

```bash
# 默认在 8000 端口启动
docker run http-server

# 覆盖端口为 9090
docker run http-server 9090
```

这样使用者不需要记住完整的命令，只需要提供不同的参数。

### 用 ENTRYPOINT + CMD 做"镜像即命令"

这是 Docker 进阶用法里的经典模式。原理是：用 ENTRYPOINT 设一个脚本，CMD 放主命令。主命令会在脚本执行完之后获得控制权。

```dockerfile
FROM alpine
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sh"]
```

`docker-entrypoint.sh` 可以做：
- 环境变量检查和默认值设置
- 数据库连接等待
- 文件权限修复
- 配置模板渲染

然后再 `exec "$@"` 把控制权交给 CMD 指定的命令。

```bash
#!/bin/sh
# docker-entrypoint.sh
set -e

# 检查必需的环境变量
if [ -z "$DATABASE_URL" ]; then
    echo "ERROR: DATABASE_URL is not set"
    exit 1
fi

# 等待数据库就绪
echo "Waiting for database..."
# ... 数据库连接检查逻辑 ...

# 执行主命令
exec "$@"
```

`exec "$@"` 是用 shell 的 `exec` 替换当前进程，保证主命令成为 PID 1，可以接收信号。

### 覆盖 ENTRYPOINT

虽然 ENTRYPOINT 设计为"固定入口"，但你可以在运行容器时用 `--entrypoint` 覆盖：

```bash
# 正常启动
docker run myimage

# 覆盖 entrypoint，进入调试模式
docker run --entrypoint sh -it myimage
```

这在调试时非常有用——你可以绕开入口程序，直接启动一个 shell 进容器排查问题。

### 完整对比表

| 特性 | CMD | ENTRYPOINT |
|------|-----|------------|
| docker run 追加参数 | 覆盖 CMD | 追加到 ENTRYPOINT 后面 |
| 能否被覆盖 | 能（命令行参数直接覆盖） | 需要 --entrypoint 才能覆盖 |
| 典型用途 | 默认命令/参数 | 容器的主程序/入口脚本 |
| 同时使用时 | 作为 ENTRYPOINT 的默认参数 | 作为容器的主程序 |

## 动手试试

1. 创建三个简单的 Dockerfile，分别测试：只有 CMD、只有 ENTRYPOINT、CMD + ENTRYPOINT 组合。构建并运行，尝试用 `docker run` 追加不同参数，观察行为。
2. 用 `docker run --entrypoint` 覆盖 ENTRYPOINT，看看能否进入容器的 shell。
3. 对比 shell 形式和 exec 形式的差异：写一个简单的 shell 脚本作为 CMD/ENTRYPOINT，在脚本里加 `trap "echo received signal" TERM`，分别用 shell 和 exec 形式运行，然后用 `docker stop` 观察信号是否被正确处理。

## 本节小结

ENTRYPOINT 是容器的固定入口程序，CMD 是默认参数（可被覆盖）。Exec 形式确保应用成为 PID 1 并正确接收信号。ENTRYPOINT + CMD 组合是构建灵活工具镜像的最佳实践。

## 下一节预告

下一节我们学习 `docker build` 命令的详细用法——标签管理、构建参数、缓存控制等。
