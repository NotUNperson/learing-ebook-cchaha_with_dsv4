/**
 * A.13 字符串操作 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.13-strings.js
 */

// ============================================================
// 1. 模板字面量 -- 反引号 ` ` 和 ${}
// ============================================================

console.log("========== 模板字面量 ==========");

let name = "小明";
let age = 25;

// 传统写法（拼接）
let msg1 = "大家好，我叫" + name + "，今年" + age + "岁了。";
console.log("传统写法:", msg1);

// 模板字面量（优雅！）
let msg2 = `大家好，我叫${name}，今年${age}岁了。`;
console.log("模板字面量:", msg2);

// ${} 里面可以是任意表达式
console.log("\n--- ${} 中的表达式 ---");
let a = 10;
let b = 20;
console.log(`${a} + ${b} = ${a + b}`);     // "10 + 20 = 30"

let price = 99.9;
let quantity = 3;
console.log(`总价：${price * quantity} 元`);  // "总价：299.7 元"

// 可以调用函数
function getStatus() {
    return "在线";
}
console.log(`用户状态：${getStatus()}`);

// 三元运算符
let isAdmin = true;
console.log(`角色：${isAdmin ? "管理员" : "普通用户"}`);

// ============================================================
// 2. 多行字符串
// ============================================================

console.log("\n========== 多行字符串 ==========");

// 传统写法（需要 \n）
let poem1 = "床前明月光，\n疑是地上霜。\n举头望明月，\n低头思故乡。";
console.log("传统写法:");
console.log(poem1);

// 模板字面量（直接换行）
let poem2 = `床前明月光，
疑是地上霜。
举头望明月，
低头思故乡。`;
console.log("\n模板字面量:");
console.log(poem2);

// ============================================================
// 3. 字符串不可变（Immutable）
// ============================================================

console.log("\n========== 字符串不可变 ==========");

let str = "hello";
console.log("原始字符串:", str);
str[0] = "H";  // 试图修改第一个字符
console.log("尝试修改后:", str);  // 还是 "hello" -- 没变！

// 要修改必须创建新字符串
let newStr = "H" + str.slice(1);
console.log("创建新字符串:", newStr);  // "Hello"

// ============================================================
// 4. 常用属性和方法
// ============================================================

console.log("\n========== 常用字符串方法 ==========");

// 4.1 length 长度
console.log("--- length ---");
console.log('"hello".length:', "hello".length);          // 5
console.log('"你好世界".length:', "你好世界".length);      // 4
console.log('"".length:', "".length);                    // 0

// 4.2 [] 索引（只读）
console.log("\n--- [] 索引 ---");
let s = "hello";
console.log("s[0]:", s[0]);   // "h"
console.log("s[1]:", s[1]);   // "e"
console.log("s[4]:", s[4]);   // "o"
console.log("s[5]:", s[5]);   // undefined（不报错）
console.log("s[-1]:", s[-1]); // undefined（没有 Python 的负数索引）

// 4.3 slice(start, end)
console.log("\n--- slice ---");
let js = "JavaScript";
console.log('slice(0, 4):', js.slice(0, 4));    // "Java"
console.log('slice(4):', js.slice(4));           // "Script"
console.log('slice(-6):', js.slice(-6));          // "Script"（从末尾数）
console.log('slice(0, -6):', js.slice(0, -6));   // "Java"（去掉最后 6 个）

// 4.4 substring -- 类似 slice 但不支持负数
console.log("\n--- substring ---");
console.log('substring(0, 4):', js.substring(0, 4));  // "Java"
console.log('substring(4):', js.substring(4));         // "Script"

// 4.5 indexOf / includes -- 查找
console.log("\n--- indexOf / includes ---");
let text = "Hello, World!";
console.log('indexOf("World"):', text.indexOf("World"));        // 7
console.log('indexOf("JavaScript"):', text.indexOf("JavaScript")); // -1
console.log('includes("World"):', text.includes("World"));       // true
console.log('includes("Java"):', text.includes("Java"));         // false

