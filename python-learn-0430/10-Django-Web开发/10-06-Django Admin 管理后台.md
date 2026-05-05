# 10-06 Django Admin 管理后台

## 本节你会学到什么
- 理解 Django Admin 是什么以及为什么它很厉害
- 学会创建超级用户（管理员账号）
- 学会把 Model 注册到 Admin 后台
- 学会在 Admin 后台中进行数据管理

## 正文
### Django Admin 是什么 —— 免费的管理后台

如果你开了一家餐厅，你需要一个"管理后台"来管理菜单、记录营业额、查看库存。你可以花钱买一套管理系统，也可以自己花几个月写一个。

Django 做了一件非常慷慨的事：它**免费送你一个管理后台**。

只要你定义了数据模型，Django Admin 就自动生成一个功能齐全的网页界面，可以：
- 查看所有数据（列表展示、分页、搜索、筛选）
- 新增数据（自动生成表单）
- 修改数据
- 删除数据
- 管理用户和权限

这节省了大量的开发时间——很多项目直接用 Django Admin 作为内部管理系统就够了。

### 创建超级用户 —— 拿到"万能钥匙"

要进入 Admin 后台，你需要一个管理员账号。Django 用"超级用户"（superuser）这个词，意思是"最高权限的管理员"。

运行命令：

```bash
python manage.py createsuperuser
```

然后按提示输入：

```
用户名：admin（或你想要的任何名字）
邮箱地址：your@email.com（可以不填真的）
密码：********（输入时看不到字符，这是正常的）
确认密码：********
```

```bash
# 完整交互示例：
$ python manage.py createsuperuser
用户名: admin
电子邮件地址: admin@example.com
Password:
Password (again):
Superuser created successfully.
```

密码要求：至少 8 个字符，不能太简单（不能用 `12345678` 这种）。输入密码时屏幕上不会显示任何字符，这是安全设计，不是卡住了。

创建成功后，启动开发服务器：

```bash
python manage.py runserver
```

访问 `http://127.0.0.1:8000/admin/`，用刚才创建的用户名和密码登录。你会看到 Django Admin 的主界面：

- 用户和组管理（Django 内置的用户系统）
- 可能还有一些默认的表格

但是——你之前定义的 `Post` 模型**不会自动出现在这里**。你需要手动"注册"它。

### 注册 Model 到 Admin

在 `blog/admin.py` 中添加：

```python
from django.contrib import admin
from .models import Post

# 注册 Post 模型到 Admin 后台
admin.site.register(Post)
```

刷新 Admin 页面，你会看到"Blog"分类下出现了"文章"（Posts）。点击进去，你可以看到所有文章的列表。

这时候你再点"增加 文章"按钮，Django 会自动生成一个表单，包含你在 `models.py` 中定义的所有字段——标题输入框、内容文本框、日期选择器、发布开关。每个字段的类型都对应合适的表单控件。

这就是 Django Admin 的魔力——你只定义了 Model，它就自动生成了完整的管理界面。

### 让 Admin 列表页更好用

默认的 Admin 列表页只显示 `__str__()` 的返回值（对 Post 来说是标题）。我们可以通过自定义来让它更好用：

```python
from django.contrib import admin
from .models import Post

class PostAdmin(admin.ModelAdmin):
    # 在列表页显示哪些列
    list_display = ["title", "created_date", "is_published"]

    # 哪些列可以点击排序
    ordering = ["-created_date"]

    # 右侧添加筛选器
    list_filter = ["is_published", "created_date"]

    # 顶部添加搜索框
    search_fields = ["title", "content"]

    # 每页显示多少条
    list_per_page = 20

# 注册时关联自定义的配置类
admin.site.register(Post, PostAdmin)
```

刷新页面，现在列表页变成了一个功能齐全的数据管理表格：你可以按标题搜索、按发布时间筛选、点击列头排序。这完全免费——你只写了 10 行配置代码。

### Admin 后台能做什么（实际操作指南）

登录 Admin 后台后，试试这些操作：

1. **新增文章**：点击右上角的"增加 文章"按钮，填写标题和内容，保存。
2. **查看列表**：所有文章以表格形式展示，带分页。
3. **搜索**：在顶部搜索框输入关键词，可以搜索标题和内容。
4. **筛选**：右侧边栏按"是否发布"或"创建时间"筛选。
5. **编辑**：点击某篇文章，进入编辑页面，修改内容后保存。
6. **删除**：在列表页勾选多条记录，选择"删除所选的文章"。
7. **快速编辑**：如果设置了 `list_editable`，可以直接在列表页改字段值。

### 什么时候用 Admin，什么时候不用

Django Admin 最适合：
- 管理员管理网站数据（增删改查文章、用户等）
- 内部工具和后台管理系统
- 开发阶段快速录入测试数据

Django Admin **不适合**当作用户使用的界面。你不会让普通用户（读者）用 Admin 后台来阅读文章——Admin 是为管理员设计的，它的 UI 风格和信息架构不适合面向公众。

## 动手试试
1. 用 `python manage.py createsuperuser` 创建管理员账号。
2. 在 `blog/admin.py` 中用 `admin.site.register(Post)` 注册模型。
3. 启动服务器，访问 `http://127.0.0.1:8000/admin/`，登录。
4. 在 Admin 后台中创建 3-5 篇测试文章。
5. 添加 `PostAdmin` 配置类，设置 `list_display`、`search_fields`、`list_filter`。
6. 返回你的博客首页 `/blog/`，看看刚才在 Admin 后台创建的文章是不是显示出来了。

## 本节小结
Django Admin 是 Django 最强大的功能之一——免费的后台管理系统。创建超级用户、注册 Model，就能获得完整的数据管理界面。

## 下一节预告
现在只能管理员通过 Admin 后台发文章。下一节学习表单，让普通用户也能提交数据。
