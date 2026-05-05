"""
============================================================
02-06 综合练习：猜数字游戏
============================================================
综合运用：变量、print、input、if-elif-else、
while 循环、break、import、random。

游戏规则：计算机想一个 1-100 的随机数，你来猜。
每猜一次告诉你"大了"还是"小了"，直到猜对。
"""

import random

# ========== 游戏设置 ==========
MIN_NUMBER = 1          # 最小数字
MAX_NUMBER = 100        # 最大数字
MAX_GUESSES = 7         # 最多猜几次（设为 7 次）

# ========== 生成随机数 ==========
secret = random.randint(MIN_NUMBER, MAX_NUMBER)
# randint(a, b) 返回 a 到 b 之间的随机整数（包含 a 和 b）

print("=" * 50)
print("         猜 数 字 游 戏")
print("=" * 50)
print("我想了一个", MIN_NUMBER, "到", MAX_NUMBER, "之间的数字")
print("你有", MAX_GUESSES, "次机会，试试看吧！")
print("-" * 50)

# ========== 游戏主循环 ==========
guess_count = 0         # 已猜次数

while guess_count < MAX_GUESSES:
    # 获取玩家输入
    # input() 返回的是字符串，用 int() 转换成整数
    try:
        guess = int(input("请输入你猜的数字："))
    except ValueError:
        print("请输入一个有效的整数！")
        continue        # 输入不合法，不消耗次数，跳过本次

    guess_count = guess_count + 1

    # 判断结果
    if guess < MIN_NUMBER or guess > MAX_NUMBER:
        print("数字要在", MIN_NUMBER, "到", MAX_NUMBER, "之间哦")
        print("剩余次数：", MAX_GUESSES - guess_count)
    elif guess == secret:
        print("\n★ 恭喜你，猜对了！★")
        print("答案就是", secret)
        print("你一共猜了", guess_count, "次")
        # 根据次数给出评价
        if guess_count == 1:
            print("评价：你是神仙吧？一次就中！")
        elif guess_count <= 3:
            print("评价：运气不错！")
        elif guess_count <= 5:
            print("评价：还行，正常水平。")
        else:
            print("评价：险胜！下次加油。")
        break       # 猜对了，退出循环
    elif guess > secret:
        print("X 猜大了，往小一点想想")
    else:
        print("X 猜小了，往大一点想想")

    # 显示剩余次数
    remaining = MAX_GUESSES - guess_count
    if remaining > 0:
        print("  剩余次数：", remaining)
    else:
        # 次数用完了
        print("\n( 很遗憾，次数用完了！")
        print("正确答案是：", secret)

print("=" * 50)
print("游戏结束，感谢游玩！")
