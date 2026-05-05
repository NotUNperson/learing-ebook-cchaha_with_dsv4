# -*- coding: utf-8 -*-
"""
08-01 random 进阶示例
=====================
演示 randint()、choice()、shuffle()、random() 等常用函数。

类比：random 就像数字抽奖转盘和各种骰子。
"""

import random
import string

print("=" * 50)
print("random 常用函数演示")
print("=" * 50)

# ---- 1. randint(a, b)：a 到 b 之间的随机整数（含两端） ----
print("\n1. randint() 随机整数：")
print(f"   掷骰子：{random.randint(1, 6)}")
print(f"   抽学号：{random.randint(1, 50)}")

# ---- 2. choice(seq)：从序列中随机选一个元素 ----
print("\n2. choice() 随机选一个：")
fruits = ["苹果", "香蕉", "橘子", "葡萄", "西瓜", "草莓"]
print(f"   水果列表：{fruits}")
print(f"   今天吃：{random.choice(fruits)}")
print(f"   随机字母：{random.choice('ABCDEFGHIJKLMNOPQRSTUVWXYZ')}")

# ---- 3. shuffle(list)：随机打乱列表（原地修改） ----
print("\n3. shuffle() 洗牌：")
cards = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
print(f"   洗牌前：{cards}")
random.shuffle(cards)   # 原地打乱，没有返回值
print(f"   洗牌后：{cards}")

# ---- 4. random()：0.0 到 1.0 之间的随机小数 ----
print("\n4. random() 随机小数：")
print(f"   随机小数：{random.random():.4f}")
print(f"   模拟概率 30%：{'中奖' if random.random() < 0.3 else '谢谢参与'}")

# ---- 5. sample(population, k)：不重复地选 k 个 ----
print("\n5. sample() 不重复抽样：")
all_fruits = ["苹果", "香蕉", "橘子", "葡萄", "西瓜", "草莓", "蓝莓", "芒果"]
print(f"   全部：{all_fruits}")
print(f"   选 3 个（不重复）：{random.sample(all_fruits, 3)}")

# ---- 6. choices(population, k)：有放回地选 k 个 ----
print("\n6. choices() 可重复抽样：")
colors = ["红", "黄", "蓝"]
print(f"   从 {colors} 中抽 5 次（可重复）：{random.choices(colors, k=5)}")

# ---- 7. 综合示例：生成随机验证码 ----
print("\n7. 生成随机验证码：")

def generate_code(length=6):
    """生成指定长度的随机验证码（数字+大写字母）"""
    # string.digits = "0123456789"
    # string.ascii_uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    chars = string.digits + string.ascii_uppercase
    code = "".join(random.choices(chars, k=length))
    return code

for _ in range(3):
    print(f"   验证码：{generate_code()}")

# ---- 8. 综合示例：抽奖程序 ----
print("\n8. 抽奖程序：")
names = ["小明", "小红", "小刚", "小丽", "小强", "小美", "小华"]
print(f"   参与者：{names}")

# 三等奖：sample 选 3 个
third = random.sample(names, 3)
print(f"   三等奖（笔记本）：{third}")

# 二等奖：从剩下的人里选 2 个
remaining = [n for n in names if n not in third]
second = random.sample(remaining, 2)
print(f"   二等奖（蓝牙耳机）：{second}")

# 一等奖：从剩下的人里选 1 个
remaining = [n for n in remaining if n not in second]
first = random.choice(remaining)
print(f"   一等奖（iPad）🏆：{first}")

# ---- 9. seed()：设置随机种子，让随机可复现 ----
print("\n9. seed() 固定随机序列：")
random.seed(42)
a = random.randint(1, 100)
random.seed(42)
b = random.randint(1, 100)
print(f"   两次 seed(42) 后 randint 结果：{a} == {b} → {a == b}")
# 相同种子产生相同随机序列，调试时很有用
