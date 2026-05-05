"""
============================================================
01-08 综合练习：成绩统计器
============================================================
用列表存储成绩，计算平均分、最高分、最低分、分差、排名。
综合运用模块 1 所学的数字、列表、变量、print 等知识。
"""

# ========== 第 1 步：准备数据 ==========
# 全班 10 位同学的成绩
scores = [85, 92, 78, 90, 88, 76, 95, 83, 91, 87]

print("全班成绩：", scores)

# ========== 第 2 步：基本统计 ==========
# sum() 求总和
total = sum(scores)

# len() 求人数
count = len(scores)

# 平均分 = 总分 / 人数
average = total / count

# max() 找最高分
highest = max(scores)

# min() 找最低分
lowest = min(scores)

# 分差 = 最高分 - 最低分
score_range = highest - lowest

# ========== 第 3 步：输出报告 ==========
print("\n" + "=" * 40)
print("           成 绩 统 计 报 告")
print("=" * 40)

print("  全班人数：", count, "人")
print("  总    分：", total)
print("  平均分  ：", round(average, 1))   # round() 保留一位小数
print("  最高分  ：", highest)
print("  最低分  ：", lowest)
print("  分    差：", score_range,
      "（最高和最低相差", score_range, "分）")

print("-" * 40)

# ========== 第 4 步：排名 ==========
# 先复制一份，以免打乱原列表
sorted_scores = scores.copy()        # .copy() 复制列表
sorted_scores.sort(reverse=True)     # 从高到低排序

print("  成绩排名（从高到低）：")
# 用索引打印前三名和后三名
for i in range(len(sorted_scores)):
    # 给前三名和后三名加上标记
    if i < 3:
        tag = "  [奖牌]"
    elif i >= len(sorted_scores) - 3:
        tag = "  [加油]"
    else:
        tag = ""
    print("    第", i + 1, "名：", sorted_scores[i], "分", tag)

print("=" * 40)

# ========== 第 5 步：加分项 —— 统计分数段 ==========
print("\n分数段统计：")

# 用 Python 内置方法 + 列表统计
above_90 = 0    # 90 分以上的人数
above_80 = 0    # 80-89 分
above_70 = 0    # 70-79 分
below_70 = 0    # 70 分以下

# 遍历成绩，逐个判断（下一个模块会学更优雅的方式）
for score in scores:
    if score >= 90:
        above_90 += 1
    elif score >= 80:
        above_80 += 1
    elif score >= 70:
        above_70 += 1
    else:
        below_70 += 1

print("  90 分以上：", above_90, "人", "=" * above_90)
print("  80-89 分：", above_80, "人", "=" * above_80)
print("  70-79 分：", above_70, "人", "=" * above_70)
print("  70 分以下：", below_70, "人", "=" * below_70)
