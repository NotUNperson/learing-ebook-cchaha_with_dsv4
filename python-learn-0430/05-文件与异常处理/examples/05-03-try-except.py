"""
05-03 异常处理 try/except 示例
用"提前准备备用方案"类比：如果出错，就执行备用代码
"""

print("=" * 40)
print("1. 没有异常处理的代码 -- 输入错误就崩溃")
print("=" * 40)

# 下面代码被注释掉了，因为一运行就会崩溃
# age = int(input("请输入年龄: "))  # 输入"abc"时程序直接崩溃

print("如果没有 try/except，输入 abc 程序会直接报 ValueError 崩溃！")
print()

print("=" * 40)
print("2. 用 try/except 捕获 ValueError")
print("=" * 40)

# 为了能自动运行演示，我们用预设数据模拟用户输入
test_inputs = ["25", "abc", "16"]  # 模拟用户分别输入了这些

for user_input in test_inputs:
    print(f"\n用户输入了: '{user_input}'")
    try:
        age = int(user_input)
        print(f"  你明年 {age + 1} 岁")
    except ValueError:
        print(f"  错误: '{user_input}' 不是有效的数字！")

print()
print("=" * 40)
print("3. 捕获多种异常类型")
print("=" * 40)


def safe_divide(a, b):
    """安全除法：处理各种可能的异常"""
    try:
        result = a / b
        print(f"  {a} / {b} = {result}")
    except ZeroDivisionError:
        print(f"  错误: 不能除以 0！（{a} / {b}）")
    except TypeError:
        print(f"  错误: 类型不匹配！（{type(a).__name__} / {type(b).__name__}）")
    except Exception as e:
        # 兜底：捕获其他任何未知异常
        print(f"  未知错误: {e}")


# 测试各种情况
print("正常除法:")
safe_divide(10, 2)
safe_divide(100, 4)

print("\n除以 0:")
safe_divide(10, 0)

print("\n类型错误:")
safe_divide("hello", 5)

print()
print("=" * 40)
print("4. 读取文件时的异常处理")
print("=" * 40)

# 读取一个存在的文件
print("读取存在的文件:")
try:
    file = open("sample_read.txt", "r", encoding="utf-8")
    content = file.read()
    print("  文件内容:")
    for line in content.split("\n"):
        if line:
            print(f"    {line}")
    file.close()
except FileNotFoundError:
    print("  文件不存在！")

# 读取一个不存在的文件
print("\n读取不存在的文件:")
try:
    file = open("不存在的文件.txt", "r", encoding="utf-8")
    content = file.read()
    print(content)
    file.close()
except FileNotFoundError:
    print("  错误: 文件不存在！请检查路径。")

print()
print("=" * 40)
print("5. 完整的 try/except/else/finally 结构")
print("=" * 40)

"""
完整结构:
try:
    尝试执行的代码
except 错误类型:
    出错时执行
else:
    没有出错时执行（可选）
finally:
    不管出不出错都执行（可选，常用于清理资源）
"""


def read_file_safe(filename):
    """完整异常处理的文件读取"""
    file = None
    try:
        file = open(filename, "r", encoding="utf-8")
        content = file.read()
        print(f"  {filename} 读取成功，共 {len(content)} 个字符")
    except FileNotFoundError:
        print(f"  {filename} 不存在")
    else:
        # 只有没有异常时才会执行
        print("  (else: 没有发生任何错误)")
        return content
    finally:
        # 无论如何都会执行 -- 保证文件被关闭
        if file:
            file.close()
            print("  (finally: 文件已关闭)")
    return None


print("测试 1: 存在的文件")
read_file_safe("sample_read.txt")

print("\n测试 2: 不存在的文件")
read_file_safe("不存在的文件.txt")
