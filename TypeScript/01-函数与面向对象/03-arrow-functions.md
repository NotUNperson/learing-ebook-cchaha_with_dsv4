# 03 箭头函数

## 本节你会学到什么

- 用箭头函数（`() => {}`）写出更简洁的函数
- 理解箭头函数的简写规则（单表达式省略 return 和大括号）
- 对比 C++ lambda 表达式和 TypeScript 箭头函数的语法异同
- 初步了解箭头函数的 this 行为与普通函数的区别

## 正文

### 函数写起来有点啰嗦？

看一段简单的代码：

```typescript
const numbers = [1, 2, 3];
const doubled = numbers.map(function(n) { return n * 2; });
```

这个 `function(n) { return n * 2; }` 只是为了表达"把每个数乘以 2"，却要写这么多字符。就像你明明只想说"帮我倒杯水"，却要说"尊敬的室友，请你执行倒水这个动作"——太正式了。

TypeScript（和 JavaScript）提供了一种更轻量的函数写法：**箭头函数**。

### 箭头函数的基本语法

把上面的例子用箭头函数重写：

```typescript
const numbers = [1, 2, 3];
const doubled = numbers.map((n) => { return n * 2; });
```

把 `function(n)` 换成 `(n) =>`——少了一个单词，视觉上也更干净。拆解语法：

```
(n) => { return n * 2; }
 ^       ^
 |       |
参数   箭头（读作"goes to"）
       后面是函数体
```

你可以把它读作："n goes to n 乘以 2"，或者说"接收 n，返回 n * 2"。

### 和 C++ lambda 的对比

如果你写过 C++11 之后的代码，你可能见过 C++ 的 lambda：

```cpp
// C++ lambda
auto lambda = [](int n) { return n * 2; };
```

TypeScript 的箭头函数和 C++ lambda 长得很像但不是一回事：

| 对比项 | C++ lambda | TypeScript 箭头函数 |
|--------|-----------|-------------------|
| 语法 | `[](int n) { return n * 2; }` | `(n: number) => { return n * 2; }` |
| 引入符号 | `[]`（捕获列表） | 无（直接用 `()`） |
| 箭头 | 无箭头（隐式） | `=>` 显式箭头 |
| 类型标注 | 参数前 `int n` | 参数后 `n: number` |
| 捕获外部变量 | 手动指定捕获方式 | 自动捕获，但 this 行为不同 |

C++ lambda 的捕获列表 `[]`（或 `[=]`、`[&]`）控制如何访问外部变量。TypeScript 的箭头函数没有这个概念——它自动能访问外部变量，但 **this 的行为和普通函数不一样**（下面会讲）。

### 箭头函数的简写规则

箭头函数有几个越来越简洁的写法：

**规则一：当函数体只有一行表达式时，可以省略 `{}` 和 `return`**

```typescript
// 完整写法
const double = (n: number): number => { return n * 2; };

// 简写（省略 {} 和 return）
const double = (n: number): number => n * 2;
```

这种简写非常常用。不带大括号时，`=>` 后面的表达式的结果会自动作为返回值。

**规则二：当只有一个参数时，可以省略 `()`**

```typescript
// 带括号
const square = (x: number) => x * x;

// 省略括号（只有一个参数时）
const square = x => x * x;
```

注意：如果没有参数，括号不能省——`() => ...` 是必须的。多个参数时括号也不能省。

**规则三：结合使用**

```typescript
// 一个参数 + 单行表达式 = 最简洁形式
const double = x => x * 2;
```

### 什么时候用箭头函数？

箭头函数最适合**短小的回调函数**。比如数组操作：

```typescript
const scores = [85, 92, 78, 95, 88];

// 找出所有及格的分数（>= 60）
const passed = scores.filter(s => s >= 60);

// 每个分数加 5 分
const curved = scores.map(s => s + 5);

// 计算总分
const total = scores.reduce((sum, s) => sum + s, 0);
```

这些一行搞定的小函数用箭头函数写，读起来就像在看公式一样直观。

### this 的陷阱——初学者知道就行

这是箭头函数和普通函数最重要的行为差异。C++ 程序员可能对 this 不陌生，但 TypeScript 的 this 有自己的规则。

先用生活类比理解 this：

想象你是一栋楼的物业前台。租客跟你说话时，你说"我这里"指的就是前台。但如果让保安来说"我这里"，指的就是保安亭。**this 就像是"我"，取决于谁在说这句话。**

**普通函数的 this**：取决于**谁调用了这个函数**。

```typescript
const person = {
    name: "小明",
    greet: function() {
        console.log("你好，我是" + this.name);
    }
};

person.greet();  // "你好，我是小明" —— this 指向 person
```

但如果把 `person.greet` 拿出来单独调用，this 就丢了：

```typescript
const fn = person.greet;
fn();  // "你好，我是 undefined" —— this 丢失了！
```

这就像你把前台的名牌借给另一个人戴——名牌上的名字还是你自己，但戴上的人不一样了。

**箭头函数的 this**：取决于**函数定义时所在的作用域**，而不是调用时。

```typescript
const person = {
    name: "小明",
    greet: () => {
        console.log("你好，我是" + this.name);
    }
};

person.greet();  // "你好，我是 undefined" —— this 指向外层（可能是 window）
```

箭头函数把 this "定死"在它被写出来的地方。在实际开发中，这通常是我们想要的行为——尤其是在回调函数里使用 this 的场景。但对于初学者，知道这个差异存在就够了，后面写 React 或 Node.js 时会自然遇到。

### C++ 程序员的思考方式

如果你来自 C++，可以把 this 理解为：
- 普通函数：this 像函数参数一样，在调用时动态传入（类似 C++ 的 `this` 指针，谁调用就指向谁）
- 箭头函数：this 像 lambda 的 `[this]` 捕获——它在定义时就确定了，不会在调用时改变

## 动手试试

用箭头函数完成以下任务：

1. 创建一个数组 `[3, 7, 2, 9, 5]`
2. 用 `map` 和箭头函数把每个数平方
3. 用 `filter` 和箭头函数筛选出大于 5 的数
4. 用 `reduce` 和箭头函数求和
5. 挑战：把 `map`、`filter`、`reduce` 串在一起，一步完成"所有数平方后筛出大于 20 的，再求和"

## 本节小结

箭头函数用 `() => {}` 替代 `function(){}`，特别适合短回调，单行表达式还能省略大括号和 return，让代码像数学公式一样简洁。

## 下一节预告

下一节我们学习 TypeScript 的函数重载——和 C++ 不同，TypeScript 采用"多个签名 + 一个实现"的独特方式来支持重载。
