/**
 * A.7 条件分支 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.7-if-else.js
 */

// ============================================================
// 1. if / else if / else
// ============================================================

console.log("========== if / else if / else ==========");

let score = 85;

if (score >= 90) {
    console.log("分数", score, "-> 优秀");
} else if (score >= 80) {
    console.log("分数", score, "-> 良好");
} else if (score >= 60) {
    console.log("分数", score, "-> 及格");
} else {
    console.log("分数", score, "-> 不及格");
}

// 条件外面的括号可选（写了也行）
let temperature = 35;
if (temperature > 30) {
    console.log("天太热了！");
}

// 单行时 {} 可省略，但不推荐
if (temperature > 30) console.log("真的很热");

// 推荐始终使用 {} -- 即使只有一行
if (temperature > 30) {
    console.log("天气炎热，注意防暑");
}

// ============================================================
// 2. 真值和假值 -- JS 的重要概念
// ============================================================

console.log("\n========== 真值和假值 ==========");

// 只有 6 个假值
console.log("--- 假值测试（这些都不会执行 if 内部）---");

if (false)      { console.log("false 是假值 -- 这行不会打印"); }
if (0)          { console.log("0 是假值 -- 这行不会打印"); }
if (-0)         { console.log("-0 是假值 -- 这行不会打印"); }
if ("")         { console.log('"" 是假值 -- 这行不会打印'); }
if (null)       { console.log("null 是假值 -- 这行不会打印"); }
if (undefined)  { console.log("undefined 是假值 -- 这行不会打印"); }
if (NaN)        { console.log("NaN 是假值 -- 这行不会打印"); }

console.log("以上没有一个会打印，因为它们都是假值");

// 其余全是真值（包括一些令人吃惊的）
console.log("\n--- 真值测试（可能会让你吃惊）---");

if (true)     { console.log("true 是真值"); }
if (42)       { console.log("42 是真值"); }
if (-1)       { console.log("-1 是真值（负数也是真！）"); }
if ("hello")  { console.log('"hello" 是真值'); }
if (" ")      { console.log('" " 是真值（含空格也是真！）'); }
if ("0")      { console.log('"0" 是真值（字符串 "0" != 数字 0）'); }
if ([])       { console.log("[] 空数组是真值！"); }
if ({})       { console.log("{} 空对象也是真值！"); }
if (() => {}) { console.log("() => {} 函数也是真值！"); }

// ============================================================
// 3. 利用真值/假值简化代码
// ============================================================

console.log("\n========== 利用真值/假值简化判断 ==========");

// 检查变量是否"有效"（不是 null、undefined 或空字符串）
function greet(name) {
    // 传统写法：
    // if (name !== null && name !== undefined && name !== "") {
    //     console.log("你好，" + name);
    // } else {
    //     console.log("你好，匿名用户");
    // }

    // 利用真值简化：
    if (name) {
        console.log("你好，" + name);
    } else {
        console.log("你好，匿名用户");
    }
}

greet("小明");   // "你好，小明"
greet("");       // "你好，匿名用户" -- 空字符串是假值
greet(null);     // "你好，匿名用户"
greet(undefined); // "你好，匿名用户"

// 警告：空数组是真值！
let items = [];
if (items) {
    console.log("空数组是真值，所以这行会打印！");
    console.log("要检查数组是否为空，请用 items.length:", items.length);
}

// 正确检查空数组
if (items.length > 0) {
    console.log("数组有内容");
} else {
    console.log("数组是空的");
}

// ============================================================
// 4. switch / case
// ============================================================

console.log("\n========== switch / case ==========");

// switch 可以使用字符串！（比 C 强的地方）
let fruit = "apple";

switch (fruit) {
    case "apple":
        console.log("这是苹果，英文是 apple");
        break;
    case "banana":
        console.log("这是香蕉，英文是 banana");
        break;
    case "orange":
        console.log("这是橙子，英文是 orange");
        break;
    default:
        console.log("未知水果");
}

// 穿透（fall-through）-- 多个 case 共享执行体
console.log("\n--- case 穿透示例 ---");
let day = 3;
switch (day) {
    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
        console.log("今天是工作日");
        break;
    case 6:
    case 7:
        console.log("今天是周末");
        break;
    default:
        console.log("无效的星期数字");
}

// 数字也可以做 switch
console.log("\n--- 数字 switch ---");
let num = 2;
switch (num) {
    case 1:
        console.log("一");
        break;
    case 2:
        console.log("二");
        break;
    case 3:
        console.log("三");
        break;
    default:
        console.log("其他数字");
}

// ============================================================
// 5. 忘了 break 会怎样？（演示穿透）
// ============================================================

console.log("\n========== 忘了 break 的后果 ==========");

let grade = "B";
console.log("没有 break 时的穿透效果：");
switch (grade) {
    case "A":
        console.log("优秀");
        // 没有 break！会穿透到下一个 case
    case "B":
        console.log("良好");
        // 没有 break！
    case "C":
        console.log("及格");
        break;
    default:
        console.log("不及格");
}
// 输出：良好、及格 -- 因为从 B 开始执行，穿过 C，直到遇到 break

// ============================================================
// 6. 使用 if-else 的实用示例：判断正负零
// ============================================================

console.log("\n========== 实用示例：判断正负零 ==========");

function checkNumber(n) {
    if (n > 0) {
        console.log(n, "是正数");
    } else if (n < 0) {
        console.log(n, "是负数");
    } else {
        console.log(n, "是零");
    }
}

checkNumber(42);   // 正数
checkNumber(-7);   // 负数
checkNumber(0);    // 零

// ============================================================
// 小结：
// - if/else 和 switch 语法和 C 一样
// - switch 的 case 支持字符串（C 不支持）
// - 假值只有 6 个，{} 和 [] 都是真值
// - 利用真值/假值可以简化条件判断
// - switch 别忘了写 break
// ============================================================
