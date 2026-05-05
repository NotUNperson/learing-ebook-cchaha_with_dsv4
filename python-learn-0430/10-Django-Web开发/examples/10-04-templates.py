"""
10-04 模板：动态生成 HTML 页面
===============================
这个文件展示 Django 模板系统的核心用法。

类比：
  HTML 模板 = 作文填空题
  模板标签和变量 = 填空题中的"空白横线"，由数据动态填入

Django 模板放在了 templates/ 目录下，是 .html 文件，
但比普通 HTML 多了"模板语法"的超能力。
"""

# ================================================================
# 第一部分：模板文件示例
# ================================================================
# 文件位置：templates/blog/index.html
#
# 以下是一个典型的 Django 模板文件内容：

TEMPLATE_INDEX_EXAMPLE = """
<!-- templates/blog/index.html -->
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>{{ title }}</title>
    <!--  {{ title }} 是模板变量：Django 会把实际数据填到这里 -->
</head>
<body>
    <h1>{{ heading }}</h1>

    <p>当前时间：{{ now }}</p>

    <!-- 模板标签 {% ... %} 用于执行逻辑，如循环、条件判断 -->
    <h2>文章列表：</h2>
    <ul>
        {% for post in posts %}
            <!-- 循环遍历 posts 列表，每次迭代生成一个 <li> -->
            <li>
                <a href="/blog/post/{{ post.id }}/">
                    {{ post.title }}
                </a>
                <span>—— {{ post.created_date }}</span>
            </li>
        {% empty %}
            <!-- 如果 posts 是空列表，显示这段内容 -->
            <li>暂无文章</li>
        {% endfor %}
    </ul>

    <!-- 条件判断 -->
    {% if user.is_authenticated %}
        <p>欢迎回来，{{ user.username }}！</p>
    {% else %}
        <p>请先<a href="/login/">登录</a></p>
    {% endif %}
</body>
</html>
"""

# ================================================================
# 第二部分：views.py 中使用模板
# ================================================================
# 文件位置：blog/views.py

from django.shortcuts import render
from datetime import datetime

def index(request):
    """
    使用 render() 函数渲染模板。

    render() 的三个参数：
      1. request      — 请求对象（Django 自动传入）
      2. 模板路径      — 相对于 templates/ 目录的路径
      3. context（字典）— 传给模板的数据
    """
    # context 是把数据"注入"模板的字典
    # 键名 = 模板中使用的变量名
    context = {
        "title": "我的博客 - 首页",
        "heading": "欢迎来到我的博客",
        "now": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "posts": [
            {"id": 1, "title": "Django 入门教程",
             "created_date": "2024-03-15"},
            {"id": 2, "title": "Python 学习心得",
             "created_date": "2024-03-20"},
            {"id": 3, "title": "Web 开发的那些事",
             "created_date": "2024-04-01"},
        ],
    }
    return render(request, "blog/index.html", context)

# ================================================================
# 第三部分：模板语法速查
# ================================================================
#
# 1. 输出变量：
#    {{ variable }}
#    用两个大括号包裹变量名，渲染时替换为实际值。
#    支持点号访问属性：{{ post.title }}、{{ user.username }}
#
# 2. 标签 —— 执行逻辑（循环、条件等）：
#    {% tag %}
#
#    {% for item in list %} ... {% endfor %}
#       循环遍历列表
#
#    {% if condition %} ... {% elif other %} ... {% else %} ... {% endif %}
#       条件判断
#
#    {% url 'route_name' arg1 arg2 %}
#       生成 URL（建议用这个而不是硬编码 /blog/post/5/）
#
#    {% block name %} ... {% endblock %}
#       模板继承中的"预留区块"
#
#    {% extends "base.html" %}
#       继承父模板
#
#    {% include "header.html" %}
#       包含其他模板片段
#
# 3. 过滤器 —— 修改变量的显示方式：
#    {{ variable|filter }}
#
#    {{ name|lower }}         — 转小写
#    {{ name|upper }}         — 转大写
#    {{ text|truncatewords:30 }} — 截断为 30 个词
#    {{ date|date:"Y-m-d" }}  — 格式化日期
#    {{ list|length }}        — 获取列表长度
#    {{ html|safe }}          — 标记为安全 HTML（不转义）
#
# 4. 模板继承 —— 避免重复写同样的 HTML 结构：
#
#    base.html（父模板，定义页面骨架）：
#      <html>
#      <body>
#        {% block content %}{% endblock %}
#      </body>
#      </html>
#
#    index.html（子模板，只填充内容）：
#      {% extends "base.html" %}
#      {% block content %}
#        <h1>这是首页的具体内容</h1>
#      {% endblock %}

# ================================================================
# 第四部分：模板配置（settings.py 中的关键项）
# ================================================================
#
# 在 myblog/settings.py 中，TEMPLATES 配置告诉 Django 去哪里找模板文件：
#
# TEMPLATES = [
#     {
#         "BACKEND": "django.template.backends.django.DjangoTemplates",
#         "DIRS": [BASE_DIR / "templates"],  # 模板目录的路径
#         "APP_DIRS": True,  # 同时也在每个应用的 templates/ 下查找
#         # ...
#     },
# ]
#
# 建议在项目根目录创建一个 templates/ 文件夹，
# 然后在里面按应用名再建子文件夹：
#   templates/
#     blog/
#       index.html
#       detail.html
#     base.html
#
# 这样模板文件不会混乱。

print("这个文件展示了 Django 模板系统的核心概念和代码。")
print("\n核心类比：")
print("  HTML 模板           = 填空作文模板（骨架固定，内容动态）")
print("  {{ variable }}      = 填空题的横线空白")
print("  {% tag %}           = 模板中的"指令"（循环、条件）")
print("  render()            = 把数据填入模板，生成最终 HTML")
print("  context（字典）      = 你放进填空题横线里的答案")
