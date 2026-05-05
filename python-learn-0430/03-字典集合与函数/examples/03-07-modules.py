"""
03-07 模块与 import 示例
用"工具箱"类比：要用什么就 import 什么
"""

print("=" * 40)
print("1. 导入整个模块 -- import 模块名")
print("=" * 40)

import math

# 使用 math.xxx 来调用模块里的功能
print("圆周率 pi:", math.pi)
print("自然常数 e:", math.e)

# 平方根
print("25 的平方根:", math.sqrt(25))

# 向上取整（天花板）和向下取整（地板）
print("3.2 向上取整:", math.ceil(3.2))    # 4
print("3.8 向下取整:", math.floor(3.8))   # 3

# 绝对值
print("-5 的绝对值:", math.fabs(-5))

# 幂运算
print("2 的 10 次方:", math.pow(2, 10))

print()
print("=" * 40)
print("2. 从模块中导入特定功能 -- from...import")
print("=" * 40)

from math import sin, cos, radians

# 直接使用，不用加 math. 前缀
angle = 90
rad = radians(angle)  # 先把角度转成弧度
print(f"sin({angle}°) = {sin(rad):.2f}")
print(f"cos({angle}°) = {cos(rad):.2f}")

print()
print("=" * 40)
print("3. random 模块 -- 生成随机数")
print("=" * 40)

import random

# randint(a, b) -- a 到 b 之间（包含两端）的随机整数
print("掷骰子 5 次:")
for i in range(5):
    print(f"  第{i+1}次: {random.randint(1, 6)}")

# random() -- 0 到 1 之间的随机小数
print("3 个 0~1 之间的随机小数:")
for i in range(3):
    print(f"  {random.random():.4f}")

# uniform(a, b) -- a 到 b 之间的随机小数
print("1.5 到 3.5 之间的随机小数:", random.uniform(1.5, 3.5))

# choice(列表) -- 从列表中随机选一个
fruits = ["苹果", "香蕉", "橙子", "葡萄", "西瓜"]
print(f"从 {fruits} 中随机选一个: {random.choice(fruits)}")

# shuffle(列表) -- 把列表的元素随机打乱
cards = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
print("洗牌前:", cards)
random.shuffle(cards)
print("洗牌后:", cards)

# sample(列表, n) -- 从列表中随机选 n 个不重复的元素
print("随机抽 3 种水果:", random.sample(fruits, 3))

print()
print("=" * 40)
print("4. 给模块起别名 -- as")
print("=" * 40)

import random as rd
import math as m

# 用简短的名字调用
print("随机整数 1~100:", rd.randint(1, 100))
print("根号 100:", m.sqrt(100))

print()
print("=" * 40)
print("5. 动手练习: 猜数字游戏思路")
print("=" * 40)

# 生成 1 到 100 的随机数，让你猜
secret = random.randint(1, 100)
guess_count = 0

print("\n(演示) 秘密数字已生成! 假设用户猜了几次...")

# 模拟几次猜测（实际游戏会用 input() + while 循环）
guesses = [50, 75, 62]
for guess in guesses:
    guess_count += 1
    if guess > secret:
        hint = "大了"
    elif guess < secret:
        hint = "小了"
    else:
        hint = "猜对了！"
    print(f"  第{guess_count}次猜 {guess}: {hint}")

print(f"\n秘密数字是: {secret}")
