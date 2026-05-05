"""
03-04 函数入门示例
用"菜谱（定义函数）vs 做菜（调用函数）"的类比来理解函数
"""

print("=" * 40)
print("1. 定义和调用最简单的函数")
print("=" * 40)


# 定义一个函数（就像写一份菜谱）
def greet():
    """
    这是一个简单的问候函数。
    定义时不会执行，只有被调用时才执行。
    """
    print("你好！")
    print("欢迎学习 Python 函数！")


# 调用函数（就像按菜谱做菜）
print("第一次调用 greet():")
greet()

print("\n第二次调用 greet():")
greet()

print()
print("=" * 40)
print("2. 为什么要用函数 -- 避免重复代码")
print("=" * 40)

# 没有函数的写法（重复代码很多）
print("--- 写法一：不用函数 ---")
# 给张三评语
name = "张三"
score = 92
if score >= 90:
    level = "优秀"
elif score >= 70:
    level = "良好"
else:
    level = "加油"
print(f"{name} 的成绩是 {score} 分，等级：{level}")

# 给李四评语 -- 几乎一模一样的代码又写一遍
name = "李四"
score = 78
if score >= 90:
    level = "优秀"
elif score >= 70:
    level = "良好"
else:
    level = "加油"
print(f"{name} 的成绩是 {score} 分，等级：{level}")

print()
print("--- 写法二：用函数 ---")


# 把重复的逻辑写成函数
def show_score(name, score):
    """根据分数打印学生的成绩等级"""
    if score >= 90:
        level = "优秀"
    elif score >= 70:
        level = "良好"
    else:
        level = "加油"
    print(f"{name} 的成绩是 {score} 分，等级：{level}")


# 调用函数 -- 多简洁！
show_score("张三", 92)
show_score("李四", 78)
show_score("王五", 55)

print()
print("=" * 40)
print("3. 函数让代码更有条理")
print("=" * 40)


def print_line():
    """打印分隔线"""
    print("-" * 30)


def show_title():
    """显示标题"""
    print("   >> Python 学习系统 <<")


def show_menu():
    """显示菜单"""
    print("1. 开始学习")
    print("2. 查看进度")
    print("3. 退出")


# 用函数组织代码，逻辑一目了然
print_line()
show_title()
print_line()
show_menu()
print_line()


# 甚至可以多次调用同一个函数组合
def welcome_block():
    print_line()
    show_title()
    print_line()


print("\n再来一次欢迎块:")
welcome_block()
