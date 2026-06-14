#!/bin/bash
# ============================================================================
# 07-links.sh
# 演示 Linux 硬链接和软链接的区别
# 硬链接 (ln)  -- 同一个 inode 的多个名字（类比：影分身）
# 软链接 (ln -s) -- 指向目标文件路径的独立文件（类比：快捷方式/路标）
# inode -- 文件的"身份证号"
# ============================================================================

echo "=============================================="
echo "  Linux 硬链接与软链接演示"
echo "  inode = 文件的'身份证号'"
echo "  硬链接 (ln)    = 影分身（同一份数据，多个名字）"
echo "  软链接 (ln -s) = 路标（指向目标的快捷方式）"
echo "=============================================="
echo ""

# ============================================================================
# 创建演示目录
# ============================================================================
DEMO_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t links 2>/dev/null || echo "/tmp/links-demo-$$")
if [ "$DEMO_DIR" = "/tmp/links-demo-$$" ]; then
    mkdir -p "$DEMO_DIR"
fi
echo "演示目录: $DEMO_DIR"
cd "$DEMO_DIR"
echo ""

# ============================================================================
# 第一部分：理解 inode
# ============================================================================
echo "=============================================="
echo "【第一部分】inode -- 文件的'身份证号'"
echo ""

echo "创建源文件:"
echo "Hello, Linux!" > source.txt
echo ""

echo "查看文件 inode 信息:"
echo "命令: ls -li source.txt"
ls -li source.txt
echo "  ^^^^^^ inode编号"
echo ""

echo "命令: stat source.txt（更详细的 inode 信息）"
stat source.txt
echo ""

echo "inode 包含的信息（但不包含文件名！）:"
echo "  - 文件类型和权限"
echo "  - 所有者 (uid) 和所属组 (gid)"
echo "  - 文件大小"
echo "  - 时间戳 (访问/修改/状态变更)"
echo "  - 数据块指针（数据存在硬盘的哪些位置）"
echo "  - 硬链接计数（有多少文件名指向这个 inode）"
echo ""
echo "  文件名存在哪里？存在目录里！"
echo "  目录 = 一张 {文件名 -> inode号} 的映射表"
echo ""

# ============================================================================
# 第二部分：硬链接（ln）
# ============================================================================
echo "=============================================="
echo "【第二部分】硬链接 (ln) -- 给同一个 inode 起多个名字"
echo "  类比：影分身术 -- 本体和分身都是同一个人"
echo ""

echo "1. 创建硬链接:"
ln source.txt hard.txt
echo "   命令: ln source.txt hard.txt"
echo ""

echo "2. 查看两个文件的 inode（注意它们相同）:"
ls -li source.txt hard.txt
echo ""
echo "   source.txt 和 hard.txt 共享同一个 inode！"
echo "   它们不是'复制'的关系，而是'同一个文件的另一个名字'"
echo ""

echo "3. 查看硬链接计数（ls -l 的第二列）:"
ls -l source.txt hard.txt
echo "   链接计数 = 2（有两个名字指向这个 inode）"
echo ""

echo "4. 修改硬链接，源文件也会变化:"
echo "  这是第二行" >> hard.txt
echo "   执行: echo '这是第二行' >> hard.txt"
echo "   source.txt 的内容:"
cat source.txt
echo "   注意：source.txt 也变了！因为它们是同一份数据"
echo ""

echo "5. 修改源文件，硬链接也会变化:"
echo "  这是第三行" >> source.txt
echo "   hard.txt 的内容:"
cat hard.txt
echo ""

echo "6. 删除源文件，硬链接仍然有效:"
rm source.txt
echo "   执行: rm source.txt"
echo "   查看 hard.txt 还在不在:"
ls -l hard.txt
echo "   hard.txt 的内容仍是完整的:"
cat hard.txt
echo "   原因：inode 还有 hard.txt 这个文件名指向它，数据不会被释放"
echo ""

echo "7. 硬链接的限制:"
echo "   a) 不能给目录创建硬链接（防止循环引用）"
mkdir test_dir 2>/dev/null
echo "      尝试: ln test_dir hard_dir"
ln test_dir hard_dir 2>&1 || true
echo ""
echo "   b) 不能跨文件系统（inode 在不同分区/磁盘上不互通）"
echo "      /home 和 /tmp 如果在不同分区，就不能互建硬链接"
echo ""
echo "   c) 不直观（从 ls 输出看不出哪个是'原文件'）"
echo "      硬链接和源文件在 ls -l 中看起来完全一样"
echo ""

# 重新创建源文件继续演示
echo "Hello, Linux!" > source.txt
echo "  重新创建 source.txt 继续演示"
echo ""

# ============================================================================
# 第三部分：软链接 / 符号链接（ln -s）
# ============================================================================
echo "=============================================="
echo "【第三部分】软链接 (ln -s) -- 指向目标的'路标'"
echo "  类比：Windows 快捷方式、路边的指路牌"
echo ""

echo "1. 创建软链接:"
ln -s source.txt soft.txt
echo "   命令: ln -s source.txt soft.txt"
echo ""

echo "2. 查看软链接（注意独立的 inode 和 l 前缀）:"
ls -li source.txt soft.txt
echo ""
echo "   soft.txt 有自己独立的 inode (不同于 source.txt 的 inode)"
echo "   l 前缀表示这是一个符号链接 (symbolic link)"
echo "   soft.txt -> source.txt 表示链接指向的目标"
echo ""

echo "3. 软链接的内容就是目标路径:"
echo "   命令: readlink soft.txt"
readlink soft.txt
echo "   软链接本身只是一个'路径文本'文件"
echo ""

echo "4. 通过软链接访问，会转发到目标文件:"
cat soft.txt
echo "   输出和 cat source.txt 一样（系统自动转发）"
echo ""

echo "5. 软链接可以链接目录（硬链接不行）:"
ln -s test_dir soft_dir
ls -ld soft_dir
echo "   链接到目录的软链接，可以 cd 进入:"
cd soft_dir 2>/dev/null && echo "   成功进入！当前目录: $(pwd)" && cd "$DEMO_DIR"
echo ""

echo "6. 删除源文件，软链接失效:"
rm source.txt
echo "   执行: rm source.txt"
echo "   尝试 cat soft.txt:"
cat soft.txt 2>&1 || true
echo "   错误信息: No such file or directory（路标指向了空气）"
echo ""
ls -l soft.txt 2>/dev/null
echo "   软链接还在，但目标不存在了（'死链接' / dangling symlink）"
echo ""

# ============================================================================
# 第四部分：软链接 vs 硬链接 对比
# ============================================================================
echo "=============================================="
echo "【第四部分】软链接 vs 硬链接 全面对比"
echo ""

# 重新创建源文件
echo "Hello, Linux!" > source.txt

echo "对比表格:"
echo ""
echo "  特性            | 硬链接 (ln)         | 软链接 (ln -s)"
echo "  ----------------|---------------------|---------------------"
echo "  本质            | 同一个 inode 的别名   | 独立的路径指针文件"
echo "  inode           | 共享                 | 独立"
echo "  跨文件系统      | 不行                 | 可以"
echo "  链接目录        | 不行                 | 可以"
echo "  删源文件后      | 数据还在             | 链接失效（死链接）"
echo "  ls -l 显示      | - (看起来是普通文件)  | l (链接标识)"
echo "  Windows 类比    | 没有直接对应         | 桌面快捷方式 (.lnk)"
echo "  动漫类比        | 影分身               | 路标/指路牌"
echo ""

# 演示跨文件系统
echo "硬链接不能跨文件系统的演示:"
echo "  如果 /home 和 /tmp 在不同分区:"
echo "  ln /home/user/file.txt /tmp/hard_link.txt"
echo "  会报错: Invalid cross-device link"
echo ""
echo "但软链接可以:"
echo "  ln -s /home/user/file.txt /tmp/soft_link.txt"
echo "  完全没问题，因为软链接只是存了一个路径字符串"
echo ""

# ============================================================================
# 第五部分：软链接的实用场景
# ============================================================================
echo "=============================================="
echo "【第五部分】软链接的实际应用场景"
echo ""

echo "场景1: 给深层目录的程序创建'桌面快捷方式'"
echo "  ln -s /opt/myapp/bin/start.sh ~/start-myapp"
echo "  效果: 不需要每次都输入完整路径"
echo ""

echo "场景2: 版本切换（更新库版本时只改链接）"
echo "  ln -s python3.12 /usr/local/bin/python3"
echo "  当升级到 3.13 时："
echo "  rm /usr/local/bin/python3"
echo "  ln -s python3.13 /usr/local/bin/python3"
echo "  所有调用 python3 的地方会自动使用新版本"
echo ""

echo "场景3: 管理配置文件（dotfiles）"
echo "  把所有配置文件集中到一个 git 仓库："
echo "  ln -s ~/dotfiles/vimrc ~/.vimrc"
echo "  ln -s ~/dotfiles/bashrc ~/.bashrc"
echo "  这样配置文件可以版本管理，又能在系统默认位置被找到"
echo ""

echo "场景4: 数据迁移（文件移到别处，原地留链接）"
echo "  mv /var/log/big.log /data/logs/big.log"
echo "  ln -s /data/logs/big.log /var/log/big.log"
echo "  效果: 看起来文件还在老地方，但实际数据在新位置"
echo ""

# ============================================================================
# 第六部分：完整对比实验
# ============================================================================
echo "=============================================="
echo "【第六部分】完整对比实验"
echo ""

# 准备
echo "原始状态:"
echo "Data" > original.txt
ln original.txt hard_link.txt
ln -s original.txt soft_link.txt
echo ""
echo "文件 inode 对比:"
ls -li original.txt hard_link.txt soft_link.txt
echo ""

echo "实验1: 修改硬链接，源文件会变吗？"
echo "Yes" >> hard_link.txt
echo "  源文件内容: $(cat original.txt)"
echo "  -> 会变！因为共享同一个 inode"
echo ""

echo "实验2: 删除源文件后，硬链接有效吗？"
cp original.txt original_backup.txt  # 备份
rm original.txt
echo "  硬链接内容: $(cat hard_link.txt 2>/dev/null || echo '无')"
echo "  -> 仍然有效！数据还在"
echo ""

echo "实验3: 删除源文件后，软链接有效吗？"
echo "  软链接内容: "
cat soft_link.txt 2>&1 || true
echo "  -> 失效了！路标指向了不存在的东西"
echo ""

# 恢复并清理
cp original_backup.txt original.txt
rm original_backup.txt

# ============================================================================
# 总结
# ============================================================================
echo "=============================================="
echo "  总结:"
echo ""
echo "  inode = 文件的'身份证号'（存权限、大小、数据位置，不存文件名）"
echo "  文件名 -> inode 的映射存在目录里"
echo ""
echo "  硬链接 (ln):"
echo "    - 同一个 inode 的多个名字（影分身）"
echo "    - 删除一个名字不影响数据（inode 还有别的名字指向它）"
echo "    - 不能链接目录，不能跨文件系统"
echo "    - 适用于：防止重要文件被误删、节省磁盘空间"
echo ""
echo "  软链接 (ln -s):"
echo "    - 独立的'路径文本'文件（路标/快捷方式）"
echo "    - 源文件删除后链接失效（死链接）"
echo "    - 可以链接目录，可以跨文件系统"
echo "    - 适用于：快捷访问、版本管理、数据迁移"
echo ""
echo "  简单记忆:"
echo "    ln   = 同一个文件的另一个门（硬链接）"
echo "    ln -s = 路牌写着'某某在那边'（软链接）"
echo "=============================================="

# 清理演示目录
cd /
rm -rf "$DEMO_DIR"
echo ""
echo "已清理演示目录: $DEMO_DIR"
