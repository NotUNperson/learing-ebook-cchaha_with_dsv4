#!/bin/bash
# 清理 WordPress + MySQL 环境
# 用法: bash teardown.sh
set -e

echo "=== 停止并删除容器 ==="
docker rm -f wordpress 2>/dev/null && echo "  已删除 wordpress" || echo "  wordpress 不存在"
docker rm -f db 2>/dev/null && echo "  已删除 db" || echo "  db 不存在"

echo ""
echo "=== 容器已删除 ==="
echo ""
echo "以下资源保留（数据安全）:"
echo "  网络: wp-network (docker network ls)"
echo "  卷:   wp-db-data  (docker volume ls)"
echo ""
echo "如需彻底清理，手动执行:"
echo "  docker network rm wp-network"
echo "  docker volume rm wp-db-data"
