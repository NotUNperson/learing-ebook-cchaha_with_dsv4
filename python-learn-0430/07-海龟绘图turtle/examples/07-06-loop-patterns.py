# -*- coding: utf-8 -*-
"""
07-06 循环画图示例：创造复杂图案
================================
演示用循环 + 旋转创造对称图案、螺旋线等。

类比：万花筒 —— 简单规则重复多次，产生复杂美感。
"""

import turtle

# ====== 准备画布 ======
t = turtle.Turtle()
t.speed(0)      # 最快，因为图案比较复杂
t.pensize(2)

# =====================================================
#  图案一：太阳光芒（36 条线从中心散开）
# =====================================================

# 画在左上角
t.penup()
t.goto(-250, 150)
t.pendown()

t.pencolor("orange")
for _ in range(36):
    t.forward(100)
    t.backward(100)    # 回到起点
    t.right(10)        # 36 * 10 = 360，正好转一圈

# =====================================================
#  图案二：旋转正方形（36 个正方形围成一圈）
# =====================================================

t.penup()
t.goto(150, 150)
t.pendown()

colors = ["red", "orange", "yellow", "green", "blue", "purple"]

for i in range(36):
    t.pencolor(colors[i % len(colors)])  # 循环取色
    for _ in range(4):                   # 画一个正方形
        t.forward(60)
        t.right(90)
    t.right(10)                          # 旋转 10 度

# =====================================================
#  图案三：螺旋线
# =====================================================

# 清空，开始螺旋线演示
t.clear()
t.penup()
t.goto(0, 0)
t.pendown()
t.pensize(2)

turtle.bgcolor("black")  # 黑色背景让彩色螺旋更耀眼

spiral_colors = ["red", "yellow", "blue", "green", "purple", "orange"]

for i in range(200):
    t.pencolor(spiral_colors[i % len(spiral_colors)])
    t.forward(i * 2)     # 越走越远
    t.right(59)          # 59 度产生优美的螺旋效果
    # 试试改成 37、89、121 看不同螺旋

# =====================================================
#  图案四：旋转三角形
# =====================================================

t.clear()
turtle.bgcolor("white")
t.penup()
t.goto(0, 0)
t.pendown()

for i in range(12):
    t.pencolor(colors[i % len(colors)])
    for _ in range(3):       # 三角形
        t.forward(80)
        t.right(120)
    t.right(30)              # 12 * 30 = 360

# =====================================================
#  图案五：五角星
# =====================================================

t.clear()
t.penup()
t.goto(0, 30)
t.pendown()
t.pensize(3)
t.pencolor("gold")
t.fillcolor("yellow")

t.begin_fill()
for _ in range(5):
    t.forward(150)
    t.right(144)    # 五角星的转弯角度 = 180 - 180/5
t.end_fill()

# 在下面画个六角星对比
t.penup()
t.goto(0, -120)
t.pendown()
t.pencolor("blue")
t.fillcolor("lightblue")

t.begin_fill()
for _ in range(6):
    t.forward(80)
    t.right(150)    # 六角星 = 180 - 180/6
t.end_fill()

turtle.done()
