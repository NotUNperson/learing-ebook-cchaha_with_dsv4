# 03-03 推送镜像到 Docker Hub

## 本节你会学到什么

- 理解 Docker Hub 的作用和镜像仓库的概念
- 注册 Docker Hub 账号并完成 docker login
- 掌握 docker push 的完整流程
- 了解推送前的安全检查（敏感信息排查）

## 正文

### Docker Hub 是什么

Docker Hub 是 Docker 官方提供的公共镜像仓库，类似于 GitHub 之于代码。你可以把它理解成 Docker 世界的"应用商店"：

- 你之前 `docker pull nginx`，就是从 Docker Hub 下载的。
- 如果你想把自己做好的镜像分享给别人，你就要 `docker push` 上传到 Docker Hub。
- 每个用户可以有一个免费账户，不限公开仓库数量，限制一个私有仓库。

用物流行业类比：Docker Hub = 仓储中心，`docker push` = 你把货发到仓储中心，`docker pull` = 别人从仓储中心提货。镜像 = 货，标签 = 货的编号。

### 注册和登录

**第一步：注册账号**

去 [hub.docker.com](https://hub.docker.com) 注册一个账号。记下你的用户名（Docker ID），后面所有镜像都要加上这个前缀。

**第二步：登录**

```bash
docker login
```

按提示输入你的 Docker ID 和密码（或 Access Token）。

```bash
# 也可以用一行命令登录
docker login -u <你的用户名>

# 登录到其他仓库（比如你自己的私有仓库）
docker login myregistry.com:5000
```

登录成功后，认证信息保存在 `~/.docker/config.json` 中。

**安全提醒**：建议使用 Access Token（在 Docker Hub 的 Account Settings -> Security 中创建）而不是密码。Token 可以随时吊销，而且不像密码那样权限过大。

**第三步：验证登录**

```bash
docker info | grep Username
# 应该显示你的 Docker ID
```

### 镜像命名规则

要推送到 Docker Hub，镜像名必须包含你的 Docker ID：

```
docker.io/<你的DockerID>/<镜像名>:<标签>
```

简写（Docker 会自动补全 `docker.io/library/` 或 `docker.io/<用户名>/`）：

```
<你的DockerID>/<镜像名>:<标签>
```

举例：

```bash
# 假设你的 Docker ID 是 zhangsan

# 给本地镜像打上 Docker Hub 的标签
docker tag myapp:1.0.0 zhangsan/myapp:1.0.0

# 可以打多个标签
docker tag myapp:1.0.0 zhangsan/myapp:latest
```

### 推送镜像

标签打好了就可以推送：

```bash
# 推送特定标签
docker push zhangsan/myapp:1.0.0

# 推送所有标签（包括 latest）
docker push zhangsan/myapp:latest

# 直接推送仓库下所有标签（慎用）
docker push zhangsan/myapp --all-tags
```

推送过程：

```
The push refers to repository [docker.io/zhangsan/myapp]
abc123: Pushed                      ← 最上层（你的 COPY）
def456: Pushed                      ← npm install 层
ghi789: Layer already exists        ← FROM 层（别人已经推过了，跳过！）
jkl012: Layer already exists        ← Alpine 层（早就在 Docker Hub 上了）
1.0.0: digest: sha256:... size: 1234
```

注意那个 `Layer already exists`——这是层共享的好处。`node:20-alpine` 的基础层早就在 Docker Hub 上了，你不需要重复上传。Docker 会跳过已经存在的层，只上传你新增的部分。

### 验证推送结果

推送完后，你可以去 Docker Hub 网页上看到你的仓库。或者用命令行：

```bash
# 先删掉本地镜像
docker rmi zhangsan/myapp:1.0.0

# 从 Docker Hub 重新拉取
docker pull zhangsan/myapp:1.0.0

# 运行验证
docker run --rm zhangsan/myapp:1.0.0
```

如果删掉本地镜像后还能拉取并运行，说明推送完全成功。

### 推送前的安全检查（重要！）

推送前，确认你的镜像里没有敏感信息。镜像一旦推送到公共仓库，里面的内容就**公开且永久**了。即使你删掉仓库页面，也有人可能已经拉取了。

检查清单：

1. **密钥和密码**：不要在镜像里硬编码 API 密钥、数据库密码、Token。用环境变量或 Secrets。
2. **私钥文件**：`.pem`、`.key`、`.pfx` 等证书文件。
3. **内部文档**：`.env` 文件、内部配置文件。
4. **构建时留下的凭证**：ARG 传入的密码会留在镜像历史里。

验证方法：

```bash
# 启动一个临时容器，进去搜索敏感关键词
docker run --rm -it zhangsan/myapp sh
grep -r "password\|secret\|key\|token" /app/ 2>/dev/null

# 查看镜像历史，看看有没有 ARG 传入的密码
docker history --no-trunc zhangsan/myapp
```

### 描述和文档：README 和 Description

Docker Hub 支持从 GitHub 自动同步 README。在 Docker Hub 仓库页面 -> Settings -> Build Settings，关联 GitHub 仓库。

或者在 Docker Hub 页面上手动设置 Description（仓库描述），让使用者知道你的镜像怎么用。

### 完整的推送流程总结

```bash
# 1. 登录
docker login

# 2. 构建镜像（已包含 docker.io/用户名 前缀也可以）
docker build -t zhangsan/myapp:1.0.0 .

# 3. 打额外标签
docker tag zhangsan/myapp:1.0.0 zhangsan/myapp:latest

# 4. 推送
docker push zhangsan/myapp:1.0.0
docker push zhangsan/myapp:latest

# 5. 验证
docker pull zhangsan/myapp:1.0.0
```

## 动手试试

1. 注册 Docker Hub 账号，完成 `docker login`。
2. 用你之前写的某个 Dockerfile 构建镜像，打上 `你的用户名/镜像名:版本` 格式的标签。
3. 推送到 Docker Hub (`docker push`)，观察推送日志中哪些层是 "Already exists"，哪些是 "Pushed"。
4. 删掉本地镜像 (`docker rmi`)，然后从 Docker Hub 重新拉取，运行验证。
5. 用 `docker history` 检查推送的镜像，确认没有意外泄露的敏感信息。

## 本节小结

推送镜像 = 先 docker tag 打上正确的仓库标签 + docker push 上传。推送前必须检查敏感信息，因为公开仓库中的内容永久存在。层共享使推送只上传新增的部分，基础层自动复用。

## 下一节预告

下一节我们学习私有仓库——Docker Hub 私有仓库、阿里云容器镜像服务以及其他可选方案。
