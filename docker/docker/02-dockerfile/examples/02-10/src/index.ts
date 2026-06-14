import express, { Request, Response } from 'express';

const app = express();
const port = process.env.APP_PORT || 3000;

// JSON 解析中间件
app.use(express.json());

// 健康检查接口
app.get('/health', (_req: Request, res: Response) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// API 接口
app.get('/api/hello', (_req: Request, res: Response) => {
  res.json({
    message: 'Hello, Docker!',
    version: '1.0.0',
    nodeVersion: process.version,
    env: process.env.NODE_ENV || 'development',
  });
});

// 404 处理
app.use((_req: Request, res: Response) => {
  res.status(404).json({ error: 'Not Found' });
});

// 启动服务器
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

// 优雅退出
process.on('SIGTERM', () => {
  console.log('Received SIGTERM, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('Received SIGINT, shutting down gracefully...');
  process.exit(0);
});
