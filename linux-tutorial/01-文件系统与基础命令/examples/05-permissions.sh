#!/bin/bash
# ============================================================================
# 05-permissions.sh
# 演示 Linux 文件权限系统
# r (读/4)、w (写/2)、x (执行/1)
# chmod 数字法 (755, 644) 和符号法 (u+x, g-w)
# 类比：公寓房门钥匙 -- 三种权限分给三类人
# ============================================================================

echo "=============================================="
echo "  Linux 文件权限演示"
echo "  r = 读 (4)    w = 写 (2)    x = 执行 (1)"
echo "  权限分三组：所有者/所属组/其他人"
echo "=============================================="
echo ""

# ============================================================================
# 创建演示目录和文件
# ============================================================================
DEMO_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t perms 2>/dev/null || echo "/tmp/perms-demo-$$")
if [ "$DEMO_DIR" = "/tmp/perms-demo-$$" ]; then
    mkdir -p "$DEMO_DIR"
fi
echo "演示目录: $DEMO_DIR"
cd "$DEMO_DIR"
echo ""

# ============================================================================
# 第一部分：看懂权限字符串
# ============================================================================
echo "=============================================="
echo "【第一部分】看懂 ls -l 的权限字符串"
echo ""

# 创建演示文件
touch regular_file.txt
chmod 644 regular_file.txt
echo "echo 'Hello from script!'" > script.sh
chmod 755 script.sh
mkdir demo_dir
chmod 755 demo_dir

echo "查看文件权限:"
echo "---"
ls -l
echo "---"
echo ""

echo "权限字符串解析（以 script.sh 为例）:"
echo ""
echo "  - rwx r-x r-x  1  user  group  size  date  script.sh"
echo "  |  |   |   |"
echo "  |  |   |   └── 其他人的权限 (r-x = 读+执行)"
echo "  |  |   └────── 所属组的权限 (r-x = 读+执行)"
echo "  |  └────────── 所有者的权限 (rwx = 读+写+执行)"
echo "  └───────────── 文件类型 (- = 普通文件, d = 目录, l = 链接)"
echo ""
echo "翻译: 所有者可以读写执行，同组可以读和执行，其他人可以读和执行"
echo ""

# 列出各种常见权限模式的示例
echo "常见权限模式示例:"
echo ""
echo "  模式    权限字符串    含义"
echo "  ----    --------      ----"
echo "  755      rwxr-xr-x    所有者全权限，其他人读+执行（可执行文件/目录）"
echo "  644      rw-r--r--    所有者可读写，其他人只读（普通文件）"
echo "  600      rw-------    只有所有者能读写（私密文件）"
echo "  700      rwx------    只有所有者全权限（私密脚本/目录）"
echo "  400      r--------    只读文件，连所有者也不能写"
echo "  777      rwxrwxrwx    所有人完全控制（不推荐，安全风险高）"
echo ""

# ============================================================================
# 第二部分：数字法 chmod（八进制）
# ============================================================================
echo "=============================================="
echo "【第二部分】chmod 数字法（八进制表示法）"
echo ""

echo "权限数值对照表:"
echo "  r = 4 (读)"
echo "  w = 2 (写)"
echo "  x = 1 (执行)"
echo "  - = 0 (无权限)"
echo ""
echo "  r+w+x = 4+2+1 = 7  (读写执行)"
echo "  r+w   = 4+2   = 6  (读写)"
echo "  r+x   = 4+1   = 5  (读执行)"
echo "  r     = 4         (只读)"
echo "  w     = 2         (只写)"
echo "  x     = 1         (只执行)"
echo ""

# 使用数字法改变权限
echo "演示：用数字法修改权限"
echo ""

# 644 -> 755
echo "1. chmod 644 -> chmod 755（给所有人加执行权限）:"
touch num_demo.txt
chmod 644 num_demo.txt
echo "   初始（644）:"
ls -l num_demo.txt
chmod 755 num_demo.txt
echo "   chmod 755 后:"
ls -l num_demo.txt
echo "   注意：从 rw-r--r-- 变成了 rwxr-xr-x"
echo ""

# 755 -> 600
echo "2. chmod 755 -> chmod 600（收归私有，只有所有者能读写）:"
chmod 600 num_demo.txt
echo "   chmod 600 后:"
ls -l num_demo.txt
echo "   注意：从 rwxr-xr-x 变成了 rw-------"
echo ""

# 600 -> 444
echo "3. chmod 600 -> chmod 444（设为只读）:"
chmod 444 num_demo.txt
echo "   chmod 444 后:"
ls -l num_demo.txt
echo "   注意：从 rw------- 变成了 r--r--r--"
echo "   所有人都只能读，没人能修改（包括所有者）"
echo ""

# ============================================================================
# 第三部分：符号法 chmod
# ============================================================================
echo "=============================================="
echo "【第三部分】chmod 符号法（字母表示法）"
echo ""

echo "语法: chmod [who][+/-/=][permission] file"
echo "  who: u(所有者) g(所属组) o(其他人) a(所有人)"
echo "  +/-/=: +添加 -移除 =精确设置"
echo "  permission: r(读) w(写) x(执行)"
echo ""

# 创建测试文件
echo "#!/bin/bash" > sym_demo.sh
echo "echo 'test'" >> sym_demo.sh
chmod 644 sym_demo.sh
echo "初始状态（644）:"
ls -l sym_demo.sh
echo ""

# u+x: 给所有者添加执行权限
echo "1. chmod u+x sym_demo.sh -- 给所有者添加执行权限:"
chmod u+x sym_demo.sh
ls -l sym_demo.sh
echo "   注意：所有者权限从 rw- 变成了 rwx"
echo ""

