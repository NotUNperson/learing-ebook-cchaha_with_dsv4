"""
============================================================
00-04 变量：贴了标签的快递盒
============================================================
变量 = 一个有名字的"盒子"，用来存放数据。
"""

# 1. 创建变量——把值放进盒子里
name = "小明"          # 把 "小明" 放进叫 name 的盒子
age = 10               # 把 10 放进叫 age 的盒子（数字不用引号）
height = 145.5         # 小数也没问题

# 现在可以用变量名来使用这些值
print("名字：", name)
print("年龄：", age)
print("身高：", height, "cm")

print("-" * 30)

# 2. 变量可以重新赋值——盒子里的东西可以换
lucky_number = 7
print("幸运数字是：", lucky_number)

lucky_number = 99       # 换成 99 了
print("新的幸运数字是：", lucky_number)

print("-" * 30)

# 3. 变量可以参与计算
price = 25              # 一本笔记本的价格
count = 4               # 买 4 本
total = price * count   # 总价 = 单价 x 数量
print("笔记本单价：", price, "元")
print("购买数量：", count, "本")
print("总价：", total, "元")

print("-" * 30)

# 4. 变量之间可以互相操作
a = 10
b = 20
c = a + b               # c 的值来自 a 和 b 的计算结果
print("a =", a, ", b =", b)
print("a + b =", c)

# 5. 一个常见的写法：变量自己更新
counter = 0
print("初始值：", counter)
counter = counter + 1   # 把 counter 的值加 1，再存回 counter
print("加 1 后：", counter)
counter = counter + 1
print("再加 1 后：", counter)
# 这就像一个计数器，每数一次，数字就加 1
