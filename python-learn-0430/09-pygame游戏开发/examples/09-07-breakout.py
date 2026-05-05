"""
09-07 综合练习：打砖块小游戏 (Breakout)
======================================
整合所学全部 pygame 知识，实现一个完整的打砖块游戏。

游戏规则：
  - 用鼠标移动底部的挡板
  - 碰到砖块的球会反弹回来
  - 碰到球的砖块会消失，得分
  - 球掉出底部 → 失去一条命
  - 消除所有砖块 → 胜利！
  - 三条命用完 → 游戏结束

操作：
  - 鼠标左右移动：控制挡板
  - 按 空格键 或鼠标左键：开始/重新发球
  - R 键：重新开始游戏
  - ESC：退出
"""

import pygame
import sys
import random

pygame.init()

# ============================================================
# 常量设置
# ============================================================
WIDTH, HEIGHT = 800, 600
FPS = 60

# 颜色
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (255, 80, 80)
GREEN = (80, 255, 80)
BLUE = (80, 80, 255)
YELLOW = (255, 255, 50)
ORANGE = (255, 180, 50)
PURPLE = (180, 50, 255)
CYAN = (50, 255, 255)
GRAY = (100, 100, 100)
BG_COLOR = (15, 15, 30)

# 砖块颜色列表（按行分配）
BRICK_COLORS = [RED, ORANGE, YELLOW, GREEN, CYAN, BLUE, PURPLE]

# 挡板
PADDLE_WIDTH = 120
PADDLE_HEIGHT = 15
PADDLE_Y = HEIGHT - 50
PADDLE_SPEED = 10

# 球
BALL_SIZE = 12
BALL_SPEED_X = 5
BALL_SPEED_Y = -5

# 砖块
BRICK_ROWS = 7
BRICK_COLS = 10
BRICK_WIDTH = 65
BRICK_HEIGHT = 22
BRICK_GAP = 5          # 砖块之间的间距
BRICK_TOP_MARGIN = 60  # 砖块区域距离顶部的距离

# 生命
MAX_LIVES = 3

# ============================================================
# 初始化游戏状态
# ============================================================
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("打砖块小游戏 — 09-07 Breakout")
clock = pygame.time.Clock()
font = pygame.font.Font(None, 36)
small_font = pygame.font.Font(None, 24)


# ============================================================
# 辅助函数
# ============================================================
def create_bricks():
    """创建所有砖块。返回一个列表，每个元素是 [Rect, color, alive]"""
    bricks = []
    # 计算砖块区域的总宽度，用于居中
    total_width = BRICK_COLS * BRICK_WIDTH + (BRICK_COLS - 1) * BRICK_GAP
    start_x = (WIDTH - total_width) // 2

    for row in range(BRICK_ROWS):
        for col in range(BRICK_COLS):
            x = start_x + col * (BRICK_WIDTH + BRICK_GAP)
            y = BRICK_TOP_MARGIN + row * (BRICK_HEIGHT + BRICK_GAP)
            rect = pygame.Rect(x, y, BRICK_WIDTH, BRICK_HEIGHT)
            color = BRICK_COLORS[row]
            bricks.append([rect, color, True])  # True = 还"活着"
    return bricks


def show_text(text, size, color, y_offset=0):
    """在屏幕中央显示文字"""
    f = pygame.font.Font(None, size)
    surface = f.render(text, True, color)
    x = WIDTH // 2 - surface.get_width() // 2
    y = HEIGHT // 2 - surface.get_height() // 2 + y_offset
    screen.blit(surface, (x, y))


