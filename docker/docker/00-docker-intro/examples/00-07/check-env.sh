#!/bin/bash
# check-env.sh —— Docker 环境验收检查脚本
# 模块 00 综合练习使用
# 在终端运行: bash check-env.sh

set -e

PASS=0
FAIL=0

check() {
    local desc="$1"
    shift
    echo -n "[检查] $desc ... "
    if "$@" > /dev/null 2>&1; then
        echo "通过"
        PASS=$((PASS + 1))
    else
        echo "失败"
        FAIL=$((FAIL + 1))
    fi
}

echo "========================================="
echo "  Docker 环境验收检查"
echo "========================================="
echo ""

# 1. Docker 已安装
check "docker 命令可用" docker --version

# 2. Docker 守护进程在运行
check "Docker 守护进程运行中" docker info

# 3. 能拉取镜像（用 hello-world 做快速测试）
check "能拉取镜像" docker pull hello-world

# 4. 能运行容器
check "能运行容器" docker run --rm hello-world

# 5. 能运行 alpine 容器
check "能运行 alpine 容器" docker run --rm alpine echo "test"

# 6. 能列出镜像
check "能列出本地镜像" docker images

# 7. 能列出容器
check "能列出容器列表" docker ps -a

echo ""
echo "========================================="
echo "  检查结果: 通过 $PASS / $((PASS + FAIL)), 失败 $FAIL"
echo "========================================="

if [ $FAIL -gt 0 ]; then
    echo ""
    echo "有检查未通过，请根据失败的检查项排查："
    echo "  - docker --version 失败 -> Docker 未正确安装"
    echo "  - docker info 失败     -> Docker 守护进程未运行"
    echo "  - docker pull 失败     -> 网络问题，考虑配置镜像加速器"
    echo "  - docker run 失败      -> Docker 引擎配置问题"
    exit 1
else
    echo "所有检查通过！你的 Docker 环境已准备就绪。"
    exit 0
fi
