"""
============================================================
02-05 break 和 continue
============================================================
break    = 提前结束整个循环（下班了）
continue = 跳过本次循环，继续下一次（这盘菜不吃，下一盘）
"""

print("========== break —— 提前结束循环 ==========")

# 找到第一个能被 7 整除的数就停
print("找 50-100 之间第一个能被 7 整除的数：")
for num in range(50, 101):
    if num % 7 == 0:
        print("找到了：", num)
        break                      # 找到就停，不继续找了

print("\n翻找水果——找到就停：")
fruits = ["苹果", "香蕉", "橘子", "葡萄", "西瓜"]
for fruit in fruits:
    print("  正在翻：", fruit)
    if fruit == "橘子":
        print("  找到橘子了！停止翻找。")
        break

print("\n========== continue —— 跳过本次循环 ==========")

# 自助餐：跳过不喜欢的菜
print("吃自助餐：")
dishes = ["红烧肉", "苦瓜", "糖醋排骨", "青菜", "水煮鱼"]
for dish in dishes:
    if dish == "苦瓜":
        print("  ", dish, "→ 跳过！")
        continue
    if dish == "青菜":
        print("  ", dish, "→ 跳过！")
        continue
    print("  ", dish, "→ 好吃！")

print("\n只打印偶数（跳过奇数）：")
for i in range(1, 11):
    if i % 2 != 0:       # 奇数
        continue          # 跳过
    print(i, end=" ")    # 只打印偶数
print()

print("\n========== break 和 continue 对比 ==========")

print("break 的效果（到 5 停止）：")
for i in range(1, 11):
    if i == 5:
        break
    print(i, end=" ")
print("\n只打印到 4，5 后面的都没了")

print("continue 的效果（跳过 5）：")
for i in range(1, 11):
    if i == 5:
        continue
    print(i, end=" ")
print("\n5 被跳过了，但后面的都还在")

print("\n========== while True 中的 break ==========")

# 模拟一个简单的密码验证（这里用固定值模拟，不让用户真的输入）
print("模拟密码验证：")
attempts = ["123", "abc", "open", "xyz"]   # 模拟用户的 4 次输入
correct_password = "open"

for attempt in attempts:
    print("  尝试密码：", attempt)
    if attempt == correct_password:
        print("  密码正确！欢迎！")
        break
    else:
        print("  密码错误，再试一次")
