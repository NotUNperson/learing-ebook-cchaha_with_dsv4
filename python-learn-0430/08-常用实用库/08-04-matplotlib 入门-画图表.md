# 08-04 matplotlib 入门：画图表

## 本节你会学到什么
- 安装 matplotlib
- 用 `plot()` 画折线图
- 用 `bar()` 画柱状图
- 设置标题、坐标轴标签
- 用 `show()` 显示图表

## 正文

### 用"Excel 里的图表"类比 matplotlib

你在 Excel 里输入一列数据，点一下"插入图表"，柱状图、折线图、饼图就自动出来了。

**matplotlib 就是 Python 世界里的 Excel 图表引擎。** 它可以把数字列表变成各种可视化图表，折线图、柱状图、散点图、饼图……学术论文里、数据分析报告里的专业图表，大部分都是用 matplotlib 画的。

matplotlib 不是内置库，需要先安装。它也引入了 Python 科学计算的生态系统，用到的 numpy 库会被自动安装为依赖。

### 安装 matplotlib

在激活虚拟环境后：

```bash
pip install matplotlib
```

安装完成后验证：

```bash
python -c "import matplotlib; print(matplotlib.__version__)"
```

### 第一张图：折线图

```python
import matplotlib.pyplot as plt

# 数据：X 轴和 Y 轴
x = [1, 2, 3, 4, 5]
y = [2, 4, 6, 8, 10]

# 画折线图
plt.plot(x, y)

# 添加标题和标签
plt.title("我的第一张图表")
plt.xlabel("X 轴")
plt.ylabel("Y 轴")

# 显示图表
plt.show()
```

运行后，会弹出一个窗口，里面有一条从(1,2)到(5,10)的蓝色斜线。这是 matplotlib 的"你好，世界"。

**关键概念**：
- `plt` 是 `matplotlib.pyplot` 的惯例别名，全 Python 界都用这个名字
- `plot(x, y)` 以 x 列表为横坐标，y 列表为纵坐标，画折线
- 图表上的每个配置（标题、轴标签）都会"堆叠"在当前图表上，最后 `show()` 渲染出来

### 自定义线条样式

```python
import matplotlib.pyplot as plt

x = [1, 2, 3, 4, 5]
y1 = [1, 4, 9, 16, 25]
y2 = [1, 8, 27, 64, 125]

plt.plot(x, y1, "r-o", label="x^2")     # 红色圆点折线
plt.plot(x, y2, "b--s", label="x^3")    # 蓝色虚线方块
plt.title("两条曲线对比")
plt.xlabel("X")
plt.ylabel("Y")
plt.legend()    # 显示图例
plt.grid(True)  # 显示网格
plt.show()
```

`"r-o"` 这种格式是"颜色+线型+标记"的组合：
- `"r"` = 红色，`"b"` = 蓝色，`"g"` = 绿色，`"k"` = 黑色
- `"-"` = 实线，`"--"` = 虚线，`":"` = 点线，`"-."` = 点划线
- `"o"` = 圆点标记，`"s"` = 方块标记，`"^"` = 三角标记

### 柱状图：bar()

```python
import matplotlib.pyplot as plt

# 各城市气温
cities = ["北京", "上海", "广州", "成都", "武汉"]
temperatures = [25, 28, 32, 26, 29]

# 画柱状图
plt.bar(cities, temperatures, color=["red", "orange", "yellow", "green", "blue"])

plt.title("各城市今日最高气温")
plt.xlabel("城市")
plt.ylabel("气温(℃)")

plt.show()
```

`bar(x, height)` 的 `x` 是类别，`height` 是数值。跟 `plot` 不同的是，`bar` 的 x 轴可以是字符串（类别标签），而 `plot` 的 x 轴一般是数字。

还可以用 `barh()` 画水平柱状图，`pie()` 画饼图。

### 显示中文

默认情况下 matplotlib 不支持中文，图表里的中文会变成方块。解决方案：

```python
import matplotlib.pyplot as plt

# 设置中文字体（Windows 用 SimHei 或 Microsoft YaHei）
plt.rcParams["font.sans-serif"] = ["SimHei"]
# 这行是为了让负号正常显示
plt.rcParams["axes.unicode_minus"] = False

# 现在中文可以正常显示了
plt.title("中文标题测试")
plt.plot([1, 2, 3], [1, 4, 9])
plt.show()
```

在 Mac 上用 `["Arial Unicode MS"]`，在 Linux 上则取决于你系统安装了什么中文字体。

### 保存图表

除了显示，还可以直接保存为图片文件：

```python
plt.savefig("my_chart.png", dpi=150, bbox_inches="tight")
```

- `dpi`：分辨率（每英寸像素数），默认 100，设高点图表更清晰
- `bbox_inches="tight"`：自动裁剪掉多余空白边距

### matplotlib 的绘图步骤总结

每次画图其实就是在做一个"5 步流程"：

1. 准备数据（两个列表）
2. 画图（`plot`、`bar`、`pie` 等）
3. 修饰（`title`、`xlabel`、`ylabel`、`legend`、`grid`）
4. （可选）保存（`savefig`）
5. 显示（`show`）

### 小心：plt.show() 之后做了什么？

`plt.show()` 显示窗口，**并且在关闭窗口后，当前图表会被清空**。所以如果你需要同时保存和显示，**先 savefig 再 show**。

## 动手试试

1. 画一个你自己一周的开销柱状图（7 天，随便编数据）。
2. 画两条折线对比：`y1 = [x for x in range(10)]`（线性增长）和 `y2 = [x**2 for x in range(10)]`（平方增长）。
3. 设置中文字体后，画一个有中文标题和中文类别标签的柱状图。
4. 用 `plt.savefig()` 把图表保存为 PNG 文件，然后去文件夹里打开看看。

## 本节小结

`plot()` 画折线，`bar()` 画柱状，`title/xlabel/ylabel` 加标签，`show()` 显示 —— matplotlib 让数据可视化像搭积木一样简单。

## 下一节预告

画了图表，那怎么从互联网上拿数据来画呢？下一节学习 requests 库，让你的 Python 程序能和网站"对话"。
