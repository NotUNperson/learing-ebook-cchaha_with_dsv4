# A.3 基本数据类型

## 本节你会学到什么

- JS 的 7 种基本数据类型（原始类型）
- number--整数和小数统一，没有 int/float 之分
- string--文本，单引号双引号都行
- boolean--true/false，以及 JS 的真值/假值概念入门
- null vs undefined--"空"和"未定义"的区别
- symbol 和 bigint--两个较新的类型，了解即可
- typeof 运算符--探测变量类型

## 正文

### 一、JavaScript 的数据类型概览

JavaScript 有 7 种**原始类型**（primitive types）和 1 种**对象类型**（object）。本节先讲原始类型，对象类型会在后面逐渐展开。

7 种原始类型：

| 类型 | 示例 | 说明 |
|------|------|------|
| `number` | `42`, `3.14`, `NaN` | 数字（整数和小数不分家） |
| `string` | `"hello"`, `'你好'` | 文本字符串 |
| `boolean` | `true`, `false` | 逻辑真假值 |
| `null` | `null` | 故意设置为"空" |
| `undefined` | `undefined` | 声明但未赋值 |
| `symbol` | `Symbol("id")` | 唯一标识符 |
| `bigint` | `123n` | 超大整数 |

> C 语言同学注意：JS 是**动态类型**语言。一个变量可以先后存不同类型的值，这在 C 中是不允许的。

```javascript
let x = 42;       // x 是 number
x = "hello";      // 现在 x 变 string 了，完全合法！
x = true;         // 又变 boolean 了，也没问题！
```

### 二、number -- 数字只有一种

在 C 语言中，你要分 `int`、`float`、`double`、`long`、`short`... 在 JS 中，**所有数字都是 number 类型**，底层是 64 位浮点数（类似 C 的 `double`）。

```javascript
let integer = 42;         // 整数
let float = 3.14;         // 小数
let negative = -10;       // 负数
let huge = 1.5e6;         // 科学计数法 = 1500000
let notANumber = NaN;     // 特殊的"非数字"值
let infinity = Infinity;  // 无穷大
```

几个特殊值：
- `NaN`（Not a Number）：表示"不是数字的数字"，比如 `0 / 0` 或者 `parseInt("abc")` 的结果。
- `Infinity`：正无穷，如 `1 / 0`。
- `-Infinity`：负无穷，如 `-1 / 0`。

> 生活类比：C 的数字类型像是不同容量的水杯（int 是小杯，long 是大杯，float 是量杯），JS 的 number 则是"一个大桶"--整数小数全装一起，底层统一处理。

### 三、string -- 文本字符串

JS 中字符串可以用**单引号**、**双引号**或**反引号**包裹：

```javascript
let s1 = 'hello';         // 单引号
let s2 = "hello";         // 双引号（和单引号没区别）
let s3 = `hello`;         // 反引号（ES6 模板字面量，后面会讲）
```

单引号和双引号在 JS 中没有功能区别，选择一种保持风格统一即可。

```javascript
let name = "小明";
let greeting = '你好！';
let sentence = "It's a nice day.";  // 双引号内可以直接用单引号
let quote = '他说："JavaScript很简单"';  // 单引号内可以直接用双引号
```

### 四、boolean -- 真和假

布尔类型只有两个值：`true` 和 `false`。和 C 语言不同，JS 的 `true`/`false` 是独立的关键字，不是数字 `1`/`0`。

```javascript
let isAdult = true;
let hasPermission = false;
console.log(typeof isAdult);  // "boolean"
```

**真值（truthy）和假值（falsy）**：JS 中每个值都可以被转换为布尔值。只有 6 个"假值"：`false`、`0`、`""`（空字符串）、`null`、`undefined`、`NaN`。其他所有值转换为布尔都是 `true`（包括空对象 `{}`、空数组 `[]`）。我们会在条件分支那一节详细讲这个概念。