// 4.6 startsWith / endsWith
console.log("\n--- startsWith / endsWith ---");
let url = "https://example.com";
console.log('startsWith("https"):', url.startsWith("https"));  // true
console.log('startsWith("http"):', url.startsWith("http"));    // true
console.log('endsWith(".com"):', url.endsWith(".com"));        // true
console.log('endsWith(".org"):', url.endsWith(".org"));        // false

// 4.7 toUpperCase / toLowerCase
console.log("\n--- 大小写转换 ---");
console.log('"Hello".toUpperCase():', "Hello".toUpperCase());  // "HELLO"
console.log('"Hello".toLowerCase():', "Hello".toLowerCase());  // "hello"

// 4.8 trim -- 去首尾空格
console.log("\n--- trim ---");
let input = "   你好   ";
console.log('原始:', `"${input}"`);
console.log('trim后:', `"${input.trim()}"`);
console.log('trimStart:', `"${input.trimStart()}"`);  // "你好   "
console.log('trimEnd:', `"${input.trimEnd()}"`);      // "   你好"

// 4.9 replace -- 替换
console.log("\n--- replace ---");
let greeting = "Hello, World!";
console.log('替换 World:', greeting.replace("World", "JavaScript"));

let fruits = "apple banana apple";
console.log('替换第一个 apple:', fruits.replace("apple", "orange"));  // 只替换第一个

// 4.10 split -- 分割成数组
console.log("\n--- split ---");
let csv = "苹果,香蕉,橙子,葡萄";
console.log('按逗号分割:', csv.split(","));     // ["苹果", "香蕉", "橙子", "葡萄"]

let sentence = "JavaScript is fun";
console.log('按空格分割:', sentence.split(" "));  // ["JavaScript", "is", "fun"]

console.log('每个字符:', "hello".split(""));  // ["h", "e", "l", "l", "o"]

// ============================================================
// 5. 方法链式调用
// ============================================================

console.log("\n========== 方法链式调用 ==========");

let raw = "   Hello, World!   ";
let processed = raw.trim().toUpperCase().slice(0, 5);
console.log('raw.trim().toUpperCase().slice(0, 5):', processed);  // "HELLO"

// ============================================================
// 6. 实用示例：邮箱脱敏
// ============================================================

console.log("\n========== 实用示例：邮箱脱敏 ==========");

function maskEmail(email) {
    let atIndex = email.indexOf("@");
    if (atIndex <= 0) return email;  // 没有 @ 或 @ 在开头

    let username = email.slice(0, atIndex);
    let domain = email.slice(atIndex);

    // 用户名部分：只保留首尾字符，中间用 * 替代
    if (username.length <= 2) {
        return username[0] + "*" + domain;
    }
    let masked = username[0] + "*".repeat(username.length - 2) + username[username.length - 1];
    return masked + domain;
}

console.log(maskEmail("zhangsan@example.com"));  // z******n@example.com
console.log(maskEmail("a@b.com"));                // a*@b.com
console.log(maskEmail("admin@gmail.com"));        // a***n@gmail.com

// ============================================================
// 7. 实用示例：单词反转
// ============================================================

console.log("\n========== 实用示例：单词反转 ==========");

function reverseWords(sentence) {
    return sentence.split(" ").reverse().join(" ");
}

console.log(reverseWords("I love JavaScript"));     // "JavaScript love I"
console.log(reverseWords("你好 世界"));              // "世界 你好"

// ============================================================
// 小结：
// - 模板字面量 ` 和 ${} 让字符串拼接更优雅
// - 模板字面量天然支持多行
// - 字符串不可变，修改 = 创建新字符串
// - 常用方法：slice, indexOf, includes, startsWith/endsWith,
//   toUpperCase/LowerCase, trim, replace, split
// - 查更多方法：MDN String
// ============================================================
