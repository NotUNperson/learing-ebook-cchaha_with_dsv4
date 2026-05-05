"""
05-01 读取文件示例
用"翻开一本书阅读"类比：open(打开) -> read(阅读) -> close(合上)
"""

# 首先创建一个示例文件供读取
sample_file = "sample_read.txt"
with open(sample_file, "w", encoding="utf-8") as f:
    f.write("静夜思\n")
    f.write("床前明月光\n")
    f.write("疑是地上霜\n")
    f.write("举头望明月\n")
    f.write("低头思故乡\n")

print("=" * 40)
print("1. 使用 read() 一次性读取全部内容")
print("=" * 40)

# 第一步：打开文件（就像翻开书）
file = open(sample_file, "r", encoding="utf-8")

# 第二步：读取全部内容
content = file.read()
print("文件内容:")
print(content)

# 第三步：关闭文件（就像合上书，放回书架）
file.close()
print("(文件已关闭)")

print()
print("=" * 40)
print("2. 使用 readlines() 逐行读取")
print("=" * 40)

file = open(sample_file, "r", encoding="utf-8")
lines = file.readlines()  # 返回列表，每个元素是一行
file.close()

print(f"共 {len(lines)} 行:")
for i, line in enumerate(lines, 1):
    # 行末本身带换行符，所以用 end="" 避免多空一行
    print(f"  第{i}行: {line}", end="")

print()
print(f"\n作为列表: {lines}")

print()
print("=" * 40)
print("3. 逐行处理 -- 使用 for 循环直接遍历文件")
print("=" * 40)

# 更 Python 风格的写法：直接在 for 循环里遍历文件对象
file = open(sample_file, "r", encoding="utf-8")

print("包含'月'字的行:")
for line in file:
    if "月" in line:
        print(f"  -> {line}", end="")

file.close()

print()
print("=" * 40)
print("4. 检查文件是否存在再读取")
print("=" * 40)

import os

target_file = "不存在的文件.txt"
if os.path.exists(target_file):
    file = open(target_file, "r", encoding="utf-8")
    print(file.read())
    file.close()
else:
    print(f"文件 '{target_file}' 不存在，无法读取。")

# 演示 readline() -- 一次读一行（和 readlines 不同，注意末尾有/无 s）
print()
print("=" * 40)
print("5. readline() vs readlines()")
print("=" * 40)

file = open(sample_file, "r", encoding="utf-8")
print("readline() 读第一行:", file.readline(), end="")
print("readline() 读第二行:", file.readline(), end="")
# readline() 每次只读一行，适合一行一行逐个处理的场景
file.close()
