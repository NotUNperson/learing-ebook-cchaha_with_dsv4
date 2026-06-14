# 03-04 私有仓库

## 本节你会学到什么

- 理解为什么需要私有镜像仓库
- 了解 Docker Hub 私有仓库、阿里云 ACR 等主流方案
- 掌握连接和使用私有仓库的基本操作
- 能够根据需求选择合适的私有仓库方案

## 正文

### 为什么需要私有仓库

上一节我们把镜像推到了 Docker Hub 的公开仓库。但现实中大多数场景下，你的镜像是不想公开的：

- 公司的内部应用，代码是保密的。
- 包含商业逻辑的镜像。
- 还没开发完的半成品，不想被外界看到。
- 合规要求（金融、医疗等行业的镜像不能放公共仓库）。

用"资料柜"来类比：Docker Hub 公开仓库 = 放在大街上的公告栏（谁都能看），私有仓库 = 你公司内部带锁的文件柜（只有有钥匙的人能看）。

### 方案一：Docker Hub 私有仓库

Docker Hub 本身就提供私有仓库功能。免费账户有**1 个免费私有仓库**（2024 年的政策，具体以 Docker 官网为准）。付费后不限数量。

优点：
- 零运维，Docker 官方帮你管。
- 登录方式和公开仓库一样（`docker login`），零学习成本。
- 全球 CDN，下载速度尚可（国内可能偏慢）。

缺点：
- 免费额度只有一个私有仓库。
- 国内访问速度不稳定。
- 镜像存储在境外，某些行业可能不合规。

使用方式与公开仓库完全一样——唯一的区别是在 Docker Hub 网页上创建仓库时把 Visibility 选为 "Private"。

```bash
# 使用方式完全一样
docker login
docker tag myapp:1.0.0 zhangsan/myapp:1.0.0
docker push zhangsan/myapp:1.0.0
```

### 方案二：阿里云容器镜像服务（ACR）

阿里云容器镜像服务（Alibaba Cloud Container Registry）是国内最流行的选择之一。免费账户有 3 个命名空间，每个命名空间 300 个仓库。国内访问速度非常快。

**设置步骤：**

