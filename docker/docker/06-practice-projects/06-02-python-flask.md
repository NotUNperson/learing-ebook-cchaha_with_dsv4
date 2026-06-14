# 06-02 实战二：Python Flask 应用容器化全流程

## 本节你会学到什么

- 把一个 Flask 应用从零开始容器化，包含开发和生产两套配置
- 用 Gunicorn 替换 Flask 内置服务器，实现生产级并发
- 通过环境变量注入配置，实现"一次构建，到处运行"
- 理解 Python 依赖管理的坑：为什么要在 Docker 里用 pip freeze
- 对比 Flask 开发服务器和 Gunicorn 的差异，类比"便利店 vs 麦当劳厨房"

---

Flask 自带的开发服务器，就像一个便利店里只有一个收银员。顾客少的时候还行，一到高峰期就排长队了。

Gunicorn 就好比麦当劳的厨房：多个工位并行出餐，一个收银、一个炸薯条、一个做汉堡，每个人负责一小块工作，整体吞吐量是便利店的几十倍。

但 Gunicorn 不是万能的。它的设计是**同步工作模型**，每个请求占用一个 worker 进程。如果你的 API 里有耗时的同步操作（比如读大文件、调慢速外部 API），worker 会被卡住，导致其他请求也排不上队。

这时候你需要考虑异步方案（FastAPI + Uvicorn），不过那是另一个话题了。今天我们先做好 Flask + Gunicorn 的标准容器化。

---

## 1. 项目结构

```
06-02/
  Dockerfile
  .dockerignore
  requirements.txt
  app.py
  gunicorn.conf.py
```

## 2. 应用代码

一个典型的 Flask 应用，提供两个接口，外加一个故意写进去的慢接口（用于演示 Gunicorn 多 worker 的必要性）。

**requirements.txt**

```
flask==3.0.0
gunicorn==21.2.0
```

**app.py**

```python
import os
import time
from flask import Flask, jsonify

app = Flask(__name__)

# 从环境变量读取配置，提供合理的默认值
APP_NAME = os.environ.get("APP_NAME", "Flask Docker Demo")
DEBUG = os.environ.get("FLASK_DEBUG", "0") == "1"


@app.route("/")
def index():
    return jsonify({
        "app": APP_NAME,
        "message": "Hello from Flask in Docker!",
    })


@app.route("/health")
def health():
    return jsonify({"status": "ok"})


@app.route("/slow")
def slow():
    """模拟耗时操作，验证多 worker 的必要性"""
    time.sleep(3)
    return jsonify({"result": "done after 3 seconds"})


if __name__ == "__main__":
    # Flask 内置服务器，仅用于本地开发
    app.run(host="0.0.0.0", port=5000, debug=DEBUG)
```

**gunicorn.conf.py**（Gunicorn 配置文件）

```python
import os

# 绑定地址和端口
bind = f"0.0.0.0:{os.environ.get('PORT', '5000')}"

# worker 进程数：读环境变量，默认 4
workers = int(os.environ.get("GUNICORN_WORKERS", "4"))

# worker 类型：sync（同步）是 Flask 的标准选择
worker_class = "sync"

# 每个 worker 最大处理请求数，达到后自动重启，防止内存泄漏
max_requests = 1000
max_requests_jitter = 50

# 日志
accesslog = "-"   # 输出到 stdout，Docker 日志收集
errorlog = "-"
loglevel = os.environ.get("GUNICORN_LOGLEVEL", "info")

# 优雅关闭
graceful_timeout = 30
timeout = 30
```

gunicorn.conf.py 的好处是：配置作为代码管理，而不是一条长长的命令行。团队成员一看这个文件就知道 worker 数、超时等关键参数是怎么设的。

## 3. Dockerfile

延续上一节的多阶段构建思路，但 Python 生态有一点不同：我们不需要编译步骤（纯 Python 项目），所以多阶段的主要目的是**隔离构建依赖**和**减小最终镜像**。

```dockerfile
# ========== 第一阶段：构建虚拟环境和依赖 ==========
FROM python:3.11-alpine AS builder

# 安装构建 Python 包可能需要的系统依赖
RUN apk add --no-cache gcc musl-dev libffi-dev

WORKDIR /app

# 创建虚拟环境，后续直接拷贝到运行阶段
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 先复制 requirements，利用层缓存
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ========== 第二阶段：运行阶段 ==========
FROM python:3.11-alpine

WORKDIR /app

# 创建非 root 用户
RUN addgroup -S appuser && adduser -S appuser -G appuser

# 从构建阶段复制虚拟环境
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 复制应用代码
COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 5000

# 用 Gunicorn 启动，引用配置文件
CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:app"]
```

