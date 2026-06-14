#!/bin/bash
# ========================================
# 03-conditionals.sh — Shell 条件判断
# ========================================
# 功能：演示 if/then/elif/else/fi 分支结构，
#        test / [ ] / [[ ]] 的用法和区别，
#        文件测试、字符串比较、数值比较。
# 用法：./03-conditionals.sh
# ========================================

echo "========================================="
echo "  一、if 语句基本结构"
echo "========================================="

# 最基本的 if 语句
score=85

if [ $score -ge 60 ]; then
    echo "成绩 $score 分：及格"
fi

# if-else 结构
temperature=38

if [ $temperature -le 37 ]; then
    echo "体温 ${temperature}°C：正常"
else
    echo "体温 ${temperature}°C：发烧了，需要看医生"
fi

# if-elif-else 多分支结构
hour=$(date +%H)   # 获取当前小时（0-23）

if [ $hour -lt 6 ]; then
    echo "现在是凌晨 ${hour} 点，夜深了，早休息。"
elif [ $hour -lt 12 ]; then
    echo "现在是上午 ${hour} 点，一天之计在于晨！"
elif [ $hour -lt 18 ]; then
    echo "现在是下午 ${hour} 点，继续加油！"
else
    echo "现在是晚上 ${hour} 点，该放松一下了。"
fi

echo ""
echo "========================================="
echo "  二、文件测试（检查文件/目录属性）"
echo "========================================="

# 创建一个测试文件
test_file="/tmp/test_conditionals_$$.txt"
echo "Hello World" > "$test_file"

echo "测试文件：$test_file"
echo ""

# -f：文件是否存在并且是普通文件
if [ -f "$test_file" ]; then
    echo "  [ -f ] 检查通过：文件存在且是普通文件"
fi

# -e：文件/目录是否存在（不关心类型）
if [ -e "$test_file" ]; then
    echo "  [ -e ] 检查通过：此路径存在"
fi

# -s：文件大小大于 0
if [ -s "$test_file" ]; then
    echo "  [ -s ] 检查通过：文件非空"
fi

# -r / -w / -x：可读 / 可写 / 可执行
if [ -r "$test_file" ]; then
    echo "  [ -r ] 检查通过：文件可读"
fi
if [ -w "$test_file" ]; then
    echo "  [ -w ] 检查通过：文件可写"
fi
if [ ! -x "$test_file" ]; then
    echo "  [ ! -x ] 检查通过：文件不可执行"
fi

# -d：检查是否为目录
if [ -d "/tmp" ]; then
    echo "  [ -d ] 检查通过：/tmp 是一个目录"
fi

# -L：检查是否为符号链接
if [ ! -L "$test_file" ]; then
    echo "  [ ! -L ] 检查通过：不是符号链接"
fi

# 清理测试文件
rm -f "$test_file"

echo ""
echo "========================================="
echo "  三、字符串比较"
echo "========================================="

str1="hello"
str2="world"
empty_str=""

# =（或 ==）：判断字符串相等
if [ "$str1" = "hello" ]; then
    echo "  字符串 \"$str1\" 等于 \"hello\""
fi

# !=：判断字符串不等
if [ "$str1" != "$str2" ]; then
    echo "  字符串 \"$str1\" 不等于 \"$str2\""
fi

# -z：判断字符串为空（长度为 0）
if [ -z "$empty_str" ]; then
    echo "  empty_str 是空字符串"
fi

# -n：判断字符串不为空
if [ -n "$str1" ]; then
    echo "  str1 不是空字符串（长度为 ${#str1}）"
fi

echo ""
echo "========================================="
echo "  四、数值比较"
echo "========================================="

a=10
b=20

# -eq：等于 (equal)
if [ $a -eq 10 ]; then
    echo "  $a -eq 10 成立"
fi

# -ne：不等于 (not equal)
if [ $a -ne $b ]; then
    echo "  $a -ne $b 成立"
fi

# -lt：小于 (less than)
if [ $a -lt $b ]; then
    echo "  $a -lt $b 成立"
fi

# -le：小于等于 (less or equal)
if [ $a -le 10 ]; then
    echo "  $a -le 10 成立"
fi

# -gt：大于 (greater than)
if [ $b -gt $a ]; then
    echo "  $b -gt $a 成立"
fi

# -ge：大于等于 (greater or equal)
if [ $b -ge 20 ]; then
    echo "  $b -ge 20 成立"
fi

echo ""
echo "========================================="
echo "  五、[ ] 与 [[ ]] 的区别"
echo "========================================="

# [ ] 是 POSIX 标准的 test 命令别名，兼容性最好
# [[ ]] 是 bash 扩展，支持更多高级功能

# [[ ]] 支持 && 和 || 逻辑运算
name="小明"
if [[ "$name" == "小明" && -n "$name" ]]; then
    echo "  [[ ]] && 连接：name 是 小明 且不为空"
fi

# [[ ]] 支持 =~ 正则匹配
phone="13812345678"
if [[ "$phone" =~ ^[0-9]{11}$ ]]; then
    echo "  [[ ]] =~ 正则：$phone 是有效的 11 位手机号"
fi

# [[ ]] 不需要给变量加引号也能安全工作
var_with_space="hello world"
if [[ $var_with_space == "hello world" ]]; then
    echo "  [[ ]] 在变量含空格时比 [ ] 更安全"
fi

# [ ] 中使用 -a 和 -o 做逻辑运算
if [ "$name" = "小明" -a -n "$name" ]; then
    echo "  [ ] -a 连接：name 是 小明 且不为空"
fi

echo ""
echo "========================================="
echo "  六、与运算 (&&) 和 或运算 (||)"
echo "========================================="

# 在命令行中 && 和 || 非常常用
file="/etc/passwd"
[ -f "$file" ] && echo "  $file 存在" || echo "  $file 不存在"

# 条件嵌套在 if 中
age=20
has_id=true

if [ $age -ge 18 ] && [ "$has_id" = true ]; then
    echo "  if 中的 &&：可以入场"
fi

if [ $age -lt 18 ] || [ "$has_id" != true ]; then
    echo "  if 中的 ||：不得入场"
else
    echo "  if 中的 || 配合 else：可以入场（如果不满足拒绝条件）"
fi

echo ""
echo "========================================="
echo "  常用测试条件速查"
echo "========================================="
echo "  文件测试："
echo "    [ -f FILE ]  是普通文件"
echo "    [ -d DIR  ]  是目录"
echo "    [ -e PATH ]  存在（文件或目录）"
echo "    [ -r FILE ]  可读"
echo "    [ -w FILE ]  可写"
echo "    [ -x FILE ]  可执行"
echo "    [ -s FILE ]  非空"
echo "    [ -L FILE ]  是符号链接"
echo ""
echo "  字符串比较："
echo "    [ \"\$a\" = \"\$b\"  ]  相等"
echo "    [ \"\$a\" != \"\$b\" ]  不等"
echo "    [ -z \"\$a\" ]       为空"
echo "    [ -n \"\$a\" ]       不为空"
echo ""
echo "  数值比较："
echo "    [ \$a -eq \$b ]  等于"
echo "    [ \$a -ne \$b ]  不等于"
echo "    [ \$a -lt \$b ]  小于"
echo "    [ \$a -le \$b ]  小于等于"
echo "    [ \$a -gt \$b ]  大于"
echo "    [ \$a -ge \$b ]  大于等于"

exit 0
