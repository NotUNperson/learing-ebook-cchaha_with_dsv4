# 05-09 综合练习：用 Compose 编排全栈项目

## 本节你会学到什么

- 用 Compose 编排 React 前端 + Node.js API + PostgreSQL 三个服务
- 为每个服务编写恰当的 Dockerfile
- 配置网络隔离、数据持久化、环境变量
- 在 5 分钟内把一个完整的全栈应用跑起来

---

模块五的最后一节，我们要来真的了。你将在本地跑起一个完整的三层架构：

```
浏览器 (localhost:3000)
        |
   +----+----+
   |  React   |  前端 (Nginx 静态服务)
   |  :80     |
   +----+----+
        |
   api-network
        |
   +----+----+
   |  Node.js |  API 服务 (Express)
   |  :4000   |
   +----+----+
        |
   db-network
        |
   +----+----+
   |PostgreSQL|  数据库
   |  :5432   |
   +----+----+
        |
   pgdata (Named Volume)
```

项目结构：

```
examples/05-09/
  docker-compose.yml
  frontend/
    Dockerfile
    nginx.conf
    src/
      index.html
      App.js
  backend/
    Dockerfile
    package.json
    src/
      server.js
  database/
    init.sql
```

---

## 先看整体：docker-compose.yml

**examples/05-09/docker-compose.yml**

```yaml
services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:80"
    networks:
      - api-network
    depends_on:
      - backend

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "4000:4000"
    networks:
      - api-network
      - db-network
    environment:
      DB_HOST: db
      DB_PORT: "5432"
      DB_USER: appuser
      DB_PASSWORD: apppass
      DB_NAME: todoapp
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:15-alpine
    networks:
      - db-network
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    environment:
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppass
      POSTGRES_DB: todoapp
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d todoapp"]
      interval: 5s
      timeout: 5s
      retries: 5

networks:
  api-network:
  db-network:

volumes:
  pgdata:
```

仔细看几个亮点：

1. **网络分层**：前端只能通过 `api-network` 访问后端，后端通过 `db-network` 访问数据库。前端和数据库之间没有直接通道。
2. **healthcheck**：数据库容器定义了健康检查。`depends_on` 中的 `condition: service_healthy` 确保后端只有在数据库真正 ready 后才启动——这是 Compose v2 才有的功能。
3. **初始化脚本**：`database/init.sql` 通过 Bind Mount 挂到 PostgreSQL 的初始化目录，容器启动时自动执行。

---

## Frontend：React 前端

这里用一个极简的纯 HTML/JS 页面（不需要 React 构建工具链，降低门槛），通过 Nginx 提供静态服务。

**examples/05-09/frontend/Dockerfile**

```dockerfile
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY src/ /usr/share/nginx/html
```

**examples/05-09/frontend/nginx.conf**

```
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://backend:4000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Nginx 配置里用到了 `backend:4000`——这是 Compose 的 DNS 解析，前端容器可以通过服务名直接找到后端。

**examples/05-09/frontend/src/index.html**

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Docker 全栈示例 — 待办事项</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container">
    <h1>待办事项</h1>
    <div class="input-group">
      <input type="text" id="todo-input" placeholder="输入新任务..." />
      <button onclick="addTodo()">添加</button>
    </div>
    <ul id="todo-list"></ul>
    <p class="status">状态: <span id="status-text">就绪</span></p>
  </div>
  <script src="App.js"></script>
</body>
</html>
```

**examples/05-09/frontend/src/style.css**

```css
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Segoe UI', sans-serif; background: #f0f2f5; display: flex; justify-content: center; padding-top: 60px; }
.container { background: white; border-radius: 12px; padding: 32px; width: 480px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
h1 { margin-bottom: 20px; color: #1a1a2e; }
.input-group { display: flex; gap: 8px; margin-bottom: 20px; }
#todo-input { flex: 1; padding: 10px 14px; border: 1px solid #d0d5dd; border-radius: 8px; font-size: 15px; outline: none; }
#todo-input:focus { border-color: #4f46e5; }
button { padding: 10px 20px; background: #4f46e5; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 15px; }
button:hover { background: #4338ca; }
#todo-list { list-style: none; margin-bottom: 20px; }
#todo-list li { padding: 10px 14px; border-bottom: 1px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center; }
#todo-list li.completed span { text-decoration: line-through; color: #9ca3af; }
.status { font-size: 13px; color: #6b7280; }
```

**examples/05-09/frontend/src/App.js**

```javascript
const API_BASE = '/api';

async function loadTodos() {
  const res = await fetch(`${API_BASE}/todos`);
  const todos = await res.json();
  const list = document.getElementById('todo-list');
  list.innerHTML = '';
  todos.forEach(todo => {
    const li = document.createElement('li');
    if (todo.completed) li.className = 'completed';
    li.innerHTML = `
      <span onclick="toggleTodo(${todo.id}, ${!todo.completed})">${todo.title}</span>
      <button onclick="deleteTodo(${todo.id})" style="background:#ef4444;padding:4px 10px;font-size:12px;">删除</button>
    `;
    list.appendChild(li);
  });
}

async function addTodo() {
  const input = document.getElementById('todo-input');
  const title = input.value.trim();
  if (!title) return;
  await fetch(`${API_BASE}/todos`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title })
  });
  input.value = '';
  loadTodos();
}

async function toggleTodo(id, completed) {
  await fetch(`${API_BASE}/todos/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ completed })
  });
  loadTodos();
}

