// HTTPS 全栈部署 - 后端 Node.js 服务
// 配合 06-04-HTTPS全栈部署.md 使用

const http = require('http');
const os = require('os');

const PORT = process.env.PORT || 3001;
const INSTANCE_ID = process.env.INSTANCE_ID || `backend-${PORT}`;
const HOST = '127.0.0.1';

let requestCount = 0;

const server = http.createServer((req, res) => {
    requestCount++;

    const response = {
        instance: INSTANCE_ID,
        port: PORT,
        hostname: os.hostname(),
        uptime: Math.floor(process.uptime()),
        requestCount: requestCount,
        clientIP: req.headers['x-forwarded-for'] || req.socket.remoteAddress,
        scheme: req.headers['x-forwarded-proto'] || 'http',
        time: new Date().toISOString()
    };

    res.writeHead(200, {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Instance': INSTANCE_ID,
        'X-Backend-Port': PORT.toString()
    });
    res.end(JSON.stringify(response, null, 2));
});

server.listen(PORT, HOST, () => {
    console.log(`[${INSTANCE_ID}] 后端启动: http://${HOST}:${PORT}`);
});
