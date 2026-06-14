# 04-06 Bind Mount：把宿主机目录"塞进"容器

## 本节你会学到什么

- 理解 Bind Mount 和 Named Volume 的本质区别
- 使用绝对路径将宿主机目录挂载到容器
- 利用 Bind Mount 实现开发时的热更新
- 理解文件权限问题和常见坑

---

如果 Named Volume 是 Docker 帮你管的"外接硬盘"，那 Bind Mount 就是你自己从抽屉里翻出来的**U盘**——你完全掌控它在哪里、里面有什么文件。你直接把宿主机上的一个目录"映射"进容器里，容器里改了，宿主机上立刻能看见；你在宿主机上用编辑器改了，容器里也立刻生效。

---

## Bind Mount 的基本语法

和 Volume 一样用 `-v`，但把卷名换成**绝对路径**：

```bash
$ docker run -it --rm \
  -v /home/you/project:/app \
  alpine:latest sh
```

区分方式很简单：
- `my-volume:/data` —— 没有 `/` 开头，Docker 认作卷名
- `/home/you/project:/app` —— 以 `/` 开头，Docker 认作宿主机路径

在 Windows 上，路径长这样：

```powershell
docker run -it --rm -v C:\Users\you\project:/app alpine:latest sh
```

或者用 `/c/Users/you/project`（Git Bash / WSL 风格）。

---

## 开发时热更新：Bind Mount 的杀手锏

这才是 Bind Mount 最让人爱不释手的场景。假设你在开发一个 Node.js 项目：

```
~/my-project/
  app.js
  package.json
```

你用 Bind Mount 把本地代码目录挂进容器：

```bash
$ docker run -d --name dev-server \
  -v ~/my-project:/app \
  -p 3000:3000 \
  node:18-alpine \
  node /app/app.js
```

现在，你在宿主机上打开 VS Code 修改 `app.js`，保存，容器里运行的就是最新代码——不需要重新 build 镜像、不需要重启容器。如果你用的是 nodemon 或文件监听工具，效果更佳：

```bash
$ docker run -d --name dev-server \
  -v ~/my-project:/app \
  -p 3000:3000 \
  node:18-alpine \
  npx nodemon /app/app.js
```

文件一存，容器自动重启服务，开发体验跟本地跑没什么区别。

---

## 一个完整的例子

我们来准备一个简单的前端开发环境。宿主机上有一个 `src/` 目录，里面有一个 HTML 文件：

**examples/04-06/src/index.html**

```html
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
  <h1>Hello from Docker Bind Mount!</h1>
  <p>Edit this file on your host and refresh the browser.</p>
</body>
</html>
```

启动一个 nginx 容器，把 `src/` 挂进去：

```bash
# 在 examples/04-06/ 目录下执行
$ docker run -d --name web-dev \
  -v "$(pwd)/src:/usr/share/nginx/html" \
  -p 8080:80 \
  nginx:alpine
```

打开浏览器访问 `http://localhost:8080`，看到你的 HTML。现在用编辑器改一下 `index.html` 里的文字，刷新浏览器——立刻看到变化。这就是 Bind Mount 的魔力。

---

## Bind Mount 的注意事项

**权限问题**是最常见的坑。容器里的进程可能以 root 运行，但挂载进来的目录权限是宿主机的。如果容器内的用户（例如 node 用户）没有写权限，就会出现 Permission denied。

```bash
# 容器里以 node 用户运行，但宿主机的目录属于 root
$ docker run --user node \
  -v /root/protected-dir:/app \
  node:18-alpine sh
/ $ touch /app/test.txt
touch: /app/test.txt: Permission denied
```

解决方案：确保宿主机目录的权限和容器内用户匹配，或者在启动时用 `--user` 调整用户。

**路径必须是绝对路径**：忘了用 `pwd` 或 `$(pwd)` 会导致 Docker 以为你在说卷名而不是路径。

**Bind Mount 会掩盖容器内原有内容**：如果容器里 `/app` 原来有文件，挂载后这些文件会被"遮住"。这有点像放了一张海报盖住了墙上的洞。

---

## Named Volume vs Bind Mount 对比

| 方面         | Named Volume                | Bind Mount                     |
| ------------ | --------------------------- | ----------------------------- |
| 谁管理       | Docker                      | 你                              |
| 存储位置     | `/var/lib/docker/volumes/`  | 你指定的任意路径                 |
| 适合场景     | 生产数据库、持久化数据       | 开发热更新、配置文件、共享代码   |
| 可移植性     | 好，Docker 命令即可迁移      | 差，依赖宿主机目录结构           |
| 容器间共享   | 方便                        | 方便，但要注意并发写冲突         |

---

## 动手试试

1. 在本地创建一个目录，里面放一个简单的 `index.html`
2. 用 Bind Mount 启动一个 nginx 容器，把该目录挂载到 `/usr/share/nginx/html`
3. 浏览器访问确认页面能打开
4. 修改 `index.html` 内容，刷新浏览器，确认热更新生效
5. （可选）尝试用 `docker exec` 进入容器，在挂载目录创建一个文件，回到宿主机看看文件是否出现

---

## 本节小结

Bind Mount 让你直接操作宿主机目录，开发时改代码秒级同步进容器，就像一个"虫洞"连接了两个世界。

---

## 下一节预告

Volumes 和 Bind Mount 都把数据写在磁盘上。但有时候你宁愿数据只存在内存里——比如临时缓存、密码令牌，哪怕容器重启丢了也无所谓。这就是 tmpfs 的用武之地。
