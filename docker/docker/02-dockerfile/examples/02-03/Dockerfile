# 展示 RUN 指令两种写法和层合并
FROM alpine:3.20

# Shell 形式
RUN echo "=== Installing packages ==="

# Exec 形式（注意 JSON 数组，双引号）
RUN ["/bin/sh", "-c", "apk add --no-cache curl"]

# 层合并：多条命令用 && 连接
RUN apk add --no-cache git && \
    git --version && \
    echo "Installation complete"

# 反例对比：下面这种写法会产生 3 个层，且清理无效
# RUN apk add git
# RUN apk add curl
# RUN rm -rf /var/cache/apk/*

CMD ["sh"]
