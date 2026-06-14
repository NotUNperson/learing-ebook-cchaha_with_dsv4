# 06-04 HTTPS 全栈部署

## 本节你会学到什么

- 将所有 Nginx 知识整合到一个生产级配置中
- 理解安全响应头（X-Frame-Options 等）的作用
- 掌握 listen 443 ssl http2 的含义
- 能用自签名证书搭建完整的 HTTPS 全栈环境

## 开一个安全合规的商场

这是本教程综合实战的顶点。想象你要开一个大型商场，把所有学到的管理知识都用上：

- **防盗门 + 安检通道**（HTTPS + 强制跳转）：正门进来必须过安检，不走安检的就绕回正门重新进
- **货架分区**（静态资源分离 + 缓存）：零食区（图片）、饮料区（CSS/JS）、生鲜区（HTML），每个区的补货频率不同（缓存策略不同）
- **自助收银台**（Nginx 直接处理静态资源）：顾客买瓶水自己扫码结账，快且不占用人工收银通道
- **人工收银台**（反向代理到后端）：复杂的退货退款去人工柜台（API 请求代理到 Node.js）
- **多个收银台并行**（负载均衡）：开了 2-3 个人工柜台，哪个空就去哪个
- **保安巡逻**（安全响应头）：保安（X-Frame-Options）防止你的店铺被套在别人网站里展示；巡查（X-Content-Type-Options）防止有人把危险品伪装成普通商品带进来
- **监控录像**（JSON 日志）：每个角落都有摄像头，出事能回溯
- **消防通道标识**（自定义错误页面）：404 找不到店铺就引导到服务台（自定义 404 页面）；500 系统故障就引导到紧急出口（50x 页面）

## 配置全景图

本节的配置文件 `examples/06-04/nginx.conf` 是全书知识的总汇。它包含了我们在教程中学习的几乎所有配置项，构成了一条完整的安全和性能流水线。

```nginx
用户请求
    |
    |-- http://myapp.test --> 301 跳转 --> https://myapp.test
    |
    v
HTTPS (TLSv1.2/1.3 + 证书验证 + HSTS)
    |
    |-- /static/.*\.css  --> Nginx 直接读取 --> Gzip 压缩 --> 7 天缓存 --> 浏览器
    |-- /static/.*\.png  --> Nginx 直接读取 --> 30 天缓存 --> 浏览器
    |-- /api/*           --> proxy_pass --> upstream 负载均衡 --> 后端 Node.js
    |                                                |
    |                                  least_conn + 健康检查 + 重试
    |                                                |
    |                                  +--> 127.0.0.1:3001
    |                                  +--> 127.0.0.1:3002
    |-- / (首页)         --> Nginx 直接读取 --> Gzip + 协商缓存 --> 浏览器
    |-- /nonexist        --> 404 页面（自定义错误页）
```

## 新增知识：安全响应头

除了之前学过的 HSTS，这里还引入了几个额外的安全响应头。它们各自像一个不同类型的"保安"保护你的网站：

```nginx
# 1. 防止网站被嵌入到 iframe 中（防止点击劫持）
add_header X-Frame-Options "SAMEORIGIN" always;
# SAMEORIGIN = 只允许同域名页面内嵌，其他网站不能把你的页面套在 iframe 里
# DENY = 完全不允许被嵌入
# 类比：防止别人把你的店招牌套在他的假店面里，欺骗顾客

# 2. 防止浏览器 MIME 类型嗅探
add_header X-Content-Type-Options "nosniff" always;
# 浏览器不会猜测文件类型，严格按照服务器声明的 Content-Type 来处理
# 类比：快递包裹只按面单上的"文件"或"食品"来分类，不打开看内容自己判断

# 3. 启用浏览器内置 XSS 过滤器
add_header X-XSS-Protection "1; mode=block" always;
# 如果浏览器检测到反射型 XSS 攻击，直接拦截页面加载

# 4. 控制 Referer 信息泄露
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
# 同域名：发送完整 URL
# 跨域名且协议降级（HTTPS->HTTP）：不发送 Referer
# 跨域名且同级：只发送域名，不发送完整路径
```

