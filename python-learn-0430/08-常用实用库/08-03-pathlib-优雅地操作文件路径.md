# 08-03 pathlib：优雅地操作文件路径

## 本节你会学到什么
- 用 `Path` 对象表示文件路径
- 判断文件/目录是否存在 `exists()`
- 创建目录 `mkdir()` 和遍历目录 `iterdir()`
- 获取文件名后缀 `suffix()` 和拼接路径

## 正文

### 用"文件柜的标签系统"类比 pathlib

办公室里有一个文件柜，每个抽屉有标签：`2026年 / 财务报表 / 季度报告.xlsx`。你要找这份文件，顺着标签一层层打开抽屉就行。

Python 里处理文件路径，以前大家用 `os.path`（一个老办法，写起来像拼积木时只给你一堆零散的螺丝），而 `pathlib` 是 Python 3.4 引入的新方法，用起来就像一套打好标签的文件夹系统，更直观、更面向对象。

### Path 对象：路径变身

```python
from pathlib import Path

# 创建一个 Path 对象
desktop = Path("C:/Users/你的用户名/Desktop")
# 在 Mac/Linux 上：
# home = Path("/home/你的用户名")

print(desktop)  # C:\Users\你的用户名\Desktop
```

看到没有？`Path` 把路径字符串变成了一个**对象**（前面学过面向对象，这里就是用一个叫 `Path` 的类来代表路径）。之后我们可以用这个对象的属性和方法来操作路径，不用再传字符串给各种函数。

### 路径拼接：用 / 号，超级直观

这是 pathlib 最爽的功能 —— 用 `/` 拼接路径：

```python
from pathlib import Path

project = Path("D:/projects")
new_folder = project / "python-learn" / "notes"
print(new_folder)
# D:\projects\python-learn\notes
```

不需要 `os.path.join()`，不需要层层字符串拼接，一个 `/` 搞定。就像顺着文件柜的文件夹标签一层层往下走。

注意：这里用的是 `/`（正斜杠），Windows 上 pathlib 会自动转换成 `\`。

### 常用属性和方法

```python
from pathlib import Path

file_path = Path("D:/documents/report.txt")

# 基础属性
print(file_path.name)       # report.txt（完整文件名）
print(file_path.stem)       # report（不带后缀的文件名）
print(file_path.suffix)     # .txt（后缀）
print(file_path.parent)     # D:\documents（父目录）

# 是否存在
print(file_path.exists())   # True 或 False

# 判断类型
print(file_path.is_file())  # True 如果是文件
print(file_path.is_dir())   # True 如果是目录
```

### 创建和遍历目录

```python
from pathlib import Path

# 创建单个目录
new_dir = Path("./my_folder")
new_dir.mkdir(exist_ok=True)  # exist_ok=True 表示如果已存在也不报错

# 创建多层目录
deep_dir = Path("./a/b/c")
deep_dir.mkdir(parents=True, exist_ok=True)
# parents=True 会逐层创建，像 "mkdir -p"

# 遍历目录
for item in Path("./").iterdir():
    print(f"{'[目录]' if item.is_dir() else '[文件]'} {item.name}")
```

`iterdir()` 返回目录下所有文件和子目录的 Path 对象（不包括子目录里的内容，也就是不递归）。

### 读写文件：Path 直接搞定

pathlib 的 `Path` 对象还可以直接读写文件，不需要 `open()` 函数：

```python
from pathlib import Path

# 写文件
content = "这是用 pathlib 写的内容"
Path("test.txt").write_text(content, encoding="utf-8")

# 读文件
text = Path("test.txt").read_text(encoding="utf-8")
print(text)

# 读二进制
data = Path("image.png").read_bytes()

# 写二进制
Path("copy.png").write_bytes(data)
```

这些方法特别适合小文件（配置、文本、笔记）。对于大文件（几百 MB 以上），还是用 `open()` 逐行读更好。

### 对比：pathlib vs os.path

来看看同样的事情，老写法和新写法有什么区别：

```python
# ---- 老写法：os.path ----
import os

path = os.path.join("D:", "projects", "learn", "data.csv")
dir_name = os.path.dirname(path)
base_name = os.path.basename(path)
exists = os.path.exists(path)

# ---- 新写法：pathlib ----
from pathlib import Path

path = Path("D:") / "projects" / "learn" / "data.csv"
dir_name = path.parent
base_name = path.name
exists = path.exists()
```

pathlib 的写法更流畅、更自然，而且不需要记不同的函数名（`dirname`、`basename` 等），对象的属性和方法更容易理解。

### 一个实用场景：列出目录下所有 .py 文件

```python
from pathlib import Path

current_dir = Path(".")

# 用 glob 模式匹配
for py_file in current_dir.glob("*.py"):
    print(f"  {py_file.name}")

# 递归搜索所有子目录
for py_file in current_dir.rglob("*.py"):
    print(f"  {py_file}")
```

`glob("*.py")` 只搜索当前目录，`rglob("*.py")` 递归搜索所有子目录。`*` 是通配符，`*.py` 表示匹配任何以 `.py` 结尾的文件。

## 动手试试

1. 创建一个 Path 对象指向你的桌面，然后用 `iterdir()` 列出桌面上所有文件。
2. 在自己项目目录里用 `mkdir(parents=True, exist_ok=True)` 创建 `test/subtest/` 两级子目录。
3. 遍历当前目录，统计文件数量和目录数量。
4. 用 `glob("*.txt")` 找到当前目录下所有 .txt 文件，打印它们的大小（用 `stat().st_size` 获取文件大小）。
5. 用 `write_text()` 和 `read_text()` 做一个小笔记程序：把今天的日期和一句话写入 `diary.txt`，然后读取出来。

## 本节小结

`Path` 让文件路径变成对象，用 `/` 拼接路径，属性直接拿名字后缀，方法直接读写文件 —— 比 `os.path` 优雅太多。

## 下一节预告

文本和路径都搞定了，接下来学一个会让数据"可视化"的库：matplotlib，把数字变成好看的图表。
