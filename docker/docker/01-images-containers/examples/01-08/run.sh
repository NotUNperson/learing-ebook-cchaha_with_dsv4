#!/bin/bash
# run.sh —— 启动自定义 Nginx 网站
# 使用方法: 在 index.html 所在目录运行: bash run.sh

set -e

echo "========================================="
echo "  启动自定义 Nginx 网站 (Docker)"
echo "========================================="
echo ""

# 先停掉旧的（如果存在）
if docker ps -a --format '{{.Names}}' | grep -q '^my-website$'; then
    echo "[*] 发现旧的 my-website 容器，正在移除..."
    docker rm -f my-website > /dev/null 2>&1
    echo "[*] 旧容器已移除"
fi

# 确保 nginx:alpine 镜像存在
if ! docker images nginx:alpine --format '{{.Repository}}' | grep -q '^nginx$'; then
    echo "[*] 拉取 nginx:alpine 镜像..."
    docker pull nginx:alpine
fi

# 启动容器
echo "[*] 启动新容器..."
docker run -d \
  --name my-website \
  -p 8080:80 \
  -v "$(pwd)/index.html:/usr/share/nginx/html/index.html" \
  nginx:alpine

echo ""
echo "========================================="
echo "  网站已启动！"
echo "  请访问: http://localhost:8080"
echo "========================================="
echo ""
echo "常用命令："
echo "  查看日志: docker logs my-website"
echo "  进入容器: docker exec -it my-website sh"
echo "  停止网站: docker rm -f my-website"
echo ""
