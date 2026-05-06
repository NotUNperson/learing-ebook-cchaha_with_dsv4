// ==========================================
// 02-variables.ts
// 演示 let、const、var 的区别与用法
// ==========================================

export {};  // 让这个文件成为一个独立的模块，避免全局作用域冲突

// --- 1. let：声明可变变量 ---
// 类比 C++ 的 int age = 25; ——可以修改值
let age: number = 25;
console.log("初始年龄:", age);

age = 26;  // 可以修改，没问题
console.log("一年后:", age);

// 不显式标注类型，TypeScript 也能自动推断
let score = 100;          // 推断为 number 类型
let playerName = "Tom";   // 推断为 string 类型
console.log(`${playerName} 的分数是 ${score}`);

// --- 2. const：声明不可变绑定 ---
// 类比 C++ 的 const int MAX = 100;
const MAX_SCORE = 100;
console.log("最高分:", MAX_SCORE);
// MAX_SCORE = 200;  // 编译错误！Cannot assign to 'MAX_SCORE' because it is a constant.

// ⚠️ 关键区别：const 只锁定"绑定"，不锁定"内容"！
// C++ 的 const 让对象本身不可修改；TypeScript 的 const 只是不让重新赋值
const colors = ["red", "blue"];     // colors 这个标签永久指向这个数组
colors.push("green");               // ✅ 可以！修改数组内容不影响标签
console.log("加了绿色后:", colors);
// colors = ["yellow"];              // ❌ 错误！不能把标签贴到另一个数组上

// const 对象也是同理
const player = { name: "Alice", hp: 100 };
player.hp = 80;                     // ✅ 可以修改对象属性
console.log("玩家受伤后:", player);
// player = { name: "Bob", hp: 100 }; // ❌ 错误！不能换一个对象

// --- 3. 块作用域：let/const vs var ---
// let 和 const 遵守块作用域——变量只在声明它的那块 {} 内可见

if (true) {
    let blockScoped = "我在 if 块里面";
    const alsoBlockScoped = "我也在 if 块里面";
    console.log("块内可以访问:", blockScoped);
}
// console.log(blockScoped);  // ❌ 编译错误！Cannot find name 'blockScoped'.
// 变量"死"在了 if 块的右花括号那里

// --- 4. var 的历史问题：函数作用域，不是块作用域 ---
// var 声明的变量会在整个函数里可见（或全局可见），忽略块边界

if (true) {
    var escaped = "我从 if 块逃出来了！";  // 用 var 声明
}
console.log(escaped);  // ✅ 可以访问！var 不受 {} 限制——这就是它的问题

// 对比：用 let 就不会逃出去
// if (true) {
//     let notEscaped = "我逃不出去";
// }
// console.log(notEscaped);  // ❌ 编译错误！

// 另一个 var 的问题：重复声明不出错
var x = 1;
var x = 2;  // var 允许重复声明同一个变量——这非常容易导致难以发现的 bug
console.log("x 被重复声明了:", x);

// let y = 1;
// let y = 2;  // ❌ 编译错误！用 let 重复声明会直接报错

// --- 5. 总结：声明变量的推荐做法 ---
// 1. 默认用 const——如果值不会重新赋值，先用 const 锁住
// 2. 需要重新赋值时用 let——比如循环计数器、状态变更
// 3. 永远不要用 var——它只有历史意义，所有现代代码都用 let/const
