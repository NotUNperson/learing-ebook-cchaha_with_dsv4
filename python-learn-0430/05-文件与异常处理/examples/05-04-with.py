"""
05-04 with 语句示例
用"自动门"类比：进去自动打开，出来自动关上
"""

print("=" * 40)
print("1. 旧方式 vs with 方式")
print("=" * 40)

# 旧方式：手动 open 和 close
print("--- 旧方式 ---")
file = open("demo_with.txt", "w", encoding="utf-8")
file.write("旧方式写入\n")
file.close()  # 容易忘！

file = open("demo_with.txt", "r", encoding="utf-8")
print(file.read(), end="")
file.close()  # 又写了一次 close...

# with 方式：自动关闭
print("\n--- with 方式 ---")
with open("demo_with.txt", "r", encoding="utf-8") as f:
    print(f.read(), end="")  # 不需要 close！出了缩进块自动关
print("(文件已经自动关闭)")

print()
print("=" * 40)
print("2. with 读文件")
print("=" * 40)

# 先准备一个文件
with open("poem_demo.txt", "w", encoding="utf-8") as f:
    f.write("春晓\n")
    f.write("春眠不觉晓\n")
    f.write("处处闻啼鸟\n")
    f.write("夜来风雨声\n")
    f.write("花落知多少\n")

# 用 with 读取
print("用 with 读文件:")
with open("poem_demo.txt", "r", encoding="utf-8") as f:
    lines = f.readlines()
    print(f"共 {len(lines)} 行:")
    for i, line in enumerate(lines, 1):
        print(f"  {i}. {line}", end="")

print("\n(with 块结束，文件已自动关闭)")

print()
print("=" * 40)
print("3. with 写文件")
print("=" * 40)

# 用 with 写入
shopping_list = ["苹果\n", "牛奶\n", "面包\n", "鸡蛋\n"]
with open("shopping_list.txt", "w", encoding="utf-8") as f:
    f.writelines(shopping_list)
    print("购物清单已写入")

# 用 with 追加
with open("shopping_list.txt", "a", encoding="utf-8") as f:
    f.write("巧克力\n")  # 追加一项
    print("已追加一项")

# 用 with 读取确认
print("\n最终文件内容:")
with open("shopping_list.txt", "r", encoding="utf-8") as f:
    for line in f:
        print(f"  - {line}", end="")

print()
print("=" * 40)
print("4. with 的好处：即使出错也会关闭文件")
print("=" * 40)

print("演示：即使在 with 块中出错...")
try:
    with open("demo_error.txt", "w", encoding="utf-8") as f:
        f.write("写入一些内容\n")
        # 故意制造一个错误
        x = 1 / 0  # ZeroDivisionError!
except ZeroDivisionError:
    print("  捕获到除以零的错误！")

# 即使上面出了错，文件也是完好关闭的
print("  文件仍然被正确关闭了（with 保证的）")
# 验证文件内容已写入
with open("demo_error.txt", "r", encoding="utf-8") as f:
    print(f"  文件内容: {f.read()}", end="")
print("  -> 在出错之前写入的内容没有丢失！")

print()
print("=" * 40)
print("5. 最佳实践：永远用 with")
print("=" * 40)

print("今后操作文件，请记住：")
print("  1. 用 with open() as f: 代替手动 open/close")
print("  2. 'r' 读, 'w' 写(覆盖), 'a' 追加")
print("  3. 永远指定 encoding='utf-8' 避免中文乱码")
print("  4. with 保证文件无论怎样都会被正确关闭")
