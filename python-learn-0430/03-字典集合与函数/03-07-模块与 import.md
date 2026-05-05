# 03-07 模块与 import

## 本节你会学到什么
- 理解什么是模块以及为什么要用模块
- 使用 import 和 from...import 导入模块
- 认识两个超好用的内置模块：math 和 random

## 正文
### 模块是什么 -- 工具箱

你家里有一套工具箱，里面有锤子、螺丝刀、扳手。当你需要钉钉子时，你不会自己从矿石开始炼铁造锤子，而是打开工具箱，拿出锤子就用。

Python 的**模块**就是这样的"工具箱"。很多常用的功能已经有人写好了、打包好了，你只需要用 `import` 把它"拿"过来就能用。

比如你想计算一个数的平方根，不用自己写算法，直接"借用" math 模块：

```python
import math

result = math.sqrt(25)  # sqrt 是 square root（平方根）
print(result)  # 5.0
```

### 两种导入方式

```python
# 方式一：import 模块名 -- 使用时需要加"模块名."
import math
print(math.pi)       # 3.141592653589793
print(math.floor(3.8))  # 3（向下取整）

# 方式二：from 模块名 import 具体功能 -- 直接使用，不用加前缀
from math import pi, sqrt
print(pi)
print(sqrt(16))  # 4.0 -- 直接写 sqrt，不用写 math.sqrt

# 可以给模块起别名（名字太长时很有用）
import random as rd
print(rd.randint(1, 10))  # 1 到 10 之间的随机整数
```

选择建议：如果只用一两个功能，用 `from...import` 省事；如果要用很多，用 `import` 加模块名前缀更清晰，知道这个函数是"借"来的。

### 两个必学的内置模块

**math -- 数学工具箱**

```python
import math

print(math.ceil(3.2))   # 4  -- 向上取整（天花板）
print(math.floor(3.8))  # 3  -- 向下取整（地板）
print(math.fabs(-5))    # 5.0 -- 绝对值
print(math.pow(2, 10))  # 1024.0 -- 2 的 10 次方
```

**random -- 随机数工具箱**

```python
import random

# 随机整数
print(random.randint(1, 6))   # 掷骰子：1 到 6 的随机整数

# 随机小数
print(random.random())        # 0 到 1 之间的随机小数

# 从列表里随机挑一个
fruits = ["苹果", "香蕉", "橙子"]
print(random.choice(fruits))  # 随机抽一种水果

# 把列表随机打乱
cards = ["A", "K", "Q", "J"]
random.shuffle(cards)
print(cards)  # 顺序被随机打乱了
```

## 动手试试
1. `import math`，计算一个圆的面积（半径 r = 5，公式：pi * r 的平方）
2. `import random`，模拟掷 10 次骰子（1-6 的随机整数），用 for 循环打印每次的结果
3. 从列表 `["石头", "剪刀", "布"]` 中随机选一个，打印出来

## 本节小结
模块就是 Python 自带的工具箱，用 import 拿出来就能用，省时省力。

## 下一节预告
结合起来！用字典 + 函数 + 循环做一个实用的小项目 -- 简易通讯录。
