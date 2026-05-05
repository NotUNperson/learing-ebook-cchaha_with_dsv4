"""
10-08 简易博客 — views.py
==========================
所有视图函数：首页列表、文章详情、创建新文章。
放在：blog/views.py
"""

from django.shortcuts import render, redirect, get_object_or_404
from .models import Post
from .forms import PostForm


def index(request):
    """
    博客首页 —— 显示所有已发布文章的列表。

    URL：/blog/
    模板：blog/index.html
    """
    # 从数据库获取所有已发布的文章（最新排前）
    posts = Post.objects.filter(is_published=True).order_by("-created_date")

    context = {
        "title": "我的博客",
        "posts": posts,
    }
    return render(request, "blog/index.html", context)


def detail(request, post_id):
    """
    文章详情页 —— 显示某篇文章的完整内容。

    URL：/blog/post/<int:post_id>/
    模板：blog/detail.html

    get_object_or_404 是 Django 的快捷函数：
      如果找到了文章 → 正常返回
      如果找不到 → 自动返回 404 页面（而不是崩掉）
    """
    post = get_object_or_404(Post, id=post_id)

    # 增加浏览次数
    # post.views_count += 1
    # post.save()

    context = {
        "post": post,
    }
    return render(request, "blog/detail.html", context)


def create_post(request):
    """
    创建新文章 —— 显示表单并处理提交。

    URL：/blog/create/
    模板：blog/create_post.html
    """
    if request.method == "POST":
        # 用户提交了表单
        form = PostForm(request.POST)
        if form.is_valid():
            # 保存新文章到数据库
            new_post = form.save()
            # 重定向到新文章详情页
            return redirect("detail", post_id=new_post.id)
    else:
        # GET 请求：显示空白表单
        form = PostForm()

    context = {
        "form": form,
        "title": "写新文章",
    }
    return render(request, "blog/create_post.html", context)
