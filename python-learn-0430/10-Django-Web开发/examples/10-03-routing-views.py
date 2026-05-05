"""
10-03 URL 路由与视图函数
========================
这个文件展示了 Django 中最核心的两个文件：urls.py 和 views.py。

注意：这两个文件需要在 Django 项目中才能运行，这里展示的是关键代码段。
     实际使用时，你需要先创建一个 Django 项目和应用。

类比：
  URL 路由 = 餐厅菜单（告诉顾客每个菜对应哪个厨师）
  视图函数 = 厨师（负责做菜并端给顾客）
"""

# ================================================================
# 第一部分：urls.py —— URL 路由配置
# ================================================================
# 文件位置：myblog/urls.py（项目的主路由）和 blog/urls.py（应用的路由）

# --- 项目主路由 myblog/urls.py ---
from django.contrib import admin
from django.urls import path, include
#                                 ^^^^^^^^
# include() 用于"包含"其他应用的路由配置
# 就像商场总服务台接到电话，转接到具体店铺

urlpatterns = [
    # 当用户访问 /admin/ 时，交给 Django 内置的 admin 模块处理
    path("admin/", admin.site.urls),

    # 当用户访问以 /blog/ 开头的任何网址时，
    # 把请求"转接"给 blog 应用的 urls.py 继续处理
    path("blog/", include("blog.urls")),

    # 当用户访问 /hello/ 时，直接由 hello 视图函数处理
    path("hello/", hello),
]

# --- 应用路由 blog/urls.py ---
from django.urls import path
from . import views  # 从当前目录导入 views.py

urlpatterns = [
    # path() 函数的基本格式：
    #   path("网址路径/", 视图函数, name="路由名称（可选）")

    # 用户访问 /blog/ → 调用 index 视图函数
    path("", views.index, name="index"),

    # 用户访问 /blog/about/ → 调用 about 视图函数
    path("about/", views.about, name="about"),

    # 用户访问 /blog/post/3/ → 调用 post_detail 视图函数
    # <int:post_id> 是"路径参数"：匹配数字，并将其作为 post_id 传给视图
    path("post/<int:post_id>/", views.post_detail, name="post_detail"),

    # 用户访问 /blog/post/2024/03/ → 调用 posts_by_month 视图
    # <int:year> 和 <int:month> 都是路径参数
    path("post/<int:year>/<int:month>/",
         views.posts_by_month, name="posts_by_month"),
]

# ================================================================
# 第二部分：views.py —— 视图函数
# ================================================================
# 文件位置：blog/views.py

from django.http import HttpResponse
from django.shortcuts import render

# --- 最简单的视图函数 ---
def hello(request):
    """
    任何视图函数的第一个参数都是 request。
    request 包含了用户请求的所有信息：
      - 用户访问了什么 URL
      - 用户用了 GET 还是 POST
      - 用户提交了什么数据
      - 用户的浏览器信息
      - 等等
    """
    return HttpResponse("Hello, World! 欢迎来到我的网站！")


def index(request):
    """博客首页 —— 返回一段 HTML"""
    html = """
    <h1>我的博客</h1>
    <p>欢迎来到我的个人博客！</p>
    <ul>
        <li><a href='/blog/about/'>关于我</a></li>
        <li><a href='/blog/post/1/'>第一篇文章</a></li>
    </ul>
    """
    return HttpResponse(html)


def about(request):
    """关于页面"""
    return HttpResponse("<h1>关于我</h1><p>这是一个用 Django 搭建的博客。</p>")


def post_detail(request, post_id):
    """
    文章详情页 —— 接收路径参数 post_id

    当用户访问 /blog/post/5/ 时，post_id 的值就是 5。
    Django 自动把 URL 中的数字提取出来传给你。
    """
    return HttpResponse(f"<h1>文章 #{post_id}</h1><p>这是第 {post_id} 篇文章的内容。</p>")


def posts_by_month(request, year, month):
    """按年月筛选文章"""
    return HttpResponse(f"<h1>{year}年{month}月的文章</h1><p>这里会列出 {year} 年 {month} 月的所有文章。</p>")


# ================================================================
# 第三部分：path() 函数详解
# ================================================================
#
# path() 的完整格式：
#   path(route, view, kwargs=None, name=None)
#
# route（路由规则）：
#   "about/"     — 匹配 /about/
#   ""           — 匹配根路径（如应用已被 include 为 /blog/，则匹配 /blog/）
#   "post/<int:id>/"  — 匹配 post/数字/，数字部分传给视图函数的 id 参数
#
# 路径转换器（<类型:参数名>）：
#   <int:xxx>    — 匹配整数
#   <str:xxx>    — 匹配字符串（默认）
#   <slug:xxx>   — 匹配字母、数字、横线、下划线（常用于文章标题）
#   <uuid:xxx>   — 匹配 UUID 格式
#   <path:xxx>   — 匹配完整路径（包含 /）
#
# name（路由名称）：
#   给这个路由起个名字，方便在模板或视图中反向生成 URL。
#   比如 {% url 'post_detail' post_id=5 %} 会自动生成 /blog/post/5/
#   这样即使以后改了 URL 规则，只要 name 不变，所有链接自动更新。

print("这个文件展示了 Django urls.py 和 views.py 的核心代码结构。")
print("实际使用时，这些代码需要放在 Django 项目的对应文件中。")
print("\n核心类比：")
print("  urlpatterns = 餐厅的菜单")
print("  path()      = 菜单上的一行（菜名 → 负责的厨师）")
print("  views 函数  = 厨师（接收 request，返回 response）")
print("  request     = 顾客的点单")
print("  HttpResponse = 厨师做好的菜")
