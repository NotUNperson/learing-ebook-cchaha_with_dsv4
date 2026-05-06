// ==========================================
// 04-type-inference.ts
// 演示 TypeScript 的类型推断机制：
// 什么时候编译器能"猜"出类型，什么时候必须你自己写
// ==========================================

export {};  // 让这个文件成为一个独立的模块，避免全局作用域冲突

// ==========================================
// 一、基础类型推断：根据初始值自动推导
// ==========================================

// 以下声明都没有写类型标注，但 TypeScript 能从初始值推断出类型
let playerName = "Alice";       // 推断为 string
let score = 100;                // 推断为 number
let isOnline = true;            // 推断为 boolean
let items = ["sword", "shield", "potion"];  // 推断为 string[]
let player = { name: "Alice", hp: 100 };     // 推断为 { name: string; hp: number }

// 悬停在这些变量上，IDE 会显示推断出的类型。
// 推断出的类型和显式写出来是完全等价的。

console.log(playerName, score, isOnline);
console.log("物品:", items);
console.log("玩家:", player);

// ==========================================
// 二、函数返回值的类型推断
// ==========================================

// 返回值类型可以不写——TypeScript 从 return 语句推断
function add(a: number, b: number) {
    return a + b;  // 推断返回类型为 number
}

function greet(name: string) {
    return `Hello, ${name}!`;  // 推断返回类型为 string
}

function isPositive(n: number) {
    return n > 0;  // 推断返回类型为 boolean
}

// 注意：函数参数的类型标注不可省略！
// function addBad(a, b) { return a + b; }  // a 和 b 都会被推断为 any，失去类型检查

console.log(add(3, 4));
console.log(greet("Bob"));
console.log("5 是正数吗:", isPositive(5));

// ==========================================
// 三、什么时候必须显式标注类型
// ==========================================

// 情况 1：声明时没有初始值——编译器不知道你要什么类型
// let result;              // 推断为 any——类型不安全
let result: number;         // 显式标注——推荐
result = 42;                // 后面再赋值
console.log("result =", result);

// 情况 2：const 声明变量的字面量类型问题
// 用 const 声明基本类型时，TypeScript 会推断出"字面量类型"
const name1 = "Alice";      // 类型是 "Alice"（字面量类型），不是 string
const age1 = 25;            // 类型是 25（字面量类型），不是 number

// name1 = "Bob";           // ❌ 错误！const 不能重新赋值 + 类型不匹配
// 如果你想让它真的是 string 类型，用 let
let name2 = "Alice";        // 类型是 string

// 情况 3：你想要比推断结果更宽的类型
// TypeScript 推断：
let level = 1;              // 推断为 number
// 如果你想确保它只能是某些特定数字的联合类型，需要显式标注（第 08 节会细讲）

// ==========================================
// 四、类型推断在数组和对象上的表现
// ==========================================

// 数组推断：根据元素类型推断数组类型
let numbers = [1, 2, 3];            // 推断为 number[]
let mixed = [1, "hello", true];     // 推断为 (string | number | boolean)[]
// 当数组元素类型不一致时，TypeScript 推断为联合类型（第 08 节细讲）

console.log("纯数字数组:", numbers);
console.log("混合数组:", mixed);

// 对象推断：每个属性单独推断
let playerA = {
    name: "Alice",      // 推断为 string
    level: 42,          // 推断为 number
    isVip: false,       // 推断为 boolean
};
// playerA 的整体类型：{ name: string; level: number; isVip: boolean; }
console.log(playerA.name, "等级", playerA.level);

// 注意：`let playerA` 的对象属性推断为 string/number，不是字面量 "Alice"/42
// 和 const 声明的基本类型不同！只有 const 声明的基本类型才会是字面量类型

// ==========================================
// 五、对比 C++ 的 auto
// ==========================================
// C++ 的 auto 和 TS 的类型推断作用类似，但社区态度不同：
//   C++:  "用 auto 要谨慎，代码可读性可能降低"
//   TS:   "能推断就推断，少写类型更清爽"
//
// 区别的根本原因：
//   C++ 的类型标注在变量名前面（int x = 1），不写类型也不难看
//   TS 的类型标注在变量名后面（let x: number = 1），标注多了显得很冗长
//
// 另一个区别：TypeScript 支持字面量类型（"Alice" 型），C++ 没有

// ==========================================
// 六、利用 IDE 悬停查看推断结果
// ==========================================
// 在 VS Code 中，把鼠标悬停在任意变量名上，就能看到 TypeScript 推断的类型。
// 强烈建议养成这个习惯——写代码时随手悬停，加深对推断机制的理解。
