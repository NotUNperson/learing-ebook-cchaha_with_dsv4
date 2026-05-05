"""
04-01 类与对象的思想示例
演示"面向过程 vs 面向对象"两种写法的区别
不要求完全看懂代码，先感受一下两种思路的不同
"""

print("=" * 50)
print("例子：管理学生的成绩信息")
print("=" * 50)

print()
print("--- 写法一：面向过程（你之前一直用的方式）---")
print()

# 数据和操作数据的代码是分开的
# 数据就是普通的变量
name1 = "张三"
score1 = 92
name2 = "李四"
score2 = 78

# 操作数据的代码是独立的函数
def show_score(name, score):
    """打印学生的成绩"""
    if score >= 90:
        level = "优秀"
    elif score >= 70:
        level = "良好"
    else:
        level = "加油"
    print(f"  {name}: {score} 分 ({level})")

# 调用函数来处理数据
show_score(name1, score1)
show_score(name2, score2)

# 面向过程的问题：
# 1. name1 和 score1 虽然都属于张三，但它们是分开的变量
# 2. 你可以不小心写成 show_score(name1, score2)，把张三的名字和李四的分数拼在一起
# 3. 如果以后要给每个学生加"年龄""班级"，你需要改很多地方


print()
print("--- 写法二：面向对象（把数据和行为打包在一起）---")
print()


# 定义一个类 -- 就像做饼干的模具
class Student:
    """
    学生类：定义了学生是什么、能做什么
    就像模具定义了饼干的形状
    """

    def __init__(self, name, score):
        """初始化方法：创建学生时自动执行，就像饼干从模具里压出来"""
        self.name = name      # 学生的姓名
        self.score = score    # 学生的分数

    def show_score(self):
        """学生自己汇报成绩 -- 数据和行为在一起"""
        if self.score >= 90:
            level = "优秀"
        elif self.score >= 70:
            level = "良好"
        else:
            level = "加油"
        print(f"  {self.name}: {self.score} 分 ({level})")


# 创建对象 -- 就像用模具做出具体的饼干
student1 = Student("张三", 92)  # 这一块叫"张三"，92分
student2 = Student("李四", 78)  # 这一块叫"李四"，78分

# 让对象自己做事情
student1.show_score()  # 告诉 student1："汇报你的成绩"
student2.show_score()  # 告诉 student2："汇报你的成绩"

# 面向对象的优势：
# 1. 张三的名字和分数打包在一起，不会搞混
# 2. student1.show_score() 自己知道自己的数据，不用你操心传参
# 3. 以后要加属性（比如年龄），只在类里加一次就行

print()
print("--- 类比总结 ---")
print("  类(class)    = 饼干模具：定义形状")
print("  对象(object)  = 饼干：模具做出来的实物，每块独立")
print("  属性(attribute) = 饼干的口味、大小")
print("  方法(method)    = 饼干可以被吃、被包装")
