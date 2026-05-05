"""
04-03 __init__ 构造方法示例
用"新生儿出生登记"类比：对象创建时自动执行 __init__
"""

print("=" * 50)
print("1. 没有 __init__ 的麻烦")
print("=" * 50)


class StudentOld:
    """没有 __init__ 的类：创建对象后要手动一个个赋值"""
    pass


# 每创建一个对象，都要手动写好几行
s = StudentOld()
s.name = "张三"
s.age = 15
s.class_name = "初一(3)班"
print(f"手动赋值: {s.name}, {s.age}岁")

print()
print("=" * 50)
print("2. 有 __init__ 的便捷")
print("=" * 50)


class Student:
    """
    学生类 -- 用 __init__ 在创建时自动初始化属性
    就像新生儿出生时医院自动登记信息
    """

    def __init__(self, name, age, class_name):
        """
        __init__ 会在 Student() 创建对象时自动调用
        self: 代表"正在被创建的这个对象自己"
        name, age, class_name: 创建时传入的参数
        """
        self.name = name
        self.age = age
        self.class_name = class_name
        print(f"  [系统] {name} 的信息已登记！")


# 创建对象 -- 一行就搞定！
s1 = Student("张三", 15, "初一(3)班")
s2 = Student("李四", 14, "初一(2)班")
s3 = Student("王五", 15, "初一(3)班")

# 访问属性
print(f"\ns1: {s1.name}, {s1.age}岁, {s1.class_name}")
print(f"s2: {s2.name}, {s2.age}岁, {s2.class_name}")
print(f"s3: {s3.name}, {s3.age}岁, {s3.class_name}")

print()
print("=" * 50)
print("3. self 的含义 -- '我自己'的")
print("=" * 50)

# 把 self 想象成每个人说"我"
# 张三说"我" = 张三自己
# 李四说"我" = 李四自己
print(f"s1.name 就是问 s1: 你的 name 是什么? -> {s1.name}")
print(f"s2.name 就是问 s2: 你的 name 是什么? -> {s2.name}")
print("它们不同，因为 self 在不同对象里代表不同的对象")

print()
print("=" * 50)
print("4. __init__ 中参数的默认值")
print("=" * 50)


class Phone:
    """手机类"""

    def __init__(self, brand, model, price=999):
        """
        brand 和 model 必须传
        price 有默认值 999
        """
        self.brand = brand
        self.model = model
        self.price = price

    def show_info(self):
        """显示手机信息"""
        print(f"  {self.brand} {self.model} - {self.price}元")


# 传了 price 的就用传的
p1 = Phone("Apple", "iPhone 15", 5999)
# 不传 price 的就用默认值
p2 = Phone("Xiaomi", "Redmi Note 12")

p1.show_info()
p2.show_info()

print()
print("=" * 50)
print("5. 动手练习：Book 类用 __init__")
print("=" * 50)


class Book:
    """书类 -- 用 __init__ 初始化"""

    def __init__(self, title, author, price=29.9):
        self.title = title
        self.author = author
        self.price = price


books = [
    Book("西游记", "吴承恩", 39.9),
    Book("红楼梦", "曹雪芹"),
    Book("三国演义", "罗贯中", 35.0),
]

print("我的书架:")
for book in books:
    print(f"  《{book.title}》 {book.author} 著, {book.price}元")
