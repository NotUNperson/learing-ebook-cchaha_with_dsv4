# A.13 字符串操作

## 本节你会学到什么

- 模板字面量：`` ` ``（反引号）和 `${}` 内嵌表达式
- 多行字符串：模板字面量天然支持换行
- 常用字符串方法：`length`、`[]` 索引、`slice`、`indexOf`、`includes`、`startsWith`/`endsWith`、`toUpperCase`/`toLowerCase`、`trim`、`replace`、`split`
- 字符串不可变（immutable）——和 C 的 char 数组完全不同
- 推荐用 MDN 查阅更多方法

## 正文

### 一、模板字面量 -- 字符串拼接的革命

ES6 引入了**模板字面量**（Template Literal），用反引号 `` ` ``（键盘上 `Tab` 键上面的那个键）包裹，用 `${}` 内嵌表达式。

```javascript
// 传统写法（拼接，又丑又容易出错）
let name = "小明";
let age = 25;
let msg1 = "大家好，我叫" + name + "，今年" + age + "岁了。";

// 模板字面量（优雅！）
let msg2 = `大家好，我叫${name}，今年${age}岁了。`;

console.log(msg1);
console.log(msg2);
// 两者输出相同：大家好，我叫小明，今年25岁了。
```

`${}` 里面可以放**任何 JS 表达式**，不只是变量：

```javascript
let a = 10;
let b = 20;
console.log(`${a} + ${b} = ${a + b}`);  // "10 + 20 = 30"

let price = 99.9;
let quantity = 3;
console.log(`总价：${price * quantity} 元`);  // "总价：299.7 元"

// 甚至可以调用函数
function getStatus() { return "在线"; }
console.log(`用户状态：${getStatus()}`);  // "用户状态：在线"

// 三元运算符也行
let isAdmin = true;
console.log(`当前用户：${isAdmin ? "管理员" : "普通用户"}`);
```

> 生活类比：传统字符串拼接就像是把碎纸片一片一片用胶水粘起来，模板字面量就是给你一张完整的纸，你只需要在纸上填空（`${}`）。

### 二、多行字符串

模板字面量天然支持换行：

```javascript
// 传统写法（需要 \n）
let poem1 = "床前明月光，\n疑是地上霜。\n举头望明月，\n低头思故乡。";

// 模板字面量（直接换行）
let poem2 = `床前明月光，
疑是地上霜。
举头望明月，
低头思故乡。`;

console.log(poem2);
```

这在你需要写 HTML 片段、SQL 查询、或者任何多行文本时非常有用。

### 三、字符串是不可变的（Immutable）

JS 的字符串是**不可变的**。一旦创建，就不能修改其中的某个字符。所有"修改"字符串的操作，实际上都是**返回一个新字符串**。

```javascript
let str = "hello";
str[0] = "H";        // 没有效果！字符串不可变
console.log(str);    // "hello" -- 没有改变

// 要修改字符串，必须创建新的
let newStr = "H" + str.slice(1);
console.log(newStr); // "Hello"
```

这和 C 语言完全不同——C 语言的 `char[]` 可以直接修改。

### 四、字符串常用属性和方法

#### `length` -- 长度属性

```javascript
console.log("hello".length);          // 5
console.log("你好世界".length);        // 4
console.log("".length);               // 0  空字符串
```

#### `[]` 索引 -- 访问单个字符（只读）

```javascript
let s = "hello";
console.log(s[0]);  // "h"
console.log(s[1]);  // "e"
console.log(s[4]);  // "o"
console.log(s[5]);  // undefined（不会报错！和 C 不一样）
console.log(s[-1]); // undefined（没有 Python 的负数索引）
```

也可以使用 `charAt()` 方法（老式写法）：`s.charAt(0)`。

#### `slice(start, end)` -- 切片

```javascript
let s = "JavaScript";

console.log(s.slice(0, 4));     // "Java"  （索引 0 到 3）
console.log(s.slice(4));        // "Script"（从 4 到末尾）
console.log(s.slice(-6));       // "Script"（负数 = 从末尾往前数）
console.log(s.slice(0, -6));    // "Java"  （去掉最后 6 个字符）
```

