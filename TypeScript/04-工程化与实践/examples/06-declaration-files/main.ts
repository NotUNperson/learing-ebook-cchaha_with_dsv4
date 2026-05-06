// ============================================================
// main.ts —— 练习：使用纯 JS 模块 math-utils.js
// ============================================================

// 目前这行会报错，因为 TypeScript 找不到 math-utils.js 的类型声明
// 你的任务：创建 math-utils.d.ts 来消除这个错误
import { add, subtract, multiply, divide, average } from "./math-utils";

// ---- 测试代码 ----
console.log("=== 声明文件练习 ===");

// 正确的调用
console.log("10 + 5 =", add(10, 5));
console.log("10 - 5 =", subtract(10, 5));
console.log("3 * 7 =", multiply(3, 7));
console.log("10 / 2 =", divide(10, 2));

// 平均值的正确调用
const scores = [85, 90, 78, 92, 88];
console.log("平均分：", average(scores));

// ---- 故意的错误调用（类型声明正确的话，下面几行应该报错） ----
// 取消注释下面那行，看看 TypeScript 会不会拦住你：
// const badAdd = add("hello", "world");  // 字符串不能做加法参数！

// 取消注释下面那行：
// const badAvg = average("not an array");  // 参数应该是数组！

// ---- 使用全局声明（在你的 types.d.ts 中声明 APP_NAME） ----
// 取消注释下面那行，看看 TypeScript 是否认识 APP_NAME：
// console.log("应用名称：", APP_NAME);

export {};
