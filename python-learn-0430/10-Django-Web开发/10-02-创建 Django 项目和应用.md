# 10-02 创建 Django 项目和应用

## 本节你会学到什么
- 理解项目(project)和应用(app)的区别
- 学会创建 Django 项目和运行开发服务器
- 了解 Django 项目目录结构中每个文件的作用

## 正文
### 项目 vs 应用 —— 建商场 vs 开店

Django 有两个非常重要的概念：**项目（project）** 和 **应用（app）**。它们的区别，用"建商场"来类比非常直观：

- **项目（project）** = 整个**商场大楼**。一个项目就是一个完整的网站。比如 `myblog` 就是一个项目，对应"我的博客"这个网站。

- **应用（app）** = 商场里的**一家店铺**。一个应用负责一个具体的功能模块。比如商场里有服装店、餐厅、电影院——对应到网站里，可能有"博客模块"、"用户管理模块"、"评论模块"。

一个项目可以包含多个应用，就像一个大商场里有多家店铺。但一个应用也可以被多个项目复用——比如你写的"用户管理"应用，这个博客项目能用，以后做的电商项目也能用。

关键规则：
- 一个 Django 网站 = 一个项目
- 一个项目 = 一个或多个应用
- 每个应用负责一个独立的功能领域

### 安装 Django

和安装 pygame 一样，用 pip 一行搞定：

```bash
pip install django
```

验证安装：

```python
import django
print(django.get_version())
# 输出类似：4.2.0
```

### 创建项目 —— 盖商场大楼

Django 提供了一个命令行工具 `django-admin`，帮我们快速生成项目骨架：

```bash
# 在你想放代码的目录下运行
django-admin startproject myblog
```

运行后，Django 会自动生成一个名为 `myblog` 的文件夹，里面有这些内容：

```
myblog/                      # 项目根目录（商场大楼）
├── manage.py                # 项目管理脚本（大楼的"总控制室"）
└── myblog/                  # 项目配置目录（大楼的"管理办公室"）
    ├── __init__.py          # 表示这是一个 Python 包
    ├── settings.py          # 项目配置文件（最重要！）
    ├── urls.py              # 总 URL 路由表（"总接线台"）
    ├── asgi.py              # ASGI 部署配置（生产环境用）
    └── wsgi.py              # WSGI 部署配置（生产环境用）
```

我们来逐一理解这些文件：

- **manage.py**：这是你每天都要用的"遥控器"。启动服务器、创建应用、数据库迁移、创建管理员……几乎一切操作都通过这个脚本完成。你不需要修改它。

- **settings.py**：**最重要的文件**。所有配置都在这里：数据库连接信息、安装的应用列表、模板路径、语言设置、时区等等。你会在开发过程中频繁修改这个文件。

- **urls.py**：项目级别的 URL 路由表。就像商场一楼的"总导览图"——顾客说"我要去餐厅"，总导览图告诉你去三楼。具体的"餐厅在哪个位置"由餐厅自己的导航（应用级 urls.py）负责。

- **`__init__.py`**：空文件，只用来告诉 Python "这个目录是一个包"。在 Python 3.3+ 中不是必须的，但存在是为了兼容性。

### 运行开发服务器 —— 看看盖好的楼什么样

进入项目目录，运行：

```bash
cd myblog
python manage.py runserver
```

你会看到类似这样的输出：

```
Watching for file changes with StatReloader
Performing system checks...

System check identified no issues (0 silenced).

You have 18 unapplied migration(s)...
Run 'python manage.py migrate' to apply them.

March 15, 2024 - 10:30:00
Django version 4.2, using settings 'myblog.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CTRL-BREAK.
```

现在打开浏览器，访问 `http://127.0.0.1:8000/`。你会看到 Django 的欢迎页面——一架小火箭！这说明你的第一个 Django 项目**跑起来了**。

几个重要的点：
- `127.0.0.1` 是"本机地址"（也叫 localhost），意思是"我自己的电脑"。
- `8000` 是端口号。你可以把它理解为"大厦里的一个门牌号"。Django 默认用 8000。
- 这个服务器是**开发服务器**，只能你自己调试用，**绝对不能**用它来上线。Django 每秒钟都会警告你这一点。
- 按 `Ctrl+C` 可以停止服务器。

### 创建应用 —— 在商场里开一家店

有了项目（商场），接下来创建我们的第一个应用（店铺）。在 `manage.py` 所在目录下运行：

```bash
python manage.py startapp blog
```

这会生成一个 `blog` 文件夹：

```
blog/                         # 应用目录（一家店铺）
├── __init__.py
├── admin.py                  # 注册模型到 Django Admin 后台
├── apps.py                   # 应用配置
├── models.py                 # 数据库模型定义（食材仓库）
├── views.py                  # 视图函数（厨师）
├── tests.py                  # 单元测试
└── migrations/               # 数据库迁移文件（自动生成）
    └── __init__.py
```

**关键一步**：创建应用后，必须把它"注册"到项目中。打开 `myblog/settings.py`，找到 `INSTALLED_APPS` 列表，加上你的应用：

```python
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # ↓ 加上你自己的应用
    "blog",
]
```

这相当于在商场的"商户登记表"里写上你的店名。不注册的话，Django 就不知道你这个应用存在，很多功能（如数据库迁移、Admin 后台）都不会工作。

### 现在的完整目录结构

```
myblog/                        # 项目根目录
├── manage.py                  # 总控制室
├── myblog/                    # 项目配置
│   ├── __init__.py
│   ├── settings.py            # 所有配置
│   ├── urls.py                # 总路由表
│   ├── asgi.py
│   └── wsgi.py
└── blog/                      # 博客应用
    ├── __init__.py
    ├── admin.py               # Admin 后台配置
    ├── apps.py                # 应用配置
    ├── models.py              # 数据模型（下一节讲）
    ├── views.py               # 视图函数（下下节讲）
    ├── tests.py
    └── migrations/            # 数据库迁移
        └── __init__.py
```

后面几节我们会逐步填充 `models.py`、`views.py`、`urls.py` 这些文件，让博客真正"活"起来。

## 动手试试
1. 安装 Django，用 `python -c "import django; print(django.get_version())"` 验证版本。
2. 用 `django-admin startproject myblog` 创建一个项目。
3. 进入项目目录，运行 `python manage.py runserver`，在浏览器打开 `http://127.0.0.1:8000/`。
4. 用 `python manage.py startapp blog` 创建应用。
5. 在 `settings.py` 的 `INSTALLED_APPS` 列表末尾添加 `"blog"`。

## 本节小结
Django 项目 = 大商场，应用 = 商场里的店铺。`startproject` 建商场，`startapp` 开店，`runserver` 点亮灯光。

## 下一节预告
商场建好了，店铺也开了。但顾客怎么找到你的店？下一节学习 URL 路由和视图函数。
