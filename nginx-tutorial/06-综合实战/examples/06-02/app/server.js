// Nginx 反向代理示例 - Node.js 后端应用
// 配合 06-02-反向代理Node应用.md 使用
//
// 这个应用模拟了一个简单的 Web 服务：
//   - 首页：HTML 页面
//   - /api/info：JSON API 接口
//   - /api/hello：带参数查询的 API

const http = require('http');
const url = require('url');

const PORT = 3000;
const HOST = '127.0.0.1';

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const pathname = parsedUrl.pathname;

    // 设置通用响应头
    res.setHeader('X-Powered-By', 'Node.js');
    res.setHeader('X-Backend-Port', PORT.toString());

    if (pathname === '/' || pathname === '/index.html') {
        // 首页 HTML
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(`<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>Node.js 应用 - Nginx 反向代理</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <div class="container">
        <h1>Node.js 应用</h1>
        <p class="info">这个页面由 Node.js 后端（端口 ${PORT}）渲染，通过 Nginx 代理到前端。</p>
        <div class="card">
            <h2>API 测试</h2>
            <button onclick="fetch('/api/info').then(r=>r.json()).then(d=>{document.getElementById('result').textContent=JSON.stringify(d,null,2)})">GET /api/info</button>
            <button onclick="fetch('/api/hello?name=World').then(r=>r.json()).then(d=>{document.getElementById('result').textContent=JSON.stringify(d,null,2)})">GET /api/hello?name=World</button>
            <pre id="result">点击按钮调用 API...</pre>
        </div>
        <div class="card">
            <h2>请求头信息</h2>
            <pre>X-Forwarded-For: ${req.headers['x-forwarded-for'] || '(Nginx 未设置)'}
Host: ${req.headers['host']}
X-Real-IP: ${req.headers['x-real-ip'] || '(Nginx 未设置)'}
Connection: ${req.headers['connection']}</pre>
            <p class="note">如果看到 X-Forwarded-For 和 X-Real-IP 有值，说明 Nginx 正确设置了代理头。</p>
        </div>
    </div>
</body>
</html>`);

    } else if (pathname === '/api/info') {
        // API: 返回服务器信息
        res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
        res.end(JSON.stringify({
            status: 'ok',
            backend: `Node.js on port ${PORT}`,
            time: new Date().toISOString(),
            nodeVersion: process.version,
            uptime: Math.floor(process.uptime()),
            memoryUsage: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + 'MB'
        }));

    } else if (pathname === '/api/hello') {
        // API: 带参数的查询
        const name = parsedUrl.query.name || 'Stranger';
        res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
        res.end(JSON.stringify({
            greeting: `Hello, ${name}!`,
            from: `Backend port ${PORT}`,
            time: new Date().toISOString()
        }));

    } else {
        // 404
        res.writeHead(404, { 'Content-Type': 'application/json; charset=utf-8' });
        res.end(JSON.stringify({ error: 'Not Found', path: pathname }));
    }
});

server.listen(PORT, HOST, () => {
    console.log(`[Node.js] 后端服务已启动: http://${HOST}:${PORT}`);
    console.log(`[Node.js] 预期前面会有 Nginx 反向代理监听 80 端口`);
    console.log(`[Node.js] Nginx 会处理 /static/ 路径，其他请求代理到本后端`);
});
