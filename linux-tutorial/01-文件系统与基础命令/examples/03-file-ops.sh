#!/bin/bash
# ============================================================================
# 03-file-ops.sh
# 演示 touch、mkdir、cp、mv、rm 等文件操作命令
# 从创建到删除，覆盖文件操作的完整生命周期
# ============================================================================

echo "=============================================="
echo "  Linux 文件操作命令演示"
echo "  touch -- 创建文件 / 更新时间戳"
echo "  mkdir -- 创建目录"
echo "  cp    -- 复制文件和目录"
echo "  mv    -- 移动和重命名"
echo "  rm    -- 删除文件和目录（谨慎使用！）"
echo "=============================================="
echo ""

# ============================================================================
# 创建演示用的临时目录
# ============================================================================
DEMO_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t fileops 2>/dev/null || echo "/tmp/fileops-demo-$$")
if [ "$DEMO_DIR" = "/tmp/fileops-demo-$$" ]; then
    mkdir -p "$DEMO_DIR"
fi
echo "演示目录: $DEMO_DIR"
cd "$DEMO_DIR"
echo ""

# ============================================================================
# 第一部分：touch -- 创建文件和更新时间戳
# ============================================================================
echo "=============================================="
echo "【第一部分】touch -- 创建空文件 / 更新时间戳"
echo ""

# 创建单个空文件
echo "1. 创建一个空文件:"
touch hello.txt
echo "   命令: touch hello.txt"
ls -l hello.txt
echo "   注意：文件大小是 0 字节"
echo ""

# 创建多个文件
echo "2. 一次创建多个文件:"
touch file1.txt file2.txt file3.txt
echo "   命令: touch file1.txt file2.txt file3.txt"
ls -l file*.txt
echo ""

# 更新时间戳
echo "3. 触摸已存在的文件会更新时间戳:"
echo "   修改前的 hello.txt:"
ls -l hello.txt
echo "   等待 2 秒..."
sleep 2
touch hello.txt
echo "   修改后的 hello.txt（注意时间戳变了）:"
ls -l hello.txt
echo ""

# 批量创建编号文件（Bash 花括号展开特性）
echo "4. 批量创建带编号的文件:"
touch report_{1..5}.txt
echo "   命令: touch report_{1..5}.txt"
ls -1 report_*.txt
echo "   创建了 report_1.txt 到 report_5.txt"
echo ""

# ============================================================================
# 第二部分：mkdir -- 创建目录
# ============================================================================
echo "=============================================="
echo "【第二部分】mkdir -- 创建目录"
echo ""

# 创建单个目录
echo "1. 创建单个目录:"
mkdir my_project
echo "   命令: mkdir my_project"
ls -ld my_project
echo ""

# 创建多个目录
echo "2. 一次创建多个目录:"
mkdir docs images scripts
echo "   命令: mkdir docs images scripts"
ls -ld docs images scripts
echo ""

# 递归创建多级目录
echo "3. 递归创建多级目录（mkdir -p）:"
mkdir -p project/src/components
echo "   命令: mkdir -p project/src/components"
echo "   这会自动创建 project/、project/src/、project/src/components/ 三层目录"
echo "   目录结构:"
find project -type d | sort
echo ""

# 展示不加 -p 时如果父目录不存在会报错
echo "4. 不加 -p 且父目录不存在时会报错:"
mkdir a/b/c 2>&1
echo "   以上是预期的错误提示（'No such file or directory'）"
echo ""

# -p 的另一个好处：目录已存在也不报错
echo "5. mkdir -p 在目录已存在时也不会报错（安全，适合脚本）:"
mkdir -p docs
echo "   mkdir -p docs（docs 已经存在，但不会报错）"
echo ""

# ============================================================================
# 第三部分：cp -- 复制文件
# ============================================================================
echo "=============================================="
echo "【第三部分】cp -- 复制文件和目录"
echo ""

# 准备一个测试文件
echo "Hello, Linux World!" > original.txt
echo "准备了一个测试文件 original.txt，内容是:"
cat original.txt
echo ""

# 复制文件（同目录，改名字）
echo "1. 复制文件到同目录（相当于复制后重命名）:"
cp original.txt copy1.txt
echo "   命令: cp original.txt copy1.txt"
ls -l original.txt copy1.txt
echo ""

# 复制文件到另一个目录
echo "2. 复制文件到另一个目录（保留原名）:"
cp original.txt docs/
echo "   命令: cp original.txt docs/"
ls -l docs/original.txt
echo ""

# 复制文件到另一个目录并重命名
echo "3. 复制文件到另一个目录并重命名:"
cp original.txt docs/renamed.txt
echo "   命令: cp original.txt docs/renamed.txt"
ls -l docs/renamed.txt
echo ""

# 复制目录（必须加 -r）
echo "4. 复制整个目录（cp -r，递归复制）:"
cp -r project project_backup
echo "   命令: cp -r project project_backup"
echo "   目录结构:"
find project_backup -type d | sort
echo ""

# -v 选项显示复制过程
echo "5. 显示复制过程（cp -v）:"
cp -v original.txt copy2.txt
echo ""

# -a 选项保留所有属性
echo "6. 归档复制（cp -a，保留所有属性）:"
cp -a original.txt archive_copy.txt
echo "   命令: cp -a original.txt archive_copy.txt"
echo "   对比原文件和归档副本的属性:"
ls -l original.txt archive_copy.txt
echo ""

