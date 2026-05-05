"""
============================================================
01-07 元组
============================================================
元组 = 不可变的列表。用 () 创建，创建后不能修改。
适用于"固定不变"的数据，如星期、月份、坐标。
"""

# 1. 创建元组——用圆括号 ()
weekdays = ("周一", "周二", "周三", "周四", "周五")
months = ("一月", "二月", "三月", "四月", "五月", "六月",
          "七月", "八月", "九月", "十月", "十一月", "十二月")
coordinates = (120.5, 30.2)     # 经纬度坐标——固定不变
empty_tuple = ()                 # 空元组

print("工作日：", weekdays)
print("坐标：", coordinates)

print("-" * 30)

# 2. 访问元素——和列表一样，用索引
print("第一个工作日：", weekdays[0])       # 周一
print("最后一个工作日：", weekdays[-1])     # 周五
print("元组长度：", len(weekdays))          # 5

# 也可以用循环（后面会学）
print("所有工作日：")
for day in weekdays:
    print("  ", day)

print("-" * 30)

# 3. 元组不可变——下面的操作全部会报错！（已注释掉）
# weekdays[0] = "周末"       # 错误！不能修改
# weekdays.append("周末")    # 错误！没有 append 方法
# weekdays.remove("周一")    # 错误！没有 remove 方法

# 元组只有两个方法可用：count 和 index
numbers = (1, 2, 3, 2, 1, 2, 3)
print("元组：", numbers)
print("2 出现次数：", numbers.count(2))        # 3 次
print("第一个 3 的索引：", numbers.index(3))    # 索引 2

print("-" * 30)

# 4. 单元素元组的陷阱
not_a_tuple = ("hello")     # 括号里没有逗号——Python 认为这是普通括号
real_tuple = ("hello",)     # 有逗号——这才是元组

print("不加逗号：", type(not_a_tuple), not_a_tuple)   # <class 'str'>
print("加逗号：", type(real_tuple), real_tuple)       # <class 'tuple'>

print("-" * 30)

# 5. 元组的使用场景

# 场景 1：表示固定的常量
STUDENT_GRADES = ("A", "B", "C", "D", "F")   # 成绩等级，永远不变
print("成绩等级：", STUDENT_GRADES)

# 场景 2：函数返回多个值（后面会学）
# 场景 3：作为字典的键（后面会学）

# 6. 元组可以"拆包"——一次性赋值给多个变量
point = (3, 7)
x, y = point              # x 得到 3，y 得到 7
print("坐标：x =", x, ", y =", y)

# 这就像一次性打开了两个盒子，把里面的东西分别放到不同的变量里
name, age, city = ("小明", 10, "北京")
print("姓名：", name, "年龄：", age, "城市：", city)
