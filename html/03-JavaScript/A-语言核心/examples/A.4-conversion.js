/**
 * A.4 类型判断与转换 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.4-conversion.js
 */

// ============================================================
// 1. typeof 的局限
// ============================================================

console.log("========== typeof 的局限 ==========");

// 局限一：null 返回 "object"（历史 bug）
console.log("typeof null:", typeof null);              // "object"
console.log("typeof undefined:", typeof undefined);    // "undefined"

// 局限二：数组、普通对象、Date 等都返回 "object"
console.log("typeof {}:", typeof {});                   // "object"
console.log("typeof []:", typeof []);                   // "object" -- 数组也是！
console.log("typeof new Date():", typeof new Date());   // "object"

// 如何真正判断数组？
console.log("Array.isArray([]):", Array.isArray([]));                // true
console.log("Array.isArray({}):", Array.isArray({}));                // false

// 使用 instanceof 判断对象类型
console.log("[] instanceof Array:", [] instanceof Array);            // true
console.log("{} instanceof Object:", {} instanceof Object);          // true
console.log("new Date() instanceof Date:", new Date() instanceof Date); // true

// ============================================================
// 2. 显式类型转换 -- String()
// ============================================================

console.log("\n========== String() 显式转换 ==========");

console.log('String(42):', String(42));              // "42"
console.log('String(3.14):', String(3.14));          // "3.14"
console.log('String(true):', String(true));          // "true"
console.log('String(false):', String(false));        // "false"
console.log('String(null):', String(null));          // "null"
console.log('String(undefined):', String(undefined));// "undefined"
console.log('String(NaN):', String(NaN));            // "NaN"

// ============================================================
// 3. 显式类型转换 -- Number()
// ============================================================

console.log("\n========== Number() 显式转换 ==========");

console.log('Number("42"):', Number("42"));          // 42
console.log('Number("3.14"):', Number("3.14"));      // 3.14
console.log('Number(""):', Number(""));              // 0 -- 空字符串 → 0
console.log('Number("abc"):', Number("abc"));        // NaN -- 解析不了
console.log('Number("100px"):', Number("100px"));    // NaN -- 包含非数字字符
console.log('Number(true):', Number(true));          // 1
console.log('Number(false):', Number(false));        // 0
console.log('Number(null):', Number(null));          // 0
console.log('Number(undefined):', Number(undefined));// NaN

// ============================================================
// 4. 显式类型转换 -- Boolean()
// 6 种假值：false, 0, "", null, undefined, NaN
// ============================================================

console.log("\n========== Boolean() 显式转换 ==========");

// 假值（falsy）
console.log("假值：");
console.log('Boolean(false):', Boolean(false));          // false
console.log('Boolean(0):', Boolean(0));                  // false
console.log('Boolean(-0):', Boolean(-0));                // false
console.log('Boolean("")', Boolean(""));                 // false
console.log('Boolean(null):', Boolean(null));            // false
console.log('Boolean(undefined):', Boolean(undefined));  // false
console.log('Boolean(NaN):', Boolean(NaN));              // false

// 真值（truthy）—— 包括一些新手觉得"应该算假"的值
console.log("\n真值（注意看！有些会让你惊讶）：");
console.log('Boolean([]):', Boolean([]));                // true -- 空数组是真！
console.log('Boolean({}):', Boolean({}));                // true -- 空对象也是真！
console.log('Boolean(" "):', Boolean(" "));              // true -- 含空格的字符串
console.log('Boolean("false"):', Boolean("false"));      // true -- 非空字符串是真
console.log('Boolean("0"):', Boolean("0"));              // true -- 字符串 "0" 不是数字 0

// ============================================================
// 5. 隐式类型转换 -- "自动挡"的惊喜与惊吓
// ============================================================

console.log("\n========== 隐式类型转换 ==========");

// + 号的双面性：看到字符串就变拼接
console.log("--- + 号的双面性 ---");
console.log('"5" + 2 =', "5" + 2);           // "52" -- 不是 7！
console.log('"5" + "2" =', "5" + "2");       // "52"
console.log('5 + 2 =', 5 + 2);               // 7 -- 没有字符串时才做加法
console.log('"Hello" + 2024 =', "Hello" + 2024); // "Hello2024"

// 计算顺序的影响
console.log('1 + "2" + 3 =', 1 + "2" + 3);   // "123"
console.log('1 + 2 + "3" =', 1 + 2 + "3");   // "33" -- 先算 1+2=3, 再 3+"3"="33"

// 其他运算符：- * / 会尝试把字符串转数字
console.log("\n--- 其他运算符的隐式转换 ---");
console.log('"6" - 2 =', "6" - 2);     // 4
console.log('"6" * "2" =', "6" * "2"); // 12
console.log('"6" / "2" =', "6" / "2"); // 3
console.log('"10" + 20 =', "10" + 20); // "1020" -- + 又变拼接了！
console.log('"10" - 20 =', "10" - 20); // -10

// ============================================================
// 6. == vs === -- 松等 vs 严等
// ============================================================

console.log("\n========== == vs ===");

// === 严格相等
console.log("--- === 严格相等 ---");
console.log("5 === 5:", 5 === 5);               // true
console.log('5 === "5":', 5 === "5");           // false -- 类型不同！
console.log("true === 1:", true === 1);         // false
console.log("null === undefined:", null === undefined); // false
console.log("null === null:", null === null);   // true

// == 宽松相等 -- 会做类型转换
console.log("\n--- == 宽松相等（注意看，有些结果反直觉）---");
console.log('5 == "5":', 5 == "5");             // true -- "5" 转成 5
console.log("true == 1:", true == 1);           // true -- true 转成 1
console.log("false == 0:", false == 0);         // true -- false 转成 0
console.log('"" == false:', "" == false);       // true
console.log("null == undefined:", null == undefined); // true -- 特例！
console.log("null == 0:", null == 0);           // false -- null 不转为 0
console.log("[] == false:", [] == false);       // true -- 有点"魔幻"的结果
console.log("[] == ![]:", [] == ![]);           // true -- 更魔幻了...

// 为什么 [] == false 是 true？
// [] 先转成字符串 ""，然后 "" 在布尔上下文中是 false
// 所以 "" == false 为 true

// 结论：日常编码用 ===
console.log("\n结论：日常应该默认使用 ===，它更安全、更可预测");
