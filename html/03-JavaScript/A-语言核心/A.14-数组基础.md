# A.14 数组基础

## 本节你会学到什么

- 数组创建：`const arr = [];` 或 `new Array()`
- 索引访问 `arr[0]` 和 `length` 属性
- `length` 可修改：`arr.length = 0` 直接清空数组
- 遍历数组：`for`、`for-of`、`forEach`
- JS 数组可以存任意类型混合 -- 和 C 完全不同
- 多维数组（数组套数组）

## 正文

### 一、创建数组

JS 有两种创建数组的方式。推荐用字面量方式：

```javascript
// 字面量（推荐！）
const fruits = ["苹果", "香蕉", "橙子"];
const numbers = [1, 2, 3, 4, 5];
const empty = [];            // 空数组
const mixed = [1, "hello", true, null, {name: "小明"}];  // 混合类型

// 构造函数（了解即可）
const arr1 = new Array(3);       // 创建长度为 3 的空数组 [ , , ]
const arr2 = new Array(1, 2, 3); // [1, 2, 3]
// 注意：new Array(3) 创建的是 [empty × 3]，不是 [3]！
```

> 推荐用 `[]` 而不是 `new Array()`，因为 `new Array(3)` 的行为可能产生误解（它创建的是长度为 3 的空数组，不是一个包含数字 3 的数组）。

### 二、索引访问

和 C 语言类似，从 `0` 开始：

```javascript
const fruits = ["苹果", "香蕉", "橙子"];

console.log(fruits[0]);       // "苹果"
console.log(fruits[1]);       // "香蕉"
console.log(fruits[2]);       // "橙子"
console.log(fruits[3]);       // undefined（越界不报错！）
console.log(fruits[-1]);      // undefined（不支持 Python 的负数索引）

// 修改元素
fruits[1] = "草莓";
console.log(fruits);          // ["苹果", "草莓", "橙子"]
```

> JS 数组越界访问返回 `undefined`，不会像 C 语言一样导致程序崩溃或读到野值。这是 JS 的安全特性之一。

### 三、`length` 属性 -- 可读可写！

这是 JS 数组最神奇的特性之一——**`length` 属性不仅可以读取，还可以修改**。

```javascript
const arr = [1, 2, 3, 4, 5];
console.log(arr.length);  // 5

// 修改 length 可以截断数组
arr.length = 3;
console.log(arr);         // [1, 2, 3] -- 后面的元素被删除了！

// arr.length = 0 直接清空整个数组！
arr.length = 0;
console.log(arr);         // []
console.log(arr.length);  // 0

// 扩大 length 会创建"空位"
const arr2 = [1, 2];
arr2.length = 5;
console.log(arr2);        // [1, 2, <3 empty items>]
console.log(arr2[3]);     // undefined
```

> 在 C 语言中，数组大小是固定的（静态数组）或需要通过指针+计数来管理（动态数组）。JS 的 length 可动态修改，非常灵活。

### 四、遍历数组

JS 提供多种遍历数组的方式：

#### 方式 1：经典 `for` 循环（C 风格）

```javascript
const fruits = ["苹果", "香蕉", "橙子"];

for (let i = 0; i < fruits.length; i++) {
    console.log(`第 ${i} 个水果：${fruits[i]}`);
}
```

#### 方式 2：`for-of`（推荐！ES6）

```javascript
for (let fruit of fruits) {
    console.log(fruit);
}
// 苹果、香蕉、橙子
```

#### 方式 3：`forEach` 方法（函数式）

```javascript
fruits.forEach(function(fruit, index) {
    console.log(`${index}: ${fruit}`);
});

// 箭头函数更简洁
fruits.forEach((fruit, index) => {
    console.log(`${index}: ${fruit}`);
});
```

#### 方式 4：不要用 `for-in` 遍历数组！

```javascript
// 错误示范
for (let key in fruits) {
    console.log(key);  // "0", "1", "2" -- 输出的是字符串索引
}
```

### 五、数组和 C 语言的本质区别

C 语言的数组在内存中是**连续的、同类型的、固定大小的**。JS 的数组则完全不同：

```javascript
// JS 数组可以混合任意类型
const mixed = [
    42,                         // 数字
    "hello",                    // 字符串
    true,                       // 布尔值
    null,                       // null
    undefined,                  // undefined
    { name: "小明" },           // 对象
    [1, 2, 3],                  // 数组（嵌套）
    function() { return "hi"; } // 函数
];

console.log(mixed[6]);          // [1, 2, 3]
console.log(mixed[7]());        // "hi"
```

> 本质区别：JS 数组更像是一个 **"列表"**——它是一个对象，底层不一定像 C 那样是连续内存。它的元素可以是任意类型，大小可以动态变化。你可以把它理解为 C 语言里 `void*` 的链表加上索引访问。

### 六、多维数组

数组里套数组 = 多维数组（就像 C 语言的二维数组）：

```javascript
// 矩阵
const matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
];

console.log(matrix[0][0]);  // 1
console.log(matrix[1][2]);  // 6
console.log(matrix[2][1]);  // 8

// 遍历二维数组
for (let row of matrix) {
    for (let cell of row) {
        console.log(cell);  // 依次输出 1, 2, 3, ..., 9
    }
}
```

更高级的不规则多维数组（每一行长度可以不同）：

```javascript
const triangle = [
    [1],
    [2, 3],
    [4, 5, 6],
    [7, 8, 9, 10]
];

console.log(triangle[2][2]);  // 6
// 这在 C 语言中需要指针数组才能实现，JS 原生支持
```

---

## 动手试试

1. 创建一个包含 5 个数字的数组，打印 `length`，然后修改 `length` 为 3，观察变化。
2. 写一个函数 `createMatrix(rows, cols, initialValue)`，返回一个 rows x cols 的二维数组，所有元素都是 `initialValue`。
3. 创建一个包含不同数据类型的混合数组，用 `for-of` 遍历并打印每个元素的类型（`typeof`）。

---

## 与 C 语言的对比

C 语言的数组是连续内存中同类型元素的集合，大小固定（静态数组）或通过 malloc 动态分配。JS 的数组本质上是一个对象，底层是动态的，更像是一种"列表"。C 的数组越界访问会导致未定义行为（崩溃、读到脏数据），JS 的数组越界返回 `undefined`。C 的数组大小只能通过额外变量跟踪，JS 的 `length` 属性随时可读可写。C 的数组所有元素类型必须相同，JS 的数组可以混合任意类型。

---

## 本节小结

- 创建数组用 `[]` 字面量，推荐不用 `new Array()`
- 索引从 0 开始，越界返回 `undefined`
- `length` 属性可读可写，`arr.length = 0` 直接清空
- 遍历推荐：`for-of` > `forEach` > 经典 `for`。别用 `for-in`
- JS 数组可以存任意类型，更像"列表"
- 多维数组 = 数组套数组

---

## 下一节预告

数组的强大之处在于它的方法。下一节我们要学 `map`、`filter`、`reduce`、`find`、`some`、`every`——这些方法会让你的代码从一个"循环+判断"的 C 风格，升级到"声明式"的函数式风格。
