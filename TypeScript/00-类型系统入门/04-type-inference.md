# 04 类型推断：让编译器帮你"猜"类型

## 本节你会学到什么

- 理解类型推断是什么，以及 TypeScript 为什么设计了这个能力
- 知道什么情况下可以放心省略类型标注
- 识别哪些场景必须显式标注类型
- 理解"字面量类型"这个推断的特殊情况
- 学会利用 IDE 的悬停提示查看推断结果

## 正文

上一节我们学了三种基本类型，每次都老老实实写了 `: number`、`: string`、`: boolean`。现在我要告诉你一个好消息：大部分时候，你不写这些标注也行。这就是 TypeScript 最让人舒服的特性之一——**类型推断**。

### 类型推断是什么

类型推断就是：**你给一个变量赋值，TypeScript 根据你赋的值自动"猜"出变量的类型**。

```typescript
let name = "Alice";   // TypeScript 推断 name 的类型是 string
let age = 25;         // TypeScript 推断 age 的类型是 number
let isAdmin = true;   // TypeScript 推断 isAdmin 的类型是 boolean
```

这三行代码没有写任何类型标注，但它们和下面这段完全等价：

```typescript
let name: string = "Alice";
let age: number = 25;
let isAdmin: boolean = true;
```

TypeScript 是怎么做到的？因为它看到 `"Alice"` 是一个字符串字面量，就知道 `name` 应该是 `string` 类型；看到 `25` 是数字，就知道 `age` 应该是 `number`。这个推导过程在我们保存文件时就瞬间完成了。

C++ 也有类似的东西（`auto` 关键字），但 TypeScript 的类型推断更强、更常用。C++ 社区很多人对 `auto` 持谨慎态度，觉得滥用 `auto` 会让代码难读。TypeScript 社区的态度恰恰相反：**能推断就不要写**，少写类型标注意味着代码更简洁，而且类型依旧安全。

### 生活类比：点菜时的"老规矩"

想象你去一家餐馆，跟老板说"老规矩"。老板不用问你，就知道你要点什么菜，因为你每次来都点同样的东西。这就是类型推断——编译器看到了你的初始值（"老规矩"），自动就知道了类型（你要点的菜）。

但如果你只说"我饿了"，却不给线索（不赋初始值），老板（编译器）就懵了，不知道给你上什么。这时候你就必须明确点菜（显式标注类型）。

### 什么时候可以不写类型标注

**绝大部份赋值声明都不需要写**：

```typescript
let score = 100;                // 推断为 number
let message = "Game Over";      // 推断为 string
let items = [1, 2, 3];         // 推断为 number[]
let player = { name: "Tom", hp: 100 }; // 推断为 { name: string; hp: number }
```

函数返回类型也经常可以不写：

```typescript
function add(a: number, b: number) {
    return a + b;  // TypeScript 推断返回类型是 number
}
```

注意：函数参数通常还是要写类型标注的。因为参数没有"初始值"供编译器参考。

```typescript
// 参数 x 和 y 不写类型，编译器不知道怎么检查
// function multiply(x, y) { ... }  // 这样写没有意义，x 和 y 会被推断为 any
function multiply(x: number, y: number) {
    return x * y;
}
```

### 什么时候必须显式标注类型

有几种情况，编译器没法猜，你必须自己写：

**1. 声明时没有初始值**

```typescript
let result;          // 推断为 any——不推荐！
let result: number;  // 显式标注——推荐
// 后面再赋值
result = 42;
```

没有初始值，编译器不知道你想要什么类型，只能给一个 `any`（"到时候再说"）。这等于放弃了类型检查，很危险。所以如果你打算"先声明，后面再赋值"，一定要写上类型。

**2. 你想要更宽的类型**

```typescript
// 编译器推断出的是 "Tom"，不是 string
const playerName = "Tom";  // 类型是 "Tom"（字面量类型），不是 string

// 如果你希望是用 string，可以做类型断言
let playerName2: string = "Tom";  // 类型是 string
```

这里涉及一个概念叫**字面量类型**。用 `const` 声明的变量，编译器会推断出最精确的类型——`const x = "hello"` 的类型不是 `string`，而是字面量 `"hello"`。这很精确，但有时你确实想要更宽泛的 `string` 类型。

**3. 函数参数**

前面说了，函数参数没有赋值行为，编译器无从推断，所以必须标注。

### 如何利用 IDE 查看推断结果

在 VS Code 里，把鼠标悬停在一个变量上，IDE 会显示 TypeScript 推断出的类型。这是学习类型推断最好的方法——写代码时随手看，不用猜。

比如你写 `let items = [1, 2, 3]`，悬停到 `items` 上，VS Code 会显示 `let items: number[]`，告诉你编译器推导出的类型是"数字数组"。

### C++ 对比

| 场景 | C++ | TypeScript |
|------|-----|------------|
| 自动推导 | `auto x = 1;` | `let x = 1;`（自动推断） |
| 显式标注 | `int x = 1;` | `let x: number = 1;` |
| 参数推导 | 不支持（C++20 concept 有类似） | 不支持——参数必须标注 |
| 社区态度 | 对 auto 持谨慎，显式更常见 | 能推断就不写，显式反而是多余的 |
| 字面量类型 | 不支持 | `const x = "hi"` 类型是 `"hi"` |

## 动手试试

1. 声明几个变量，不写类型标注，分别赋值为数字、字符串、布尔、数组。然后用鼠标悬停查看 VS Code 显示的类型。
2. 声明一个没有初始值的变量，看看什么情况。然后加上类型标注，对比。
3. 写一个函数，三个参数都写类型标注，返回一个字符串。然后注释掉其中一个参数的类型标注，看编译器报什么错。
4. 用 `const` 声明 `const name = "Alice"`，悬停查看类型——是 `string` 还是更精确的 `"Alice"`？

## 本节小结

TypeScript 能根据初始值自动推断类型，日常写代码大部分时候不用写类型标注——但函数参数和"先声明后赋值"的情况必须写，const 会推断出比预期更精确的字面量类型。

## 下一节预告

学完了单个变量，下一节我们学习如何组织多个数据——数组和元组，看看 TypeScript 的 `number[]` 和 C++ 的 `vector<int>` 有什么异同。
