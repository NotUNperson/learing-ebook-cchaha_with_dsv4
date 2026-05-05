"""
03-02 字典的增删改查与方法
演示 keys()、values()、items()、get()、pop()、del 等常用操作
"""

print("=" * 40)
print("1. keys() -- 获取所有键（就像看通讯录里所有人的名字）")
print("=" * 40)

contacts = {"妈妈": "13800001111", "爸爸": "13900002222", "老师": "13600003333"}
print("通讯录:", contacts)

print("通讯录里的所有人:")
for name in contacts.keys():
    print("  ", name)

# 也可以直接转成列表
name_list = list(contacts.keys())
print("名字列表:", name_list)

print()
print("=" * 40)
print("2. values() -- 获取所有值（就像只看号码不看名字）")
print("=" * 40)

print("所有电话号码:")
for phone in contacts.values():
    print("  ", phone)

phone_list = list(contacts.values())
print("号码列表:", phone_list)

print()
print("=" * 40)
print("3. items() -- 同时获取键和值（名字和号码一起看）")
print("=" * 40)

print("完整通讯录:")
for name, phone in contacts.items():
    print(f"  {name} 的电话是 {phone}")

print()
print("=" * 40)
print("4. get() -- 安全地查询")
print("=" * 40)

# get(键, 默认值)：键存在就返回值，不存在就返回默认值
print("查询妈妈:", contacts.get("妈妈", "查无此人"))
print("查询小明:", contacts.get("小明", "查无此人"))

# 对比：用方括号会直接报错
# print(contacts["小明"])  # 会报 KeyError

print()
print("=" * 40)
print("5. 修改值 -- 直接赋值")
print("=" * 40)

# 修改已有的键值对
contacts["老师"] = "13600009999"
print("老师换号了:", contacts)

print()
print("=" * 40)
print("6. pop() -- 删除并返回被删除的值")
print("=" * 40)

# pop(键) 删除键值对，并返回值
removed_phone = contacts.pop("老师")
print(f"已删除老师的号码: {removed_phone}")
print("剩余通讯录:", contacts)

# pop() 也可以设置默认值：如果键不存在就返回默认值
safe_remove = contacts.pop("陌生人", "不存在此人")
print("删除陌生人:", safe_remove)

print()
print("=" * 40)
print("7. del -- 直接删除键值对")
print("=" * 40)

del contacts["爸爸"]
print("删除爸爸后:", contacts)

print()
print("=" * 40)
print("8. 综合练习：水果价格表")
print("=" * 40)

fruits = {"苹果": 5.5, "香蕉": 3.0, "橙子": 4.0, "葡萄": 8.0}
print("水果价格表:", fruits)

# 遍历所有水果
print("本店水果价格:")
for fruit, price in fruits.items():
    print(f"  {fruit}: {price} 元/斤")

# 安全查询
query = "西瓜"
if query in fruits:
    print(f"{query}的价格: {fruits[query]}")
else:
    print(f"抱歉，本店没有{query}")

# 涨价：所有水果价格提高 1 元
for fruit in fruits.keys():
    fruits[fruit] += 1
print("涨价后:", fruits)
