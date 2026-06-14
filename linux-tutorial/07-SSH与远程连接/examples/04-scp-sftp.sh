#!/bin/bash
# ========================================
# 04-scp-sftp.sh — SCP 和 SFTP 文件传输演示
# ========================================
# 功能：演示 scp、sftp、rsync 的文件传输用法
# 用法：./04-scp-sftp.sh
# 注意：本脚本创建本地演示文件，不连接远程服务器
# ========================================

echo "==========================================="
echo "  SCP / SFTP / rsync 文件传输演示"
echo "==========================================="
echo ""

# --------------------------------------------------
# 创建演示用的测试文件
# --------------------------------------------------
DEMO_DIR="/tmp/scp_sftp_demo_$$"
mkdir -p "$DEMO_DIR/subdir"
echo "这是文件A的内容" > "$DEMO_DIR/file_a.txt"
echo "这是文件B的内容" > "$DEMO_DIR/file_b.txt"
echo "子目录中的文件" > "$DEMO_DIR/subdir/file_c.txt"

echo "演示数据已创建在：$DEMO_DIR"
ls -laR "$DEMO_DIR/"
echo ""

# --------------------------------------------------
# 一、SCP：安全复制
# --------------------------------------------------
echo "--- 1. SCP（Secure Copy）---"
echo ""

cat << 'EOF'
SCP 基于 SSH 协议，用于在本地和远程之间复制文件。

类比：快递寄送
  你打包好文件，快递员上门取件，运送到目的地。
  SCP 在"运输"过程中全程加密，就像快递使用了防篡改密封箱。

基本语法：

  scp [选项] 源路径 目标路径

源路径或目标路径中，远程路径格式为：user@host:路径

==================== 本地 → 远程（上传） ====================

  # 上传单个文件
  scp local_file.txt user@host:/remote/path/

  # 上传整个目录（-r 递归）
  scp -r local_dir/ user@host:/remote/path/

  # 上传并保留原始文件的修改时间和权限
  scp -p local_file.txt user@host:/remote/path/

  # 上传多个文件
  scp file1.txt file2.txt user@host:/remote/path/

  # 指定端口
  scp -P 2222 local_file.txt user@host:/remote/path/
  # 注意：SCP 用 -P（大写），SSH 用 -p（小写），别搞混！

==================== 远程 → 本地（下载） ====================

  # 下载单个文件
  scp user@host:/remote/path/file.txt ./local_dir/

  # 下载整个目录
  scp -r user@host:/remote/dir/ ./local_dir/

  # 下载多个文件（用花括号）
  scp user@host:"/var/log/{syslog,auth.log}" ./logs/

==================== 远程 → 远程（中转） ====================

  # 从服务器A复制到服务器B
  scp userA@hostA:/path/file userB@hostB:/path/

  # 用 -3 让数据走本地中转（默认是A直接传到B）
  scp -3 userA@hostA:/path/file userB@hostB:/path/

==================== 常用选项 ====================

  -r      递归复制整个目录
  -p      保留文件属性（修改时间、权限）
  -P PORT 指定 SSH 端口（大写！）
  -C      传输时压缩（慢速网络有用）
  -q      安静模式（不显示进度）
  -v      详细模式（调试用）
  -l N    限制带宽为 N Kbit/s（避免占满网络）
EOF

echo ""

# --------------------------------------------------
# 二、本地 SCP 模拟演示
# --------------------------------------------------
echo "--- 2. 本地 SCP 效果模拟 ---"
echo ""

# 模拟"上传"（本地到本地）
LOCAL_BACKUP="/tmp/scp_demo_backup_$$"
mkdir -p "$LOCAL_BACKUP"

echo "模拟 scp 上传："
echo "  命令：scp $DEMO_DIR/file_a.txt user@host:/backup/"
echo "  效果如下（用 cp 模拟）"

cp "$DEMO_DIR/file_a.txt" "$LOCAL_BACKUP/"
echo "  已'上传' file_a.txt -> $LOCAL_BACKUP/"

