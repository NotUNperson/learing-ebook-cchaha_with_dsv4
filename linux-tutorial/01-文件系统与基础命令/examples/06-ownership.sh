#!/bin/bash
# ============================================================================
# 06-ownership.sh
# 演示 Linux 文件所有者和用户组概念
# chown -- 改变文件所有者（类比：房产证过户）
# chgrp -- 改变文件所属组（类比：改家庭归属）
# groups, whoami, id -- 查看身份信息
# SGID 位 -- 共享目录中自动继承组归属
# ============================================================================

echo "=============================================="
echo "  Linux 所有者与用户组演示"
echo "  每个文件有所有者 (Owner) 和所属组 (Group)"
echo "  chown = 过户房产证    chgrp = 改家庭归属"
echo "=============================================="
echo ""

# ============================================================================
# 第一部分：了解自己的身份
# ============================================================================
echo "【第一部分】了解自己的身份 -- 你是谁？属于哪些组？"
echo ""

echo "1. 我是谁？"
echo "   命令: whoami"
echo "   结果: $(whoami)"
echo ""

echo "2. 我的用户ID和组ID？"
echo "   命令: id"
id
echo ""

echo "3. 我属于哪些组？"
echo "   命令: groups"
groups
echo ""

echo "4. 当前登录了哪些用户？"
echo "   命令: who"
who 2>/dev/null || echo "   (无其他登录用户)"
echo ""

# ============================================================================
# 第二部分：查看文件的所有者和所属组
# ============================================================================
echo "=============================================="
echo "【第二部分】查看文件的所有者和所属组"
echo ""

# 创建演示目录和文件
DEMO_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t ownership 2>/dev/null || echo "/tmp/ownership-demo-$$")
if [ "$DEMO_DIR" = "/tmp/ownership-demo-$$" ]; then
    mkdir -p "$DEMO_DIR"
fi
cd "$DEMO_DIR"
echo "演示目录: $DEMO_DIR"
echo ""

# 创建示例文件
touch my_file.txt
echo "创建文件 my_file.txt:"
ls -l my_file.txt
echo ""

echo "ls -l 输出解读:"
echo "  -rw-r--r--  1  zhangsan  zhangsan  0  May 15  10:30  my_file.txt"
echo "                |  ^^^^^^^^  ^^^^^^^^"
echo "                |  所有者     所属组"
echo "                |"
echo "                硬链接数（后面章节详讲）"
echo ""

# 查看不同类型文件的所有权
echo "查看一些系统文件的所有权:"
echo ""
echo "  系统用户配置文件:"
ls -l /etc/passwd 2>/dev/null || echo "   (无法读取)"
echo "    注意：/etc/passwd 属于 root:root，普通用户只能读"
echo ""

echo "  系统日志目录:"
ls -ld /var/log 2>/dev/null || echo "   (无法读取)"
echo "    注意：日志目录通常属于 root，但有些可能属于 syslog 组"
echo ""

# ============================================================================
# 第三部分：chown -- 改变所有者
# ============================================================================
echo "=============================================="
echo "【第三部分】chown -- 改变文件所有者"
echo "  类比：房产证过户，只有管理员（root）才能操作"
echo ""

echo "基本语法:"
echo "  chown 新所有者 文件名"
echo "  chown 所有者:所属组 文件名  （同时改所有者和组）"
echo ""

touch chown_test.txt
chmod 644 chown_test.txt
echo "创建测试文件 chown_test.txt:"
ls -l chown_test.txt
echo ""

echo "注意：普通用户不能 chown ！（这是安全设计）"
echo "  尝试 chown root chown_test.txt 会报错:"
chown root chown_test.txt 2>&1 || true
echo "  原因：如果谁都能随便改文件的所有者，权限系统就失效了"
echo ""

echo "需要 root 身份才能 chown:"
echo "  sudo chown root chown_test.txt"
# 不实际执行 sudo，只是说明
echo ""

# 演示 chown 同时改所有者和组
echo "chown user:group 同时修改所有者与组:"
echo "  sudo chown zhangsan:developers file.txt"
echo "  这样所有者变成 zhangsan，所属组变成 developers"
echo ""

# ============================================================================
# 第四部分：chgrp -- 改变所属组
# ============================================================================
echo "=============================================="
echo "【第四部分】chgrp -- 改变文件所属组"
echo "  类比：把房子从'家庭'名下改到'投资公司'名下"
echo "  前提：你必须是目标组的成员"
echo ""

touch chgrp_test.txt
chmod 664 chgrp_test.txt
echo "创建测试文件 chgrp_test.txt:"
ls -l chgrp_test.txt
echo ""

echo "chgrp 基本语法:"
echo "  chgrp 新组名 文件名"
echo ""

echo "查看你属于哪些组（决定你能 chgrp 到哪些组）:"
groups
echo ""

echo "等价命令: chown :group file"
echo "  chgrp developers file.txt"
echo "  等价于"
echo "  chown :developers file.txt"
echo ""

