# -*- coding: utf-8 -*-
"""
07-02 移动与转向示例
====================
演示 right()、left()、setheading()、goto() 的用法。

类比：
- right()/left()：拿着遥控器左右转弯
- setheading()：看指南针调整朝向
- goto()：输入地图坐标直接飞过去
"""

import turtle

t = turtle.Turtle()
t.speed(3)          # 设置速度（1=最慢，10=最快）

# ====== 1. right() 和 left() ======
# right(angle)：顺时针转 angle 度
# left(angle)：逆时针转 angle 度

t.forward(100)      # 向右走 100
t.right(90)         # 右转 90 度 → 现在头朝下
t.forward(100)      # 向下走 100
t.left(90)          # 左转 90 度 → 现在头朝右
t.forward(100)      # 再向右走 100
# 此时画了一个倒 L 形

print(f"当前位置: {t.pos()}")       # 输出当前坐标
print(f"当前朝向: {t.heading()} 度") # 输出当前朝向

# 清空画布，重新开始演示
t.clear()
t.penup()
t.goto(0, 0)
t.pendown()

# ====== 2. setheading() ======
# setheading(angle) 或 seth(angle)：设置绝对朝向

t.seth(45)          # 朝向 45 度（东北方向）
t.forward(100)      # 沿 45 度方向走

t.seth(135)         # 朝向 135 度（西北方向）
t.forward(100)      # 沿 135 度方向走

# 清空，继续演示
t.clear()
t.penup()
t.goto(0, 0)
t.pendown()

# ====== 3. goto() ======
# goto(x, y)：直线移动到指定坐标

t.goto(100, 100)    # 走到 (100, 100)
t.goto(200, 0)      # 走到 (200, 0)
t.goto(0, 0)        # 走回原点
# 这 3 步画了一个三角形

# ====== 4. 综合：画直角三角形 ======
t.clear()            # 清空画布
t.penup()
t.goto(-100, -100)   # 把起点挪到左下角
t.pendown()

t.forward(200)       # 底边 200
t.left(90)
t.forward(150)       # 竖边 150
t.goto(-100, -100)   # 斜边（直接飞回起点）

turtle.done()
