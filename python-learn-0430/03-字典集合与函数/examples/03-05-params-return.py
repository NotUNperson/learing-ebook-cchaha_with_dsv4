"""
03-05 参数与返回值示例
用"自动售货机"类比：投钱（参数）→ 出货（返回值）
"""

print("=" * 40)
print("1. 位置参数 -- 像自动售货机的投币口")
print("=" * 40)


def buy_drink(money):
    """投 money 元，返回买到的饮料"""
    if money >= 5:
        return "可乐"
    elif money >= 3:
        return "矿泉水"
    else:
        return "钱不够！"


# 投入不同的钱，得到不同的结果
print("投 5 元:", buy_drink(5))
print("投 3 元:", buy_drink(3))
print("投 2 元:", buy_drink(2))

print()
print("=" * 40)
print("2. 多个参数")
print("=" * 40)


def introduce(name, age, hobby):
    """介绍一个人 -- 三个参数"""
    print(f"大家好，我叫{name}，今年{age}岁，喜欢{hobby}。")


# 必须按顺序传入参数
introduce("小明", 15, "打篮球")
introduce("小红", 14, "画画")

# 也可以用"关键字参数"的方式传参，不按顺序也行
introduce(age=16, hobby="弹吉他", name="小刚")

print()
print("=" * 40)
print("3. 默认参数 -- 不传就用默认值")
print("=" * 40)


def greet(name, greeting="你好"):
    """问候某人，默认问候语是'你好'"""
    print(f"{greeting}，{name}！")


greet("小明")                    # 使用默认问候语
greet("小红", "早上好")          # 传入自定义问候语
greet("小刚", greeting="晚上好")  # 也可以用关键字方式传


# 计算长方形面积，默认宽=1（也就是默认是宽为1的长条）
def rectangle_area(length, width=1):
    """计算长方形面积，默认 width=1"""
    return length * width


print("\n长方形面积计算:")
print(f"长 10, 宽 5: {rectangle_area(10, 5)}")    # 50
print(f"长 10, 不传宽: {rectangle_area(10)}")    # 10（默认宽=1）
print(f"长 6, 宽 6: {rectangle_area(6, 6)}")      # 36

print()
print("=" * 40)
print("4. return -- 把结果还回去")
print("=" * 40)


def add(a, b):
    """返回两数之和"""
    return a + b


def subtract(a, b):
    """返回两数之差"""
    return a - b


# 返回值可以存到变量里
sum_result = add(10, 20)
print(f"10 + 20 = {sum_result}")

# 返回值可以直接参与运算
print(f"(10 + 20) * (30 - 5) = {add(10, 20) * subtract(30, 5)}")

# 函数也可以返回多个值（实际上是返回一个元组）
def get_user_info():
    """返回多个值"""
    name = "小明"
    age = 15
    city = "北京"
    return name, age, city


n, a, c = get_user_info()
print(f"姓名: {n}, 年龄: {a}, 城市: {c}")

print()
print("=" * 40)
print("5. print 和 return 的区别 -- 非常重要！")
print("=" * 40)


def func_print():
    """这个函数只打印，不返回"""
    print("我在打印东西")


def func_return():
    """这个函数返回一个值"""
    return "我返回了东西"


# func_print 只显示，没有返回值
p = func_print()
print("func_print 的返回值:", p)  # None

# func_return 有返回值
r = func_return()
print("func_return 的返回值:", r)  # "我返回了东西"

# 关键区别：有 return 的值可以继续用
if r:
    print("返回值可以被条件判断使用！")

if p:
    print("这句话不会打印，因为 p 是 None")
