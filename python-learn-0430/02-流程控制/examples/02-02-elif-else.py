"""
============================================================
02-02 elif 和 else 多分支判断
============================================================
if-elif-else：多个选项选一个，从上到下检查，命中即停。
elif = "否则如果"，else = "否则"（兜底）。
"""

print("========== 成绩等级判定 ==========")

score = 85
print("成绩：", score)

if score >= 90:
    print("等级：A（优秀）")
elif score >= 80:
    print("等级：B（良好）")
elif score >= 70:
    print("等级：C（中等）")
elif score >= 60:
    print("等级：D（及格）")
else:
    print("等级：F（不及格）")

# 注意：85 同时满足 >=80 和 >=70，
# 但只会执行第一个命中的（>=80），后面的跳过

print("\n========== 改变分数观察 ==========")
# 测试不同的分数
test_scores = [95, 82, 75, 61, 45]

for s in test_scores:
    if s >= 90:
        grade = "A"
    elif s >= 80:
        grade = "B"
    elif s >= 70:
        grade = "C"
    elif s >= 60:
        grade = "D"
    else:
        grade = "F"
    print("分数", s, "→ 等级", grade)

print("\n========== 多个 if vs if-elif ==========")
value = 50

# 写法 1：多个 if（每个都检查）
print("多个 if 的结果：")
if value > 30:
    print("  大于 30")
if value > 40:
    print("  大于 40")
if value > 60:
    print("  大于 60")
# 每前两个都打印了

# 写法 2：if-elif（命中即停）
print("if-elif 的结果：")
if value > 60:
    print("  大于 60")
elif value > 40:
    print("  大于 40")
elif value > 30:
    print("  大于 30")
# 只打印了"大于 40"

print("\n========== 生活中的多分支 ==========")

# 看月份判断季节
month = 7
print("现在是", month, "月")

if month in [3, 4, 5]:
    print("春天")
elif month in [6, 7, 8]:
    print("夏天")
elif month in [9, 10, 11]:
    print("秋天")
elif month in [12, 1, 2]:
    print("冬天")
else:
    print("月份不合法！")

# 看时间决定问候语
hour = 14
print("现在是", hour, "点")

if hour < 6:
    print("凌晨好")
elif hour < 12:
    print("早上好")
elif hour < 18:
    print("下午好")
else:
    print("晚上好")
