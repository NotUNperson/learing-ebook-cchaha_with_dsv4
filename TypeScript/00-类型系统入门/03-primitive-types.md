# 03 基本类型：number、string、boolean

## 本节你会学到什么

- 掌握 TypeScript 的三种基本类型 number、string、boolean
- 理解 TypeScript 的 number 为什么和 C++ 的 int/float 不一样
- 知道 TypeScript 的 string 和 C++ 的 std::string 在用法上的异同
- 学会用 typeof 运算符检查类型

## 正文

学完了变量声明，这一节我们来认识 TypeScript 最基础的三种类型。如果你是从 C++ 来的，你可能会想："不就是 int、string、bool 吗？有什么好学的？" 还真不是——它们看起来像，实际差别很大。

### number：一个类型管所有数字

在 C++ 里，你有无数种表示数字的方式：

```cpp
int age = 25;        // 整数
float price = 9.99;  // 单精度浮点数
double pi = 3.14;    // 双精度浮点数
short s = 1;         // 短整数
long long big = 0;   // 长整数
```

TypeScript 的做法简单到让人不敢相信：**所有数字，无论整数还是小数，类型都是 `number`**。

```typescript
let age: number = 25;       // 整数？number
let price: number = 9.99;   // 小数？还是 number
let pi: number = 3.14;      // 圆周率？number
let hex: number = 0xFF;     // 十六进制？number
```

为什么会这样？因为 TypeScript 底层跑在 JavaScript 引擎上，而 JavaScript 只有一个数字类型：**64 位双精度浮点数**（IEEE 754）。这意味着：

- TypeScript 里没有"整数"和"小数"的运行时区分。`25` 和 `25.0` 在内存里是完全一样的。
- 数字的范围和精度由 JavaScript 的 IEEE 754 决定，不是由你选 int 还是 long 决定的。
- 那些熟悉的 C++ 整数溢出行为（比如 `INT_MAX + 1` 变成负数）在 TypeScript 里不存在——`Number.MAX_SAFE_INTEGER + 1` 等于 `Number.MAX_SAFE_INTEGER + 2`，因为是浮点数，整数的精度有限。

**生活类比**：C++ 的数字类型像是各种不同尺寸的盒子——小盒子（short）、中盒子（int）、大盒子（long long），你得分情况选。TypeScript 的 number 只有一个"万能盒子"，什么数字都能装，但它的内部结构是固定的——都是 64 位浮点数。

TypeScript 有一些特殊的数字值值得知道：

```typescript
let infinity: number = Infinity;       // 正无穷，类似 C++ 的 INFINITY
let negInfinity: number = -Infinity;   // 负无穷
let notANumber: number = NaN;          // 不是一个数字（比如 0/0 的结果）
```

注意 `NaN` 的类型也是 `number`——"不是数字"的东西，类型是 number。这听起来很矛盾，但这是 JavaScript 底层决定的，只能接受。

### string：比 std::string 更灵活

在 C++ 里，字符串可以用 `std::string`、`char[]`、`const char*`，各有各的用法和陷阱。

TypeScript 只有一种：`string`。而且用法非常灵活：

```typescript
let single: string = '单引号';               // 可以单引号
let double: string = "双引号";               // 也可以双引号
let backtick: string = `模板字符串`;           // 还可以反引号（模板字符串）
```

**模板字符串**（反引号）是 TypeScript 的一大亮点，C++ 直到很晚的标准才加入类似功能。它可以：

```typescript
let name = "Alice";
let age = 25;
// ${} 可以在字符串里嵌入变量，比 C++ 的 printf 或 cout << << 方便太多
let intro = `我是 ${name}，今年 ${age} 岁`;
console.log(intro);  // "我是 Alice，今年 25 岁"
```

这和 C++ 的字符串拼接形成鲜明对比：

```cpp
// C++：要么用加号，要么用 printf
std::string intro = "我是 " + name + "，今年 " + std::to_string(age) + " 岁";
// 或者
printf("我是 %s，今年 %d 岁", name.c_str(), age);
```

TypeScript 的模板字符串不需要手动转换类型，`${}` 里可以放任何表达式，自动变成了字符串。这就像你有一份填空的表格，只要把变量名填进 `${}` 里就行，不用管是什么类型。

### boolean：最简单的类型，没有坑

`boolean` 是三者中最简单的。它只有两个值：`true` 和 `false`。

```typescript
let isDone: boolean = false;
let hasError: boolean = true;
```

和 C++ 的 `bool` 几乎完全一样。但有一个细微差别：C++ 里很多非布尔值可以隐式转换成 bool（比如 `if (1)` 是合法的），TypeScript 在这方面更严格。

### typeof 运算符：看看变量的"身份证号"

TypeScript 提供了一个 `typeof` 运算符，可以查看一个变量的类型（在运行时）：

```typescript
console.log(typeof 42);          // "number"
console.log(typeof "hello");     // "string"
console.log(typeof true);        // "boolean"
console.log(typeof undefined);   // "undefined"
console.log(typeof null);        // "object" —— 这是一个历史 bug，记住就好
```

`typeof null` 返回 `"object"` 是 JavaScript 诞生时就有的 bug，TypeScript 也没有修复它（为了兼容性）。这一点在面试中经常被问到，先给你打预防针。

**生活类比**：`typeof` 像是身份证读卡器。你拿任何变量往读卡器上一刷（`typeof x`），它告诉你"这个变量是什么种族的"（number 族、string 族、object 族等）。

## 动手试试

1. 声明三个变量：一个整数、一个小数、一个 NaN，都用 `typeof` 检查类型，看它们是不是都返回 `"number"`。
2. 用模板字符串（反引号）拼接你的名字、年龄和爱好，打印出来。
3. 试试 `console.log(typeof null)`，亲眼看看那个著名的 bug。
4. 声明一个 `boolean` 变量，用 `typeof` 检查，确认返回的是 `"boolean"` 而不是 `"bool"`（和 C++ 不同）。

## 本节小结

TypeScript 只有三个基本"初代"类型：所有数字都是 number（底层是 64 位浮点数），所有文本都是 string（模板字符串比 C++ 方便很多），真假值是 boolean；typeof 是检查类型身份的工具。

## 下一节预告

了解了基本类型之后，下一节我们要学一个 TypeScript 最聪明的特性——类型推断：你不需要每次写类型，编译器能自己"猜"出来。
