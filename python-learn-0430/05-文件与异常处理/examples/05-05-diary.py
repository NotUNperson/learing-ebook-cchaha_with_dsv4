"""
05-05 综合练习：个人日记本
综合运用：函数 + 字典 + 文件读写 + 异常处理 + 循环 + 菜单交互
"""

import os

# 日记文件名
DIARY_FILE = "my_diary.txt"


# ============================================================
# 文件操作函数
# ============================================================
def load_diary():
    """
    从文件加载日记到字典
    返回格式: {"2024-04-28": "日记内容...", "2024-04-29": "日记内容..."}
    如果文件不存在，返回空字典
    """
    diary = {}
    try:
        with open(DIARY_FILE, "r", encoding="utf-8") as f:
            current_date = None
            current_lines = []

            for line in f:
                line = line.rstrip("\n")
                # 检查是否是日期分隔行 === YYYY-MM-DD ===
                if line.startswith("=== ") and line.endswith(" ==="):
                    # 保存上一段日记
                    if current_date and current_lines:
                        diary[current_date] = "\n".join(current_lines)

                    # 提取新日期
                    current_date = line[4:-4].strip()
                    current_lines = []
                else:
                    # 跳过空行（日记之间的分隔空行）
                    if current_date is not None:
                        current_lines.append(line)

            # 保存最后一段日记
            if current_date and current_lines:
                diary[current_date] = "\n".join(current_lines)

    except FileNotFoundError:
        # 日记文件不存在，没有关系，返回空字典
        pass

    return diary


def save_diary(diary):
    """把日记字典存入文件"""
    with open(DIARY_FILE, "w", encoding="utf-8") as f:
        # 按日期排序写入
        for date in sorted(diary.keys()):
            f.write(f"=== {date} ===\n")
            f.write(diary[date] + "\n\n")


# ============================================================
# 菜单功能函数
# ============================================================
def show_menu():
    """显示主菜单"""
    print("\n" + "=" * 30)
    print("       我的日记本")
    print("=" * 30)
    print("  1. 写日记")
    print("  2. 查看所有日记")
    print("  3. 按日期查看")
    print("  4. 删除日记")
    print("  5. 保存并退出")
    print("=" * 30)


def write_entry(diary):
    """写一篇新日记"""
    print("\n--- 写日记 ---")
    # 获取当前日期（也可以让用户自己输入）
    from datetime import date
    today = str(date.today())
    print(f"今天的日期: {today}")

    use_today = input("使用今天的日期? (直接回车=是, 输入新日期=自定义): ").strip()
    if use_today:
        date_key = use_today
    else:
        date_key = today

    # 检查日期是否已有日记
    if date_key in diary:
        print(f"\n  {date_key} 已有日记:")
        print(f"  {'-' * 20}")
        print(f"  {diary[date_key]}")
        print(f"  {'-' * 20}")
        overwrite = input("  是否覆盖? (y/n): ").strip().lower()
        if overwrite != "y":
            print("  已取消。")
            return

    print("\n请输入日记内容（输入 END 结束）:")
    lines = []
    while True:
        line = input()
        if line.strip() == "END":
            break
        lines.append(line)

    if lines:
        diary[date_key] = "\n".join(lines)
        print(f"\n日记已保存到 {date_key}！")
    else:
        print("日记内容为空，已取消。")


def show_all(diary):
    """显示所有日记的日期和预览"""
    print("\n--- 所有日记 ---")
    if not diary:
        print("  （日记本是空的）")
        return

    print(f"  共 {len(diary)} 篇日记:\n")
    for date in sorted(diary.keys()):
        # 显示日期的第一行作为预览
        first_line = diary[date].split("\n")[0]
        # 如果第一行太长就截断
        if len(first_line) > 30:
            first_line = first_line[:30] + "..."
        print(f"  [{date}] {first_line}")


def show_entry(diary):
    """显示指定日期的完整日记"""
    print("\n--- 查看日记 ---")
    if not diary:
        print("  （日记本是空的）")
        return

    # 先列出所有可用日期
    print("可用的日期:")
    dates = sorted(diary.keys())
    for i, d in enumerate(dates, 1):
        print(f"  {i}. {d}")

    choice = input("\n请输入日期（或编号）: ").strip()

    # 尝试解析为编号
    try:
        idx = int(choice) - 1
        if 0 <= idx < len(dates):
            date_key = dates[idx]
        else:
            print("编号超出范围！")
            return
    except ValueError:
        # 不是数字，当作日期字符串
        date_key = choice

    if date_key in diary:
        print(f"\n  === {date_key} ===")
        print(f"  {diary[date_key]}")
    else:
        print(f"没有找到日期 '{date_key}' 的日记。")


def delete_entry(diary):
    """删除指定日期的日记"""
    print("\n--- 删除日记 ---")
    if not diary:
        print("  （日记本是空的）")
        return

    # 列出所有日期
    dates = sorted(diary.keys())
    for i, d in enumerate(dates, 1):
        print(f"  {i}. {d}")

    choice = input("\n请输入要删除的日期（或编号）: ").strip()

    try:
        idx = int(choice) - 1
        if 0 <= idx < len(dates):
            date_key = dates[idx]
        else:
            print("编号超出范围！")
            return
    except ValueError:
        date_key = choice

    if date_key in diary:
        confirm = input(f"确认删除 {date_key} 的日记? (y/n): ").strip().lower()
        if confirm == "y":
            removed = diary.pop(date_key)
            print(f"已删除 {date_key} 的日记。")
            # 删除后立即保存
            save_diary(diary)
        else:
            print("已取消。")
    else:
        print(f"没有找到日期 '{date_key}' 的日记。")


# ============================================================
# 主程序
# ============================================================
def main():
    """主程序入口"""
    print("欢迎使用个人日记本！")

    # 加载已有日记
    diary = load_diary()
    if diary:
        print(f"已加载 {len(diary)} 篇日记。")

    while True:
        show_menu()
        choice = input("请选择操作 (1-5): ").strip()

        if choice == "1":
            write_entry(diary)
            # 每写一篇就自动保存，防止数据丢失
            save_diary(diary)

        elif choice == "2":
            show_all(diary)

        elif choice == "3":
            show_entry(diary)

        elif choice == "4":
            delete_entry(diary)

        elif choice == "5":
            save_diary(diary)
            print(f"\n日记已保存到 '{DIARY_FILE}'，再见！")
            break

        else:
            print("输入错误！请输入 1-5 之间的数字。")

        if choice in ("1", "2", "3", "4"):
            input("\n按回车键继续...")


if __name__ == "__main__":
    main()
