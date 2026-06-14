/**
 * 留言板后端服务（用于反向代理综合练习）
 *
 * 启动方式：node server.js
 * 监听端口：3000
 *
 * 接口：
 *   GET  /messages  - 获取留言列表
 *   POST /add       - 添加留言（JSON: {name, content}）
 *   GET  /slow      - 慢请求（15 秒延迟，测试代理超时）
 *
 * 这个后端设计为通过 Nginx 反向代理访问，
 * 前端浏览器不直接连 3000 端口，
 * 而是通过 80 端口的 Nginx 代理转发。
 */

const http = require('http');

const PORT = 3000;

// 留言存储（内存中，重启丢失）
const messages = [];

const server = http.createServer((req, res) => {
    const url = new URL(req.url, `http://${req.headers.host}`);

    console.log(`[${new Date().toLocaleString()}] ${req.method} ${url.pathname}`);

    // CORS 头（方便直接测试，即使 Nginx 已经统一处理）
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    // 预检请求处理
    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    // ======== GET /messages —— 获取留言列表 ========
    if (req.method === 'GET' && url.pathname === '/messages') {
        res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
        res.end(JSON.stringify({
            success: true,
            total: messages.length,
            messages: messages,
            // 这些字段帮助你验证代理头是否正确传递
            clientIp: req.headers['x-real-ip'] || req.socket.remoteAddress,
            forwardedFor: req.headers['x-forwarded-for'] || '（未设置）',
            host: req.headers.host || '（未设置）'
        }));
        return;
    }

    // ======== POST /add —— 添加留言 ========
    if (req.method === 'POST' && url.pathname === '/add') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            try {
                const data = JSON.parse(body);
                const msg = {
                    id: Date.now(),
                    name: data.name || '匿名',
                    content: data.content || '',
                    time: new Date().toISOString()
                };
                messages.unshift(msg);
                console.log(`  新留言: ${msg.name} - ${msg.content.substring(0, 30)}`);

                res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
                res.end(JSON.stringify({
                    success: true,
                    message: msg,
                    clientIp: req.headers['x-real-ip'] || req.socket.remoteAddress
                }));
            } catch (e) {
                res.writeHead(400, { 'Content-Type': 'application/json; charset=utf-8' });
                res.end(JSON.stringify({ success: false, error: '请求数据格式错误，请发送 JSON' }));
            }
        });
        return;
    }

    // ======== GET /slow —— 慢请求（测试代理超时）========
    if (req.method === 'GET' && url.pathname === '/slow') {
        console.log('  收到慢请求，将在 15 秒后响应...');
        setTimeout(() => {
            res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
            res.end(JSON.stringify({
                success: true,
                message: '这个响应延迟了 15 秒',
                delayed: '15s'
            }));
            console.log('  慢请求响应完成');
        }, 15000);
        return;
    }

    // ======== 404 ========
    res.writeHead(404, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({
        success: false,
        error: `接口不存在: ${req.method} ${url.pathname}`
    }));
});

server.listen(PORT, () => {
    console.log('========================================');
    console.log('  留言板后端服务已启动');
    console.log(`  地址：http://localhost:${PORT}`);
    console.log('  接口：');
    console.log('    GET  /messages  获取留言列表');
    console.log('    POST /add       添加留言');
    console.log('    GET  /slow      慢请求（15秒，测试超时）');
    console.log('  通过 Nginx 代理访问：http://messageboard.local/api/');
    console.log('  按 Ctrl+C 停止服务');
    console.log('========================================\n');
});