#### `substring(start, end)` -- 子串

和 `slice` 类似，但不支持负数索引：

```javascript
let s = "JavaScript";
console.log(s.substring(0, 4));  // "Java"
console.log(s.substring(4));     // "Script"
```

#### `indexOf()` / `includes()` -- 查找

```javascript
let s = "Hello, World!";

console.log(s.indexOf("World"));     // 7  （找到的位置）
console.log(s.indexOf("JavaScript"));// -1 （没找到）
console.log(s.includes("World"));    // true
console.log(s.includes("Java"));     // false
```

#### `startsWith()` / `endsWith()` -- 判断开头/结尾

```javascript
let url = "https://example.com";

console.log(url.startsWith("https"));   // true
console.log(url.startsWith("http"));    // true
console.log(url.endsWith(".com"));      // true
console.log(url.endsWith(".org"));      // false
```

#### `toUpperCase()` / `toLowerCase()` -- 大小写

```javascript
console.log("Hello".toUpperCase());  // "HELLO"
console.log("Hello".toLowerCase());  // "hello"
```

#### `trim()` -- 去除首尾空格

```javascript
let input = "   你好   ";
console.log(input.trim());       // "你好"
console.log(input.trimStart());  // "你好   "  （ES2019）
console.log(input.trimEnd());    // "   你好"   （ES2019）
```

#### `replace()` -- 替换

```javascript
let text = "Hello, World!";
console.log(text.replace("World", "JavaScript"));  // "Hello, JavaScript!"

// 注意：replace 只替换第一个匹配（除非用正则加 g 标志）
let text2 = "apple banana apple";
console.log(text2.replace("apple", "orange"));  // "orange banana apple"
```

#### `split(separator)` -- 分割成数组

```javascript
let csv = "苹果,香蕉,橙子,葡萄";
let fruits = csv.split(",");
console.log(fruits);  // ["苹果", "香蕉", "橙子", "葡萄"]

let sentence = "JavaScript is fun";
let words = sentence.split(" ");
console.log(words);  // ["JavaScript", "is", "fun"]

let letters = "hello".split("");  // 空字符串分隔 -> 每个字符
console.log(letters);  // ["h", "e", "l", "l", "o"]
```

#### 方法链式调用

```javascript
let raw = "   Hello, World!   ";
let result = raw.trim().toUpperCase().slice(0, 5);
console.log(result);  // "HELLO"
// 先去空格 -> 转大写 -> 取前5个字符
```

---

## 动手试试

1. 用模板字面量写一段自我介绍，包含名字、年龄、爱好（变量动态替换）。
2. 写一段多行字符串（比如唐诗），用模板字面量展示。
3. 写一个函数 `maskEmail(email)`，用 `indexOf` 和 `slice` 把邮箱地址的用户名部分（@ 前面）的前面大部分字符替换为 `*`。
4. 用 `split` 和 `join` 把一个句子的单词顺序反转。

---

## 与 C 语言的对比

C 语言的字符串本质上是 `char[]` / `char*`，存储在连续内存中，可修改。JS 字符串是不可变的（immutable），每次"修改"都是创建新字符串。C 语言没有模板字面量，拼接用 `strcat`/`sprintf`；JS 的 `` `你好，${name}` `` 远比 C 的 `sprintf` 优雅。C 语言需要用 `strlen`、`strcmp`、`strchr` 等库函数操作字符串；JS 的字符串自带 30+ 内置方法。

---

## 本节小结

- 模板字面量 `` ` `` + `${}` 让字符串拼接非常优雅
- 模板字面量天然支持多行字符串
- JS 字符串不可变，所有"修改"都返回新字符串
- 常用方法：`slice`、`indexOf`、`includes`、`startsWith`/`endsWith`、`toUpperCase`/`toLowerCase`、`trim`、`replace`、`split`
- 更多方法查阅 [MDN](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/String)

---

## 下一节预告

学完字符串，该学数组了。JS 的数组和 C 语言的数组有天壤之别——它可以混合存储任意类型，自带一堆强大方法，更像是一个"列表"。下一节先讲数组的创建、索引、遍历。
