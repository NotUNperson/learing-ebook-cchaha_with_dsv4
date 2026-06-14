# 03-07 综合练习：构建、优化并发布镜像

## 本节你会学到什么

- 将模块 03 学到的全部知识付诸实践
- 完成从 Dockerfile 到 Docker Hub 的完整发布流程
- 实际体验镜像优化（瘦身）的每一步
- 掌握镜像发布的安全检查和方法

## 正文

这一节是模块 03 的总复习——我们会把一个 Python Flask 应用从 Dockerfile 编写一路做到推送到 Docker Hub，中间经历标签管理、层分析、瘦身优化、安全检查等全部环节。

### 项目概览

我们要构建一个 Flask 应用，提供两个接口：

```
GET /         → 返回 HTML 欢迎页面
GET /api/info → 返回 JSON（应用名、版本、主机名、时间）
```

项目文件已在 `examples/03-07/` 下准备好了。

### 步骤一：准备应用代码

首先看 `app.py`：

```python
from flask import Flask, jsonify, render_template_string
import socket
import os
import datetime

app = Flask(__name__)

WELCOME_HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>Docker Demo App</title>
    <style>
        body { font-family: sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
        h1 { color: #333; }
        pre { background: #f4f4f4; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Hello from Docker!</h1>
    <p>This app is running inside a Docker container.</p>
    <pre>
Hostname: {{ hostname }}
Version:  {{ version }}
Uptime:   3 days (since container boot)
    </pre>
    <p>Try the <a href="/api/info">/api/info</a> API endpoint.</p>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(
        WELCOME_HTML,
        hostname=socket.gethostname(),
        version=os.environ.get('APP_VERSION', 'dev')
    )

@app.route('/api/info')
def api_info():
    return jsonify({
        'app': 'docker-demo',
        'version': os.environ.get('APP_VERSION', 'dev'),
        'hostname': socket.gethostname(),
        'time': datetime.datetime.utcnow().isoformat() + 'Z',
        'python_version': os.environ.get('PYTHON_VERSION', 'unknown'),
        'message': 'If you see this, your Docker setup is working!'
    })

if __name__ == '__main__':
    port = int(os.environ.get('APP_PORT', 5000))
    app.run(host='0.0.0.0', port=port)
```

注意这个应用通过环境变量来配置（`APP_VERSION`、`APP_PORT`），这是容器化应用的最佳实践——配置从环境变量注入，不要写死在代码里。

### 步骤二：编写 Dockerfile（第一版——最"胖"的写法）

先写一版不做任何优化的，看看有多胖：

```dockerfile
FROM python:3.12
COPY . /app/
WORKDIR /app
RUN pip install flask
CMD ["python", "app.py"]
```

构建并查看大小：

```bash
docker build -t docker-demo:v1-fat .
docker images docker-demo
```

预期结果：约 1GB+（ubuntu 完整版 + Python + 缓存）。

### 步骤三：优化 Dockerfile（第二版——上瘦身技巧）

```dockerfile
FROM python:3.12-slim

LABEL maintainer="yourname@example.com" \
      version="1.0.0"

ARG APP_VERSION=1.0.0
ENV APP_VERSION=${APP_VERSION} \
    APP_PORT=5000 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# 依赖文件先拷贝（缓存友好）
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# 源码后拷贝
COPY app.py ./

# 非 root 用户
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
```

`requirements.txt`：

```
flask==3.0.0
```

构建：

```bash
docker build -t docker-demo:v2-slim .
docker images docker-demo
```

预期结果：约 150MB（slim 基础镜像 + Python + flask）。从 1GB+ 降到 150MB，缩小了约 7 倍。

### 步骤四：用多阶段构建（第三版——更彻底）

对于 Python 解释型语言，多阶段构建的收益不如编译型语言。但我们仍然可以用它来创建更安全的生产镜像：

```dockerfile
# 阶段一：依赖安装
FROM python:3.12-slim AS builder

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir --user -r requirements.txt

# 阶段二：运行
FROM python:3.12-slim

LABEL maintainer="yourname@example.com" \
      version="1.0.0"

ARG APP_VERSION=1.0.0
ENV APP_VERSION=${APP_VERSION} \
    APP_PORT=5000 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:${PATH}"

WORKDIR /app

# 只拷贝安装好的包（不拷贝 pip 缓存）
COPY --from=builder /root/.local /home/appuser/.local
COPY app.py ./

RUN groupadd -r appgroup && useradd -r -g appgroup appuser && \
    chown -R appuser:appgroup /app /home/appuser

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
```

### 步骤五：标签管理和推送

