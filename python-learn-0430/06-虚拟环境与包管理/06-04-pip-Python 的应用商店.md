# 06-04 pip：Python 的"应用商店"

## 本节你会学到什么
- 理解 pip 是什么以及它和虚拟环境的关系
- 用 pip 安装、卸载、查看第三方库
- 安装一个真实的库并验证

## 正文

### 用"手机应用商店"类比 pip

你的手机上有应用商店（App Store、华为应用市场），你想用什么软件，搜一下、点安装，搞定。

**pip 就是 Python 世界的应用商店。** 你想用别人写好的库（比如发网络请求的 `requests`、画图表的 `matplotlib`），只需要一行命令，pip 就帮你下载、安装、配置好。

pip 的全称是 "Pip Installs Packages"（一个递归缩写，Python 社区的老传统了）。它是 Python 官方推荐的包管理工具，Python 3.4 开始默认自带。

### pip 和虚拟环境的关系

你在虚拟环境里用 pip 装的包，只装在那个虚拟环境里。离开了这个环境，那些包就"看不见"了。

这就像一个应用商店账号对应一部手机：你的工作手机上装了钉钉、企业微信，你的个人手机上装了抖音、王者荣耀 —— 互不影响。

**所以 pip 安装之前，务必先激活对应的虚拟环境！**

### 安装包：pip install

语法很简单：

```bash
pip install 包名
```

比如安装 `requests`（一个用来发送 HTTP 请求的库）：

```bash
pip install requests
```

运行后，你会看到 pip 自动下载、解压、安装的过程。安装完成后，这个库就出现在你虚拟环境的 `site-packages` 目录里了。

pip 还会自动处理"依赖的依赖"：比如你装 A 库，A 库又需要 B 库和 C 库，pip 会把 B 和 C 也一起装了。

还可以安装指定版本：

```bash
pip install requests==2.25.0   # 安装 2.25.0 这个特定版本
pip install requests>=2.25.0   # 安装 2.25.0 或更高版本
```

### 卸载包：pip uninstall

```bash
pip uninstall 包名
```

比如：

```bash
pip uninstall requests
```

运行后会提示你是否确认，输入 `y` 回车就行。如果想跳过确认，加 `-y`：

```bash
pip uninstall -y requests
```

### 列出已安装的包：pip list

```bash
pip list
```

这会列出当前环境中所有已安装的第三方包及其版本。刚创建的虚拟环境运行这个命令，几乎没什么东西（只有 pip 和 setuptools 这两个自带的）。

### 查看某个包的详细信息：pip show

```bash
pip show 包名
```

比如：

```bash
pip show requests
```

会输出这个包的版本、作者、简介、依赖项、安装位置等信息。

### 升级 pip 本身

pip 自己也是一个包，偶尔会提示你升级：

```bash
python -m pip install --upgrade pip
```

### 演示：安装并使用 requests

确保你的虚拟环境已激活（提示符前有环境名），然后：

```bash
pip install requests
```

装好之后，在终端里快速验证一下：

```bash
python -c "import requests; print(requests.__version__)"
```

如果没有报错，还打印出了版本号，说明安装成功。

你也可以写一个小的 Python 脚本来试：

```python
import requests

response = requests.get("https://www.baidu.com")
print(f"状态码: {response.status_code}")
print(f"页面长度: {len(response.text)} 字符")
```

把它保存为 `test_req.py`，然后用 `python test_req.py` 运行。如果能打印出状态码 200 和页面长度，就一切正常。

### 常用 pip 命令速查表

| 命令 | 作用 |
|------|------|
| `pip install 包名` | 安装一个包 |
| `pip install 包名==版本` | 安装指定版本 |
| `pip uninstall 包名` | 卸载一个包 |
| `pip list` | 列出所有已安装的包 |
| `pip show 包名` | 查看某个包的详细信息 |
| `pip install --upgrade 包名` | 升级一个包 |

## 动手试试

1. 激活一个虚拟环境（用前面创建的那个就行）。
2. 运行 `pip list`，看看初始状态下有哪些包。
3. 用 `pip install requests` 安装 requests。
4. 再运行一次 `pip list`，对比变化。
5. 运行 `pip show requests`，查看它的详细信息。
6. 用 `python -c "import requests; print(requests.__version__)"` 验证安装。
7. 用 `pip uninstall requests` 卸载它。

## 本节小结

pip 是 Python 的包管理器，`install` 安装、`uninstall` 卸载、`list` 查看 —— 就像手机应用商店一样简单。

## 下一节预告

当一个项目用到的库越来越多，你怎么告诉别人"我这个项目需要哪些包"？下一节我们学习用 requirements.txt 记录依赖。
