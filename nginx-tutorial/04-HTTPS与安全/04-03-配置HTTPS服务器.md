# 04-03 配置 HTTPS 服务器

## 本节你会学到什么

- 掌握 ssl_certificate 和 ssl_certificate_key 两个关键指令
- 理解 listen 443 ssl 的含义
- 学会配置 ssl_protocols 和 ssl_ciphers 控制安全性
- 能够验证 HTTPS 配置是否生效且正确

## 给房子装上防盗门

想象你住的房子，原本大门敞开着，谁都能往里看（HTTP 明文）。现在你要给这扇门装上一道防盗门（HTTPS）。装防盗门需要三样东西：

1. **门锁**——这就是你的私钥（server.key）。只有你有钥匙，锁装在门内侧，绝对不能给外人。
2. **防盗门的铭牌**——这就是你的证书（server.crt）。上面刻着你的门牌号和制造商信息，访客（浏览器）看到后能确认"对，这就是张三家的门"。
3. **门的规格说明**——这就是 SSL 协议配置。你告诉访客：这扇门用什么级别的锁（TLSv1.2/TLSv1.3）、什么类型的钥匙（加密套件）。

装好防盗门之后，访客和你之间的所有交流都在门内进行，外面的人既看不到也改不了。

## 核心配置指令

把证书配到 Nginx 上，只需要两个指令：

```nginx
server {
    listen 443 ssl;                         # 监听 443 端口，开启 SSL
    server_name example.test;

    ssl_certificate      /path/to/server.crt;   # 证书路径
    ssl_certificate_key  /path/to/server.key;   # 私钥路径
}
```

**listen 443 ssl** 和普通的 `listen 80` 有什么区别？

- `listen 80` —— 开了一扇普通门，进来的人说的是"明文"，谁都能听懂
- `listen 443 ssl` —— 开了一扇防盗门，进来的人在门口先对暗号（TLS 握手），确认身份后进入，之后说的全是加密后的"暗语"

有个容易混淆的点：`listen 443` 和 `listen 443 ssl` 不一样。没有 `ssl` 参数时，Nginx 会把这个 443 端口当作普通 HTTP 处理，不会进行 TLS 握手。加上 `ssl` 参数后才开启加密。你可以把它想象成：装了一扇防盗门，但没有启动锁芯——门是关着，但谁都能推开。

## 控制协议版本：不要旧锁

就像你不会用上世纪的老式挂锁来保护金库一样，你不应该使用有漏洞的老版本加密协议：

```nginx
# 只启用安全的协议版本
ssl_protocols TLSv1.2 TLSv1.3;
```

各版本的状态：
- SSLv2、SSLv3 —— 古董级，早已被攻破，**绝对不能启用**
- TLSv1.0、TLSv1.1 —— 2019-2021 年间各大浏览器已停止支持，**不应启用**
- TLSv1.2 —— 2008 年发布，仍然是主流，安全
- TLSv1.3 —— 2018 年发布，更快更安全，现代浏览器都支持

如果你的网站面向普通用户，只需启用 TLSv1.2 和 TLSv1.3 就够。如果你的用户群体还在用老设备（比如某些嵌入式设备），可能需要把 TLSv1.0 也打开，但要清楚这么做会降低安全性。

## 控制加密套件：选择安全的锁芯

加密套件（Cipher Suite）决定了数据用什么算法加密。不同的"锁芯"安全级别不同：

```nginx
# 指定允许的加密套件列表
ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;

# 优先使用服务器指定的加密套件，而不是客户端（浏览器）提出的
ssl_prefer_server_ciphers on;
```

加密套件以冒号分隔，每个套件的名字里包含了关键算法信息。以 `ECDHE-RSA-AES128-GCM-SHA256` 为例：
- `ECDHE` —— 密钥交换算法，使用椭圆曲线，支持前向保密
- `RSA` —— 身份认证算法
- `AES128-GCM` —— 对称加密算法，128 位密钥，GCM 模式（带完整性校验）
- `SHA256` —— 哈希算法

