# ========== 第一阶段：构建阶段 ==========
FROM node:18-alpine AS builder

WORKDIR /app

# 先复制依赖描述文件，利用 Docker 的层缓存
# 只要 package.json 没变，RUN npm ci 就会命中缓存，不用重新下载
COPY package.json package-lock.json* ./

# ci 比 install 更快更严格，适合 CI/CD 场景
RUN npm ci --only=production && npm cache clean --force

# ========== 第二阶段：运行阶段 ==========
FROM node:18-alpine

WORKDIR /app

# 创建一个非 root 用户来运行应用
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# 只从构建阶段复制生产依赖
COPY --from=builder /app/node_modules ./node_modules

# 复制应用代码
COPY --chown=nodejs:nodejs . .

# 切换到非 root 用户
USER nodejs

EXPOSE 3000

# 用 node 直接启动，而不是 npm start，减少一层进程包裹
CMD ["node", "src/index.js"]
