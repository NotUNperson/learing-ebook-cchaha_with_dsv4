# 演示 .dockerignore 效果的简单项目
# 构建上下文大小对比：
# 1. 不写 .dockerignore → 构建日志显示 "Sending build context: xxx MB"
# 2. 写好 .dockerignore → 构建日志显示 "Sending build context: x MB"

FROM alpine:3.20

WORKDIR /app

# 示范：如果 .dockerignore 没写对，下面的 COPY 会把 node_modules 也拷进去
COPY . .

RUN echo "Build context size matters!" && \
    ls -la /app

CMD ["sh"]

# 配套的 .dockerignore 应该至少包含：
# node_modules
# .git
# *.log
# Dockerfile
# .dockerignore
