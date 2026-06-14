/**
 * 负载均衡综合练习 - 后端服务
 *
 * 启动方式（分别在 4 个终端中运行）：
 *   node server.js 3001   # Server A - 高性能（weight=5）
 *   node server.js 3002   # Server B - 标准（weight=3）
 *   node server.js 3003   # Server C - 老旧（weight=2）
 *   node server.js 3004   # Server D - 备用（backup）
 *
 * 每个实例返回自己的端口号和请求计数，
 * 方便观察 Nginx 的负载分配和故障转移行为。
 */

const http = require('http');

// 从命令行参数获取端口号
const PORT = parseInt(process.argv[2]) || 3000;

// 服务器标签（便于识别）
const labels = {
    3001: 'Server A (高性能, weight=5)',
    3002: 'Server B (标准, weight=3)',
    3003: 'Server C (老旧, weight=2)',
    3004: 'Server D (备用, backup)'
};

const LABEL = labels[PORT] || `Server on port ${PORT}`;

// 请求计数器
let requestCount = 0;

// 服务启动时间
const startTime = new Date();

const server = http.createServer((req, res) => {
    requestCount++;

    const now = new Date();
    const uptime = Math.floor((now - startTime) / 1000);

    console.log(`[${LABEL}] 请求 #${requestCount}: ${req.method} ${req.url}`);

    // 健康检查端点
    if (req.url === '/health') {
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end('OK');
        return;
    }

    // 模拟轻微的处理延迟（让演示更真实）
    const delay = Math.floor(Math.random() * 80) + 20;

    setTimeout(() => {
        res.writeHead(200, {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Server-Port': String(PORT),
            'X-Server-Label': LABEL
        });

        res.end(JSON.stringify({
            server: LABEL,
            port: PORT,
            uptime: `${uptime}s`,
            requestCount: requestCount,
            timestamp: now.toISOString(),
            clientIp: req.headers['x-real-ip'] || req.socket.remoteAddress,
            forwardedFor: req.headers['x-forwarded-for'] || '（未设置）',
            host: req.headers.host || '（未设置）'
        }, null, 2));
    }, delay);
});

server.listen(PORT, () => {
    console.log('========================================');
    console.log(`  ${LABEL}`);
    console.log(`  端口：${PORT}`);
    console.log(`  PID：${process.pid}`);
    console.log(`  地址：http://localhost:${PORT}`);
    console.log('========================================\n');
});

// 优雅退出处理
process.on('SIGTERM', () => {
    console.log(`\n[${LABEL}] 收到 SIGTERM，正在优雅退出...`);
    server.close(() => {
        console.log(`[${LABEL}] 服务已停止`);
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log(`\n[${LABEL}] 收到 SIGINT (Ctrl+C)，正在退出...`);
    server.close(() => {
        console.log(`[${LABEL}] 服务已停止`);
        process.exit(0);
    });
});
