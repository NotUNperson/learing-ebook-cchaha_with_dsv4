# 09-05 图片与精灵 (Sprites)

## 本节你会学到什么
- 学会加载和显示外部图片
- 理解精灵(Sprite)的概念和作用
- 学会创建精灵类和精灵组
- 用精灵系统统一管理多个游戏角色

## 正文
### 为什么需要图片 —— 用图形太单调了

到目前为止，我们一直在用 `draw.rect()` 和 `draw.circle()` 画几何图形。这就像用尺子和圆规画画——虽然能画，但离真正的"美术"还差很远。

真实的游戏里，角色有精美的图片：主角是一个拿着剑的勇士，敌人是一条喷火的龙，背景是茂密的森林。这些图片一般都是 PNG 格式（支持透明背景），由美术设计师画好之后，程序员用代码加载到游戏里。

pygame 加载图片非常简单：

```python
# 加载图片
image = pygame.image.load("player.png").convert_alpha()
# convert_alpha() 保留图片的透明通道（PNG 的透明背景不会变成白色）

# 把图片画到窗口上
screen.blit(image, (x, y))  # (x, y) 是图片左上角的坐标
```

`blit` 这个词有点奇怪，它的意思是"把一张图拷贝到另一张图上"。你可以理解为"把角色贴纸贴到画布上"。

### 精灵是什么 —— 木偶戏里的角色

当你游戏里只有一两个角色时，手动管理每个角色的图片、位置、速度还可以应付。但想象一个有 50 个敌人、100 颗子弹、20 个道具的游戏——如果你给每个角色都单独写一套位置更新、绘制、碰撞检测的代码，那会是一场噩梦。

pygame 提供了一个解决方案：**精灵（Sprite）**。

精灵这个词来自早期的电子游戏——画面中的角色（主角、敌人、子弹）被称为"精灵"。在 pygame 中，`Sprite` 是一个类，它把角色的**外观（图片）**和**位置（矩形框）**打包在一起。

你可以把精灵想象成木偶戏里的一个木偶：
- 每个木偶有自己的**造型**（`self.image`，角色的图片）
- 每个木偶有自己的**位置和大小**（`self.rect`，碰撞检测框）
- 每个木偶有自己的**动作**（`update()` 方法，每帧做什么）

### 创建精灵类

```python
class Player(pygame.sprite.Sprite):
    def __init__(self, x, y, image):
        super().__init__()          # 必须调用父类的 __init__
        self.image = image          # 精灵的外观
        self.rect = self.image.get_rect()  # 精灵的位置和大小
        self.rect.x = x
        self.rect.y = y
        self.speed = 5

    def update(self):
        """每帧调用一次"""
        keys = pygame.key.get_pressed()
        if keys[pygame.K_LEFT]:
            self.rect.x -= self.speed
        # ... 其他方向的移动
```

关键点：
- `self.image`：一个 `Surface` 对象（可以理解为"一张图"），是精灵显示出来的样子。
- `self.rect`：一个 `pygame.Rect` 对象，决定了精灵的**位置**和**碰撞区域**。`self.rect.x` 和 `self.rect.y` 是左上角坐标。
- `update()`：你会在这个方法里写精灵的行为逻辑（移动、动画切换等）。每帧调用一次。

### 精灵组 —— 剧团的"大管家"

当你有很多精灵时，一个一个调用 `update()` 和 `blit()` 太麻烦了。精灵组（`sprite.Group`）就像一个剧团的"大管家"：

```python
# 创建精灵组
all_sprites = pygame.sprite.Group()

# 添加精灵到组里
player = Player(100, 100, image)
all_sprites.add(player)

# 在主循环中，一行搞定所有精灵的更新和绘制：
all_sprites.update()   # 调用组内所有精灵的 update() 方法
all_sprites.draw(screen)  # 把组内所有精灵画到屏幕上
```

精灵组的 `draw()` 方法会自动使用每个精灵的 `self.image` 和 `self.rect` 来完成绘制，你完全不需要手动写 `screen.blit()`。

### 如果没有图片怎么办

`examples/09-05-sprites.py` 示例程序会先尝试加载 `player.png`，如果找不到这个文件，会自动用代码"画"一个占位角色（蓝色方块 + 黄色脸 + 眼睛和嘴巴）。所以即使你手头没有图片文件，也能正常看到效果。

## 动手试试
1. 运行 `examples/09-05-sprites.py`，用 W/A/S/D 或方向键移动角色。
2. 找一张你自己的图片（PNG 或 JPG），改名为 `player.png` 放在同一目录下，再次运行，看看你自己的图片出现在窗口里。
3. 尝试创建两个不同的精灵（比如一个"玩家"和一个"追随者"），把它们都加到精灵组里。
4. 给精灵添加一个"按空格键变色"的功能。

## 本节小结
精灵 = 把图片、位置、行为打包成一个对象；精灵组 = 统一管理一群精灵的大管家。大量角色用精灵系统管理会优雅很多。

## 下一节预告
角色会动了，但它们碰在一起会怎么样？下一节学习碰撞检测——游戏物理的基础。
