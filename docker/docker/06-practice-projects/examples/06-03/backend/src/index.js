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
