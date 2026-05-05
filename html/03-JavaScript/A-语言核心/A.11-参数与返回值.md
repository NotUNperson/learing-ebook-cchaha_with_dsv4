# A.11 参数与返回值

## 本节你会学到什么

- 默认参数：`function greet(name = "世界") {}`
- 剩余参数：`...args` 把剩余参数收集成数组
- `arguments` 对象（老式方法，了解即可）
- `return` 返回值和函数终止
- JS 函数可以返回任意类型，包括函数（高阶函数伏笔）
- 没有 return 的函数返回 `undefined`

## 正文

### 一、参数的灵活性 -- JS 和 C 的重大区别

在 C 语言中，函数定义了几个参数，调用时就必须传几个（否则编译报错）。JS 中**不是这样的**：

```javascript
function greet(name) {
    console.log("你好，" + name);
}

greet("小明");   // "你好，小明"
greet();          // "你好，undefined" -- 没传参数，name 就是 undefined
greet("张三", "李四"); // "你好，张三" -- 多余的参数被忽略了
```

JS 不会因为参数数量不匹配而报错。少了就是 `undefined`，多了就忽略。

> 生活类比：C 语言函数像是一个要求精准的快递柜——每个格子必须填满。JS 函数像是一个开放的邮筒——你塞多少东西都可以，少塞就当空着，多塞的就放一边。

### 二、默认参数（Default Parameters）

ES6 引入了**默认参数**，让你给参数指定一个默认值——当调用时没传这个参数（或传了 `undefined`），就使用默认值。

```javascript
// 传统写法（ES6 之前）
function greet(name) {
    name = name || "世界";  // 用 || 做默认值
    console.log("你好，" + name);
}

// ES6 默认参数（推荐！）
function greetNew(name = "世界") {
    console.log("你好，" + name);
}

greetNew("小明");   // "你好，小明"
greetNew();          // "你好，世界" -- 用了默认值
greetNew(undefined); // "你好，世界" -- undefined 也会触发默认值
greetNew(null);      // "你好，null" -- null 不会触发默认值！
```

默认参数的求值是在**调用时**进行的，可以使用前置参数：

```javascript
function createGreeting(greeting = "你好", name = "世界") {
    console.log(greeting + "，" + name);
}

createGreeting();                    // "你好，世界"
createGreeting("早上好");            // "早上好，世界"
createGreeting("Good Morning", "Alice"); // "Good Morning，Alice"
createGreeting(undefined, "小明");   // "你好，小明" -- 第一个参数用默认值
```

默认参数也可以使用前置参数的值：

```javascript
function sum(a, b = a * 2) {
    return a + b;
}
console.log(sum(5));     // 15 (5 + 5*2)
console.log(sum(5, 3));  // 8  (5 + 3)
```

### 三、剩余参数 `...args`（Rest Parameters）

ES6 引入的**剩余参数**让你把多个参数收集成一个数组。这比 C 语言的可变参数（`stdarg.h`）好用得多：

```javascript
// ... 把剩余的所有参数收集到 numbers 数组中
function sum(...numbers) {
    let total = 0;
    for (let n of numbers) {
        total += n;
    }
    return total;
}

console.log(sum(1, 2, 3));          // 6
console.log(sum(10, 20, 30, 40));   // 100
console.log(sum());                  // 0
```

注意几个点：
- `...` 必须是最后一个参数：`function f(a, b, ...rest) {}`
- 一个函数只能有一个剩余参数
- 它始终是一个数组（即使是空的），所以可以用数组方法

```javascript
function logAll(tag, ...messages) {
    for (let msg of messages) {
        console.log("[" + tag + "]", msg);
    }
}

logAll("INFO", "服务器启动", "监听端口 3000", "等待连接");
// [INFO] 服务器启动
// [INFO] 监听端口 3000
// [INFO] 等待连接
```

### 四、`arguments` 对象（老式方法）

