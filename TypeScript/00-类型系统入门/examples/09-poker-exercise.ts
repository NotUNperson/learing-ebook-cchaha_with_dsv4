// ==========================================
// 09-poker-exercise.ts
// 综合练习：设计一副扑克牌的类型系统
//
// 使用到目前为止学到的所有概念：
//   枚举（Suit）、字面量联合类型（Rank）、
//   interface（Card、Joker）、联合类型（PokerCard）、
//   类型别名（Rank、PokerCard）、类型收窄（in 运算符）、
//   数组操作、Record 工具类型
// ==========================================

export {};  // 让这个文件成为一个独立的模块，避免全局作用域冲突

// ==========================================
// 第一步：定义花色枚举（第 06 节知识）
// ==========================================
// 用字符串枚举：打印时直接看到 "HEARTS" 而不是 0，更有可读性
enum Suit {
    Hearts = "HEARTS",       // 红心 ♥
    Spades = "SPADES",       // 黑桃 ♠
    Diamonds = "DIAMONDS",   // 方块 ♦
    Clubs = "CLUBS",         // 梅花 ♣
}

// 花色对应的符号显示
function suitToSymbol(suit: Suit): string {
    const symbols: Record<Suit, string> = {
        [Suit.Hearts]: "♥",
        [Suit.Spades]: "♠",
        [Suit.Diamonds]: "♦",
        [Suit.Clubs]: "♣",
    };
    return symbols[suit];
}

// 花色对应的中文显示
function suitToChinese(suit: Suit): string {
    const names: Record<Suit, string> = {
        [Suit.Hearts]: "红心",
        [Suit.Spades]: "黑桃",
        [Suit.Diamonds]: "方块",
        [Suit.Clubs]: "梅花",
    };
    return names[suit];
}

// ==========================================
// 第二步：定义点数类型（第 08 节知识）
// ==========================================
// 用字面量联合类型：A, J, Q, K 不是数字，所以用字符串联合最自然
type Rank = "A" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "10" | "J" | "Q" | "K";

// 点数对应的数值（用于比大小）
// Record<Rank, number>：要求对象包含 Rank 的每一个值，少一个编译就报错（穷尽性检查）
function rankValue(rank: Rank): number {
    const map: Record<Rank, number> = {
        "A": 14,    // 大多数扑克玩法中 A 最大
        "2": 2,
        "3": 3,
        "4": 4,
        "5": 5,
        "6": 6,
        "7": 7,
        "8": 8,
        "9": 9,
        "10": 10,
        "J": 11,
        "Q": 12,
        "K": 13,
    };
    return map[rank];
}

// ==========================================
// 第三步：定义牌的接口（第 09 节新概念：interface）
// ==========================================
// interface 描述对象"长什么样"——类似 C++ 的 struct

// 普通牌：有花色和点数
interface Card {
    suit: Suit;   // 花色，类型是 Suit 枚举
    rank: Rank;   // 点数，类型是 Rank 联合类型
}

// 大小王：和普通牌结构完全不同
// isJoker: true 用来区分大小王（类型收窄的关键标记）
interface Joker {
    isJoker: true;            // 固定为 true，作为类型收窄的判别标记
    type: "small" | "big";    // 小王还是大王
}

// 联合类型：一张牌要么是普通牌，要么是大小王（第 08 节知识）
type PokerCard = Card | Joker;

// ==========================================
// 第四步：创建整副牌
// ==========================================

const SUITS: Suit[] = [Suit.Hearts, Suit.Spades, Suit.Diamonds, Suit.Clubs];
const RANKS: Rank[] = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];

// 生成一副完整的 54 张牌（52 张普通牌 + 2 张大小王）
function createDeck(): PokerCard[] {
    let deck: PokerCard[] = [];

    // 双重循环生成 52 张普通牌：每种花色 x 每种点数
    for (let suit of SUITS) {
        for (let rank of RANKS) {
            deck.push({ suit, rank });  // 这是 Card 接口的对象
        }
    }

    // 加上大小王（Joker 接口的对象）
    deck.push({ isJoker: true, type: "small" });
    deck.push({ isJoker: true, type: "big" });

    return deck;
}

// ==========================================
// 第五步：洗牌（Fisher-Yates 算法）
// ==========================================

function shuffle(deck: PokerCard[]): PokerCard[] {
    // 复制一份数组，不修改原始牌组
    let shuffled = [...deck];

    // Fisher-Yates：从尾到头，每次随机交换当前位置和一个随机位置
    for (let i = shuffled.length - 1; i > 0; i--) {
        // 生成 0 到 i 之间的随机整数
        let j = Math.floor(Math.random() * (i + 1));
        // 解构赋值交换两个元素
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }

    return shuffled;
}

// ==========================================
// 第六步：发牌
// ==========================================

// 从牌堆顶部取 count 张牌（会修改原数组）
function deal(deck: PokerCard[], count: number): PokerCard[] {
    return deck.splice(0, count);
}

// ==========================================
// 第七步：牌的显示
// ==========================================

