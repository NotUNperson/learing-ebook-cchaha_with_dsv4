"""
============================================================
02-03 while 循环
============================================================
while = "当……的时候，反复做……"
只要条件为 True，缩进的代码就一直执行。
一定要让条件最终变成 False，否则会死循环！
"""

print("========== 基本 while 循环 ==========")

count = 1
while count <= 5:
    print("第", count, "次循环")
    count = count + 1       # 计数器 +1，没有这行就是死循环！
print("循环结束！")

print("\n========== 倒计时 ==========")

timer = 5
print("倒计时开始：")
while timer > 0:
    print("  ", timer, "...")
    timer = timer - 1
print("时间到！")

print("\n========== 累加：1+2+3+...+10 ==========")

total = 0
n = 1
while n <= 10:
    total = total + n     # 每次把一个数加到总和里
    n = n + 1
print("1 到 10 的和是：", total)

print("\n========== 模拟自动贩卖机 ==========")
# 模拟：你投币买可乐，每瓶 3 元，你投了 10 元
balance = 10        # 余额
price = 3           # 单价
bottles = 0         # 买到的瓶数

while balance >= price:
    balance = balance - price     # 扣掉一瓶的钱
    bottles = bottles + 1         # 多了一瓶
    print("买了一瓶可乐，余额", balance, "元")

print("一共买了", bottles, "瓶，余额", balance, "元")

print("\n========== 计算奇数和 ==========")
# 计算 1 到 20 之间所有奇数的和
odd_sum = 0
n = 1
while n <= 20:
    odd_sum = odd_sum + n
    n = n + 2               # 跳过偶数：1,3,5,7...
print("1 到 20 奇数的和：", odd_sum)   # 100

print("\n========== 死循环演示（已保护） ==========")
# 下面展示一个"安全"的有限循环，模拟死循环的原理
i = 0
while i < 100:
    i = i + 1
    if i == 3:
        print("如果 while 条件永远不变成 False，这就是死循环")
        print("按 Ctrl+C 可以强制停止")
        break       # break 提前退出循环（下一节学）