在 ES6 之前，JS 用 `arguments` 对象来访问所有传入的参数。**现在不推荐使用**，但你在老代码中可能会遇到。

```javascript
function oldStyle() {
    console.log("传入了", arguments.length, "个参数");
    for (let i = 0; i < arguments.length; i++) {
        console.log("参数" + i + ":", arguments[i]);
    }
}

oldStyle(1, 2, 3);
// 传入了 3 个参数
// 参数0: 1
// 参数1: 2
// 参数2: 3
```

`arguments` 的问题：
- 是"类数组"但不是真正的数组（不能用 `map`、`filter` 等数组方法）
- 在箭头函数中不可用
- 代码可读性不如 `...args`

**结论：新代码请用剩余参数 `...args`，忘记 `arguments`。**

### 五、`return` -- 返回值和函数终止

`return` 做两件事：
1. 指定函数的返回值
2. **立即终止函数的执行**

```javascript
function findFirstEven(numbers) {
    for (let n of numbers) {
        if (n % 2 === 0) {
            return n;  // 找到第一个偶数就返回，函数结束
        }
    }
    return null;  // 没找到返回 null
}

console.log(findFirstEven([1, 3, 5, 7, 8, 10]));  // 8
console.log(findFirstEven([1, 3, 5, 7]));          // null
```

没有 `return` 的函数默认返回 `undefined`：

```javascript
function doSomething() {
    console.log("做完了");
    // 没有 return
}
let result = doSomething();
console.log(result);  // undefined
```

### 六、JS 函数可以返回任意类型

JS 函数可以返回任何类型——数字、字符串、数组、对象，乃至**函数**：

```javascript
// 返回一个对象
function createPerson(name, age) {
    return { name: name, age: age };  // 注意 ES6 可简写为 { name, age }
}

// 返回一个数组
function splitName(fullName) {
    return fullName.split(" ");  // 按空格分割
}

// 返回一个函数！（高阶函数）
function createAdder(base) {
    return function(n) {
        return base + n;
    };
}

const add5 = createAdder(5);
console.log(add5(10));  // 15
```

注意：JS 的函数**只能返回一个值**。如果想返回多个值，可以把它们装进数组或对象中：

```javascript
function getMinMax(numbers) {
    let min = Math.min(...numbers);
    let max = Math.max(...numbers);
    return { min, max };  // ES6 简写：{ min: min, max: max }
}

let result2 = getMinMax([3, 1, 7, 5, 9]);
console.log(result2);  // { min: 1, max: 9 }
```

---

## 动手试试

1. 写一个函数，接收一个名字和一个问候语，两个参数都有默认值，并测试不同调用方式。
2. 用剩余参数写一个函数 `average(...nums)`，计算所有参数的平均值。
3. 写一个函数 `createCounter`，返回一个每次调用加 1 的函数（闭包的入门）。

---

## 与 C 语言的对比

C 语言的参数在编译时就得确定类型和数量，调用时参数个数必须匹配。JS 参数非常灵活：少了变 `undefined`（可搭配默认参数），多了被忽略（可搭配剩余参数收集）。C 语言的可变参数通过 `stdarg.h` + `va_list` 实现，语法繁琐且类型不安全；JS 的 `...args` 语法简洁清晰，直接得到一个真数组。另外 C 语言函数只能返回一种类型（编译时确定），JS 函数可以返回任意类型且没有类型约束。

---

## 本节小结

- JS 调用时的参数个数可以和声明时不一致
- 默认参数：`function f(name = "默认")`
- 剩余参数：`...args` 收集成数组（推荐代替 `arguments`）
- `return` 返回值和终止函数；无 `return` 时返回 `undefined`
- JS 函数可以返回任何类型，包括函数

---

## 下一节预告

接下来是 JS 中最核心、也是面试最爱考的概念——作用域和闭包。函数如何"记住"自己诞生时的环境？什么叫"函数背着包到处走"？下一节为你彻底揭开闭包的面纱。
