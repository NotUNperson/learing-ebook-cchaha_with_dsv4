"""
03-08 综合练习：简易通讯录
综合使用：字典 + 函数 + while 循环 + if 判断
实现一个命令行交互式通讯录
"""

# ============================================================
# 全局变量：用一个字典存储所有联系人
# ============================================================
contacts = {}  # 格式：{"姓名": "电话号码", ...}


# ============================================================
# 功能函数
# ============================================================
def show_menu():
    """显示操作菜单"""
    print("\n" + "=" * 30)
    print("       简易通讯录")
    print("=" * 30)
    print("  1. 查看所有联系人")
    print("  2. 添加联系人")
    print("  3. 查找联系人")
    print("  4. 删除联系人")
    print("  5. 退出")
    print("=" * 30)


def show_all():
    """显示所有联系人"""
    print("\n--- 所有联系人 ---")
    if not contacts:  # 如果字典是空的
        print("  (通讯录为空)")
        return

    # 遍历字典，显示所有的姓名和电话
    for name, phone in contacts.items():
        print(f"  {name}: {phone}")

    print(f"  共 {len(contacts)} 个联系人")


def add_contact():
    """添加联系人"""
    print("\n--- 添加联系人 ---")
    name = input("请输入姓名: ").strip()

    # 检查是否为空
    if not name:
        print("姓名不能为空！")
        return

    # 检查是否已存在
    if name in contacts:
        confirm = input(f"'{name}' 已存在，是否覆盖？(y/n): ")
        if confirm.lower() != "y":
            print("已取消添加。")
            return

    phone = input("请输入电话号码: ").strip()
    if not phone:
        print("电话号码不能为空！")
        return

    contacts[name] = phone
    print(f"已添加 {name}: {phone}")


def search_contact():
    """查找联系人"""
    print("\n--- 查找联系人 ---")
    name = input("请输入要查找的姓名: ").strip()

    # 用 get() 安全查询
    phone = contacts.get(name)
    if phone is not None:
        print(f"找到 {name}: {phone}")
    else:
        print(f"查无此人: '{name}'")


def delete_contact():
    """删除联系人"""
    print("\n--- 删除联系人 ---")
    name = input("请输入要删除的姓名: ").strip()

    if name in contacts:
        phone = contacts.pop(name)  # 删除并获取被删除的值
        print(f"已删除 {name}: {phone}")
    else:
        print(f"查无此人: '{name}'")


# ============================================================
# 预设一些示例联系人（方便测试）
# ============================================================
def add_sample_contacts():
    """添加一些示例数据，方便测试"""
    contacts["张三"] = "13800138001"
    contacts["李四"] = "13800138002"
    contacts["王五"] = "13800138003"


# ============================================================
# 主程序
# ============================================================
def main():
    """主程序：显示菜单，循环等待用户操作"""
    add_sample_contacts()

    while True:
        show_menu()
        choice = input("请选择操作 (1-5): ").strip()

        if choice == "1":
            show_all()

        elif choice == "2":
            add_contact()

        elif choice == "3":
            search_contact()

        elif choice == "4":
            delete_contact()

        elif choice == "5":
            print("\n谢谢使用通讯录，再见！")
            break  # 退出 while 循环

        else:
            print("输入错误！请输入 1-5 之间的数字。")

        # 小提示：按回车继续
        if choice in ("1", "2", "3", "4"):
            input("\n按回车键继续...")


# 程序入口
if __name__ == "__main__":
    main()
