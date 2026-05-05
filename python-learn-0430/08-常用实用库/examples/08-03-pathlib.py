# -*- coding: utf-8 -*-
"""
08-03 pathlib 示例
==================
演示 Path 对象的创建、拼接、属性和常用方法。

类比：pathlib 就像文件柜的标签系统，整整齐齐，一目了然。
"""

from pathlib import Path
import os

print("=" * 50)
print("pathlib 常用功能演示")
print("=" * 50)

# ---- 1. 创建 Path 对象 ----
print("\n1. 创建 Path 对象：")
desktop = Path.home() / "Desktop"       # 用户桌面路径（跨平台）
current = Path(".")                      # 当前目录
abs_current = current.resolve()          # 转为绝对路径

print(f"   当前目录：{current}")
print(f"   绝对路径：{abs_current}")
print(f"   桌面路径：{desktop}")
print(f"   用户目录：{Path.home()}")

# ---- 2. 路径拼接（用 / 号） ----
print("\n2. 路径拼接（/ 操作符）：")
project = Path("D:/projects")
sub_path = project / "python-learn" / "examples" / "demo.py"
print(f"   拼接结果：{sub_path}")
# 注意：Windows 上 Path 会自动把 / 转换为 \

# ---- 3. 路径的各个部分（属性） ----
print("\n3. 路径的各个部分：")
file_path = Path("D:/documents/report.txt")
print(f"   完整路径：{file_path}")
print(f"   文件名(name)：{file_path.name}")        # report.txt
print(f"   无后缀(stem)：{file_path.stem}")        # report
print(f"   后缀(suffix)：{file_path.suffix}")      # .txt
print(f"   父目录(parent)：{file_path.parent}")    # D:\documents
print(f"   锚点(anchor)：{file_path.anchor}")      # D:\

# ---- 4. 判断是否存在、是文件还是目录 ----
print("\n4. 判断文件/目录状态：")
test_path = Path(__file__)  # 当前这个 .py 文件自己
print(f"   当前脚本：{test_path}")
print(f"   存在吗？{test_path.exists()}")
print(f"   是文件？{test_path.is_file()}")
print(f"   是目录？{test_path.is_dir()}")

# 判断一个不存在的路径
fake_path = Path("./不存在的文件.txt")
print(f"   不存在的文件：{fake_path}")
print(f"   存在吗？{fake_path.exists()}")

# ---- 5. 创建目录 ----
print("\n5. 创建目录：")

# 在当前目录下创建 test_dir
test_dir = Path("./test_dir_demo")
test_dir.mkdir(exist_ok=True)   # 如果已存在也不报错
print(f"   创建 {test_dir.resolve()}")

# 创建多层目录
nested = Path("./a/b/c")
nested.mkdir(parents=True, exist_ok=True)
print(f"   创建多层目录 {nested.resolve()}")

# ---- 6. 遍历目录 ----
print("\n6. 遍历当前目录：")
items = list(Path(".").iterdir())[:10]  # 只取前 10 个
for item in items:
    type_label = "[目录]" if item.is_dir() else "[文件]"
    print(f"   {type_label} {item.name}")

# ---- 7. glob 模式匹配 ----
print("\n7. glob 查找文件：")
current = Path(".")
print("   当前目录下所有 .py 文件：")
for py_file in current.glob("*.py"):
    print(f"     {py_file.name}")

print("   当前目录下所有 .txt 文件：")
for txt_file in current.glob("*.txt"):
    print(f"     {txt_file.name}")

# ---- 8. 读写文件（小文件适用） ----
print("\n8. Path 直接读写文件：")

# 写文件
note = "今天是学习 pathlib 的日子！\npathlib 让路径操作变得超级简单。"
note_path = Path("./test_note.txt")
note_path.write_text(note, encoding="utf-8")
print(f"   写入文件：{note_path.resolve()}")

# 读文件
content = note_path.read_text(encoding="utf-8")
print(f"   读取文件内容：")
for line in content.split("\n"):
    print(f"     {line}")

# ---- 9. 获取文件大小和修改时间 ----
print("\n9. 文件信息：")
file_stat = Path(__file__).stat()
print(f"   当前脚本大小：{file_stat.st_size} 字节")
print(f"   最后修改：{file_stat.st_mtime:.0f} (Unix 时间戳)")

# ---- 10. 对比 os.path 老写法 ----
print("\n10. os.path vs pathlib 对比：")

# 老写法
old_path = os.path.join("D:", "projects", "learn", "data.csv")
old_dir = os.path.dirname(old_path)
old_name = os.path.basename(old_path)
print(f"   os.path 写法：路径={old_path}, 目录={old_dir}, 文件名={old_name}")

# 新写法（pathlib）
new_path = Path("D:") / "projects" / "learn" / "data.csv"
new_dir = new_path.parent
new_name = new_path.name
print(f"   pathlib 写法：路径={new_path}, 目录={new_dir}, 文件名={new_name}")

# ---- 清理测试文件 ----
print("\n清理测试文件和目录...")
note_path.unlink(missing_ok=True)   # 删除文件
# 删除创建的目录（从内到外）
for rm_dir in [nested, Path("./a/b"), Path("./a"), test_dir]:
    try:
        if rm_dir.exists():
            rm_dir.rmdir()  # 只能删除空目录
    except OSError:
        pass
print("   清理完成！")
