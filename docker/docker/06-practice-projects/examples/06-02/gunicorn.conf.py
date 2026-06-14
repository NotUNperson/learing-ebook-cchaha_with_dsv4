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
