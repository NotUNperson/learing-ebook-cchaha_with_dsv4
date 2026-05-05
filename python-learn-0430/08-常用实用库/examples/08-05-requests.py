# -*- coding: utf-8 -*-
"""
08-05 requests 入门示例
=======================
演示 requests.get()、状态码检查、JSON 解析、错误处理。

类比：你的 Python 程序去网站柜台要资料。
注意：需要先 pip install requests
"""

import requests

print("=" * 50)
print("requests 常用功能演示")
print("=" * 50)

# ---- 1. 基本 GET 请求 ----
print("\n1. 基本 GET 请求：")

response = requests.get("https://www.baidu.com")
print(f"   状态码：{response.status_code}")
print(f"   状态是否正常：{response.ok}")
print(f"   页面编码：{response.encoding}")
print(f"   页面长度：{len(response.text)} 字符")
print(f"   页面标题：", end="")
# 从 HTML 中提取 <title> 标签内容（简单方法）
if "<title>" in response.text:
    start = response.text.find("<title>") + 7
    end = response.text.find("</title>")
    print(response.text[start:end])
else:
    print("未找到")

# ---- 2. 获取 JSON 数据 ----
print("\n2. 获取 JSON 数据（GitHub API）：")

response = requests.get("https://api.github.com")
if response.ok:
    data = response.json()
    print(f"   API 入口信息：")
    # 只打印前 5 个 key-value
    for i, (key, value) in enumerate(data.items()):
        if i < 5:
            print(f"     {key}: {value}")

# ---- 3. 带参数的请求 ----
print("\n3. 带参数搜索 GitHub 仓库：")

params = {"q": "python turtle", "per_page": 5}
response = requests.get(
    "https://api.github.com/search/repositories",
    params=params
)

if response.ok:
    data = response.json()
    total = data["total_count"]
    print(f"   找到 {total} 个仓库，显示前 5 个：")
    for repo in data["items"]:
        name = repo["full_name"]
        stars = repo["stargazers_count"]
        desc = (repo["description"] or "无描述")[:40]
        print(f"   - {name} ({stars} 星): {desc}")
else:
    print(f"   请求失败，状态码：{response.status_code}")

# ---- 4. URL 和响应头 ----
print("\n4. 响应头和 URL：")
response = requests.get("https://www.baidu.com")
print(f"   实际 URL：{response.url}")
print(f"   Content-Type：{response.headers.get('Content-Type')}")
print(f"   Server：{response.headers.get('Server')}")

# ---- 5. 错误处理 ----
print("\n5. 错误处理演示：")

# 正常的请求
try:
    response = requests.get("https://www.baidu.com", timeout=5)
    response.raise_for_status()
    print("   百度：请求成功")
except requests.exceptions.Timeout:
    print("   百度：请求超时")
except requests.exceptions.ConnectionError:
    print("   百度：连接失败")

# 请求一个不存在的页面
try:
    response = requests.get("https://www.baidu.com/nonexistent-page", timeout=5)
    response.raise_for_status()
    print("   不存在页面：请求成功")  # 不应该到这里
except requests.exceptions.HTTPError:
    print(f"   不存在页面：HTTP 错误，状态码 {response.status_code}")

# 请求一个不存在的域名
try:
    response = requests.get("https://this-domain-does-not-exist-123456.com", timeout=5)
except requests.exceptions.ConnectionError:
    print("   虚假域名：连接失败（意料之中）")

# ---- 6. 请求一个返回中文的 API ----
print("\n6. 获取一首诗（免费 API）：")

try:
    # 一个免费古诗词 API
    response = requests.get("https://v1.jinrishici.com/rensheng.txt", timeout=5)
    if response.ok:
        # 这个 API 的编码问题需要特殊处理
        response.encoding = "utf-8"
        poem = response.text.strip()
        print(f"   今日诗词：{poem}")
    else:
        print(f"   诗词 API 返回状态码：{response.status_code}")
except Exception as e:
    print(f"   诗词 API 请求失败：{e}")

print("\nrequests 演示完毕！")
