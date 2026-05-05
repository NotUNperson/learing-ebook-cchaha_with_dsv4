// ============================================================
// A.27 async/await 示例代码
// 运行方式：node examples/A.27-async-await.js
// ============================================================

console.log("========== A.27 async/await ==========\n");

// ----------------------------------------------------------
// 1. async 函数——自动返回 Promise
// ----------------------------------------------------------
console.log("1. async 函数自动返回 Promise：");

async function simpleGreet() {
    return "你好，世界！";  // 自动变成 Promise.resolve("你好，世界！")
}

console.log("  simpleGreet() 返回的是:", simpleGreet());  // Promise { "你好，世界！" }

simpleGreet().then(msg => {
    console.log("  .then 拿到:", msg);
});

// 对比：和手动返回 Promise 效果完全一样
function manualGreet() {
    return Promise.resolve("你好，世界！");
}

// ----------------------------------------------------------
// 2. await——等待 Promise 完成
// ----------------------------------------------------------
console.log("\n2. await 等待 Promise 完成：");

// 模拟一个异步操作（如网络请求）
function fetchData(name, delay) {
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve(`数据来自 ${name}（耗时 ${delay}ms）`);
        }, delay);
    });
}

async function loadData() {
    console.log("  开始加载...");

    // await 暂停函数执行，等待 Promise 完成后拿到结果
    const data1 = await fetchData("服务器A", 500);
    console.log(`  收到: ${data1}`);

    const data2 = await fetchData("服务器B", 300);
    console.log(`  收到: ${data2}`);

    console.log("  加载完成！");
    return `${data1} + ${data2}`;
}

// 注意：loadData 是 async 函数，返回 Promise
loadData().then(final => {
    // 等所有 await 完成后才能拿到最终结果
    console.log(`  最终结果: ${final}`);
});

// 等一下
setTimeout(() => {
    console.log("\n  --------------------");
}, 1200);

// ----------------------------------------------------------
// 3. 错误处理——try/catch 包裹 await
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n3. try/catch 包裹 await——错误处理：");

    function riskyOperation(name, willFail) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                if (willFail) {
                    reject(new Error(`${name} 操作失败`));
                } else {
                    resolve(`${name} 操作成功`);
                }
            }, 200);
        });
    }

    async function doWork() {
        try {
            console.log("  尝试操作1（应该成功）...");
            const r1 = await riskyOperation("操作1", false);
            console.log(`  ${r1}`);

            console.log("  尝试操作2（会失败）...");
            const r2 = await riskyOperation("操作2", true);
            console.log(`  ${r2}`);  // 这行不会执行

        } catch (err) {
            console.log(`  [捕获错误] ${err.message}`);
            // 可以在这里做恢复操作，或者重新抛出
        } finally {
            console.log("  操作结束（finally）");
        }
    }

    doWork();
}, 1500);

// ----------------------------------------------------------
// 4. 串行 vs 并行
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n4. 串行 vs 并行——性能差异巨大：");

    function delay(name, ms) {
        return new Promise(resolve => {
            setTimeout(() => resolve(`${name}(${ms}ms)`), ms);
        });
    }

    // 串行——一个等完了再下一个，总时间累加
    async function sequential() {
        const start = Date.now();
        const a = await delay("A", 400);
        const b = await delay("B", 400);
        const c = await delay("C", 400);
        const elapsed = Date.now() - start;
        console.log(`  串行: [${a}, ${b}, ${c}] 总耗时 ${elapsed}ms`);
        // 大约 1200ms（400+400+400）
    }

    // 并行——同时进行，总时间取最慢的
    async function parallel() {
        const start = Date.now();
        const [a, b, c] = await Promise.all([
            delay("A", 400),
            delay("B", 400),
            delay("C", 400),
        ]);
        const elapsed = Date.now() - start;
        console.log(`  并行: [${a}, ${b}, ${c}] 总耗时 ${elapsed}ms`);
        // 大约 400ms（只等最慢的那个）
    }

    sequential();
    parallel();
}, 2500);

