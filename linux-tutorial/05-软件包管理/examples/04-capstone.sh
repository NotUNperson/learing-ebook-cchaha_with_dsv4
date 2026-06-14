#!/bin/bash
# ============================================================
# 04-capstone.sh - 综合练习：从源码编译安装 Nginx
# 配套章节：05-04-综合练习.md
#
# 本脚本演示从源码编译安装 Nginx 的完整流程：
#   1. 下载 Nginx 源码 tar.gz
#   2. 安装编译依赖
#   3. ./configure 配置编译选项
#   4. make 编译
#   5. make install 安装
#   6. 创建 systemd 服务文件
#   7. 验证安装
#
# 注意：本脚本仅支持 apt 和 dnf/yum 系统。
#       需要 root 权限运行（sudo bash 04-capstone.sh）
# ============================================================

set -e

# -------------------- 可配置变量 --------------------
NGINX_VERSION="1.26.2"
NGINX_URL="https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
INSTALL_PREFIX="/usr/local/nginx"
DOWNLOAD_DIR="/tmp/nginx-install"
NGINX_USER="www-data"    # Debian/Ubuntu 默认的 web 用户
NGINX_GROUP="www-data"

# -------------------- 颜色输出 --------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_step() {
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}============================================${NC}"
}

print_info() {
    echo -e "${CYAN}[信息]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# -------------------- 权限检查 --------------------
if [ "$(id -u)" -ne 0 ]; then
    print_error "本脚本需要 root 权限运行。"
    echo "请使用：sudo bash $0"
    exit 1
fi

echo "============================================"
echo "  05-04 综合练习：从源码编译安装 Nginx"
echo "============================================"
echo ""
echo "目标版本：nginx-${NGINX_VERSION}"
echo "安装目录：${INSTALL_PREFIX}"
echo "下载目录：${DOWNLOAD_DIR}"
echo ""

# ============================================================
# 第 1 步：安装编译依赖
# ============================================================
print_step "第 1 步：安装编译依赖"

install_deps() {
    if command -v apt &>/dev/null; then
        print_info "检测到 apt 系统，安装编译工具链..."
        apt update -qq
        apt install -y -qq \
            build-essential \
            libpcre3-dev \
            libssl-dev \
            zlib1g-dev \
            wget \
            tar \
            gcc \
            make
    elif command -v dnf &>/dev/null; then
        print_info "检测到 dnf 系统，安装编译工具链..."
        dnf install -y --setopt=tsflags=nodocs \
            gcc \
            make \
            pcre-devel \
            openssl-devel \
            zlib-devel \
            wget \
            tar \
            gzip \
            perl
    elif command -v yum &>/dev/null; then
        print_info "检测到 yum 系统，安装编译工具链..."
        yum install -y \
            gcc \
            make \
            pcre-devel \
            openssl-devel \
            zlib-devel \
            wget \
            tar \
            gzip \
            perl
    else
        print_error "无法识别包管理器。请手动安装依赖：gcc, make, pcre-devel, openssl-devel, zlib-devel"
        exit 1
    fi
    print_info "依赖安装完成。"
}

install_deps

# ============================================================
# 第 2 步：创建运行 nginx 的系统用户
# ============================================================
print_step "第 2 步：创建 nginx 运行用户"

if id "$NGINX_USER" &>/dev/null; then
    print_info "用户 ${NGINX_USER} 已存在，跳过创建。"
else
    useradd -r -s /usr/sbin/nologin "$NGINX_USER" 2>/dev/null || \
    useradd -r -s /sbin/nologin "$NGINX_USER"
    print_info "已创建系统用户 ${NGINX_USER}（无登录 Shell）。"
fi

# ============================================================
# 第 3 步：下载 Nginx 源码
# ============================================================
print_step "第 3 步：下载 Nginx 源码"

mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

if [ -f "nginx-${NGINX_VERSION}.tar.gz" ]; then
    print_info "源码包已存在，跳过下载。"
else
    print_info "从 ${NGINX_URL} 下载..."
    wget -q --show-progress "$NGINX_URL" || {
        print_error "下载失败，请检查网络连接或手动下载。"
        print_info "手动下载：wget ${NGINX_URL}"
        exit 1
    }
fi

print_info "解压源码包..."
tar xzf "nginx-${NGINX_VERSION}.tar.gz"
cd "nginx-${NGINX_VERSION}"

print_info "当前工作目录：$(pwd)"
echo ""
echo "源码目录内容："
ls -la | head -15
echo ""

# ============================================================
# 第 4 步：配置编译选项 ./configure
# ============================================================
print_step "第 4 步：配置编译选项（./configure）"

print_info "configure 是一个脚本，用于："
print_info "  - 检测系统环境（编译器、库文件版本等）"
print_info "  - 设置编译参数（安装路径、启用哪些模块等）"
print_info "  - 生成 Makefile（告诉 make 怎么编译）"
echo ""

./configure \
    --prefix="${INSTALL_PREFIX}" \
    --sbin-path="${INSTALL_PREFIX}/sbin/nginx" \
    --conf-path="${INSTALL_PREFIX}/conf/nginx.conf" \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --user="${NGINX_USER}" \
    --group="${NGINX_GROUP}" \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-stream \
    --with-stream_ssl_module \
    --without-http_ssi_module \
    --without-http_autoindex_module \
    --without-http_scgi_module \
    --without-http_uwsgi_module

print_info "配置完成！Makefile 已生成。"
echo ""

# ============================================================
# 第 5 步：编译 make
# ============================================================
print_step "第 5 步：编译（make）"

# 获取 CPU 核数用于并行编译
CPU_CORES=$(nproc 2>/dev/null || echo "2")
print_info "使用 ${CPU_CORES} 个 CPU 核并行编译（make -j${CPU_CORES}）..."
print_info "编译过程约需 1-5 分钟，请耐心等待..."
echo ""

make -j"${CPU_CORES}"

print_info "编译完成！"
echo ""

# ============================================================
# 第 6 步：安装 make install
# ============================================================
print_step "第 6 步：安装（make install）"

print_info "将编译好的文件安装到 ${INSTALL_PREFIX} ..."
make install

print_info "安装完成！"

# 创建日志目录
mkdir -p /var/log/nginx
chown "${NGINX_USER}:${NGINX_GROUP}" /var/log/nginx

echo ""
echo "安装后的目录结构："
find "${INSTALL_PREFIX}" -maxdepth 2 -type d | sort
echo ""

# ============================================================
# 第 7 步：验证安装
# ============================================================
print_step "第 7 步：验证安装"

NGINX_BIN="${INSTALL_PREFIX}/sbin/nginx"

print_info "Nginx 版本信息："
"$NGINX_BIN" -v
echo ""

print_info "Nginx 编译参数："
"$NGINX_BIN" -V 2>&1 | sed 's/ --/\n  --/g'
echo ""

print_info "测试配置语法："
"$NGINX_BIN" -t
echo ""

# ============================================================
# 第 8 步：创建 systemd 服务文件
# ============================================================
print_step "第 8 步：创建 systemd 服务文件"

UNIT_FILE="/etc/systemd/system/nginx.service"

cat > "${UNIT_FILE}" << UNITEOF
[Unit]
Description=Nginx - 高性能 Web 服务器（源码编译安装）
Documentation=http://nginx.org/en/docs/
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid

# 启动前先确保 PID 文件被清理了（防止启动失败）
ExecStartPre=${INSTALL_PREFIX}/sbin/nginx -t
ExecStart=${INSTALL_PREFIX}/sbin/nginx
ExecReload=${INSTALL_PREFIX}/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT \$MAINPID

# 私密临时目录（安全加固）
PrivateTmp=true

# 自动重启策略
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
UNITEOF

print_info "Unit 文件已创建：${UNIT_FILE}"
echo ""
print_info "关键配置解读："
print_info "  Type=forking           -- Nginx 以守护进程模式运行，启动时 fork"
print_info "  PIDFile=/var/run/nginx.pid  -- 与编译时 --pid-path 保持一致"
print_info "  ExecStartPre=... -t    -- 启动前先测试配置语法，避免配错导致启动失败"
print_info "  ExecReload=... -s reload  -- 重新加载配置（不中断连接）"
print_info "  PrivateTmp=true        -- 使用独立的 /tmp 目录（安全加固）"
echo ""

# 重载 systemd 配置
systemctl daemon-reload
print_info "systemd 配置已重新加载。"
echo ""

# 启动服务
print_info "启动 Nginx 服务..."
systemctl start nginx
sleep 2

if systemctl is-active --quiet nginx; then
    print_info "Nginx 启动成功！"
else
    print_warn "Nginx 可能启动失败，请检查状态。"
fi

# 查看状态
echo ""
systemctl status nginx --no-pager -l | head -20
echo ""

# 设置开机自启
print_info "设置 Nginx 开机自启..."
systemctl enable nginx
echo ""

# ============================================================
# 第 9 步：测试
# ============================================================
print_step "第 9 步：测试 Nginx"

# 尝试用 curl 测试
if command -v curl &>/dev/null; then
    print_info "curl 测试 http://localhost:"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" != "000" ]; then
        print_info "HTTP 状态码：${HTTP_CODE}"
        echo ""
        print_info "响应头："
        curl -s -I http://localhost/ | head -10
        echo ""
        print_info "页面内容（前 20 行）："
        curl -s http://localhost/ | head -20
    else
        print_warn "curl 连接失败，请手动检查：curl http://localhost/"
    fi
else
    print_info "curl 未安装。请手动在浏览器访问 http://<服务器IP>/ 测试。"
fi
echo ""

# 检查 80 端口是否在监听
print_info "检查 80 端口监听状态："
ss -tlnp | grep -E ":80|nginx" || netstat -tlnp 2>/dev/null | grep -E ":80|nginx" || echo "（无法确认端口监听状态）"
echo ""

# ============================================================
# 第 10 步：总结
# ============================================================
print_step "安装总结"

echo "Nginx 安装信息："
echo "  版本：     ${NGINX_VERSION}"
echo "  安装目录： ${INSTALL_PREFIX}"
echo "  二进制：   ${INSTALL_PREFIX}/sbin/nginx"
echo "  配置文件： ${INSTALL_PREFIX}/conf/nginx.conf"
echo "  日志目录： /var/log/nginx/"
echo "  PID 文件： /var/run/nginx.pid"
echo ""
echo "常用操作："
echo "  systemctl start nginx       -- 启动"
echo "  systemctl stop nginx        -- 停止"
echo "  systemctl restart nginx     -- 重启"
echo "  systemctl reload nginx      -- 重新加载配置（平滑）"
echo "  systemctl status nginx      -- 查看状态"
echo "  journalctl -u nginx -f      -- 实时查看日志"
echo "  ${INSTALL_PREFIX}/sbin/nginx -s reload  -- 手动重载配置"
echo "  ${INSTALL_PREFIX}/sbin/nginx -t          -- 测试配置语法"
echo ""
echo "卸载方法（如果需要）："
echo "  systemctl stop nginx && systemctl disable nginx"
echo "  rm -rf ${INSTALL_PREFIX}"
echo "  rm -f /etc/systemd/system/nginx.service"
echo "  rm -rf /var/log/nginx"
echo "  userdel nginx  （如果有专用 nginx 用户）"
echo ""
echo "注意：与通过 apt/dnf 安装不同，源码编译的 Nginx"
echo "      不会出现在包管理器的已安装列表中。"
echo "      更新 Nginx 版本需要重新下载源码、编译、安装。"
echo ""
echo "============================================"
echo "  综合练习完成！"
echo "============================================"

# 清理下载目录
print_info "下载的源码保存在 ${DOWNLOAD_DIR}，如需清理可执行："
print_info "  rm -rf ${DOWNLOAD_DIR}"
