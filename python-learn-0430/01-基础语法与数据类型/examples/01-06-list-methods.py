"""
============================================================
01-06 列表的操作方法
============================================================
列表的"工具箱"：append、insert、remove、pop、sort。
这些方法都会直接修改原列表。
"""

# 1. append() —— 在末尾添加
print("========== append() ==========")
fruits = ["苹果", "香蕉"]
print("原始列表：", fruits)

fruits.append("橘子")          # 加在最后
print("append 后：", fruits)

fruits.append("葡萄")
print("再 append 后：", fruits)

print("\n========== insert() ==========")
# 2. insert() —— 在指定位置插入
colors = ["红", "蓝", "紫"]
print("原始：", colors)

colors.insert(1, "绿")         # 在索引 1 处插入"绿"
print("insert(1, '绿')：", colors)   # ['红', '绿', '蓝', '紫']

colors.insert(0, "黑")         # 在索引 0 处（最开头）插入
print("insert(0, '黑')：", colors)

print("\n========== remove() ==========")
# 3. remove() —— 按值删除（删第一个匹配的）
items = ["苹果", "香蕉", "橘子", "香蕉"]
print("原始：", items)

items.remove("香蕉")           # 删除第一个"香蕉"
print("remove('香蕉')：", items)    # ['苹果', '橘子', '香蕉'] — 第二个还在

# items.remove("西瓜")          # 如果取消注释，会报错——"西瓜"不在列表里

print("\n========== pop() ==========")
# 4. pop() —— 按位置取出
numbers = [10, 20, 30, 40, 50]
print("原始：", numbers)

last = numbers.pop()        # 默认取最后一个
print("pop() 取出的值：", last)       # 50
print("pop 后列表：", numbers)        # [10, 20, 30, 40]

second = numbers.pop(1)     # 取出索引 1 的元素（20）
print("pop(1) 取出的值：", second)    # 20
print("pop(1) 后列表：", numbers)     # [10, 30, 40]

print("\n========== sort() ==========")
# 5. sort() —— 排序
nums = [3, 1, 4, 1, 5, 9, 2]
print("排序前：", nums)
nums.sort()
print("从小到大：", nums)

nums.sort(reverse=True)
print("从大到小：", nums)

# 字符串也可以排序——按字母顺序
words = ["banana", "apple", "cherry"]
words.sort()
print("字母排序：", words)

print("\n========== 综合演示 ==========")
# 模拟一个简单的任务清单
tasks = []                         # 空列表开始
print("初始任务：", tasks)

tasks.append("写作业")
tasks.append("跑步")
tasks.append("看书")
print("添加任务后：", tasks)

tasks.insert(1, "吃早餐")          # 在"跑步"前面插入"吃早餐"
print("插入任务后：", tasks)

done = tasks.pop(0)                # 完成第一个任务（写作业）
print("完成了：", done)
print("剩余任务：", tasks)
