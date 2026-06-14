# 08-04 Let's Encrypt 免费证书：零成本公网 HTTPS

## 本节你会学到什么

- 理解 Let's Encrypt 的工作原理和 ACME 协议
- 用 certbot 申请和部署免费 SSL 证书
- 区分 HTTP 验证和 DNS 验证的适用场景
- 配置证书自动续期，确保证书永不过期
- 理解 90 天有效期的设计哲学

---

## 正文

### 一、Let's Encrypt 是什么

Let's Encrypt 是一个免费、自动化、开放的 CA（证书颁发机构），由非营利组织 ISRG（Internet Security Research Group）运营。自 2015 年成立以来，它彻底改变了 HTTPS 的普及速度——在那之前，SSL 证书要花钱买（几百到几千元/年），很多小网站干脆不用 HTTPS。

**核心特点**：

- **完全免费**：不需要信用卡，没有隐藏费用
- **自动化**：通过 ACME 协议，证书申请和续期都可以用命令行完成
- **90 天有效期**：故意设短，迫使你用自动化续期（而不是买一年期的然后忘掉）
- **全球信任**：Let's Encrypt 的根证书预装在几乎所有浏览器和操作系统中

**类比**：以前的 SSL 证书 = 需要付费找律师公证合同。Let's Encrypt = 政府开设了免费的自助公证机，刷身份证就能用，但公证书有效期只有三个月，过期了自己再刷一次。

### 二、ACME 协议：如何证明域名是你的

CA 签发证书前，需要验证申请人是否真的拥有这个域名。Let's Encrypt 使用 **ACME（Automatic Certificate Management Environment，自动证书管理环境）** 协议，提供两种验证方式：

#### HTTP 验证（HTTP-01 Challenge）

```
Let's Encrypt 服务器
    │
    (1) "请把这份随机令牌放到 http://你的域名/.well-known/acme-challenge/<token>"
    │
    ▼
你的 Web 服务器（端口 80 必须能从公网访问）
    │
    (2) 返回令牌
    │
    ▼
Let's Encrypt 服务器验证 → 签发证书
```

**类比**：快递员要确认你的地址是真的。他在你家门口放了一个只属于你的特殊标记，然后说"如果你真的住在这里，就把这个标记贴在窗户上"。他绕一圈回来，看到窗户上有标记，确认地址有效。

HTTP 验证的要求：
- 服务器的 80 端口必须能从互联网访问
- 域名 DNS 必须已经解析到服务器的公网 IP
- 不能用于通配符证书（`*.example.com`）

#### DNS 验证（DNS-01 Challenge）

```
Let's Encrypt 服务器
    │
    (1) "请在 DNS 中为 _acme-challenge.你的域名 添加一条 TXT 记录，值为 <随机令牌>"
    │
    ▼
你的 DNS 服务商
    │
    (2) 你添加 TXT 记录
    │
    ▼
Let's Encrypt 服务器查询 DNS → 验证 → 签发证书
```

**类比**：要证明你是房子的主人，不去原地址，而去房产登记处查。如果你的名字确实登记在册，就证明你是房主。

DNS 验证的优势：
- **不需要公网 80 端口**：适用于内网服务器、API 服务
- **支持通配符证书**：`*.example.com` 覆盖所有子域名
- **服务器无需对外暴露 HTTP**：更安全

### 三、安装 certbot

certbot 是 Let's Encrypt 官方推荐的 ACME 客户端：

```bash
# Ubuntu / Debian
sudo apt update
sudo apt install certbot

# CentOS / RHEL 7
sudo yum install epel-release
sudo yum install certbot

# CentOS / RHEL 8+ / Fedora
sudo dnf install certbot

# 通过 snap 安装（适用于更多发行版，保持最新）
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

验证安装：

```bash
certbot --version
# certbot 2.0.0
```

### 四、申请第一张证书

#### 方式一：certbot 自动配置 Nginx

如果你已经装了 Nginx 并且 80 端口已经在运行：

```bash
# certbot 会自动修改 nginx 配置，帮你完成 HTTPS 设置
sudo certbot --nginx -d example.com -d www.example.com
```

certbot 会：
1. 自动获取证书
2. 在 `/etc/nginx/sites-enabled/` 中修改配置，加上 SSL 相关指令
3. 添加 HTTP → HTTPS 重定向
4. 配置自动续期的 cron/systemd timer

这是最简单的方式，适合大多数场景。

#### 方式二：只获取证书，手动配置 Web 服务器

如果你不想让 certbot 动你的 Web 服务器配置：

```bash
# 使用 HTTP 验证，只获取证书
sudo certbot certonly --webroot \
    -w /var/www/html \
    -d example.com \
    -d www.example.com

# 或使用 standalone 模式（certbot 临时启动自己的 Web 服务器）
sudo certbot certonly --standalone \
    -d example.com \
    -d www.example.com
```

`--standalone` 模式需要 80 端口空闲（临时关掉 Nginx），`--webroot` 模式不占用端口。

证书生成后，文件位置：

```
/etc/letsencrypt/live/example.com/
├── fullchain.pem      ← Nginx 用这个！(证书 + 中间 CA)
├── privkey.pem        ← 私钥
├── cert.pem           ← 仅服务器证书
├── chain.pem          ← 仅中间 CA 证书
└── README
```

**注意**：`fullchain.pem` 和 `privkey.pem` 是最重要的两个文件。

#### 方式三：DNS 验证（支持通配符）

```bash
# 使用 DNS 验证，可申请通配符证书
sudo certbot certonly --manual \
    --preferred-challenges dns \
    -d "*.example.com" \
    -d example.com
