# 04-04 HTTP 自动跳转 HTTPS

## 本节你会学到什么

- 用 return 301 实现 HTTP 到 HTTPS 的永久重定向
- 了解 error_page 497 方法的适用场景和局限
- 理解 HSTS 头的作用和配置方法
- 明白为什么强制跳转不能完全靠服务端

## 商场入口自动引导到安检通道

想象你去一个大型商场。这个商场有好几个入口，但不管从哪个门进去，保安都会引导你先去安检通道——检查健康码、过金属探测门。过了安检之后，你才能在商场里自由活动。

强制 HTTPS 跳转就是这个道理：不管用户输入的是 `http://your-site.com` 还是直接点了一个 HTTP 链接，服务器一律把他们引导到安全的 HTTPS 通道。

这样做至少有两个好处：
1. **安全**——所有流量都加密了，不存在"部分安全、部分明文"的半吊子状态
2. **简单**——你的后端应用只需要考虑 HTTPS 的情况，不用再处理 HTTP 和 HTTPS 两套逻辑

## 方法一：return 301（推荐）

这是最常用、最直接的方法。单独开一个 `server` 块监听 80 端口，收到任何请求都直接返回 301 重定向：

```nginx
# 这个 server 块只做一件事：跳转
server {
    listen       80;
    server_name  example.test;

    # 301 永久重定向到 HTTPS
    # $server_name 是访问的域名
    # $request_uri 是请求路径，包含参数
    return 301 https://$server_name$request_uri;
}
```

301 和 302 有什么区别？联系现实生活——
- **301（永久搬走）**：就像你搬家后去邮局办了转寄服务。邮局知道"这个人已经永久搬到新地址了"，以后所有的信都直接投递到新地址。浏览器收到 301 后会记住这个跳转，下次用户再输入 HTTP 地址，浏览器可能直接跳到 HTTPS，不经过服务器。
- **302（临时搬走）**：就像你跟快递员说"今天的包裹请放到邻居家"。这是临时的，地址还是原来的。浏览器不会记住这个跳转，每次都会再问一遍服务器。

对于 HTTP 跳 HTTPS 这个场景，你应该用 **301**——因为这是永久性的策略改变。你把 HTTP 门关掉的决定不是临时的。

`$request_uri` 的作用：假设用户访问的是 `http://example.test/product?id=123`，通过 `$request_uri` 变量，重定向后的地址是 `https://example.test/product?id=123`——路径和查询参数原封不动地保留下来。如果只写 `return 301 https://$server_name;`，那所有请求都会被重定向到首页，用户的原始访问意图就丢失了。

## 方法二：error_page 497（特殊场景）

Nginx 有一个特殊的状态码 497：当客户端用 HTTP 协议请求一个只监听 HTTPS 的端口时触发。乍一看这不太可能发生——端口都不一样，怎么会有这种情况？但有一种场景：在同端口上同时处理 HTTP 和 HTTPS（不推荐这么做），或者客户端错误地给 443 端口发了明文 HTTP 请求。

配置方式：

```nginx
server {
    listen 443 ssl;
    # ... 证书等配置 ...

    # 如果收到 HTTP 请求（497），重定向到 HTTPS
    error_page 497 =301 https://$server_name$request_uri;
}
```

这个方法**不能替代** method 一的 80 端口跳转。把 error_page 497 理解为一道"正好在安检通道旁边还有一道紧急门"——偶尔有人走错了，这里的保安也把他引导到安检通道。但你绝不能因为这里有这道门，就把商场正门（80 端口）的安检引导给撤了。

## HSTS：让浏览器记住你的规矩

301 重定向有一个安全盲区：**第一次访问**。用户第一次输入 `example.test` 时，浏览器默认走 HTTP（因为没有 HTTPS 的"记忆"），这时中间人可以劫持这个 HTTP 请求，阻止跳转发生——这就是著名的 **SSL 剥离攻击**。

HSTS（HTTP Strict Transport Security）就是来解决这个问题的：

```nginx
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
```

理解 HSTS 的三个参数，可以用物业公告来类比：

- **max-age=63072000**（两年）——物业贴了一张公告说"本小区大门以后永久只开放东门，西门封闭"。公告有效期两年。浏览器在两年内，只要看到这个域名，就直接内部替换成 HTTPS 发起请求，不会先尝试 HTTP。
- **includeSubDomains**——公告上补充："不仅大门，所有侧门也按这个规矩来"。所有子域名也强制 HTTPS。
- **preload**——把你的规矩写入浏览器的"出厂设置"。主流浏览器维护了一个 HSTS 预加载列表，Chrome、Firefox 等浏览器在出厂时就内置了这个列表。即使用户从来没见过你的网站，第一次访问也是直接走 HTTPS。

不过要注意，HSTS 也有"鸡和蛋"的问题——浏览器至少要成功收到一次 HSTS 头，才能记住它。第一次访问仍然可能存在 SSL 剥离的风险。`preload` 列表就是为了从根本上堵住这个漏洞。

启用 HSTS 的注意事项：
1. 一旦配置了 max-age，在有效期内浏览器不会再访问 HTTP 版本。如果你以后想改回 HTTP，那些在这期间访问过你网站的浏览器会拒绝——因为它们已经"记住"了只能走 HTTPS
2. 测试时用短一点的 max-age（比如 `max-age=60`）验证效果，确认没问题后再改成长期值
3. 如果你的子域名还没有 HTTPS，就不要加 `includeSubDomains`

## 完整配置

```nginx
# 80 端口：301 跳转到 HTTPS
server {
    listen       80;
    server_name  example.test;
    return 301 https://$server_name$request_uri;
}

# 443 端口：正经的 HTTPS 服务 + HSTS 头
server {
    listen       443 ssl;
    server_name  example.test;

    ssl_certificate      certs/server.crt;
    ssl_certificate_key  certs/server.key;
    ssl_protocols         TLSv1.2 TLSv1.3;

    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    root   /usr/share/nginx/html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

## 动手试试

1. 使用 `examples/04-04/nginx.conf` 配置文件，确保证书路径正确
2. 启动 Nginx 后，用 curl 访问 HTTP 版本，观察 301 响应：

```bash
# 访问 HTTP，查看响应头中的 Location 和 Strict-Transport-Security
curl -I http://example.test

# 允许 curl 跟随重定向，最终访问到 HTTPS
curl -L http://example.test
```

3. 打开浏览器的开发者工具（F12），切换到 Network 标签，访问 `http://example.test`，观察：
   - 第一个请求是 301 重定向
   - 第二个请求自动变成了 HTTPS
   - 响应头中能看到 `Strict-Transport-Security` 头
4. 在 Chrome 中访问 `chrome://net-internals/#hsts`，在 "Query HSTS/PKP domain" 中输入你的域名，查看浏览器是否已经记住了 HSTS 设置

## 本节小结

HTTP 强制跳转 HTTPS 的推荐做法是用单独的 80 端口 server 块返回 301，再配合 HSTS 响应头让浏览器记住只走 HTTPS，就像商场统一把所有入口的顾客引导到安检通道。

## 下一节预告

下一节我们将回顾整个 HTTPS 模块的知识，完成一个综合练习。
