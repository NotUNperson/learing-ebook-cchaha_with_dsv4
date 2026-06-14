# 01-07 docker logs 和 docker inspect —— 容器诊断手册

## 本节你会学到什么

- 熟练用 `docker logs` 查看容器日志的各种技巧
- 掌握 `docker inspect` 查看容器底层配置
- 学会用 `--format` 提取特定字段
- 学会排查容器的常见问题：启动失败、端口错误、配置不对

---

## 你的餐厅出问题了，怎么办？

你的餐厅（容器）可能遇到各种问题：

- 菜上得特别慢（性能问题）——看看后厨在干什么
- 突然倒闭了（容器退出了）——看看倒闭前的最后记录
- 菜的味道不对（配置错误）——看看菜谱（配置）写的是什么

`docker logs` 和 `docker inspect` 就是你的诊断工具——一个看"发生了什么"，一个看"是怎么配置的"。

---

## docker logs：看容器说了什么

### 基本用法

```bash
# 先启动一个会持续输出日志的容器
docker run -d --name log-test alpine \
  sh -c 'while true; do echo "$(date) - 第 $((i=i+1)) 条日志"; sleep 2; done'

# 查看日志
docker logs log-test
```

你会看到源源不断的日志输出。

**类比**：`docker logs` 就像餐厅的监控录像——你回放看厨房里发生了什么。

### 常用选项

```bash
# --tail N：只看最后 N 行
docker logs --tail 10 log-test

# -f / --follow：实时跟踪日志（类似 tail -f）
docker logs -f log-test
# 按 Ctrl+C 退出跟踪

# --since：只看某时间之后的日志
docker logs --since 5m log-test      # 最近 5 分钟
docker logs --since 2024-01-01 log-test

# --until：只看某时间之前的日志
docker logs --until 2024-01-01 log-test

# --timestamps / -t：显示时间戳
docker logs -t log-test

# 组合使用
docker logs --tail 50 -f log-test     # 看最后 50 行，然后实时跟踪
```

### 日志太多怎么办？

```bash
# 管道到 less 分页查看
docker logs log-test | less

# 管道到 grep 搜索关键词
docker logs log-test | grep "ERROR"

# 管道到 head/tail 控制行数
docker logs log-test | tail -20
```

---

## docker inspect：看容器长什么样

`docker logs` 告诉你"容器做了什么"，`docker inspect` 告诉你"容器是怎么构建的"。

```bash
docker inspect log-test
```

输出是一大段 JSON，看起来很吓人。但别怕，我们来解读关键部分。

### 输出中的关键字段

```bash
# 只看关键的部分（截取输出）
docker inspect log-test
```

```json
[
    {
        "Id": "abc123...完整 64 位 ID",
        "Name": "/log-test",
        "State": {
            "Status": "running",
            "Running": true,
            "StartedAt": "2024-01-15T10:30:00.123456789Z"
        },
        "Mounts": [],                         // 挂载的卷
        "Config": {
            "Image": "alpine",
            "Env": ["PATH=/usr/local/sbin:..."], // 环境变量
            "Cmd": ["sh", "-c", "while true..."], // 启动命令
            "ExposedPorts": {}
        },
        "NetworkSettings": {
            "IPAddress": "172.17.0.2",        // 容器 IP
            "Ports": {}                       // 端口映射
        }
    }
]
```

关键字段解读：
- **Id**：容器的完整 ID
- **State.Status**：`running` / `exited` / `paused`
- **State.StartedAt**：启动时间
- **Config.Image**：基于哪个镜像
- **Config.Env**：环境变量列表
- **Config.Cmd**：容器启动时执行的命令
- **NetworkSettings.IPAddress**：容器的内部 IP
- **NetworkSettings.Ports**：端口映射详情
- **Mounts**：数据卷挂载情况

类比：`docker inspect` 就是"调出这家餐厅的工商注册档案"——法人是谁、注册资本多少、经营范围是什么、注册地址在哪……所有你想知道的底层信息都在里面。

---

## 用 --format 提取特定字段

JSON 全量输出信息量太大。`--format` 让你只取自己想要的部分，使用 Go 模板语法：

```bash
# 查看容器 IP 地址
docker inspect --format='{{.NetworkSettings.IPAddress}}' log-test

# 查看容器状态
docker inspect --format='{{.State.Status}}' log-test

# 查看环境变量（一行一个）
docker inspect --format='{{range .Config.Env}}{{println .}}{{end}}' log-test

# 查看端口映射
docker inspect --format='{{json .NetworkSettings.Ports}}' log-test

# 一次查多个字段
docker inspect --format='容器 {{.Name}} 状态={{.State.Status}} IP={{.NetworkSettings.IPAddress}}' log-test
```

