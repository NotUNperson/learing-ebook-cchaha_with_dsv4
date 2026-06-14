#!/bin/bash
# 用法: ./backup-volume.sh <卷名>
# 示例: ./backup-volume.sh my-data

VOLUME_NAME=$1
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -z "$VOLUME_NAME" ]; then
  echo "用法: $0 <卷名>"
  echo "示例: $0 my-data"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

echo "正在备份卷 $VOLUME_NAME ..."
docker run --rm \
  -v ${VOLUME_NAME}:/source \
  -v $(pwd)/${BACKUP_DIR}:/backup \
  alpine:latest \
  tar czf /backup/${VOLUME_NAME}_${TIMESTAMP}.tar.gz -C /source .

echo "备份完成: ${BACKUP_DIR}/${VOLUME_NAME}_${TIMESTAMP}.tar.gz"
