# -*- coding: utf-8 -*-
"""
08-04 matplotlib 入门示例
==========================
演示 plot() 折线图、bar() 柱状图、title()、show()、savefig() 等。

类比：matplotlib 就像 Python 里的 Excel 图表引擎。
注意：需要先 pip install matplotlib
"""

import matplotlib.pyplot as plt

# ---- 0. 设置中文字体（Windows） ----
# 如果你的系统没有 SimHei，可以换成 Microsoft YaHei 或注释掉这两行
plt.rcParams["font.sans-serif"] = ["SimHei"]
plt.rcParams["axes.unicode_minus"] = False  # 解决负号显示问题

print("=" * 50)
print("matplotlib 图表演示")
print("图表将依次弹出，关闭当前窗口后显示下一个")
print("=" * 50)

# ---- 1. 第一张图表：简单折线图 ----
print("\n1. 折线图演示...")

x = [1, 2, 3, 4, 5]
y = [2, 4, 6, 8, 10]

plt.figure(figsize=(8, 5))  # 设置图表大小（宽 8 英寸，高 5 英寸）
plt.plot(x, y)
plt.title("我的第一张图表")
plt.xlabel("X 轴")
plt.ylabel("Y 轴")
plt.grid(True)              # 显示网格
plt.show()

# ---- 2. 双线对比图（自定义样式） ----
print("2. 双线对比图演示...")

x = list(range(1, 11))
y1 = [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]     # 平方
y2 = [1, 8, 27, 64, 125, 216, 343, 512, 729, 1000]  # 立方

plt.figure(figsize=(8, 5))
# "r-o" = 红色(red) + 实线 + 圆点  "b--s" = 蓝色(blue) + 虚线 + 方块
plt.plot(x, y1, "r-o", label="x^2 (平方)")
plt.plot(x, y2, "b--s", label="x^3 (立方)")
plt.title("二次函数 vs 三次函数")
plt.xlabel("X")
plt.ylabel("Y")
plt.legend()    # 显示图例（因为每条线都设置了 label）
plt.grid(True)
plt.show()

# ---- 3. 柱状图 bar() ----
print("3. 柱状图演示...")

cities = ["北京", "上海", "广州", "成都", "武汉", "西安", "杭州"]
temperatures = [25, 28, 32, 26, 29, 27, 30]
colors_bar = ["red", "orange", "gold", "green", "blue", "purple", "pink"]

plt.figure(figsize=(10, 5))
plt.bar(cities, temperatures, color=colors_bar, edgecolor="black")
plt.title("各城市今日最高气温")
plt.xlabel("城市")
plt.ylabel("气温 (℃)")

# 在每个柱子上标注数值
for i, temp in enumerate(temperatures):
    plt.text(i, temp + 0.5, f"{temp}℃", ha="center")

plt.show()

# ---- 4. 饼图 pie() ----
print("4. 饼图演示...")

labels = ["学习", "睡觉", "吃饭", "运动", "娱乐"]
sizes = [8, 8, 2, 1, 5]  # 小时
colors_pie = ["lightblue", "lightgray", "lightyellow", "lightgreen", "pink"]
explode = (0, 0, 0, 0, 0.1)  # 把"娱乐"这块稍微突出

plt.figure(figsize=(8, 8))
plt.pie(sizes, explode=explode, labels=labels, colors=colors_pie,
        autopct="%1.1f%%", shadow=True, startangle=90)
plt.title("一天 24 小时时间分配")
plt.show()

# ---- 5. 保存图表到文件 ----
print("5. 保存图表到文件...")

x = [1, 2, 3, 4, 5, 6, 7]
y = [23, 25, 22, 28, 26, 29, 30]

plt.figure(figsize=(8, 4))
plt.plot(x, y, "g^-", linewidth=2, markersize=8)
plt.title("本周气温变化")
plt.xlabel("星期")
plt.ylabel("气温 (℃)")
plt.xticks(x, ["周一", "周二", "周三", "周四", "周五", "周六", "周日"])
plt.grid(True, linestyle="--", alpha=0.7)
# 先保存再 show
plt.savefig("temperature_week.png", dpi=150, bbox_inches="tight")
print("   图表已保存为 temperature_week.png")
plt.show()

print("\n所有图表演示完毕！")
