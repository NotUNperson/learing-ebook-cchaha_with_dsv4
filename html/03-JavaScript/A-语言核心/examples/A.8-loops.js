/**
 * A.8 循环 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.8-loops.js
 */

// ============================================================
// 1. for 循环 -- 经典三段式
// ============================================================

console.log("========== for 循环 ==========");

// 基础 for 循环
for (let i = 0; i < 5; i++) {
    console.log("i =", i);
}

// 计算 1 到 100 的和
console.log("\n--- 1 到 100 求和 ---");
let sum = 0;
for (let i = 1; i <= 100; i++) {
    sum += i;
}
console.log("1 + 2 + ... + 100 =", sum);  // 5050

// 倒序循环
console.log("\n--- 倒序循环 ---");
for (let i = 5; i > 0; i--) {
    console.log("倒计时:", i);
}
console.log("发射！");

// for 中的 let 变量作用域只在循环内
// console.log(i);  // 这里访问不到 i，会报错

// ============================================================
// 2. while 和 do-while
// ============================================================

console.log("\n========== while 循环 ==========");

let count = 0;
while (count < 5) {
    console.log("count =", count);
    count++;
}

// do-while：至少执行一次
console.log("\n========== do-while 循环 ==========");

let n = 10;
do {
    console.log("n =", n);  // 即使条件不满足，这行也会执行一次
    n++;
} while (n < 3);
console.log("循环结束后 n =", n);  // 11

// 对比：如果 n 一开始就不满足条件
let m = 10;
while (m < 3) {
    console.log("这行不会执行");  // 永远不会执行
}
console.log("while 循环根本没进入");

// ============================================================
// 3. break 和 continue
// ============================================================

console.log("\n========== break 和 continue ==========");

// break：提前退出循环
console.log("--- break 示例 ---");
for (let i = 0; i < 10; i++) {
    if (i === 5) {
        console.log("遇到 5，使用 break 退出循环");
        break;
    }
    console.log("检查:", i);
}

// continue：跳过当前迭代
console.log("\n--- continue 示例（只打印奇数）---");
for (let i = 0; i < 10; i++) {
    if (i % 2 === 0) {
        continue;  // 偶数跳过，不执行后面的 console.log
    }
    console.log("奇数:", i);
}

// 在 while 中使用 break
console.log("\n--- while 中使用 break ---");
let password = "";
let attempts = 0;
// 模拟密码检查
while (true) {
    attempts++;
    if (attempts > 3) {
        console.log("尝试次数过多，锁定！");
        break;
    }
    console.log("第", attempts, "次尝试...");
    // 在实际程序中，这里会检查密码
    if (attempts === 2) {
        console.log("密码正确，登录成功！");
        break;
    }
}

// ============================================================
// 4. for-of 循环 -- 遍历数组值（ES6）
// ============================================================

console.log("\n========== for-of 循环 ==========");

let fruits = ["苹果", "香蕉", "橙子", "葡萄"];

// 传统 for 写法
console.log("--- 传统 for ---");
for (let i = 0; i < fruits.length; i++) {
    console.log("索引", i, "=", fruits[i]);
}

// for-of：直接拿到值，不需要索引
console.log("\n--- for-of（推荐！）---");
for (let fruit of fruits) {
    console.log(fruit);
}

// for-of 遍历字符串
console.log("\n--- for-of 遍历字符串 ---");
let message = "Hello";
for (let char of message) {
    console.log(char);
}

// for-of 可以用来获取索引吗？可以，用 entries()
console.log("\n--- for-of 获取索引 ---");
for (let [index, fruit] of fruits.entries()) {
    console.log(index, ":", fruit);
}

// ============================================================
// 5. for-in 循环 -- 遍历对象属性键
// ============================================================

console.log("\n========== for-in 循环 ==========");

let person = {
    name: "小明",
    age: 25,
    city: "北京",
    occupation: "程序员"
};

for (let key in person) {
    console.log(key, ":", person[key]);
}

// 警告：不要用 for-in 遍历数组！
console.log("\n--- 危险的 for-in 遍历数组 ---");
let arr = [10, 20, 30];
arr.customProp = "我是自定义属性";

console.log("for-of（正确，只遍历元素）:");
for (let val of arr) {
    console.log("  元素:", val);  // 10, 20, 30
}

console.log("for-in（危险，会遍历到自定义属性）:");
for (let key in arr) {
    console.log("  键:", key, "值:", arr[key]);
    // 会输出 "0", "1", "2", "customProp"
}

// ============================================================
// 6. 综合示例：九九乘法表
// ============================================================

console.log("\n========== 九九乘法表 ==========");

for (let i = 1; i <= 9; i++) {
    let row = "";
    for (let j = 1; j <= i; j++) {
        let product = i * j;
        // 用空格对齐格式
        let entry = j + "x" + i + "=" + product;
        row += entry + (product < 10 ? "  " : " ");
    }
    console.log(row);
}

// ============================================================
// 7. 无限循环的预防
// ============================================================

// 下面的代码被注释掉了，运行会导致程序卡死
// while (true) {
//     console.log("无限循环！");
// }
// 按 Ctrl+C 可以强制终止 Node.js 程序

// 安全的写法：始终确保循环条件最终会变为 false
let safeCounter = 0;
while (safeCounter < 10) {
    safeCounter++;  // 确保每次迭代 counter 都在变化
    // 如果 counter 不增加，就会永远小于 10，变成无限循环
}

// ============================================================
// 小结：
// - for/while/do-while 和 C 一样
// - break/continue 和 C 一样
// - for-of 是遍历数组的推荐方式（直接拿到值）
// - for-in 用于遍历对象属性，不要用于数组
// ============================================================