和上一节 Node.js 的做法一对比，你会发现套路完全一样：

| 步骤 | Node.js 做法 | Python 做法 |
|------|-------------|------------|
| 基础镜像 | `node:18-alpine` | `python:3.11-alpine` |
| 依赖管理 | `package.json` + `npm ci` | `requirements.txt` + `pip install` |
| 非 root 用户 | `adduser -S nodejs` | `adduser -S appuser` |
| 启动命令 | `node src/index.js` | `gunicorn app:app` |
| 端口 | `EXPOSE 3000` | `EXPOSE 5000` |

## 4. .dockerignore

```
__pycache__
*.pyc
*.pyo
.env
.git
.gitignore
*.md
.vscode
.idea
venv
.venv
*.egg-info
dist
build
```

Python 的 `__pycache__` 和 `.pyc` 是运行时自动生成的字节码，不需要打包进镜像。`venv` 目录是本地开发用的虚拟环境，更不应该进去——我们在构建阶段会在容器里重新创建。

## 5. 构建和运行

```bash
# 构建
docker build -t flask-app:latest .

# 查看镜像体积（用 alpine 大概 80-100MB）
docker images flask-app

# 开发模式运行：用 Flask 内置服务器
docker run --rm -p 5000:5000 \
  -e FLASK_DEBUG=1 \
  flask-app:latest

# 生产模式运行：用 Gunicorn（Dockerfile 默认）
docker run -d --name flask-prod \
  -p 5000:5000 \
  -e GUNICORN_WORKERS=8 \
  -e APP_NAME="Production API" \
  flask-app:latest

# 验证
curl http://localhost:5000/
curl http://localhost:5000/health
```

## 6. 验证 Gunicorn 多 worker 的效果

打开两个终端窗口，同时请求慢接口：

```bash
# 终端 1
curl http://localhost:5000/slow

# 终端 2（立即执行）
curl http://localhost:5000/health
```

如果只有 1 个 worker，第二个请求会被第一个的 3 秒阻塞卡住。有 4 个 worker 时，第二个请求会立即返回。

这就是并发处理的核心价值：**一个 worker 被阻塞，不影响其他 worker 继续服务。**

## 7. 环境变量：配置的艺术

你可能会问：为什么用环境变量而不是配置文件？

因为容器化的核心理念是"一次构建，到处运行"。如果你把配置写死在代码里，同一个镜像在开发、测试、生产三个环境就需要构建三次。而用环境变量，同一个镜像，换一套环境变量就能跑在不同的环境里。

```
# 开发环境
-e APP_NAME="Dev API" -e GUNICORN_WORKERS=2

# 生产环境
-e APP_NAME="Prod API" -e GUNICORN_WORKERS=32
```

就像同一套西装，搭配不同的领带和皮鞋，可以应对面试、婚礼、日常通勤——衣服（镜像）没变，配件（环境变量）变了。

---

## 动手试试

**目标：** 验证 worker 数量对并发的影响，并尝试修改 Dockerfile 中的基础镜像看体积变化。

1. 在 `examples/06-02/` 目录下构建镜像
2. 用 1 个 worker 启动：`docker run --rm -p 5000:5000 -e GUNICORN_WORKERS=1 flask-app:latest`
3. 打开两个终端，同时分别请求 `/slow` 和 `/health`，观察 health 是否被阻塞
4. 停止容器，改用 4 个 worker 重新启动，重复步骤 3
5. 可选：把 Dockerfile 里的 `python:3.11-alpine` 改成 `python:3.11-slim` 重新构建，对比两种基础镜像的体积差异（`docker images`）

预计耗时：5 分钟。

---

## 本节小结

Python Web 应用的容器化套路和 Node.js 一脉相承：Alpine 基础镜像 + 多阶段构建 + 非 root 用户 + 生产级 WSGI 服务器 + 环境变量配置。

## 下一节预告

下一节我们挑战全栈项目容器化：React 前端 + Express API + PostgreSQL + Redis，四个服务用 docker-compose 编排起来，涉及网络隔离、卷持久化和健康检查。
