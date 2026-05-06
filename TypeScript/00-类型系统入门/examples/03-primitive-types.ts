// ==========================================
// 03-primitive-types.ts
// 演示 TypeScript 的三种基本类型：number、string、boolean
// 以及 typeof 运算符的用法
// ==========================================

export {};  // 让这个文件成为一个独立的模块，避免全局作用域冲突

// ==========================================
// 一、number：所有数字的统一类型
// C++ 里数字分 int、float、double、short、long...
// TypeScript 只有一种：number（底层是 64 位双精度浮点数）
// ==========================================

let age: number = 25;           // 整数 -> number
let price: number = 9.99;       // 小数 -> 还是 number
let pi: number = 3.14159;       // 圆周率 -> number
let hex: number = 0xFF;         // 十六进制 -> 依然是 number（等于 255）
let binary: number = 0b1010;    // 二进制 -> number（等于 10）
let octal: number = 0o744;      // 八进制 -> number（等于 484）

console.log("整数 age:", age, typeof age);
console.log("小数 price:", price, typeof price);
console.log("十六进制 0xFF =", hex);
console.log("二进制 0b1010 =", binary);
console.log("八进制 0o744 =", octal);

// 特殊数字值
let infinity: number = Infinity;           // 正无穷
let negInfinity: number = -Infinity;       // 负无穷
let notANumber: number = NaN;              // 非数值（比如 0/0 的结果）
// NaN 的类型也是 number——这看起来矛盾，但 JS 底层就是这样设计的

console.log("正无穷 Infinity:", infinity, typeof infinity);
console.log("负无穷 -Infinity:", negInfinity, typeof negInfinity);
console.log("NaN:", notANumber, typeof NaN);  // typeof NaN 也是 "number"

// 数学运算
let sum = 10 + 20;              // 加法
let product = 5 * 6;            // 乘法
let quotient = 15 / 3;          // 除法（注意：结果永远是浮点数，JS 没有整数除法）
let remainder = 17 % 5;         // 取余，结果是 2
let power = 2 ** 10;            // 幂运算，2 的 10 次方 = 1024

console.log("10 + 20 =", sum);
console.log("5 * 6 =", product);
console.log("15 / 3 =", quotient);
console.log("17 % 5 =", remainder);
console.log("2 ** 10 =", power);

// ==========================================
// 二、string：用模板字符串拼接
// C++ 里 string 拼接要靠 + 或 printf
// TypeScript 的模板字符串 `${}` 直接嵌入变量，非常方便
// ==========================================

let singleQuote: string = '单引号也可以';
let doubleQuote: string = "双引号也可以";
let firstName: string = "张三";
let lastName: string = "三";

// 传统拼法（也能用，但不推荐）
let fullName1: string = lastName + " " + firstName;

// 模板字符串（推荐用法）
let fullName2: string = `${lastName} ${firstName}`;
// `${}` 的威力：里面可以放任意表达式，自动转换类型
let userAge: number = 25;
let intro: string = `我叫 ${fullName2}，今年 ${userAge} 岁，明年 ${userAge + 1} 岁`;
console.log(intro);

// 多行字符串也不需要 \n，直接换行就行
let multiLine: string = `
=== 用户信息 ===
姓名：${fullName2}
年龄：${userAge}
积分：${1000 * 2}
==============
`;
console.log(multiLine);

// C++ 对比：
// C++ 里你得写成：
// std::cout << "我叫 " << fullName2 << "，今年 " << userAge << " 岁，明年 " << userAge + 1 << " 岁";
// 或者用 printf("我叫 %s，今年 %d 岁，明年 %d 岁", fullName2.c_str(), userAge, userAge + 1);
// ——TypeScript 的模板字符串显然更干净

// ==========================================
// 三、boolean：只有 true 和 false，没有 C++ 的隐式转换陷阱
// ==========================================

let isActive: boolean = true;
let isComplete: boolean = false;

console.log("isActive =", isActive, typeof isActive);
console.log("isComplete =", isComplete, typeof isComplete);

// 比较运算的结果是 boolean
let isAdult: boolean = userAge >= 18;
let isSameName: boolean = firstName === lastName;  // === 严格相等，类似 C++ 的 ==
console.log("是否成年:", isAdult);
console.log("名是否等于姓:", isSameName);

// 逻辑运算
let canEnter: boolean = isAdult && isActive;   // 且：两个都 true 才 true
let needHelp: boolean = !isActive || !isAdult; // 或：一个 true 就 true
console.log("能入场吗:", canEnter);
console.log("需要帮助吗:", needHelp);

// ==========================================
// 四、typeof 运算符：查看变量的运行时类型
// 就像拿身份证读卡器刷一下，看它返回什么"种族"标签
// ==========================================

console.log("\n=== typeof 示范 ===");
console.log("typeof 42         ->", typeof 42);          // "number"
console.log("typeof 3.14       ->", typeof 3.14);        // "number"
console.log("typeof NaN        ->", typeof NaN);          // "number"（有点意外但没错）
console.log("typeof 'hello'    ->", typeof "hello");      // "string"
console.log("typeof true       ->", typeof true);         // "boolean"
console.log("typeof undefined  ->", typeof undefined);    // "undefined"
console.log("typeof null       ->", typeof null);         // "object" —— JavaScript 的历史 bug！
// typeof null 返回 "object" 是 JS 诞生时就有的 bug，TypeScript 继承了它

// 实用技巧：用 typeof 做运行时判断
function describeValue(value: any): string {
    let t = typeof value;
    if (t === "number") return `数字：${value}`;
    if (t === "string") return `文本：${value}`;
    if (t === "boolean") return `布尔值：${value}`;
    return `其他类型：${t}`;
}

console.log(describeValue(42));
console.log(describeValue("Hello"));
console.log(describeValue(true));
console.log(describeValue(null));      // 注意：typeof null 是 "object"
console.log(describeValue(undefined)); // typeof undefined 是 "undefined"
