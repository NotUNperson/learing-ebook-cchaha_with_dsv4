#!/bin/bash
# 用法: ./restore-volume.sh <卷名> <备份文件>
# 示例: ./restore-volume.sh my-data ./backups/my-data_20260515.tar.gz

VOLUME_NAME=$1
BACKUP_FILE=$2

if [ -z "$VOLUME_NAME" ] || [ -z "$BACKUP_FILE" ]; then
  echo "用法: $0 <卷名> <备份文件路径>"
  echo "示例: $0 my-data ./backups/my-data_20260515.tar.gz"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "错误: 备份文件不存在: $BACKUP_FILE"
  exit 1
fi

docker volume create $VOLUME_NAME 2>/dev/null || true

BACKUP_FILE_DIR=$(dirname "$(realpath "$BACKUP_FILE")")
BACKUP_FILE_NAME=$(basename "$BACKUP_FILE")

echo "正在恢复卷 $VOLUME_NAME ..."
docker run --rm \
  -v ${VOLUME_NAME}:/target \
  -v ${BACKUP_FILE_DIR}:/backup \
  alpine:latest \
  tar xzf /backup/${BACKUP_FILE_NAME} -C /target .

echo "恢复完成: 卷 ${VOLUME_NAME} 已从 ${BACKUP_FILE} 恢复"
