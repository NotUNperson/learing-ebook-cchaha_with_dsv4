# 02-02 proxy_pass 详解

## 本节你会学到什么

- 掌握 `proxy_pass` 的基本语法和用法
- 理解 URL 带斜杠和不带斜杠的关键区别
- 学会在代理过程中处理 URI 路径替换
- 亲手配置 Nginx 反向代理到本地后端应用

## 正文

### proxy_pass 是什么

`proxy_pass` 是反向代理的核心指令。它告诉 Nginx："把匹配到这个 location 的请求，转发到指定地址去。"

最简单的例子：

```nginx
location /api/ {
    proxy_pass http://localhost:3000;
}
```

这个配置的意思是：所有以 `/api/` 开头的请求，都转发到 `http://localhost:3000`。比如用户请求 `/api/users`，Nginx 就把请求转发给 `http://localhost:3000/api/users`。

### 带斜杠 vs 不带斜杠：最容易踩的坑

`proxy_pass` 后面 URL 的尾部是否带 `/`，决定了请求的 URI 是否被修改。这是 Nginx 配置中最让人困惑的地方之一，但理解之后其实很简单。

**规则：**

- 如果 `proxy_pass` 后面**不带路径**（只有协议+域名+端口），原始请求 URI 完整传递
- 如果 `proxy_pass` 后面**带了路径**（有斜杠和更多内容），location 匹配的部分会被替换

用**快递中转站**来类比：你寄一个快递，中转站拿到包裹后看地址标签。

- 不带路径 = 中转站不改地址标签，原样转发："上海市浦东新区 XX 路 88 号"还是"上海市浦东新区 XX 路 88 号"
- 带路径 = 中转站撕掉旧标签，贴上新的："上海市浦东新区"被替换成"上海市徐汇区"，后面的"XX 路 88 号"不变

来看具体例子。

**情况一：proxy_pass 不带路径**

```nginx
location /api/ {
    proxy_pass http://localhost:3000;
}
```

请求路径转换表：

| 用户请求 | 转发给后端 |
|----------|-----------|
| `/api/users` | `http://localhost:3000/api/users` |
| `/api/posts/123` | `http://localhost:3000/api/posts/123` |
| `/api/` | `http://localhost:3000/api/` |

原始路径完整保留，直接拼到 `proxy_pass` 地址后面。

**情况二：proxy_pass 带路径（根路径 `/`）**

```nginx
location /api/ {
    proxy_pass http://localhost:3000/;
}
```

注意 `http://localhost:3000/` 后面有 `/`（一个根路径）。这意味着 location 匹配到的 `/api/` 被替换成了 `/`。

请求路径转换表：

| 用户请求 | 转发给后端 |
|----------|-----------|
| `/api/users` | `http://localhost:3000/users` |
| `/api/posts/123` | `http://localhost:3000/posts/123` |
| `/api/` | `http://localhost:3000/` |

`/api/` 被替换成了 `/`，后面的部分保持原样。

**情况三：proxy_pass 带自定义路径**

```nginx
location /api/ {
    proxy_pass http://localhost:3000/v2/;
}
```

请求路径转换表：

| 用户请求 | 转发给后端 |
|----------|-----------|
| `/api/users` | `http://localhost:3000/v2/users` |
| `/api/posts/123` | `http://localhost:3000/v2/posts/123` |

`/api/` 被替换成了 `/v2/`。

这个功能非常实用——你可以对外暴露简洁的 API 路径，内部映射到后端实际路径，相当于一层"URL 重写"。就像公司对外说"找技术支持请拨分机 800"，但实际上总机把 800 转接到了"技术部小李的内线 3102"。

**一句话总结：** proxy_pass 后面有路径就替换，没路径就原样追加。

### 完整配置示例

假设你有一个 Node.js 后端应用跑在 3000 端口，Nginx 在 80 端口接收请求并转发：

```nginx
server {
    listen 80;
    server_name api.example.com;

    # 所有 API 请求转发给后端
    location /api/ {
        # 去掉 /api 前缀，后端直接收到 /users 而不是 /api/users
        proxy_pass http://localhost:3000/;
    }

    # 静态文件直接由 Nginx 提供
    location / {
        root /var/www/frontend;
        try_files $uri $uri/ /index.html;
    }
}
```

这样配置后：
- 用户访问 `http://api.example.com/api/users`，Nginx 转发给 `http://localhost:3000/users`
- 用户访问 `http://api.example.com/`，Nginx 直接返回前端静态文件

同一个域名，不同路径走了不同的处理逻辑——反向代理和静态文件服务和平共存。

### 准备后端测试程序

为了验证代理是否工作，我们需要一个简单的后端程序。用 Node.js 写一个最简后端：

```javascript
// backend/app.js
const http = require('http');

const server = http.createServer((req, res) => {
    console.log(`收到请求: ${req.method} ${req.url}`);

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
        message: '后端服务正常运行',
        method: req.method,
        url: req.url,
        headers: req.headers,
        timestamp: new Date().toISOString()
    }, null, 2));
});

server.listen(3000, () => {
    console.log('后端服务已启动：http://localhost:3000');
});
```

启动这个后端：

```bash
node backend/app.js
```

然后在浏览器访问 `http://localhost/api/users`，你应该看到后端返回的 JSON 数据，其中 `url` 字段会显示 `/users`（因为 Nginx 把 `/api/` 替换成了 `/`），这正好验证了 `proxy_pass` 的路径替换规则。

## 动手试试

1. 将上面的 Node.js 后端代码保存为 `app.js`，在终端中运行 `node app.js`，启动后端服务。
2. 在 Nginx 配置中添加一个 server 块，将 `/api/` 的请求反向代理到 `http://localhost:3000/`（注意带斜杠）。
3. 用 `nginx -t && nginx -s reload` 重载配置。
4. 用浏览器或 curl 访问 `http://localhost/api/users`，观察返回的 JSON 数据。
5. 把 `proxy_pass` 改成不带斜杠（`http://localhost:3000`），重载后再次访问，对比两次 `url` 字段的区别。理解带斜杠和不带斜杠的差异。
6. 尝试改成 `proxy_pass http://localhost:3000/v2/`，看看 URL 怎么变化的。

## 本节小结

`proxy_pass` 后面带路径则替换 location 匹配的部分，不带路径则原样传递 URI。掌握这个区别是正确配置反向代理的关键。

## 下一节预告

下一节我们学习请求头和缓冲的配置。反向代理不只是转发请求体，还要正确处理各种 HTTP 头（Host、IP、协议等），否则后端应用可能收不到正确的客户端信息。
