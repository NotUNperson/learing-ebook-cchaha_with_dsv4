# A.15 数组常用方法

## 本节你会学到什么

- `map` -- 每个元素加工后返回新数组（流水线）
- `filter` -- 筛选符合条件的元素
- `reduce` -- 归并（sum/avg/统计等），最难但要讲清楚
- `find` -- 找到第一个符合条件的元素
- `some` / `every` -- 存在/全部符合条件的判断
- 这些方法都接受回调函数（函数是一等公民的体现）
- 链式调用：`arr.filter().map()`

## 正文

### 一、`map` -- 流水线加工

`map` 对数组中的每个元素调用一个函数，用返回值组成一个新数组。**不改变原数组**。

> 生活类比：`map` 就像一条流水线。每个产品经过流水线时都被加工一次，最后出来的都是加工后的产品。

```javascript
const numbers = [1, 2, 3, 4, 5];

// 每个数字乘以 2
const doubled = numbers.map(function(n) {
    return n * 2;
});
console.log(doubled);  // [2, 4, 6, 8, 10]

// 箭头函数更简洁
const squared = numbers.map(n => n * n);
console.log(squared);  // [1, 4, 9, 16, 25]

// 提取对象数组中的某个属性
const users = [
    { name: "小明", age: 20 },
    { name: "小红", age: 22 },
    { name: "小刚", age: 18 }
];
const names = users.map(user => user.name);
console.log(names);  // ["小明", "小红", "小刚"]
```

`map` 的回调函数接收三个参数：`(当前元素, 当前索引, 原数组)`：

```javascript
const withIndex = numbers.map((n, i) => `[${i}] ${n}`);
console.log(withIndex);  // ["[0] 1", "[1] 2", "[2] 3", "[3] 4", "[4] 5"]
```

### 二、`filter` -- 筛选

`filter` 返回一个**通过测试**的元素组成的新数组。**不改变原数组**。

> 生活类比：`filter` 就像一个筛子——符合条件的留下，不符合的漏下去。

```javascript
const numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// 筛选偶数
const evens = numbers.filter(n => n % 2 === 0);
console.log(evens);  // [2, 4, 6, 8, 10]

// 筛选大于 5 的数
const big = numbers.filter(n => n > 5);
console.log(big);   // [6, 7, 8, 9, 10]

// 筛选数组中的对象
const adults = users.filter(user => user.age >= 18);
console.log(adults);  // 所有 age >= 18 的用户对象
```

### 三、`reduce` -- 归并（最难但最重要）

`reduce` 把数组中的所有元素**归并**成一个值。它是所有数组方法中最强大的，也是最难理解的。

> 生活类比：`reduce` 就像滚雪球。你从一个初始的雪球（初始值）开始，滚过数组中的每个元素，雪球越滚越大，最后得到一个大的结果。

```javascript
// 语法：arr.reduce(callback, initialValue)
// callback(累计值, 当前元素, 当前索引, 原数组)

const numbers = [1, 2, 3, 4, 5];

// 求和：从 0 开始，每次加上当前元素
const sum = numbers.reduce(function(acc, n) {
    return acc + n;
}, 0);
console.log(sum);  // 15

// 用箭头函数
const sumArrow = numbers.reduce((acc, n) => acc + n, 0);
console.log(sumArrow);  // 15
```

**逐步拆解 `reduce` 的执行过程**：

| 迭代 | acc（累加值） | n（当前元素） | 返回值 acc + n |
|------|-------------|-------------|---------------|
| 初始（initialValue） | 0 | - | - |
| 第 1 次 | 0 | 1 | 1 |
| 第 2 次 | 1 | 2 | 3 |
| 第 3 次 | 3 | 3 | 6 |
| 第 4 次 | 6 | 4 | 10 |
| 第 5 次 | 10 | 5 | **15** |

**`reduce` 的其他用途**：

```javascript
// 求乘积
const product = numbers.reduce((acc, n) => acc * n, 1);
console.log(product);  // 120

// 求最大值
const max = numbers.reduce((acc, n) => n > acc ? n : acc, -Infinity);
console.log(max);  // 5

// 统计元素出现次数
const items = ["苹果", "香蕉", "苹果", "橙子", "香蕉", "苹果"];
const countMap = items.reduce((acc, item) => {
    acc[item] = (acc[item] || 0) + 1;
    return acc;
}, {});
console.log(countMap);  // { 苹果: 3, 香蕉: 2, 橙子: 1 }

// 展平二维数组
const nested = [[1, 2], [3, 4], [5, 6]];
const flat = nested.reduce((acc, row) => acc.concat(row), []);
console.log(flat);  // [1, 2, 3, 4, 5, 6]
```

> 如果不传初始值，`reduce` 会用数组的第一个元素作为初始值，从第二个元素开始归并。

