# 06-04 Docker 安全最佳实践

## 本节你会学到什么

- 理解为什么容器默认以 root 运行是巨大的安全隐患
- 使用 USER 指令和 user namespace 实现权限最小化
- 用 docker scout 扫描镜像漏洞，读懂扫描报告
- 配置只读文件系统和能力（capability）限制，缩小攻击面
- 管理 secrets 的正确姿势：不要写在镜像里，不要写在环境变量里

---

## 房子安全类比

想象你住在一栋房子里。安全措施是有层次的：

- **没锁门**：Docker 默认用 root 运行容器。谁都能推门进来，进来就能翻你所有的抽屉
- **锁了门**：切换到非 root 用户。门锁了，但窗户还开着
- **锁门+关窗**：加上只读文件系统。攻击者进来了也只能看，拿不走也改不了
- **锁门+关窗+警报**：限制 Linux capability。即使攻击者突破了应用，他能做的事情也极其有限
- **锁门+关窗+警报+保险柜**：secrets 管理。最敏感的信息（密码、密钥）存在专门的保险柜里，应用只在需要时读取

每一层不会让你的房子"绝对安全"，但会让攻击成本指数级上升。黑客也是算账的：攻破一层防护只要 5 分钟，攻破五层可能要 5 天，那他大概率换下一个目标。

---

## 第一道防线：不要用 root 运行

**问题：** 绝大多数 Dockerfile 教程默认这样写：

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "index.js"]
```

这个容器里的 Node 进程是以 root 身份运行的。如果攻击者利用了一个 Node 包里的漏洞拿到了 shell，他就是容器里的 root。虽然容器本身有一些隔离，但 root 在容器里能做的事比你想象的多——比如挂载磁盘、加载内核模块（如果没限制的话）。

**修复：** 创建专用用户，权限最小化。

```dockerfile
FROM node:18-alpine
WORKDIR /app

# 创建系统用户（无登录 shell，无 home 目录）
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# 把文件的所有权给 appuser
COPY --chown=appuser:appgroup . .

# 切换用户
USER appuser

CMD ["node", "index.js"]
```

关键参数解释：
- `-S`：创建**系统用户**，不是人类登录用的，没有密码、没有 home 目录
- `-g 1001` / `-u 1001`：显式指定 UID/GID，避免不同构建产生的 UID 不一致
- `--chown`：确保文件属于 appuser，否则复制进来的文件可能属于 root

**验证：**

```bash
# 跑一个容器，看看当前用户是谁
docker run --rm node:18-alpine whoami
# 输出: root（危险！）

docker run --rm --user 1000 node:18-alpine whoami
# 输出: whoami: unknown uid 1000（但至少不是 root）
```

---

## 第二道防线：镜像漏洞扫描

**问题：** 你的镜像基于 `node:18-alpine`，但 alpine 本身可能有已知漏洞，node 也可能有。你总不能每次发布前手动去查 CVE 数据库吧？

**工具：docker scout**

Docker Desktop 内置了 `docker scout`，它能扫描镜像的每一层，告诉你有哪些已知漏洞（CVE），严重程度如何，以及修复建议。

```bash
# 扫描一个镜像
docker scout quickview express-app:latest

# 详细报告
docker scout recommendations express-app:latest

# 对比两个镜像的安全性
docker scout compare express-app:latest express-app:v2
```

输出示例：

```
Target  │  express-app:latest
  digest│  abc123...
——————————┼——————————————
## Packages and Vulnerabilities

  0 Critical, 1 High, 3 Medium, 12 Low

  ✗ HIGH    CVE-2023-xxxx  [libcrypto3]
    Affected range: <3.1.4-r2
    Fixed version  : 3.1.4-r2
```

**类比：** docker scout 就像你入住酒店前的安检——扫描房间有没有隐藏摄像头、门锁有没有被撬过的痕迹。问题发现得越早，修复成本越低。

**最佳实践：** 把扫描集成到 CI 流水线里，每次构建自动扫描。发现 critical 或 high 漏洞就阻止镜像推送。

---

## 第三道防线：只读文件系统

**问题：** 如果攻击者拿下了你的容器，他可能会在文件系统里写恶意脚本、改配置文件、或者把木马藏在临时目录。

**修复：** 用 `--read-only` 挂载只读根文件系统，只给需要写权限的目录挂 tmpfs。

```bash
docker run --read-only \
  --tmpfs /tmp \
  --tmpfs /var/run \
  -p 3000:3000 \
  express-app:latest
```

如果你的应用需要写日志到特定目录，可以用 volume 挂载：

```bash
docker run --read-only \
  -v /var/log/myapp:/var/log/app \
  -p 3000:3000 \
  express-app:latest
