/**
 * 05-utils.ts —— 工具模块（被 05-modules.ts 导入）
 *
 * 这个文件负责提供各种工具函数，通过 export 导出给别的文件使用。
 * 它演示了三种导出方式：命名导出、默认导出、类型导出。
 *
 * 运行方式：这个文件不单独运行，请运行 05-modules.ts
 *   ts-node 05-modules.ts
 */

// ============================================================
// 第一部分：命名导出（Named Export）
// ============================================================

/**
 * 可以导出多个东西，每个都有自己的名字。
 * 导入时用花括号 { add, subtract } 按名字取。
 */

// 导出一个函数
export function add(a: number, b: number): number {
  return a + b;
}

export function subtract(a: number, b: number): number {
  return a - b;
}

// 导出一个常量
export const PI: number = 3.14159;

// 导出一个接口（TS 专属：编译后接口会被删除，但类型检查时有效）
export interface CalculationResult {
  operation: string;
  result: number;
  timestamp: Date;
}

// ============================================================
// 第二部分：默认导出（Default Export）
// ============================================================

/**
 * 一个文件只能有一个默认导出。
 * 通常用于"这个文件主要就提供这一个东西"的场景。
 * 导入时不用花括号，名字可以随便起。
 */

// 定义一个计算器类
class Calculator {
  private history: CalculationResult[] = [];

  /** 执行运算并记录历史 */
  calculate(operation: string, a: number, b: number): CalculationResult {
    let result: number;

    switch (operation) {
      case "add":
        result = a + b;
        break;
      case "subtract":
        result = a - b;
        break;
      case "multiply":
        result = a * b;
        break;
      case "divide":
        if (b === 0) {
          throw new Error("除数不能为零");
        }
        result = a / b;
        break;
      default:
        throw new Error(`不支持的运算：${operation}`);
    }

    const record: CalculationResult = {
      operation,
      result,
      timestamp: new Date(),
    };

    this.history.push(record);
    return record;
  }

  /** 获取所有运算历史 */
  getHistory(): CalculationResult[] {
    return [...this.history]; // 返回副本，不让外部直接改内部数组
  }
}

// 默认导出：导出整个 Calculator 类
// 导入时：import Calculator from "./05-utils"
export default Calculator;

// ============================================================
// 第三部分：也可以同时有默认导出和命名导出
// ============================================================

// 额外导出一个配置对象（命名导出）
export const CALCULATOR_VERSION: string = "1.0.0";

// 额外导出一个辅助类型
export type OperationType = "add" | "subtract" | "multiply" | "divide";
