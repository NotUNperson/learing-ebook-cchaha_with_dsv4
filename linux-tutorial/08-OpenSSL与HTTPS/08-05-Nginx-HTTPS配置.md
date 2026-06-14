# 08-05 Nginx HTTPS 配置：从证书到 A+ 评级

## 本节你会学到什么

- 配置 Nginx 监听 443 端口并使用 SSL 证书
- 设置 HTTP 自动跳转到 HTTPS
- 优化 TLS 配置：启用 HTTP/2、TLS 1.3、选择安全的加密套件
- 添加安全响应头（HSTS、CSP、X-Frame-Options 等）
- 用 SSL Labs 和 testssl.sh 验证站点安全性

---

## 正文

### 一、Nginx HTTPS 最小配置

拿到证书后，最简单的 Nginx HTTPS 配置如下：

```nginx
server {
    listen 443 ssl;
    server_name example.com www.example.com;

    # 证书文件（fullchain = 你的证书 + 中间 CA）
    ssl_certificate     /etc/letsencrypt/live/example.com/fullchain.pem;
    # 私钥文件
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    root /var/www/html;
    index index.html;
}
```

**类比**：HTTP 站点 = 路边摊，谁来都能坐，说话别人都能听见。加上 SSL 配置 = 把路边摊改成带隔音玻璃的包间，门口还挂营业执照（证书）。

重载 Nginx 让配置生效：

```bash
sudo nginx -t          # 先测试配置语法
sudo systemctl reload nginx
```

### 二、HTTP 自动跳转 HTTPS

光配 443 还不够——用户可能在地址栏输入 `http://example.com`（默认走 80 端口）。你需要把 HTTP 流量引导到 HTTPS：

```nginx
# 端口 80 只做一件事：重定向到 HTTPS
server {
    listen 80;
    server_name example.com www.example.com;

    # 301 永久重定向
    return 301 https://$host$request_uri;
}

# 端口 443 才是真正的网站
server {
    listen 443 ssl http2;   # http2 启用了 HTTP/2
    server_name example.com www.example.com;

    ssl_certificate     /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

或者用更灵活的方式（如果同一个域名下有多个路径要不同处理）：

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    # 对于 .well-known/acme-challenge 路径不重定向（Let's Encrypt 需要）
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}
```

### 三、HTTP/2 和 TLS 1.3

在 `listen 443 ssl` 后面加上 `http2`，一行改动就能让网站速度快 15-30%：

```nginx
listen 443 ssl http2;
```

HTTP/2 的特性：
- **多路复用**：一个 TCP 连接上并行传输多个请求（HTTP/1.1 最多 6 个并发）
- **头部压缩**：减少重复请求头带来的带宽浪费
- **服务器推送**（Server Push）：服务器可以主动推送资源（用的不多）

TLS 1.3 相比 TLS 1.2 的改进：
- **握手少一轮**：从 2-RTT 降到 1-RTT（甚至 0-RTT）
- **移除不安全算法**：不再支持 RC4、3DES、CBC 模式
- **前向安全性**：默认启用（即使私钥泄露，历史会话不会解密）

### 四、优化安全配置：从默认到 A+

默认的 Nginx TLS 配置比较保守（为了兼容老设备）。如果你追求安全性（而不是兼容 IE8），可以做以下优化：

```nginx
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;

    # === 证书 ===
    ssl_certificate     /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    # === 协议版本：只允许 TLS 1.2 和 1.3 ===
    ssl_protocols TLSv1.2 TLSv1.3;

    # === 加密套件：只选安全的 ===
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers off;   # TLS 1.3 中这个设置被忽略（让客户端选）

    # === ECDH 曲线 ===
    ssl_ecdh_curve X25519:prime256v1:secp384r1;

    # === 会话复用：提升性能 ===
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;   # TLS 1.3 推荐关闭

    # === DH 参数（仅 TLS 1.2 需要，1.3 不用） ===
    ssl_dhparam /etc/nginx/dhparam.pem;

    # === OCSP Stapling：减少证书状态查询 ===
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/example.com/chain.pem;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;

    # === 安全头 ===
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    root /var/www/html;
}
```

#### 各配置项详解

**ssl_protocols**：只允许 TLS 1.2 和 1.3。禁用 TLS 1.0 和 1.1（已被 PCI DSS 和主流标准淘汰）。

**ssl_ciphers**：加密套件是"加密算法组合"。你需要理解套件名的格式：

```
ECDHE-ECDSA-AES256-GCM-SHA384
  │     │      │     │    │
  │     │      │     │    哈希算法（SHA-384）
  │     │      │    加密模式（GCM 是认证加密）
  │     │     加密算法（AES-256）
  │    签名算法（ECDSA）
  密钥交换（ECDHE = 椭圆曲线 Diffie-Hellman 临时密钥，提供前向安全性）
```

所有推荐的套件都以 `ECDHE` 开头——确保前向安全性。推荐用 Mozilla SSL Configuration Generator（https://ssl-config.mozilla.org/）获取最新推荐配置。

**ssl_dhparam**：DH 参数文件用于 TLS 1.2 的 DHE 密钥交换。生成方式：

```bash
# 生成 2048 位 DH 参数（需要几分钟）
sudo openssl dhparam -out /etc/nginx/dhparam.pem 2048
```

> 安全提示：用 2048 位就够。4096 位会更安全但生成极慢（可能几十分钟），而且每次 TLS 握手都会更慢。

**ssl_session_cache** 和 **ssl_session_timeout**：缓存 TLS 会话参数，用户再次连接时可以跳过完整握手，减少计算开销。`shared:SSL:10m` 表示用 10MB 共享内存做会话缓存。

