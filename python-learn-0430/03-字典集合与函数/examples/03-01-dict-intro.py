"""
03-01 字典入门示例
用"电话本"的类比来理解字典（dict）
字典是一种通过"键"来查找"值"的数据结构
"""

print("=" * 40)
print("1. 创建字典")
print("=" * 40)

# 空字典 -- 就像一本空白的电话本
empty_book = {}
print("空字典:", empty_book)

# 有内容的字典 -- {键: 值, 键: 值, ...}
phone_book = {"小明": "13800138000", "小红": "13900139000", "小刚": "13700137000"}
print("电话本:", phone_book)

# 字典里的值可以是任何类型
student = {"姓名": "张三", "年龄": 15, "班级": "初一(3)班", "成绩": 92.5}
print("学生信息:", student)

print()
print("=" * 40)
print("2. 通过键访问值")
print("=" * 40)

# 就像在电话本里找某个人的号码
print("小明的电话:", phone_book["小明"])
print("小红的电话:", phone_book["小红"])

print("姓名:", student["姓名"])
print("年龄:", student["年龄"])
print("成绩:", student["成绩"])

# 注意：用不存在的键访问会报错！
# print(phone_book["小李"])  # KeyError: '小李'

print()
print("=" * 40)
print("3. 添加和修改键值对")
print("=" * 40)

# 添加新联系人 -- 键不存在就添加
phone_book["小李"] = "13600136000"
print("添加小李后:", phone_book)

# 修改已有联系人的号码 -- 键存在就覆盖
phone_book["小明"] = "13811111111"
print("修改小明后:", phone_book)

# 修改学生信息
student["年龄"] = 16          # 长大了一岁
student["爱好"] = "打篮球"     # 添加新信息
print("更新后的学生信息:", student)

print()
print("=" * 40)
print("4. 用 in 检查键是否存在")
print("=" * 40)

# 先检查一下再访问，就不会报错了
if "小李" in phone_book:
    print("小李在电话本里:", phone_book["小李"])
else:
    print("小李不在电话本里")

if "爱好" in student:
    print("学生的爱好:", student["爱好"])
else:
    print("学生信息里没有爱好这一项")
