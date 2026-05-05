# 08-02 datetime：处理日期和时间

## 本节你会学到什么
- 用 `datetime.now()` 获取当前日期时间
- 用 `strftime()` 把时间格式化成你想要的字符串
- 用 `timedelta` 计算日期差
- 从字符串解析日期 `strptime()`

## 正文

### 用"日历和手表"类比 datetime

日历帮你查几月几号星期几，手表告诉你现在是几点几分。Python 的 `datetime` 模块把这两者合为一体：既能看日期，又能看时间，还能计算"还有多少天"。

`datetime` 是 Python 内置模块，不需要安装。

### 获取当前时间：datetime.now()

```python
from datetime import datetime

now = datetime.now()
print(now)  # 2026-04-30 15:30:45.123456
```

`datetime.now()` 返回一个包含了年、月、日、时、分、秒、微秒的对象。你可以单独取出其中任何一部分：

```python
print(now.year)    # 2026
print(now.month)   # 4
print(now.day)     # 30
print(now.hour)    # 15
print(now.minute)  # 30
print(now.second)  # 45
print(now.weekday())  # 周几（0=周一，6=周日）
```

### 格式化输出：strftime()

直接打印时间对象，那串数字太不友好了。`strftime()` 可以把你想要的时间格式"翻译"成人看得懂的样子。

```python
from datetime import datetime

now = datetime.now()

# 常见的格式化
print(now.strftime("%Y-%m-%d"))           # 2026-04-30
print(now.strftime("%Y年%m月%d日"))        # 2026年04月30日
print(now.strftime("%H:%M:%S"))           # 15:30:45
print(now.strftime("%Y-%m-%d %H:%M:%S")) # 2026-04-30 15:30:45
print(now.strftime("%A"))                 # Thursday
```

**常用格式化代码速查表**：

| 代码 | 含义 | 示例 |
|------|------|------|
| `%Y` | 四位年份 | 2026 |
| `%y` | 两位年份 | 26 |
| `%m` | 月份（补零） | 04 |
| `%d` | 日期（补零） | 30 |
| `%H` | 小时（24 小时制） | 15 |
| `%I` | 小时（12 小时制） | 03 |
| `%M` | 分钟 | 30 |
| `%S` | 秒 | 45 |
| `%p` | AM 或 PM | PM |
| `%A` | 星期几（全称） | Thursday |
| `%a` | 星期几（缩写） | Thu |
| `%B` | 月份（全称） | April |
| `%b` | 月份（缩写） | Apr |

### 计算时间差：timedelta

"距离期末考试还有多少天？""这项工作还有几小时截止？"这类问题用 `timedelta` 轻松解决。

```python
from datetime import datetime, timedelta

today = datetime.now()
exam_date = datetime(2026, 6, 20)  # 指定一个日期

# 计算相差天数
days_left = exam_date - today
print(f"距离考试还有 {days_left.days} 天")

# 08-30 天后是几号？
future = today + timedelta(days=30)
print(f"30 天后：{future.strftime('%Y-%m-%d')}")

# 08-100 天前是几号？
past = today - timedelta(days=100)
print(f"100 天前：{past.strftime('%Y-%m-%d')}")
```

`timedelta` 除了 `days`，还可以用 `weeks`、`hours`、`minutes`、`seconds`：

```python
timedelta(weeks=2)           # 两周
timedelta(days=3, hours=12)  # 三天半
timedelta(hours=1.5)         # 报错！hours 不能是小数
# 正确的写法：
timedelta(minutes=90)        # 90 分钟 = 1.5 小时
```

### 从字符串解析时间：strptime()

你有了一份别人给的日期字符串，比如 `"2026-04-30"`，需要把它变成 datetime 对象，就用 `strptime()`：

```python
from datetime import datetime

# 把字符串变成时间对象
date_str = "2026-04-30 15:30:00"
dt = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")
print(dt.year)   # 2026
print(dt.month)  # 4

# 解析其他格式
dt2 = datetime.strptime("2026/04/30", "%Y/%m/%d")
dt3 = datetime.strptime("30-04-2026", "%d-%m-%Y")
```

**简单记忆法**：
- `strftime`（f = format）：**把时间对象格式化成字符串**（计算机 -> 人）
- `strptime`（p = parse）：**把字符串解析成时间对象**（人 -> 计算机）

### date 和 time 的细分

如果只关心日期不关心时间，可以用 `date` 类：

```python
from datetime import date

today = date.today()
print(today)           # 2026-04-30
print(today.year)      # 2026

birthday = date(2000, 1, 15)
age_days = (today - birthday).days
print(f"活了 {age_days} 天")
```

只关心时间的话用 `time` 类：

```python
from datetime import time

noon = time(12, 0, 0)
print(noon.strftime("%I:%M %p"))  # 12:00 PM
```

## 动手试试

1. 打印今天的日期，格式为"2026年4月30日 星期四"。
2. 计算距离明年元旦（2027 年 1 月 1 日）还有多少天。
3. 输入你的生日，计算你已经活了多少天。
4. 做一个"倒计时器"：输入一个未来的日期，程序每秒打印"还剩 X 天 X 小时 X 分 X 秒"（提示：用 `timedelta` 计算差值）。
5. 写一个程序判断今天是不是星期五（`weekday() == 4`），是就输出"TGIF!"。

## 本节小结

`datetime.now()` 获取时间，`strftime()` 格式化给人看，`strptime()` 解析成对象，`timedelta` 算时间差 —— 日历和手表都在你掌握之中。

## 下一节预告

日期的处理学会了，接下来看看怎么优雅地操作文件路径 —— pathlib 让文件路径处理变得像搭积木一样简单。
