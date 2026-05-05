// ============================================================
// A.28 事件循环 示例代码
// 运行方式：node examples/A.28-event-loop.js
// ============================================================

console.log("========== A.28 事件循环 ==========\n");

// ----------------------------------------------------------
// 1. 调用栈演示——函数的入栈和出栈
// ----------------------------------------------------------
console.log("1. 调用栈（Call Stack）演示：");

function baz() {
    console.log("  [栈] baz 执行中（栈顶）");
}
function bar() {
    console.log("  [栈] bar 开始（入栈）");
    baz();
    console.log("  [栈] bar 结束（baz 已出栈）");
}
function foo() {
    console.log("  [栈] foo 开始（入栈）");
    bar();
    console.log("  [栈] foo 结束（bar 已出栈）");
}

console.log("  [栈] 全局代码（栈底）");
foo();
console.log("  [栈] 回到全局（调用栈已清空）");

// ----------------------------------------------------------
// 2. 微任务 vs 宏任务的执行顺序——核心演示
// ----------------------------------------------------------
console.log("\n2. 微任务 vs 宏任务——谁先执行？");

// 先标记执行顺序的数组
const order = [];

// 宏任务：setTimeout
setTimeout(() => {
    order.push("timeout");
    console.log("  ※ setTimeout 回调（宏任务）执行");
}, 0);

// 微任务：Promise.then
Promise.resolve().then(() => {
    order.push("promise1");
    console.log("  ※ Promise.then 1（微任务）执行");

    // 在微任务里再添加一个微任务
    Promise.resolve().then(() => {
        order.push("promise2");
        console.log("  ※ Promise.then 2（嵌套微任务）执行");
    });
});

// 另一个微任务
Promise.resolve().then(() => {
    order.push("promise3");
    console.log("  ※ Promise.then 3（微任务）执行");
});

// 直接用 queueMicrotask 添加微任务
queueMicrotask(() => {
    order.push("microtask");
    console.log("  ※ queueMicrotask（微任务）执行");
});

// 同步代码
order.push("sync1");
console.log("  1. 同步代码开始");
order.push("sync2");
console.log("  2. 同步代码结束");

// 等所有异步完成后输出顺序
setTimeout(() => {
    console.log("\n  完整执行顺序:", order.join(" → "));
    console.log("  （微任务总是在宏任务之前执行）");
}, 50);

// ----------------------------------------------------------
// 3. setTimeout(fn, 0) 的真正含义
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n3. setTimeout(fn, 0) 的真正含义：");

    console.log("  A: 同步代码");
    setTimeout(() => console.log("  C: setTimeout 0"), 0);
    console.log("  B: 同步代码继续");

    console.log("  输出顺序：A → B → C");
    console.log("  原因：setTimeout(fn, 0) 把 fn 放入宏任务队列");
    console.log("        但当前同步代码必须先执行完");
}, 100);

// ----------------------------------------------------------
// 4. 综合演示——面试经典题
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n4. 面试经典事件循环题：");

    console.log("  -------- 代码 --------");
    console.log("  console.log('1');");
    console.log("  setTimeout(() => console.log('2'), 0);");
    console.log("  Promise.resolve()");
    console.log("    .then(() => console.log('3'))");
    console.log("    .then(() => {");
    console.log("      console.log('4');");
    console.log("      setTimeout(() => console.log('5'), 0);");
    console.log("    });");
    console.log("  console.log('6');");
    console.log("  ----------------------");

    console.log("  -------- 输出 --------");
    console.log("  1");  // 同步

    setTimeout(() => console.log("  2"), 0);  // 宏任务

    Promise.resolve()
        .then(() => {
            console.log("  3");  // 微任务
        })
        .then(() => {
            console.log("  4");  // 微任务
            setTimeout(() => console.log("  5"), 0);  // 微任务里添加宏任务
        });

    console.log("  6");  // 同步
    console.log("  ----------------------");

    console.log("\n  分析：");
    console.log("    同步: 1 → 6");
    console.log("    第一轮微任务: 3 → 4");
    console.log("    第一轮宏任务: 2");
    console.log("    第二轮微任务: （无）");
    console.log("    第二轮宏任务: 5");
    console.log("    最终: 1 → 6 → 3 → 4 → 2 → 5");
}, 200);

// ----------------------------------------------------------
// 5. 微任务内部添加微任务——会阻塞吗？
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n5. 微任务里加微任务——会一直占用：");

    let microtaskCount = 0;

    function addMicrotask() {
        microtaskCount++;
        if (microtaskCount <= 5) {
            console.log(`    微任务 #${microtaskCount}`);
            // 在微任务中再添加微任务——新的微任务在同一次 tick 中执行
            Promise.resolve().then(addMicrotask);
        }
    }

    Promise.resolve().then(() => {
        console.log("    开始嵌套微任务...");
        addMicrotask();
        console.log("    （新的微任务在当前 tick 全部清空）");
    });

    // 这个宏任务要等所有微任务清空后才执行
    setTimeout(() => {
        console.log("    ★ 宏任务终于执行了（微任务全部清空之后）");
    }, 0);
}, 350);

// ----------------------------------------------------------
// 6. 事件循环的生活类比总结
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n6. 生活类比总结：");

    console.log("  +---------------------------------------------------+");
    console.log("  |  小饭馆（JS 引擎）只有一个厨师（单线程）         |");
    console.log("  |                                                   |");
    console.log("  |  炒菜（同步代码）: 厨师正在炒，别人得等着        |");
    console.log("  |  炖汤（setTimeout）: 灶上炖着，厨师不站着等      |");
    console.log("  |  切菜要求（微任务）: 炒完这个菜马上切            |");
    console.log("  |  新的点菜单（宏任务）: 等切完菜再处理            |");
    console.log("  |                                                   |");
    console.log("  |  每次只炒一道菜（一个宏任务）                     |");
    console.log("  |  炒完先把切菜要求都处理了（清空微任务）           |");
    console.log("  |  然后才看有没有新点单（下一个宏任务）             |");
    console.log("  +---------------------------------------------------+");

    console.log("\n  核心规则：");
    console.log("    1. 同步代码优先（厨师先把手里的事做完）");
    console.log("    2. 微任务其次（切菜请求，当前这道菜做完立即处理）");
    console.log("    3. 宏任务最后（新点单，下一轮再处理）");
}, 500);

console.log("\n========== 事件循环 演示结束 ==========");
