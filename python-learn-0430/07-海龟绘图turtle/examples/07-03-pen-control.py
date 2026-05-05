# -*- coding: utf-8 -*-
"""
07-03 画笔控制示例
==================
演示 pencolor()、pensize()、penup()、pendown()、speed() 的用法。

类比：
- pencolor()/pensize()：换不同颜色和粗细的笔
- penup()/pendown()：抬笔换位置 / 落笔继续画
- speed()：调整画画的速度
"""

import turtle

t = turtle.Turtle()
t.speed(5)  # 中速

# ====== 1. pencolor() 设置笔颜色 ======
# 可以用颜色名字、十六进制码，或者（需先 colormode(255)）RGB 元组

t.pencolor("red")           # 方式一：颜色名字
t.forward(100)

t.pencolor("#0000FF")       # 方式二：十六进制蓝色
t.forward(100)              # 继续走（会沿当前方向）

turtle.colormode(255)       # 切换到 RGB 模式（0-255）
t.pencolor(0, 180, 0)       # 方式三：RGB 绿色
t.forward(100)

# 把海龟挪回来
t.penup()
t.goto(0, 0)
t.seth(0)
t.pendown()

# ====== 2. pensize() 设置笔粗细 ======
# pensize(数字) 或 width(数字)，单位是像素

for size in [1, 3, 5, 7]:
    t.pensize(size)         # 每次循环换一种粗细
    t.forward(80)
    # 抬笔换行，不画线
    t.penup()
    t.right(90)
    t.forward(20)
    t.right(90)
    t.forward(80)
    t.right(180)
    t.pendown()
# 画了 4 条逐渐变粗的线

# 清空，演示 penup/pendown
t.clear()
t.speed(6)

# ====== 3. penup() / pendown() 抬笔和落笔 ======

# 先画一条线
t.pencolor("blue")
t.pensize(3)
t.forward(150)

# 抬笔，跳到下面，落笔，画第二条线（两条线是断开的）
t.penup()          # 抬笔 → 移动不会画线
t.goto(0, -50)     # 跳到下面
t.pendown()        # 落笔 → 恢复画线
t.forward(150)

# 如果不抬笔直接 goto 会怎么样？
# t.goto(0, -100)   # 会从 (150, -50) 画一条斜线到 (0, -100)
# 注释掉了，你可以取消注释试试

# ====== 4. speed() 速度演示 ======
t.clear()
t.penup()
t.goto(-200, 100)
t.pendown()
t.pensize(2)

# 尝试把 speed 值从 1 改到 10 再改到 0，观察动画速度
t.speed(1)          # 把它改成 5、10、0 分别试试
t.pencolor("purple")
for _ in range(4):
    t.forward(100)
    t.left(90)
# 用最慢速度画一个正方形，你可以清楚看到海龟的移动过程

turtle.done()
