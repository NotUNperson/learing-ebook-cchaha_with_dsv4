"""
09-05 图片与精灵 (Sprites)
==========================
这个程序演示如何加载图片、使用精灵类来管理游戏角色。

类比：精灵(sprite) = 木偶戏里的角色
      每个角色有自己的"造型"(图片)和"动作"(update/移动)

注意：运行前请先准备一张名为 player.png 的图片放在同目录下，
      如果没有，程序会用绘制的矩形代替。
"""

import pygame
import sys
import os

pygame.init()

WIDTH, HEIGHT = 800, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("09-05 图片与精灵 (Sprites)")
clock = pygame.time.Clock()

# --- 首先，准备一张"玩家图片" ---
# 尝试加载外部图片文件
image_path = "player.png"
player_image = None  # 先设为 None
image_loaded = False

if os.path.exists(image_path):
    # 如果图片文件存在，加载它
    original_image = pygame.image.load(image_path).convert_alpha()
    # 缩放到 60x60
    player_image = pygame.transform.scale(original_image, (60, 60))
    image_loaded = True
    print(f"成功加载图片：{image_path}")
else:
    # 如果图片不存在，创建一个简易的"占位图片"（蓝色方块 + 笑脸圆圈）
    player_image = pygame.Surface((60, 60), pygame.SRCALPHA)
    # 画一个蓝色方块
    pygame.draw.rect(player_image, (50, 100, 200), (0, 0, 60, 60))
    # 画一个黄色圆形当"脸"
    pygame.draw.circle(player_image, (255, 255, 0), (30, 30), 20)
    # 画两个圆点当"眼睛"
    pygame.draw.circle(player_image, (0, 0, 0), (23, 25), 3)
    pygame.draw.circle(player_image, (0, 0, 0), (37, 25), 3)
    # 画弧线当"嘴巴"
    import math
    pygame.draw.arc(player_image, (0, 0, 0), (15, 20, 30, 20),
                    math.radians(0), math.radians(180), 2)
    print("未找到 player.png，使用绘制的占位图片。")


# ============================================================
# 定义精灵类
# ============================================================
class Player(pygame.sprite.Sprite):
    """
    玩家精灵类。
    继承自 pygame.sprite.Sprite，获得精灵的所有"超能力"：
    - 可以用精灵组管理
    - 可以自动检测碰撞
    - 可以统一调用 update() 和 draw()
    """

    def __init__(self, x, y, image):
        # 调用父类的初始化方法（重要！）
        super().__init__()

        # self.image 是精灵的外观（玩家看到的样子）
        self.image = image
        # self.rect 是精灵的"碰撞框"（决定位置和碰撞检测的区域）
        self.rect = self.image.get_rect()
        # 设置初始位置
        self.rect.x = x
        self.rect.y = y
        # 移动速度
        self.speed = 5

    def update(self):
        """
        每帧调用一次，更新精灵的状态。
        这里检测键盘输入并移动。
        """
        keys = pygame.key.get_pressed()  # 获取当前所有按键的状态

        if keys[pygame.K_LEFT] or keys[pygame.K_a]:
            self.rect.x -= self.speed
        if keys[pygame.K_RIGHT] or keys[pygame.K_d]:
            self.rect.x += self.speed
        if keys[pygame.K_UP] or keys[pygame.K_w]:
            self.rect.y -= self.speed
        if keys[pygame.K_DOWN] or keys[pygame.K_s]:
            self.rect.y += self.speed

        # 不让精灵跑出窗口
        if self.rect.left < 0:
            self.rect.left = 0
        if self.rect.right > WIDTH:
            self.rect.right = WIDTH
        if self.rect.top < 0:
            self.rect.top = 0
        if self.rect.bottom > HEIGHT:
            self.rect.bottom = HEIGHT


# ============================================================
# 创建精灵对象
# ============================================================
# 创建玩家精灵
player = Player(WIDTH // 2, HEIGHT // 2, player_image)

# 把所有精灵放进一个"精灵组"
# 精灵组就像一个剧团，可以统一管理所有演员
all_sprites = pygame.sprite.Group()
all_sprites.add(player)

# ============================================================
# 游戏主循环
# ============================================================
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
            running = False

    # --- 更新 ---
    # 调用精灵组中每个精灵的 update() 方法
    all_sprites.update()

    # --- 绘制 ---
    screen.fill((30, 30, 50))

    # 把精灵组中所有精灵画到屏幕上
    all_sprites.draw(screen)

    # 显示提示
    font = pygame.font.Font(None, 28)
    if image_loaded:
        tip = "使用方向键或 WASD 移动角色（已加载外部图片）"
    else:
        tip = "使用方向键或 WASD 移动角色（使用占位图片）"
    text = font.render(tip, True, (200, 200, 200))
    screen.blit(text, (10, 10))
    text2 = font.render("当前精灵位置：({}, {})".format(
        player.rect.x, player.rect.y), True, (200, 200, 200))
    screen.blit(text2, (10, 40))

    pygame.display.flip()
    clock.tick(60)

pygame.quit()
sys.exit()