# ============================================================
# 游戏主函数
# ============================================================
def main():
    # 游戏状态变量
    paddle_x = (WIDTH - PADDLE_WIDTH) // 2     # 挡板 x 坐标
    ball_x = WIDTH // 2                          # 球的 x 坐标
    ball_y = PADDLE_Y - BALL_SIZE                # 球的 y 坐标（在挡板上方）
    ball_dx = BALL_SPEED_X                       # 球水平速度
    ball_dy = BALL_SPEED_Y                       # 球垂直速度
    ball_moving = False                          # 球是否正在移动
    bricks = create_bricks()                     # 砖块列表
    lives = MAX_LIVES                            # 剩余生命
    score = 0                                    # 得分
    game_over = False                            # 游戏结束标志
    win = False                                  # 胜利标志

    running = True
    while running:
        # ========== 事件处理 ==========
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    running = False
                elif event.key == pygame.K_r:
                    # R 键：重新开始
                    main()
                    return
                elif event.key == pygame.K_SPACE and not ball_moving and not game_over:
                    # 空格键：发球
                    ball_moving = True
            elif event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1 and not ball_moving and not game_over:
                    # 鼠标左键：发球
                    ball_moving = True

        # ========== 鼠标控制挡板 ==========
        mouse_x, _ = pygame.mouse.get_pos()
        paddle_x = mouse_x - PADDLE_WIDTH // 2
        # 边界限制
        paddle_x = max(0, min(paddle_x, WIDTH - PADDLE_WIDTH))
        paddle_rect = pygame.Rect(paddle_x, PADDLE_Y,
                                  PADDLE_WIDTH, PADDLE_HEIGHT)

        # ========== 球的移动 ==========
        if ball_moving and not game_over:
            ball_x += ball_dx
            ball_y += ball_dy

            # 球碰到左右墙壁 → 反弹
            if ball_x <= 0 or ball_x >= WIDTH - BALL_SIZE:
                ball_dx = -ball_dx

            # 球碰到顶部 → 反弹
            if ball_y <= 0:
                ball_dy = -ball_dy

            # 球掉出底部 → 失去一条命
            if ball_y >= HEIGHT:
                lives -= 1
                if lives <= 0:
                    game_over = True
                else:
                    # 重置球的位置
                    ball_moving = False
                    ball_x = paddle_x + PADDLE_WIDTH // 2 - BALL_SIZE // 2
                    ball_y = PADDLE_Y - BALL_SIZE

            # 球碰到挡板 → 反弹
            ball_rect = pygame.Rect(ball_x, ball_y, BALL_SIZE, BALL_SIZE)
            if ball_rect.colliderect(paddle_rect):
                # 反弹，并根据碰撞位置改变角度（让玩家有控制感）
                # 碰到挡板左侧：球往左弹；碰到右侧：球往右弹
                offset = (ball_x + BALL_SIZE / 2) - (paddle_x + PADDLE_WIDTH / 2)
                # offset 范围约 -60 ~ +60，除以 30 使其不超过 2
                ball_dx = offset / 30 * abs(BALL_SPEED_X)
                ball_dx = max(-8, min(ball_dx, 8))  # 限制水平速度
                ball_dy = -abs(ball_dy)  # 确保向上弹
                ball_y = PADDLE_Y - BALL_SIZE  # 防止球卡在挡板里

            # 球碰到砖块 → 砖块消失、球反弹、加分
            for brick in bricks:
                rect, color, alive = brick
                if alive and ball_rect.colliderect(rect):
                    brick[2] = False  # 砖块"死亡"
                    score += 10
                    # 简单的反弹逻辑：判断球从哪个方向撞到砖块
                    # 比较球中心和砖块中心的差异来判断撞击方向
                    ball_center_x = ball_x + BALL_SIZE / 2
                    ball_center_y = ball_y + BALL_SIZE / 2
                    brick_center_x = rect.x + BRICK_WIDTH / 2
                    brick_center_y = rect.y + BRICK_HEIGHT / 2

                    dx = ball_center_x - brick_center_x
                    dy = ball_center_y - brick_center_y

                    # 宽高比决定了是水平还是垂直碰撞
                    if abs(dx) * (BRICK_HEIGHT / 2) > abs(dy) * (BRICK_WIDTH / 2):
                        ball_dx = -ball_dx  # 水平反弹
                    else:
                        ball_dy = -ball_dy  # 垂直反弹

                    break  # 一帧只处理一个碰撞（防止连续碰撞多个砖块）

            # 检查是否胜利（所有砖块都消除了）
            if all(not alive for _, _, alive in bricks):
                win = True
                ball_moving = False
                game_over = True

        # ========== 绘制 ==========
        screen.fill(BG_COLOR)

        # 画砖块
        for rect, color, alive in bricks:
            if alive:
                pygame.draw.rect(screen, color, rect)
                pygame.draw.rect(screen, WHITE, rect, 1)  # 白色边框

        # 画挡板
        pygame.draw.rect(screen, WHITE, paddle_rect)
        pygame.draw.rect(screen, GRAY, paddle_rect, 2)

        # 画球
        ball_rect = pygame.Rect(ball_x, ball_y, BALL_SIZE, BALL_SIZE)
        pygame.draw.ellipse(screen, WHITE, ball_rect)

        # 显示信息
        score_text = font.render(f"得分：{score}", True, WHITE)
        lives_text = font.render(f"生命：{'♥ ' * lives}", True, RED)
        screen.blit(score_text, (10, 10))
        screen.blit(lives_text, (WIDTH - 200, 10))

        # 游戏状态提示
        if not ball_moving and not game_over:
            show_text("按 空格键 或 鼠标左键 发球", 28, WHITE, 180)
        if game_over:
            if win:
                show_text(f"恭喜通关！ 得分：{score}", 48, GREEN, -40)
            else:
                show_text(f"游戏结束 得分：{score}", 48, RED, -40)
            show_text("按 R 键重新开始 | 按 ESC 退出", 28, GRAY, 40)

        pygame.display.flip()
        clock.tick(FPS)

    pygame.quit()
    sys.exit()


# 启动游戏
if __name__ == "__main__":
    main()
