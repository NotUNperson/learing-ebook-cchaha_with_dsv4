# -*- coding: utf-8 -*-
"""
08-07 综合练习：下载图片并保存
===============================
综合运用 requests + pathlib + datetime 做一个图片下载器。

核心功能：
1. 从 URL 下载图片二进制数据
2. 自动创建日期子目录（downloads/2026-04-30/）
3. 从 URL 提取文件名
4. 打印下载摘要（状态码、文件大小、保存路径、耗时）
"""

import requests
from pathlib import Path
from datetime import datetime
import time


def download_image(url, save_dir="downloads"):
    """
    下载一张图片到本地。

    参数:
        url: 图片的 URL 地址
        save_dir: 保存的根目录（默认为 "downloads"）

    返回:
        保存后的文件路径（Path 对象），失败返回 None
    """
    print(f"\n开始下载: {url}")

    # ---- 1. 准备保存目录（按日期归档） ----
    today = datetime.now().strftime("%Y-%m-%d")
    target_dir = Path(save_dir) / today
    target_dir.mkdir(parents=True, exist_ok=True)
    # parents=True: 如果父目录不存在则一并创建
    # exist_ok=True: 如果目录已存在也不报错

    # ---- 2. 从 URL 中提取文件名 ----
    # URL 格式: https://example.com/path/to/photo.jpg?size=large
    # 第一步：用 / 分割取最后一段 → "photo.jpg?size=large"
    # 第二步：用 ? 分割取第一部分 → "photo.jpg"
    filename = url.split("/")[-1].split("?")[0]

    # 如果 URL 中没有合适的文件名，自己生成一个
    if not filename or "." not in filename:
        timestamp = datetime.now().strftime("%H%M%S")
        filename = f"image_{timestamp}.jpg"

    filepath = target_dir / filename

    # ---- 3. 检查是否已存在 ----
    if filepath.exists():
        print(f"  文件已存在: {filepath.name}")
        # 生成不重复的文件名
        stem = filepath.stem
        suffix = filepath.suffix
        for i in range(1, 100):
            new_name = f"{stem}_{i}{suffix}"
            filepath = target_dir / new_name
            if not filepath.exists():
                print(f"  使用新文件名: {filepath.name}")
                break

    # ---- 4. 下载图片 ----
    start_time = time.time()

    try:
        # timeout=30: 如果 30 秒内没响应就放弃
        response = requests.get(url, timeout=30)
        response.raise_for_status()   # 检查 HTTP 状态码（4xx/5xx 会抛异常）

        # 检查返回的内容类型是否是图片
        content_type = response.headers.get("Content-Type", "")
        if "image" not in content_type:
            print(f"  警告: Content-Type 是 '{content_type}'，可能不是图片文件")
            print(f"  但仍然会尝试保存...")

        # 用二进制模式 ("wb") 写入文件
        with open(filepath, "wb") as f:
            f.write(response.content)

        elapsed = time.time() - start_time
        file_size = len(response.content)

        # ---- 5. 打印下载摘要 ----
        print(f"\n  下载成功！")
        print(f"  状态码: {response.status_code}")
        print(f"  Content-Type: {content_type}")
        print(f"  文件大小: {file_size} 字节 ({file_size/1024:.1f} KB)")
        print(f"  保存路径: {filepath.resolve()}")
        print(f"  耗时: {elapsed:.2f} 秒")

        return filepath

    except requests.exceptions.Timeout:
        print(f"  下载失败: 请求超时（30 秒）")
        return None
    except requests.exceptions.ConnectionError:
        print(f"  下载失败: 无法连接到服务器，请检查 URL 和网络")
        return None
    except requests.exceptions.HTTPError as e:
        print(f"  下载失败: HTTP 错误 - {e}")
        return None
    except Exception as e:
        print(f"  下载失败: 未知错误 - {e}")
        return None


def download_images_batch(url_file, save_dir="downloads"):
    """
    从文件中读取 URL 列表，批量下载。

    参数:
        url_file: 包含 URL 的文件路径（每行一个 URL）
        save_dir: 保存目录
    """
    url_path = Path(url_file)

    if not url_path.exists():
        print(f"URL 文件不存在: {url_file}")
        return

    urls = [
        line.strip()
        for line in url_path.read_text(encoding="utf-8").split("\n")
        if line.strip() and not line.strip().startswith("#")
    ]

    print(f"从 {url_file} 读取到 {len(urls)} 个 URL")

    success = 0
    for i, url in enumerate(urls, 1):
        print(f"\n[{i}/{len(urls)}]", end="")
        result = download_image(url, save_dir)
        if result:
            success += 1
        if i < len(urls):
            time.sleep(1)  # 礼貌地等待 1 秒再请求下一个

    print(f"\n批量下载完成: {success}/{len(urls)} 成功")


# =====================================================
#  主程序入口
# =====================================================

if __name__ == "__main__":
    print("=" * 50)
    print("图片下载器演示")
    print("=" * 50)

    # ---- 示例 1: 下载一张图片 ----
    print("\n【示例 1】下载 Python 官方 Logo:")
    url1 = "https://www.python.org/static/img/python-logo.png"
    result1 = download_image(url1)

    # ---- 示例 2: 下载另一张图片 ----
    print("\n【示例 2】下载一张测试图片:")
    # 这是一个 200x150 的占位图片
    url2 = "https://picsum.photos/200/150"
    result2 = download_image(url2)

    # ---- 示例 3: 同一张图片再下载一次（测试防重名） ----
    print("\n【示例 3】再次下载同一张图片（测试防重名）:")
    if result1:
        download_image(url1)

    # ---- 查看下载目录 ----
    print("\n" + "=" * 50)
    print("下载目录结构:")
    print("=" * 50)

    download_root = Path("downloads")
    if download_root.exists():
        for date_dir in sorted(download_root.iterdir()):
            if date_dir.is_dir():
                print(f"\n  {date_dir.name}/")
                for file in sorted(date_dir.iterdir()):
                    size_kb = file.stat().st_size / 1024
                    print(f"    {file.name} ({size_kb:.1f} KB)")

    print("\n演示完毕！")
