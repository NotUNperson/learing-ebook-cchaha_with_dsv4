FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine
WORKDIR /app
RUN addgroup -S appuser && adduser -S appuser -G appuser
COPY --from=builder /app/node_modules ./node_modules
COPY --chown=appuser:appuser . .
USER appuser
EXPOSE 3001
CMD ["node", "src/index.js"]
