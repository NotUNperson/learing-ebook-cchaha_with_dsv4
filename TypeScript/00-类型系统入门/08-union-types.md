# 08 联合类型、类型别名与类型收窄

## 本节你会学到什么

- 理解联合类型 `|` 的含义：一个变量可以"是 A 类型，也可以是 B 类型"
- 掌握类型别名的用法：给复杂的类型起个简洁的名字
- 学会类型收窄：用 `typeof` 判断分支，让 TypeScript 知道"现在到底是哪种类型"
- 认识字面量联合类型：用 `|` 组合具体的字符串或数字，实现类似枚举的效果
- 了解联合类型在 C++ 中的对应物（`std::variant`）以及它们的关键区别

## 正文

上一节我们学了 `unknown`，在使用它之前需要用 `typeof` 判断类型。这引出一个更强大的概念：一个变量不只有一种类型，它可以是"类型 A **或者** 类型 B"。

### 联合类型：一个"或"字解决大问题

看一个真实需求：你在写一个函数，计算"折扣价"。折扣可以是**百分比**（比如打 8 折），也可以是**固定金额**（比如减 20 元）。一个参数怎么表示"可能是百分比，也可能是金额"？

```typescript
// percentage: 0.8 表示打八折
// fixed: 20 表示减 20 元
function calculateDiscount(price: number, discount: number | string) {
    // discount 可以是 number（固定金额），也可以是 string（如 "20%")
}
```

这里的 `number | string` 就是**联合类型**。"|" 读作"或"。`number | string` 表示"number 或 string"。

**生活类比**：你去超市结账，收银员问你"会员卡还是现金？"你只能选其中一种，不能两个同时用。联合类型就是这个概念——变量在**任一时刻**只能是联合中的某一种类型，不能同时是两个。就像你付款时要么刷卡要么付现金，不会同时干两件事。

C++ 也有类似的东西——`std::variant`（C++17）：

```cpp
// C++
std::variant<int, std::string> discount;
discount = 20;           // OK，现在是 int
discount = "20%";        // OK，现在变成 string
```

但 TypeScript 的联合类型比 `std::variant` 用起来自然得多。不需要 `std::get` 或者 `std::visit`，直接用 `typeof` 判断就够了。

### 类型收窄：让编译器知道"现在到底是哪个"

联合类型给了变量多种可能性，但在使用时你必须弄清楚"现在到底是哪种"。`typeof` 就是最好的工具——TypeScript 能理解 `typeof` 检查的分支，自动收窄类型：

```typescript
function printId(id: number | string) {
    if (typeof id === "string") {
        // 在这个分支里，TypeScript 知道 id 是 string
        console.log(id.toUpperCase());
    } else {
        // 在这个分支里，TypeScript 知道 id 是 number
        console.log(id.toFixed(2));
    }
}
```

TypeScript 的类型收窄非常智能。它不只看 `typeof`，还能理解：

- `typeof` 判断（如 `typeof x === "string"`）
- `instanceof` 判断（如 `x instanceof Date`）
- `in` 判断（如 `"name" in obj`）
- `Array.isArray` 判断
- 等值比较（如 `x === "hello"`）

这个概念在程序分析中叫**控制流分析**（Control Flow Analysis）。TypeScript 追踪你的 `if`/`else` 分支，知道在每个分支里变量被"排除了哪些可能性"。

**生活类比**：类型收窄就像快递分拣中心的传送带。包裹（变量）从传送带上过来，分拣员（typeof 判断）看到包裹上的标签："易碎品"走左边通道（string 分支）、"普通包裹"走右边通道（number 分支）。进了各自通道之后，工人们就可以按各自的方式处理了——左边的工人轻拿轻放（字符串操作），右边的工人直接堆叠（数学运算）。

### 类型别名：给长类型起个小名

联合类型的好处很明显，但有一个问题：如果一个复杂类型到处重复写，代码会变得很难看：

```typescript
// 恶心：每个函数都要写一大串
function foo(input: string | number | boolean | null) { ... }
function bar(input: string | number | boolean | null) { ... }
function baz(input: string | number | boolean | null) { ... }
```

用 `type` 关键字给这个联合类型起个名字，问题就解决了：

```typescript
// 类型别名：定义一个"自定义类型"
type AcceptableInput = string | number | boolean | null;

// 现在每个函数都只用写这个短名字
function foo(input: AcceptableInput) { ... }
function bar(input: AcceptableInput) { ... }
function baz(input: AcceptableInput) { ... }
```

`type` 不只是给联合类型起名，各种类型都可以起别名：

```typescript
type UserId = number;                              // 基本类型别名
type Point = [number, number];                     // 元组别名
type Callback = (data: string) => void;            // 函数类型别名
type Status = "loading" | "success" | "error";    // 字面量联合类型（最强大！）
```

**C++ 对比**：`type` 有点像 C++ 的 `using` 别名：

```cpp
using UserId = int;          // C++ 类型别名
using StringList = std::vector<std::string>;
```

### 字面量联合类型：枚举的轻量替代

最后这个 `Status` 的例子值得单独讲讲：

```typescript
type Status = "loading" | "success" | "error";
```

这里 `"loading"`、`"success"`、`"error"` 不是普通的 `string` 类型，而是**字面量类型**——类型就是具体的字符串值本身。把它们用 `|` 组合起来，就形成了一个"只能是这三个字符串之一"的类型。

这其实能替代枚举，而且更轻量：

```typescript
// 枚举写法（第 06 节）
enum Status { Loading, Success, Error }

// 字面量联合类型写法
type Status = "loading" | "success" | "error";

let state: Status = "loading";   // ✅ 只能是这三个字符串之一
// state = "waiting";            // ❌ 编译错误！
```

字面量联合类型的优势是：
- **零运行时开销**——它只存在于编译期，不生成任何 JavaScript 对象
- **更简洁**——不需要 `import`，直接定义
- **IDE 自动补全**——输入 `"` 后 IDE 会提示三个选项

枚举的优势是：
- 可以反向映射（数字枚举）
- 可以在运行时遍历所有成员
- 有命名空间，名字有组织感

对于简单场景，字面量联合类型往往更受欢迎。

## 动手试试

1. 写一个函数 `formatValue(value: number | string): string`，如果是 number 就返回 `value.toFixed(2)`，如果是 string 就返回 `value.trim()`。
2. 定义一个类型别名 `Id = number | string`，然后写两个函数 `getUser(id: Id)` 和 `deleteUser(id: Id)`。
3. 定义一个 `HttpMethod = "GET" | "POST" | "PUT" | "DELETE"` 类型，声明一个变量赋值为 `"GET"`，再尝试赋值为 `"PATCH"` 看报错。
4. 写一个函数 `area(shape: "circle" | "rectangle", ...dimensions)`：如果是 circle 接受一个半径参数，如果是 rectangle 接受两个边长参数。用类型收窄在分支里安全地计算面积。

## 本节小结

联合类型让变量同时接受多种类型（`A | B`），`type` 给复杂类型起简洁的别名，`typeof` 分支自动收窄类型让每种类型都能被安全处理——字面量联合类型还能替代简单枚举。

## 下一节预告

我们已经学完了类型系统入门的所有核心概念。下一节是本系列的收官之作——设计一副扑克牌的类型系统，把你学到的枚举、联合类型、数组、接口全部用上，完成一个完整的综合练习。
