# 09 综合练习：设计一副扑克牌的类型系统

## 本节你会学到什么

- 综合运用枚举、联合类型、类型别名、数组、接口来设计一个真实的类型系统
- 学习如何用 TypeScript 的类型系统"建模"现实世界的事物
- 掌握 `interface` 的基本概念——它是"描述对象形状"的工具
- 完成一个完整的练习：定义扑克牌类型，创建一副牌，实现洗牌和发牌

## 正文

前面八节我们分别学了变量声明、基本类型、类型推断、数组元组、枚举、any/unknown、联合类型。这一节我们来一场"期末考试"——用所有这些知识设计一副扑克牌的类型系统。

你会发现，当你把所有这些概念组合起来用时，TypeScript 的类型系统就从一个"知识清单"变成了一个真正有用的"设计工具"。就像拼乐高——单独看每一块没什么意思，但拼在一起就能搭出城堡。

### 第一步：分析"扑克牌"由什么组成

一副标准扑克牌有 54 张（52 张普通牌 + 大小王）。每张普通牌由两部分组成：

1. **花色**（Suit）：红心、黑桃、方块、梅花。这是固定的四种，适合用**枚举**。
2. **点数**（Rank）：A, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K。这也是固定值，适合用字面量联合类型，因为 A 在有些玩法里可以算 1 或 14。

此外还有大小王（Joker），这不是花色+点数的组合，而是完全不同的概念。

**生活类比**：设计类型系统就像设计表格。你要先想好表格里有哪些列（属性），每列是什么类型（数字？文字？枚举？），然后每一行就是一张具体的牌。

### 第二步：定义花色枚举

花色是一个经典的枚举场景——四种选择，不多不少：

```typescript
enum Suit {
    Hearts = "HEARTS",       // 红心
    Spades = "SPADES",       // 黑桃
    Diamonds = "DIAMONDS",   // 方块
    Clubs = "CLUBS",         // 梅花
}
```

为什么用字符串枚举而不是数字枚举？因为在打印牌的时候，`Suit.Hearts` 直接输出 `"HEARTS"` 比输出 `0` 更有可读性。而且在调试时，你看日志就能直接看懂花色，不需要去查 `0` 代表什么。

### 第三步：定义点数类型

点数可以用字面量联合类型，因为它是 13 个具体的值：

```typescript
type Rank = "A" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "10" | "J" | "Q" | "K";
```

注意 `"10"` 是字符串。也许用 `number` 看起来更"数学"，但 `"A"`、`"J"`、`"Q"`、`"K"` 不是数字，所以用 `string` 的联合类型最自然。

你可以同时定义一个函数，把点数映射到实际的数值（用于比大小）：

```typescript
function rankValue(rank: Rank): number {
    const map: Record<Rank, number> = {
        "A": 14, "2": 2, "3": 3, "4": 4, "5": 5,
        "6": 6, "7": 7, "8": 8, "9": 9, "10": 10,
        "J": 11, "Q": 12, "K": 13,
    };
    return map[rank];
}
```

这里用到的 `Record<Rank, number>` 也是一个类型——它表示"键是 Rank 类型、值是 number 类型的对象"。TypeScript 会确保你的 `map` 对象包含了 Rank 的每一个值（A 到 K 全部 13 个），少了任何一个编译器都会报错。这个特性叫**穷尽性检查**（exhaustiveness check），是 TypeScript 类型系统的一个强大能力。

### 第四步：用 interface 描述一张牌

`interface` 是 TypeScript 用来描述"对象的形状"的工具。它很像 C++ 的 `struct`（只描述数据，没有方法）：

```typescript
// 普通牌
interface Card {
    suit: Suit;       // 花色
    rank: Rank;       // 点数
}

// 大小王
interface Joker {
    isJoker: true;    // 用来区分大小王
    type: "small" | "big";  // 小王还是大王
}
```

一个 `Card` 对象就是一张普通牌，它必须有 `suit` 和 `rank` 两个属性，而且类型必须分别是 `Suit` 和 `Rank`。

然后我们用联合类型把普通牌和大小王组合起来：

```typescript
type PokerCard = Card | Joker;
```

这样 `PokerCard` 既可以是一张普通牌（有花色和点数），也可以是一张大小王（有 isJoker 标记和 type 属性）。

### C++ 对比

在 C++ 里，做类似的事情你需要：

```cpp
// C++ 方式（使用 std::variant）
enum class Suit { Hearts, Spades, Diamonds, Clubs };
enum class Rank { A, _2, _3, /* ... */ K };

struct Card {
    Suit suit;
    Rank rank;
};

struct Joker {
    bool isJoker = true;
    enum Type { Small, Big } type;
};

using PokerCard = std::variant<Card, Joker>;
```

