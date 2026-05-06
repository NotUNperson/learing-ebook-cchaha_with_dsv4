# 06 枚举：数字枚举与字符串枚举

## 本节你会学到什么

- 理解枚举是什么，以及它解决了什么问题
- 掌握数字枚举的声明和使用，注意它和 C++ 枚举的关键差异
- 学会字符串枚举，这是 C++ 没有的东西
- 知道 TypeScript 枚举在运行时实际变成了什么（一个对象！）
- 认识到 TypeScript 枚举的陷阱：数字枚举允许反向映射和任意数字赋值

## 正文

假设你在写一个扑克牌游戏。你需要表示四种花色：红心、黑桃、方块、梅花。你可以用数字：

```typescript
// 糟糕的写法——"1"代表什么？看代码的人不知道
let suit = 1;
```

你也可以用字符串：

```typescript
// 好一点，但打字容易打错
let suit = "heart";  // 万一写成 "hart" 编译器也不会管
```

更好的方案是用**枚举**，给一组相关的常量起正式的名字：

```typescript
enum Suit {
    Hearts,    // 默认值是 0
    Spades,    // 1
    Diamonds,  // 2
    Clubs,     // 3
}

let mySuit: Suit = Suit.Hearts;  // 类型安全，不会拼错
```

枚举解决了什么问题？它把"魔法数字"（没有意义的原始数字）变成了有名字的符号，让代码读起来像自然语言。`Suit.Hearts` 比 `0` 清晰一百倍。

### 数字枚举：和 C++ 很像，但有坑

C++ 的数字枚举：

```cpp
enum Color { Red, Green, Blue };
// Red = 0, Green = 1, Blue = 2
```

TypeScript 的数字枚举：

```typescript
enum Color { Red, Green, Blue }
// Red = 0, Green = 1, Blue = 2
```

看起来几乎一样。但你也可以手动指定起始值：

```typescript
enum Status {
    OK = 200,
    BadRequest = 400,
    NotFound = 404,
}
```

**第一个关键区别**：TypeScript 的数字枚举支持**反向映射**。

```typescript
enum Color { Red, Green, Blue }
console.log(Color.Red);    // 0   —— 正向：名字 -> 数字
console.log(Color[0]);     // "Red" —— 反向：数字 -> 名字
```

这是 C++ 枚举做不到的。TypeScript 在运行时会生成一个双向的对象：既可以通过名字找到数字，也可以通过数字找到名字。这在你需要打印枚举值名称时很方便（比如要在日志里显示 "Color.Red" 而不是 "0"）。

**第一个陷阱**：数字枚举的类型检查很松散。

```typescript
enum Color { Red, Green, Blue }
let c: Color = Color.Red;
c = 999;  // ⚠️ 编译不会报错！数字枚举允许赋值任意数字
```

这是很多人踩过的坑。TypeScript 的数字枚举**不对值做范围检查**，任何数字都能赋给数字枚举类型的变量。这和 C++ 的 `enum class` 完全不同（C++ 的 `enum class` 必须显式转换）。

### 生活类比：老式拨盘电话 vs 手机通讯录

数字枚举就像一部老式拨盘电话。你拨 "01" 打给张三，拨 "02" 打给李四。但你拨 "99" 也能拨出去——虽然没人接，但电话不会阻止你拨这个号。TypeScript 的数字枚举就是这样：`Color.Red` 等于 `0`，但写 `999` 编译器也不拦你。

字符串枚举则像手机通讯录。你只能选通讯录里存了的名字（`Direction.Up`、`Direction.Down`），不能随便输入一个不存在的名字。

### 字符串枚举：C++ 没有，TypeScript 独有

TypeScript 支持**字符串枚举**，每个成员的值是一个字符串：

```typescript
enum Direction {
    Up = "UP",
    Down = "DOWN",
    Left = "LEFT",
    Right = "RIGHT",
}

let dir: Direction = Direction.Up;
// dir = "UP";  // ❌ 错误！即使值相同，类型是 Direction，不能直接赋字符串
```

字符串枚举有两个数字枚举没有的优势：
1. **不能反向映射**（`Direction["UP"]` 不行），但这是好事——你不会意外地把字符串当成枚举成员的索引。
2. **类型更安全**——你不能把任意字符串赋给字符串枚举类型的变量。只能赋枚举成员。

这一点很重要：对于字符串枚举，`Direction.Up` 的类型是 `Direction.Up`（字面量类型），不是 `Direction`，也不是 `string`。编译器知道它具体是哪个成员。

### TypeScript 枚举在运行时变成了什么？

这是从 C++ 过来的人最容易困惑的一点。C++ 的枚举在编译后就变成了整数——零开销，没有任何运行时结构。

TypeScript 的枚举在编译后会**变成一个 JavaScript 对象**：

```typescript
enum Color { Red, Green, Blue }
```

编译后大致变成：

```javascript
var Color;
(function (Color) {
    Color[Color["Red"] = 0] = "Red";
    Color[Color["Green"] = 1] = "Green";
    Color[Color["Blue"] = 2] = "Blue";
})(Color || (Color = {}));
```

这段代码做的事情是：创建一个对象 `{0: "Red", 1: "Green", 2: "Blue", Red: 0, Green: 1, Blue: 2}`。一个双向的映射表。

所以 TypeScript 的枚举不是零开销的。它在运行时是一个真实存在的对象。对于性能敏感的场景，有些人会改用 `const enum` 或者联合类型（第 08 节）。但对于学习阶段和个人项目，枚举完全没问题。

### C++ 对比总结

| 特性 | C++ enum | C++ enum class | TypeScript enum |
|------|----------|----------------|-----------------|
| 默认值 | 从 0 开始递增 | 从 0 开始递增 | 从 0 开始递增 |
| 自定义值 | 支持 | 支持 | 支持 |
| 字符串值 | 不支持 | 不支持 | 支持 |
| 类型安全 | 弱（自动转换int） | 强（不能隐式转换） | 数字枚举弱，字符串枚举强 |
| 运行时开销 | 零（编译成整数） | 零 | 生成对象 |
| 反向映射 | 不支持 | 不支持 | 数字枚举支持 |

## 动手试试

1. 声明一个数字枚举 `HttpStatus`，包含 OK=200, NotFound=404, ServerError=500。打印 `HttpStatus.OK` 和 `HttpStatus[404]`。
2. 试试把 `999` 赋给一个 `HttpStatus` 类型的变量，看编译器会不会报错。
3. 声明一个字符串枚举 `Role`，包含 Admin="ADMIN", User="USER", Guest="GUEST"。在 VS Code 里输入 `Role.` 看自动补全提示。
4. 把编译后的 JS 文件打开，看看你的枚举被编译成了什么样子。

## 本节小结

数字枚举类似 C++ 的 enum 但支持反向映射且类型检查更松散；字符串枚举是 TypeScript 独有的，类型更安全；不管哪种枚举，编译后都会变成一个 JavaScript 对象，不是零开销。

## 下一节预告

枚举让你定义"一组固定的值"。但如果你想让一个变量接受"任何类型"呢？下一节我们学 any 和 unknown——TypeScript 类型系统里的"逃生舱"。
