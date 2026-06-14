# 01-08 综合练习 —— 用 Nginx 部署一个自定义网站

## 本节你会学到什么

- 综合运用模块 01 学到的所有 Docker 技能
- 从拉取镜像到部署一个完整的自定义网页
- 学会用 `-v` 挂载本地文件到容器中
- 体验一次完整的"开发-部署-验证"流程

---

## 目标

用 Docker 部署一个 Nginx Web 服务器，显示你自己定制的网页内容，而不是 Nginx 默认的欢迎页。

我们会用到：`docker pull`、`docker run`、`-d`、`--name`、`-p`、`-v`、`docker ps`、`docker logs`、`docker exec`。

---

## 第一步：准备自定义网页

在你的工作目录下创建以下文件结构：

```
examples/01-08/
  +-- index.html       # 你的自定义首页
  +-- run.sh           # 启动脚本（可选）
```

首先创建 `index.html`：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的 Docker 网站</title>
    <style>
        body {
            font-family: "Microsoft YaHei", "微软雅黑", sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 0 20px;
            background: #f5f5f5;
            color: #333;
        }
        .card {
            background: white;
            border-radius: 8px;
            padding: 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #0db7ed;
            margin-top: 0;
        }
        .info {
            background: #e8f4fd;
            border-left: 4px solid #0db7ed;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        code {
            background: #eee;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: "Courier New", monospace;
        }
        .footer {
            margin-top: 30px;
            font-size: 14px;
            color: #999;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="card">
        <h1>恭喜！你的自定义网站通过 Docker 成功部署了！</h1>
        <p>这个页面正在一个 Docker 容器中运行。</p>

        <div class="info">
            <strong>你刚才完成的操作为：</strong><br>
            1. 拉取了 <code>nginx:alpine</code> 镜像<br>
            2. 用 <code>docker run</code> 启动了一个容器<br>
            3. 用 <code>-v</code> 把这个 HTML 文件挂载进了容器<br>
            4. 用 <code>-p 8080:80</code> 把容器端口映射到了宿主机<br>
            5. 现在你正在浏览器里看到这个页面！
        </div>

        <h2>试一试改动这个页面</h2>
        <ol>
            <li>用文本编辑器打开 <code>index.html</code> 文件</li>
            <li>修改上面的标题或任何文字</li>
            <li>保存文件</li>
            <li>刷新浏览器 —— 改动立即可见！</li>
        </ol>

        <h2>你还学会了什么？</h2>
        <p>在这个模块 01 里，你已经掌握了：</p>
        <ul>
            <li><code>docker pull</code> —— 从 Docker Hub 拉取镜像</li>
            <li><code>docker run</code> —— 启动容器（后台运行、命名、端口映射、环境变量）</li>
            <li><code>docker ps</code> —— 查看容器列表和状态</li>
            <li><code>docker stop / start / restart / rm</code> —— 管理容器生命周期</li>
            <li><code>docker exec -it</code> —— 进入容器内部</li>
            <li><code>docker logs / inspect</code> —— 查看日志和诊断</li>
        </ul>

        <div class="footer">
            模块 01 完成！下一步：学习编写 Dockerfile，构建你自己的镜像。
        </div>
    </div>
</body>
</html>
```

---

## 第二步：搞清楚 -v 挂载

我们需要把本地的 `index.html` 文件"塞"进容器里，替换掉 Nginx 默认的欢迎页。这就用到 `-v` 参数（volume mount）：

```bash
-v 宿主机路径:容器内路径
```

Nginx 默认的网页文件在容器内的路径是：`/usr/share/nginx/html/index.html`

所以我们把本地的 `index.html` 挂载进去：

```bash
-v ./index.html:/usr/share/nginx/html/index.html
```

类比：你的餐厅（容器）默认菜单上写的是"今日特价：炒饭"。但你想改成"今日特价：龙虾"。你把新菜单（`index.html`）粘到旧菜单的位置上——顾客（浏览器）看到的就是新菜单了。

注意：我们这里挂载的是**单个文件**。你也可以挂载整个目录：

```bash
-v ./html:/usr/share/nginx/html
```

这样 `./html` 目录下的所有文件都会出现在容器里——更适合有多个静态资源的网站（CSS、JS、图片等）。

---

## 第三步：启动容器

进入你创建 `index.html` 的目录，然后运行：

```bash
# 拉取 alpine 版本的 nginx（体积小，下载快）
docker pull nginx:alpine

# 启动容器，挂载自定义页面
docker run -d \
  --name my-website \
  -p 8080:80 \
  -v "$(pwd)/index.html:/usr/share/nginx/html/index.html" \
  nginx:alpine
```

解释：
- `-d`：后台运行
- `--name my-website`：取名 my-website
- `-p 8080:80`：宿主机 8080 映射到容器 80
- `-v "$(pwd)/index.html:/usr/share/nginx/html/index.html"`：把当前目录下的 `index.html` 挂载到容器内 Nginx 的网页目录
  - **Windows PowerShell 用户注意**：把 `$(pwd)` 换成 `${PWD}` 或者直接用绝对路径
  - **Windows CMD 用户注意**：把 `$(pwd)` 换成 `%cd%`

---

## 第四步：验证

```bash
# 1. 确认容器在运行
docker ps --filter "name=my-website"

# 2. 查看日志，确保 Nginx 正常启动
docker logs my-website

# 3. 用 curl 测试（任意一种方式）
curl http://localhost:8080
# 或者在浏览器打开 http://localhost:8080
```

你应该能看到自己写的 HTML 页面。

---

## 第五步：边改边看 —— 热更新

因为我们用 `-v` 挂载了文件，所以本地修改 `index.html` 后，刷新浏览器就能看到变化——不需要重启容器！

试试：
1. 打开 `index.html`，修改标题
2. 保存
3. 刷新浏览器
4. 变化立即可见

这就是 `-v` 挂载在开发时的最大价值：改代码 -> 立刻看效果，不用重新构建镜像。

---

## 第六步：进入容器看看

```bash
# 进入容器
docker exec -it my-website sh

# 看看我们挂载的文件
cat /usr/share/nginx/html/index.html

# 看看 Nginx 配置
cat /etc/nginx/nginx.conf

# 看看 Nginx 的访问日志
cat /var/log/nginx/access.log

# 退出来
exit
```

你能看到，容器里的 `/usr/share/nginx/html/index.html` 就是你本地的那个文件。你在容器里修改它，本地文件也会同步变化（反之亦然）。这是因为挂载是双向的。

---

## 第七步：清理（但要记住怎么恢复）

```bash
# 停止并删除容器
docker rm -f my-website

# 镜像留着，下次直接用
docker images nginx:alpine

# 下次想再跑起来，只需要：
docker run -d --name my-website -p 8080:80 \
  -v "$(pwd)/index.html:/usr/share/nginx/html/index.html" \
  nginx:alpine
```

你的 `index.html` 文件在本地磁盘上，不会因为删除容器而丢失。这就是 `-v` 挂载的好处。

---

## 完整启动脚本（可选）

为了方便，可以创建一个 `run.sh` 脚本（Mac/Linux/Git Bash）：

```bash
#!/bin/bash
# run.sh —— 启动自定义 Nginx 网站

# 先停掉旧的（如果存在）
docker rm -f my-website 2>/dev/null

# 启动新的
docker run -d \
  --name my-website \
  -p 8080:80 \
  -v "$(pwd)/index.html:/usr/share/nginx/html/index.html" \
  nginx:alpine

echo "网站已启动！请访问 http://localhost:8080"
echo ""
echo "查看日志: docker logs my-website"
echo "进入容器: docker exec -it my-website sh"
echo "停止网站: docker rm -f my-website"
```

---

## 动手试试 —— 你的挑战

在完成上面的步骤后，试试以下扩展练习（仍然 5 分钟内能完成）：

1. **改样式**：修改 `index.html` 中的 CSS，换一个背景色或字体颜色，刷新浏览器看效果。
2. **多页面**：创建第二个 HTML 文件（比如 `about.html`），把它也挂载到容器里。访问 `http://localhost:8080/about.html` 看能不能看到。
3. **多容器**：再启动第二个 Nginx 容器，映射到 8081 端口，挂载一个不同的 HTML 页面。

```bash
# 挑战 3 的提示：
# 先创建第二个 HTML 文件
echo "<h1>第二个网站</h1>" > index2.html

# 启动第二个容器
docker run -d --name my-website-2 -p 8081:80 \
  -v "$(pwd)/index2.html:/usr/share/nginx/html/index.html" \
  nginx:alpine
```

---

## 本节小结

这一节你完成了一个完整的 Docker 部署练习：拉取 Nginx 镜像、用 `-v` 挂载自定义页面、暴露端口、验证访问——用不到 10 分钟就把自己的网页部署到了 Docker 容器里。

---

## 模块 01 总结

祝贺你完成模块 01！你在这八章里掌握了 Docker 最核心的日常操作技能：

- 从 Docker Hub 拉取镜像（`docker pull`）
- 启动容器并掌握常用参数（`docker run -d --name -p -e -v --rm`）
- 管理容器生命周期（`docker ps / stop / start / restart / rm`）
- 进入容器调试（`docker exec -it`）
- 查看日志和诊断（`docker logs / inspect`）
- 完成了一次自定义网站部署

这些技能已经覆盖了日常 Docker 使用场景的 80%。从模块 02 开始，我们将进入更进阶的内容——编写 Dockerfile，构建你自己的镜像。

---

## 下一节预告

下一节是模块 02 的开篇——你会学习编写你的第一个 Dockerfile。拉别人做好的镜像很有用，但真正的力量在于构建你自己的镜像。就像学会做自己的蛋糕模具，而不是永远用别人做的。