# g+w: 给所属组添加写权限
echo "2. chmod g+w sym_demo.sh -- 给所属组添加写权限:"
chmod g+w sym_demo.sh
ls -l sym_demo.sh
echo "   注意：组权限从 r-- 变成了 rw-"
echo ""

# o-r: 移除其他人的读权限
echo "3. chmod o-r sym_demo.sh -- 移除其他人的读权限:"
chmod o-r sym_demo.sh
ls -l sym_demo.sh
echo "   注意：其他人权限从 r-- 变成了 ---（没有任何权限）"
echo ""

# a+x: 给所有人添加执行权限
echo "4. chmod a+x sym_demo.sh -- 给所有人添加执行权限:"
chmod a+x sym_demo.sh
ls -l sym_demo.sh
echo "   注意：所有人的权限都多了 x"
echo ""

# ug-x: 移除所有者和组的执行权限
echo "5. chmod ug-x sym_demo.sh -- 移除所有者和组的执行权限:"
chmod ug-x sym_demo.sh
ls -l sym_demo.sh
echo ""

# o=r: 精确设置其他人的权限为 r（清除 w 和 x）
echo "6. chmod o=r sym_demo.sh -- 精确设置其他人权限为只读:"
chmod o=r sym_demo.sh
ls -l sym_demo.sh
echo "   注意：其他人的权限被精确设置为 r--（不管之前是什么）"
echo ""

# ============================================================================
# 第四部分：执行权限的深层理解
# ============================================================================
echo "=============================================="
echo "【第四部分】x（执行权限）的深层理解"
echo ""

echo "文件 vs 目录的 x 权限有不同含义："
echo "  对文件: 能否把这个文件当作程序运行"
echo "  对目录: 能否'穿越'这个目录（cd 进去）"
echo ""

# 演示：目录没有 x 权限就不能 cd 进入
echo "演示：目录没有 x 权限就无法进入"
mkdir no_exec_dir
chmod 666 no_exec_dir   # rw-rw-rw-（有读写但没有执行）
touch no_exec_dir/inside.txt
echo "   目录 no_exec_dir 的权限: rw-rw-rw-（有读写但没有执行）"
ls -ld no_exec_dir
echo ""
echo "   尝试 cd 进入 no_exec_dir:"
cd no_exec_dir 2>&1 || echo "   (预期报错: Permission denied)"
echo "   即使有 rw 权限，没有 x 也进不去目录！"
echo ""
echo "   恢复执行权限:"
chmod 755 no_exec_dir
cd no_exec_dir
echo "   现在能进入了，当前目录: $(pwd)"
cd "$DEMO_DIR"
echo ""

# ============================================================================
# 第五部分：实战场景
# ============================================================================
echo "=============================================="
echo "【第五部分】实战权限设置场景"
echo ""

# 场景1：创建一个可执行脚本
echo "场景1：创建一个所有人都能执行但不能修改的脚本"
cat > public_script.sh << 'EOF'
#!/bin/bash
echo "This is a public script, everyone can run it but nobody can edit it."
EOF
chmod 755 public_script.sh
echo "   权限: 755 (rwxr-xr-x)"
echo "   效果: 所有者可以修改，其他人只能执行"
ls -l public_script.sh
echo ""

# 场景2：创建一个只有自己能读写的配置文件
echo "场景2：创建只有自己能读写的私密配置文件"
echo "SECRET_KEY=abc123" > secret.conf
chmod 600 secret.conf
echo "   权限: 600 (rw-------)"
echo "   效果: 只有所有者能读写，组和其他人完全看不到"
ls -l secret.conf
echo ""

# 场景3：创建一个只读的公告文件
echo "场景3：创建一个所有人都只能读不能改的公告"
echo "公告：今天下午3点开会" > announcement.txt
chmod 444 announcement.txt
echo "   权限: 444 (r--r--r--)"
echo "   效果: 所有人都只能读，没人能修改（包括所有者）"
ls -l announcement.txt
echo ""

# 场景4：项目目录的标准权限设置
echo "场景4：项目目录的标准权限设置"
mkdir -p project/src project/docs
touch project/README.md project/src/main.py
echo ""
echo "   给目录设置 755（需要 x 才能进入）:"
find project -type d -exec chmod 755 {} \;
echo "   给文件设置 644（不需要 x）:"
find project -type f -exec chmod 644 {} \;
echo ""
echo "   结果:"
find project -exec ls -ld {} \;
echo ""

# ============================================================================
# 总结
# ============================================================================
echo "=============================================="
echo "  总结:"
echo ""
echo "  ls -l 权限解析:"
echo "  -  rwx  r-x  r--"
echo "  类型 所有者 组 其他人"
echo ""
echo "  数字法 (记这个表):"
echo "  r=4, w=2, x=1, -=0"
echo "  755 = rwxr-xr-x (可执行文件/目录)"
echo "  644 = rw-r--r-- (普通文件)"
echo "  600 = rw------- (私密文件)"
echo ""
echo "  符号法 (记这个语法):"
echo "  chmod u+x  file  给所有者加执行"
echo "  chmod g-w  file  移除组的写权限"
echo "  chmod o=r  file  设置其他人只读"
echo "  chmod a+x  file  所有人加执行"
echo ""
echo "  文件 x = 可执行    目录 x = 可进入(cd)"
echo "=============================================="

# 清理演示目录
cd /
rm -rf "$DEMO_DIR"
echo ""
echo "已清理演示目录: $DEMO_DIR"