// ----------------------------------------------------------
// 5. 常见陷阱——forEach 中 await 不生效
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n5. 陷阱——forEach 中的 async 回调：");

    async function processItem(item) {
        await new Promise(resolve => setTimeout(resolve, 100));
        return item * 2;
    }

    // 错误写法——forEach 不等待 async 回调
    async function wrongWay() {
        console.log("  错误写法（forEach）——不会等待！");
        const items = [1, 2, 3];
        items.forEach(async (item) => {
            const result = await processItem(item);
            console.log(`    处理完成: ${item} -> ${result}`);
        });
        console.log("  这行会先打印！（因为 forEach 不等 await）");
    }

    // 正确写法——用 for...of
    async function rightWay() {
        console.log("  正确写法（for...of）——会等待！");
        const items = [1, 2, 3];
        for (const item of items) {
            const result = await processItem(item);
            console.log(`    处理完成: ${item} -> ${result}`);
        }
        console.log("  全部完成才打印这行");
    }

    wrongWay().then(() => rightWay());
}, 3200);

// ----------------------------------------------------------
// 6. 实用模式——重试机制
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n6. 实用模式——带重试的异步操作：");

    async function fetchWithRetry(fn, maxRetries = 3, delayMs = 200) {
        for (let attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                const result = await fn();
                return result;  // 成功了就返回
            } catch (err) {
                console.log(`    第 ${attempt} 次尝试失败: ${err.message}`);
                if (attempt === maxRetries) {
                    throw new Error(`重试 ${maxRetries} 次后仍然失败: ${err.message}`);
                }
                // 等一下再重试
                await new Promise(resolve => setTimeout(resolve, delayMs));
            }
        }
    }

    // 模拟一个可能失败的操作
    let callCount = 0;
    function unreliableFetch() {
        return new Promise((resolve, reject) => {
            callCount++;
            setTimeout(() => {
                if (callCount < 3) {
                    reject(new Error("临时故障"));
                } else {
                    resolve("数据获取成功！");
                }
            }, 100);
        });
    }

    fetchWithRetry(unreliableFetch, 5, 150)
        .then(result => console.log(`  最终结果: ${result}`))
        .catch(err => console.log(`  彻底失败: ${err.message}`));
}, 4000);

// ----------------------------------------------------------
// 7. 综合示例——模拟一个数据加载流程
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n7. 综合示例——数据加载流程：");

    // 模拟缓存
    const cache = new Map();

    async function fetchUserWithCache(userId) {
        // 先检查缓存
        if (cache.has(userId)) {
            console.log(`  缓存命中: ${userId}`);
            return cache.get(userId);
        }

        console.log(`  缓存未命中，请求: ${userId}`);
        // 模拟网络请求
        const user = await new Promise(resolve => {
            setTimeout(() => {
                resolve({ id: userId, name: `用户${userId}`, age: 20 + userId });
            }, 300);
        });

        // 存入缓存
        cache.set(userId, user);
        return user;
    }

    async function loadDashboard(userId) {
        try {
            console.log(`  加载用户 ${userId} 的仪表盘...`);

            // 第一次——没有缓存
            const user1 = await fetchUserWithCache(userId);
            console.log(`    用户: ${user1.name}, 年龄: ${user1.age}`);

            // 第二次——有缓存，瞬间返回
            const user2 = await fetchUserWithCache(userId);
            console.log(`    再次获取: ${user2.name}`);

            console.log("  仪表盘加载完成！");
        } catch (err) {
            console.log(`  加载失败: ${err.message}`);
        }
    }

    loadDashboard(1);
}, 5200);

// 确保所有异步操作完成
setTimeout(() => {
    console.log("\n========== async/await 演示结束 ==========");
}, 6000);
