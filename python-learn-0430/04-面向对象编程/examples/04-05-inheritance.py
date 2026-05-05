"""
04-05 继承示例
用"继承家业"类比：子类自动拥有父类的属性和方法
"""

print("=" * 50)
print("1. 最简单的继承 -- 子类继承父类所有方法")
print("=" * 50)


class Restaurant:
    """父类：老爸的餐馆"""

    def __init__(self, name):
        self.name = name

    def describe(self):
        print(f"餐馆名称: {self.name}")

    def open(self):
        print(f"{self.name} 开门营业了！")


class FastFood(Restaurant):
    """
    子类：儿子的快餐店
    括号里写 Restaurant 表示继承 Restaurant
    pass 表示暂时不添加任何新东西
    """
    pass


# 创建子类对象 -- 子类自动拥有父类的所有方法
kfc = FastFood("肯德基")
kfc.describe()   # 继承自父类
kfc.open()       # 继承自父类
print(f"kfc 是 Restaurant 的子类吗?", issubclass(FastFood, Restaurant))
print(f"kfc 是 FastFood 的实例吗?", isinstance(kfc, FastFood))
print(f"kfc 是 Restaurant 的实例吗?", isinstance(kfc, Restaurant))

print()
print("=" * 50)
print("2. 子类添加自己的属性和方法")
print("=" * 50)


class FastFoodV2(Restaurant):
    """子类：继承父类 + 添加新功能"""

    def __init__(self, name, style):
        # super() 表示"调用父类（老爸）的 __init__"
        super().__init__(name)  # 让父类处理 name
        self.style = style      # 子类新增的属性

    def deliver(self):
        """子类新增的方法 -- 外卖服务"""
        print(f"{self.name} 提供{self.style}外卖服务")


mcd = FastFoodV2("麦当劳", "30分钟")
mcd.describe()   # 继承的方法
mcd.open()       # 继承的方法
mcd.deliver()    # 子类自己的方法
print(f"风格: {mcd.style}")  # 子类自己的属性

print()
print("=" * 50)
print("3. 方法重写 -- 儿子有自己的做法")
print("=" * 50)


class FastFoodV3(Restaurant):
    """子类：重写父类的方法"""

    def __init__(self, name, style):
        super().__init__(name)
        self.style = style

    # 重写 describe -- 用子类自己的版本替代父类的版本
    def describe(self):
        """子类版本的自我介绍"""
        print(f"{self.name} ({self.style}) -- 欢迎光临！")

    def open(self):
        """先做父类的开张，再做子类特有的准备"""
        super().open()  # 调用父类的 open
        print("  -> 外卖平台已上线，开始接单！")


burger_king = FastFoodV3("汉堡王", "火烤汉堡")
burger_king.describe()
burger_king.open()

print()
print("=" * 50)
print("4. 动手练习：动物类继承")
print("=" * 50)


class Animal:
    """父类：动物"""

    def __init__(self, name):
        self.name = name

    def speak(self):
        """父类的叫法 -- 通用的"""
        print(f"{self.name}: 动物在叫")

    def sleep(self):
        print(f"{self.name}: zzz...（睡着了）")


class Cat(Animal):
    """子类：猫"""

    def speak(self):
        """猫的叫声 -- 重写父类的 speak"""
        print(f"{self.name}: 喵喵喵~")


class Dog(Animal):
    """子类：狗"""

    def speak(self):
        """狗的叫声 -- 重写父类的 speak"""
        print(f"{self.name}: 汪汪汪！")


# 多态：不同类型的对象，调用相同的方法，产生不同的行为
animals = [
    Cat("小花"),
    Dog("旺财"),
    Cat("咪咪"),
    Dog("阿黄"),
    Animal("某未知生物"),
]

print("动物们在叫:")
for animal in animals:
    animal.speak()  # 同样的 speak()，不同的动物叫法不同

print("\n动物们在睡觉:")
for animal in animals:
    animal.sleep()  # sleep 没有被重写，全都用父类的版本
