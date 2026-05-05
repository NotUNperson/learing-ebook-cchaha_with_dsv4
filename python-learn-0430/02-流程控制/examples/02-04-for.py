"""
============================================================
02-04 for 循环
============================================================
for = "对于……中的每一个"，逐个遍历。
常与 range() 配合，不需要自己管理计数器。
"""

print("========== for 遍历列表 ==========")

# 老师点名——逐个取出列表中的每个元素
students = ["张三", "李四", "王五", "小明"]
for name in students:
    print(name, "→ 到！")

print("-" * 30)

# 打印购物清单
items = ["牛奶", "面包", "鸡蛋", "苹果"]
print("购物清单：")
for item in items:
    print("  -", item)

print("\n========== for 遍历字符串 ==========")

word = "Python"
print("逐字母分解", word, "：")
for char in word:
    print("  ", char)

print("\n========== range() 的基本用法 ==========")

# range(5) → 0, 1, 2, 3, 4（不含 5）
print("range(5)：")
for i in range(5):
    print(i, end=" ")    # end=" " 表示打印后不换行，加空格
print()                  # 打印一个换行

# range(2, 6) → 2, 3, 4, 5（从 2 开始，6 之前停止）
print("range(2, 6)：")
for i in range(2, 6):
    print(i, end=" ")
print()

# range(1, 11, 2) → 1, 3, 5, 7, 9（每次 +2）
print("range(1, 11, 2)：")
for i in range(1, 11, 2):
    print(i, end=" ")
print()

print("\n========== for + range 常用模式 ==========")

# 重复执行 N 次
print("重复 3 次：")
for i in range(3):
    print("  我爱 Python")

# 打印九九乘法表的 3 那行
print("3 的乘法：")
for i in range(1, 10):
    print("  3 x", i, "=", 3 * i)

# 累加 1 到 100
total = 0
for i in range(1, 101):
    total = total + i
print("1 到 100 的和：", total)

print("\n========== for 遍历列表做计算 ==========")

scores = [85, 92, 78, 90, 88]
print("成绩列表：", scores)

# 计算平均分
total_score = 0
for s in scores:
    total_score = total_score + s
avg = total_score / len(scores)
print("平均分：", avg)

# 找出所有及格的分数（>=60）（这里只是演示遍历+判断）
print("及格成绩：")
for s in scores:
    if s >= 60:
        print("  ", s)

print("\n========== for 循环的"计数器"模式 ==========")
# 有时你需要同时知道"索引"和"值"
fruits = ["苹果", "香蕉", "橘子"]
for i in range(len(fruits)):
    print("第", i, "个水果是", fruits[i])
# range(len(fruits)) → range(3) → 0,1,2
