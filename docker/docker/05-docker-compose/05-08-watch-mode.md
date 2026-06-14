# 05-08 开发模式：Compose Watch

## 本节你会学到什么

- 理解 Compose Watch 解决的问题：代码改动后自动同步到容器
- 掌握 `watch` 配置的三种模式：sync、rebuild、sync+restart
- 对比 Watch 模式和传统 Bind Mount 方案的优劣
- 实际配置一个带热重载的开发环境

---

在模块四的 04-06 节我们用了 Bind Mount 做热更新：改宿主机文件，容器里立刻生效。那当时你可能满脑子问号：为什么 Compose 不直接用 Bind Mount 呢？

答案是：**能用，但不完美**。

---

## Bind Mount 的三个痛处

1. **性能问题**：在 macOS 和 Windows 上，Bind Mount 的文件同步性能差得让人抓狂。大型项目（成千上万文件）用 Bind Mount，`npm install` 能慢到怀疑人生。
2. **权限问题**：容器里创建的文件，在宿主机上可能属于 root，普通用户改不了。
3. **生命周期问题**：Bind Mount 是一开始就挂载上去的，无法在运行中动态添加或移除。

**Compose Watch**（Docker Compose v2.22+ 的新功能）就是为了解决这些痛点设计的。

---

## Watch 怎么工作

Compose Watch 在容器外监听文件变化，然后根据你的配置决定怎么做。它有三种触发动作：

| 动作          | 含义                                           | 类比                 |
| ------------- | ---------------------------------------------- | -------------------- |
| `sync`        | 把改动的文件拷贝进容器（不重建容器）             | 快递员把新文件送进房间 |
| `rebuild`     | 重新构建镜像并重建容器                           | 房间重新装修          |
| `sync+restart` | 先 sync 文件进去，再重启容器进程                | 换了家具，重启一下电源 |

---

## 一个 Node.js 的例子

假设你在开发一个 Express 应用：

**examples/05-08/docker-compose.yml**

```yaml
services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    develop:
      watch:
        - action: sync
          path: ./src               # 监听 src/ 目录
          target: /app/src          # 目标容器内路径
        - action: sync
          path: ./public
          target: /app/public
        - action: rebuild
          path: ./package.json      # package.json 变了就重建
        - action: rebuild
          path: ./Dockerfile        # Dockerfile 变了也重建
```

**examples/05-08/Dockerfile**

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "--watch", "server.js"]
```

**examples/05-08/src/server.js**

```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ message: 'Hello from Docker Compose Watch!', time: new Date().toISOString() });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

**examples/05-08/package.json**

```json
{
  "name": "compose-watch-demo",
  "version": "1.0.0",
  "description": "Demo for Docker Compose Watch mode",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "node --watch src/server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

启动方式——注意用的是 `up` 加 `--watch`：

```bash
$ docker compose up --watch
```

现在你修改 `src/server.js`，在 `/` 路由里加一行，保存——Watch 自动把文件 sync 进容器，Node.js 的 `--watch` 参数自动重启进程。浏览器刷新，变化即刻可见。

如果你改了 `package.json`（新增了依赖），Watch 会触发 `rebuild`，自动重新构建镜像。

---

## Watch vs Bind Mount：怎么选？

| 场景               | 推荐方案        | 理由                              |
| ------------------ | ------------- | --------------------------------- |
| 代码热更新          | Watch sync    | 跨平台性能好，无权限问题            |
| 依赖变更           | Watch rebuild | 自动重建，不需要手动干预            |
| 静态配置文件        | Watch sync    | 简单直接                          |
| 需要双向同步        | Bind Mount    | Watch 是单向的（宿主机 -> 容器）     |
| 旧版 Docker        | Bind Mount    | Watch 需要 Compose v2.22+         |

---

## 动手试试

1. 把上面的 `docker-compose.yml`、`Dockerfile`、`src/server.js`、`package.json` 复制到本地
2. 运行 `docker compose up --watch`
3. 修改 `src/server.js` 中返回的 message 文字，保存，观察容器日志（Node.js `--watch` 会自动重启）
4. 浏览器访问 `http://localhost:3000`，确认变化
5. 试试修改 `package.json`，观察 Watch 是否触发 rebuild

---

## 本节小结

Compose Watch 是比 Bind Mount 更优雅的代码热同步方案，sync 用于代码文件，rebuild 用于依赖和构建配置变更。

---

## 下一节预告

最后一节！我们不做单项练习了，而是用 Compose 编排一个完整的前后端项目：React 前端 + Node.js API + PostgreSQL 数据库。检验你整个模块的学习成果。