# 模拟"递归上传目录"
echo ""
echo "模拟 scp -r 上传目录："
echo "  命令：scp -r $DEMO_DIR/ user@host:/backup/"
cp -r "$DEMO_DIR"/* "$LOCAL_BACKUP/" 2>/dev/null
echo "  已'上传'整个目录 -> $LOCAL_BACKUP/"
ls -la "$LOCAL_BACKUP/"

rm -rf "$LOCAL_BACKUP"

# --------------------------------------------------
# 三、SFTP：交互式文件传输
# --------------------------------------------------
echo ""
echo "--- 3. SFTP（SSH File Transfer Protocol）---"
echo ""

cat << 'EOF'
SFTP 基于 SSH，提供一个交互式的文件传输界面。

类比：FTP 客户端的安全版本
  如果你用过 FTP 客户端（如 FileZilla），SFTP 就是它的安全版。
  所有命令都在加密通道内执行。

连接：
  sftp user@host
  sftp -P 2222 user@host   # 指定端口

连接后进入交互式界面，常用命令：

  === 导航 ===
  pwd              显示远程当前目录
  lpwd             显示本地当前目录
  cd /remote/path  切换远程目录
  lcd /local/path  切换本地目录
  ls               列出远程目录内容
  lls              列出本地目录内容

  === 传输 ===
  get remote.txt           下载文件到本地当前目录
  get remote.txt local.txt 下载并重命名
  get -r remote_dir/       递归下载目录

  put local.txt            上传文件到远程当前目录
  put local.txt remote.txt 上传并重命名
  put -r local_dir/        递归上传目录

  === 批量操作 ===
  mget *.log        下载所有 .log 文件
  mput *.txt        上传所有 .txt 文件

  === 其他 ===
  !command          在本地 Shell 执行命令
  help              显示帮助
  bye / exit / quit 退出 SFTP
  version           显示 SFTP 版本

非交互式用法（一条命令完成传输）：

  sftp user@host << EOF
  put local_file.txt /remote/path/
  get /remote/log.txt ./local/
  bye
  EOF

  # 或直接指定要下载的文件
  sftp user@host:/remote/file.txt ./local/
EOF

echo ""

# --------------------------------------------------
# 四、rsync：增量同步
# --------------------------------------------------
echo "--- 4. rsync：增量同步利器 ---"
echo ""

# 检查 rsync 是否安装
if command -v rsync &>/dev/null; then
    echo "rsync 已安装：$(rsync --version | head -1)"
else
    echo "rsync 未安装"
    echo "安装方法：sudo apt install rsync"
fi

echo ""
cat << 'EOF'
rsync 不是一个 SSH 工具，但它可以通过 SSH 传输，是生产环境中最重要
的文件同步工具之一。

类比：快递寄送中的"续重"机制
  scp 每次都传完整的文件，就像每次寄送都重新打包一整个箱子。
  rsync 只传"变化的部分"，就像第一次寄完整箱子，之后只寄"多出来
  或改过的部分"。省流量、省时间。

为什么 rsync 比 scp 好？
  1. 增量传输：只传输有变化的文件
  2. 断点续传：传输中断后可恢复
  3. 可选择性同步：可以用 --exclude 排除不需要的文件
  4. 删除目标端多余文件：--delete 选项保持两端完全一致

基本语法：

  rsync [选项] 源 目标

==================== 本地同步 ====================

  # 同步目录（本地到本地）
  rsync -av /source/dir/ /dest/dir/

  # 末尾的 / 很重要！
  # /source/dir/   → 同步目录内容
  # /source/dir    → 同步目录本身

==================== 远程同步（通过 SSH）====================

  # 本地 → 远程
  rsync -avz /local/dir/ user@host:/remote/dir/

  # 远程 → 本地
  rsync -avz user@host:/remote/dir/ /local/dir/

==================== 常用选项详解 ====================

  -a    归档模式（保留权限、时间戳、符号链接等）
        相当于 -rlptgoD
  -v    详细输出（看到底在传哪些文件）
  -z    传输时压缩
  -P    显示进度 + 支持断点续传（= --partial --progress）
  -n    干跑（dry-run）：只显示会做什么，不真的执行
  --delete
        删除目标端多余的文件
        （让目标端和源端完全一致）
  --exclude='*.log'
        排除特定模式的文件
  --exclude-from=exclude.txt
        从文件读取排除列表
  --max-size=10M
        跳过大于 10M 的文件
  --bwlimit=1000
        限制带宽为 1000 KB/s
  -e 'ssh -p 2222'
        指定 SSH 选项（如非标准端口）
  --link-dest=DIR
        硬链接去重（增量备份神器）

==================== 生产环境常用组合 ====================

  # 网站文件同步（最常用）
  rsync -avzP --delete /var/www/ user@server:/var/www/

  # 备份（先干跑检查，再真执行）
  rsync -avzn --delete /source/ user@host:/backup/   # 先看效果
  rsync -avz --delete /source/ user@host:/backup/    # 确认后执行

  # 限速同步（避免占满带宽）
  rsync -avzP --bwlimit=5000 /bigdata/ user@host:/backup/

  # 增量备份（利用 --link-dest）
  rsync -av --link-dest=../previous_backup /data/ /backups/current/
EOF

echo ""

# --------------------------------------------------
# 五、rsync 本地演示
# --------------------------------------------------
echo "--- 5. rsync 本地演示 ---"
echo ""

if command -v rsync &>/dev/null; then
    # 创建源目录和目标目录
    RSYNC_SRC="/tmp/rsync_src_$$"
    RSYNC_DST="/tmp/rsync_dst_$$"
    mkdir -p "$RSYNC_SRC" "$RSYNC_DST"

    # 创建一些文件
    echo "file1 content" > "$RSYNC_SRC/file1.txt"
    echo "file2 content" > "$RSYNC_SRC/file2.txt"
    echo "this is a log" > "$RSYNC_SRC/debug.log"

    echo "源目录内容："
    ls -la "$RSYNC_SRC/"

    # 第一次同步
    echo ""
    echo "第一次 rsync（排除 .log 文件）："
    rsync -av --exclude='*.log' "$RSYNC_SRC/" "$RSYNC_DST/"
    echo "目标目录内容："
    ls -la "$RSYNC_DST/"

    # 修改源文件，第二次同步
    echo ""
    echo "修改 file1.txt 后第二次 rsync（只传变化的部分）："
    echo "updated content" >> "$RSYNC_SRC/file1.txt"
    rsync -av --exclude='*.log' "$RSYNC_SRC/" "$RSYNC_DST/"
    echo "注意输出：只有 file1.txt 被传输"

    # 清理
    rm -rf "$RSYNC_SRC" "$RSYNC_DST"
else
    echo "  rsync 未安装，跳过本地演示"
fi

# --------------------------------------------------
# 六、工具对比总结
# --------------------------------------------------
echo ""
echo "==========================================="
echo "  工具对比"
echo "==========================================="
echo ""

cat << 'EOF'
+----------+-----------+-----------+-----------+----------+
| 特性     | scp       | sftp      | rsync     | 类比     |
+----------+-----------+-----------+-----------+----------+
| 传输方式 | 一次性    | 交互式    | 增量同步  |          |
+----------+-----------+-----------+-----------+----------+
| 适用场景 | 单文件/   | 浏览+选择 | 目录同步  |          |
|          | 少量文件  | 性传输    | 海量文件  |          |
+----------+-----------+-----------+-----------+----------+
| 断点续传 | 不支持    | 支持(reget| 支持      |          |
|          |           | /reput)   |           |          |
+----------+-----------+-----------+-----------+----------+
| 进度显示 | 无        | 有        | -P 有     |          |
+----------+-----------+-----------+-----------+----------+
| 加密传输 | 是(SSH)   | 是(SSH)   | -e ssh    |          |
|          |           |           | 时是      |          |
+----------+-----------+-----------+-----------+----------+

选择建议：
  传一两个文件       → scp（最快最简单）
  浏览远程文件并选择  → sftp（交互式）
  同步目录/海量文件  → rsync（省时省流量）
  定期备份          → rsync + cron

类比总结：
  scp  = 快递员上门取件，一次性送达
  sftp = 逛超市，在货架上挑挑拣拣，选好了放进购物车
  rsync = 搬家公司的分批搬运，只搬动了的东西
EOF

# 清理演示数据
rm -rf "$DEMO_DIR"

echo ""
echo "==========================================="
echo "  动手练习建议"
echo "==========================================="
echo ""
echo "  1. 创建测试文件，用 scp 传到远程服务器"
echo "  2. 用 sftp 连接远程服务器，探索交互式界面"
echo "  3. 用 rsync -avzn 先干跑，再 -avz 真正同步"
echo "  4. 用 rsync --exclude 排除特定文件类型"
echo "  5. 比较传输同一目录时 scp 和 rsync 的速度差异"