echo "普通用户使用 chgrp 的限制:"
echo "  你只能把文件改成你所属的组"
echo "  不能改成你不属于的组（需要 sudo）"
echo ""

# ============================================================================
# 第五部分：SGID 位 -- 共享目录的"组继承"
# ============================================================================
echo "=============================================="
echo "【第五部分】SGID 位 -- 让新文件自动继承目录的组"
echo "  类比：公司的'默认项目归属'标签"
echo ""

echo "创建演示目录并设置 SGID:"
mkdir shared_project
chmod 775 shared_project
echo "  初始权限:"
ls -ld shared_project
echo ""

# 尝试设置 SGID（需要当前用户是目录所有者或root）
chmod g+s shared_project 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  设置 SGID 后:"
    ls -ld shared_project
    echo ""
    echo "  注意权限字符串中的 's':"
    echo "    drwxrwsr-x  (组权限的 x 变成了 s)"
    echo "    s = SGID + 执行权限"
    echo "    S = SGID (没有执行权限)"
    echo ""

    cd shared_project
    touch test_file.txt
    echo "  在 SGID 目录中创建文件 test_file.txt:"
    ls -l test_file.txt
    echo ""
    echo "  注意：文件的所属组自动继承了目录的组"
    echo "  如果没有 SGID，所属组会是创建者的默认组"
    cd "$DEMO_DIR"
else
    echo "  (无法在当前环境设置 SGID，但不影响理解概念)"
fi
echo ""

# ============================================================================
# 第六部分：常见协作模式
# ============================================================================
echo "=============================================="
echo "【第六部分】多用户协作的典型权限设置"
echo ""

echo "场景1: 个人工作目录（默认模式）"
echo "  /home/zhangsan/  所有者: zhangsan  组: zhangsan  权限: 700"
echo "  效果: 只有 zhangsan 能进入和操作自己的家目录"
echo ""

echo "场景2: 团队共享目录（项目协作）"
echo "  /srv/project/     所有者: root     组: devteam   权限: 770"
echo "  + SGID 位  (chmod g+s /srv/project/)"
echo "  效果: devteam 组的所有成员可以自由读写，其他人看不到"
echo "        新文件自动属于 devteam 组"
echo ""

echo "场景3: 公共只读目录（发布文档）"
echo "  /srv/docs/        所有者: root     组: root     权限: 755"
echo "  效果: 所有人都能进入和读取，但只有 root 能修改"
echo ""

echo "场景4: 共享可写目录（公共上传区）"
echo "  /srv/uploads/     所有者: root     组: users    权限: 1770"
echo "  注意: 这里的 1 是 sticky bit（粘滞位），后面详讲"
echo "  效果: users 组成员可以上传文件，但不能删除别人的文件"
echo ""

# ============================================================================
# 第七部分：实用命令速查
# ============================================================================
echo "=============================================="
echo "【第七部分】实用命令速查"
echo ""

echo "查看自己身份:"
echo "  whoami            -- 我是谁"
echo "  id                -- 完整身份信息 (uid, gid, groups)"
echo "  groups            -- 我属于哪些组"
echo "  who               -- 当前谁登录了系统"
echo ""

echo "查看文件所有权:"
echo "  ls -l file        -- 显示所有者和组"
echo "  stat file         -- 更详细的信息（包括 inode）"
echo ""

echo "修改所有权:"
echo "  chown  user file          -- 改所有者（需 root）"
echo "  chown  user:group file    -- 同时改所有者和组（需 root）"
echo "  chown  :group file        -- 只改组（需 root）"
echo "  chgrp  group file         -- 只改组（需是组成员）"
echo "  chown -R user:group dir/  -- 递归修改整个目录"
echo ""

echo "共享目录最佳实践:"
echo "  1. mkdir /srv/shared"
echo "  2. chown root:team /srv/shared"
echo "  3. chmod 2770 /srv/shared  (2 = SGID, 770 = rwxrwx---)"
echo "  4. usermod -aG team zhangsan  (把成员加入 team 组)"
echo ""

# ============================================================================
# 总结
# ============================================================================
echo "=============================================="
echo "  总结:"
echo ""
echo "  每个文件有两个'身份标签':"
echo "    所有者 (Owner)  -- 文件的'主人'"
echo "    所属组 (Group)  -- 文件的'家庭/团队'"
echo ""
echo "  类比: 房产证上的名字"
echo "    房产证名字 = 所有者（Owner）"
echo "    家庭成员   = 所属组（Group）"
echo "    邻居路人   = 其他人（Others）"
echo ""
echo "  chown = 房产证过户（需root）"
echo "  chgrp = 改家庭归属（需在目标组中）"
echo "  SGID  = 共享目录中文件自动继承组归属"
echo "=============================================="

# 清理演示目录
cd /
rm -rf "$DEMO_DIR"
echo ""
echo "已清理演示目录: $DEMO_DIR"