TypeScript 的 `interface` 比 C++ 的 `struct` 更灵活——不需要定义构造函数，不需要写 `public:`，直接列出属性就行。而且 TypeScript 的类型别名 `PokerCard = Card | Joker` 比 C++ 的 `using PokerCard = std::variant<Card, Joker>` 用起来简单很多——不需要 `std::visit` 就能做类型收窄。

### 第五步：创建一副完整的牌

接下来，我们把 52 张普通牌全部生成出来：

```typescript
const SUITS: Suit[] = [Suit.Hearts, Suit.Spades, Suit.Diamonds, Suit.Clubs];
const RANKS: Rank[] = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];

function createDeck(): PokerCard[] {
    let deck: PokerCard[] = [];

    // 生成 52 张普通牌
    for (let suit of SUITS) {
        for (let rank of RANKS) {
            deck.push({ suit, rank });
        }
    }

    // 加上大小王
    deck.push({ isJoker: true, type: "small" });
    deck.push({ isJoker: true, type: "big" });

    return deck;
}
```

### 第六步：洗牌和发牌

洗牌用的是经典的 Fisher-Yates 洗牌算法：

```typescript
function shuffle(deck: PokerCard[]): PokerCard[] {
    let shuffled = [...deck];  // 不修改原数组，做一个拷贝
    for (let i = shuffled.length - 1; i > 0; i--) {
        let j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];  // 交换
    }
    return shuffled;
}
```

发牌就是数组切片：

```typescript
function deal(deck: PokerCard[], count: number): PokerCard[] {
    return deck.splice(0, count);  // 从顶部取 count 张牌
}
```

### 第七步：打印牌的显示

```typescript
function cardToString(card: PokerCard): string {
    if ("isJoker" in card) {
        // 大小王——用 in 运算符收窄
        return card.type === "big" ? "大王" : "小王";
    } else {
        // 普通牌——TypeScript 自动收窄为 Card 类型
        let suitSymbol = suitToSymbol(card.suit);
        return `${suitSymbol}${card.rank}`;
    }
}
```

这里用了 `"isJoker" in card` 来判断是大小王还是普通牌。这叫做 **`in` 运算符类型收窄**——TypeScript 看到 `isJoker` 是 `Joker` 接口独有的属性，就会在 `if` 分支里自动把 `card` 的类型收窄。

### 完整设计回顾

我们在一个练习中使用了：
- **枚举**（Suit）——表示四种固定的花色
- **字面量联合类型**（Rank）——表示 13 个固定的点数
- **接口**（Card、Joker）——描述对象的数据结构
- **联合类型**（PokerCard）——Card 或 Joker
- **类型别名**（Rank、PokerCard）——给类型起好记的名字
- **类型收窄**（`in` 运算符）——安全地区分大小王和普通牌
- **数组操作**（push、splice、map）——操作牌组
- **Record 工具类型**——确保映射表覆盖了所有可能值

这就是 TypeScript 类型系统的力量——你不仅是在写代码，还在用类型描述你业务领域里的真实概念。

## 动手试试

1. 运行 `examples/09-poker-exercise.ts`，看一副完整的扑克牌打印出来。
2. 修改花色枚举，给每个花色加上对应的中文显示（红心、黑桃、方块、梅花），在 `suitToSymbol` 旁边加一个 `suitToChinese` 函数。
3. 在 `cardToString` 函数里，把普通牌的显示改成中文格式，比如"红心 A"、"黑桃 K"。
4. 写一个 `compareCards` 函数，比较两张牌的大小（用 `rankValue` 函数），返回 -1（小于）、0（等于）、1（大于）。
5. 给斗地主发牌：3 个玩家每人 17 张，留 3 张底牌。打印每个玩家的手牌和底牌。

## 本节小结

用枚举管理花色、用字面量联合类型管理点数、用 interface 和联合类型描述牌的数据结构——把这些基础概念组合起来，你就有了用 TypeScript 类型系统建模现实世界的完整能力。

## 系列总结

恭喜你完成了全部 9 节 TypeScript 类型系统入门课程！

我们从 C++ 和 TypeScript 的宏观对比开始，经历了变量声明、基本类型、类型推断、数组元组、枚举、any/unknown、联合类型和类型收窄，最后用一个扑克牌的综合练习把所有知识串了起来。

这些就是 TypeScript 类型系统的核心基础。掌握了它们，你就能够：
- 看懂大多数 TypeScript 代码的类型标注
- 给自己写的代码加上类型保护
- 利用类型推断少写冗余代码
- 用联合类型和类型收窄处理复杂的分支逻辑
- 用 interface 和 type 设计数据结构

下一步你可以继续学习：函数类型的详细用法、泛型（`<T>`）、类与接口的关系、工具类型（Partial、Pick 等），以及 TypeScript 的配置文件 `tsconfig.json`。

编程愉快。
