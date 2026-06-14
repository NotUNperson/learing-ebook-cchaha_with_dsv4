# 06-03 实战三：全栈项目容器化（React + Express + PostgreSQL + Redis）

## 本节你会学到什么

- 用 docker-compose 编排四个微服务：前端、后端、数据库、缓存
- 设计合理的网络拓扑：前端暴露，后端和数据库内网隔离
- 使用卷（volume）持久化数据库数据，重启容器数据不丢
- 配置健康检查，让 Docker 知道服务什么时候真正就绪
- 理解 docker-compose 的 `depends_on` 为什么不能保证服务就绪，以及如何补救

---

想象你在开一家餐厅。餐厅有四个岗位：

- **大堂服务员（React 前端）**：直接面对顾客，接单、上菜
- **厨师（Express 后端）**：处理订单逻辑，做菜
- **冰箱（PostgreSQL）**：存放食材原料的持久库
- **出餐台（Redis）**：暂存做好的菜品，快速取餐

这四个岗位需要不同的"空间"（容器），但他们之间必须能通信。服务员不需要直接开冰箱——她告诉厨师要什么菜，厨师去冰箱取。同样，客人不能直接跑到后厨——他们只能通过大堂服务员点单。

把这种关系映射到 Docker 网络：
- 前端服务对外暴露（映射端口到宿主机）
- 后端、数据库、Redis 在内网通信
- PostgreSQL 的数据目录挂载到宿主机卷，保证数据持久化

---

## 1. 项目结构

```
06-03/
  docker-compose.yml
  frontend/
    Dockerfile
    nginx.conf
    package.json
    src/
      App.jsx
      index.jsx
      ...
  backend/
    Dockerfile
    package.json
    src/
      index.js
  db/
    init.sql
```

## 2. 后端：Express API

**backend/Dockerfile**

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine
WORKDIR /app
RUN addgroup -S appuser && adduser -S appuser -G appuser
COPY --from=builder /app/node_modules ./node_modules
COPY --chown=appuser:appuser . .
USER appuser
EXPOSE 3001
CMD ["node", "src/index.js"]
```

**backend/package.json**

```json
{
  "name": "fullstack-api",
  "version": "1.0.0",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.3",
    "redis": "^4.6.10",
    "cors": "^2.8.5"
  }
}
```

**backend/src/index.js**

```javascript
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const { createClient } = require('redis');

const app = express();
app.use(cors());
app.use(express.json());

// ---- PostgreSQL 连接 ----
const pgPool = new Pool({
  host: process.env.DB_HOST || 'db',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'appuser',
  password: process.env.DB_PASSWORD || 'apppassword',
  database: process.env.DB_NAME || 'appdb',
});

// ---- Redis 连接 ----
const redisClient = createClient({
  url: `redis://${process.env.REDIS_HOST || 'redis'}:6379`,
});
redisClient.connect().catch(console.error);

