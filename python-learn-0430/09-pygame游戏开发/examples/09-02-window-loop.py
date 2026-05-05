"""
09-02 游戏窗口与主循环
=====================
这个程序演示 pygame 最核心的概念：
    窗口 = 舞台
    主循环 = 持续进行的演出

运行后会看到一个窗口，按窗口右上角的 X 按钮可以关闭。
"""

import pygame
import sys  # sys 用于退出程序

# === 1. 初始化 pygame ===
pygame.init()

# === 2. 创建窗口（舞台） ===
# set_mode() 的参数是一个元组：(宽度, 高度)
# 这里创建一个 800x600 的窗口
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600
screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))

# 设置窗口标题 —— 就像给舞台挂上横幅
pygame.display.set_caption("09-02 游戏窗口与主循环")

# === 3. 创建时钟对象 —— 控制游戏运行的速度（帧率） ===
clock = pygame.time.Clock()
FPS = 60  # 每秒 60 帧，游戏画面每秒刷新 60 次

# === 4. 游戏主循环 ===
# 主循环 = 一场演出的无限循环：
#   观众离场（点击 X）→ 演出结束
#   否则 → 不断更新画面
running = True  # 标记"演出是否还在进行"
frame_count = 0  # 计数器，用来在窗口标题上显示帧数

while running:
    # --- 4a. 事件处理（处理观众的动作） ---
    # pygame.event.get() 获取这段时间发生的所有"事件"
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            # 玩家点击了窗口的 X 按钮
            # QUIT 事件 = "观众要离场了"
            running = False
        elif event.type == pygame.KEYDOWN:
            # 玩家按下了键盘
            if event.key == pygame.K_ESCAPE:
                # 按 ESC 键也可以退出
                running = False

    # --- 4b. 更新游戏状态 ---
    # 这里暂时没有需要更新的游戏逻辑
    frame_count += 1

    # --- 4c. 绘制画面 ---
    # 用颜色填充整个窗口背景（RGB 颜色）
    screen.fill((30, 30, 50))  # 深蓝紫色背景

    # 在标题栏显示帧数（方便看到主循环确实在运行）
    if frame_count % 60 == 0:  # 每秒更新一次标题
        pygame.display.set_caption(
            f"09-02 游戏窗口与主循环 - 已运行 {frame_count} 帧"
        )

    # 把绘制的内容显示到屏幕上
    pygame.display.flip()

    # --- 4d. 控制帧率 ---
    # tick(FPS) 的意思是：确保每秒钟不超过 FPS 帧
    # 如果机器很快，这里会等待一会；如果很慢，会尽量追赶
    clock.tick(FPS)

# === 5. 循环结束，退出游戏 ===
print(f"游戏主循环结束。总共运行了 {frame_count} 帧。")
print(f"大约运行了 {frame_count / FPS:.1f} 秒。")
pygame.quit()
sys.exit()
