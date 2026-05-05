# -*- coding: utf-8 -*-
"""
07-07 综合练习：画一朵花 + 星星
===============================
综合运用 turtle 的各种技能，把复杂图案分解为简单零件。

核心思路：
- 用函数封装可复用的图形（花瓣、叶子、星星）
- 用循环把单个零件旋转围成完整图案
- penup/pendown 控制在不同位置之间跳转
"""

import turtle

# ====== 准备画布 ======
window = turtle.Screen()
window.title("一朵花和一颗星星")
window.bgcolor("lightyellow")

t = turtle.Turtle()
t.speed(8)
t.pensize(2)

# =====================================================
#  零件函数定义
# =====================================================

def draw_petal(radius, color_name):
    """
    画一个花瓣。
    用两个四分之一圆弧拼成一个花瓣形状。

    参数:
        radius: 花瓣的半径
        color_name: 花瓣的填充颜色
    """
    t.fillcolor(color_name)
    t.begin_fill()
    t.circle(radius, 90)      # 四分之一圆弧
    t.left(90)
    t.circle(radius, 90)      # 又一个四分之一圆弧
    t.left(90)                # 方向恢复
    t.end_fill()


def draw_leaf(radius, color_name):
    """
    画一片叶子。
    结构和花瓣类似，两个四分之一圆弧拼成叶子。
    """
    t.fillcolor(color_name)
    t.begin_fill()
    t.circle(radius, 90)
    t.left(90)
    t.circle(radius, 90)
    t.left(90)
    t.end_fill()


def draw_star(size, color_name):
    """
    画一个填充颜色的五角星。
    五角星转弯角度 = 180 - 180/5 = 144 度。

    参数:
        size: 边长
        color_name: 填充颜色
    """
    t.fillcolor(color_name)
    t.begin_fill()
    for _ in range(5):
        t.forward(size)
        t.right(144)
    t.end_fill()


# =====================================================
#  第一步：画花朵（6 个花瓣围成圈）
# =====================================================

# 把海龟移动到花朵中心位置
t.penup()
t.goto(-50, 120)
t.pendown()
t.pencolor("deeppink")

petal_count = 6          # 花瓣数量，试试改成 8、10、12
for _ in range(petal_count):
    draw_petal(60, "pink")
    t.right(360 / petal_count)  # 旋转到下一个花瓣的位置


# =====================================================
#  第二步：画花心
# =====================================================

t.penup()
t.goto(-50, 60)
t.pendown()
t.fillcolor("yellow")
t.begin_fill()
t.circle(25)                # 半径 25 的圆形花心
t.end_fill()


# =====================================================
#  第三步：画花茎
# =====================================================

t.penup()
t.goto(-50, 60)             # 从花心正下方开始
t.pendown()
t.pencolor("darkgreen")
t.pensize(6)
t.setheading(270)           # 朝向正下方
t.forward(220)              # 画直线茎


# =====================================================
#  第四步：画两片叶子
# =====================================================

t.pensize(2)

# 左边叶子
t.penup()
t.goto(-50, -40)            # 茎的左边
t.setheading(210)           # 朝左下方
t.pendown()
draw_leaf(35, "lightgreen")

# 右边叶子
t.penup()
t.goto(-50, -100)           # 茎的右边（再往下一点）
t.setheading(330)           # 朝右下方
t.pendown()
draw_leaf(35, "mediumspringgreen")


# =====================================================
#  第五步：在旁边画一颗五角星
# =====================================================

t.penup()
t.goto(180, 180)            # 右上角
t.setheading(0)             # 朝右
t.pendown()
t.pencolor("gold")
t.pensize(2)
draw_star(100, "gold")


# =====================================================
#  第六步：再画一颗小星星（像国旗上的小星星）
# =====================================================

t.penup()
t.goto(280, 80)
t.setheading(45)            # 朝向 45 度（东北）
t.pendown()
t.pencolor("orange")
draw_star(40, "yellow")


# =====================================================
#  收尾
# =====================================================

t.hideturtle()              # 隐藏海龟，画面更干净
print("画完了！欣赏一下你的作品吧。")
turtle.done()
