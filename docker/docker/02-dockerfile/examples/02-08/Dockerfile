# 多阶段构建完整示例：前端应用
# 构建 + 运行分离

# ===== 阶段一：构建 =====
FROM node:20.11.0-alpine3.19 AS builder

WORKDIR /app

# 缓存友好：先拷依赖声明
COPY package.json package-lock.json ./
RUN npm ci

# 再拷源码并构建
COPY . .
RUN npm run build

# ===== 阶段二：运行 =====
FROM nginx:1.25-alpine AS runner

# 复制自定义 nginx 配置（可选）
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# 从 builder 阶段只拿构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# 构建命令：
# docker build -t multi-stage-demo .
# docker images multi-stage-demo    # 查看镜像大小，对比单阶段构建的差异
# docker run -p 8080:80 multi-stage-demo
