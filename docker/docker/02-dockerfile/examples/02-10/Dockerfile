# ===== 阶段一：基础 =====
# 安装生产依赖，被 dev 和 prod 共用
FROM node:20.11.0-alpine3.19 AS base

# 安装 dumb-init 处理信号转发
RUN apk add --no-cache dumb-init

WORKDIR /app

# 元数据
LABEL maintainer="dev@myapp.com" \
      description="Express API server"

# 声明构建参数
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# 先拷贝依赖文件（缓存友好）
COPY package.json package-lock.json ./

# 安装所有依赖（包括 devDependencies，builder 阶段要用）
RUN npm ci && npm cache clean --force

# 创建非 root 用户
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app

# ===== 阶段二：开发 =====
FROM base AS dev

# 覆盖环境变量
ENV NODE_ENV=development

# 安装 nodemon 用于热重载
RUN npm install --save-dev nodemon

# 复制源码
COPY --chown=appuser:appgroup tsconfig.json ./
COPY --chown=appuser:appgroup src/ ./src/

USER appuser

EXPOSE 3000
CMD ["npx", "nodemon", "--exec", "ts-node", "src/index.ts"]

# ===== 阶段三：生产构建 =====
FROM base AS builder

COPY tsconfig.json ./
COPY src/ ./src/

# 编译 TypeScript
RUN npm run build

# ===== 阶段四：生产运行 =====
FROM node:20.11.0-alpine3.19 AS prod

RUN apk add --no-cache dumb-init

WORKDIR /app

LABEL maintainer="dev@myapp.com" \
      version="1.0.0"

ENV NODE_ENV=production \
    APP_PORT=3000

# 从 builder 阶段拷贝编译产物
COPY --from=builder /app/dist ./dist

# 从 base 阶段拷贝 node_modules（只有生产依赖）
COPY --from=base /app/node_modules ./node_modules

# 拷贝 package.json 作为参考
COPY package.json package-lock.json ./

# 创建非 root 用户
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

# dumb-init 作为入口，确保信号正确转发
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
