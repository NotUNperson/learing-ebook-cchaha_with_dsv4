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
