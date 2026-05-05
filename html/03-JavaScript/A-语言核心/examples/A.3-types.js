/**
 * A.3 基本数据类型 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.3-types.js
 */

// ============================================================
// 1. JavaScript 是动态类型语言
// 同一个变量可以先后存储不同类型的值
// ============================================================

let x = 42;
console.log("x =", x, "类型:", typeof x);    // number

x = "hello";
console.log("x =", x, "类型:", typeof x);    // string

x = true;
console.log("x =", x, "类型:", typeof x);    // boolean

// ============================================================
// 2. number -- 唯一的数字类型
// 整数和小数都是 number，没有 int/float 之分
// ============================================================

let integer = 42;
let floating = 3.14;
let negative = -10;
let scientific = 1.5e6;          // 科学计数法 = 1500000

console.log("\n========== number 类型 ==========");
console.log("整数:", integer, "类型:", typeof integer);
console.log("小数:", floating, "类型:", typeof floating);
console.log("负数:", negative, "类型:", typeof negative);
console.log("科学计数:", scientific, "类型:", typeof scientific);

// number 的特殊值
console.log("\n特殊 number 值:");
console.log("NaN:", NaN, "类型:", typeof NaN);          // NaN -- "不是数字的数字"
console.log("Infinity:", Infinity, "类型:", typeof Infinity);  // 无穷大
console.log("-Infinity:", -Infinity, "类型:", typeof -Infinity);

// NaN 示例
console.log("0 / 0 =", 0 / 0);             // NaN
console.log("1 / 0 =", 1 / 0);             // Infinity
console.log(-1 / 0, "=", -Infinity);       // -Infinity

// NaN 的一个怪癖：NaN 不等于 NaN
console.log("NaN === NaN:", NaN === NaN);   // false -- NaN 是唯一不等于自己的值！

// ============================================================
// 3. string -- 字符串
// 单引号、双引号、反引号都可以
// ============================================================

console.log("\n========== string 类型 ==========");

let s1 = '单引号字符串';
let s2 = "双引号字符串";
let s3 = `反引号字符串`;   // ES6 模板字面量

console.log(s1);
console.log(s2);
console.log(s3);

// 单双引号互相嵌套
let sentence = "He said, 'JavaScript is fun!'";
let another = '这是"加粗"的文字';

console.log(sentence);
console.log(another);

// 字符串拼接用 + （后面会详细讲）
let firstName = "张";
let lastName = "三";
let fullName = firstName + lastName;
console.log("全名:", fullName);  // "张三"

// ============================================================
// 4. boolean -- 布尔值
// true 和 false，不是 1 和 0
// ============================================================

console.log("\n========== boolean 类型 ==========");

let isAdult = true;
let hasPermission = false;

console.log("isAdult:", isAdult, "类型:", typeof isAdult);
console.log("hasPermission:", hasPermission, "类型:", typeof hasPermission);

// 比较运算产生布尔值
console.log("10 > 5:", 10 > 5);         // true
console.log("10 < 5:", 10 < 5);         // false
console.log("10 === 5:", 10 === 5);     // false

// ============================================================
// 5. null 和 undefined -- 两种"空"
// ============================================================

console.log("\n========== null 和 undefined ==========");

// undefined：声明了但没赋值
let notAssigned;
console.log("未赋值的变量:", notAssigned);          // undefined
console.log("typeof undefined:", typeof undefined);  // "undefined"

// null：程序员主动设为空
let empty = null;
console.log("null 值:", empty);                    // null
console.log("typeof null:", typeof null);           // "object" ← 著名的 bug！

// null == undefined 是 true，但 null === undefined 是 false
console.log("null == undefined:", null == undefined);   // true
console.log("null === undefined:", null === undefined); // false

// ============================================================
// 6. symbol -- 唯一标识符（了解即可）
// ============================================================

console.log("\n========== symbol 类型 ==========");

const sym1 = Symbol("id");
const sym2 = Symbol("id");
console.log("sym1:", sym1.toString());
console.log("sym2:", sym2.toString());
console.log("sym1 === sym2:", sym1 === sym2);  // false -- 每个 Symbol 都是唯一的
console.log("typeof sym1:", typeof sym1);       // "symbol"

// ============================================================
// 7. bigint -- 超大整数（了解即可）
// ============================================================

console.log("\n========== bigint 类型 ==========");

const bigNum = 9007199254740991n;   // n 后缀表示 bigint
const bigger = 12345678901234567890n;
console.log("bigNum:", bigNum);
console.log("typeof bigNum:", typeof bigNum);  // "bigint"

// bigint 和普通 number 不能直接混合运算
// const result = bigNum + 1;  // 报错！TypeError
const result = bigNum + 1n;     // 正确 -- 两边都是 bigint
console.log("bigNum + 1n =", result);

// ============================================================
// 小结：
// - JS 有 7 种原始类型
// - number 没有 int/float 之分
// - string 单双引号均可
// - null 是主动空，undefined 是默认空
// - typeof null === "object" 是历史 bug
// - symbol 创建唯一值，bigint 处理超大整数
// ============================================================