**OCSP Stapling**：正常情况下浏览器要查询 CA 的 OCSP 服务器确认证书没被吊销。这增加了延迟和隐私泄露。OCSP Stapling 让服务器替你查询 OCSP 状态，然后把结果"订"在 TLS 握手中发给浏览器。

- `ssl_stapling on`：启用 OCSP Stapling
- `ssl_stapling_verify on`：验证 OCSP 响应的签名
- `ssl_trusted_certificate`：指定中间 CA 证书链（用于验证 OCSP 响应）
- `resolver`：DNS 解析器（查询 OCSP 服务器地址用）

### 五、安全响应头

| HTTP 头 | 作用 | 推荐值 |
|---------|------|--------|
| `Strict-Transport-Security` (HSTS) | 强制浏览器只用 HTTPS 访问，禁止 HTTP | `max-age=63072000; includeSubDomains; preload` |
| `X-Content-Type-Options` | 禁止浏览器猜测 MIME 类型 | `nosniff` |
| `X-Frame-Options` | 禁止页面被嵌入 iframe（防点击劫持） | `DENY` 或 `SAMEORIGIN` |
| `X-XSS-Protection` | 启用浏览器内置 XSS 过滤器 | `1; mode=block` |
| `Referrer-Policy` | 控制 Referer 头信息泄露 | `strict-origin-when-cross-origin` |
| `Content-Security-Policy` (CSP) | 白名单控制页面可加载的资源 | 按需配置（较复杂） |

**HSTS 风险警告**：`max-age=63072000`（2 年）加上 `includeSubDomains` 意味着一旦浏览器收到这个头，之后 2 年内访问该域名及其所有子域名都会强制使用 HTTPS。如果你的子域名中还有没用 HTTPS 的，它们会打不开！先在测试环境验证。

### 六、验证你的 HTTPS 配置

#### SSL Labs Server Test

访问 `https://www.ssllabs.com/ssltest/`，输入你的域名，等待检测完成。目标评级：**A+**。

#### testssl.sh（命令行工具）

```bash
# 下载 testssl.sh
git clone https://github.com/drwetter/testssl.sh.git
cd testssl.sh

# 测试你的站点
./testssl.sh https://example.com

# 只检查漏洞
./testssl.sh --vulnerable https://example.com

# 只检查协议和加密套件
./testssl.sh --protocols --ciphers https://example.com
```

#### OpenSSL s_client

```bash
# 连接你的服务器并查看 TLS 握手详情
openssl s_client -connect example.com:443 -tls1_3
openssl s_client -connect example.com:443 -tls1_2

# 看具体协商了哪个加密套件
openssl s_client -connect example.com:443 -tls1_3 2>/dev/null | grep -E "Protocol|Cipher"
```

### 七、完整配置模板

以下是一个生产就绪的 Nginx HTTPS 配置模板：

```nginx
# ============================================
# /etc/nginx/sites-available/example.com
# 生产级 HTTPS 站点配置
# ============================================

# ---- HTTP → HTTPS 重定向 ----
server {
    listen 80;
    server_name example.com www.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# ---- HTTPS 主站点 ----
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;

    # -- 证书 --
    ssl_certificate         /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/example.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/example.com/chain.pem;

    # -- 协议与套件 --
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
    ssl_prefer_server_ciphers off;
    ssl_ecdh_curve X25519:prime256v1:secp384r1;

    # -- 性能 --
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;
    ssl_dhparam /etc/nginx/dhparam.pem;

    # -- OCSP Stapling --
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;

    # -- 安全头 --
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # -- 网站 --
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # -- 禁止访问隐藏文件 --
    location ~ /\. {
        deny all;
    }
}
```

### 八、常见问题

**Q: Nginx 启动失败，报 "ssl_certificate" 错误？**

```bash
# 检查证书和私钥是否配对
openssl x509 -noout -modulus -in /path/to/cert.pem | openssl md5
openssl rsa -noout -modulus -in /path/to/key.pem | openssl md5
# 两个 MD5 值应该一样
```

**Q: 80 端口被占用，certbot standalone 模式失败？**

```bash
# 先停掉 Nginx
sudo systemctl stop nginx

# 用 standalone 模式获取证书
sudo certbot certonly --standalone -d example.com

# 启动 Nginx
sudo systemctl start nginx
```

**Q: SSL Labs 评分总是 B 或 C？**
- 检查 `ssl_protocols` 是否包含 TLS 1.0 / 1.1（应该去掉）
- 检查 `ssl_ciphers` 中是否包含 RC4、3DES、CBC 模式的套件（应该去掉）
- 检查是否启用 HSTS（`add_header Strict-Transport-Security`）

## 动手试试

1. 按本节模板配置一个完整的 HTTPS 站点（可以用自签名证书测试）
2. 用 `curl -I https://你的域名` 查看返回的安全响应头
3. 用 `openssl s_client -connect 你的域名:443 -tls1_3` 确认 TLS 1.3 已启用
4. 用 SSL Labs 或 testssl.sh 检测站点，争取 A 级评定
5. 故意把 `ssl_protocols` 设成 `TLSv1`，再测试一次，观察评级的巨大差异

## 本节小结

Nginx HTTPS 配置从 443 端口 SSL 监听开始，通过 HTTP/2 和 TLS 1.3 提升性能，通过严格的加密套件和安全头拿到 A+ 评级，用 HSTS 防止降级攻击。OCSP Stapling 减少隐私泄露，HTTP 80 通过 301 重定向平滑迁移用户到 HTTPS。

## 下一节预告

综合练习：我们将从一台全新服务器开始，完成申请证书、部署 Nginx、配置安全头、搭建测试和监控的一整套流程。
