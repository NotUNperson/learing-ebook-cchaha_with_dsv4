"""
04-06 综合练习：图书管理系统
综合运用：类 + 对象 + 列表 + 方法 + 循环 + 菜单交互
"""


class Book:
    """书类：每本书有书名、作者和借出状态"""

    def __init__(self, title, author):
        self.title = title
        self.author = author
        self.is_borrowed = False  # True=已借出, False=在馆

    def borrow(self):
        """借出这本书"""
        if not self.is_borrowed:
            self.is_borrowed = True
            return True, f"《{self.title}》借出成功！"
        else:
            return False, f"《{self.title}》已经被借出了，暂时不能借。"

    def return_book(self):
        """归还这本书"""
        if self.is_borrowed:
            self.is_borrowed = False
            return True, f"《{self.title}》归还成功！"
        else:
            return False, f"《{self.title}》本来就在馆内，不需要归还。"

    def __str__(self):
        """打印对象时显示的字符串（类似 Java 的 toString）"""
        status = "【已借出】" if self.is_borrowed else "【在馆】"
        return f"《{self.title}》 {self.author} 著 {status}"


# ============================================================
# 管理功能函数
# ============================================================
def show_menu():
    """显示主菜单"""
    print("\n" + "=" * 40)
    print("        图书管理系统")
    print("=" * 40)
    print("  1. 添加书籍")
    print("  2. 查看所有书籍")
    print("  3. 借出书籍")
    print("  4. 归还书籍")
    print("  5. 搜索书籍")
    print("  6. 退出")
    print("=" * 40)


def add_book(library):
    """添加新书到图书馆"""
    print("\n--- 添加书籍 ---")
    title = input("请输入书名: ").strip()
    if not title:
        print("书名不能为空！")
        return

    author = input("请输入作者: ").strip()
    if not author:
        print("作者不能为空！")
        return

    book = Book(title, author)
    library.append(book)
    print(f"添加成功: {book}")


def show_all_books(library):
    """显示所有藏书"""
    print("\n--- 图书馆藏书 ---")
    if not library:
        print("  （图书馆里一本书都没有）")
        return

    print(f"  共 {len(library)} 本书:\n")
    for i, book in enumerate(library, 1):
        print(f"  {i}. {book}")


def borrow_book(library):
    """借出书籍"""
    print("\n--- 借出书籍 ---")
    if not library:
        print("  图书馆里还没有书！")
        return

    show_all_books(library)

    try:
        index = int(input("\n请输入要借的书的编号: ")) - 1
        if 0 <= index < len(library):
            book = library[index]
            success, msg = book.borrow()
            print(msg)
        else:
            print("编号超出范围！")
    except ValueError:
        print("请输入有效的数字！")


def return_book(library):
    """归还书籍"""
    print("\n--- 归还书籍 ---")
    if not library:
        print("  图书馆里还没有书！")
        return

    show_all_books(library)

    try:
        index = int(input("\n请输入要还的书的编号: ")) - 1
        if 0 <= index < len(library):
            book = library[index]
            success, msg = book.return_book()
            print(msg)
        else:
            print("编号超出范围！")
    except ValueError:
        print("请输入有效的数字！")


def search_books(library):
    """搜索书籍 -- 按书名或作者关键词搜索"""
    print("\n--- 搜索书籍 ---")
    if not library:
        print("  图书馆里还没有书！")
        return

    keyword = input("请输入搜索关键词: ").strip()
    if not keyword:
        print("关键词不能为空！")
        return

    # 遍历所有书，检查书名或作者是否包含关键词
    results = []
    for book in library:
        if keyword in book.title or keyword in book.author:
            results.append(book)

    if results:
        print(f"\n  找到 {len(results)} 本相关书籍:")
        for i, book in enumerate(results, 1):
            print(f"  {i}. {book}")
    else:
        print(f"  没有找到包含 '{keyword}' 的书籍。")


def add_sample_books(library):
    """添加一些示例数据，方便测试"""
    library.append(Book("西游记", "吴承恩"))
    library.append(Book("红楼梦", "曹雪芹"))
    library.append(Book("三国演义", "罗贯中"))
    library.append(Book("水浒传", "施耐庵"))


# ============================================================
# 主程序
# ============================================================
def main():
    """主程序入口"""
    library = []  # 用列表存储所有 Book 对象
    add_sample_books(library)

    while True:
        show_menu()
        choice = input("请选择操作 (1-6): ").strip()

        if choice == "1":
            add_book(library)

        elif choice == "2":
            show_all_books(library)

        elif choice == "3":
            borrow_book(library)

        elif choice == "4":
            return_book(library)

        elif choice == "5":
            search_books(library)

        elif choice == "6":
            print("\n谢谢使用图书管理系统，再见！")
            break

        else:
            print("输入错误！请输入 1-6 之间的数字。")

        if choice in ("1", "2", "3", "4", "5"):
            input("\n按回车键继续...")


if __name__ == "__main__":
    main()
