// 负载均衡集群实战 - 后端 Node.js 服务
// 配合 06-03-负载均衡集群实战.md 使用
//
// 这个文件会被 3 个进程分别以不同端口启动
// 启动方式：PORT=3001 node server.js
//           PORT=3002 node server.js
//           PORT=3003 node server.js

const http = require('http');
const url = require('url');
const os = require('os');

const PORT = process.env.PORT || 3001;
const INSTANCE_ID = process.env.INSTANCE_ID || `worker-${PORT}`;
const HOST = '127.0.0.1';

// 记录请求计数（演示粘性会话时能看到请求去了哪个实例）
let requestCount = 0;

const server = http.createServer((req, res) => {
    requestCount++;
    const parsedUrl = url.parse(req.url, true);
    const pathname = parsedUrl.pathname;

    // 模拟偶尔的慢响应（用于演示健康检查和故障转移）
    if (pathname === '/slow') {
        setTimeout(() => {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                instance: INSTANCE_ID,
                port: PORT,
                message: 'This response was deliberately slow (2 seconds)',
                time: new Date().toISOString()
            }));
        }, 2000);
        return;
    }

    // 模拟故障（用于演示健康检查自动摘除）
    if (pathname === '/crash') {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            instance: INSTANCE_ID,
            port: PORT,
            error: 'Simulated internal error',
            time: new Date().toISOString()
        }));
        return;
    }

    // 健康检查端点
    if (pathname === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            status: 'ok',
            instance: INSTANCE_ID,
            port: PORT,
            uptime: Math.floor(process.uptime()),
            requestCount: requestCount
        }));
        return;
    }

    // 所有其他请求：返回实例信息
    res.writeHead(200, {
        'Content-Type': 'text/html; charset=utf-8',
        'X-Instance': INSTANCE_ID,
        'X-Backend-Port': PORT.toString()
    });
    res.end(`<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>负载均衡集群 - ${INSTANCE_ID}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: "Microsoft YaHei", sans-serif; background: linear-gradient(135deg, #43cea2, #185a9d); min-height: 100vh; display: flex; justify-content: center; align-items: center; }
        .card { background: #fff; border-radius: 12px; box-shadow: 0 15px 40px rgba(0,0,0,0.2); padding: 50px; text-align: center; max-width: 500px; }
        h1 { color: #333; font-size: 2em; margin-bottom: 10px; }
        .instance-id { font-size: 3em; color: #185a9d; font-weight: bold; margin: 20px 0; font-family: "Courier New", monospace; }
        .info { color: #888; line-height: 2; }
        .info span { color: #43cea2; font-weight: bold; }
        .badge { display: inline-block; background: #e8f5e9; color: #2e7d32; padding: 5px 15px; border-radius: 20px; margin: 10px 5px; font-size: 0.9em; }
        button { background: #185a9d; color: #fff; border: none; padding: 12px 25px; margin: 10px; border-radius: 6px; cursor: pointer; font-size: 1em; }
        button:hover { background: #0d47a1; }
    </style>
</head>
<body>
    <div class="card">
        <h1>负载均衡集群演示</h1>
        <div class="instance-id">${INSTANCE_ID}</div>
        <div class="info">
            <p>后端端口: <span>${PORT}</span></p>
            <p>本实例处理请求数: <span>${requestCount}</span></p>
            <p>主机名: <span>${os.hostname()}</span></p>
            <p>运行时间: <span>${Math.floor(process.uptime())} 秒</span></p>
        </div>
        <p>每次刷新页面，Nginx 会轮流转发到不同的后端实例。</p>
        <p>观察上面的 "Instance ID" 和 "后端端口" 来判断请求被路由到了哪个实例。</p>
        <div>
            <span class="badge">least_conn 算法</span>
            <span class="badge">3 个实例</span>
            <span class="badge">健康检查</span>
        </div>
        <div style="margin-top:20px">
            <button onclick="location.href='/slow'">测试慢响应</button>
            <button onclick="location.href='/crash'">模拟故障 (500)</button>
            <button onclick="location.href='/health'">健康检查</button>
        </div>
    </div>
</body>
</html>`);
});

server.listen(PORT, HOST, () => {
    console.log(`[${INSTANCE_ID}] 后端服务启动: http://${HOST}:${PORT}`);
});