async function deleteTodo(id) {
  await fetch(`${API_BASE}/todos/${id}`, { method: 'DELETE' });
  loadTodos();
}

async function checkHealth() {
  try {
    const res = await fetch('/api/health');
    const data = await res.json();
    document.getElementById('status-text').textContent =
      `API ${data.status} | DB ${data.db}`;
  } catch (e) {
    document.getElementById('status-text').textContent = 'API 离线';
  }
}

document.getElementById('todo-input').addEventListener('keypress', (e) => {
  if (e.key === 'Enter') addTodo();
});

loadTodos();
checkHealth();
setInterval(checkHealth, 10000);
```

---

## Backend：Node.js API

**examples/05-09/backend/Dockerfile**

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 4000
CMD ["node", "src/server.js"]
```

**examples/05-09/backend/package.json**

```json
{
  "name": "todo-backend",
  "version": "1.0.0",
  "description": "Todo API with Express and PostgreSQL",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.3",
    "cors": "^2.8.5"
  }
}
```

**examples/05-09/backend/src/server.js**

```javascript
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || 'db',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'appuser',
  password: process.env.DB_PASSWORD || 'apppass',
  database: process.env.DB_NAME || 'todoapp',
});

// 健康检查
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', db: 'connected' });
  } catch (e) {
    res.status(500).json({ status: 'error', db: 'disconnected' });
  }
});

// 获取所有待办
app.get('/todos', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM todos ORDER BY id DESC'
    );
    res.json(result.rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 创建待办
app.post('/todos', async (req, res) => {
  const { title } = req.body;
  if (!title) return res.status(400).json({ error: 'title is required' });
  try {
    const result = await pool.query(
      'INSERT INTO todos (title) VALUES ($1) RETURNING *',
      [title]
    );
    res.status(201).json(result.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 更新待办
app.put('/todos/:id', async (req, res) => {
  const { id } = req.params;
  const { completed } = req.body;
  try {
    const result = await pool.query(
      'UPDATE todos SET completed = $1 WHERE id = $2 RETURNING *',
      [completed, id]
    );
    if (result.rows.length === 0)
      return res.status(404).json({ error: 'not found' });
    res.json(result.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 删除待办
app.delete('/todos/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM todos WHERE id = $1', [id]);
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

const PORT = 4000;
app.listen(PORT, () => {
  console.log(`Backend API running on port ${PORT}`);
});
```

---

## Database：初始化脚本

**examples/05-09/database/init.sql**

```sql
CREATE TABLE IF NOT EXISTS todos (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO todos (title, completed) VALUES
  ('学习 Docker Compose', false),
  ('搭建全栈项目', false),
  ('部署到生产环境', false);
```

---

## 一键启动

一切就绪，在 `examples/05-09/` 目录下：

```bash
$ docker compose up -d
[+] Running 4/4
 Network 05-09_db-network    Created
 Network 05-09_api-network   Created
 Container 05-09-db-1        Healthy
 Container 05-09-backend-1   Started
 Container 05-09-frontend-1  Started
```

打开浏览器，访问 `http://localhost:3000`，你应该看到：

- 一个待办事项列表
- 输入框可以添加新任务
- 点击任务可以切换完成状态
- 删除按钮可以删除任务
- 底部状态栏显示 API 和数据库连接状态

---

## 验证全链路

```bash
# 查看所有服务状态
$ docker compose ps

# 直接调用 API
$ curl http://localhost:4000/todos
[{"id":3,"title":"部署到生产环境","completed":false,...}]

# 查看数据库
$ docker compose exec db psql -U appuser -d todoapp -c "SELECT * FROM todos;"

# 查看日志
$ docker compose logs -f
```

---

## 验证数据持久化

```bash
# 全部停掉
$ docker compose down

# 卷还在
$ docker volume ls | grep pgdata
local     05-09_pgdata

# 重启
$ docker compose up -d

# 浏览器打开——数据都还在
```

---

## 动手试试

1. 把 `examples/05-09/` 下的所有文件复制到你的工作目录
2. 运行 `docker compose up -d`
3. 访问 `http://localhost:3000`，添加几条待办
4. 运行 `docker compose down` 再 `docker compose up -d`，检查数据是否持久化
5. （挑战）给前端加一个"编辑待办标题"的功能，需要修改 App.js 和后端 server.js。用 `docker compose up -d --build` 重新构建并启动

---

## 本节小结

一个 `docker-compose.yml` 文件编排了前端、后端、数据库三个服务，配合各自的 Dockerfile 和初始化脚本，5 分钟内跑起完整的全栈应用——这就是 Compose 的力量。

---

## 下一节预告

恭喜你完成了 Docker Compose 模块的全部内容！接下来你可以进入模块六——实战项目演练，把学到的知识用到更真实的场景中。也可以回头翻翻之前的章节，巩固基础。
