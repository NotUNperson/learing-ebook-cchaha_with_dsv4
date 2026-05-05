"""
============================================================
01-03 字符串的常用操作
============================================================
字符串自带的"工具箱"：len()、upper()、lower()、replace()、索引。
"""

# 1. len() —— 数字符串长度（空格也算一个字符！）
text = "Python 真好玩"
print("字符串：", text)
print("长度：", len(text), "个字符")   # 注意空格也算

print("Hello 的长度：", len("Hello"))
print("空字符串的长度：", len(""))      # 啥都没有，长度为 0

print("-" * 30)

# 2. upper() 和 lower() —— 大小写转换
word = "Hello Python"
print("原文：", word)
print("全大写：", word.upper())       # HELLO PYTHON
print("全小写：", word.lower())       # hello python
print("原文没变：", word)              # 原字符串不变！

# 中文不受影响
text_cn = "你好 World"
print("中文+英文混合：", text_cn.upper())   # 你好 WORLD

print("-" * 30)

# 3. replace() —— 替换文字
message = "我喜欢吃苹果，苹果很好吃"
print("原文：", message)
print("替换后：", message.replace("苹果", "橘子"))
# 第二个苹果也被替换了——replace() 会替换所有匹配的文字

print("单次替换：", message.replace("苹果", "橘子", 1))
# 第三个参数 1 表示只替换第一次出现的

print("-" * 30)

# 4. 索引 —— 取出字符串中某个位置的字符
# 索引从 0 开始！！
word = "Python"
#       012345
print("word =", word)
print("索引 0：", word[0])    # P —— 第 1 个字符
print("索引 1：", word[1])    # y —— 第 2 个字符
print("索引 2：", word[2])    # t —— 第 3 个字符
print("索引 5：", word[5])    # n —— 第 6 个字符（最后一个）

print("-" * 10)

# 负索引：从末尾倒着数
print("索引 -1（倒数第 1）：", word[-1])   # n
print("索引 -2（倒数第 2）：", word[-2])   # o
print("索引 -3（倒数第 3）：", word[-3])   # h

print("-" * 30)

# 5. 综合演示：字符串是不可变的
original = "Hello"
print("原始字符串：", original)
upper_version = original.upper()     # 生成新字符串
print("大写版本：", upper_version)
print("原始还是：", original)          # 没变！
# 所有字符串操作都"不破坏现场"——原字符串永远不变
