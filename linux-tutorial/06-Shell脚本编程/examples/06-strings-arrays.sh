#!/bin/bash
# ========================================
# 06-strings-arrays.sh — 字符串与数组操作
# ========================================
# 功能：演示字符串截取/替换/长度计算，
#        普通数组的定义/遍历/增删，
#        关联数组（declare -A）的使用
# 用法：./06-strings-arrays.sh
# ========================================

echo "========================================="
echo "  一、字符串基本操作"
echo "========================================="

str="Hello World, Linux Bash!"

# 获取字符串长度
echo "原始字符串：'$str'"
echo "  长度：${#str}"

# 转为大写 / 小写
echo "  全大写：${str^^}"
echo "  全小写：${str,,}"

# 首字母大写
name="linux"
echo "  首字母大写：${name^}"     # Linux

echo ""
echo "========================================="
echo "  二、字符串截取（子串）"
echo "========================================="

url="https://www.example.com/docs/index.html"

echo "URL：$url"

# ${变量:起始位置:长度}  —  从左边第 N 个字符开始
echo "  \${url:0:5}    = ${url:0:5}"          # https
echo "  \${url:8:11}   = ${url:8:11}"         # www.example

# ${变量:起始位置}  —  从左边第 N 个字符开始到末尾
echo "  \${url:12}     = ${url:12}"           # www.example.com/docs/index.html

# ${变量: -N}  —  从右边倒数 N 个字符开始（注意冒号后面的空格！）
echo "  \${url: -10}   = ${url: -10}"         # index.html

# ${变量#模式}  —  从左边去掉最短匹配
echo "  \${url#*//}    = ${url#*//}"          # www.example.com/docs/index.html

# ${变量##模式}  —  从左边去掉最长匹配
echo "  \${url##*/}    = ${url##*/}"          # index.html

# ${变量%模式}  —  从右边去掉最短匹配
echo "  \${url%/*}     = ${url%/*}"           # https://www.example.com/docs

# ${变量%%模式}  —  从右边去掉最长匹配
echo "  \${url%%/*}    = ${url%%/*}"          # https:

echo ""
echo "========================================="
echo "  三、字符串替换"
echo "========================================="

text="apple orange apple banana apple"

echo "原始：$text"

# ${变量/旧的/新的}  —  只替换第一个匹配
echo "  \${text/apple/PEAR}   = ${text/apple/PEAR}"

# ${变量//旧的/新的}  —  替换所有匹配
echo "  \${text//apple/PEAR}  = ${text//apple/PEAR}"

# ${变量/#旧的/新的}  —  只替换开头的匹配
echo "  \${text/#apple/PEAR}  = ${text/#apple/PEAR}"

# ${变量/%旧的/新的}  —  只替换结尾的匹配
echo "  \${text/%apple/PEAR}  = ${text/%apple/PEAR}"

# 删除操作（把"新的"留空就是删除）
echo "  \${text/apple/}       = ${text/apple/}"       # 删除第一个
echo "  \${text//apple/}      = ${text//apple/}"      # 删除所有

echo ""
echo "========================================="
echo "  四、字符串判断与默认值"
echo "========================================="

var1="hello"
var2=""       # 空字符串（但变量已定义）
# var3 未定义

# ${变量:-默认值}  —  变量为空或未设置时使用默认值
echo "\${var1:-default}   = ${var1:-default}"      # hello
echo "\${var2:-default}   = ${var2:-default}"      # default（var2 为空）
echo "\${var3:-default}   = ${var3:-default}"      # default（var3 未定义）

# ${变量:=默认值}  —  变量为空时设为默认值并返回
echo "\${var2:=newval}    = ${var2:=newval}"       # newval（同时赋值给 var2）
echo "var2 现在的值：$var2"                         # newval

# ${变量:+替换值}  —  变量有值时使用替换值
echo "\${var1:+<已设置>}   = ${var1:+<已设置>}"      # <已设置>

# ${变量:?错误信息}  —  变量为空时打印错误并退出
echo "\${var1:?未设置\!}   = ${var1:?未设置\!}"      # hello
# echo ${var3:?变量未设置!}  # 会报错退出，这里先注释掉

echo ""
echo "========================================="
echo "  五、普通数组（索引数组）"
echo "========================================="

# 定义数组 — 用小括号，元素用空格分隔
fruits=("苹果" "香蕉" "橘子" "葡萄" "西瓜")
echo "数组定义：fruits=(\"苹果\" \"香蕉\" \"橘子\" \"葡萄\" \"西瓜\")"

# 访问整个数组
echo "  所有元素：${fruits[@]}"

