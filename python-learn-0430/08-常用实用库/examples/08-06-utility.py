# -*- coding: utf-8 -*-
"""
08-06 实用小工具示例
====================
结合 datetime + pathlib + random + shutil 做一个文件夹整理器，
以及一个随机文件名生成器。

核心思想：把多个标准库组合起来解决实际问题。
"""

from pathlib import Path
from datetime import datetime
import random
import string
import shutil

print("=" * 50)
print("实用小工具演示")
print("=" * 50)

# =====================================================
#  工具一：文件夹整理器
# =====================================================

def organize_folder(target_dir):
    """
    整理文件夹：按文件后缀分类，把文件移到对应子目录。

    参数:
        target_dir: 要整理的目录路径（字符串或 Path 对象）

    处理后：
        txt/    存放所有 .txt 文件
        py/     存放所有 .py 文件
        jpg/    存放所有 .jpg 文件
        无后缀/ 存放没有后缀的文件
        ...（依此类推）
    """
    target = Path(target_dir)

    if not target.exists():
        print(f"目录 {target} 不存在！")
        return False

    # 收集所有文件（跳过目录）
    files = [f for f in target.iterdir() if f.is_file()]

    if not files:
        print(f"目录 {target} 中没有文件")
        return True

    print(f"找到 {len(files)} 个文件，开始整理...")

    moved_count = 0
    log_lines = []

    for file_path in files:
        # 获取后缀（去掉点，统一小写）
        suffix = file_path.suffix.lstrip(".").lower()
        if not suffix:
            suffix = "无后缀"

        # 创建对应的分类子目录
        category_dir = target / suffix
        category_dir.mkdir(exist_ok=True)

        # 目标路径
        new_path = category_dir / file_path.name

        # 如果已有同名文件，加上数字后缀避免覆盖
        if new_path.exists():
            stem = file_path.stem  # 不带后缀的文件名
            for i in range(1, 100):
                new_name = f"{stem}_{i}{file_path.suffix}"
                new_path = category_dir / new_name
                if not new_path.exists():
                    break

        # 移动文件
        shutil.move(str(file_path), str(new_path))
        log = f"[{datetime.now().strftime('%H:%M:%S')}] {file_path.name} -> {suffix}/"
        log_lines.append(log)
        moved_count += 1
        print(f"  {log}")

    # 写入整理日志
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = target / f"整理日志_{timestamp}.txt"
    log_file.write_text("\n".join(log_lines), encoding="utf-8")
    print(f"\n整理完成！共移动 {moved_count} 个文件")
    print(f"日志文件：{log_file.name}")
    return True


# =====================================================
#  工具二：随机文件名生成器
# =====================================================

def random_filename(prefix="tmp", suffix=".txt", with_time=True):
    """
    生成一个随机的、不太可能重复的文件名。

    参数:
        prefix:   前缀（如 "temp"、"cache"、"backup"）
        suffix:   后缀（如 ".txt"、".log"、".tmp"）
        with_time: 是否在文件名中嵌入时间戳

    返回:
        类似 "cache_20260430_1530_x7k2m3.tmp" 的文件名
    """
    time_part = ""
    if with_time:
        time_part = datetime.now().strftime("%Y%m%d_%H%M") + "_"

    # 6 位随机字符（小写字母 + 数字）
    chars = string.ascii_lowercase + string.digits
    random_part = "".join(random.choices(chars, k=6))

    return f"{prefix}_{time_part}{random_part}{suffix}"


# =====================================================
#  演示：生成随机文件名
# =====================================================

print("\n" + "=" * 50)
print("随机文件名生成器演示")
print("=" * 50)

print("\n生成 5 个随机文件名：")
for i in range(5):
    name = random_filename("cache", ".tmp")
    print(f"  {name}")

print("\n生成 5 个日志文件名：")
for i in range(5):
    name = random_filename("log", ".txt")
    print(f"  {name}")

# =====================================================
#  演示：文件夹整理器
# =====================================================

print("\n" + "=" * 50)
print("文件夹整理器演示")
print("=" * 50)

# 创建一个测试文件夹和一些测试文件
test_dir = Path("./test_organize_demo")
test_dir.mkdir(exist_ok=True)

# 清除旧文件
for old in test_dir.iterdir():
    if old.is_file():
        old.unlink()
    elif old.is_dir():
        shutil.rmtree(str(old))

# 创建一些不同类型和内容的测试文件
print("\n创建测试文件...")
(test_dir / "readme.txt").write_text("这是一个说明文件", encoding="utf-8")
(test_dir / "notes.txt").write_text("学习笔记", encoding="utf-8")
(test_dir / "script.py").write_text("print('hello')", encoding="utf-8")
(test_dir / "utils.py").write_text("def add(a,b): return a+b", encoding="utf-8")
(test_dir / "photo.jpg").write_text("fake image data", encoding="utf-8")
(test_dir / "image.jpg").write_text("fake image data 2", encoding="utf-8")
(test_dir / "config.json").write_text('{"version": "1.0"}', encoding="utf-8")
(test_dir / "NOTES.txt").write_text("大写后缀测试", encoding="utf-8")
(test_dir / "nofile").write_text("没有后缀的文件", encoding="utf-8")

print("测试文件创建完毕！")
print(f"\n整理前，{test_dir.resolve()} 目录内容：")
for item in sorted(test_dir.iterdir()):
    print(f"  {'[D]' if item.is_dir() else '[F]'} {item.name}")

# 执行整理
print("\n--- 开始整理 ---")
organize_folder(test_dir)

print(f"\n整理后，{test_dir.resolve()} 目录内容：")
for item in sorted(test_dir.iterdir()):
    if item.is_dir():
        print(f"  [D] {item.name}/")
        for sub in sorted(item.iterdir()):
            print(f"      [F] {sub.name}")
    else:
        print(f"  [F] {item.name}")

print("\n工具演示完毕！")
