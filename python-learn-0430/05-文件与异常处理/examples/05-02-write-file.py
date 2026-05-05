"""
05-02 写入文件示例
用"笔记本写字"类比：'w' 清空重写，'a' 接着往后写
"""

print("=" * 40)
print("1. 'w' 模式：覆盖写入（清空旧内容重写）")
print("=" * 40)

write_file = "sample_write.txt"

# 第一次写入
file = open(write_file, "w", encoding="utf-8")
file.write("这是第一段内容\n")
file.write("Hello Python!\n")
file.close()
print(f"第一次写入 '{write_file}' 完成")

# 读取看看
file = open(write_file, "r", encoding="utf-8")
print("当前文件内容:")
print(file.read())
file.close()

# 第二次用 'w' 写入 -- 会清空之前的内容！
print("\n第二次用 'w' 模式写入（旧内容会被清空）...")
file = open(write_file, "w", encoding="utf-8")
file.write("全新的内容！旧内容消失了\n")
file.close()

file = open(write_file, "r", encoding="utf-8")
print("清空后的文件内容:")
print(file.read())
file.close()

print()
print("=" * 40)
print("2. 'a' 模式：追加写入（保留旧内容，末尾接着写）")
print("=" * 40)

append_file = "sample_append.txt"

# 先清空（确保从头演示）
file = open(append_file, "w", encoding="utf-8")
file.write("")
file.close()

# 第一次追加
file = open(append_file, "a", encoding="utf-8")
file.write("2024年1月1日 晴\n")
file.write("今天开学了，很开心！\n")
file.close()

# 第二次追加
file = open(append_file, "a", encoding="utf-8")
file.write("2024年1月2日 阴\n")
file.write("学习了 Python 文件操作。\n")
file.close()

# 第三次追加
file = open(append_file, "a", encoding="utf-8")
file.write("2024年1月3日 雨\n")
file.write("今天下雨，在家写代码。\n")
file.close()

print(f"已向 '{append_file}' 追加多篇日记")
file = open(append_file, "r", encoding="utf-8")
print("当前文件完整内容:")
print(file.read())
file.close()

print()
print("=" * 40)
print("3. write() vs writelines()")
print("=" * 40)

# write() 一次写一个字符串
file = open("fruits_demo.txt", "w", encoding="utf-8")
file.write("苹果\n")
file.write("香蕉\n")
file.close()

# writelines() 一次写一个列表的所有元素
more_fruits = ["橙子\n", "葡萄\n", "西瓜\n", "草莓\n"]
file = open("fruits_demo.txt", "a", encoding="utf-8")
file.writelines(more_fruits)
file.close()

print("水果列表文件内容:")
file = open("fruits_demo.txt", "r", encoding="utf-8")
print(file.read())
file.close()

print()
print("=" * 40)
print("4. 动手练习：写日记")
print("=" * 40)

# 模拟写日记的过程
diary_file = "my_diary.txt"

# 第一天的日记（用 'w' 创建新日记本）
file = open(diary_file, "w", encoding="utf-8")
file.write("===== 我的日记本 =====\n\n")
file.write("4月28日: 开始学 Python 文件操作\n")
file.close()

# 第二天的日记（用 'a' 追加）
file = open(diary_file, "a", encoding="utf-8")
file.write("4月29日: 学会了读文件和写文件\n")
file.close()

# 今天的日记
file = open(diary_file, "a", encoding="utf-8")
file.write("4月30日: 在写综合练习，加油！\n")
file.close()

print(f"日记已保存到 '{diary_file}':")
file = open(diary_file, "r", encoding="utf-8")
for line in file:
    print(f"  {line}", end="")
file.close()
