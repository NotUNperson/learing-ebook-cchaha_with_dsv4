/**
 * A.6 比较与逻辑运算符 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.6-comparison.js
 */

// ============================================================
// 1. 比较运算符
// ============================================================

console.log("========== 比较运算符 ==========");

console.log("10 > 5:", 10 > 5);          // true
console.log("10 < 5:", 10 < 5);          // false
console.log("10 >= 10:", 10 >= 10);      // true
console.log("10 <= 9:", 10 <= 9);        // false

// 严格相等 vs 宽松相等（复习）
console.log("\n=== vs ==");
console.log('5 === "5":', 5 === "5");    // false -- 类型不同
console.log('5 == "5":', 5 == "5");      // true -- 自动转换类型
console.log('5 !== "5":', 5 !== "5");     // true
console.log('5 != "5":', 5 != "5");      // false

// ============================================================
// 2. 字符串比较
// ============================================================

console.log("\n========== 字符串比较 ==========");

console.log('"a" < "b":', "a" < "b");            // true
console.log('"apple" < "banana":', "apple" < "banana"); // true
console.log('"Apple" < "apple":', "Apple" < "apple");   // true -- 大写字母编码更小

// 字符串数字的比较陷阱
console.log('\n注意：字符串数字的比较是字典序！');
console.log('"10" > "2":', "10" > "2");   // false -- 字典序："1" < "2"
console.log('10 > 2:', 10 > 2);           // true -- 数字比较

// 正确做法：先转成数字再比较
console.log('Number("10") > Number("2"):', Number("10") > Number("2")); // true

// ============================================================
// 3. 逻辑运算符：&& || !
// ============================================================

console.log("\n========== 逻辑运算符 ==========");

// && 逻辑与
console.log("--- && 逻辑与 ---");
console.log("true && true:", true && true);       // true
console.log("true && false:", true && false);     // false
console.log("false && true:", false && true);     // false

let age = 20;
let hasTicket = true;
console.log("age >= 18 && hasTicket:", age >= 18 && hasTicket); // true

// || 逻辑或
console.log("\n--- || 逻辑或 ---");
console.log("true || false:", true || false);     // true
console.log("false || true:", false || true);     // true
console.log("false || false:", false || false);   // false

let isVIP = false;
let hasInvitation = true;
console.log("isVIP || hasInvitation:", isVIP || hasInvitation); // true

// ! 逻辑非
console.log("\n--- ! 逻辑非 ---");
console.log("!true:", !true);            // false
console.log("!false:", !false);          // true
console.log("!0:", !0);                  // true -- 0 是假值
console.log('!"hello":', !"hello");      // false -- 非空字符串是真值
console.log("!!" + '"hello":', !!"hello"); // true -- 双感叹号 = 转布尔值

// 双感叹号是 Boolean() 的简写
console.log("\n!! 和 Boolean() 等价：");
console.log("!!42 =", !!42);             // true
console.log("!!null =", !!null);         // false

// ============================================================
// 4. 短路求值
// ============================================================

console.log("\n========== 短路求值 ==========");

// && 短路：左边为假时，右边不执行
console.log("--- && 短路 ---");
false && console.log("这行永远不会打印");

let isLoggedIn = true;
isLoggedIn && console.log("欢迎回来！");  // 登录了才打印

isLoggedIn = false;
isLoggedIn && console.log("这行不会打印"); // 不打印

// || 短路：左边为真时，右边不执行
console.log("--- || 短路 ---");
true || console.log("这行永远不会打印");

// || 短路常见用法：设置默认值
console.log("\n--- || 设置默认值 ---");
let inputName = "";
let displayName1 = inputName || "匿名用户";
console.log("|| 默认值:", displayName1);  // "匿名用户"

// ============================================================
// 5. ?? 空值合并运算符 -- 比 || 更精确
// ============================================================

console.log("\n========== ?? 空值合并运算符 ==========");

// || 的问题：把 0 和 "" 也当"空"
console.log("--- || 的问题 ---");
let score = 0;
console.log("score || 60 =", score || 60);    // 60 -- 可能不是你想要的结果
console.log("score ?? 60 =", score ?? 60);    // 0  -- 正确！

let username = "";
console.log('username || "用户" =', username || "用户");   // "用户"
console.log('username ?? "用户" =', username ?? "用户");   // "" -- 空字符串被保留了

// ?? 只在 null/undefined 时用默认值
console.log("\n--- ?? 的正确行为 ---");
let val1 = null;
let val2 = undefined;
let val3 = 0;
let val4 = "";
let val5 = false;

console.log("null ?? '默认':", val1 ?? "默认");        // "默认"
console.log("undefined ?? '默认':", val2 ?? "默认");   // "默认"
console.log("0 ?? '默认':", val3 ?? "默认");           // 0  -- 保留了！
console.log("'' ?? '默认':", val4 ?? "默认");          // "" -- 保留了！
console.log("false ?? '默认':", val5 ?? "默认");        // false -- 保留了！

// ============================================================
// 6. 三元运算符
// ============================================================

console.log("\n========== 三元运算符 ==========");

// 语法：条件 ? 值1 : 值2
let userAge = 20;
let status = userAge >= 18 ? "成年人" : "未成年人";
console.log("userAge =", userAge, "-> status =", status);

// 三元运算符可以简洁地写在表达式中
let price = 100;
let discount = true;
let finalPrice = discount ? price * 0.8 : price;
console.log("原价:", price, "折扣后:", finalPrice);

// 嵌套三元（虽然可以用，但不要嵌套太深）
let examScore = 85;
let grade = examScore >= 90 ? "A" : examScore >= 80 ? "B" : examScore >= 70 ? "C" : "D";
console.log("分数:", examScore, "-> 等级:", grade);

// ============================================================
// 7. 综合示例：闰年判断
// ============================================================

console.log("\n========== 综合示例：闰年判断 ==========");

let year = 2024;
// 闰年规则：能被4整除但不能被100整除，或能被400整除
let isLeapYear = (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
console.log(year + "年是闰年吗？", isLeapYear);  // true

year = 1900;
isLeapYear = (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
console.log(year + "年是闰年吗？", isLeapYear);  // false

// ============================================================
// 小结：
// - 比较运算符和 C 一样，但用 === 而不是 ==
// - && || 支持短路求值，可写出简洁代码
// - ?? 比 || 更精确，只在 null/undefined 时取默认值
// - 三元运算符和 C 一模一样
// ============================================================
