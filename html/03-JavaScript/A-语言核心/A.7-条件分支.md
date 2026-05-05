# A.7 条件分支

## 本节你会学到什么

- `if` / `else if` / `else` -- 和 C 几乎一样的条件分支
- `switch` / `case` -- JS 的 case 可以用字符串
- JS 的真值（truthy）和假值（falsy）完整讲解
- 假值只有 6 个：`false`, `0`, `""`, `null`, `undefined`, `NaN`
- 空对象 `{}` 和空数组 `[]` 是真值！和 C 完全不同

## 正文

### 一、if / else if / else

和 C 语言几乎一模一样，只有一个小区别：条件不需要用括号包裹（但写了也行）。

```javascript
let score = 85;

if (score >= 90) {
    console.log("优秀");
} else if (score >= 80) {
    console.log("良好");
} else if (score >= 60) {
    console.log("及格");
} else {
    console.log("不及格");
}
```

几点注意事项：
- 条件表达式只要有值就行，会自动转为布尔值
- 只有一行语句时，`{}` 可以省略（但不推荐，容易出 bug）
- 条件外面加括号 `(score >= 90)` 也可以，这是 C 程序员的习惯

### 二、真值和假值 -- JS 的核心概念

在 JS 中，`if` 的条件不要求是布尔值。任何值都可以放在条件位置，JS 会自动转为布尔值判断。

**假值（falsy）只有 6 个**：

```javascript
if (false)      {}  // 不执行
if (0)          {}  // 不执行
if (-0)         {}  // 不执行
if ("")         {}  // 不执行  空字符串
if (null)       {}  // 不执行
if (undefined)  {}  // 不执行
if (NaN)        {}  // 不执行
```

**除此以外的所有值都是真值（truthy）**，包括：

```javascript
if (true)       {}  // 执行
if (42)         {}  // 执行  非 0 数字
if (-1)         {}  // 执行  负数也是真
if ("hello")    {}  // 执行  非空字符串
if (" ")        {}  // 执行  含空格的字符串
if ("0")        {}  // 执行  字符串 "0" 不是数字 0
if ([])         {}  // 执行  空数组是真！← C 程序员可能会吃惊
if ({})         {}  // 执行  空对象是真！← 同样令人吃惊
if (() => {})   {}  // 执行  函数也是真
```

> 重点：空数组 `[]` 和空对象 `{}` 是真值。这和很多语言不同。在 C 语言中，空指针（NULL）是假的；在 JS 中，"空"的数组或对象是真值。

> 生活类比：假值就像是 6 个有"免检通行证"的人，其余所有人（包括那些"看起来没装东西的袋子"——空数组和空对象）都要被当做"有人"处理。

### 三、使用真值/假值简化代码

理解了真值/假值后，你可以写出更简洁的条件判断：

```javascript
// 传统写法
if (name !== "" && name !== null && name !== undefined) {
    console.log("name 有效:", name);
}

// 利用真值/假值简化
if (name) {
    console.log("name 有效:", name);
}
// 因为 null、undefined、"" 都是假值，name 为假时条件不执行

// 检查数组是否为空
let items = [];
// 错误写法：if (items) -- 空数组是真值！
// 正确写法：
if (items.length > 0) {
    console.log("有内容");
} else {
    console.log("数组为空");
}
```

### 四、switch / case

和 C 语言基本相同，但有一个大改进：**JS 的 case 可以使用字符串**。

```javascript
let fruit = "apple";

switch (fruit) {
    case "apple":
        console.log("这是苹果");
        break;
    case "banana":
        console.log("这是香蕉");
        break;
    case "orange":
        console.log("这是橙子");
        break;
    default:
        console.log("未知水果");
}
```

switch 的工作机制：
1. 计算 `switch` 后面括号里的表达式
2. 用 `===` 严格相等去匹配每个 `case` 的值
3. 找到匹配的 case 后，执行其中的代码
4. 遇到 `break` 跳出，否则会"穿透"到下一个 case（和 C 一样）

**穿透（fall-through）** 是 switch 的经典特性，有时候可以用它来合并多个 case：

```javascript
let day = 3;
switch (day) {
    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
        console.log("工作日");
        break;
    case 6:
    case 7:
        console.log("周末");
        break;
    default:
        console.log("无效的星期");
}
```

> 注意：忘了写 `break` 是 switch 最常见的 bug。JS 不会警告你，会一路执行下去。

### 五、if-else vs switch -- 什么时候用哪个

- **if-else**：条件比较复杂（如范围判断 `score >= 90`）
- **switch**：单个值和多个固定值比较（如 `fruit === "apple"`）

选择更清晰的那个即可，没有硬性规定。

---

## 动手试试

1. 写一个 if-else 判断一个数是正数、负数还是零。
2. 测试几个"你认为可能是假值但实际不是"的值（如空数组 `[]`，含空格的字符串 `" "`），用 `if` 验证。
3. 用 `switch` 判断今天是周几（用数字 0-6 代表周日到周六），打印对应的中文名称。
4. 故意在一个 switch 中漏掉一个 `break`，看看"穿透"效果是什么样的。

---

## 与 C 语言的对比

`if-else` 和 `switch-case` 的语法和 C 基本完全一致。核心区别有两个：第一，JS 的 `switch` 可以用**字符串**作为 case 值，C 语言只支持整数类型。第二，C 语言中 `if (x)` 只在 x 为非 0 时执行，JS 中有更丰富的"真值/假值"概念（`[]`、`{}` 等都是真值）。另外，C 语言要求条件表达式必须是整数或指针，JS 则可以是任何类型。

---

## 本节小结

- `if / else if / else` 和 C 基本一样
- `switch / case` 和 C 类似，但 case 支持字符串
- 假值只有 6 个：`false`, `0`, `""`, `null`, `undefined`, `NaN`
- 空数组 `[]` 和空对象 `{}` 都是真值
- 利用真值/假值可以简化条件判断
- 别忘了在 switch 中写 `break`

---

## 下一节预告

有了分支，还需要循环来重复执行代码。下一节讲 JS 的循环：你熟悉的 `for`、`while`、`do-while`，以及 ES6 的 `for-of`（让你惊喜的语法）和 `for-in`。