# ============================================================================
# 第四部分：mv -- 移动和重命名
# ============================================================================
echo "=============================================="
echo "【第四部分】mv -- 移动和重命名"
echo ""

# 重命名文件
echo "1. 重命名文件（在同一目录下'移动'）:"
mv copy1.txt renamed_copy.txt
echo "   命令: mv copy1.txt renamed_copy.txt"
echo "   文件列表："
ls -1 *copy* *renamed* 2>/dev/null
echo "   copy1.txt 已不复存在，变成了 renamed_copy.txt"
echo ""

# 移动文件到目录
echo "2. 移动文件到其他目录:"
mv file1.txt my_project/
echo "   命令: mv file1.txt my_project/"
ls -l my_project/file1.txt
echo ""

# 移动多个文件
echo "3. 一次移动多个文件:"
mv file2.txt file3.txt my_project/
echo "   命令: mv file2.txt file3.txt my_project/"
ls -l my_project/file*.txt
echo ""

# 移动目录
echo "4. 移动整个目录:"
mv images my_project/
echo "   命令: mv images my_project/"
ls -ld my_project/images
echo ""

# 移动并重命名
echo "5. 移动文件并同时重命名:"
mv scripts my_project/code_scripts
echo "   命令: mv scripts my_project/code_scripts"
ls -ld my_project/code_scripts
echo "   注意：scripts 目录被移动并重命名为 code_scripts"
echo ""

# ============================================================================
# 第五部分：rm -- 删除（请务必谨慎！）
# ============================================================================
echo "=============================================="
echo "【第五部分】rm -- 删除文件和目录"
echo "  * 警告：Linux 的 rm 没有回收站！删了就没了！"
echo ""

# 创建一些用于删除的演示文件
touch delete_me_1.txt delete_me_2.txt delete_me_3.txt
echo "准备了三个用于删除的文件:"
ls -1 delete_me_*.txt
echo ""

# 删除单个文件
echo "1. 删除单个文件:"
rm delete_me_1.txt
echo "   命令: rm delete_me_1.txt"
echo "   delete_me_1.txt 已被删除"
ls -1 delete_me_*.txt 2>/dev/null
echo ""

# 删除多个文件
echo "2. 删除多个文件:"
rm delete_me_2.txt delete_me_3.txt
echo "   命令: rm delete_me_2.txt delete_me_3.txt"
ls -1 delete_me_*.txt 2>/dev/null
echo "   (没有输出 = 文件都已删除)"
echo ""

# -i 交互模式
echo "3. 交互模式删除（rm -i，删除前询问）-- 推荐新手使用:"
touch safe_delete_test.txt
echo "   下面会询问你是否确认删除（本脚本自动跳过交互）:"
echo "   命令: rm -i safe_delete_test.txt"
# 在脚本中跳过实际交互
rm -f safe_delete_test.txt
echo "   (脚本中直接删除了，实际命令行中你会看到 y/n 确认)"
echo ""

# 删除目录
echo "4. 删除空目录:"
mkdir empty_dir
rmdir empty_dir
echo "   命令: rmdir empty_dir（只能删除空目录）"
echo ""

# 删除非空目录
echo "5. 删除非空目录（rm -r）:"
mkdir -p temp_dir/sub
touch temp_dir/sub/file.txt
echo "   删除前的目录结构:"
find temp_dir -type f
rm -rf temp_dir
echo "   命令: rm -rf temp_dir"
echo "   temp_dir 及其所有内容已被删除"
echo ""

# 强调安全做法
echo "6. 安全删除的最佳实践:"
echo "   a) 删除前先用 ls 确认要删除什么"
echo "      ls *.txt    # 先看看匹配了哪些文件"
echo "      rm *.txt    # 确认无误后再删除"
echo ""
echo "   b) 使用 rm -i 每次确认"
echo "      rm -i *.txt"
echo ""
echo "   c) 安装 trash-cli（模拟回收站）"
echo "      sudo apt install trash-cli"
echo "      trash file.txt   # 文件进回收站，可以还原"
echo ""
echo "   d) 重要文件先备份"
echo "      cp important.conf important.conf.bak"
echo "      # 修改 important.conf"
echo "      # 如果改错了: cp important.conf.bak important.conf"
echo ""

# ============================================================================
# 总结
# ============================================================================
echo "=============================================="
echo "  总结:"
echo ""
echo "  touch file            -- 创建空文件 / 更新时间戳"
echo "  touch f_{1..5}.txt    -- 批量创建文件"
echo "  mkdir dir             -- 创建目录"
echo "  mkdir -p a/b/c        -- 递归创建多级目录"
echo "  cp src dst            -- 复制文件"
echo "  cp -r src_dir dst     -- 复制目录（必须加 -r）"
echo "  cp -a src dst         -- 归档复制（保留属性）"
echo "  mv src dst            -- 移动文件 / 重命名文件"
echo "  rm file               -- 删除文件"
echo "  rm -r dir             -- 删除目录"
echo "  rm -i file            -- 删除前确认（推荐！）"
echo "  rmdir empty_dir       -- 删除空目录"
echo ""
echo "  * 重要：rm 没有回收站！操作前先用 ls 确认！"
echo "=============================================="

# 清理整个演示目录
cd /
rm -rf "$DEMO_DIR"
echo ""
echo "已清理演示目录: $DEMO_DIR"
