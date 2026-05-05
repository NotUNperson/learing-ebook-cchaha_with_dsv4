// ============================================================
// A.25 回调函数 示例代码
// 运行方式：node examples/A.25-callback.js
// ============================================================

console.log("========== A.25 回调函数 ==========\n");

// ----------------------------------------------------------
// 1. 回调的基本概念——把函数当参数传
// ----------------------------------------------------------
console.log("1. 回调基本概念：");

// 干洗店类比：把"回调函数"当电话号码留给对方
function dryClean(clothes, callback) {
    console.log(`  [干洗店] 开始清洗：${clothes}`);
    // 模拟洗衣服的过程（用延迟模拟）
    const result = `${clothes}（已洗干净）`;
    // 洗好了，打给你
    callback(null, result);
}

dryClean("羽绒服", function (err, result) {
    if (err) return console.log("  出错:", err);
    console.log(`  [用户] 收到通知：${result}`);
});

// ----------------------------------------------------------
// 2. 同步回调 vs 异步回调
// ----------------------------------------------------------
console.log("\n2. 同步回调 vs 异步回调：");

// 同步回调——马上执行（forEach/map/filter 等数组方法）
console.log("  同步回调（forEach）：");
const items = ["A", "B", "C"];
items.forEach(function (item, index) {
    console.log(`    forEach 回调 #${index}: ${item}`);
});
console.log("  forEach 全部完成（回调是同步的，立即执行）");

// 异步回调——不马上执行（setTimeout/setInterval/IO）
console.log("\n  异步回调（setTimeout）：");
console.log("    代码行1: 开始");

setTimeout(function () {
    console.log("    代码行3: setTimeout 回调执行（1秒后）");
}, 1000);

console.log("    代码行2: setTimeout 已设置，继续执行");
// 输出顺序：代码行1 → 代码行2 → （1秒后）代码行3

// 等 1.2 秒再继续，让异步回调有机会执行
// 注意：实际开发中不会这样等，这里是为了演示输出顺序
function wait(ms) {
    const start = Date.now();
    while (Date.now() - start < ms) { /* 忙等 */ }
}

// ----------------------------------------------------------
// 3. Node.js 错误优先回调模式
// ----------------------------------------------------------
console.log("\n3. Node.js 错误优先回调：");

// 模拟 fs.readFile——Node.js 经典模式
function simulatedReadFile(path, callback) {
    console.log(`  [读取] 开始读取文件：${path}`);

    // 模拟异步操作
    setTimeout(() => {
        // 模拟：一半概率成功，一半概率失败
        if (Math.random() < 0.5) {
            // 成功：第一个参数 null，第二个参数是结果
            callback(null, `<<${path} 的内容>>`);
        } else {
            // 失败：第一个参数是错误对象
            callback(new Error(`文件不存在：${path}`));
        }
    }, 100);
}

// 使用
simulatedReadFile("data.txt", function (err, data) {
    if (err) {
        console.log(`  [错误] ${err.message}`);
    } else {
        console.log(`  [成功] ${data}`);
    }
});

// 等一会再运行，让异步操作完成
setTimeout(() => {
    console.log("\n  --------------------");
}, 200);

// ----------------------------------------------------------
// 4. 回调地狱演示
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n4. 回调地狱（callback hell）演示：");

    // 模拟：依次读取三个文件
    // 每个读取依赖上一个的结果（这里的模拟只是演示嵌套结构）
    simulatedReadFile("a.txt", function (err, dataA) {
        if (err) {
            console.log("  读取 A 失败:", err.message);
            return;
        }
        console.log(`  A 完成: ${dataA}`);

        simulatedReadFile("b.txt", function (err, dataB) {
            if (err) {
                console.log("  读取 B 失败:", err.message);
                return;
            }
            console.log(`  B 完成: ${dataB}`);

            simulatedReadFile("c.txt", function (err, dataC) {
                if (err) {
                    console.log("  读取 C 失败:", err.message);
                    return;
                }
                console.log(`  C 完成: ${dataC}`);
                console.log(`  全部完成: ${dataA} + ${dataB} + ${dataC}`);
                // 如果还需要读 d.txt、e.txt...继续向右缩进！
            });
        });
    });
}, 700);

// ----------------------------------------------------------
// 5. 为什么需要解决回调地狱
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n5. 回调地狱的问题：");

    console.log("  问题1：代码向右不断缩进，可读性极差");
    console.log("  问题2：每一层都要写 if(err) 错误处理，代码重复");
    console.log("  问题3：中间的逻辑很难单独复用");
    console.log("  问题4：如果有并行需求（同时读 A 和 B），写起来更乱");

    console.log("  => 这就是为什么 ES6 引入了 Promise");
    console.log("  => 下节我们来看 Promise 如何优雅地解决这些问题");
}, 1500);

// ----------------------------------------------------------
// 6. 回调的实际应用——函数参数化
// ----------------------------------------------------------
console.log("\n6. 回调的应用——让函数变得更通用：");

// 不带回调：只能做一件事
function doubleArray(arr) {
    return arr.map(item => item * 2);
}

// 带回调：行为由调用者决定——更灵活！
function transformArray(arr, transformFn) {
    return arr.map(transformFn);
}

const nums = [1, 2, 3, 4, 5];

const doubled = transformArray(nums, n => n * 2);
const squared = transformArray(nums, n => n * n);
const asString = transformArray(nums, n => `数字${n}`);

console.log("  原数组:", nums);
console.log("  双倍:", doubled);
console.log("  平方:", squared);
console.log("  字符串:", asString);

// ----------------------------------------------------------
// 7. 模拟真实的文件读取流程（同步演示异步概念）
// ----------------------------------------------------------
console.log("\n7. 事件循环视角看异步回调：");

console.log("  1. 主程序开始");
console.log("  2. 调用 setTimeout(callback, 0)");
setTimeout(() => {
    console.log("  4. setTimeout 回调执行（虽然延迟为0，但在主程序之后）");
}, 0);
console.log("  3. 主程序继续执行");

// 延迟为 0 的回调不会立即执行！
// 它会被放入任务队列，等当前调用栈清空后才执行
// 这就是事件循环的核心机制（详见 A.28）

console.log("\n========== 回调函数 演示结束 ==========");
