/**
 * 负载均衡测试后端
 * 启动时接受一个端口号参数，返回自己的端口号以便观察负载分配
 *
 * 启动方式：
 *   node server.js 3001
 *   node server.js 3002
 *   node server.js 3003
 *
 * 每次请求返回 JSON，包含本服务端口号，
 * 通过 Nginx 反向代理访问时可以看到请求被分到了哪个后端。
 */

const http = require('http');

// 从命令行参数获取端口号，默认 3000
const PORT = parseInt(process.argv[2]) || 3000;

// 统计本进程处理的请求次数
let requestCount = 0;

const server = http.createServer((req, res) => {
    requestCount++;

    console.log(`[端口 ${PORT}] 收到第 ${requestCount} 个请求: ${req.method} ${req.url}`);

    // 模拟一些处理延迟（让演示更真实）
    const delay = Math.floor(Math.random() * 100) + 50;

    setTimeout(() => {
        res.writeHead(200, {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Server-Port': String(PORT)
        });

        res.end(JSON.stringify({
            server: `后端服务 ${PORT}`,
            port: PORT,
            requestCount: requestCount,
            timestamp: new Date().toISOString(),
            clientInfo: {
                remoteAddr: req.socket.remoteAddress,
                xRealIp: req.headers['x-real-ip'] || '未设置',
                xForwardedFor: req.headers['x-forwarded-for'] || '未设置'
            }
        }, null, 2));
    }, delay);
});

server.listen(PORT, () => {
    console.log(`后端服务已启动，端口 ${PORT}`);
    console.log(`访问地址：http://localhost:${PORT}`);
    console.log(`PID: ${process.pid}\n`);
});
