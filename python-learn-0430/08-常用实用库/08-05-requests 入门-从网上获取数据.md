# 08-05 requests 入门：从网上获取数据

## 本节你会学到什么
- 安装 requests 库
- 发送 GET 请求并获取响应
- 理解 HTTP 状态码
- 获取文本和 JSON 数据

## 正文

### 用"去网站柜台要一份资料"类比 HTTP 请求

你去一家公司办事，走到前台说："你好，我想要一份 XX 资料的复印件。" 前台要么给你资料（"好的，给"），要么告诉你"没找到"（404），要么让你去别的地方（302 重定向）。

**在互联网上，你的 Python 程序就是"来访者"，别人的服务器就是"前台"，而 requests 库就是帮你走进去、开口要资料的"嘴巴和手"。**

requests 不是内置库，需要用 pip 安装：

```bash
pip install requests
```

requests 是 Python 界最流行的第三方库之一，它把底层的 HTTP 协议包装成"一句话调用"的极简体验。官网对它的描述是"HTTP for Humans"（给人用的 HTTP）。

### 发送第一个请求：get()

```python
import requests

response = requests.get("https://www.baidu.com")

print(response.status_code)   # 200 表示成功
print(len(response.text))     # 百度首页的 HTML 长度
```

`requests.get(url)` 向指定的网址发送一个 GET 请求（"请给我这个页面的内容"），返回一个 `Response` 对象。

### Response 对象的常用属性

| 属性/方法 | 含义 |
|-----------|------|
| `response.status_code` | HTTP 状态码。200 成功，404 找不到，500 服务器错误 |
| `response.text` | 响应的内容（字符串，通常是 HTML） |
| `response.json()` | 如果返回的是 JSON 数据，直接解析成字典/列表 |
| `response.content` | 响应的内容（二进制，用于下载图片、文件等） |
| `response.headers` | 响应的头部信息（字典） |
| `response.url` | 实际响应的 URL（如果发生了重定向，可能与请求的 URL 不同） |
| `response.encoding` | 响应的编码 |

### HTTP 状态码速查

| 状态码 | 含义 |
|--------|------|
| 200 | 一切正常 |
| 301 | 永久重定向（网址搬家了） |
| 302 | 临时重定向 |
| 403 | 禁止访问（你没权限） |
| 404 | 页面不存在 |
| 500 | 服务器内部出错 |

状态码是服务器跟你"打招呼"的方式。检查状态码是写爬虫程序的基本功：

```python
response = requests.get(url)
if response.status_code == 200:
    print("成功获取数据！")
elif response.status_code == 404:
    print("页面不存在")
else:
    print(f"请求失败，状态码：{response.status_code}")
```

`requests` 还提供了一个更简单的方法：`response.ok` 属性。状态码在 200-399 之间返回 `True`，否则返回 `False`。

```python
if response.ok:
    print("请求成功")
```

### 获取 JSON 数据（调用 API）

互联网上有很多免费的 API（应用程序接口），它们直接返回 JSON 格式的数据，非常适合程序读取。

```python
import requests

# 一个免费 API：获取随机用户信息
response = requests.get("https://api.github.com")
data = response.json()  # 把 JSON 字符串变成 Python 字典

print(f"GitHub API 版本: {data.get('current_user_url', '未知')}")
```

注意：调用 `response.json()` 之前要确保返回的确实是 JSON。如果服务器返回的是 HTML 或纯文本，`.json()` 会报错。可以先用 `response.text[:100]` 看看返回内容的前 100 个字符。

### 带参数的请求：params

很多 API 支持查询参数，比如搜索：

```python
# 搜索 GitHub 上的仓库
params = {"q": "python turtle"}
response = requests.get("https://api.github.com/search/repositories", params=params)

if response.ok:
    data = response.json()
    print(f"找到 {data['total_count']} 个仓库")
    for repo in data["items"][:3]:
        print(f"  - {repo['full_name']}")
```

`params` 会自动拼接到 URL 后面，变成 `?q=python+turtle`，比自己手动拼接 URL 更安全。

### 设置超时和错误处理

```python
import requests

try:
    response = requests.get("https://www.baidu.com", timeout=5)
    response.raise_for_status()  # 如果不是 200 就抛异常
    print("请求成功")
except requests.exceptions.Timeout:
    print("请求超时了，可能是网络太慢")
except requests.exceptions.ConnectionError:
    print("连接失败，检查一下网络和网址")
except requests.exceptions.HTTPError:
    print(f"HTTP 错误，状态码：{response.status_code}")
except Exception as e:
    print(f"未知错误：{e}")
```

几个关键的防错机制：
- `timeout=5`：如果 5 秒内没有响应就抛出异常，防止程序永远卡住
- `raise_for_status()`：把 4xx 或 5xx 状态码转成异常
- `try/except`：捕获各种可能的错误

### GET 和 POST 的区别

- **GET**：向服务器要数据（"把那个页面给我看看"）。参数在 URL 里。
- **POST**：向服务器提交数据（"这是我要提交的报名表"）。参数在请求体里。

```python
# POST 示例
data = {"username": "xiaoming", "password": "123456"}
response = requests.post("https://example.com/login", data=data)
```

在我们的学习阶段，主要用 GET 就够了。

## 动手试试

1. 用 `requests.get()` 请求百度首页，打印状态码和页面文字的前 200 个字符。
2. 访问 `https://api.github.com`，用 `.json()` 解析，打印出它提供了哪些 API 入口。
3. 写一个"网址探活器"：输入一个网址，程序告诉你这个网站能不能访问（状态码是不是 200）。
4. 尝试故意访问一个不存在的页面（如 `https://www.baidu.com/nonexist`），看状态码是多少。
5. 搜索 GitHub API（`https://api.github.com/search/repositories?q=turtle`），打印前 5 个仓库的名字和星数。

## 本节小结

`requests.get()` 发请求，`status_code` 看状态，`.text` 取文本，`.json()` 解析数据 —— 让你的 Python 程序有了"上网"的能力。

## 下一节预告

我们已经学了 random、datetime、pathlib 和 requests，下一节把这些库结合起来做一个实用小工具。
