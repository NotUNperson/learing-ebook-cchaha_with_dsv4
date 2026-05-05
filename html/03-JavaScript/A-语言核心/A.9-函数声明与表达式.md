# A.9 函数声明与表达式

## 本节你会学到什么

- 函数声明：`function add(a, b) { return a + b; }` -- 和 C 很像
- 函数表达式：函数也是值，可以赋值给变量
- 提升（hoisting）：函数声明 vs 函数表达式的关键区别
- 函数是一等公民（First-Class Citizen）-- JS 最重要的概念之一
- 和 C 语言函数指针的对比

## 正文

### 一、函数声明 -- 和 C 最像的写法

函数声明（Function Declaration）的写法和 C 很像：

```javascript
function add(a, b) {
    return a + b;
}

console.log(add(3, 5));  // 8
```

和 C 的区别：
- 不需要声明返回类型
- 参数不需要声明类型（`a` 和 `b` 前面没有类型名）
- 函数可以有返回值，也可以没有（没有 return 时返回 `undefined`）

```javascript
function greet(name) {
    console.log("你好，" + name);
    // 没有 return，函数默认返回 undefined
}

let result = greet("小明");
console.log(result);  // undefined
```

### 二、函数表达式 -- 函数也是值！

这是 JS 和 C 的一个**根本性区别**——在 JS 中，函数是一种**值**，可以赋值给变量。

```javascript
// 函数表达式：把一个函数赋值给变量
const add = function(a, b) {
    return a + b;
};

console.log(add(3, 5));  // 8 -- 调用方式和函数声明完全一样
```

注意 `function(a, b) { ... }` 这部分**没有函数名**。它叫"匿名函数"，就像一个没有名字的"临时工"，但你可以把它赋值给变量，通过变量名调用它。

> 生活类比：函数声明像是"注册公司"——公司在工商局有正式名称。函数表达式像是"雇一个临时工，给他一个工牌（变量名）"——用的时候通过工牌叫人。但本质上他们干的活是一样的。

因为函数是值，你可以把它：
- 赋值给变量
- **作为参数传给另一个函数**（这是 C 语言里函数指针做的事）
- 作为函数的返回值

```javascript
// 函数作为参数传给另一个函数
function execute(fn, x, y) {
    return fn(x, y);
}

const multiply = function(a, b) {
    return a * b;
};

console.log(execute(multiply, 4, 5));  // 20 -- multiply 函数被传给了 execute
```

### 三、提升（Hoisting）——函数声明 vs 函数表达式

这是新手常遇到的坑，但搞清楚后就很简单。

**函数声明会整体提升**：你可以在声明之前调用它：

```javascript
sayHello();  // 正常工作！输出 "Hello"

function sayHello() {
    console.log("Hello");
}
```

**函数表达式不会提升**：只有变量名提升了，但值（函数体）没有：

```javascript
// sayHi();  // 报错！Cannot access 'sayHi' before initialization

const sayHi = function() {
    console.log("Hi");
};

sayHi();  // 这里才能正常调用
```

如果用 `var` 声明，情况更坑人：

```javascript
// console.log(foo);  // undefined -- var 把变量名提升了，但值是 undefined
// foo();             // 报错！undefined is not a function

var foo = function() {
    console.log("foo");
};
```

> 提升类比：函数声明就像是"领导先把名字在花名册上登记好（提升到顶部），具体事情之后再说"。函数表达式更像是"临时工，拿到工牌那天才能开始工作"。

### 四、函数是一等公民 -- JS 最重要的概念之一

编程语言中，"一等公民"意味着某个东西可以：
1. 赋值给变量
2. 作为参数传给函数
3. 作为函数的返回值
4. 存储在数据结构中

JS 的函数满足以上所有条件。这是 JS 能写出**函数式编程**风格代码的基础。

```javascript
// 1. 赋值给变量
const greet = function(name) {
    return "你好，" + name;
};

// 2. 作为参数传给其他函数（回调函数）
function processUser(name, callback) {
    const greeting = callback(name);
    console.log(greeting);
}
processUser("小明", greet);  // "你好，小明"

// 3. 作为函数的返回值（高阶函数）
function createMultiplier(n) {
    return function(x) {
        return x * n;  // 返回的新函数"记住"了 n
    };
}
const triple = createMultiplier(3);
console.log(triple(10));  // 30

// 4. 存储在数组中
const operations = [
    function(a, b) { return a + b; },
    function(a, b) { return a - b; },
    function(a, b) { return a * b; }
];
console.log(operations[0](5, 3));  // 8
```

> 对于 C 程序员：C 语言中函数不是一等公民，你不能在运行时创建函数。你只能用函数指针来引用函数。JS 让函数变得像变量一样自由地传来传去。

---

## 动手试试

1. 分别写一个函数声明和一个函数表达式，功能都是计算阶乘，然后测试它们的"提升"行为。
2. 写一个函数 `applyOperation(a, b, operation)`，接收两个数字和一个函数作为参数，调用第三个参数来处理前两个参数。
3. 写一个函数 `createGreeter`，接收一个语言代码（`"zh"` 或 `"en"`），返回一个对应的问候函数。

---

## 与 C 语言的对比

C 语言中函数是"二等公民"：你不能在运行时定义新函数，函数不能嵌套（GCC 扩展除外），你想把函数当参数传只能用函数指针，语法怪异。JS 中函数是"一等公民"：可以在运行时创建（函数表达式），可以作为参数随意传递（回调），可以从其他函数返回（高阶函数），可以存进数组。这种"函数是值"的思想是理解 JS 后续很多概念（闭包、回调、Promise、事件处理）的基石。

---

## 本节小结

- 函数声明：`function name() {}` -- 和 C 很像
- 函数表达式：`const name = function() {};` -- 函数是值
- 函数声明会整体提升，函数表达式只提升变量名
- JS 函数是一等公民：可以赋值、传参、返回、存储
- 这个特性是 JS 函数式编程的基础

---

## 下一节预告

函数表达式写起来有点长（`const add = function(a, b) { return a + b; };`），ES6 提供了一种更简洁的写法——箭头函数。下一节你会写出 `const add = (a, b) => a + b;`。
