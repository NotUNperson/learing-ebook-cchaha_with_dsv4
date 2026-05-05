"""
09-01 pygame 入门：认识 pygame 并验证安装
==============================================
pygame 是一套专门用来做 2D 游戏和多媒体程序的 Python 库。
这个程序用来验证你的 pygame 是否安装成功，并演示最基本的结构。
"""

import pygame  # 导入 pygame 库

# 1. 初始化 pygame —— 就像打开工具箱，把所有工具准备好
pygame.init()
print("pygame 初始化成功！")

# 2. 查看 pygame 版本 —— 确认安装的是哪个版本
print(f"pygame 版本：{pygame.version.ver}")

# 3. 检查 pygame 支持哪些功能模块
# pygame 包含很多子模块，每个模块负责不同的功能
modules = [
    ("display", "窗口和屏幕显示"),
    ("draw", "绘制图形（矩形、圆形、线条等）"),
    ("event", "事件处理（键盘、鼠标、窗口关闭等）"),
    ("image", "加载和保存图片"),
    ("font", "文字渲染"),
    ("mixer", "声音和音乐播放"),
    ("sprite", "精灵和碰撞检测"),
    ("time", "时钟和帧率控制"),
    ("key", "键盘按键常量"),
    ("mouse", "鼠标相关功能"),
]

print("\npygame 主要功能模块：")
for name, desc in modules:
    try:
        # 尝试导入子模块来检查是否可用
        __import__(f"pygame.{name}")
        status = "可用"
    except ImportError:
        status = "不可用"
    print(f"  pygame.{name:<10} — {desc:<20} [{status}]")

# 4. 试试创建一个窗口（立即关闭，只是为了验证功能）
print("\n正在尝试创建测试窗口...")
try:
    # 创建一个 400x300 的窗口
    screen = pygame.display.set_mode((400, 300))
    # 设置窗口标题
    pygame.display.set_caption("pygame 安装验证 - Hello pygame!")
    print("窗口创建成功！")
    # 显示 2 秒后关闭
    pygame.time.wait(2000)
except Exception as e:
    print(f"窗口创建失败：{e}")

# 5. 退出 pygame —— 用完工具后收拾干净
pygame.quit()
print("\npygame 退出成功。一切正常，可以开始学习啦！")
