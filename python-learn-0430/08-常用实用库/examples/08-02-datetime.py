# -*- coding: utf-8 -*-
"""
08-02 datetime 示例
===================
演示 datetime.now()、strftime()、timedelta、strptime() 的用法。

类比：datetime 就是你的日历和手表，写代码也能看时间。
"""

from datetime import datetime, timedelta, date, time

print("=" * 50)
print("datetime 常用功能演示")
print("=" * 50)

# ---- 1. datetime.now() 获取当前时间 ----
print("\n1. datetime.now() 当前时间：")
now = datetime.now()
print(f"   原始格式：{now}")
print(f"   年份：{now.year}")
print(f"   月份：{now.month}")
print(f"   日期：{now.day}")
print(f"   小时：{now.hour}")
print(f"   分钟：{now.minute}")
print(f"   秒数：{now.second}")
print(f"   星期：{now.weekday()} (0=周一, 6=周日)")

# ---- 2. strftime() 格式化输出 ----
print("\n2. strftime() 格式化时间：")
print(f"   标准日期：{now.strftime('%Y-%m-%d')}")
print(f"   中文日期：{now.strftime('%Y年%m月%d日')}")
print(f"   时间：{now.strftime('%H:%M:%S')}")
print(f"   完整：{now.strftime('%Y-%m-%d %H:%M:%S')}")
print(f"   星期：{now.strftime('%A')}")
print(f"   12小时制：{now.strftime('%I:%M %p')}")
print(f"   中文星期：星期{['一','二','三','四','五','六','日'][now.weekday()]}")

# ---- 3. timedelta 时间差 ----
print("\n3. timedelta 计算时间差：")

# 计算距离元旦还有几天
new_year = datetime(2027, 1, 1)
days_to_new_year = (new_year - now).days
print(f"   距离 2027 年元旦还有 {days_to_new_year} 天")

# 加减天数
future_30 = now + timedelta(days=30)
past_100 = now - timedelta(days=100)
print(f"   30 天后：{future_30.strftime('%Y-%m-%d')}")
print(f"   100 天前：{past_100.strftime('%Y-%m-%d')}")

# 使用时、分、秒
in_5_hours = now + timedelta(hours=5)
in_90_min = now + timedelta(minutes=90)
print(f"   5 小时后：{in_5_hours.strftime('%H:%M')}")
print(f"   90 分钟后：{in_90_min.strftime('%H:%M')}")

# 两周后
two_weeks = now + timedelta(weeks=2)
print(f"   两周后：{two_weeks.strftime('%Y-%m-%d')}")

# ---- 4. strptime() 解析字符串为时间 ----
print("\n4. strptime() 解析时间字符串：")
date_str1 = "2026-04-30 15:30:00"
dt1 = datetime.strptime(date_str1, "%Y-%m-%d %H:%M:%S")
print(f"   解析 '{date_str1}' → 年份={dt1.year}, 月份={dt1.month}")

date_str2 = "2026/04/30"
dt2 = datetime.strptime(date_str2, "%Y/%m/%d")
print(f"   解析 '{date_str2}' → {dt2}")

date_str3 = "30-04-2026"
dt3 = datetime.strptime(date_str3, "%d-%m-%Y")
print(f"   解析 '{date_str3}' → {dt3}")

# 记忆法：strptime 中 p = parse（解析），strftime 中 f = format（格式化）

# ---- 5. date 类：只看日期 ----
print("\n5. date.today() 只看日期：")
today = date.today()
print(f"   今天：{today}")
print(f"   年/月/日：{today.year}/{today.month}/{today.day}")

# 计算活了多久（示例生日）
birthday = date(1995, 6, 15)
days_alive = (today - birthday).days
years_alive = days_alive / 365.25
print(f"   如果生日是 {birthday}：")
print(f"   已经活了 {days_alive} 天（约 {years_alive:.1f} 年）")

# ---- 6. time 类：只看时间 ----
print("\n6. time 类：")
noon = time(12, 0, 0)
evening = time(18, 30, 0)
print(f"   中午：{noon.strftime('%H:%M')}")
print(f"   傍晚：{evening.strftime('%H:%M')}")

# ---- 7. 小应用：判断今天是不是星期五 ----
print("\n7. 判断今天是星期几：")
weekday_names = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"]
weekday_index = now.weekday()  # 0=周一
print(f"   今天是{weekday_names[weekday_index]}")
if weekday_index == 4:
    print("   TGIF! 感谢上帝今天是星期五！")
elif weekday_index in (5, 6):
    print("   周末愉快！")
else:
    print(f"   还有 {4 - weekday_index} 天到星期五，加油！")
