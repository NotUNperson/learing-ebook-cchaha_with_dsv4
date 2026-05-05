"""
04-04 实例方法示例
用"遥控器的按钮"类比：属性 = 电视的当前状态，方法 = 遥控器上的按钮
"""

print("=" * 50)
print("1. 电视遥控器的例子")
print("=" * 50)


class TV:
    """电视类 -- 属性是状态，方法是操作"""

    def __init__(self, brand="小米"):
        self.brand = brand
        self.is_on = False       # 是否开机
        self.channel = 1         # 当前频道
        self.volume = 10         # 当前音量 (0-100)

    def power(self):
        """开关机"""
        self.is_on = not self.is_on
        state = "开" if self.is_on else "关"
        print(f"{self.brand} 电视已{state}机")

    def change_channel(self, channel):
        """换台"""
        if self.is_on:
            self.channel = channel
            print(f"切换到第 {self.channel} 频道")
        else:
            print("电视没开机，不能换台！")

    def volume_up(self):
        """音量加"""
        if self.is_on and self.volume < 100:
            self.volume += 1
            print(f"音量: {self.volume}")

    def volume_down(self):
        """音量减"""
        if self.is_on and self.volume > 0:
            self.volume -= 1
            print(f"音量: {self.volume}")

    def show_status(self):
        """显示当前状态"""
        state = "开机" if self.is_on else "关机"
        print(f"[{self.brand}] {state} | 频道: {self.channel} | 音量: {self.volume}")


# 创建电视并操作
tv = TV("海信")
tv.show_status()       # 初始状态：关机
tv.power()             # 开机
tv.change_channel(5)   # 换到第 5 频道
tv.volume_up()         # 音量+1
tv.volume_up()         # 音量+1
tv.show_status()       # 查看当前状态

print()
print("=" * 50)
print("2. 狗的例子 -- 方法中调用其他方法")
print("=" * 50)


class Dog:
    """狗类"""

    def __init__(self, name):
        self.name = name
        self.hunger = 5  # 饥饿度 0~10，越大越饿
        self.energy = 5  # 精力值 0~10

    def bark(self):
        """叫"""
        print(f"  {self.name}: 汪汪！")

    def eat(self):
        """吃东西"""
        if self.hunger > 0:
            self.hunger -= 1
            print(f"  {self.name} 吃了一口 (饥饿度: {self.hunger})")
        else:
            print(f"  {self.name} 已经饱了")

    def run(self):
        """跑 -- 消耗精力，增加饥饿度"""
        if self.energy > 0:
            self.energy -= 1
            self.hunger += 1
            print(f"  {self.name} 跑了一圈 (精力: {self.energy}, 饥饿: {self.hunger})")
        else:
            print(f"  {self.name} 太累了，跑不动")

    def status(self):
        """汇报状态"""
        print(f"  [{self.name}] 饥饿度={self.hunger} 精力值={self.energy}")
        if self.hunger > 7:
            self.bark()  # 太饿了就叫 -- 方法里调用自己的另一个方法


# 旺财的一天
print("旺财的一天:")
dog = Dog("旺财")
dog.status()
dog.run()
dog.run()
dog.status()
dog.eat()
dog.eat()
dog.status()

print()
print("=" * 50)
print("3. 证明：多个对象的数据互不影响")
print("=" * 50)


class Counter:
    """计数器类"""

    def __init__(self, name):
        self.name = name
        self.count = 0

    def add_one(self):
        """加 1"""
        self.count += 1
        print(f"  [{self.name}] count = {self.count}")

    def reset(self):
        """归零"""
        self.count = 0
        print(f"  [{self.name}] 已归零")

    def get_count(self):
        """获取当前计数"""
        return self.count


# 两个独立的计数器
c1 = Counter("一号计数器")
c2 = Counter("二号计数器")

print("操作一号:")
c1.add_one()
c1.add_one()
c1.add_one()

print("操作二号:")
c2.add_one()

print(f"\n最终: 一号={c1.get_count()}, 二号={c2.get_count()}")
print("看，两个计数器互不影响！因为它们的 self 指向不同的对象")