```bash
# 构建并打多个标签
docker build \
  --build-arg APP_VERSION=1.0.0 \
  -t docker-demo:1.0.0 \
  -t docker-demo:1.0 \
  -t docker-demo:stable \
  -t docker-demo:latest \
  .

# 查看镜像和标签
docker images docker-demo
# 可以看到：latest, stable, 1.0, 1.0.0 都指向同一个 IMAGE ID

# 标记为 Docker Hub 格式（替换 yourname 为你的 Docker ID）
docker tag docker-demo:1.0.0 yourname/docker-demo:1.0.0
docker tag docker-demo:1.0.0 yourname/docker-demo:latest
```

### 步骤六：安全检查

推送前做最后的检查：

```bash
# 检查镜像历史，确认没有敏感信息
docker history --no-trunc yourname/docker-demo:1.0.0

# 检查镜像层大小
docker history yourname/docker-demo:1.0.0

# 如果有 dive，深入分析
dive yourname/docker-demo:1.0.0

# 检查环境变量（确认没有泄露密钥）
docker inspect yourname/docker-demo:1.0.0 | jq '.[0].Config.Env'
```

### 步骤七：推送到 Docker Hub

```bash
# 登录
docker login

# 推送
docker push yourname/docker-demo:1.0.0
docker push yourname/docker-demo:latest

# 看到如下输出表示成功：
# 1.0.0: digest: sha256:abc... size: 1234
```

### 步骤八：验证发布的镜像

```bash
# 先删除本地镜像
docker rmi yourname/docker-demo:1.0.0

# 从 Docker Hub 拉取
docker pull yourname/docker-demo:1.0.0

# 运行并测试
docker run -d -p 5000:5000 --name demo-test yourname/docker-demo:1.0.0

# 测试接口
curl http://localhost:5000/
curl http://localhost:5000/api/info

# 查看日志
docker logs demo-test

# 进入容器检查
docker exec -it demo-test whoami
# 输出: appuser  （确认以非 root 运行）

# 清理
docker stop demo-test && docker rm demo-test
```

### 步骤九：使用 docker save 备份

```bash
# 把最终的镜像保存到文件（可用于离线部署）
docker save yourname/docker-demo:1.0.0 | gzip > docker-demo-1.0.0.tar.gz

# 查看文件大小
ls -lh docker-demo-1.0.0.tar.gz
```

### 完整发布检查清单（总结）

以后每次发布镜像，过一遍这个清单：

```
[ ] 基础镜像用了固定版本（不是 latest）
[ ] .dockerignore 排除了不必要的文件
[ ] COPY 顺序优化了（依赖文件在前，源码在后）
[ ] RUN 命令合并且在同一层清理了缓存
[ ] pip/npm/apt 用了 --no-cache 等效参数
[ ] 最终镜像以非 root 用户运行
[ ] CMD/ENTRYPOINT 用了 exec 形式
[ ] 配置通过 ENV 传入（不是硬编码）
[ ] 镜像标签用了语义化版本
[ ] 推送前检查了历史中没有敏感信息
[ ] 做了 docker pull + docker run 验证
```

## 动手试试

1. 进入 `examples/03-07/` 目录，依次完成步骤一到步骤九。
2. 记录每一步的镜像大小，画一个"瘦身曲线"（v1 胖版本 -> v2 slim -> v3 多阶段）。
3. 修改 `app.py`，加一个新的 API 接口（比如 `/api/echo?msg=hello`），重新构建、打标签、推送到 Docker Hub。
4. 用 `docker history` 检查你推送的最终镜像，找出还有优化空间的层（SIZE 较大的），思考怎么优化。
5. 把这个流程写成你自己的脚本——从构建到推送一步完成。

## 本节小结

从应用代码到 Docker Hub 的完整发布流程：写 Dockerfile（用最佳实践） -> 构建（多标签） -> 优化瘦身 -> 安全检查 -> 推送 -> 验证 -> 备份。掌握这个流程，你就是一个能独立交付容器化应用的开发者了。

## 模块 03 总结

恭喜你完成了 Docker 镜像管理进阶的全部 7 节内容！你现在应该能够：

- 制定合理的镜像标签策略，避开 latest 陷阱
- 理解镜像层的工作原理和写时复制机制
- 把镜像推送到 Docker Hub 和私有仓库
- 用多种技巧把镜像体积压缩到极致
- 使用 docker save/load 进行镜像迁移和备份

到这里，你已经掌握了 Docker 镜像的完整生命周期——从 Dockerfile 编写到发布上线的全部技能。下一模块我们将进入 Docker 网络和存储的世界。
