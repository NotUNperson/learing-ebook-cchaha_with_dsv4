/**
 * 我的 TypeScript 工程
 * 入口文件
 */

// 使用路径别名导入工具函数
import { greet, add } from "@/utils/helpers";
import * as path from "path";

function main(): void {
  console.log("=== TypeScript 工程模板启动 ===");
  console.log(greet("TypeScript 学习者"));
  console.log(`当前工作目录：${path.resolve(".")}`);
  console.log(`3 + 5 = ${add(3, 5)}`);
}

main();
