"""
10-05 模型 Model：与数据库对话
===============================
这个文件展示 Django 模型（Model）的定义和使用。

类比：
  数据库表   = Excel 表格（每行一条数据，每列一个字段）
  Model 类   = 表格的"设计蓝图"（定义有哪些列，每列是什么类型）
  一行记录   = Model 类的一个实例对象
  ORM       = 翻译官（把 Python 代码翻译成 SQL 语句）

Django ORM 的好处：
  不用写一行 SQL，全用 Python 代码操作数据库。
  写完 Model 后，Django 自动生成创建表的 SQL。
"""

# ================================================================
# 第一部分：定义模型（models.py）
# ================================================================
# 文件位置：blog/models.py

from django.db import models
from django.utils import timezone

class Post(models.Model):
    """
    博客文章模型。

    每个类属性代表数据库表中的一列（字段）。
    Django 会根据这个类自动创建数据库表。
    表名默认为：应用名_类名小写 → blog_post
    """

    # --- 字段定义 ---

    # CharField：短文本字段（标题、名字等）
    # max_length 是必填参数，限制最大字符数
    title = models.CharField(max_length=200, verbose_name="标题")

    # TextField：长文本字段（文章内容、评论等）
    # 没有 max_length 限制（数据库层面可存储大量文本）
    content = models.TextField(verbose_name="内容")

    # DateTimeField：日期时间字段
    # default=timezone.now 设置默认值为当前时间
    created_date = models.DateTimeField(
        default=timezone.now, verbose_name="创建时间"
    )

    # BooleanField：布尔值字段（是/否）
    is_published = models.BooleanField(
        default=True, verbose_name="是否发布"
    )

    # IntegerField：整数字段
    views_count = models.IntegerField(
        default=0, verbose_name="浏览次数"
    )

    # --- Meta 内部类：模型的元配置 ---
    class Meta:
        # 按创建时间倒序排列（最新的排前面）
        ordering = ["-created_date"]
        # 在 Admin 后台显示的名字
        verbose_name = "文章"
        verbose_name_plural = "文章"  # 复数形式

    # --- 方法 ---
    def __str__(self):
        """定义对象的字符串表示。
        在 Admin 后台、Shell 中显示时很有用。"""
        return self.title

    def summary(self):
        """返回文章的前 100 个字符作为摘要"""
        return self.content[:100] + "..." if len(self.content) > 100 else self.content


class Comment(models.Model):
    """评论模型 —— 演示外键关联"""

    # ForeignKey：外键，建立"一对多"关系
    # 一篇文章可以有多个评论（一对多）
    # on_delete=models.CASCADE：文章被删除时，关联的评论也一起删除
    post = models.ForeignKey(
        Post,
        on_delete=models.CASCADE,
        related_name="comments",  # 反向查询的名字
        verbose_name="所属文章"
    )

    author_name = models.CharField(max_length=50, verbose_name="评论者")
    content = models.TextField(verbose_name="评论内容")
    created_date = models.DateTimeField(
        default=timezone.now, verbose_name="评论时间"
    )

    class Meta:
        ordering = ["-created_date"]
        verbose_name = "评论"
        verbose_name_plural = "评论"

    def __str__(self):
        return f"{self.author_name}: {self.content[:30]}"


# ================================================================
# 第二部分：常用字段类型速查
# ================================================================
#
# CharField(max_length=N)   — 短文本（标题、名字）
# TextField()               — 长文本（文章内容）
# IntegerField()            — 整数
# FloatField()              — 浮点数
# BooleanField()            — 布尔值（True/False）
# DateTimeField()           — 日期+时间
# DateField()               — 纯日期
# EmailField()              — 邮箱地址（自动验证格式）
# URLField()                — 网址
# ImageField(upload_to="")  — 图片（需要 Pillow 库支持）
# FileField(upload_to="")   — 文件
# ForeignKey(to, on_delete) — 外键（一对多关系）
# ManyToManyField(to)       — 多对多关系
# OneToOneField(to, on_delete) — 一对一关系
#
# 常用字段参数：
#   max_length    — 最大长度（CharField 必填）
#   default       — 默认值
#   null=True     — 数据库层面允许 NULL
#   blank=True    — 表单验证层面允许为空
#   choices       — 可选的枚举值列表
#   verbose_name  — 字段的"人类可读"名称（在 Admin 后台显示）

# ================================================================
# 第三部分：数据库迁移命令
# ================================================================
#
# 定义好模型后，需要"应用"到数据库：
#
# 1. 生成迁移文件：
#    python manage.py makemigrations
#    → 生成 blog/migrations/0001_initial.py
#    这个文件记录了"数据库要做哪些改动"
#
# 2. 应用迁移：
#    python manage.py migrate
#    → 真正在数据库中创建表
#
# 类比：
#   makemigrations = 写一份"装修计划书"
#   migrate        = 施工队按计划书动工
#
# 每次修改 models.py 后，都要重新执行这两步。

# ================================================================
# 第四部分：在视图中使用模型（操作数据库）
# ================================================================
#
# # 创建一条记录
# post = Post.objects.create(
#     title="我的第一篇文章",
#     content="这是文章内容...",
# )
#
# # 或者先创建对象再保存
# post = Post(title="标题", content="内容")
# post.save()
#
# # 查询所有记录
# all_posts = Post.objects.all()
#
# # 过滤查询
# published = Post.objects.filter(is_published=True)
# recent = Post.objects.filter(created_date__year=2024)
#
# # 获取单条记录
# post = Post.objects.get(id=1)  # 找不到会报错
# post = Post.objects.get_or_create(title="某标题")  # 有就取，没有就建
#
# # 排序
# posts = Post.objects.order_by("-created_date")
#
# # 限制数量
# latest_5 = Post.objects.order_by("-created_date")[:5]
#
# # 更新记录
# post = Post.objects.get(id=1)
# post.title = "修改后的标题"
# post.save()
#
# # 删除记录
# post = Post.objects.get(id=1)
# post.delete()
# # 或者批量删除
# Post.objects.filter(is_published=False).delete()
#
# # 通过外键反向查询（一篇文章的所有评论）
# post = Post.objects.get(id=1)
# comments = post.comments.all()  # 因为设置了 related_name="comments"
#
# # 聚合查询
# from django.db.models import Count, Avg, Sum
# Post.objects.aggregate(Count("id"))  # 文章总数

print("这个文件展示了 Django Model 的核心定义和用法。")
print("\n核心类比：")
print("  Model 类     = Excel 表格的'列头'定义")
print("  Model 实例   = Excel 表格中的一行数据")
print("  ORM          = Python → SQL 的翻译官")
print("  makemigrations = 写装修计划书")
print("  migrate      = 施工队动工")