常见格式模板速查：

| 你想查的 | 模板 |
|----------|------|
| 容器状态 | `{{.State.Status}}` |
| 容器 IP | `{{.NetworkSettings.IPAddress}}` |
| 镜像名 | `{{.Config.Image}}` |
| 启动命令 | `{{.Config.Cmd}}` |
| 环境变量列表 | `{{range .Config.Env}}{{println .}}{{end}}` |
| 挂载点 | `{{range .Mounts}}{{.Source}} -> {{.Destination}}{{println}}{{end}}` |
| 端口映射 | `{{json .NetworkSettings.Ports}}` |
| 启动时间 | `{{.State.StartedAt}}` |

这些格式刚开始不急着背。用时回来查，用多了自然就记住了。

---

## 排查问题实战

### 场景 1：容器启动后立刻退出

```bash
docker run -d --name crash-test alpine echo "我跑完了"
# 容器立刻就退出了，因为它执行的命令结束了

# 查看状态
docker ps -a --filter "name=crash-test"
# 状态显示 Exited (0)

# 查看退出前有没有日志
docker logs crash-test
# 输出：我跑完了

# 查看退出码
docker inspect --format='{{.State.ExitCode}}' crash-test
# ExitCode 0 表示正常退出
# 非 0 表示异常退出
```

### 场景 2：容器在运行但服务连不上

```bash
# 查看容器是否真的在监听端口
docker inspect --format='{{json .NetworkSettings.Ports}}' my-web-app

# 查看容器日志，看有没有启动报错
docker logs --tail 50 my-web-app

# 进入容器内部检查
docker exec -it my-web-app bash
netstat -tlnp    # 看容器内部什么端口在监听
```

### 场景 3：配置没生效

```bash
# 查看容器实际收到的环境变量
docker inspect --format='{{range .Config.Env}}{{println .}}{{end}}' my-container
```

### 场景 4：找到所有异常退出的容器

```bash
# 列出所有非 0 退出码的容器
docker ps -a --filter "exited=1"

# 批量查看它们最后的日志
docker ps -a --filter "exited=1" --format '{{.Names}}' | \
  while read name; do
    echo "===== $name ====="
    docker logs --tail 5 "$name"
  done
```

---

## 动手试试

1. 启动一个会出错的容器，并用日志和 inspect 诊断：

```bash
# 启动一个会立即失败的容器
docker run -d --name error-test alpine sh -c "echo '要出错了...'; exit 1"

# 查看容器状态
docker ps -a --filter "name=error-test"

# 查看日志
docker logs error-test

# 查看退出码
docker inspect --format='退出码: {{.State.ExitCode}}' error-test

# 查看完整的 State 信息
docker inspect --format='{{json .State}}' error-test
```

2. 练习 `--format`（先清理上面的测试容器）：

```bash
docker rm -f log-test error-test crash-test 2>/dev/null

# 启动一个新容器
docker run -d --name inspect-test nginx:alpine

# 只提取 IP 地址
docker inspect --format='IP: {{.NetworkSettings.IPAddress}}' inspect-test

# 只提取镜像名和启动时间
docker inspect --format='镜像: {{.Config.Image}}, 启动于: {{.State.StartedAt}}' inspect-test
```

3. 日志跟踪练习：

```bash
# 启动一个持续输出的容器
docker run -d --name log-demo alpine sh -c 'i=0; while true; do i=$((i+1)); echo "循环第 $i 次"; sleep 1; done'

# 实时跟踪
docker logs -f log-demo
# 按 Ctrl+C 退出

# 只看最后 5 行
docker logs --tail 5 log-demo
```

4. 清理：

```bash
docker rm -f inspect-test log-demo
```

---

## 本节小结

`docker logs` 是监控录像（容器做了什么），`docker inspect` 是工商档案（容器怎么配置的）——两个工具组合起来，排查问题不用慌。

---

## 下一节预告

模块 01 的最后一节来了！我们做一个综合练习：用 Nginx 部署一个自定义的网站。你要用到这个模块学到的所有技能——拉取镜像、运行容器、端口映射、进入容器、查看日志。我们还会提供一个自定义的 index.html，让你真正感觉"我把自己的东西部署上去了"。
