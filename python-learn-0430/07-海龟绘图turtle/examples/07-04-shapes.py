# -*- coding: utf-8 -*-
"""
07-04 画基本图形示例
====================
演示用循环画正方形、三角形、正多边形，以及 circle() 画圆和圆弧。

核心规律：正 N 边形，每次转 360/N 度。
"""

import turtle

t = turtle.Turtle()
t.speed(5)
t.pensize(2)

# ====== 1. 正方形 ======
t.pencolor("blue")
for _ in range(4):
    t.forward(100)
    t.right(90)     # 360 / 4 = 90

# 抬笔移到新位置
t.penup()
t.goto(150, 0)
t.pendown()

# ====== 2. 正三角形 ======
t.pencolor("red")
for _ in range(3):
    t.forward(100)
    t.right(120)    # 360 / 3 = 120

# 换位置
t.penup()
t.goto(-150, 0)
t.pendown()

# ====== 3. 正五边形 ======
t.pencolor("green")
for _ in range(5):
    t.forward(80)
    t.right(72)     # 360 / 5 = 72

# 清空，演示通用方法
t.clear()
t.penup()
t.goto(0, 50)
t.pendown()

# ====== 4. 通用：画任意正 N 边形 ======
n = 8               # 把 n 改成 3、4、5、6、8 试试
t.pencolor("purple")
for _ in range(n):
    t.forward(60)
    t.right(360 / n)

# 清空，演示 circle()
t.clear()
t.penup()
t.goto(0, 0)
t.pendown()
t.pensize(2)

# ====== 5. circle() 画圆和圆弧 ======

# 完整圆
t.pencolor("blue")
t.penup()
t.goto(-150, 0)
t.pendown()
t.circle(80)        # 半径 80 的完整圆

# 半圆
t.pencolor("red")
t.penup()
t.goto(0, 0)
t.pendown()
t.circle(80, 180)   # 半径 80，角度 180（半圆）

# 四分之三圆
t.pencolor("green")
t.penup()
t.goto(150, 0)
t.pendown()
t.circle(80, 270)   # 半径 80，角度 270

# 内切正多边形
t.pencolor("orange")
t.penup()
t.goto(0, -200)
t.pendown()
t.circle(80, 360, 6)  # 正六边形，内切于半径为 80 的圆

# ====== 6. 用 dot() 画实心圆点 ======
t.penup()
t.goto(50, 150)
t.dot(30, "red")      # 半径 30 的红色实心圆点
t.goto(0, 150)
t.dot(20, "blue")     # 半径 20 的蓝色实心圆点
t.goto(-50, 150)
t.dot(15, "green")    # 半径 15 的绿色实心圆点

turtle.done()
