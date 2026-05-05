"""
============================================================
02-01 if 条件判断
============================================================
if = "如果……就……"。条件满足时执行缩进的代码。
缩进（4 个空格或 1 个 Tab）是 Python 的语法核心。
"""

print("========== 基本的 if ==========")

# 例 1：根据天气决定
weather = "下雨"            # 试试改成 "晴天" 看看输出变化
if weather == "下雨":
    print("带伞出门")
    print("穿雨鞋")
print("出门了")             # 这句没缩进，不管下不下雨都执行

print("-" * 30)

# 例 2：分数判断
score = 85
print("你的分数：", score)

if score >= 60:
    print("及格了！恭喜！")

if score >= 90:
    print("优秀！")

if score == 100:
    print("满分！太厉害了！")

# 观察：score=85 时，只有第一个 if 满足（>=60），后面两个不满足

print("-" * 30)

# 例 3：条件可以是布尔值
is_weekend = True

if is_weekend:
    print("今天是周末，可以睡懒觉！")

is_weekend = False

if is_weekend:
    print("这句不会执行")     # is_weekend 是 False

print("-" * 30)

# 例 4：多条件组合
age = 15
height = 160

# 检查：是否够格玩过山车（年龄 >=12 且身高 >=140）
if age >= 12 and height >= 140:
    print("你可以玩过山车！")

# 检查一个不满足的情况
if age < 12 or height < 140:
    print("你还不能玩过山车哦")

print("-" * 30)

# 例 5：if 可以嵌套（不推荐过度嵌套）
weather = "下雨"
has_umbrella = True

if weather == "下雨":
    print("外面在下雨")
    if has_umbrella:              # 嵌套的 if——在第一个 if 里面
        print("   还好带了伞")
    if not has_umbrella:
        print("   糟糕，没带伞！")

# 注意缩进的层次：每多一层嵌套，多缩进一级