1. 登录 [阿里云控制台](https://cr.console.aliyun.com/)，开通容器镜像服务。
2. 创建一个命名空间（比如你的公司名或项目名）。
3. 在命名空间下创建仓库。
4. 设置访问凭证（设置固定密码或使用 RAM 子账号）。

**登录和推送：**

```bash
# 登录阿里云仓库（地址取决于你所在的 region）
docker login --username=<你的阿里云账号> registry.cn-hangzhou.aliyuncs.com

# 打标签（格式：仓库地址/命名空间/镜像名:标签）
docker tag myapp:1.0.0 registry.cn-hangzhou.aliyuncs.com/my-namespace/myapp:1.0.0

# 推送
docker push registry.cn-hangzhou.aliyuncs.com/my-namespace/myapp:1.0.0

# 拉取
docker pull registry.cn-hangzhou.aliyuncs.com/my-namespace/myapp:1.0.0
```

阿里云 ACR 的几个好用的功能：
- 镜像安全扫描（自动检测已知漏洞）。
- 镜像同步（自动从 Docker Hub、GitHub 同步镜像，可用作 Docker Hub 的"加速器"）。
- 访问控制（RAM 子账号精细控制推送/拉取权限）。
- 免密拉取（配合阿里云 ECS 或 ACK 集群，拉取自己仓库的镜像不需要手动 login）。

### 方案三：自建 Registry

如果你需要一个完全掌控的私有仓库，可以自己部署 Docker Registry：

```bash
# 用官方 registry 镜像，一秒钟搭建私有仓库
docker run -d \
  -p 5000:5000 \
  --name registry \
  -v /data/registry:/var/lib/registry \
  registry:2
```

然后就能用了：

```bash
docker tag myapp:1.0.0 localhost:5000/myapp:1.0.0
docker push localhost:5000/myapp:1.0.0
docker pull localhost:5000/myapp:1.0.0
```

但是这个方式有几个严重缺陷：
- **没有认证**：谁都能推送和拉取。
- **没有 HTTPS**：默认用 HTTP，Docker 会拒绝连接（除非你配置 insecure-registries）。
- **没有 Web 界面**：纯 API，管理不方便。

生产环境的自建 Registry 至少需要：
- TLS 证书（用 Let's Encrypt 免费获取，或者 nginx 反代 + 证书）。
- HTTP 基本认证（htpasswd）。
- 持久化存储（挂载 volume 或对象存储）。

```bash
# 带认证的 registry 启动
docker run -d \
  -p 443:443 \
  --name registry \
  -v /data/certs:/certs \
  -v /data/auth:/auth \
  -v /data/registry:/var/lib/registry \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/fullchain.pem \
  -e REGISTRY_HTTP_TLS_KEY=/certs/privkey.pem \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  registry:2
```

更好的方案是使用 Harbor（VMware 开源的企业级镜像仓库），它内置了 Web 界面、漏洞扫描、镜像复制、访问控制等功能。

### 方案四：云厂商托管方案

除了阿里云，其他主流云厂商也提供容器镜像仓库：

| 厂商 | 服务名称 | 特点 |
|------|---------|------|
| 阿里云 | ACR | 国内速度快，免费额度大 |
| 腾讯云 | TCR | 与腾讯云生态集成 |
| 华为云 | SWR | 与华为云生态集成 |
| AWS | ECR | 全球部署，与 ECS/EKS 深度集成 |
| Google Cloud | Artifact Registry | 多语言包管理（不仅 Docker） |
| Azure | ACR | 与 Azure DevOps 深度集成 |
| GitHub | GHCR | 与 GitHub Actions 无缝集成 |

如果你公司主要用某家云厂商，强烈建议用该厂商的镜像仓库——免流量费、免密拉取、VPC 内网加速。

### 如何选择

按需求选方案：

- **个人开发/开源项目**：Docker Hub 公开仓库，零成本。
- **个人私密项目**：Docker Hub 免费 1 个私有仓库，或者阿里云 ACR 免费版。
- **国内公司/团队**：阿里云 ACR 或腾讯云 TCR，速度快、有权限管理。
- **大量私有仓库/合规要求高**：自建 Harbor。
- **云厂商绑定**：就用该云厂商的镜像仓库服务。

### 私有仓库的标签格式

无论选哪种方案，标签格式都是类似的：

```
仓库地址/命名空间或用户名/镜像名:标签
```

举例：

```bash
# Docker Hub 私有仓库
docker.io/zhangsan/secret-app:v1.0

# 阿里云 ACR
registry.cn-hangzhou.aliyuncs.com/my-namespace/secret-app:v1.0

# 自建 Registry
myregistry.company.com:5000/team-a/secret-app:v1.0

# AWS ECR
123456789012.dkr.ecr.us-east-1.amazonaws.com/secret-app:v1.0
```

## 动手试试

1. 注册阿里云账号（如果没有），开通容器镜像服务 ACR，创建一个命名空间和仓库。
2. 用上一节创建的镜像，打上 ACR 的标签，登录 ACR 并推送。
3. 在另一台机器（或删掉本地镜像后），从 ACR 拉取并运行。
4. 尝试自建 Registry：`docker run -d -p 5000:5000 --name registry registry:2`，推送一个镜像上去再用 curl 验证 `curl http://localhost:5000/v2/_catalog`。

## 本节小结

私有仓库解决镜像的安全分发问题。个人开发者用 Docker Hub 私有仓库或阿里云 ACR 免费版就够了，企业用户推荐阿里云 ACR（国内）或 Harbor（自建）。无论选哪种，标签格式都是 `仓库地址/命名空间/镜像名:标签`。

## 下一节预告

下一节我们学习镜像瘦身技巧——如何把镜像体积压缩到极致，包括 Alpine 选择、层优化、缓存清理和 dive 工具的使用。
