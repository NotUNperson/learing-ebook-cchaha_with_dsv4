# A.18 解构与展开

## 本节你会学到什么

- 数组解构：`const [a, b] = arr` 把数组元素"拆"到变量里
- 对象解构：`const { name, age } = obj` 从对象中"抽取"同名属性
- 默认值与嵌套解构——解构时设置备选值，以及深层结构的拆解
- 展开运算符 `...` ——把数组/对象"摊开"，常用于合并、拷贝、传参
- 剩余模式 `...rest` ——收集剩余的元素/属性

## 正文

### 解构是什么

**生活类比**：你收到一个快递箱（数组），里面有笔、本子、橡皮。你不想用手一件件掏，而是"哗"一下倒在桌上——笔在这、本子在这、橡皮在这。解构就是这种"倒出来、各就各位"的语法。

### 数组解构

```javascript
const arr = [1, 2, 3];

// 传统方式
const a = arr[0];
const b = arr[1];
const c = arr[2];

// 解构——一行搞定
const [a, b, c] = [1, 2, 3];
console.log(a, b, c);  // 1 2 3
```

按位置对应，左边第几个变量就取右边第几个元素。

### 跳过元素和默认值

```javascript
const [first, , third] = [10, 20, 30];  // 空位跳过 20
console.log(first, third);  // 10 30

const [x, y = 99] = [5];    // y 没取到，用默认值 99
console.log(x, y);           // 5 99
```

### 交换变量——一行搞定

```javascript
let a = 1, b = 2;
[a, b] = [b, a];
console.log(a, b);  // 2 1  ——不用临时变量！
```

### 对象解构

数组解构按位置对应，对象解构则按**属性名**对应：

```javascript
const user = { name: "张三", age: 20, city: "北京" };

// 从对象中"抽取"同名属性到变量中
const { name, age } = user;
console.log(name);  // "张三"
console.log(age);   // 20
// city 没有被抽取，就被忽略了
```

### 重命名——解构时换个变量名

```javascript
const { name: userName, age: userAge } = user;
console.log(userName);  // "张三"  ——用新名字
// console.log(name);   // 报错！name 没有被定义
```

冒号在这里的含义是"原名: 新变量名"，和对象字面量里的冒号含义不同。

### 嵌套解构

```javascript
const data = {
    user: {
        profile: {
            name: "李四",
            city: "上海",
        },
    },
};

const { user: { profile: { name, city } } } = data;
console.log(name);  // "李四"
console.log(city);  // "上海"
```

注意：嵌套解构时，中间的 `user` 和 `profile` 不会作为独立变量存在，只有最内层的 `name` 和 `city` 被创建。

### 对象解构的默认值

```javascript
const { score = 60 } = {};       // 没有 score，用默认 60
const { age = 18 } = { age: 30 }; // age 存在，不用默认
```

### 展开运算符（Spread）`...`

展开运算符就像把一颗卷心菜"摊开"成一片片叶子。它把数组中的每个元素或对象中的每个属性"拆"出来。

**数组展开**——最常见的用法：

```javascript
const arr1 = [1, 2, 3];
const arr2 = [4, 5, 6];

// 合并数组
const merged = [...arr1, ...arr2];
console.log(merged);  // [1, 2, 3, 4, 5, 6]

// 插入元素
const withInsert = [0, ...arr1, 99];
console.log(withInsert);  // [0, 1, 2, 3, 99]

// 数组拷贝（浅拷贝）
const copy = [...arr1];
```

传统的 `concat` 也能合并数组，但 `...` 可以插在任意位置，语义更清晰。

**对象展开**——创建包含原属性+新属性的新对象：

```javascript
const base = { name: "张三", age: 20 };
const extended = { ...base, city: "北京", age: 21 };
// 展开 base 的属性，然后覆盖 age，添加 city
console.log(extended);  // { name: "张三", age: 21, city: "北京" }
```

后面的属性会覆盖前面的同名属性。这是一个非常常见的模式——"基于旧对象创建新对象，改动几个字段"。

注意：展开是**浅拷贝**。如果属性值是对象，拷贝的是引用，不会递归复制。

### 剩余模式（Rest）`...rest`

剩余模式和展开用的是同一个 `...` 符号，但含义相反：展开是"摊开"，剩余是"收拢"——把剩下的元素装进一个变量里。

```javascript
const [first, second, ...rest] = [1, 2, 3, 4, 5];
console.log(first);   // 1
console.log(second);  // 2
console.log(rest);    // [3, 4, 5]  ——剩下的全在这里

// 对象剩余
const { name, ...others } = { name: "张三", age: 20, city: "北京" };
console.log(name);    // "张三"
console.log(others);  // { age: 20, city: "北京" }
```

`...rest` 必须放在最后，因为它是"剩下的全归我"。

## 与 C 语言的对比

C 语言没有解构语法——你得逐个字段访问 `person.name`、`person.age`。JS 的解构是一种"批量赋值"的语法糖，背后没有新的运行时机制，但大幅减少了冗余代码。`...` 展开类似 C 中逐元素拷贝数组，但 JS 一行搞定。

## 动手试试

1. 创建数组 `["red", "green", "blue"]`，解构出前两个颜色
2. 解构一个对象，同时使用默认值和重命名
3. 用展开运算符合并两个数组，用对象展开创建一个"修改了某个字段"的新对象

## 本节小结

- 数组解构按位置匹配 `[a, b] = arr`，对象解构按属性名匹配 `{ a, b } = obj`
- 解构支持默认值、重命名（对象）、嵌套、跳过元素
- 展开 `...arr` 把数组/对象的元素"摊开"，用于合并、拷贝、传参
- 剩余 `...rest` 把剩余元素"收拢"到一个变量，必须放在最后
- 对象展开是浅拷贝，嵌套对象仍共享引用

## 下一节预告

A.19 this 关键字——JavaScript 中最让人困惑的概念之一。我们将系统拆解 this 的四种绑定规则，彻底搞清楚"this 到底指向谁"。
