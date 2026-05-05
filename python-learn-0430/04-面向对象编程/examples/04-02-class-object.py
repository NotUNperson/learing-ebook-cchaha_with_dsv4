"""
04-02 定义类和创建对象示例
用"学生档案表"类比：类 = 表格模板，对象 = 填好的表格
"""

print("=" * 50)
print("1. 定义最简单的类")
print("=" * 50)


class Student:
    """学生类 -- 定义了学生这个概念"""
    pass  # pass 是占位符，表示"这里暂时什么都不做"


# 创建对象（也叫"实例化"） -- 就像拿出两份空白表格
s1 = Student()
s2 = Student()

print("s1 的类型:", type(s1))
print("s2 的类型:", type(s2))
print("s1 和 s2 是同一个对象吗?", s1 is s2)  # False，它们是独立的

print()
print("=" * 50)
print("2. 手动添加属性")
print("=" * 50)

# 给 s1 填写信息
s1.name = "张三"
s1.age = 15
s1.class_name = "初一(3)班"

# 给 s2 填写信息
s2.name = "李四"
s2.age = 14
s2.class_name = "初一(3)班"

# 访问属性
print(f"s1: {s1.name}, {s1.age}岁, {s1.class_name}")
print(f"s2: {s2.name}, {s2.age}岁, {s2.class_name}")

print()
print("=" * 50)
print("3. 狗的例子 -- 每只狗有自己的属性")
print("=" * 50)


class Dog:
    """狗类"""
    pass


# 创建三只不同的狗
dog1 = Dog()
dog1.name = "旺财"
dog1.breed = "金毛"
dog1.age = 3

dog2 = Dog()
dog2.name = "小黑"
dog2.breed = "泰迪"
dog2.age = 1

dog3 = Dog()
dog3.name = "阿黄"
dog3.breed = "土狗"
dog3.age = 5

# 每只狗自我介绍
print(f"我叫{dog1.name}，是{dog1.breed}，今年{dog1.age}岁")
print(f"我叫{dog2.name}，是{dog2.breed}，今年{dog2.age}岁")
print(f"我叫{dog3.name}，是{dog3.breed}，今年{dog3.age}岁")

# 修改属性
dog1.age = 4  # 旺财长大了一岁
print(f"\n{dog1.name} 过生日了，现在 {dog1.age} 岁")

print()
print("=" * 50)
print("4. 动手练习：Book 类")
print("=" * 50)


class Book:
    """书类"""
    pass


# 创建两本书
book1 = Book()
book1.title = "西游记"
book1.author = "吴承恩"
book1.price = 39.9

book2 = Book()
book2.title = "红楼梦"
book2.author = "曹雪芹"
book2.price = 49.9

# 打印信息
print(f"《{book1.title}》作者: {book1.author}，价格: {book1.price}元")
print(f"《{book2.title}》作者: {book2.author}，价格: {book2.price}元")

# 对比：用字典也能存这些信息...
book_dict1 = {"title": "西游记", "author": "吴承恩", "price": 39.9}
book_dict2 = {"title": "红楼梦", "author": "曹雪芹", "price": 49.9}
print(f"\n字典版: 《{book_dict1['title']}》作者: {book_dict1['author']}")

print("\n字典和类看起来有点相似，但类的功能远不止存数据...\n(下一节你就会看到)")
