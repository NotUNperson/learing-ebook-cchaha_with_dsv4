"""
09-04 键盘和鼠标事件
===================
这个程序演示如何用方向键移动一个矩形，用鼠标点击来改变颜色。
还会显示所有事件类型的名称。

类比：事件系统 = 游戏手柄的每个按钮都会产生"信号"。
"""

import pygame
import sys

pygame.init()

WIDTH, HEIGHT = 600, 500
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("09-04 键盘和鼠标事件 — 用方向键移动方块")
clock = pygame.time.Clock()

# --- 玩家方块 ---
player_x = WIDTH // 2 - 25   # 方块的 x 坐标（居中）
player_y = HEIGHT // 2 - 25  # 方块的 y 坐标（居中）
player_size = 50             # 方块的边长
player_speed = 5             # 每次移动的像素数
player_color = (0, 200, 100) # 方块颜色（初始绿色）

# --- 颜色列表 ---
# 按数字键 1-5 切换颜色
COLORS = [
    (0, 200, 100),   # 绿色
    (200, 100, 0),   # 橙色
    (100, 0, 200),   # 紫色
    (200, 50, 50),   # 红色
    (50, 150, 200),  # 蓝色
]
color_index = 0

# --- 字体（用来显示提示文字） ---
font = pygame.font.Font(None, 28)

running = True
while running:
    # === 事件处理 ===
    for event in pygame.event.get():
        # -- 打印事件类型（你可以看到 pygame 能捕获哪些事件） --
        # print(event)  # 取消注释可以看到所有事件的详细信息

        if event.type == pygame.QUIT:
            running = False

        elif event.type == pygame.KEYDOWN:
            # 键盘有键被按下
            if event.key == pygame.K_ESCAPE:
                running = False
            elif event.key == pygame.K_UP:
                player_y -= player_speed
            elif event.key == pygame.K_DOWN:
                player_y += player_speed
            elif event.key == pygame.K_LEFT:
                player_x -= player_speed
            elif event.key == pygame.K_RIGHT:
                player_x += player_speed
            # 按数字键切换颜色
            elif event.key == pygame.K_1:
                color_index = 0
            elif event.key == pygame.K_2:
                color_index = 1
            elif event.key == pygame.K_3:
                color_index = 2
            elif event.key == pygame.K_4:
                color_index = 3
            elif event.key == pygame.K_5:
                color_index = 4

        elif event.type == pygame.MOUSEBUTTONDOWN:
            # 鼠标按键被按下
            mouse_x, mouse_y = event.pos  # 获取鼠标点击位置
            if event.button == 1:   # 左键
                # 把方块移到鼠标位置
                player_x = mouse_x - player_size // 2
                player_y = mouse_y - player_size // 2
            elif event.button == 3:  # 右键
                # 重置到屏幕中央
                player_x = WIDTH // 2 - player_size // 2
                player_y = HEIGHT // 2 - player_size // 2

        elif event.type == pygame.MOUSEMOTION:
            # 鼠标移动 —— 这里不处理移动，但你可以检测到这个事件
            # 按住鼠标左键拖动也可以移动方块
            if event.buttons[0]:  # 如果左键是按下的状态
                mouse_x, mouse_y = event.pos
                player_x = mouse_x - player_size // 2
                player_y = mouse_y - player_size // 2

    # === 保持在窗口内（不让方块跑出画面） ===
    player_x = max(0, min(player_x, WIDTH - player_size))
    player_y = max(0, min(player_y, HEIGHT - player_size))

    # === 绘制 ===
    screen.fill((20, 20, 40))

    # 画玩家方块
    current_color = COLORS[color_index]
    player_rect = pygame.Rect(player_x, player_y, player_size, player_size)
    pygame.draw.rect(screen, current_color, player_rect)
    pygame.draw.rect(screen, (255, 255, 255), player_rect, 2)  # 白色边框

    # 画提示文字
    text1 = font.render("方向键：移动方块  |  数字键 1-5：换颜色", True,
                        (200, 200, 200))
    text2 = font.render("鼠标左键点击：方块移到点击位置", True,
                        (200, 200, 200))
    text3 = font.render("鼠标右键点击：重置方块位置", True, (200, 200, 200))
    text4 = font.render("按住左键拖动：也可以移动方块", True, (200, 200, 200))
    text5 = font.render("ESC 或 点X：退出", True, (180, 180, 180))
    screen.blit(text1, (10, 10))
    screen.blit(text2, (10, 35))
    screen.blit(text3, (10, 60))
    screen.blit(text4, (10, 85))
    screen.blit(text5, (10, 110))

    pygame.display.flip()
    clock.tick(60)

pygame.quit()
sys.exit()
