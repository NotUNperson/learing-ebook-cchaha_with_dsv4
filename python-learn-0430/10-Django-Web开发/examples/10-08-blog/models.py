"""
10-08 简易博客 — models.py
===========================
定义博客文章的数据模型。
放在：blog/models.py
"""

from django.db import models
from django.utils import timezone


class Post(models.Model):
    """博客文章模型"""

    # 文章标题
    title = models.CharField(max_length=200, verbose_name="标题")

    # 文章内容（长文本）
    content = models.TextField(verbose_name="内容")

    # 创建时间（自动设为当前时间）
    created_date = models.DateTimeField(
        default=timezone.now, verbose_name="创建时间"
    )

    # 是不是已经发布（草稿 vs 正式发布）
    is_published = models.BooleanField(default=True, verbose_name="发布")

    class Meta:
        ordering = ["-created_date"]  # 最新的文章排最前面
        verbose_name = "文章"
        verbose_name_plural = "文章"

    def __str__(self):
        return self.title

    def summary(self):
        """返回文章摘要（前 120 个字符）"""
        if len(self.content) > 120:
            return self.content[:120] + "..."
        return self.content
