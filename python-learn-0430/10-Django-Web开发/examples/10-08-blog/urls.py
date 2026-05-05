"""
10-08 简易博客 — urls.py
=========================
URL 路由配置。
放在：blog/urls.py
"""

from django.urls import path
from . import views

urlpatterns = [
    # 首页：文章列表
    # 访问 /blog/ → 调用 views.index
    path("", views.index, name="index"),

    # 文章详情页
    # 访问 /blog/post/5/ → 调用 views.detail，post_id=5
    path("post/<int:post_id>/", views.detail, name="detail"),

    # 创建新文章
    # 访问 /blog/create/ → 调用 views.create_post
    path("create/", views.create_post, name="create_post"),
]

# ================================================================
# 别忘了在项目主路由 myblog/urls.py 中 include 这个文件：
#
# from django.urls import path, include
#
# urlpatterns = [
#     path("admin/", admin.site.urls),
#     path("blog/", include("blog.urls")),  # ← 关键行
# ]
# ================================================================
