"""
10-07 表单：让用户提交数据
==========================
这个文件展示 Django 表单的定义和在视图中的使用。

类比：
  Django 表单 = 餐厅的"点菜单"（有格式、有验证）
  HTML form  = 申请表（用户填写的部分）
  表单验证    = 服务员检查你有没有漏填必填项
  CSRF 防护  = 防伪标志（确保下单的人是你本人）
"""

# ================================================================
# 第一部分：定义表单（forms.py）
# ================================================================
# 文件位置：blog/forms.py

from django import forms
from .models import Post  # 如果需要和模型关联

class ContactForm(forms.Form):
    """
    一个简单的联系表单（不关联模型，纯表单）。
    每个类属性 = 表单中的一个字段。
    """

    # CharField = 文本输入框
    name = forms.CharField(
        max_length=100,
        label="你的名字",
        # widget 控制字段在 HTML 中的外观
        widget=forms.TextInput(attrs={
            "placeholder": "请输入你的名字",
            "class": "form-control",  # CSS 类名
        })
    )

    # EmailField = 邮箱输入框（自动验证邮箱格式）
    email = forms.EmailField(
        label="邮箱地址",
        widget=forms.EmailInput(attrs={
            "placeholder": "your@email.com",
        })
    )

    # CharField + Textarea = 多行文本框
    message = forms.CharField(
        label="留言内容",
        widget=forms.Textarea(attrs={
            "placeholder": "你想说什么...",
            "rows": 5,  # 文本框行数
        })
    )


class PostForm(forms.ModelForm):
    """
    模型表单：直接基于 Model 类自动生成表单字段。
    不需要手动定义每个字段 —— Django 会根据 Model 自动推断。

    类比：
      Form = 你自己设计点菜单
      ModelForm = 餐厅的"标准点菜单"（菜品 = 数据库字段）
    """

    class Meta:
        # 指定基于哪个模型
        model = Post
        # 指定包含哪些字段
        fields = ["title", "content", "is_published"]
        # 或者用 exclude 指定排除哪些字段：
        # exclude = ["views_count"]

        # 自定义字段的 label（标签）
        labels = {
            "title": "文章标题",
            "content": "文章内容",
            "is_published": "是否发布",
        }

        # 自定义字段的 widget
        widgets = {
            "title": forms.TextInput(attrs={
                "placeholder": "输入文章标题",
                "class": "title-input",
            }),
            "content": forms.Textarea(attrs={
                "placeholder": "输入文章内容...",
                "rows": 10,
            }),
        }


# ================================================================
# 第二部分：在视图中使用表单（views.py）
# ================================================================
# 文件位置：blog/views.py

from django.shortcuts import render, redirect
from django.http import HttpResponse
from .forms import ContactForm, PostForm
from .models import Post

def contact(request):
    """
    处理联系表单的视图。

    支持两种请求方法：
      GET  → 显示空白表单给用户填写
      POST → 用户提交了表单，处理数据

    类比：
      GET  = 服务员递给你一张空白的点菜单
      POST = 你填好点菜单交给服务员
    """

    if request.method == "POST":
        # POST 请求：用户提交了表单数据
        # 用用户提交的数据填充表单
        form = ContactForm(request.POST)

        # is_valid() 验证所有字段是否填写正确
        # 比如 email 字段会检查格式是否合法
        if form.is_valid():
            # cleaned_data 是验证通过后的"干净数据"
            # 它是字典格式：{"name": "张三", "email": "...", ...}
            name = form.cleaned_data["name"]
            email = form.cleaned_data["email"]
            message = form.cleaned_data["message"]

            # 实际应用中，这里可以：
            #   - 发邮件通知管理员
            #   - 保存到数据库
            #   - 调用其他服务
            print(f"收到来自 {name} ({email}) 的留言：{message}")

            # 处理完成后，重定向到"感谢"页面
            # redirect() 会让浏览器跳转到新的 URL
            # 这避免了用户刷新页面时重复提交表单
            return redirect("thanks")  # 假设有 name="thanks" 的路由
        else:
            # 验证失败（比如邮箱格式不对），
            # 重新渲染表单页面并显示错误信息
            # Django 会自动在模板中显示每个字段的错误
            pass
    else:
        # GET 请求：显示空白表单
        form = ContactForm()

    return render(request, "blog/contact.html", {"form": form})


def create_post(request):
    """创建新文章的视图"""

    if request.method == "POST":
        form = PostForm(request.POST)
        if form.is_valid():
            # ModelForm 可以直接 save() 保存到数据库！
            post = form.save()  # 创建并保存新的 Post 记录
            # 重定向到新创建的文章详情页
            return redirect("post_detail", post_id=post.id)
    else:
        form = PostForm()

    return render(request, "blog/create_post.html", {"form": form})


def edit_post(request, post_id):
    """编辑已有文章的视图"""

    # 先从数据库取出要编辑的文章
    post = Post.objects.get(id=post_id)

    if request.method == "POST":
        # instance=post 告诉表单：你要更新的是这篇已有文章
        form = PostForm(request.POST, instance=post)
        if form.is_valid():
            form.save()
            return redirect("post_detail", post_id=post.id)
    else:
        # GET 请求时，用已有文章的数据预填充表单
        form = PostForm(instance=post)

    return render(request, "blog/edit_post.html", {"form": form})


# ================================================================
# 第三部分：在模板中渲染表单
# ================================================================
#
# 模板文件 templates/blog/contact.html：
#
# <form method="post">
#     <!-- CSRF 令牌：Django 的安全机制，防止跨站请求伪造 -->
#     {% csrf_token %}
#
#     <!-- 简单渲染：{{ form.as_p }} 以段落方式渲染所有字段 -->
#     {{ form.as_p }}
#
#     <!-- 或者逐个字段手动渲染（更灵活）：
#     <div>
#         {{ form.name.label_tag }}
#         {{ form.name }}
#         {{ form.name.errors }}
#     </div>
#     <div>
#         {{ form.email.label_tag }}
#         {{ form.email }}
#         {{ form.email.errors }}
#     </div>
#     <div>
#         {{ form.message.label_tag }}
#         {{ form.message }}
#         {{ form.message.errors }}
#     </div>
#     -->
#
#     <button type="submit">提交</button>
# </form>

# ================================================================
# 第四部分：CSRF 防护是什么（简单理解）
# ================================================================
#
# CSRF = Cross-Site Request Forgery（跨站请求伪造）
#
# 场景：
#   你登录了银行网站 A。
#   然后你访问了恶意网站 B。
#   网站 B 偷偷向网站 A 发送转账请求。
#   因为你的浏览器里还保存着 A 的登录状态，
#   这个请求可能会被 A 当作合法请求，钱就被转走了！
#
# Django 的防护办法：
#   每个表单里放一个"一次性令牌"（{% csrf_token %}）。
#   服务器收到请求时检查令牌是否正确。
#   恶意网站 B 无法获取这个令牌，所以它的请求会被拒绝。
#
# 类比：
#   CSRF 令牌 = 银行给你的"动态口令"小令牌
#   就算有人知道你的账号，没有这个动态口令也转不走钱。

print("这个文件展示了 Django 表单系统的核心用法。")
print("\n核心类比：")
print("  Form / ModelForm  = 你定义的点菜单格式")
print("  GET 请求          = 服务员给你空白点菜单")
print("  POST 请求         = 你交回填好的点菜单")
print("  is_valid()        = 服务员检查是否有漏填")
print("  cleaned_data      = 验证通过的"干净"数据")
print("  form.save()       = ModelForm 的快捷方式：直接保存到数据库")
print("  {% csrf_token %}  = 防伪令牌")
