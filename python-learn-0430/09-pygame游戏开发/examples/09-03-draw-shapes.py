"""
09-03 绘制图形与颜色
===================
这个程序演示如何在 pygame 窗口中绘制各种图形：
矩形、圆形、椭圆、线条、多边形等。

类比：窗口 = 画布，各种 draw 函数 = 不同的画笔。
"""

import pygame
import sys

pygame.init()

# --- 窗口设置 ---
WIDTH, HEIGHT = 800, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("09-03 绘制图形与颜色")
clock = pygame.time.Clock()

# --- 定义一些颜色常量 ---
# RGB 颜色模型：每颜色分量 0~255
#   R = Red(红)   G = Green(绿)   B = Blue(蓝)
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
RED = (255, 0, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)
YELLOW = (255, 255, 0)
CYAN = (0, 255, 255)
MAGENTA = (255, 0, 255)
ORANGE = (255, 165, 0)
PURPLE = (128, 0, 128)
GRAY = (128, 128, 128)

running = True
frame = 0

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
            running = False

    # --- 1. 填充背景色 ---
    # fill() 像用滚筒刷把整个画布刷成一种颜色
    screen.fill((20, 20, 40))  # 深色背景

    # --- 2. 画矩形 ---
    # pygame.draw.rect(surface, color, rect, width=0)
    #   rect 可以是 (x, y, width, height) 或 pygame.Rect 对象
    #   width=0 表示填充，width>0 表示边框粗细
    pygame.draw.rect(screen, RED, (50, 50, 150, 100))       # 填充红色矩形
    pygame.draw.rect(screen, GREEN, (250, 50, 150, 100), 5)  # 绿色边框矩形
    # 用 pygame.Rect 对象
    blue_rect = pygame.Rect(450, 50, 150, 100)
    pygame.draw.rect(screen, BLUE, blue_rect)

    # --- 3. 画圆形 ---
    # pygame.draw.circle(surface, color, center, radius, width=0)
    pygame.draw.circle(screen, YELLOW, (125, 250), 60)       # 填充黄色圆
    pygame.draw.circle(screen, CYAN, (325, 250), 60, 3)      # 青色圆环

    # --- 4. 画椭圆 ---
    # pygame.draw.ellipse(surface, color, rect, width=0)
    # 椭圆内接于指定的矩形
    pygame.draw.ellipse(screen, MAGENTA, (400, 200, 180, 100))     # 填充椭圆
    pygame.draw.ellipse(screen, ORANGE, (620, 200, 120, 80), 4)    # 边框椭圆

    # --- 5. 画线条 ---
    # pygame.draw.line(surface, color, start_pos, end_pos, width=1)
    pygame.draw.line(screen, WHITE, (50, 400), (300, 550), 3)   # 线段
    pygame.draw.line(screen, GRAY, (300, 400), (600, 400), 1)   # 水平线

    # --- 6. 画多边形 ---
    # pygame.draw.polygon(surface, color, points, width=0)
    points = [(500, 400), (600, 550), (400, 550)]
    pygame.draw.polygon(screen, PURPLE, points)     # 填充三角形
    # 五边形
    pentagon_points = [(700, 350), (750, 390), (730, 450),
                       (670, 450), (650, 390)]
    pygame.draw.polygon(screen, GREEN, pentagon_points, 3)  # 五边形边框

    # --- 7. 画弧线（圆形的一部分） ---
    # pygame.draw.arc(surface, color, rect, start_angle, end_angle, width=1)
    # 角度以弧度为单位
    import math
    arc_rect = pygame.Rect(350, 380, 100, 80)
    pygame.draw.arc(screen, YELLOW, arc_rect,
                    math.radians(0), math.radians(270), 3)

    # --- 8. 在图形旁边标注文字说明 ---
    font = pygame.font.Font(None, 24)
    label = font.render("矩形", True, WHITE)
    screen.blit(label, (90, 160))
    label2 = font.render("圆形", True, WHITE)
    screen.blit(label2, (100, 320))
    label3 = font.render("椭圆", True, WHITE)
    screen.blit(label3, (470, 310))
    label4 = font.render("三角形", True, WHITE)
    screen.blit(label4, (470, 560))

    # 更新显示
    pygame.display.flip()
    clock.tick(60)
    frame += 1

pygame.quit()
sys.exit()