### 五、null 和 undefined -- "空"的两种形态

这是 JS 面试的高频考点，也是新手容易搞混的地方。

**null**：程序员主动设置的值，表示"这里应该有个值，但现在是空的"。类似于你在餐厅预订了一个位置，但人还没来。

**undefined**：系统自动给的默认值，表示"还没初始化"。类似于你根本没预订，餐厅自然不知道你是谁。

```javascript
let a;                  // 声明但没赋值
console.log(a);         // undefined -- 系统默认

let b = null;           // 程序员主动设为空
console.log(b);         // null -- 人为设置的"空"

// 一个经典的面试题
console.log(typeof null);       // "object" -- 这是 JS 的历史遗留 bug！
console.log(typeof undefined);  // "undefined" -- 正常
```

`typeof null === "object"` 是 JavaScript 诞生时就留下的 bug，永远无法修复（因为会破坏大量现有代码）。记住这件事。

> 生活类比：`undefined` 是"我不小心空着没填"，`null` 是"我认真考虑后决定让它空着"。

### 六、symbol 和 bigint -- 两个特殊的类型

**symbol**（ES6）：创建唯一标识符，主要用于对象属性名，避免属性名冲突。日常开发中不常用，了解即可。

```javascript
const id1 = Symbol("id");
const id2 = Symbol("id");
console.log(id1 === id2);  // false -- 每次调用 Symbol() 都创建独一无二的值
```

**bigint**（ES2020）：用来处理超大整数（超出 `Number.MAX_SAFE_INTEGER`，约 9 千万亿）。

```javascript
const bigNumber = 9007199254740991n;  // 加 n 后缀就是 bigint
const bigger = 12345678901234567890n;
console.log(typeof bigNumber);  // "bigint"
```

日常学习中几乎不会用到 bigint，知道有这么个东西就行。

### 七、typeof 运算符 -- 查看变量类型

`typeof` 返回一个表示类型的字符串：

```javascript
console.log(typeof 42);         // "number"
console.log(typeof "hello");    // "string"
console.log(typeof true);       // "boolean"
console.log(typeof undefined);  // "undefined"
console.log(typeof null);       // "object"  ← 记住这个 bug
console.log(typeof Symbol());   // "symbol"
console.log(typeof 123n);       // "bigint"
```

---

## 动手试试

1. 用 `typeof` 检查不同类型的值，在终端验证输出。
2. 故意让一个数除以 0，看看 JS 返回什么（不会像 C 一样崩溃）。
3. 声明一个变量但不赋值，用 `typeof` 检查它的类型。
4. 试一下 `typeof NaN` -- 你会发现结果是 `"number"`。NaN 是数字类型，但它表示"不是数字的数字"，想想是不是很奇妙？

---

## 与 C 语言的对比

C 语言的数字类型繁多（int, float, double, long, short...），每种有固定字节宽度。JS 只有一个 number 类型，底层是 64 位浮点数，整数和小数统一处理。C 的 char 和字符串用 char 数组表示，JS 的 string 是独立的原始类型。C 没有 null 和 undefined 的区分，只有 NULL 宏（本质上就是 0）。JS 的类型系统更简洁，但也需要适应数字只有一种类型这个设定。

---

## 本节小结

- JS 有 7 种原始类型：number, string, boolean, null, undefined, symbol, bigint
- number 没有 int/float 区分，全部是 64 位浮点数
- string 单双引号均可，没有实际区别
- null 是"主动设置的空"，undefined 是"系统默认的空"
- `typeof null === "object"` 是历史 bug
- symbol 用于唯一标识符，bigint 用于超大整数，日常使用较少

---

## 下一节预告

知道了有哪些类型之后，下一步就是学会在它们之间进行判断和转换。下一节会讲到 `typeof` 的局限、显式类型转换、隐式类型转换，以及 JS 中最让人头疼的 `==` vs `===` 问题。
