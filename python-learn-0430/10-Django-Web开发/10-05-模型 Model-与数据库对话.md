# 10-05 模型 Model：与数据库对话

## 本节你会学到什么
- 理解数据库表和 Model 的对应关系
- 学会用 Python 代码定义数据库表结构
- 学会执行数据库迁移（makemigrations + migrate）
- 学会在视图中用 ORM 操作数据库（增删改查）

## 正文
### 数据库表就像 Excel 表格

你可能还没接触过数据库。没关系，用 Excel 来类比就很容易理解。

想象你在用 Excel 管理一个"文章列表"：

| ID | 标题 | 内容 | 创建时间 | 是否发布 |
|----|------|------|---------|---------|
| 1 | Django 入门 | Django 是一个非常棒的... | 2024-03-15 | 是 |
| 2 | Python 笔记 | Python 的基础语法包括... | 2024-03-20 | 是 |
| 3 | 草稿一篇 | 还没写完... | 2024-04-01 | 否 |

在数据库中：
- 整个表格叫"**表**"（Table）—— 对应 Django 中的一个 **Model 类**。
- 表头（ID、标题、内容...）叫"**字段**"（Field）—— 对应 Model 类中的**类属性**。
- 每一行数据叫"**记录**"（Record）—— 对应 Model 类的一个**实例对象**。

### Django ORM —— 不会 SQL 也能操作数据库

传统上，操作数据库需要学一门叫 **SQL** 的语言。比如查询所有文章：

```sql
SELECT * FROM blog_post WHERE is_published = 1 ORDER BY created_date DESC;
```

对新手来说，SQL 语法死板又难记。

Django 的 **ORM**（Object-Relational Mapping，对象关系映射）解决了这个问题。它是一个"翻译官"，把你写的 Python 代码自动翻译成 SQL 语句。

用 ORM 查所有文章：

```python
posts = Post.objects.filter(is_published=True).order_by("-created_date")
```

是不是比 SQL 自然多了？你不需要写一行 SQL，全程用 Python 就够了。

### 定义第一个 Model

在 `blog/models.py` 中定义文章模型：

```python
from django.db import models
from django.utils import timezone

class Post(models.Model):
    """博客文章模型"""
    # 标题 —— 短文本，最长 200 字符
    title = models.CharField(max_length=200, verbose_name="标题")

    # 内容 —— 长文本，没有长度限制
    content = models.TextField(verbose_name="内容")

    # 创建时间 —— 自动填入当前时间
    created_date = models.DateTimeField(default=timezone.now, verbose_name="创建时间")

    # 是否发布 —— 布尔值（True/False）
    is_published = models.BooleanField(default=True, verbose_name="发布")

    class Meta:
        ordering = ["-created_date"]  # 默认按时间倒序排列
        verbose_name = "文章"
        verbose_name_plural = "文章"

    def __str__(self):
        return self.title  # 在后台显示文章标题，而不是 "Post object (1)"
```

这段代码定义了一张"文章表"，表里有 4 个字段：title、content、created_date、is_published。Django 会自动加一个 `id` 字段作为主键（就像 Excel 表格里的第一列序号）。

### 常用字段类型速查

| 字段类型 | 对应 Python 类型 | 用在哪里 | 特殊参数 |
|---------|-----------------|---------|---------|
| `CharField` | str | 标题、名字、短文本 | `max_length`（必填） |
| `TextField` | str | 文章内容、长文本 | 无长度限制 |
| `IntegerField` | int | 数量、年龄 | 无 |
| `FloatField` | float | 价格、评分 | 无 |
| `BooleanField` | bool | 是/否开关 | 无 |
| `DateTimeField` | datetime | 日期+时间 | `auto_now_add`（创建时自动） |
| `EmailField` | str | 邮箱 | 自动验证格式 |
| `ForeignKey` | 关联对象 | 一对多关系（如文章→评论） | `on_delete`（必填） |

### 数据库迁移 —— 把设计图变成现实

定义好 Model 之后，数据库里还没有这张表。你需要两步操作：

**第一步：生成迁移文件**

```bash
python manage.py makemigrations
```

这一步相当于你画好了装修设计图，现在把它写成一份"施工计划书"。Django 会在 `blog/migrations/` 目录下生成一个 Python 文件（比如 `0001_initial.py`），里面记录了"要创建一个 Post 表，有这些字段"。

**第二步：执行迁移**

```bash
python manage.py migrate
```

这一步相当于施工队按计划书动工，在数据库里真正创建了表。

类比：
- `makemigrations` = 写施工计划书
- `migrate` = 施工队动工

每次修改 `models.py`（新增字段、修改字段类型等），都要重新执行这两步。

### 在视图中操作数据库 —— ORM 的增删改查

有了 Model 和数据库表，接下来就是在视图中使用它。

**创建（Create）—— 新增一条数据：**

```python
# 方法1：create()
Post.objects.create(
    title="我的第一篇文章",
    content="这是文章内容...",
)

# 方法2：先创建对象再 save()
post = Post(title="标题", content="内容")
post.save()
```

**查询（Read）—— 从数据库取数据：**

```python
# 获取所有文章
all_posts = Post.objects.all()

# 过滤：只要已发布的
published = Post.objects.filter(is_published=True)

# 按时间倒序
posts = Post.objects.order_by("-created_date")

# 取前 5 篇
latest_5 = Post.objects.order_by("-created_date")[:5]

# 获取单篇（根据 ID）
post = Post.objects.get(id=1)  # 找不到会报 DoesNotExist 异常

# get_or_create：有就取，没有就创建
post, created = Post.objects.get_or_create(title="某标题")
```

**更新（Update）—— 修改已有数据：**

```python
post = Post.objects.get(id=1)
post.title = "修改后的标题"
post.save()
```

**删除（Delete）—— 删除数据：**

```python
post = Post.objects.get(id=1)
post.delete()

# 或者批量删除
Post.objects.filter(is_published=False).delete()
```

### 在真实的视图中使用 Model

修改 `blog/views.py`，让首页真正从数据库获取数据：

```python
from .models import Post

def index(request):
    posts = Post.objects.filter(is_published=True).order_by("-created_date")
    context = {"posts": posts, "title": "我的博客"}
    return render(request, "blog/index.html", context)
```

在模板中遍历：

```html
{% for post in posts %}
    <div>
        <h2>{{ post.title }}</h2>
        <p>{{ post.created_date|date:"Y-m-d" }}</p>
        <p>{{ post.content|truncatechars:100 }}</p>
    </div>
{% empty %}
    <p>还没有文章。</p>
{% endfor %}
```

现在你的博客首页就是"活的"了——数据库里有多少文章，页面上就显示多少文章。

## 动手试试
1. 阅读 `examples/10-05-models.py`，了解所有常用字段和查询方法。
2. 在 `blog/models.py` 中定义 Post 模型。
3. 执行 `python manage.py makemigrations` 和 `python manage.py migrate`。
4. 运行 `python manage.py shell`，在交互环境中试试：
   ```python
   from blog.models import Post
   Post.objects.create(title="测试文章", content="测试内容")
   Post.objects.all()
   ```
5. 修改 `blog/views.py` 的 `index` 函数，用 ORM 查询代替手动写死的数据。

## 本节小结
Model = 用 Python 类定义数据库表，ORM = Python→SQL 翻译官，makemigrations+migrate = 设计图→现实。从此操作数据库全程 Python，一行 SQL 不用写。

## 下一节预告
数据库里有数据了，但每次都得进 shell 里操作太麻烦了。下一节学习 Django Admin，一个免费的数据管理后台。
