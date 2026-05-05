# A.4 类型判断与转换

## 本节你会学到什么

- `typeof` 的局限和 `instanceof` 的基本用法
- 显式类型转换：`String()`、`Number()`、`Boolean()`
- 隐式类型转换：自动发生的"自动挡"转换
- JS 中最经典的坑：`"5" + 2 = "52"` 而不是 `7`
- `==` vs `===`：松等和严等的区别，以及为什么推荐用 `===`

## 正文

### 一、typeof 的局限

上一节我们用了 `typeof`，它很实用但有两个主要局限：

**局限一：`typeof null === "object"`**

这是 JS 诞生时的 bug，木已成舟。

```javascript
console.log(typeof null);  // "object" -- 不是 "null"！
```

**局限二：数组、对象等引用类型，typeof 都返回 "object"**

```javascript
console.log(typeof {});           // "object"
console.log(typeof []);           // "object" ← 数组也是 "object"！
console.log(typeof new Date());   // "object"
```

这意味着 `typeof` 无法区分数组和普通对象。要判断数组，可以用 `Array.isArray()`：

```javascript
console.log(Array.isArray([1, 2, 3]));  // true
console.log(Array.isArray({a: 1}));     // false
```

要判断对象的具体类型，可以用 `instanceof`：

```javascript
console.log([] instanceof Array);     // true
console.log({} instanceof Object);    // true
console.log(new Date() instanceof Date); // true
```

### 二、显式类型转换 -- "手动挡"

显式类型转换是你在代码里明确地调用函数来转换类型。就像开手动挡汽车，换挡是你自己操作的。

#### String() -- 转字符串

```javascript
console.log(String(42));       // "42"
console.log(String(true));     // "true"
console.log(String(null));     // "null"
console.log(String(undefined));// "undefined"
```

#### Number() -- 转数字

```javascript
console.log(Number("42"));        // 42
console.log(Number("3.14"));      // 3.14
console.log(Number(""));          // 0 -- 空字符串转成 0
console.log(Number("abc"));       // NaN -- 无法解析
console.log(Number(true));        // 1
console.log(Number(false));       // 0
console.log(Number(null));        // 0
console.log(Number(undefined));   // NaN
```

#### Boolean() -- 转布尔

```javascript
// 假值（以下 6 种转为 false）
console.log(Boolean(false));    // false
console.log(Boolean(0));        // false
console.log(Boolean(""));       // false
console.log(Boolean(null));     // false
console.log(Boolean(undefined));// false
console.log(Boolean(NaN));      // false

// 其余全是真值（包括下面这些让 C 程序员吃惊的）
console.log(Boolean([]));       // true -- 空数组是真！
console.log(Boolean({}));       // true -- 空对象也是真！
console.log(Boolean(" "));      // true -- 包含空格的字符串也是真！
console.log(Boolean("false"));  // true -- 非空字符串都是真！
```

### 三、隐式类型转换 -- "自动挡"

JS 在某些情况下会**自动**把值从一种类型转为另一种类型。就像自动驾驶的汽车，你不用操作它也会换挡。这很方便，但有时会产生"意外"。

#### 字符串拼接中的隐式转换

**这是 JS 最著名的坑之一**：

```javascript
console.log("5" + 2);      // "52" -- 不是 7！
console.log("5" + "2");    // "52"
console.log(5 + 2);        // 7    -- 没有字符串时正常做加法

// + 号的规则：只要有一个操作数是字符串，+ 就变成"拼接"
console.log("Hello" + 2024);  // "Hello2024"
console.log(1 + "2" + 3);     // "123" -- 计算顺序：1 + "2" = "12", "12" + 3 = "123"
```

**为什么会这样？** JS 的设计者让 `+` 运算符承担了两个角色：加法运算和字符串拼接。当 `+` 遇到字符串时，它优先选择"拼接"这个角色。

> 生活类比：`+` 就像一个多功能工具（瑞士军刀），平时做数学加法，但一看到字符串就自动切换成"拼接模式"。

