# A.8 循环

## 本节你会学到什么

- `for` 循环--经典三段式，和 C 一样
- `while` 和 `do-while` 循环
- `break` 和 `continue` -- 和 C 一模一样
- `for-of` 循环（ES6）-- 遍历数组值，让 C 程序员惊喜的语法
- `for-in` 循环--遍历对象属性键，**不要用来遍历数组**

## 正文

### 一、for 循环 -- 经典三段式

和 C 语言基本一样，三个表达式：初始化、条件、更新。

```javascript
// 和 C 完全一致的写法
for (let i = 0; i < 5; i++) {
    console.log("i =", i);
}
// 输出：0, 1, 2, 3, 4
```

三段式详解：
1. `let i = 0` -- 初始化，在循环开始前执行一次
2. `i < 5` -- 条件检查，每次迭代前检查，为 false 时退出循环
3. `i++` -- 更新，每次迭代结束后执行

```javascript
// 更复杂的例子：计算 1 到 100 的和
let sum = 0;
for (let i = 1; i <= 100; i++) {
    sum += i;
}
console.log("1 + 2 + ... + 100 =", sum);  // 5050
```

> 注意：JS 中 for 循环用 `let i = 0` 声明的 `i`，作用域只在循环内部。C 语言（C99 之前）在 for 里声明的变量可能逃逸到循环外面。

### 二、while 和 do-while

和 C 语言完全一样。

```javascript
// while：先检查条件，再执行
let count = 0;
while (count < 5) {
    console.log("count =", count);
    count++;
}

// do-while：先执行一次，再检查条件（至少执行一次）
let n = 0;
do {
    console.log("n =", n);
    n++;
} while (n < 3);
```

### 三、break 和 continue

和 C 语言完全一样：

- **`break`**：跳出整个循环
- **`continue`**：跳过本次循环的剩余代码，直接进入下一次迭代

```javascript
// break：找到目标后立即停止
for (let i = 0; i < 10; i++) {
    if (i === 5) {
        console.log("找到 5 了，停止搜索");
        break;
    }
    console.log("检查中:", i);
}

// continue：跳过偶数，只打印奇数
for (let i = 0; i < 10; i++) {
    if (i % 2 === 0) {
        continue;  // 偶数跳过
    }
    console.log(i);  // 只打印 1, 3, 5, 7, 9
}
```

### 四、for-of 循环 -- 遍历数组值（ES6）

这是 ES6 引入的语法，**让 C 程序员感到惊喜**。它可以直接遍历数组的每一个**元素值**：

```javascript
let fruits = ["苹果", "香蕉", "橙子", "葡萄"];

// 传统 for（需要操作索引）
for (let i = 0; i < fruits.length; i++) {
    console.log(fruits[i]);
}

// for-of（直接拿到值，不需要索引！）
for (let fruit of fruits) {
    console.log(fruit);
}
// 输出：苹果、香蕉、橙子、葡萄
```

> 生活类比：传统 `for` 循环像是按门牌号去找人（"101 室是谁？102 室是谁？"），`for-of` 则是直接把每个人都请出来见一面（"下一个是谁？"）。

`for-of` 还可以遍历字符串（每个字符）：

```javascript
for (let char of "Hello") {
    console.log(char);
}
// 输出：H, e, l, l, o
```

> 注意：`for-of` 遍历的是**值**，而不是索引/下标。这个设计让 JS 更接近 Python 的 `for item in list`。

### 五、for-in 循环 -- 遍历对象属性键

`for-in` 用来遍历对象的**属性名（键）**。**不要用它来遍历数组**（虽然能跑，但会遍历出意想不到的东西）。

```javascript
let person = {
    name: "小明",
    age: 25,
    city: "北京"
};

for (let key in person) {
    console.log(key + ": " + person[key]);
}
// 输出：
// name: 小明
// age: 25
// city: 北京
```

为什么不要用 `for-in` 遍历数组？

```javascript
let arr = [10, 20, 30];
arr.customProp = "hello";  // 给数组添加了一个自定义属性

// for-of：只遍历数组元素
for (let val of arr) {
    console.log(val);  // 10, 20, 30  （正确的）
}

// for-in：把自定义属性也遍历出来了！
for (let key in arr) {
    console.log(key, arr[key]);  // "0" 10, "1" 20, "2" 30, "customProp" "hello"
}
```

结论：**遍历数组值用 `for-of`，遍历对象属性用 `for-in`。**

### 六、循环选择指南

| 场景 | 推荐循环 |
|------|----------|
| 知道循环次数 | `for` |
| 条件未知，依赖某条件 | `while` |
| 至少执行一次 | `do-while` |
| 遍历数组元素值 | `for-of` |
| 遍历对象属性 | `for-in` |

---

## 动手试试

1. 用 `for` 循环打印九九乘法表（和 C 语言作业一样）。
2. 用 `for-of` 遍历一个数组，打印出所有长度大于 3 的字符串。
3. 写一个 `while` 循环，从一个数字开始不断除以 2，直到结果小于 1，打印每一步的值。
4. 分别用 `for-of` 和 `for-in` 遍历同一个数组，对比输出有什么不同。

---

## 与 C 语言的对比

`for`、`while`、`do-while`、`break`、`continue` 的语法和 C 完全一致。主要区别是：(1) JS 用 `let i` 声明的循环变量作用域只在循环内部，而 C 语言（C99 之前）可能逸出；(2) JS 没有 C 语言的 `goto` 语句（谢天谢地）；(3) JS 有 `for-of` 和 `for-in`，C 语言所有的数组/列表遍历都要靠索引。`for-of` 是 C 程序员应该重点采纳的新习惯。

---

## 本节小结

- `for`、`while`、`do-while` 和 C 一样
- `break` 跳出循环，`continue` 跳过本次迭代
- `for-of` 遍历数组值，简洁好用（推荐！）
- `for-in` 遍历对象属性键，别用来遍历数组
- 数组遍历优先用 `for-of`

---

## 下一节预告

循环的兄弟是函数——把代码打包成可重复使用的模块。下一节开始讲 JS 的函数：函数声明、函数表达式，以及 JS 中最重要的概念之一——函数是一等公民。