不用死记这些，关键是记住：选择支持**前向保密（Forward Secrecy）**的套件。前向保密的意思是即使你的私钥将来泄露了，之前的历史通信内容也无法被解密——因为每次会话都用了不同的临时密钥。这就像你家的门锁每天自动换一把新钥匙，即使今天的钥匙被偷了，昨天的小偷也打不开以前的录像。

## 会话缓存：减少重复握手

TLS 握手虽然快，但如果用户频繁访问，每次都握手也是一种开销。可以通过会话缓存来优化：

```nginx
# 分配 10MB 内存用于存储 SSL 会话参数
ssl_session_cache shared:SSL:10m;

# 会话参数的有效期是 10 分钟
ssl_session_timeout 10m;
```

这个机制就像你去小区物业办了一张访客卡——第一次要登记身份证（完整握手），之后凭访客卡直接刷卡进入（会话恢复），省去重复登记的时间。10 分钟后访客卡过期，需要重新登记。

## 如何验证 HTTPS 配置是否正确

配置完成后重启 Nginx，用以下方法验证：

**方法一：curl**

```bash
# -k 表示忽略证书验证（因为自签名证书不被信任）
# -I 表示只获取响应头
curl -k -I https://example.test

# 如果看到 HTTP/2 200 或 HTTP/1.1 200，说明 HTTPS 工作正常
```

**方法二：openssl s_client**

```bash
# 直接连接服务器的 443 端口，查看 TLS 握手详情
echo | openssl s_client -connect example.test:443 -servername example.test 2>&1 | head -30

# 重点看：
#   - "SSL handshake has read ..."  表示握手成功
#   - "Protocol  : TLSv1.2"         表示使用的协议版本
#   - "Cipher    : ECDHE-RSA-..."    表示协商的加密套件
```

**方法三：浏览器**

用浏览器访问 `https://example.test`。对于自签名证书，浏览器会显示"不安全"或"您的连接不是私密连接"。点击"高级" -> "继续前往"可以强制访问。这个警告是预期行为，上一节已经解释过原因了。

## 完整配置示例

下面是一个可直接使用的完整 HTTPS 服务器配置：

```nginx
server {
    listen       443 ssl;
    server_name  example.test;

    ssl_certificate      certs/server.crt;
    ssl_certificate_key  certs/server.key;

    ssl_protocols         TLSv1.2 TLSv1.3;
    ssl_ciphers           ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers on;

    ssl_session_cache     shared:SSL:10m;
    ssl_session_timeout   10m;

    root   /usr/share/nginx/html;
    index  index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

配置说明：
- 443 端口，配了 ssl 参数
- 指定了证书和私钥路径
- 限制只允许 TLSv1.2 和 TLSv1.3
- 指定了安全加密套件
- 启用了会话缓存减少握手开销

实际的配置文件在 `examples/04-03/nginx.conf`，可以对照参考。

## 动手试试

1. 先用上一节的脚本生成证书（或用本节配套脚本），确保证书路径与配置一致
2. 把 `examples/04-03/nginx.conf` 配置放到 Nginx 的配置目录中（或用 `-c` 参数指定）
3. 启动 Nginx，用 `curl -k -I https://localhost` 验证 HTTPS 是否生效
4. 再用 `openssl s_client -connect localhost:443` 查看 TLS 握手详情，确认使用的协议版本和加密套件
5. 尝试把 `ssl_protocols` 改成只留 `TLSv1.3`，重启后用老一点的 curl 版本测试，观察会发生什么

## 本节小结

启用 HTTPS 就是给 Nginx 配好证书和私钥，在 listen 指令加上 ssl 参数，再限制安全的协议版本和加密套件，相当于给网站装上了一道防盗门。

## 下一节预告

下一节你将学习如何自动把 HTTP 请求跳转到 HTTPS，确保所有流量都走加密通道。
