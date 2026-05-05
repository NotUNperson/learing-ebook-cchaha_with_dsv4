# 06-05 requirements.txt：记录项目依赖

## 本节你会学到什么
- 理解 requirements.txt 的作用
- 用 `pip freeze` 生成依赖清单
- 用 `pip install -r` 从清单批量安装

## 正文

### 用"购物清单"类比 requirements.txt

你去超市买菜，如果只买一两样，脑子里记着没问题。但如果要买 50 样东西，你一定会写一张购物清单。

同样的道理，你的 Python 项目可能依赖几十个第三方库。如果要把项目分享给别人（或者换一台电脑开发），你怎么让对方知道该装哪些库？挨个口头告诉他"你装这个、再装那个、再装那个……"显然不现实。

**requirements.txt 就是这张"购物清单"：它用纯文本记录了这个项目需要的所有第三方库及其版本。**

### requirements.txt 长什么样？

一个典型的 `requirements.txt` 文件长这样：

```
requests==2.31.0
flask==3.0.0
numpy==1.26.2
pandas==2.1.4
```

每一行一个包，`==` 后面是版本号。语法和 `pip install 包名==版本号` 中的版本号部分一致。

### 生成 requirements.txt：pip freeze

最常用的方法是：

```bash
pip freeze > requirements.txt
```

- `pip freeze`：列出当前虚拟环境中所有已安装的包及版本号
- `>`：把输出重定向到文件（终端里学过的基本操作）
- `requirements.txt`：文件名，惯例叫这个（你也可以取别的名字，但全 Python 界都认这个名字）

**重要提醒**：运行 `pip freeze` 之前，确保你在正确的虚拟环境中！否则你会把全局环境的所有包都写进去，那清单就太长了，里面还有很多这个项目根本不需要的东西。

### 从 requirements.txt 安装：pip install -r

当你拿到一个有 `requirements.txt` 的项目（比如从 GitHub 上下载的），只需要一行命令就能装好所有依赖：

```bash
pip install -r requirements.txt
```

`-r` 是 `--requirement` 的缩写，意思是"从这个文件读取要安装的包列表"。

同样，运行之前先激活对应的虚拟环境。

### 一个完整的协作流程

假设你和朋友小明合作开发一个 Flask 网站：

**你的操作（分享者）：**

```bash
# 1. 确认在虚拟环境中
# 2. 安装项目需要的包
pip install flask requests

# 3. 生成依赖清单
pip freeze > requirements.txt

# 4. 把 requirements.txt 和你的代码一起发给小明（或上传到 GitHub）
```

**小明的操作（接收者）：**

```bash
# 1. 克隆或下载你的项目代码
# 2. 创建虚拟环境并激活
python -m venv venv
venv\Scripts\activate    # Windows
# source venv/bin/activate  # Mac/Linux

# 3. 根据清单安装所有依赖
pip install -r requirements.txt

# 4. 开跑！
python app.py
```

这样小明就能在你的代码里用到的所有库都装好，不会遗漏，版本也一模一样。

### 版本号写不写？

- **写死版本号**（`requests==2.31.0`）：最安全，确保所有环境一模一样。推荐在团队项目中使用。
- **不写版本号**（`requests`）：只用名字，pip 会自动装最新版。方便，但如果新版本有不兼容的改动，可能会出 bug。
- **写范围**（`requests>=2.25.0,<3.0`）：灵活性折中。允许小版本升级，但禁止大版本变化。

新手建议先用 `pip freeze` 生成的精确版本，最省心。

### 不要把虚拟环境本身上传

如果你用 Git 管理代码，记得把虚拟环境文件夹（`venv/` 或 `.venv/`）加入 `.gitignore`。虚拟环境文件夹可能很大（几百 MB），且在不同电脑上不通用。把 `requirements.txt` 上传就够了，接收者会根据它重建自己的虚拟环境。

## 动手试试

1. 激活一个虚拟环境。
2. 安装两个包，比如 `requests` 和 `flask`：
   ```bash
   pip install requests flask
   ```
3. 运行 `pip freeze > requirements.txt`，生成清单文件。
4. 用记事本或编辑器打开 `requirements.txt`，看看里面写了什么。
5. （可选）创建一个新的虚拟环境，用 `pip install -r requirements.txt` 在这个新环境里批量安装，验证一模一样。

## 本节小结

`requirements.txt` 是项目的"购物清单"，`pip freeze` 生成它，`pip install -r` 按照它安装 —— 让项目依赖的传递变得轻松可靠。

## 下一节预告

虚拟环境和包管理的内容到这里就结束了。接下来我们进入一个有趣的模块 —— 用 Python 的海龟绘图（turtle）在屏幕上画画！