// 用类型收窄（第 07、08 节知识）区分大小王和普通牌
function cardToString(card: PokerCard): string {
    // "isJoker" in card 是类型收窄：
    //   如果 isJoker 存在于 card 上，说明它是 Joker 类型
    //   TypeScript 自动在这个分支里把 card 收窄为 Joker
    if ("isJoker" in card) {
        return card.type === "big" ? "🃏 大王" : "🃏 小王";
    }

    // 走到这个分支，TypeScript 知道 card 是 Card 类型
    // 所以可以安全地访问 card.suit 和 card.rank
    let symbol = suitToSymbol(card.suit);
    return `${symbol}${card.rank}`;
}

// 显示整手牌
function handToString(hand: PokerCard[]): string {
    return hand.map(cardToString).join("  ");
}

// ==========================================
// 第八步：比较两张牌的大小
// ==========================================

// 返回值：-1 表示 a < b，0 表示相等，1 表示 a > b
// 大小王比所有普通牌都大，大王 > 小王
function compareCards(a: PokerCard, b: PokerCard): number {
    // 先判断是不是大小王——用 "isJoker" in card 做类型收窄
    let aIsJoker = "isJoker" in a;
    let bIsJoker = "isJoker" in b;

    if (aIsJoker && bIsJoker) {
        // 两张大/小王：在 if 块内 TypeScript 不知 a.type 是否安全，
        // 但我们已经通过 "isJoker" in 确认了，使用类型断言来访问
        let aJoker = a as Joker;
        let bJoker = b as Joker;
        if (aJoker.type === "big" && bJoker.type === "small") return 1;
        if (aJoker.type === "small" && bJoker.type === "big") return -1;
        return 0;
    }

    if (aIsJoker) return 1;   // 大小王比普通牌大
    if (bIsJoker) return -1;  // 普通牌比大小王小

    // 都是普通牌：比较点数的数值
    // 使用类型断言告诉 TypeScript 我们知道这是 Card
    let aCard = a as Card;
    let bCard = b as Card;
    let aVal = rankValue(aCard.rank);
    let bVal = rankValue(bCard.rank);

    if (aVal > bVal) return 1;
    if (aVal < bVal) return -1;
    return 0;  // 点数相同（花色不影响大小）
}

// ==========================================
// 第九步：组装演示 —— 运行整个流程
// ==========================================

console.log("♠ ♥ ♦ ♣  扑克牌类型系统演示  ♣ ♦ ♥ ♠");
console.log("=".repeat(50));

// 1. 创建一副新牌
let deck = createDeck();
console.log(`\n创建了一副新牌，共 ${deck.length} 张`);

// 2. 展示前 5 张
console.log("\n前 5 张牌（按花色+点数顺序）：");
console.log(handToString(deck.slice(0, 5)));

// 3. 洗牌
let shuffled = shuffle(deck);
console.log("\n洗牌后的前 13 张牌：");
console.log(handToString(shuffled.slice(0, 13)));

// 4. 发牌——模拟斗地主：3 人各 17 张，留 3 张底牌
let remaining = [...shuffled];  // 重新复制一份

let player1Hand = deal(remaining, 17);
let player2Hand = deal(remaining, 17);
let player3Hand = deal(remaining, 17);
let bottomCards = remaining;    // 剩下的 3 张底牌

console.log("\n=== 斗地主发牌 ===");
console.log(`玩家 1（${player1Hand.length} 张）：${handToString(player1Hand)}`);
console.log(`玩家 2（${player2Hand.length} 张）：${handToString(player2Hand)}`);
console.log(`玩家 3（${player3Hand.length} 张）：${handToString(player3Hand)}`);
console.log(`底牌（${bottomCards.length} 张）：${handToString(bottomCards)}`);

// 5. 比大小演示
console.log("\n=== 比大小演示 ===");
let testCards: PokerCard[] = [
    { suit: Suit.Hearts, rank: "A" },       // 红心 A
    { suit: Suit.Clubs, rank: "K" },        // 梅花 K
    { isJoker: true, type: "small" },       // 小王
    { isJoker: true, type: "big" },         // 大王
];

for (let i = 0; i < testCards.length; i++) {
    for (let j = i + 1; j < testCards.length; j++) {
        let result = compareCards(testCards[i], testCards[j]);
        let symbol = result > 0 ? " > " : result < 0 ? " < " : " = ";
        console.log(`${cardToString(testCards[i])} ${symbol} ${cardToString(testCards[j])}`);
    }
}

// ==========================================
// 第十步：C++ 对比
// ==========================================
// C++ 等价写法（伪代码）：
//
// enum class Suit { Hearts, Spades, Diamonds, Clubs };
// using Rank = std::string;  // 或 enum class
// struct Card { Suit suit; Rank rank; };
// struct Joker { bool isJoker = true; enum { Small, Big } type; };
// using PokerCard = std::variant<Card, Joker>;
//
// 关键差异：
//   1. C++ 的 std::variant 需要 std::visit 来匹配类型
//      TypeScript 直接用 "isJoker" in card 做类型收窄
//   2. C++ 没有字面量联合类型
//      要用 enum class Rank { A, _2, ... K } 代替
//   3. TypeScript 的 interface 不需要写构造函数或 public:
