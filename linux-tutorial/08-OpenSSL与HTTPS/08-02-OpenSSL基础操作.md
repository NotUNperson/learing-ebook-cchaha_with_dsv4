# 08-02 OpenSSL 基础操作：私钥与证书的生成和查看

## 本节你会学到什么

- 用 `openssl genrsa` 和 `openssl ecparam` 生成 RSA 和 ECDSA 私钥
- 理解私钥文件格式（PEM）和权限要求
- 用 `openssl req` 生成证书签名请求（CSR）
- 用 `openssl x509` 查看证书的完整内容
- 区分 `.pem`、`.crt`、`.key`、`.csr` 等常见文件后缀的实际含义

---

## 正文

### 一、OpenSSL 是什么

OpenSSL 是一个开源的密码学工具库和命令行工具，几乎所有 Linux 发行版都自带它。它包含了：

- 对称加密算法的实现（AES、ChaCha20 等）
- 非对称加密算法的实现（RSA、ECDSA、Ed25519 等）
- 证书的生成、签发、格式转换
- TLS/SSL 协议的实现（被 Nginx、Apache 链接使用）
- 散列函数（SHA-256、SHA-512 等）

**类比**：OpenSSL 就像一把瑞士军刀——它不是一个单一用途的工具，而是集成了密码学领域几乎所有常用功能的工具集。

确认你的系统上已经安装了它：

```bash
openssl version
# 输出类似：OpenSSL 3.0.2 15 Mar 2022 (Library: OpenSSL 3.0.2 15 Mar 2022)
```

### 二、私钥是什么

在上一节我们讲到了非对称加密需要一对密钥：公钥和私钥。

- **私钥（Private Key）**：绝密文件，只有服务器自己持有。如果私钥泄露，你的 HTTPS 加密就形同虚设——攻击者可以冒充你的网站。
- **公钥（Public Key）**：从私钥推导出来，可以包含在证书里，公开分发。

**类比**：私钥就是你的银行 U 盾，公钥就是你的银行卡号。别人知道你的卡号（公钥）只能给你打钱，但只有插上 U 盾（私钥）才能取钱。

### 三、生成第一把私钥

#### RSA 私钥

RSA 是最传统、兼容性最好的非对称加密算法。生成一把 2048 位的 RSA 私钥：

```bash
# 生成 RSA 私钥（2048 位，安全基线）
openssl genrsa -out server.key 2048

# 建议设置严格的权限
chmod 600 server.key
```

如果要更高的安全性，用 4096 位（但握手速度会慢一些）：

```bash
openssl genrsa -out server.key 4096
```

**注意**：2026 年了，至少用 2048 位，推荐 4096 位。1024 位的 RSA 已经被认为不安全。

#### ECDSA 私钥（更现代的选择）

ECDSA（椭圆曲线数字签名算法）比 RSA 更快、密钥更小、安全性相同。推荐用 prime256v1 曲线：

```bash
# 生成 ECDSA 私钥（推荐！比 RSA 更快更小）
openssl ecparam -genkey -name prime256v1 -out server.key

chmod 600 server.key
```

#### Ed25519 私钥（最新最推荐）

如果你用的软件支持（OpenSSL 1.1.1+），Ed25519 是目前最先进的：

```bash
# Ed25519 -- 最安全最快，但兼容性需要确认
openssl genpkey -algorithm Ed25519 -out server.key
```

#### 三种算法对比

| 特性 | RSA 2048 | ECDSA P-256 | Ed25519 |
|------|----------|-------------|---------|
| 安全性 | 中等 | 高 | 很高 |
| 密钥大小 | 256 字节 | 32 字节 | 32 字节 |
| 签名速度 | 慢 | 快 | 非常快 |
| 兼容性 | 最好 | 好 | 较新 |
| 推荐场景 | 最大兼容性 | 通用推荐 | 最佳性能 |

### 四、查看私钥的内容

```bash
# 以文本形式查看私钥
openssl rsa -in server.key -text -noout

# 只显示公钥部分
openssl rsa -in server.key -pubout
```

输出示例解读：

```
Private-Key: (2048 bit, 2 primes)
modulus:
    00:b5:2e:3a:...（这就是 n，RSA 的模数）
publicExponent: 65537 (0x10001)
privateExponent:
    00:8d:1f:...（这就是 d，私钥的核心机密）
prime1: ...（大质数 p）
prime2: ...（大质数 q）
```

如果你还不太了解 RSA 的数学原理，不重要。你只需要知道：私钥文件里的这些大数字绝对不能泄露。

### 五、PEM 文件格式

这是 Linux 世界里最常见的密钥和证书文件格式。打开一个 PEM 文件，你会看到这样的内容：

```
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC1Ljqn8Xv...
（Base64 编码的密钥数据，通常很长）
-----END PRIVATE KEY-----
```

**PEM** 的原意是 Privacy Enhanced Mail，是一种用 Base64 编码二进制数据的方法，外面用 `-----BEGIN xxx-----` 和 `-----END xxx-----` 包起来。本质上它就是一个**文本文件**，所以可以用 `cat` 直接看。

不同的 BEGIN/END 标记表示不同的内容类型：

| 头尾标记 | 内容 |
|---------|------|
| `BEGIN PRIVATE KEY` | 私钥（PKCS#8 格式） |
| `BEGIN RSA PRIVATE KEY` | RSA 私钥（PKCS#1 格式） |
| `BEGIN CERTIFICATE` | 证书 |
| `BEGIN CERTIFICATE REQUEST` | 证书签名请求（CSR） |
| `BEGIN PUBLIC KEY` | 公钥 |
| `BEGIN EC PRIVATE KEY` | EC 私钥 |

### 六、生成 CSR（证书签名请求）

有了私钥之后，你需要一个 **CSR（Certificate Signing Request，证书签名请求）**。这是你提交给 CA，请求它给你签发证书的申请文件。

**类比**：CSR 就是"身份证申请表"。你填好个人信息（姓名、地址、机构等），附上你的照片（公钥），提交给公安局（CA）。公安局审核后给你制作身份证（证书）。

```bash
# 生成 CSR（交互式）
openssl req -new -key server.key -out server.csr
```

执行后会进入交互式问答：

```
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Beijing
Locality Name (eg, city) []:Beijing
Organization Name (eg, company) []:My Company
Organizational Unit Name (eg, section) []:IT
Common Name (eg, your name) []:www.example.com
Email Address []:admin@example.com

# 以下两个直接回车跳过（不需要在 CSR 里设密码）
A challenge password []:
An optional company name []:
```

**最重要的字段**：
- **Common Name（CN）**：写你的域名，比如 `www.example.com`。这是传统方式。
- **Subject Alternative Name（SAN）**：现代方式，一个证书可以支持多个域名。

非交互式一键生成 CSR（推荐在脚本中使用）：

```bash
openssl req -new -key server.key -out server.csr \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=MyCompany/OU=IT/CN=www.example.com"
```

### 七、查看 CSR 内容

```bash
# 查看 CSR 的详细信息
openssl req -in server.csr -text -noout
```

输出中你会看到：

```
Subject: C=CN, ST=Beijing, L=Beijing, O=MyCompany, OU=IT, CN=www.example.com
Subject Public Key Info:
    Public Key Algorithm: rsaEncryption
        RSA Public-Key: (2048 bit)
        Modulus: ...
```

### 八、查看证书内容

当你拿到一个证书后（无论自签名还是 CA 签发的），用以下命令查看：

```bash
# 查看证书的文本内容
openssl x509 -in server.crt -text -noout

# 只看关键字段
openssl x509 -in server.crt -subject -issuer -dates -noout

# 输出示例：
# subject=C=CN, ST=Beijing, O=MyCompany, CN=www.example.com
# issuer=C=US, O=Let's Encrypt, CN=R3
# notBefore=May 15 10:00:00 2026 GMT
# notAfter=Aug 13 10:00:00 2026 GMT
```

| 参数 | 含义 |
|------|------|
| `-subject` | 证书是颁给谁的（你的域名和组织） |
| `-issuer` | 谁签发的（CA 的信息） |
| `-dates` | 有效期起止时间 |
| `-fingerprint` | 证书指纹（SHA-256 哈希） |
| `-modulus` | 公钥的模数（可以跟私钥的 modulus 对比，确认匹配） |
| `-purpose` | 这个证书可以用来干什么 |

验证私钥和证书是否配对：

```bash
# 比较两者的公钥模数（RSA）或公钥（EC）
openssl rsa -in server.key -modulus -noout | md5sum
openssl x509 -in server.crt -modulus -noout | md5sum
# 两个哈希值应该完全相同
```

### 九、证书格式转换

你可能会遇到不同的证书文件格式：

| 格式 | 后缀 | 特征 | 使用场景 |
|------|------|------|---------|
| PEM | `.pem` `.crt` `.key` | Base64 文本，`-----BEGIN...-----` | Linux/Nginx/Apache |
| DER | `.der` `.cer` | 二进制格式 | Windows IIS、Java KeyStore |
| PKCS#12 | `.pfx` `.p12` | 二进制，包含私钥+证书+CA 链 | Windows 导入 |
| PKCS#7 | `.p7b` | 二进制，只包含证书链（不含私钥） | 部分 Java 应用 |

常用转换命令：

```bash
# PEM 转 DER
openssl x509 -in server.crt -outform der -out server.der

# DER 转 PEM
openssl x509 -in server.der -inform der -outform pem -out server.pem

# 将证书和私钥打包为 PKCS#12（pfx）
openssl pkcs12 -export -out server.pfx \
    -inkey server.key -in server.crt \
    -certfile ca-bundle.crt

# 从 PKCS#12 中提取私钥和证书
openssl pkcs12 -in server.pfx -nocerts -out server.key
openssl pkcs12 -in server.pfx -clcerts -nokeys -out server.crt
```

**记法提示**：
- `-inform` / `-outform` 指定输入 / 输出格式
- `-in` / `-out` 指定输入 / 输出文件
- 转换方向：PEM <-> DER，CRT+KEY <-> PFX

### 十、文件后缀的真相

新手经常被 `.pem` `.crt` `.key` `.csr` 这些后缀搞晕。实际上：

- **`*.key`**：惯例命名，表示私钥文件。内容就是 PEM 格式。
- **`*.crt` / `*.pem`**：惯例命名，表示证书文件。内容也是 PEM 格式。
- **`*.csr`**：证书签名请求。内容也是 PEM 格式。
- **`*.pfx` / `*.p12`**：PKCS#12 格式，二进制。

**它们本质上都是 PEM 格式的文本文件**（PKCS#12 除外）。你完全可以用 `cat server.key` 看私钥内容。后缀名只是给人看的约定，程序判断文件类型靠的是文件头 `-----BEGIN xxx-----`。

**类比**：文件的扩展名就像文件夹上的标签——你可以贴"账单"或"重要"标签，但里面的纸是什么，看了才知道。`.crt` 和 `.pem` 可以互换，只要内容确实是证书就行。

## 动手试试

1. 生成一把 RSA 私钥，分别尝试 2048 和 4096 位，比较生成速度
2. 生成一把 ECDSA 私钥，查看它的内容并与 RSA 对比（大小差异很明显）
3. 用非交互模式生成一个 CSR，填写你的项目域名信息
4. 用 `openssl req -text` 查看你生成的 CSR 内容
5. 练习 PEM 和 DER 格式互转，用 `file` 命令对比转换前后的文件类型
6. 用 `md5sum` 验证私钥和对应 CSR 中的公钥是否匹配

## 本节小结

私钥是加密的根基，PEM 是通用格式。用 `openssl genrsa` / `ecparam` 生成私钥，用 `req -new` 生成 CSR 提交给 CA。`openssl x509 -text` 查看证书细节，`openssl rsa -modulus` 验证配对。后缀 `.key` `.crt` `.csr` 只是命名约定，真正区分文件类型的是 PEM 文件的 BEGIN/END 标记。

## 下一节预告

有了私钥和 CSR，下一节我们将自己搭建一个微型 CA，签发自签名证书，不花一分钱让你的本地服务器用上 HTTPS。
