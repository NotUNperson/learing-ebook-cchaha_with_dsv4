"""
============================================================
01-04 比较运算与逻辑运算
============================================================
比较运算：判断大小和相等，结果是 True 或 False
逻辑运算：and（而且）、or（或者）、not（取反）
"""

print("========== 比较运算 ==========")

# 大于和小于
print("5 > 3：", 5 > 3)         # True
print("5 < 3：", 5 < 3)         # False
print("10 >= 10：", 10 >= 10)   # True（大于或等于，满足一个就行）
print("10 <= 5：", 10 <= 5)     # False

# 等于和不等于（重要：判断相等用两个等号 ==）
print("100 == 100：", 100 == 100)          # True
print("100 == 99：", 100 == 99)            # False
print("'abc' == 'abc'：", "abc" == "abc")  # True（字符串也可以比较）
print("'abc' == 'ABC'：", "abc" == "ABC")  # False（大小写不同！）

# 不等于
print("100 != 99：", 100 != 99)            # True（确实不等）
print("100 != 100：", 100 != 100)          # False（相等，所以"不等"是错的）

print("\n========== 一个等号 vs 两个等号 ==========")
# =  （一个等号）：赋值——把东西放进盒子
# == （两个等号）：比较——盒子里的东西等于 XXX 吗？
age = 15                      # 赋值：把 15 放到 age 里
print("age =", age)
print("age == 15：", age == 15)   # 比较：age 等于 15 吗？True
print("age == 20：", age == 20)   # 比较：age 等于 20 吗？False

print("\n========== 逻辑运算 and ==========")
# and：所有条件都满足 → True；有一个不满足 → False
weather = "晴"
day = "周末"
print("晴天？", weather == "晴")
print("周末？", day == "周末")
print("晴天且周末？", weather == "晴" and day == "周末")   # True

# 一个条件不满足就是 False
print("晴天且周一？", weather == "晴" and day == "周一")   # False

print("\n========== 逻辑运算 or ==========")
# or：满足任意一个 → True；都不满足 → False
has_card = True
has_coupon = False
print("有会员卡？", has_card)
print("有优惠券？", has_coupon)
print("有卡或有券？", has_card or has_coupon)   # True（有卡就行）

is_raining = False
is_snowing = False
print("下雨或下雪？", is_raining or is_snowing)   # False（都没有）

print("\n========== 逻辑运算 not ==========")
# not：True 变 False，False 变 True
print("not True：", not True)        # False
print("not False：", not False)      # True
print("not (5 > 3)：", not (5 > 3))  # 5>3 是 True，not 后变 False

print("\n========== 综合运用 ==========")
# 判断一个人是否符合"青少年"标准：年龄 13-19 且身高大于 150
age = 15
height = 165
is_teenager = age >= 13 and age <= 19
is_tall_enough = height > 150
print("年龄在 13-19 之间？", is_teenager)
print("身高大于 150？", is_tall_enough)
print("符合全部条件？", is_teenager and is_tall_enough)