```

**类比：** 在博物馆参观，你可以看展品（读），但不能碰（写）。博物馆地面上有专门划定的休息区（tmpfs），你可以在那里喝水吃东西——但展品区域绝对不行。

---

## 第四道防线：限制 Linux capability

**问题：** Linux 把 root 的超级权限拆成了很多小块，每块叫一个 capability。比如：
- `CAP_SYS_ADMIN`：几乎等同于 root，能挂载文件系统、修改内核参数
- `CAP_NET_RAW`：能用原始套接字，意味着可以伪造网络包
- `CAP_SYS_PTRACE`：能跟踪和修改其他进程的内存

默认情况下，Docker 容器拥有比实际需要多得多的 capability。一个普通的 Web 应用根本不需要 `CAP_SYS_ADMIN`。

**修复：** 显式删除不需要的 capability，只保留最少的。

```bash
# 删除所有能力，然后只添加必要的
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE \
  -p 80:3000 \
  express-app:latest
```

你的 Web 应用只需要 `NET_BIND_SERVICE`（绑定低于 1024 的端口）就够了。

Docker Compose 中配置：

```yaml
services:
  app:
    image: express-app:latest
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

**类比：** 给一个实习生公司门禁卡时，你不会给他机房门禁、财务室门禁、CEO 办公室门禁——你只给他办公区的权限。Linux capability 就是这个道理：把 root 的大串钥匙拆开，只给容器需要的那一把。

---

## 第五道防线：Secrets 管理

**问题：** 数据库密码、API 密钥、TLS 证书——这些敏感信息最常见的错误是：

错误做法 1：写死在 Dockerfile 里
```dockerfile
ENV DB_PASSWORD=MySecret123  # 永远不要这样做！
```
镜像被推送后，任何人都能通过 `docker history` 看到这一层的内容。

错误做法 2：用环境变量传明文密码
```bash
docker run -e DB_PASSWORD=MySecret123 ...  # 稍好，但密码在进程列表里可见
```

**正确做法：Docker Secrets（Swarm 模式）**

```bash
# 创建 secret
echo "MySecret123" | docker secret create db_password -

# 在服务中使用
docker service create \
  --secret db_password \
  --name myapp \
  express-app:latest
```

容器里 secret 以文件形式挂载到 `/run/secrets/db_password`，应用读取文件内容即可。内存中传输，不落盘。

**Compose 中的 secrets（需要 Swarm 或使用文件模拟）：**

```yaml
# compose 文件方式（开发环境用文件）
secrets:
  db_password:
    file: ./secrets/db_password.txt

services:
  app:
    secrets:
      - db_password
```

**类比：** 环境变量传密码就像把保险柜密码写在便利贴上、贴在显示器旁边。Docker secrets 则是把密码存在保险柜里，只有保险柜钥匙（挂载权限）的人才能打开。

---

## 安全检查清单

用一个完整的 docker run 命令汇总所有安全措施：

```bash
docker run -d \
  --name secure-app \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=64M \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --memory=512M \
  --cpus=1 \
  --security-opt=no-new-privileges:true \
  -p 3000:3000 \
  express-app:latest
```

每个参数的含义：
- `--read-only`：根文件系统只读
- `--tmpfs /tmp:rw,noexec,nosuid,size=64M`：/tmp 可写，但不能执行文件、不能 suid、限制大小
- `--cap-drop=ALL`：丢掉所有能力
- `--cap-add=NET_BIND_SERVICE`：只加回端口绑定能力
- `--memory=512M`：限制内存使用，防内存耗尽攻击
- `--cpus=1`：限制 CPU，防挖矿脚本
- `--security-opt=no-new-privileges:true`：防止进程通过 setuid 提升权限

---

## 动手试试

**目标：** 扫描一个镜像的漏洞，并体验只读文件系统的效果。

1. 用 `docker scout quickview express-app:latest`（或任何一个你已有的镜像）查看漏洞报告
2. 以只读模式启动一个 alpine 容器：`docker run --rm -it --read-only alpine sh`
3. 在容器里尝试创建文件：`touch /test.txt`，观察错误信息
4. 对比：不带 `--read-only` 启动，再试 `touch /test.txt`

预计耗时：3 分钟。

---

## 本节小结

容器安全不是一道选择题，而是一道加法题：非 root 运行 + 漏洞扫描 + 只读文件系统 + 限制 capability + secrets 管理，每一层都在缩小攻击面，五层叠加才能让攻击者望而却步。

## 下一节预告

安全做好之后，是时候关注性能了。下一节我们聊怎么把镜像体积从 1GB 压到 50MB，怎么利用层缓存把构建时间从 5 分钟砍到 10 秒，以及资源限制的实际效果。
