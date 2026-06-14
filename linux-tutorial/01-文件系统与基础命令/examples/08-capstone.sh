#!/bin/bash
# ============================================================================
# 08-capstone.sh
# 综合练习：从零搭建一个完整的项目目录结构
# 综合运用本章所有知识：
#   pwd, cd, ls, mkdir, touch, cp, mv, rm
#   cat, less, head, tail, wc
#   chmod, chown, chgrp
#   ln, ln -s
# ============================================================================

echo "=============================================="
echo "  第一章综合练习：搭建 GeekApp 项目目录"
echo "  场景：模拟真实工作中从零搭建项目结构"
echo "=============================================="
echo ""

# ============================================================================
# 一、准备工作：创建练习环境
# ============================================================================
echo "【阶段一】准备工作"
echo ""

# 在临时目录下创建项目，避免污染用户家目录
PROJECT_ROOT="/tmp/geekapp-$$"
echo "项目根目录: $PROJECT_ROOT"
mkdir -p "$PROJECT_ROOT"
cd "$PROJECT_ROOT"
echo "当前位置: $(pwd)"
echo ""

# ============================================================================
# 二、创建目录结构（用 mkdir -p 和 touch）
# ============================================================================
echo "=============================================="
echo "【阶段二】创建目录结构"
echo ""

echo "正在创建子目录..."
mkdir -p src docs logs config scripts backups
echo "  已创建: src/ docs/ logs/ config/ scripts/ backups/"
echo ""

echo "正在创建文件..."
touch README.md
touch src/main.py src/utils.py src/config.example.py
touch docs/api.md docs/guide.md
touch logs/app.log logs/error.log
touch config/app.conf config/database.conf
touch scripts/start.sh scripts/stop.sh scripts/deploy.sh
touch backups/README.md

echo "已创建 $(find . -type f | wc -l) 个文件"
echo ""

echo "当前目录结构:"
find . -type f -o -type d | sort
echo ""

# ============================================================================
# 三、给文件填充初始内容
# ============================================================================
echo "=============================================="
echo "【阶段三】填充初始内容"
echo ""

# README
cat > README.md << 'READEOD'
# GeekApp

极客科技公司的核心 Web 应用项目。

## 目录结构

- src/      - 源代码
- docs/     - 项目文档
- logs/     - 运行日志
- config/   - 配置文件
- scripts/  - 运维脚本
- backups/  - 备份文件

## 快速开始

./scripts/start.sh
READEOD
echo "  README.md -- 已填充项目说明"

# Python 源代码
cat > src/main.py << 'PYEOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GeekApp 主程序入口
"""

VERSION = "1.0.0"


def main():
    print(f"GeekApp v{VERSION} 启动中...")
    print("Hello from GeekApp!")


if __name__ == "__main__":
    main()
PYEOF
echo "  src/main.py -- 已填充主程序代码"

cat > src/utils.py << 'PYEOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GeekApp 工具函数
"""

import datetime


def get_timestamp():
    """返回当前时间戳字符串"""
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def log(message):
    """打印带时间戳的日志"""
    print(f"[{get_timestamp()}] {message}")
PYEOF
echo "  src/utils.py -- 已填充工具函数"

cat > src/config.example.py << 'PYEOF'
# GeekApp 配置文件示例
# 复制此文件为 config.py 并修改实际值

DATABASE = {
    "host": "localhost",
    "port": 5432,
    "name": "geekapp",
    "user": "geekapp_user",
    "password": "请修改为真实密码",
}

SERVER = {
    "host": "0.0.0.0",
    "port": 8080,
    "debug": False,
}

LOG_LEVEL = "INFO"
PYEOF
echo "  src/config.example.py -- 已填充配置示例"

# 文档文件
cat > docs/api.md << 'DOCEOF'
# GeekApp API 文档

## 接口列表

### GET /api/health

健康检查接口，返回服务运行状态。

**响应示例:**
```json
{
    "status": "ok",
    "version": "1.0.0"
}
```

### POST /api/users

创建新用户。

**请求体:**
```json
{
    "username": "zhangsan",
    "email": "zhangsan@example.com"
}
```
DOCEOF
echo "  docs/api.md -- 已填充 API 文档"

cat > docs/guide.md << 'DOCEOF'
# GeekApp 部署指南

## 环境要求

- Python 3.10+
- PostgreSQL 14+
- Redis 7+

## 安装步骤

