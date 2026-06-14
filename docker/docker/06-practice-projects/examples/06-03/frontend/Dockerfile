# ========== 构建阶段：React 编译 ==========
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci && npm cache clean --force
COPY . .
RUN npm run build

# ========== 运行阶段：Nginx 静态服务 ==========
FROM nginx:alpine
# 把 React 构建产物放到 Nginx 的静态文件目录
COPY --from=builder /app/dist /usr/share/nginx/html
# 使用自定义 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
