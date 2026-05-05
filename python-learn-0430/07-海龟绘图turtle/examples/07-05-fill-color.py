# -*- coding: utf-8 -*-
"""
07-05 填充颜色示例
==================
演示 fillcolor()、begin_fill()、end_fill() 的用法。

类比：给涂色本的轮廓内部填上颜色。
"""

import turtle

# 设置画布
window = turtle.Screen()
window.bgcolor("lightyellow")   # 浅黄色背景，让填充色更显眼
window.title("填充颜色演示")

t = turtle.Turtle()
t.speed(5)
t.pensize(3)

# ====== 1. 基本三步：选颜色 → 开始 → 画图 → 结束 ======
t.penup()
t.goto(-200, 100)
t.pendown()

t.pencolor("red")          # 轮廓颜色：红色
t.fillcolor("yellow")      # 填充颜色：黄色
t.begin_fill()             # 开始填充
for _ in range(4):
    t.forward(80)
    t.right(90)
t.end_fill()               # 结束填充 → 正方形自动填满黄色

# 标注
t.penup()
t.goto(-200, 70)
t.write("正方形", font=("Arial", 12, "normal"))

# ====== 2. 填充三角形 ======
t.penup()
t.goto(-50, 100)
t.pendown()

t.color("blue", "lightblue")  # 一行设置：轮廓蓝，填充浅蓝
t.begin_fill()
for _ in range(3):
    t.forward(80)
    t.right(120)
t.end_fill()

t.penup()
t.goto(-50, 70)
t.write("三角形", font=("Arial", 12, "normal"))

# ====== 3. 填充圆形 ======
t.penup()
t.goto(150, 100)
t.pendown()

t.color("green", "#90EE90")   # 绿轮廓，浅绿填充
t.begin_fill()
t.circle(40)                  # 半径 40 的圆
t.end_fill()

t.penup()
t.goto(150, 70)
t.write("圆形", font=("Arial", 12, "normal"))

# ====== 4. 彩色同心靶子 ======
t.clear()
t.speed(8)

# 使用颜色列表
colors = ["red", "orange", "yellow", "green", "blue", "purple"]

for i, color_name in enumerate(colors):
    t.penup()
    t.goto(0, -25 * (i + 1))   # 每层圆心往下挪 25 像素
    t.pendown()
    t.pencolor(color_name)
    t.fillcolor(color_name)
    t.begin_fill()
    t.circle(25 * (i + 1))     # 半径递增：25, 50, 75...
    t.end_fill()

# ====== 5. 填充八边形 ======
t.clear()
t.penup()
t.goto(-60, 40)
t.pendown()
t.color("red", "pink")
t.pensize(4)
t.begin_fill()
for _ in range(8):
    t.forward(50)
    t.right(360 / 8)
t.end_fill()
t.penup()
t.goto(-60, 0)
t.write("红边框 + 粉填充的八边形", font=("Arial", 10, "normal"))

turtle.done()