1. 克隆代码仓库
2. 安装依赖: `pip install -r requirements.txt`
3. 配置数据库: 复制 `config.example.py` 为 `config.py` 并修改
4. 启动服务: `./scripts/start.sh`
DOCEOF
echo "  docs/guide.md -- 已填充部署指南"

# 备份说明
cat > backups/README.md << 'BKEOD'
# 备份目录

此目录用于存放项目文件的定期备份。

备份命名规则: `{文件名}.bak.{日期}`

例如: `main.py.bak.20260515`
BKEOD
echo "  backups/README.md -- 已填充备份说明"

# 脚本文件（添加 shebang）
for script in scripts/start.sh scripts/stop.sh scripts/deploy.sh; do
    cat > "$script" << 'SCRIPTEOF'
#!/bin/bash
# GeekApp 运维脚本
# 请根据实际部署环境修改

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

SCRIPTEOF
done

# 给每个脚本添加不同的内容
cat >> scripts/start.sh << 'STREOF'

echo "正在启动 GeekApp..."
echo "项目目录: $PROJECT_DIR"
cd "$PROJECT_DIR"
python3 src/main.py
echo "GeekApp 已启动"
STREOF

cat >> scripts/stop.sh << 'STEOF'

echo "正在停止 GeekApp..."
# 查找并终止 main.py 进程
pkill -f "python3 src/main.py" && echo "GeekApp 已停止" || echo "未找到运行中的 GeekApp"
STEOF

cat >> scripts/deploy.sh << 'DPEOF'

echo "=== GeekApp 部署脚本 ==="
echo "1. 拉取最新代码..."
echo "2. 安装依赖..."
echo "3. 运行数据库迁移..."
echo "4. 重启服务: $PROJECT_DIR/scripts/stop.sh && $PROJECT_DIR/scripts/start.sh"
echo "部署完成！"
DPEOF

echo "  脚本文件已填充内容"
echo ""

# 日志文件
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] System initialized" > logs/app.log
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Welcome to GeekApp" >> logs/app.log
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] Error log initialized (for testing)" > logs/error.log
echo "  日志文件已填充示例内容"
echo ""

# ============================================================================
# 四、设置权限
# ============================================================================
echo "=============================================="
echo "【阶段四】设置文件权限"
echo ""

echo "基本策略:"
echo "  目录         -> 755 (rwxr-xr-x)"
echo "  普通文件     -> 644 (rw-r--r--)"
echo "  可执行脚本   -> 755 (rwxr-xr-x)"
echo "  日志文件     -> 664 (rw-rw-r--)"
echo "  配置文件     -> 640 (rw-r-----)"
echo "  私密配置     -> 600 (rw-------)"
echo ""

# 第一步：批量设置基础权限
echo "1. 所有目录设为 755:"
find . -type d -exec chmod 755 {} \;
echo "   find . -type d -exec chmod 755 {} \\;"
echo ""

echo "2. 所有普通文件设为 644:"
find . -type f -exec chmod 644 {} \;
echo "   find . -type f -exec chmod 644 {} \\;"
echo ""

# 第二步：特殊文件的精细权限
echo "3. 精细调整特殊文件/目录的权限:"
echo ""

# 日志目录：组可写
chmod 775 logs
echo "   logs/ -> 775 (rwxrwxr-x) -- 组可写（方便运维人员写日志）"
chmod 664 logs/app.log logs/error.log
echo "   logs/*.log -> 664 (rw-rw-r--) -- 组可读写日志文件"
echo ""

# 配置目录：更私密
chmod 750 config
echo "   config/ -> 750 (rwxr-x---) -- 只有所有者和组可进入"
chmod 640 config/app.conf
echo "   config/app.conf -> 640 (rw-r-----) -- 组只读"
chmod 600 config/database.conf
echo "   config/database.conf -> 600 (rw-------) -- 只有所有者能读写（包含密码）"
echo ""

# 备份目录：限制访问
chmod 750 backups
echo "   backups/ -> 750 (rwxr-x---) -- 备份目录限制访问"
echo ""

