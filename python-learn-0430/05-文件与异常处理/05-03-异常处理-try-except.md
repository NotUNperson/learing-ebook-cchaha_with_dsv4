# 05-03 异常处理：try/except

## 本节你会学到什么
- 理解什么是异常，以及为什么要处理异常
- 用 try/except 捕获异常并给出友好的提示
- 认识常见的异常类型

## 正文
### 为什么需要异常处理 -- 提前准备备用方案

你计划周末去爬山，但你知道可能发生意外：
- 如果下雨，就在家看电影
- 如果朋友临时有事，就自己去
- 如果封山了，就换一条路线

这就是"提前准备备用方案"。编程里的**异常处理**也一样：你要预估可能出错的地方，提前写好"如果出错了该怎么办"。

没有异常处理的代码：

```python
# 用户可能输入的不是数字！
age = int(input("请输入你的年龄: "))  # 如果输入 "abc"，程序直接崩溃
print(f"你明年 {age + 1} 岁")
```

有异常处理的代码：

```python
try:
    age = int(input("请输入你的年龄: "))
    print(f"你明年 {age + 1} 岁")
except ValueError:
    print("输入的不是数字！请重新运行程序。")
```

### try/except 的结构

```python
try:
    # 尝试执行这段代码（可能出错的部分）
    num = int(input("请输入一个数字: "))
    result = 100 / num
    print(f"100 / {num} = {result}")
except ValueError:
    # 如果 try 里的代码发生 ValueError，就执行这里
    print("请输入有效的数字！")
except ZeroDivisionError:
    # 如果 try 里的代码发生 ZeroDivisionError，就执行这里
    print("不能除以 0！")
except:
    # 如果发生了其他任何类型的异常，就执行这里
    print("发生了未知错误")
```

Python 首先执行 `try` 里面的代码。如果一切正常，跳过所有 `except`。如果出错：
- Python 看错误类型是否匹配某个 `except`，匹配就执行那个 `except` 的代码
- `except` 后面不写错误类型，表示"捕获所有类型的异常"（兜底）

### 常见异常类型

| 异常类型 | 什么时候发生 |
|---|---|
| `ValueError` | 类型对但值不对，比如 `int("abc")` |
| `TypeError` | 类型不对，比如 `"hello" + 5` |
| `ZeroDivisionError` | 除以 0 |
| `FileNotFoundError` | 文件不存在 |
| `KeyError` | 字典里没有这个键 |
| `IndexError` | 列表索引超出范围 |

### 实际场景：读取文件

```python
try:
    file = open("data.txt", "r", encoding="utf-8")
    content = file.read()
    print(content)
    file.close()
except FileNotFoundError:
    print("文件不存在！请检查文件路径。")
```

这样即使文件不存在，程序也不会崩溃，而是给出友好的提示。

## 动手试试
1. 写一个程序，要求用户输入两个数字，然后做除法
2. 用 try/except 处理三个异常：`ValueError`（非数字输入）、`ZeroDivisionError`（除数为0）、以及一个兜底的 `except`（未知错误）
3. 多测试几次，输入不同的错误数据，观察程序是否优雅
4. 加上一个 `try/except` 来读取一个不存在的文件，看程序是否崩溃

## 本节小结
用 try/except 给代码上"保险"，即使出错了程序也不会崩溃，还能给出友好的提示。

## 下一节预告
每次都手动 close() 太麻烦了，而且容易忘。Python 提供了 with 语句，自动关门。