# 访问单个元素（索引从 0 开始）
echo "  第1个元素：${fruits[0]}"
echo "  第3个元素：${fruits[2]}"

# 数组长度
echo "  元素个数：${#fruits[@]}"

# 所有索引
echo "  所有索引：${!fruits[@]}"

# 修改元素
fruits[1]="榴莲"
echo "  修改第2个元素后：${fruits[@]}"

# 追加元素
fruits+=("草莓")
echo "  追加草莓后：${fruits[@]}"

# 删除元素
unset fruits[2]   # 删除第3个元素
echo "  删除第3个元素后：${fruits[@]}"

echo ""
echo "========================================="
echo "  六、遍历数组"
echo "========================================="

# 方式一：for 遍历值
echo "  方式一（遍历值）："
for fruit in "${fruits[@]}"; do
    echo "    - $fruit"
done

# 方式二：for 遍历索引
echo "  方式二（遍历索引）："
for i in "${!fruits[@]}"; do
    echo "    索引 $i = ${fruits[$i]}"
done

# 方式三：C 风格循环
echo "  方式三（C 风格循环）："
len=${#fruits[@]}
for ((i = 0; i < len; i++)); do
    echo "    [$i] ${fruits[$i]}"
done

echo ""
echo "========================================="
echo "  七、关联数组（declare -A）"
echo "========================================="

# 关联数组类似于其他语言中的 Map / Dictionary
# 必须先用 declare -A 声明

# 定义关联数组
declare -A student_scores
student_scores["张三"]=95
student_scores["李四"]=87
student_scores["王五"]=92
student_scores["赵六"]=78

echo "学生成绩表："

# 遍历关联数组
for name in "${!student_scores[@]}"; do
    score=${student_scores[$name]}
    if [ "$score" -ge 90 ]; then
        level="优秀"
    elif [ "$score" -ge 80 ]; then
        level="良好"
    elif [ "$score" -ge 60 ]; then
        level="及格"
    else
        level="不及格"
    fi
    echo "  $name：${score}分 ($level)"
done

# 关联数组的其他操作
echo ""
echo "  学生总数：${#student_scores[@]}"
echo "  所有姓名：${!student_scores[@]}"
echo "  所有成绩：${student_scores[@]}"

# 检查某个 key 是否存在
if [ -n "${student_scores["张三"]+exists}" ]; then
    echo "  张三的成绩已录入"
fi
if [ -z "${student_scores["孙七"]+exists}" ]; then
    echo "  孙七还没有成绩"
fi

# 删除一个条目
unset "student_scores[赵六]"
echo "  删除赵六后人数：${#student_scores[@]}"

echo ""
echo "========================================="
echo "  八、实战：配置文件解析"
echo "========================================="

# 模拟读取一个简单的 key=value 配置文件
echo "模拟解析配置文件："
declare -A config

# 模拟配置项
config["host"]="localhost"
config["port"]="3306"
config["user"]="admin"
config["database"]="test_db"

# 打印配置
for key in "${!config[@]}"; do
    printf "  %-12s = %s\n" "$key" "${config[$key]}"
done

# 生成连接字符串
conn_str="mysql://${config[user]}@${config[host]}:${config[port]}/${config[database]}"
echo ""
echo "  生成连接串：$conn_str"

echo ""
echo "========================================="
echo "  字符串与数组操作速查"
echo "========================================="
echo "  字符串："
echo "    \${#str}         获取长度"
echo "    \${str:pos:len}  截取子串"
echo "    \${str#pat}      从左边去掉最短匹配"
echo "    \${str##pat}     从左边去掉最长匹配"
echo "    \${str%pat}      从右边去掉最短匹配"
echo "    \${str%%pat}     从右边去掉最长匹配"
echo "    \${str/old/new}  替换第一个匹配"
echo "    \${str//old/new} 替换所有匹配"
echo "    \${str^^}        全大写"
echo "    \${str,,}        全小写"
echo ""
echo "  数组："
echo "    arr=(a b c)        定义数组"
echo "    \${arr[0]}         访问第0个元素"
echo "    \${arr[@]}         所有元素"
echo "    \${#arr[@]}        元素个数"
echo "    \${!arr[@]}        所有索引"
echo "    arr+=(d)           追加元素"
echo "    unset arr[1]       删除元素"
echo ""
echo "  关联数组："
echo "    declare -A map            声明"
echo "    map[\"key\"]=\"value\"      设置"
echo "    \${map[\"key\"]}           获取"
echo "    \${!map[@]}               所有 key"

exit 0
