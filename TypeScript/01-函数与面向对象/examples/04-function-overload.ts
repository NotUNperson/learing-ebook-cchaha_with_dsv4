/**
 * 04-function-overload.ts
 * 主题：函数重载——多重签名 + 单一实现
 *
 * 本节演示 TypeScript 独特的函数重载方式，
 * 并与 C++ 的函数重载进行对比。
 * 核心概念：重载签名（菜单）+ 实现签名（厨房）
 */

// ==================== 基础示例：getInfo ====================

/**
 * 重载签名 1：传入数字 ID，返回字符串格式的用户信息
 */
function getInfo(id: number): string;

/**
 * 重载签名 2：传入名字字符串，返回对象格式的用户信息
 */
function getInfo(name: string): object;

/**
 * 实现签名：真正干活的函数
 * - 参数类型是 number | string（覆盖两个重载签名）
 * - 返回值类型是 string | object（覆盖两个重载签名）
 * - 实现签名对调用者不可见——调用者只能看到两个重载签名
 */
function getInfo(input: number | string): string | object {
    if (typeof input === "number") {
        // 按 ID 查找，返回简单字符串
        return `用户 #${input} 的信息`;
    } else {
        // 按名字查找，返回一个对象
        return { name: input, id: Math.floor(Math.random() * 10000) };
    }
}

// 调用时 TypeScript 知道精确的返回类型：
const infoById = getInfo(42);        // infoById 的类型是 string
const infoByName = getInfo("张三");  // infoByName 的类型是 object

console.log("按 ID 查询:", infoById);
console.log("按名字查询:", JSON.stringify(infoByName));


// ==================== 对比：不用重载的问题 ====================

/**
 * 如果用联合类型，TypeScript 不知道参数和返回值的对应关系
 */
function getInfoNoOverload(id: number | string): string | object {
    if (typeof id === "number") {
        return `用户 #${id}`;
    } else {
        return { name: id, id: 0 };
    }
}

const resultNoOverload = getInfoNoOverload(42);
// resultNoOverload 的类型是 string | object
// 每次使用前都要判断类型，很不方便
if (typeof resultNoOverload === "string") {
    console.log("（无重载版本）结果:", resultNoOverload.toUpperCase());
}


// ==================== 重载示例：类型转换 ====================

/**
 * convert 函数：输入什么类型，返回相反的类型
 * 这是重载的经典场景——参数类型和返回值类型有关系
 */
function convert(value: number): string;
function convert(value: string): number;
function convert(value: number | string): number | string {
    if (typeof value === "number") {
        return value.toString();       // 数字 → 字符串
    } else {
        return parseInt(value, 10);    // 字符串 → 数字
    }
}

const strResult = convert(100);    // strResult 的类型是 string
const numResult = convert("200");  // numResult 的类型是 number

console.log("convert(100) =", strResult, "| 类型:", typeof strResult);
console.log('convert("200") =', numResult, "| 类型:", typeof numResult);


// ==================== 重载示例：日期格式化 ====================

/**
 * 重载签名 1：传入时间戳（毫秒数）
 */
function formatDate(timestamp: number): string;

/**
 * 重载签名 2：传入 Date 对象
 */
function formatDate(date: Date): string;

/**
 * 重载签名 3：传入年、月、日三个数字
 */
function formatDate(year: number, month: number, day: number): string;

/**
 * 实现签名：处理所有三种情况
 * 注意：arg2 和 arg3 是可选的（只有第三种调用方式需要它们）
 */
function formatDate(
    arg1: number | Date,
    arg2?: number,
    arg3?: number
): string {
    // 情况 2：arg1 是 Date 对象
    if (arg1 instanceof Date) {
        const y = arg1.getFullYear();
        const m = (arg1.getMonth() + 1).toString().padStart(2, "0");
        const d = arg1.getDate().toString().padStart(2, "0");
        return `${y}-${m}-${d}`;
    }
    // 情况 3：传了三个数字（年、月、日）
    else if (arg2 !== undefined && arg3 !== undefined) {
        const m = arg2.toString().padStart(2, "0");
        const d = arg3.toString().padStart(2, "0");
        return `${arg1}-${m}-${d}`;
    }
    // 情况 1：arg1 是时间戳数字
    else {
        const date = new Date(arg1);
        const y = date.getFullYear();
        const m = (date.getMonth() + 1).toString().padStart(2, "0");
        const d = date.getDate().toString().padStart(2, "0");
        return `${y}-${m}-${d}`;
    }
}

// 三种调用方式
console.log("时间戳方式:", formatDate(1685548800000));  // 2023-05-31 的某个时刻
console.log("Date对象方式:", formatDate(new Date(2024, 0, 15)));  // 2024-01-15
console.log("年月日方式:", formatDate(2024, 12, 25));  // 2024-12-25


// ==================== 重载注意事项 ====================

/**
 * 重要：重载签名的顺序是从上到下匹配的
 * 应该把更具体的签名放在上面
 */

// 好例子：具体类型在前
function process(input: "yes" | "no"): boolean;   // 字面量类型，更具体
function process(input: string): string;           // 通用 string
function process(input: string): string | boolean {
    if (input === "yes") return true;
    if (input === "no") return false;
    return input.toUpperCase();
}

console.log('process("yes") =', process("yes"));     // true
console.log('process("hello") =', process("hello")); // "HELLO"


// ==================== 动手试试答案参考 ====================

/**
 * calculate 函数的重载
 *
 * 重载 1：两个数字 + 操作符
 * 重载 2：数字数组（求总和）
 * 重载 3：计算表达式字符串
 */

// 重载签名
function calculate(a: number, b: number, operator: "add" | "subtract" | "multiply" | "divide"): number;
function calculate(numbers: number[]): number;
function calculate(expression: string): number;

// 实现签名
function calculate(
    arg1: number | number[] | string,
    arg2?: number | string,
    arg3?: string
): number {
    // 情况 3：字符串表达式，如 "3+5"
    if (typeof arg1 === "string") {
        // 简单解析：找操作符位置
        const match = arg1.match(/(\d+)\s*([\+\-\*\/])\s*(\d+)/);
        if (!match) throw new Error("无效的表达式");
        const left = parseInt(match[1], 10);
        const op = match[2];
        const right = parseInt(match[3], 10);
        switch (op) {
            case "+": return left + right;
            case "-": return left - right;
            case "*": return left * right;
            case "/": return left / right;
            default: throw new Error("未知操作符");
        }
    }

    // 情况 2：数字数组
    if (Array.isArray(arg1)) {
        return arg1.reduce((sum, n) => sum + n, 0);
    }

    // 情况 1：两个数字 + 操作符
    const a = arg1 as number;
    const b = arg2 as number;
    const op = arg3 as string;

    switch (op) {
        case "add": return a + b;
        case "subtract": return a - b;
        case "multiply": return a * b;
        case "divide": return a / b;
        default: throw new Error("未知操作符");
    }
}

// 测试三种调用方式
console.log("calculate(10, 3, 'add') =", calculate(10, 3, "add"));         // 13
console.log("calculate([1, 2, 3, 4, 5]) =", calculate([1, 2, 3, 4, 5]));  // 15
console.log('calculate("3+5") =', calculate("3+5"));                       // 8
console.log('calculate("10/2") =', calculate("10/2"));                     // 5
