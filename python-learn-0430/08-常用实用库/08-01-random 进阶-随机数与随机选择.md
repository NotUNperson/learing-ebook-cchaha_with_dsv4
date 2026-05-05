# 08-01 random 进阶：随机数与随机选择

## 本节你会学到什么
- 用 `randint()` 生成指定范围的随机整数
- 用 `choice()` 从列表中随机选取一个元素
- 用 `shuffle()` 随机打乱列表顺序
- 用 `random()` 生成 0 到 1 之间的小数

## 正文

### 用"抽奖转盘"类比 random

公司年会上那个抽奖转盘还记得吗？指针一转，随机落在某个名字上。或者你玩的骰子游戏：一丢，随机出 1 到 6。

Python 的 `random` 模块就是这样一个"数字抽奖转盘"。它可以帮你做各种随机的事情：抽一个数字、选一个人、打乱扑克牌顺序、生成验证码等等。

`random` 是 Python 内置模块，不需要额外安装。

### randint()：生成随机整数

```python
import random

num = random.randint(1, 10)
print(num)  # 可能是 1 到 10 之间的任意整数，包含 1 和 10
```

`randint(a, b)` 返回 a 到 b 之间（包含 a 和 b）的一个随机整数。就像一个范围骰子。

常用场景：
- 生成一个 4 位数的验证码：`random.randint(1000, 9999)`
- 模拟掷骰子：`random.randint(1, 6)`
- 抽学号：`random.randint(1, 50)`

### choice()：随机选一个

```python
fruits = ["苹果", "香蕉", "橘子", "葡萄", "西瓜"]
winner = random.choice(fruits)
print(f"今天的水果是：{winner}")
```

`choice(seq)` 从一个序列（列表、元组、字符串）中随机选取一个元素。就像从抽奖箱里摸一个出来。

对字符串也可以用：

```python
random.choice("ABCDEFGHIJKLMNOPQRSTUVWXYZ")  # 随机一个大写字母
```

### shuffle()：随机打乱顺序

```python
cards = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
random.shuffle(cards)
print(cards)  # 洗牌后的结果
```

`shuffle(list)` 会**原地**打乱列表的顺序（"原地"的意思是直接修改原列表，不生成新列表）。就像洗扑克牌。

注意：`shuffle()` 只能用于可变序列（如列表），不能用于元组或字符串。而且它没有返回值（返回 `None`），直接修改传入的列表。

### random()：生成 0 到 1 的随机小数

```python
prob = random.random()
print(f"概率：{prob:.2%}")  # 以百分比形式输出

# 生成 5 到 10 之间的随机小数
value = 5 + random.random() * 5
print(value)  # 比如 7.3241
```

`random()` 返回 0.0 到 1.0 之间（不包含 1.0）的一个随机小数。很适合模拟概率：比如 `random() < 0.3` 表示 30% 的概率。

### 更多实用的 random 函数

| 函数 | 作用 | 示例 |
|------|------|------|
| `uniform(a, b)` | a 到 b 之间的随机小数 | `random.uniform(1.5, 3.5)` |
| `randrange(start, stop, step)` | 从 range 里随机选一个 | `random.randrange(0, 101, 2)` 偶数 |
| `sample(population, k)` | 随机选 k 个不重复的元素 | `random.sample(fruits, 2)` |
| `choices(population, k)` | 随机选 k 个（可重复） | `random.choices(fruits, k=5)` |
| `seed(n)` | 设置随机种子，让随机可复现 | `random.seed(42)` |

`seed(42)` 这个特别提一下：如果你在随机之前先 `random.seed(某个数字)`，那么每次运行生成的"随机"数都是相同序列。这在调试时很有用 —— 让"随机"变得可预测，方便复现 bug。

### 综合示例：抽奖小程序

```python
import random

# 参与者名单
names = ["小明", "小红", "小刚", "小丽", "小强", "小美", "小华"]

# 三等奖：随机选 3 个（不重复）
third_prize = random.sample(names, 3)
print(f"三等奖（每人一本笔记本）：{third_prize}")

# 剩下的进入二等奖抽奖
remaining = [n for n in names if n not in third_prize]
second_prize = random.sample(remaining, 2)
print(f"二等奖（每人一个蓝牙耳机）：{second_prize}")

# 一等奖：从所有未中奖的人里选
remaining = [n for n in remaining if n not in second_prize]
first_prize = random.choice(remaining)
print(f"一等奖（iPad）：{first_prize}")
```

### 实用技巧：生成随机验证码

```python
import random
import string

def generate_code(length=6):
    """生成指定长度的随机验证码（数字+大写字母）"""
    chars = string.digits + string.ascii_uppercase
    code = ''.join(random.choices(chars, k=length))
    return code

print(f"你的验证码是：{generate_code()}")
```

`string.digits` 是 `"0123456789"`，`string.ascii_uppercase` 是大写字母。不用自己打一遍！

## 动手试试

1. 模拟掷 1000 次骰子，统计每个点数出现的次数，看是不是接近 1/6。
2. 写一个"今天谁请客"程序：输入几个朋友的名字，随机选一个。
3. 写一个"抽扑克牌"程序：用 shuffle 洗牌，然后打印前 5 张。
4. 写一个"石头剪刀布"简化版：你输入，computer 用 random.choice 出拳，判断输赢。

## 本节小结

`random` 是 Python 的数字抽奖箱：`randint` 随机整数，`choice` 随机选一个，`shuffle` 洗牌，`random` 随机小数 —— 生活里很多随机场景都能用代码模拟。

## 下一节预告

随机性很好玩，但生活里也充满了时间。下一节学习用 datetime 处理日期和时间。
