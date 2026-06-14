# 展示 COPY 顺序对缓存的影响
FROM node:20-alpine

WORKDIR /app

# === 缓存友好的 COPY 顺序 ===

# 第一步：先拷贝依赖声明文件（不常变，缓存命中率高）
COPY package.json package-lock.json ./

# 第二步：安装依赖（仅在依赖声明变化时重新执行）
RUN npm ci --only=production

# 第三步：最后拷贝源码（常变，但上面两步已经缓存在）
COPY src/ ./src/

# 启动
CMD ["node", "src/index.js"]
