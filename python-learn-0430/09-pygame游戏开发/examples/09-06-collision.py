"""
09-06 碰撞检测
=============
这个程序演示 pygame 中的碰撞检测：
玩家方块 vs 多个目标方块，检测到碰撞时目标会变色。

类比：碰撞检测 = 碰碰车相撞时的"碰碰"感应器
      两个矩形重叠了 → 就发生了碰撞
"""

import pygame
import sys
import random

pygame.init()

WIDTH, HEIGHT = 800, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("09-06 碰撞检测 — 吃掉所有方块！")
clock = pygame.time.Clock()

# --- 玩家 ---
player_size = 50
player_x = WIDTH // 2 - player_size // 2
player_y = HEIGHT // 2 - player_size // 2
player_speed = 6
player_color = (50, 200, 150)       # 正常颜色
player_hit_color = (255, 100, 100)  # 碰撞时的颜色（红色闪一下）

# --- 目标方块 ---
TARGET_COUNT = 8   # 目标方块的数量
target_size = 40
targets = []  # 存储所有目标方块的信息

def create_target():
    """创建一个随机位置的目标方块"""
    x = random.randint(0, WIDTH - target_size)
    y = random.randint(50, HEIGHT - target_size)  # 避开顶部文字区域
    return {
        "rect": pygame.Rect(x, y, target_size, target_size),
        "color": (random.randint(100, 255),
                  random.randint(100, 255),
                  random.randint(100, 255)),
        "alive": True  # 还没有被"吃掉"
    }

# 初始化目标方块
for _ in range(TARGET_COUNT):
    targets.append(create_target())

score = 0
font = pygame.font.Font(None, 36)

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
            running = False

    # === 键盘移动 ===
    keys = pygame.key.get_pressed()
    if keys[pygame.K_LEFT] or keys[pygame.K_a]:
        player_x -= player_speed
    if keys[pygame.K_RIGHT] or keys[pygame.K_d]:
        player_x += player_speed
    if keys[pygame.K_UP] or keys[pygame.K_w]:
        player_y -= player_speed
    if keys[pygame.K_DOWN] or keys[pygame.K_s]:
        player_y += player_speed

    # 边界限制
    player_x = max(0, min(player_x, WIDTH - player_size))
    player_y = max(0, min(player_y, HEIGHT - player_size))

    # === 碰撞检测 ===
    player_rect = pygame.Rect(player_x, player_y, player_size, player_size)

    # 当前帧是否发生了碰撞（用来改变玩家颜色）
    collided_this_frame = False

    for target in targets:
        if target["alive"]:
            # --- 核心：colliderect() 检测两个矩形是否重叠 ---
            # 如果 player_rect 和 target["rect"] 有重叠，返回 True
            if player_rect.colliderect(target["rect"]):
                target["alive"] = False  # 标记为"被吃掉"
                score += 10
                collided_this_frame = True

    # --- 如果没有"活着的"目标了，全部重生 ---
    alive_count = sum(1 for t in targets if t["alive"])
    if alive_count == 0:
        targets = [create_target() for _ in range(TARGET_COUNT)]
        player_speed += 1  # 每轮提速

    # === 绘制 ===
    screen.fill((20, 20, 40))

    # 画目标方块
    for target in targets:
        if target["alive"]:
            pygame.draw.rect(screen, target["color"], target["rect"])
            pygame.draw.rect(screen, (255, 255, 255), target["rect"], 2)

    # 画玩家方块（碰撞时闪烁红色）
    current_color = player_hit_color if collided_this_frame else player_color
    pygame.draw.rect(screen, current_color, player_rect)
    pygame.draw.rect(screen, (255, 255, 255), player_rect, 3)

    # 显示分数和提示
    score_text = font.render(f"得分：{score}  剩余目标：{alive_count}", True,
                             (255, 255, 255))
    screen.blit(score_text, (10, 10))
    tip = font.render("用方向键移动绿色方块去'吃'彩色方块！", True,
                      (200, 200, 200))
    screen.blit(tip, (10, HEIGHT - 35))

    pygame.display.flip()
    clock.tick(60)

print(f"最终得分：{score}")
pygame.quit()
sys.exit()
