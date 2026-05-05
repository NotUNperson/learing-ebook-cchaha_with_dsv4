# A.12 作用域与闭包

## 本节你会学到什么

- 词法作用域 -- 作用域在写代码时就决定，像出生地
- 块作用域（`let`/`const`）vs 函数作用域（`var`）
- 嵌套函数如何访问外部变量
- **闭包（Closure）** -- 函数记住了它诞生时的环境
- 闭包的实际用途：数据私有、计数器、回调
- 用"背包"类比彻底理解闭包

## 正文

### 一、词法作用域 -- 写代码时就决定

JS 采用**词法作用域**（Lexical Scope），意思是：**变量的作用域在写代码的时候就已经确定了**，不需要等到运行。

```javascript
let name = "小明";  // 全局作用域

function greet() {
    let greeting = "你好";  // greet 函数作用域
    console.log(greeting + "，" + name);  // 可以访问外层的 name
}

greet();  // "你好，小明"
// console.log(greeting); // 报错！greeting 在 greet 函数外不可见
```

> 生活类比：词法作用域就像出生地——你出生在北京或上海，这个事实在你出生时就确定了，不会因为你后来去了哪里而改变。函数的"出生地"同理。

和 C 语言一样，JS 的作用域也是嵌套的。内层可以访问外层的变量，反过来不行。

### 二、块作用域 vs 函数作用域

这是 A.2 学过的内容，这里复习并加深。

| 声明关键字 | 作用域类型 | 边界 |
|-----------|-----------|------|
| `let` | 块作用域 | `{}` |
| `const` | 块作用域 | `{}` |
| `var` | 函数作用域 | `function {}` |

```javascript
// let/const：块作用域
{
    let x = 10;
    const y = 20;
    console.log(x, y);  // 正常
}
// console.log(x);  // 报错！

// var：函数作用域
{
    var z = 30;
}
console.log(z);  // 30 -- var 不会被困在 {} 里！

// var 只在函数边界被限制
function test() {
    var inside = "函数内部";
}
// console.log(inside);  // 报错！var 被困在函数内
```

### 三、闭包（Closure）-- JS 最核心的概念

终于到闭包了。闭包是 JS 面试必考、也是理解 JS 运行机制的关键概念。

**闭包的定义**：一个函数，记住了它被创建时所在的作用域中的变量，即使那个作用域已经执行完毕。

通俗一点说：**函数背着它出生时的"背包"，走到哪里这个背包都跟着。**

来看一个最简单的闭包例子：

```javascript
function createCounter() {
    let count = 0;  // count 是 createCounter 内部的局部变量

    return function() {  // 返回一个内部函数
        count++;         // 内部函数使用了外层的 count
        return count;
    };
}

const counter1 = createCounter();
console.log(counter1());  // 1
console.log(counter1());  // 2
console.log(counter1());  // 3

const counter2 = createCounter();
console.log(counter2());  // 1 -- 独立的计数器！
console.log(counter2());  // 2
console.log(counter1());  // 4 -- counter2 不影响 counter1
```

**关键理解**：
1. `createCounter` 函数执行完毕后，按理说 `count` 就该被销毁了（和 C 局部变量一样）
2. 但是！返回的内部函数"记住"了 `count`——它把 `count` 装进"背包"里带走了
3. 每次 `counter1()` 时，访问的是同一个"背包"里的同一个 `count`
4. `counter1` 和 `counter2` 各有各的"背包"，互不影响

> 背包类比：你去图书馆寄存东西，你的物品被锁在一个柜子里。柜子的钥匙（闭包）拿在你手里。即使图书馆关门（外部函数执行完毕），你手上的钥匙（闭包）仍然可以打开那个柜子（访问闭包内的变量）。每个计数器都有自己独一无二的"钥匙"。

### 四、闭包的经典用途

#### 用途 1：数据私有（Private Data）

在没有 class 的时代，闭包是 JS 实现"私有变量"的方式：

```javascript
function createPerson(name, age) {
    // name 和 age 是私有的，外部无法直接访问
    return {
        getName: function() { return name; },
        getAge: function() { return age; },
        haveBirthday: function() { age++; },  // 只能通过方法修改
        greet: function() { console.log("你好，我是" + name); }
    };
}

const person = createPerson("小明", 20);
console.log(person.getName());  // "小明"
person.haveBirthday();
console.log(person.getAge());   // 21
// console.log(person.name);    // undefined -- 无法直接访问！
```

#### 用途 2：创建工厂函数

```javascript
function createMultiplier(factor) {
    return function(n) {
        return n * factor;
    };
}

const double = createMultiplier(2);
const triple = createMultiplier(3);

console.log(double(5));  // 10
console.log(triple(5));  // 15
```

#### 用途 3：在循环中捕获变量

这是闭包的经典面试题：

```javascript
// 问题代码：所有函数都输出 3（循环结束后的值）
for (var i = 0; i < 3; i++) {
    setTimeout(function() {
        console.log(i);  // 3, 3, 3
    }, 100);
}

// 解决（ES6 之前）：用闭包捕获每次迭代的 i
for (var i = 0; i < 3; i++) {
    (function(j) {
        setTimeout(function() {
            console.log(j);  // 0, 1, 2
        }, 100);
    })(i);
}

// 解决（ES6 最简单）：直接用 let！（let 有块作用域）
for (let i = 0; i < 3; i++) {
    setTimeout(function() {
        console.log(i);  // 0, 1, 2  -- let 每次迭代都是新的绑定
    }, 100);
}
```

### 五、闭包可能的内存影响

闭包会让外部函数的变量不被垃圾回收。这意味着如果你创建了大量闭包且长期持有，可能占用内存。但对于大多数日常开发来说，这不是问题。正确理解和使用闭包远比"担心内存泄漏"更重要。

---

## 动手试试

1. 写一个闭包 `createGreeter(greeting)`，接收一个问候语，返回一个接受名字的问候函数。`const sayHello = createGreeter("你好"); sayHello("小明"); // "你好，小明"`
2. 写一个 `createBank` 函数，创建一个"银行账户"对象，用闭包保护余额。只能通过指定的方法（存钱、取钱、查余额）访问。
3. 尝试用 `let` 和 `var` 在 for 循环中创建函数，观察闭包行为的不同。

---

## 与 C 语言的对比

C 语言中函数不能嵌套定义（GCC 扩展除外），因此不存在闭包的概念。C 语言的局部变量在函数返回后就被销毁了（栈帧弹出）。JS 的闭包让内部函数可以"记住"外部函数的变量，即使外部函数已经返回。这是 C 程序员学习 JS 时最重要的思维转变之一。如果你理解 C 语言中 `malloc` 的内存可以在函数返回后继续存在，那么闭包可以类比为"变量的生命周期被闭包延长了"。

---

## 本节小结

- 词法作用域：作用域在写代码时就决定
- 块作用域（`let`/`const`）vs 函数作用域（`var`）
- **闭包** = 函数记住了诞生时的环境（"背包"）
- 闭包用于：数据私有、工厂函数、捕获循环变量
- 理解闭包是 JS 进阶的基石

---

## 下一节预告

学完了函数的核心知识，接下来我们回到数据类型——深入看看字符串操作。ES6 的模板字面量 `\`\${}\`` 会让字符串拼接变得非常优雅。