这些头本身不会增加太多服务器开销，但对于提升网站的安全评级有显著效果。你可以用 [securityheaders.com](https://securityheaders.com) 来检测你的网站安全头配置是否到位。

`always` 参数的含义：正常响应（200、301 等）加上这些头，非正常响应（404、500）也要加上。如果忘了加 `always`，Nginx 只在成功响应中添加头部，错误页面就没有这些安全保护了。

## http2：让浏览器"一次说话、多次收菜"

注意 `listen 443 ssl http2` 中的 `http2` 参数。HTTP/2 相比 HTTP/1.1 有几个重要改进：

- **多路复用**：一个连接上可以同时传输多个文件。想象你在餐厅点菜——HTTP/1.1 是你说一个菜，服务员去厨房拿来，你再说下一个。HTTP/2 是你一次性说完所有菜，厨房并行准备，服务员陆陆续续端上来。不需要断开连接再重连。
- **头部压缩**：请求头也会被压缩传输。多次请求的相同头部（如 `User-Agent`）只会传一次差异部分
- **服务器推送**：Nginx 可以在浏览器请求 HTML 时，主动把 CSS 和 JS 也推送给浏览器

启用 HTTP/2 需要 SSL（所有主流浏览器都只支持在 TLS 上使用 HTTP/2），所以 `listen 443 ssl http2` 是标配。

## 运行步骤

**第一步：生成证书**

```bash
cd examples/06-04
bash generate-certs.sh
# 证书生成在 ./certs/ 目录
```

**第二步：启动后端集群**

```bash
# 启动两个后端实例
PORT=3001 INSTANCE_ID=backend-3001 node examples/06-04/backend/server.js &
PORT=3002 INSTANCE_ID=backend-3002 node examples/06-04/backend/server.js &
```

**第三步：配置 Nginx**

把 `examples/06-04/nginx.conf` 中的路径调整为实际路径，然后重载 Nginx。

**第四步：验证完整栈**

```bash
# 1. HTTP 跳 HTTPS
curl -I http://myapp.test

# 2. HTTPS 首页（带 Gzip）
curl -k -H "Accept-Encoding: gzip" https://myapp.test | wc -c

# 3. 安全响应头检查
curl -k -I https://myapp.test 2>/dev/null | grep -E "^X-|^Strict-"

# 4. API 负载均衡（连续调用看分发到不同后端）
for i in $(seq 1 6); do
  curl -k -s https://myapp.test/api/status | grep -o '"instance":"[^"]*"'
done

# 5. 停止一个后端，再试 API（应该只路由到存活的后端）
```

## 动手试试

1. 生成证书：`cd examples/06-04 && bash generate-certs.sh`
2. 启动 2 个后端实例（`examples/06-04/backend/server.js`）
3. 参考 `examples/06-04/nginx.conf`，配置并启动 Nginx
4. 浏览器访问 `https://myapp.test/`（自签名证书需要手动信任或点"继续前往"）
5. 在开发者工具的 Network 标签中验证：
   - 所有请求走 HTTPS
   - `Content-Encoding: gzip` 存在
   - 静态资源有 `Cache-Control` 头
   - 响应头中包含 `Strict-Transport-Security` 和 `X-Frame-Options` 等安全头
6. 点击页面上的"连续 5 次调用"按钮，观察 API 请求是否在不同后端之间分发
7. 停止一个后端实例，再次调用 API，确认请求只路由到存活的后端
8. 浏览器地址栏中，看看有没有小锁图标（自签名证书下是"不安全"提示，但连接确实是加密的）

## 本节小结

生产级 HTTPS 全栈部署 = HTTPS + 301跳转 + HSTS + Gzip + 分类缓存 + 静态/API 分离 + 负载均衡 + 安全响应头 + JSON 日志，就像一个全方位合规、安全且高效的大型商场。

## 下一节预告

最后一节，我们来回顾整个教程的知识体系，并给出 Nginx 的进阶学习路线。
