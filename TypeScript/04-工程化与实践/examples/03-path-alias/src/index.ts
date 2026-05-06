// ============================================================
// 练习：把所有相对路径 import 替换为 @/ 路径别名
// ============================================================

// ---- 原始版本（深层相对路径，看起来杂乱） ----
// import { formatDate } from "./utils/date";
// import { add, multiply } from "./utils/math";
// import { Button } from "./components/Button";

// ---- 你的任务：用 @/ 别名改写上面的 import ----
// （提示：tsconfig.json 已配置 @/* 映射到 src/*）
// 请在下方写出改写后的 import 语句：


// ---- 测试代码（不需要修改） ----
console.log("=== 路径别名测试 ===");
console.log("今天日期：", formatDate(new Date()));
console.log("3 + 5 =", add(3, 5));
console.log("4 * 7 =", multiply(4, 7));

const btn = new Button("提交");
btn.click();

export {};
