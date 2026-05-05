/**
 * A.9 函数声明与表达式 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.9-functions.js
 */

// ============================================================
// 1. 函数声明 -- 和 C 最像的写法
// ============================================================

console.log("========== 函数声明 ==========");

// 不需要写参数类型和返回类型
function add(a, b) {
    return a + b;
}

console.log("add(3, 5) =", add(3, 5));  // 8

// 没有 return 时，函数返回 undefined
function greet(name) {
    console.log("你好，" + name);
    // 没有 return 语句
}

let result = greet("小明");  // 打印 "你好，小明"
console.log("greet 的返回值:", result);  // undefined

// ============================================================
// 2. 函数表达式 -- 函数也是值！
// ============================================================

console.log("\n========== 函数表达式 ==========");

// 匿名函数赋值给变量
const multiply = function(a, b) {
    return a * b;
};

console.log("multiply(4, 5) =", multiply(4, 5));  // 20

// 函数表达式调用方式和函数声明完全一样
console.log("multiply(6, 7) =", multiply(6, 7));  // 42

// 把函数当成普通值一样处理
let myFunction = multiply;               // 赋值给另一个变量
console.log("myFunction(3, 4) =", myFunction(3, 4));  // 12

// ============================================================
// 3. 函数作为参数 -- 回调函数
// ============================================================

console.log("\n========== 函数作为参数（回调） ==========");

// execute 接收一个函数作为参数
function execute(fn, x, y) {
    console.log("执行函数，参数:", x, y);
    let result = fn(x, y);
    console.log("结果:", result);
    return result;
}

// 把函数直接作为参数传入
execute(multiply, 5, 6);   // 30
execute(add, 10, 20);      // 30

// 也可以直接传入匿名函数
execute(function(a, b) {
    return a - b;
}, 10, 3);  // 7

// ============================================================
// 4. 函数作为返回值 -- 高阶函数
// ============================================================

console.log("\n========== 函数作为返回值（高阶函数） ==========");

// 创建一个"乘法器"工厂
function createMultiplier(factor) {
    // 返回一个新函数，这个新函数"记住"了 factor
    return function(x) {
        return x * factor;
    };
}

const double = createMultiplier(2);
const triple = createMultiplier(3);
const tenTimes = createMultiplier(10);

console.log("double(5) =", double(5));     // 10
console.log("triple(5) =", triple(5));     // 15
console.log("tenTimes(5) =", tenTimes(5)); // 50

// ============================================================
// 5. 函数存储在数据结构中
// ============================================================

console.log("\n========== 函数存储在数组中 ==========");

const operations = [
    function(a, b) { return a + b; },   // [0] 加法
    function(a, b) { return a - b; },   // [1] 减法
    function(a, b) { return a * b; },   // [2] 乘法
    function(a, b) { return a / b; }    // [3] 除法
];

console.log("operations[0](10, 3) =", operations[0](10, 3));  // 13 (加法)
console.log("operations[1](10, 3) =", operations[1](10, 3));  // 7  (减法)
console.log("operations[2](10, 3) =", operations[2](10, 3));  // 30 (乘法)
console.log("operations[3](10, 3) =", operations[3](10, 3));  // 3.333... (除法)

// ============================================================
// 6. 提升（Hoisting）-- 函数声明 vs 函数表达式
// ============================================================

console.log("\n========== 提升（Hoisting） ==========");

// 函数声明可以在定义之前调用（会整体提升）
declaredFunc();  // 正常工作！

function declaredFunc() {
    console.log("函数声明被提升了，可以在定义前调用");
}

// 函数表达式不能在赋值前调用
// expressionFunc();  // 报错！Cannot access 'expressionFunc' before initialization

const expressionFunc = function() {
    console.log("函数表达式，只能在定义后调用");
};

expressionFunc();  // 正常！

// ============================================================
// 7. 综合示例：一个简单的高阶函数实用场景
// ============================================================

console.log("\n========== 综合示例 ==========");

// 模拟一个"处理数据"的流程
function processData(data, validator, transformer, logger) {
    console.log("开始处理数据...");

    // 1. 验证
    if (!validator(data)) {
        logger("验证失败");
        return null;
    }

    // 2. 转换
    let result = transformer(data);
    logger("处理成功");
    return result;
}

// 使用
const data = [1, 2, 3, 4, 5];

const isValid = function(arr) {
    return arr.length > 0;
};

const transform = function(arr) {
    let sum = 0;
    for (let num of arr) {
        sum += num;
    }
    return sum;
};

const log = function(message) {
    console.log("[日志]", message);
};

let processed = processData(data, isValid, transform, log);
console.log("处理结果:", processed);  // 15

// ============================================================
// 小结：
// - 函数声明 function name() {} -- 会整体提升
// - 函数表达式 const name = function() {}; -- 只提升变量名
// - 函数是一等公民：可赋值、传参、返回、存储
// - 这个思想是 JS 后续概念的基础
// ============================================================
