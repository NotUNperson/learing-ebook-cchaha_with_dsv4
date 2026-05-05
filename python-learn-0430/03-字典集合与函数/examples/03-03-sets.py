"""
03-03 集合（set）示例
集合就像"会自动去重的袋子"：没有顺序、元素不重复
"""

print("=" * 40)
print("1. 创建集合")
print("=" * 40)

# 方法一：直接用大括号（有元素时）
bag = {"笔", "书", "橡皮", "笔"}  # 故意放了两支"笔"
print("书包里的东西:", bag)
print("东西的数量:", len(bag))  # 3，不是 4！重复的"笔"被去掉了

# 方法二：用 set() 函数（空集合只能用这种方式）
empty_set = set()
print("空集合:", empty_set)

# 把列表转成集合 -- 自动去重
numbers = [1, 2, 2, 3, 3, 3, 4]
unique_numbers = set(numbers)
print("列表转集合（自动去重）:", unique_numbers)

print()
print("=" * 40)
print("2. 集合的增删操作")
print("=" * 40)

fruits = {"苹果", "香蕉", "橙子"}
print("初始集合:", fruits)

# add() -- 添加一个元素
fruits.add("葡萄")
print("添加葡萄后:", fruits)

# 重复添加不会改变集合
fruits.add("苹果")
print("再次添加苹果后（没有变化）:", fruits)

# remove() -- 删除元素（元素不存在会报错）
fruits.remove("香蕉")
print("删除香蕉后:", fruits)

# discard() -- 安全删除（元素不存在也不报错）
fruits.discard("西瓜")  # 西瓜不在集合里，但不报错
print("尝试删除西瓜后（无变化）:", fruits)

print()
print("=" * 40)
print("3. 集合运算 -- 交集、并集、差集")
print("=" * 40)

# 类比：两个朋友各自喜欢的菜
a_foods = {"鱼香肉丝", "宫保鸡丁", "麻婆豆腐"}
b_foods = {"宫保鸡丁", "麻婆豆腐", "糖醋里脊"}

print("A 喜欢的菜:", a_foods)
print("B 喜欢的菜:", b_foods)
print()

# 交集 &：两个人都喜欢的
print("交集（都喜欢的）:", a_foods & b_foods)

# 并集 |：所有菜去重
print("并集（全部菜品）:", a_foods | b_foods)

# 差集 -：A 喜欢但 B 不喜欢的
print("差集（只有 A 喜欢的）:", a_foods - b_foods)

# 差集反过来
print("差集（只有 B 喜欢的）:", b_foods - a_foods)

print()
print("=" * 40)
print("4. 集合的其他用法")
print("=" * 40)

# 判断元素是否在集合中 -- 比列表快得多
languages = {"Python", "Java", "C++", "Go"}
print("Python 在集合中吗?", "Python" in languages)
print("Ruby 在集合中吗?", "Ruby" in languages)

# 把一句话中的字去重
sentence = "好好学习天天向上"
unique_chars = set(sentence)
print(f"'{sentence}' 中的字（去重后）:", unique_chars)
print(f"一共有 {len(unique_chars)} 个不同的字")
