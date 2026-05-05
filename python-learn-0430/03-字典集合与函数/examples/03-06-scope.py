"""
03-06 变量的作用域示例
用"教室里的东西（全局）vs 书包里的东西（局部）"类比
"""

print("=" * 40)
print("1. 全局变量 -- 像教室里的黑板，全班都能看到")
print("=" * 40)

school_name = "阳光中学"  # 全局变量
class_name = "初一(3)班"   # 又一个全局变量

def show_class_info():
    """函数内部可以直接访问全局变量"""
    print(f"学校: {school_name}, 班级: {class_name}")

show_class_info()
# 函数外面当然也能访问
print(f"直接访问: {school_name}")

print()
print("=" * 40)
print("2. 局部变量 -- 像自己书包里的东西，只有自己能用")
print("=" * 40)

def show_secret():
    """secret 是函数内部的局部变量"""
    secret = "我的密码是1234"
    print("函数内部:", secret)

show_secret()

# 在外面访问会报错！
# print(secret)  # NameError: name 'secret' is not defined

print()
print("=" * 40)
print("3. 同名变量互不影响")
print("=" * 40)

x = 10  # 全局变量 x

def try_change_x():
    """函数内部创建了一个新的局部变量 x"""
    x = 5  # 这是局部变量，和外面那个 x 不是同一个！
    print("函数内的 x:", x)

try_change_x()
print("函数外的 x:", x)  # 还是 10，没有变！

print()
print("=" * 40)
print("4. global 关键字 -- 真想改全局变量时用")
print("=" * 40)

counter = 0  # 全局计数器

def increase_without_global():
    """这个函数改不了全局 counter"""
    counter = 999  # 创建的是局部变量
    print("局部 counter:", counter)

def increase_with_global():
    """这个函数用 global 声明后，真的改了全局 counter"""
    global counter
    counter = counter + 1
    print("全局 counter 变成:", counter)

print("初始 counter:", counter)

increase_without_global()
print("调用 increase_without_global 后, counter:", counter)  # 还是 0

increase_with_global()
print("调用 increase_with_global 后, counter:", counter)  # 变成 1

increase_with_global()
print("再调用一次 increase_with_global 后, counter:", counter)  # 变成 2

print()
print("=" * 40)
print("5. 最佳实践 -- 少用 global，多用参数和返回值")
print("=" * 40)

# 推荐写法：通过参数传入，通过 return 返回
def add_score(current_scores, new_score):
    """不修改外部变量，接收参数、返回新结果"""
    current_scores = current_scores + new_score  # 处理的是局部变量
    return current_scores

total = 0
total = add_score(total, 10)
print("加 10 分后:", total)  # 10
total = add_score(total, 15)
print("再加 15 分后:", total)  # 25

# 这样写的好处：函数是"独立"的，不依赖外部状态
# 换一份数据也一样工作
another_total = 100
another_total = add_score(another_total, 50)
print("另一份数据加 50 后:", another_total)  # 150
