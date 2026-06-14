#!/bin/bash
# WordPress + MySQL 一键部署脚本
# 用法: bash setup.sh
set -e

echo "=== 创建网络和卷 ==="
docker network create wp-network 2>/dev/null || echo "  网络 wp-network 已存在"
docker volume create wp-db-data 2>/dev/null || echo "  卷 wp-db-data 已存在"

echo ""
echo "=== 启动 MySQL ==="
docker run -d \
  --name db \
  --network wp-network \
  -v wp-db-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=somewordpress \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=wordpress \
  mysql:8.0

echo ""
echo "=== 等待 MySQL 就绪 ==="
until docker exec db mysqladmin ping -h localhost --silent; do
  echo "  等待 MySQL 启动..."
  sleep 2
done

echo "  MySQL 已就绪"

echo ""
echo "=== 启动 WordPress ==="
docker run -d \
  --name wordpress \
  --network wp-network \
  -p 8080:80 \
  -e WORDPRESS_DB_HOST=db:3306 \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=wordpress \
  -e WORDPRESS_DB_NAME=wordpress \
  wordpress:latest

echo ""
echo "=== 部署完成 ==="
echo "WordPress: http://localhost:8080"
echo ""
echo "管理命令:"
echo "  查看日志: docker logs wordpress"
echo "  查看MySQL日志: docker logs db"
echo "  停止服务: docker stop wordpress db"
echo "  启动服务: docker start wordpress db"
echo "  清理容器: docker rm -f wordpress db"
echo "  清理网络: docker network rm wp-network"
echo "  清理卷:   docker volume rm wp-db-data"