# 脚本：需要可执行
chmod 755 scripts/*.sh
echo "   scripts/*.sh -> 755 (rwxr-xr-x) -- 脚本需要执行权限"
echo ""

# ============================================================================
# 五、创建软链接
# ============================================================================
echo "=============================================="
echo "【阶段五】创建软链接"
echo ""

# 在项目根目录创建便利链接
ln -s logs/app.log latest.log
echo "1. ln -s logs/app.log latest.log"
echo "   效果: 在项目根目录直接能看到最新日志"
ls -l latest.log
echo ""

ln -s scripts/start.sh start
echo "2. ln -s scripts/start.sh start"
echo "   效果: ./start 即可启动项目"
ls -l start
echo ""

# 创建数据库配置的硬链接保护
ln config/database.conf config/database.conf.protected
echo "3. ln config/database.conf config/database.conf.protected"
echo "   效果: 硬链接保护数据库配置不被误删"
echo "   inode 对比（确认是同一个）:"
ls -li config/database.conf config/database.conf.protected
echo "   注意：两个文件共享同一个 inode"
echo ""

# ============================================================================
# 六、生成权限审计报告
# ============================================================================
echo "=============================================="
echo "【阶段六】生成权限审计报告"
echo ""

AUDIT_FILE="$PROJECT_ROOT/audit_report.txt"

{
    echo "=========================================="
    echo "  GeekApp 项目权限审计报告"
    echo "  生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo ""
    echo "--- 项目文件统计 ---"
    echo "总文件数: $(find . -type f | wc -l)"
    echo "总目录数: $(find . -type d | wc -l)"
    echo "代码行数(py): $(find . -name '*.py' -exec cat {} \; | wc -l)"
    echo "文档行数(md): $(find . -name '*.md' -exec cat {} \; | wc -l)"
    echo ""
    echo "--- 拥有执行权限的文件 ---"
    find . -type f -perm -u+x -exec ls -l {} \;
    echo ""
    echo "--- 其他人可写的文件（安全检查）---"
    find . -type f -perm -o+w -exec ls -l {} \; 2>/dev/null || echo "  (无，安全)"
    echo ""
    echo "--- 软链接列表 ---"
    find . -type l -exec ls -l {} \;
    echo ""
    echo "--- 各子目录文件数 ---"
    for dir in src docs logs config scripts backups; do
        if [ -d "$dir" ]; then
            count=$(find "$dir" -type f 2>/dev/null | wc -l)
            echo "  $dir/: $count 个文件"
        fi
    done
} > "$AUDIT_FILE"

chmod 644 "$AUDIT_FILE"
echo "审计报告已生成: $AUDIT_FILE"
echo ""
cat "$AUDIT_FILE"
echo ""

# ============================================================================
# 七、最终展示完整目录结构
# ============================================================================
echo "=============================================="
echo "【最终结果】完整项目目录结构（含权限）"
echo ""

echo "命令: find . -exec ls -lhd {} \; | sort"
echo "---"
find . -exec ls -lhd {} \; 2>/dev/null | sort
echo "---"
echo ""

# ============================================================================
# 八、本章命令知识总结
# ============================================================================
echo "=============================================="
echo "  第一章命令知识总览"
echo "=============================================="
echo ""
echo "  导航与查看:"
echo "    pwd              -- 当前目录（GPS 定位）"
echo "    cd               -- 切换目录（~回家, -返回, ..上级）"
echo "    ls -lah          -- 查看目录内容（最常用组合）"
echo ""
echo "  文件操作:"
echo "    touch            -- 创建空文件/更新时间戳"
echo "    mkdir -p         -- 创建多级目录"
echo "    cp -r            -- 复制文件/目录"
echo "    mv               -- 移动和重命名"
echo "    rm -rf           -- 删除（危险！小心使用）"
echo ""
echo "  查看内容:"
echo "    cat              -- 查看小文件"
echo "    less             -- 翻页浏览大文件（q退出）"
echo "    head -n          -- 看开头 N 行"
echo "    tail -f          -- 实时追踪日志"
echo "    wc -l            -- 统计行数"
echo ""
echo "  权限与所有权:"
echo "    chmod 755        -- 数字法设置权限"
echo "    chmod u+x        -- 符号法添加执行权限"
echo "    chown            -- 改变所有者（需root）"
echo "    chgrp            -- 改变所属组"
echo ""
echo "  链接:"
echo "    ln               -- 硬链接（同一inode，影分身）"
echo "    ln -s            -- 软链接（路径指针，快捷方式）"
echo ""
echo "  其他:"
echo "    find . -type f   -- 搜索文件"
echo "    history          -- 查看命令历史"
echo "    man 命令         -- 查看命令手册"
echo ""
echo "  恭喜完成第一章！"
echo "=============================================="

echo ""
echo "项目目录保留在: $PROJECT_ROOT"
echo "可以 cd 过去自由探索，不想要时 rm -rf 即可"
