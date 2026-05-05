"""
10-08 简易博客 — forms.py
==========================
文章表单定义。
放在：blog/forms.py
"""

from django import forms
from .models import Post


class PostForm(forms.ModelForm):
    """创建/编辑文章的表单"""

    class Meta:
        model = Post
        fields = ["title", "content", "is_published"]  # 表单包含的字段
        labels = {
            "title": "文章标题",
            "content": "文章内容",
            "is_published": "是否发布",
        }
        widgets = {
            "title": forms.TextInput(attrs={
                "placeholder": "请输入文章标题...",
                "style": "width: 100%; padding: 8px; font-size: 16px;",
            }),
            "content": forms.Textarea(attrs={
                "placeholder": "请输入文章内容...",
                "rows": 12,
                "style": "width: 100%; padding: 8px; font-size: 14px;",
            }),
        }