// ---- 路由 ----
app.get('/api/health', async (req, res) => {
  try {
    await pgPool.query('SELECT 1');
    await redisClient.ping();
    res.json({ status: 'ok', db: 'connected', redis: 'connected' });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// 带 Redis 缓存的列表查询
app.get('/api/items', async (req, res) => {
  const cacheKey = 'items:list';

  try {
    // 先查缓存
    const cached = await redisClient.get(cacheKey);
    if (cached) {
      return res.json({ source: 'redis', data: JSON.parse(cached) });
    }

    // 缓存未命中，查数据库
    const result = await pgPool.query(
      'SELECT id, title, created_at FROM items ORDER BY created_at DESC LIMIT 50'
    );

    // 写入缓存，过期时间 30 秒
    await redisClient.setEx(cacheKey, 30, JSON.stringify(result.rows));

    res.json({ source: 'postgresql', data: result.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 新增数据，同时清缓存
app.post('/api/items', async (req, res) => {
  const { title } = req.body;
  if (!title) {
    return res.status(400).json({ error: 'title is required' });
  }

  try {
    const result = await pgPool.query(
      'INSERT INTO items (title) VALUES ($1) RETURNING id, title, created_at',
      [title]
    );
    // 数据变了，清掉旧缓存
    await redisClient.del('items:list');
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`API server running on port ${PORT}`);
});
```

后端的核心设计是**缓存透传模式**：请求来了先问 Redis，有就直接返回（快速通道）；没有就查 PostgreSQL，查完后顺手写进 Redis（给下一个请求铺好路）。

## 3. 数据库初始化

**db/init.sql**

```sql
-- 这个文件在 PostgreSQL 容器首次启动时自动执行
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 插入一些示例数据
INSERT INTO items (title) VALUES
    ('Learn Docker'),
    ('Build a REST API'),
    ('Deploy to production');
```

PostgreSQL 官方镜像有一个很棒的特性：如果挂载目录 `docker-entrypoint-initdb.d/` 下有 `.sql` 或 `.sh` 文件，它会在数据库首次初始化时自动执行。这是数据库初始化的最佳实践——不需要在应用代码里写 `CREATE TABLE`，也不需要手动连进去执行 SQL。

## 4. 前端：React + Nginx

**frontend/Dockerfile**

```dockerfile
# ========== 构建阶段：React 编译 ==========
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci && npm cache clean --force
COPY . .
RUN npm run build

# ========== 运行阶段：Nginx 静态服务 ==========
FROM nginx:alpine
# 把 React 构建产物放到 Nginx 的静态文件目录
COPY --from=builder /app/dist /usr/share/nginx/html
# 使用自定义 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

注意：React 前端镜像的最终大小只有大约 25MB（Nginx Alpine + 编译好的静态文件），因为构建工具、node_modules 统统留在了第一阶段。

**frontend/nginx.conf**

```nginx
server {
    listen 80;
    server_name localhost;

    # 静态文件
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;  # SPA 路由回退
    }

    # API 代理到后端
    location /api/ {
        proxy_pass http://backend:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

这里有一个关键设计：**前端不直接连后端**，而是通过 Nginx 反向代理。浏览器发请求到 Nginx（同域名、同端口），Nginx 根据路径转发：
- `/` 返回静态文件
- `/api/*` 转发到后端容器

这样做的好处是**前后端同源**，不会有 CORS 问题，而且只需要暴露一个端口。

**frontend/package.json**（简化版）

```json
{
  "name": "fullstack-frontend",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.0",
    "vite": "^5.0.0"
  }
}
```

**frontend/src/App.jsx**

```jsx
import { useState, useEffect } from 'react';

function App() {
  const [items, setItems] = useState([]);
  const [source, setSource] = useState('');
  const [title, setTitle] = useState('');
  const [health, setHealth] = useState(null);

  const fetchItems = async () => {
    const res = await fetch('/api/items');
    const json = await res.json();
    setItems(json.data || []);
    setSource(json.source || '');
  };

  const addItem = async () => {
    if (!title.trim()) return;
    await fetch('/api/items', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title }),
    });
    setTitle('');
    fetchItems();
  };

  const checkHealth = async () => {
    try {
      const res = await fetch('/api/health');
      const json = await res.json();
      setHealth(json);
    } catch (err) {
      setHealth({ status: 'error', message: err.message });
    }
  };

  useEffect(() => {
    fetchItems();
    checkHealth();
  }, []);

  return (
    <div style={{ maxWidth: 600, margin: '40px auto', fontFamily: 'sans-serif' }}>
      <h1>Docker Fullstack Demo</h1>

      <div style={{ marginBottom: 20 }}>
        <h3>System Health</h3>
        <pre>{JSON.stringify(health, null, 2)}</pre>
      </div>

      <div style={{ marginBottom: 20 }}>
        <h3>Add Item</h3>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && addItem()}
          placeholder="Enter item title..."
          style={{ padding: 8, width: 200, marginRight: 8 }}
        />
        <button onClick={addItem} style={{ padding: 8 }}>
          Add
        </button>
      </div>

      <div>
        <h3>Items (source: {source})</h3>
        <ul>
          {items.map((item) => (
            <li key={item.id}>
              {item.title} <small>({new Date(item.created_at).toLocaleString()})</small>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default App;
```

## 5. docker-compose.yml：编排所有服务

```yaml
version: "3.9"

services:
  # ===================== 数据库 =====================
  db:
    image: postgres:16-alpine
    container_name: fullstack-db
    environment:
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppassword
      POSTGRES_DB: appdb
    volumes:
      # 持久化数据：即使容器被删除，数据还在
      - pgdata:/var/lib/postgresql/data
      # 数据库初始化脚本
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - backend-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
      interval: 5s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  # ===================== 缓存 =====================
  redis:
    image: redis:7-alpine
    container_name: fullstack-redis
    volumes:
      - redisdata:/data
    networks:
      - backend-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    restart: unless-stopped

  # ===================== API 后端 =====================
  backend:
    build: ./backend
    container_name: fullstack-backend
    environment:
      DB_HOST: db
      DB_USER: appuser
      DB_PASSWORD: apppassword
      DB_NAME: appdb
      REDIS_HOST: redis
      PORT: 3001
    networks:
      - backend-net
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped

  # ===================== 前端（对外暴露） =====================
  frontend:
    build: ./frontend
    container_name: fullstack-frontend
    ports:
      - "8080:80"
    networks:
      - backend-net
    depends_on:
      - backend
    restart: unless-stopped

# ===================== 卷 =====================
volumes:
  pgdata:
  redisdata:

# ===================== 网络 =====================
networks:
  backend-net:
    driver: bridge
```

这个 compose 文件里藏着好几个重要的设计决策，逐一说明：

**网络隔离：** 所有服务加入同一个 `backend-net`，但只有前端映射了端口到宿主机（`8080:80`）。后端、数据库、Redis 对外部世界是不可见的，只能被同一网络内的服务访问。就像餐厅的后厨——客人看不到，但服务员可以去。

**`depends_on` 配合 `condition: service_healthy`：** 早期 Docker Compose 的 `depends_on` 只保证容器**启动了**，不保证服务**就绪了**。PostgreSQL 容器启动后，可能还需要几秒才能接受连接。如果你的后端在这几秒内就连数据库，会直接报错退出。

从 Compose v3 开始，`condition: service_healthy` 解决了这个问题——它会等待健康检查通过，才认为依赖的服务真正就绪。

**卷持久化：** `pgdata` 和 `redisdata` 是命名卷（named volume），由 Docker 管理，不绑定到宿主机特定路径。这样数据库文件和 Redis dump 在容器重启甚至删除重建后依然保留。

## 6. 启动项目

```bash
# 进入项目目录
cd examples/06-03/

# 构建并启动所有服务
docker-compose up --build

# 后台运行
docker-compose up --build -d

# 查看所有服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 验证
curl http://localhost:8080/api/health
# 浏览器打开 http://localhost:8080
```

等待几秒钟让数据库初始化完成（PostgreSQL 需要一些时间执行 init.sql），然后打开浏览器访问 `http://localhost:8080`，你应该能看到：
- 系统健康状态面板
- 三条预置的示例数据
- 可以添加新的 item

每次添加 item，观察数据来源是 `redis` 还是 `postgresql`：第一次查数据库，30 秒内再查就走缓存。

## 7. 常用运维命令

```bash
# 只重启后端
docker-compose restart backend

# 重建单个服务
docker-compose up --build -d backend

# 查看特定服务的日志
docker-compose logs -f backend

# 进入数据库命令行
docker-compose exec db psql -U appuser -d appdb
# 然后可以 SELECT * FROM items;

# 进入 Redis 命令行
docker-compose exec redis redis-cli
# 然后可以 KEYS *

# 停止并清理（保留数据卷）
docker-compose down

# 停止并删除数据卷（彻底清理）
docker-compose down -v
```

---

## 动手试试

**目标：** 启动全栈应用，验证缓存机制，体验数据持久化。

1. 在 `examples/06-03/` 下执行 `docker-compose up --build`
2. 浏览器打开 `http://localhost:8080`，记下三条初始数据
3. 通过界面添加一条新数据，观察响应中的 `source` 字段
4. 执行 `docker-compose down`，再执行 `docker-compose up -d`
5. 再次打开 `http://localhost:8080`，确认数据还在（卷持久化生效）
6. 执行 `docker-compose exec redis redis-cli KEYS '*'`，看看 Redis 里有哪些 key

预计耗时：5 分钟。

---

## 本节小结

docker-compose 把四个独立服务拧成一股绳：前端 Nginx 反向代理、后端 Express API、PostgreSQL + Redis 双存储、健康检查保证启动顺序、命名卷保障数据安全——这套组合拳就是你以后做任何多容器项目的"标准起手式"。

## 下一节预告

应用跑起来了，但它安全吗？下一节我们专门聊 Docker 安全：为什么不该用 root 跑容器、怎么扫描镜像漏洞、什么是只读文件系统——用"房子安全"的类比，让你轻松记住所有安全措施。
