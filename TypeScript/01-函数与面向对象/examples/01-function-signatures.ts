/**
 * 01-function-signatures.ts
 * 主题：函数声明与类型签名
 *
 * 本节演示 TypeScript 中函数的参数类型标注和返回值类型标注，
 * 并与 C++ 的函数声明进行对比。
 */

// ==================== 基本函数声明 ====================

/**
 * 加法函数
 * - 参数 a 和 b 都需要标注为 number 类型
 * - 返回值类型标注在参数列表后面，用冒号隔开
 * - 对比 C++: int add(int a, int b)  →  TypeScript 把类型写在了参数名后面
 */
function add(a: number, b: number): number {
    return a + b;
}

// 正确调用
console.log("add(3, 5) =", add(3, 5));  // 输出: 8

// 下面的调用会报错，因为参数类型不匹配（你可以取消注释试试）：
// add(3, "5");  // 错误：类型 "string" 的参数不能赋给类型 "number" 的参数


// ==================== 无返回值的函数 (void) ====================

/**
 * 打印问候语的函数
 * - 参数 name 是 string 类型
 * - 返回值类型是 void，表示这个函数不返回任何值
 * - 对比 C++: void greet(string name) → TypeScript: greet(name: string): void
 */
function greet(name: string): void {
    console.log(`你好，${name}！欢迎学习 TypeScript。`);
}

greet("小明");  // 输出: 你好，小明！欢迎学习 TypeScript。


// ==================== 无参数的函数 ====================

/**
 * 没有参数、返回字符串的函数
 * - 空括号表示没有参数
 * - 返回值类型标注为 string
 */
function getGreeting(): string {
    return "Hello TypeScript!";
}

console.log(getGreeting());  // 输出: Hello TypeScript!


// ==================== 返回值类型推断 ====================

/**
 * 省略返回值类型标注
 * TypeScript 会根据 return 语句自动推断返回值是 number 类型
 * 虽然可以省略，但显式标注是更好的习惯——它能帮你在写错逻辑时立刻发现错误
 */
function multiply(x: number, y: number) {  // 注意：没有写返回值类型
    return x * y;  // TypeScript 自动推断返回值为 number
}

// result 的类型被推断为 number
const product = multiply(6, 7);
console.log("multiply(6, 7) =", product);  // 输出: 42


// ==================== 类型签名（Type Signature） ====================

/**
 * 类型签名描述了函数的参数类型和返回值类型，不包含函数体。
 * 可以把它理解为函数的"身份证"或"岗位要求"。
 *
 * (a: number, b: number) => number
 *
 * 拆解：
 * - (a: number, b: number)  → 参数列表：两个数字参数
 * - => number                → 返回值类型：数字
 */

// 声明一个变量，类型是"接收两个数字、返回数字的函数"
let calculate: (a: number, b: number) => number;

// 将符合签名的函数赋值给它
calculate = function subtract(x: number, y: number): number {
    return x - y;
};

console.log("calculate(10, 3) =", calculate(10, 3));  // 输出: 7

// 也可以把 add 函数赋值给它（因为 add 的签名和 calculate 兼容）
calculate = add;
console.log("calculate 现在是 add(10, 3) =", calculate(10, 3));  // 输出: 13


// ==================== 多个参数的函数 ====================

/**
 * 计算三个数的平均值
 * 参数标注可以在一行中连续书写，每个参数用逗号分隔
 */
function average(a: number, b: number, c: number): number {
    return (a + b + c) / 3;
}

console.log("average(80, 90, 100) =", average(80, 90, 100));  // 输出: 90


// ==================== 字符串返回值的函数 ====================

/**
 * 格式化分数显示
 * 演示字符串返回类型
 */
function formatScore(name: string, score: number): string {
    return `${name} 的成绩是 ${score} 分`;
}

console.log(formatScore("小红", 95));  // 输出: 小红 的成绩是 95 分
