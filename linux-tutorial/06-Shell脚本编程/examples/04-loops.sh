#!/bin/bash
# ========================================
# 04-loops.sh — Shell 循环结构
# ========================================
# 功能：演示 for...in / for((;;)) / while / until
#        break / continue，以及遍历文件/命令输出
# 用法：./04-loops.sh
# ========================================

echo "========================================="
echo "  一、for...in 循环：遍历列表"
echo "========================================="

# 最基本的 for 循环 — 遍历一组固定的值
echo "水果清单："
for fruit in 苹果 香蕉 橘子 葡萄 西瓜; do
    echo "  - $fruit"
done

# 遍历大括号展开的数字范围
echo ""
echo "1 到 5 的平方："
for i in {1..5}; do
    echo "  ${i} 的平方 = $((i * i))"
done

# 遍历变量的值
echo ""
echo "遍历 \$PATH 中的目录："
IFS_OLD="$IFS"
IFS=':'   # 临时修改分隔符为冒号
for dir in $PATH; do
    echo "  $dir"
done
IFS="$IFS_OLD"   # 恢复默认分隔符

echo ""
echo "========================================="
echo "  二、for((;;))：C 语言风格的循环"
echo "========================================="

# 初始化; 条件; 更新
echo "C 风格倒计时："
for ((i = 5; i >= 1; i--)); do
    echo "  $i..."
    sleep 0.2   # 暂停 0.2 秒，制造倒计时效果
done
echo "  🎆 发射！"

echo ""
echo "九九乘法表示例（前 5 行）："
for ((i = 1; i <= 5; i++)); do
    for ((j = 1; j <= i; j++)); do
        printf "%dx%d=%-2d " "$j" "$i" "$((i * j))"
    done
    echo ""
done

echo ""
echo "========================================="
echo "  三、while 循环：条件为真时循环"
echo "========================================="

# while 在条件满足时一直执行
echo "数到 5（while 版本）："
count=1
while [ $count -le 5 ]; do
    echo "  数字：$count"
    ((count++))
done

# while 读取文件内容（逐行处理）
echo ""
echo "逐行读取 /etc/hosts 的内容（前 5 行）："
if [ -f /etc/hosts ]; then
    line_num=0
    while IFS= read -r line; do
        if [ -z "$line" ] || [[ "$line" == \#* ]]; then
            continue  # 跳过空行和注释行
        fi
        echo "  第 $((++line_num)) 行: $line"
        if [ $line_num -ge 5 ]; then
            break
        fi
    done < /etc/hosts
else
    echo "  /etc/hosts 文件不存在（可能不是 Linux 系统）"
fi

echo ""
echo "========================================="
echo "  四、until 循环：条件为假时循环"
echo "========================================="

# until 和 while 相反：条件为假时一直执行
echo "等待服务启动的模拟（until 版本）："
ready_flag=false
attempt=1
until $ready_flag; do
    echo "  第 ${attempt} 次检查..."

    # 模拟：第 3 次检查时"发现"服务已启动
    if [ $attempt -ge 3 ]; then
        ready_flag=true
        echo "  >>> 服务已启动！"
    fi

    ((attempt++))
    sleep 0.3
done

echo ""
echo "========================================="
echo "  五、break 和 continue"
echo "========================================="

# break：跳出整个循环
echo "break 演示（到 3 就停）："
for i in {1..10}; do
    if [ $i -gt 3 ]; then
        break
    fi
    echo "  i = $i"
done

# continue：跳过本次循环的剩余部分，继续下一次
echo ""
echo "continue 演示（跳过 3 和 7）："
for i in {1..10}; do
    if [ $i -eq 3 ] || [ $i -eq 7 ]; then
        continue
    fi
    echo "  i = $i"
done

echo ""
echo "========================================="
echo "  六、遍历命令输出"
echo "========================================="

# 方法一：$() 包在 for 的 in 后面
echo "当前目录下的 .sh 文件："
for file in $(ls *.sh 2>/dev/null); do
    echo "  脚本文件：$file"
done

# 方法二：while read 配合管道（更安全，处理带空格的文件名更好）
echo ""
echo "管道 + while read 方式："
find /tmp -maxdepth 1 -type f -name "*.log" 2>/dev/null | while read -r logfile; do
    if [ -s "$logfile" ]; then
        echo "  日志文件：$logfile（大小：$(wc -c < "$logfile") 字节）"
    fi
done

# 如果没有日志文件，显示一条说明
if [ -z "$(find /tmp -maxdepth 1 -type f -name '*.log' 2>/dev/null)" ]; then
    echo "  （/tmp 下没有 .log 文件）"
fi

echo ""
echo "========================================="
echo "  七、实用的循环模式"
echo "========================================="

# 模式一：批量重命名文件
echo "批量重命名示例（模拟）："
mkdir -p "/tmp/loop_test_$$"
for i in {1..3}; do
    touch "/tmp/loop_test_$$/photo_${i}.jpg"
done
echo "  原始文件："
ls "/tmp/loop_test_$$/"

for file in "/tmp/loop_test_$$/photo_"*.jpg; do
    newname="${file/photo_/image_}"   # 字符串替换
    mv "$file" "$newname"
    echo "  重命名：$(basename "$file") -> $(basename "$newname")"
done
rm -rf "/tmp/loop_test_$$"

# 模式二：遍历数组
echo ""
echo "遍历数组："
servers=("web01" "web02" "db01" "cache01")
for server in "${servers[@]}"; do
    echo "  部署到服务器：$server"
done

# 模式三：带索引遍历数组
echo ""
echo "带索引遍历："
for index in "${!servers[@]}"; do
    echo "  服务器 #$((index + 1)): ${servers[$index]}"
done

echo ""
echo "========================================="
echo "  循环知识点总结"
echo "========================================="
echo "  for...in       遍历列表/数组/文件"
echo "  for((;;))      C 语言风格计数循环"
echo "  while          条件满足时循环"
echo "  until          条件不满足时循环"
echo "  break          跳出循环"
echo "  continue       跳过本轮，继续下一轮"
echo "  \$() 在 for 中  遍历命令输出"
echo "  while read     逐行读取文件"

exit 0