```

certbot 会提示你在 DNS 中添加 TXT 记录：

```
Please deploy a DNS TXT record under the name:
_acme-challenge.example.com with the following value:

abcdefghijklmnopqrstuvwxyz1234567890

Press Enter to Continue
```

**在另一个终端窗口**，去你的 DNS 服务商（阿里云、Cloudflare、DNSPod 等）管理后台，添加这条 TXT 记录，等待几分钟让 DNS 生效，然后回到 certbot 按回车。验证通过后证书就签发了。

如果你用的是主流 DNS 服务商，certbot 还有**自动化的 DNS 插件**，不用手动去控制台改：

```bash
# Cloudflare
sudo certbot certonly --dns-cloudflare \
    --dns-cloudflare-credentials ~/.secrets/cloudflare.ini \
    -d "*.example.com" -d example.com

# 阿里云 DNS（需要安装插件：pip install certbot-dns-aliyun）
sudo certbot certonly --dns-aliyun \
    --dns-aliyun-credentials ~/.secrets/aliyun.ini \
    -d "*.example.com" -d example.com
```

### 五、自动续期

Let's Encrypt 证书只有 90 天有效期。好消息是 certbot 安装时会自动创建续期任务。

查看自动续期是否配置了：

```bash
# systemd timer 方式（Ubuntu 18.04+, CentOS 7+ 使用）
sudo systemctl list-timers | grep certbot

# 或 cron 方式（老版本）
sudo ls /etc/cron.d/certbot
```

手动测试续期（不真正续期，只是测试）：

```bash
sudo certbot renew --dry-run
```

如果测试通过，说明你的证书到期时会自动续期。实际续期流程：

```bash
# certbot 检查所有 /etc/letsencrypt/live/ 下的证书
# 如果快过期了（< 30 天），自动续期
sudo certbot renew
```

**续期后自动重载 Web 服务器**：

在 certbot 的续期配置中指定重载命令。编辑 `/etc/letsencrypt/renewal/example.com.conf`，在 `[renewalparams]` 部分添加：

```
renew_hook = systemctl reload nginx
```

或者在 `/etc/letsencrypt/cli.ini` 中全局配置：

```
# 续期成功后自动重载 nginx
deploy-hook = systemctl reload nginx
```

### 六、常用的 certbot 命令速查

```bash
# 查看所有已签发的证书
sudo certbot certificates

# 查看某域名的证书详情
sudo certbot certificates -d example.com

# 删除某个证书
sudo certbot delete --cert-name example.com

# 吊销证书（如私钥泄露）
sudo certbot revoke --cert-path /etc/letsencrypt/live/example.com/cert.pem

# 更新 certbot 自身
sudo pip install --upgrade certbot
# 或 snap refresh certbot
```

### 七、速率限制（Rate Limits）

Let's Encrypt 有一些限制，了解它们免得撞墙：

| 限制 | 额度 | 说明 |
|------|------|------|
| 同一域名每周证书数 | 50 张 | 一般够用 |
| 同一域名每 3 小时验证次数 | 5 次 | 连续失败后要等 |
| 通配符证书 | 仅 DNS 验证 | 无法用 HTTP 验证 |
| 同一 IP 每小时注册 | 10 个账户 | 对大多数够用 |

如果撞了限，等就好了。正式环境建议先用 `--dry-run` 测试，`--dry-run` 走的是 staging 环境，不受生产限速。

```bash
# 干跑测试
sudo certbot certonly --dry-run --webroot -w /var/www/html -d example.com
```

### 八、手动续期 vs 自动续期的设计哲学

你可能会想："为什么有效期只有 90 天？一年甚至三年的不行吗？"

Let's Encrypt 的 90 天有效期是**故意的**：

1. **强迫自动化**：手工续期 90 天一次太烦了，逼你从一开始就搭建自动化续期流程
2. **缩短攻击窗口**：即使私钥泄露了，证书最多 90 天就过期。如果是三年期证书，攻击者可以用很久
3. **降低吊销依赖**：传统 CA 的证书吊销机制（CRL/OCSP）并不完美。短期证书天然减少了对吊销的依赖
4. **CT 日志时效**：证书透明度日志让短期证书更容易被监控和审计

**类比**：长期证书 = 一次性买 100 斤大米回家，吃到虫蛀了还在吃。短期证书 = 每次只买 1 斤，吃完再买，永远新鲜。

## 动手试试

1. 如果你有公网域名和服务器，安装 certbot 并为你的域名申请第一张免费证书
2. 如果没有公网服务器，用 `certbot --dry-run` 体验一下申请流程（不会真正签发）
3. 运行 `sudo certbot certificates` 查看证书信息
4. 运行 `sudo certbot renew --dry-run` 测试自动续期是否正常
5. 将 `fullchain.pem` 读到屏幕上，用 `openssl x509 -text -in /etc/letsencrypt/live/你的域名/fullchain.pem | head -30` 查看证书详情
6. 访问 `https://crt.sh/?q=你的域名`，查看你的证书在 CT 日志中的公开记录

## 本节小结

Let's Encrypt 通过 ACME 协议自动验证域名所有权并提供免费证书。HTTP 验证需 80 端口开放，DNS 验证支持通配符且更灵活。90 天有效期是为安全设计的，certbot 自动续期确保永不过期。用 `sudo certbot --nginx -d 域名` 一行命令就能给你的网站加上 HTTPS。

## 下一节预告

拿到证书后，我们学习将证书部署到 Nginx，配置 HTTP/2、TLS 1.3、安全头部——打造一个评分 A+ 的 HTTPS 站点。