### 四、`find` -- 找到第一个

`find` 返回**第一个**符合条件的元素，找不到返回 `undefined`。

```javascript
const numbers = [10, 20, 30, 40, 50];

const found = numbers.find(n => n > 25);
console.log(found);  // 30（第一个大于 25 的）

const notFound = numbers.find(n => n > 100);
console.log(notFound);  // undefined
```

还有一个 `findIndex`，返回索引而不是值：

```javascript
console.log(numbers.findIndex(n => n > 25));  // 2
console.log(numbers.findIndex(n => n > 100)); // -1
```

### 五、`some` 和 `every` -- 存在/全体的判断

**`some`**：至少有一个元素符合条件就返回 `true`。没有符合条件的返回 `false`。

**`every`**：所有元素都符合条件才返回 `true`。有一个不符合就返回 `false`。

```javascript
const scores = [85, 92, 78, 60, 95];

// some：有人的成绩 >= 90 吗？
console.log(scores.some(s => s >= 90));  // true

// every：所有人的成绩都 >= 60 吗？
console.log(scores.every(s => s >= 60)); // true

// every：所有人的成绩都 >= 80 吗？
console.log(scores.every(s => s >= 80)); // false
```

> 生活类比：`some` 就像"这门课有人满分吗？"——只要有一个就行。`every` 就像"全班都及格了吗？"——得每个人都满足才行。

### 六、链式调用 -- 组合使用

因为这些方法都返回数组（除了 `reduce`、`find`、`some`、`every`），你可以把它们链在一起：

```javascript
const students = [
    { name: "小明", score: 85 },
    { name: "小红", score: 92 },
    { name: "小刚", score: 45 },
    { name: "小丽", score: 78 },
    { name: "小华", score: 60 }
];

// 链式调用：筛选及格 -> 提取名字 -> 转大写
const passedNames = students
    .filter(s => s.score >= 60)       // 筛选及格
    .map(s => s.name)                  // 提取名字
    .filter(name => name.length > 1)   // 名字长度 > 1
    .map(name => name.toUpperCase());  // 转大写

console.log(passedNames);  // ["小明", "小红", "小丽", "小华"]
```

链式调用的美：每一步做一件事，读起来像"流水账"一样清晰。这比嵌套 for 循环优雅得多。

### 七、方法速查表

| 方法 | 输入 | 输出 | 是否改变原数组 |
|------|------|------|--------------|
| `map` | 回调 | 新数组（每个元素都被加工） | 否 |
| `filter` | 回调 | 新数组（符合条件的元素） | 否 |
| `reduce` | 回调 + 初始值 | 单个值 | 否 |
| `find` | 回调 | 第一个符合条件的元素 | 否 |
| `findIndex` | 回调 | 第一个符合条件的索引 | 否 |
| `some` | 回调 | `true` / `false` | 否 |
| `every` | 回调 | `true` / `false` | 否 |

关键点：**除了 `reduce` 需要传两个参数，其他方法都只接收一个回调函数参数。**

---

## 动手试试

1. 有一个数组 `[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]`，用 `map` + `filter` 链式调用：先筛选奇数，再乘以 3，再筛选大于 10 的数。
2. 用 `reduce` 计算一个数组的最大值和最小值的差（max - min）。
3. 写一个 `groupBy(arr, keyFn)` 函数，用 `reduce` 对数组按条件分组（比如按用户的年龄分组）。

---

## 与 C 语言的对比

C 语言没有 `map`、`filter`、`reduce` 这类高阶方法。你要实现同样的功能，必须手写循环+条件判断。一个"将所有元素乘以 2 后取大于 5 的值"的操作，在 C 中需要：遍历 → 判断 → 存临时数组；在 JS 中只需 `.map(n => n * 2).filter(n => n > 5)`。这种**声明式编程**风格让代码意图更清晰，bug 更少。这些方法接受回调函数的设计，正是"函数是一等公民"概念的直接应用。

---

## 本节小结

- `map`：每个元素加工，返回新数组（流水线）
- `filter`：筛选符合条件的元素（筛子）
- `reduce`：归并成一个值（滚雪球），最难但最强大
- `find`：找到第一个符合条件的元素
- `some`/`every`：存在/全体的布尔判断
- 链式调用：`arr.filter().map()` 风格优雅清晰
- 所有这些方法都不改变原数组

---

## 下一节预告

至此，A 篇 1-15 节完结。你已经掌握了 JS 语言核心的所有基础知识：变量、类型、运算符、分支、循环、函数（声明/表达式/箭头）、作用域与闭包、字符串操作、数组操作。下一节（A.16）将进入对象（Object）的世界——这是 JS 中最基础也最重要的数据结构。之后还有原型链、class、异步编程等高级内容在等着你。
