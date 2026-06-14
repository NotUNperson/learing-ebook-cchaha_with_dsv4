/**
 * 简单的 HTTP 后端服务
 * 用于验证 Nginx 反向代理的 proxy_pass 路径替换行为
 *
 * 启动方式：node app.js
 * 监听端口：3000
 */

const http = require('http');

const PORT = 3000;

const server = http.createServer((req, res) => {
    // 在控制台打印收到的请求信息
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);

    // 收集请求体（如果有的话）
    let body = '';
    req.on('data', chunk => {
        body += chunk.toString();
    });

    req.on('end', () => {
        // 返回 JSON 格式的请求摘要
        res.writeHead(200, {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Backend-Server': 'Node.js Demo Server'
        });

        const response = {
            message: '后端服务运行正常',
            backend: {
                server: 'Node.js',
                port: PORT
            },
            request: {
                method: req.method,
                url: req.url,
                headers: {
                    host: req.headers.host,
                    'user-agent': req.headers['user-agent'],
                    'x-forwarded-for': req.headers['x-forwarded-for'] || '（未设置）',
                    'x-real-ip': req.headers['x-real-ip'] || '（未设置）'
                },
                body: body || '（空）'
            },
            timestamp: new Date().toISOString()
        };

        res.end(JSON.stringify(response, null, 2));
    });
});

server.listen(PORT, () => {
    console.log(`后端服务已启动：http://localhost:${PORT}`);
    console.log('可以直接访问测试，也可以通过 Nginx 反向代理访问');
    console.log('按 Ctrl+C 停止服务\n');
});