#### 其他运算符的隐式转换

和 `+` 不同，`-`、`*`、`/` 等运算符会尝试把字符串转成数字：

```javascript
console.log("6" - 2);    // 4  -- 减号没有"拼接"功能，所以字符串被转成数字
console.log("6" * "2");  // 12
console.log("6" / "2");  // 3
```

#### 条件判断中的隐式转换

```javascript
if ("hello") {  // 字符串被隐式转为 true
    console.log("非空字符串 -> true");
}
if (0) {  // 0 被隐式转为 false
    console.log("这行永远不会执行");
}
```

### 四、== vs === -- 松等 vs 严等

这是 JS 中另一个核心概念，也是新手容易掉坑的地方。

**`===`（严格相等，严等）**：类型不同直接返回 `false`。类型相同再比较值。

**`==`（宽松相等，松等）**：类型不同时，会先做类型转换，再比较。转换规则比较复杂，容易产生反直觉的结果。

```javascript
// === 严格相等 -- 类型不同直接 false
console.log(5 === 5);        // true
console.log(5 === "5");      // false -- 类型不同！number vs string
console.log(true === 1);     // false -- 类型不同！
console.log(null === undefined);  // false

// == 宽松相等 -- 会做类型转换
console.log(5 == "5");       // true -- "5" 先转为 5 再比较
console.log(true == 1);      // true -- true 先转为 1
console.log(false == 0);     // true -- false 先转为 0
console.log(null == undefined);  // true -- 特例：null 和 undefined 松等
```

来看一些经典的`==`"反直觉"行为：

```javascript
console.log("" == false);      // true  (空字符串转为 false)
console.log([] == false);      // true  (空数组转为 "" 再转为 false)
console.log(null == 0);        // false (null 不转为 0，和你想的可能不一样)
console.log([] == ![]);        // true  (什么鬼？！)
```

**结论：始终使用 `===`，除非你明确知道为什么需要使用 `==`。**

> 生活类比：`===` 是一个严谨的安检员，人和证件必须完全匹配；`==` 是一个好说话的安检员，"你看起来像这个人就进去吧"。在严肃场合（生产代码），你肯定希望安检员是前一种。

---

## 动手试试

1. 用 `Array.isArray()` 判断 `[1, 2, 3]` 和 `{a: 1}` 哪个是数组。
2. 写一句 `console.log("10" + 20)` 和 `console.log("10" - 20)`，对比两者的结果，理解 `+` 的双面性。
3. 用 `===` 和 `==` 分别比较 `0` 和 `false`，看看结果有何不同。
4. 试着用 `Number()` 转换一些奇奇怪怪的值（如 `"100px"`、`undefined`、`true`），观察结果。

---

## 与 C 语言的对比

C 语言有严格的静态类型检查，编译器会在编译时告诉你类型不匹配。JS 是动态类型，类型转换可以自动发生，这带来了灵活性，也带来了潜在的 bug。C 语言没有 `===` 和 `==` 的区分（C 的 `==` 不会做类型转换，因为类型在编译时就定了）。另外，C 的 `NULL` 本质上就是 `(void*)0`，而 JS 的 `null` 和 `undefined` 是两个独立的类型。

---

## 本节小结

- `typeof` 有局限：`typeof null` 是 `"object"`，`typeof []` 也是 `"object"`
- 显式转换：`String()`、`Number()`、`Boolean()`
- 隐式转换：JS 自动做类型转换，`+` 遇到字符串变拼接是最大的坑
- `===` 严格相等（类型不同直接 false），`==` 宽松相等（会做类型转换）
- 日常编码默认用 `===`，避免 `==` 的意外行为

---

## 下一节预告

有了类型和转换的基础，下一节我们来全面了解 JS 的运算符。除了 C 语言里你熟悉的 + - * / %，JS 还有 `**`（幂运算）和 `??`（空值合并）等新朋友。
