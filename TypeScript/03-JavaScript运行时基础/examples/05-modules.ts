/**
 * 05-modules.ts —— 模块系统演示（主文件）
 *
 * 这个文件导入 05-utils.ts 提供的各种功能，展示：
 * 1. 命名导入
 * 2. 默认导入
 * 3. 类型导入
 * 4. 导入别名
 * 5. 对比 C++ #include vs JS import
 *
 * 运行方式：
 *   ts-node 05-modules.ts
 *
 * 如果用 tsc 编译，建议先设置 tsconfig.json 的 module 为 commonjs：
 *   tsc 05-modules.ts 05-utils.ts
 *   node 05-modules.js
 */

// ============================================================
// 第一部分：命名导入（Named Import）
// ============================================================

// 用花括号按名字导入，名字必须和导出时一致
import { add, subtract, PI, CALCULATOR_VERSION } from "./05-utils";

console.log("=== 第一部分：命名导入 ===");
console.log(`add(10, 5) = ${add(10, 5)}`);
console.log(`subtract(10, 5) = ${subtract(10, 5)}`);
console.log(`PI = ${PI}`);
console.log(`计算器版本：${CALCULATOR_VERSION}`);

// ============================================================
// 第二部分：默认导入（Default Import）
// ============================================================

// 默认导入不需要花括号，名字可以随便起
// 导出时叫 Calculator，导入时可以继续叫 Calculator，也可以叫别的
import MyCalc from "./05-utils"; // 这里叫 MyCalc，就是 Calculator 类

console.log("\n=== 第二部分：默认导入 ===");

const calc: MyCalc = new MyCalc();

// 做一些运算
const r1 = calc.calculate("add", 100, 50);
console.log(`${r1.operation}: ${r1.result}`);

const r2 = calc.calculate("multiply", 7, 8);
console.log(`${r2.operation}: ${r2.result}`);

// ============================================================
// 第三部分：导入别名（Import Alias）
// ============================================================

// 如果两个模块导出了同名的东西，或者你想换个名字，用 as
import { add as plus } from "./05-utils";

console.log("\n=== 第三部分：导入别名 ===");
console.log(`plus(99, 1) = ${plus(99, 1)}`); // 效果和 add 一样

// ============================================================
// 第四部分：类型导入
// ============================================================

// 导入接口和类型（TS 专属，编译后不会出现在 JS 中）
import type { CalculationResult, OperationType } from "./05-utils";

// 使用导入的类型标注变量
const latestResult: CalculationResult = calc.calculate("divide", 100, 4);
console.log("\n=== 第四部分：类型导入 ===");
console.log(
  `最新运算：${latestResult.operation} = ${latestResult.result}`
);
console.log(`时间：${latestResult.timestamp.toISOString()}`);

// 使用导入的类型作为变量的类型约束
const myOperation: OperationType = "add"; // 只能是这四种值之一
console.log(`当前操作：${myOperation}`);

// ============================================================
// 第五部分：查看计算历史
// ============================================================

console.log("\n=== 第五部分：运算历史 ===");

const history: CalculationResult[] = calc.getHistory();
history.forEach((record, index) => {
  console.log(
    `  ${index + 1}. ${record.operation}(...) = ${record.result} (${record.timestamp.toLocaleTimeString()})`
  );
});

// ============================================================
// 第六部分：对比 C++ #include vs JS import
// ============================================================

console.log("\n=== 第六部分：C++ #include vs JS import ===");

const comparison: string = `
┌─────────────────────┬──────────────────────────────┐
│    C++ #include     │       JS / TS import         │
├─────────────────────┼──────────────────────────────┤
│ 编译时（预处理器）    │ 运行时（由 JS 引擎解析）      │
│ 文本替换（粘贴内容）  │ 符号导入（只取用的东西）      │
│ 需要 #pragma once   │ 引擎自动处理，不重复加载       │
│ 或 #ifndef 防重复    │                              │
│ 循环引用可能出错     │ 可处理循环引用（但不推荐）      │
│ 导入内容进入当前作用域│ 不 import 就无法使用          │
│ 可在函数内部 #include│ import 必须在顶层             │
│                     │ （也有动态 import() 做例外）   │
└─────────────────────┴──────────────────────────────┘

一句话总结：
  #include 是 C 时代的"替身术" —— 编译器看到的实际上是拼接后的完整文本
  import   是 JS 时代的"领物单" —— 告诉运行环境"我需要这个名字的东西"
`;

console.log(comparison);

// ============================================================
// 第七部分：模块化思维 —— 工具箱类比
// ============================================================

console.log("=== 第七部分：模块化思维 ===");

const modularThinking: string = `
模块化的本质是"关注点分离"（Separation of Concerns）：

没有模块时：所有工具散落一地，变量满天飞
有模块后：  每个文件是一个"工具箱格子"，各司其职

本项目的组织：
  05-utils.ts  → 负责数学计算（工具函数 + Calculator 类）
  05-modules.ts → 负责主流程（使用计算工具，演示如何 import）

未来的真实项目可能会有：
  src/
    components/  → UI 组件
    services/    → API 请求
    utils/       → 通用工具函数
    types/       → TS 类型定义
    index.ts     → 入口文件，把所有模块串起来
`;

console.log(modularThinking);

console.log("\n演示完毕！");
