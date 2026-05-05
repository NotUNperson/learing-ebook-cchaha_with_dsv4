// ============================================================
// A.26 Promise 示例代码
// 运行方式：node examples/A.26-promise.js
// ============================================================

console.log("========== A.26 Promise ==========\n");

// ----------------------------------------------------------
// 1. 创建 Promise——三种状态演示
// ----------------------------------------------------------
console.log("1. Promise 三种状态：");

// Promise 构造函数接收一个函数，该函数接收 resolve 和 reject 两个参数
const promise = new Promise((resolve, reject) => {
    // 模拟一个异步操作（如网络请求）
    console.log("  1秒后决定成功还是失败...");

    setTimeout(() => {
        const success = Math.random() > 0.5;  // 随机成功或失败
        if (success) {
            resolve("数据获取成功！");  // 状态变为 fulfilled
        } else {
            reject(new Error("网络连接失败"));  // 状态变为 rejected
        }
    }, 1000);
});

console.log("  Promise 已创建，状态是 pending...");

// ----------------------------------------------------------
// 2. .then() / .catch() / .finally()
// ----------------------------------------------------------
console.log("\n2. .then .catch .finally 链式调用：");

promise
    .then((result) => {
        // 成功时执行
        console.log(`  [成功] ${result}`);
        return result + "（已处理）";  // 返回值会被下一个 then 接收
    })
    .then((processed) => {
        // 第二个 then 接收上一个 then 的返回值
        console.log(`  [第二步] 收到：${processed}`);
    })
    .catch((error) => {
        // 失败时执行——捕获链上任意位置的错误
        console.log(`  [失败] ${error.message}`);
    })
    .finally(() => {
        // 不管成功还是失败，都执行
        console.log("  [finally] 操作结束，不管结果如何");
    });

// 等一下让异步操作完成
setTimeout(() => {
    console.log("\n  --------------------");
}, 1200);

// ----------------------------------------------------------
// 3. 链式调用 vs 回调地狱
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n3. 链式调用——平铺代替嵌套：");

    // 模拟异步读取文件
    function readFile(name, delay) {
        return new Promise((resolve, reject) => {
            console.log(`    开始读取：${name}`);
            setTimeout(() => {
                if (Math.random() < 0.3) {
                    reject(new Error(`${name} 读取失败`));
                } else {
                    resolve(`<<${name} 的内容>>`);
                }
            }, delay);
        });
    }

    // Promise 链式调用——代码是平铺的！
    readFile("a.txt", 200)
        .then(dataA => {
            console.log(`    A 完成: ${dataA}`);
            return readFile("b.txt", 200);  // 返回新的 Promise
        })
        .then(dataB => {
            console.log(`    B 完成: ${dataB}`);
            return readFile("c.txt", 200);
        })
        .then(dataC => {
            console.log(`    C 完成: ${dataC}`);
            console.log("    全部文件读取完毕！");
        })
        .catch(err => {
            console.log(`    [统一错误处理] ${err.message}`);
        });
}, 1500);

// ----------------------------------------------------------
// 4. Promise.all()——并行等待多个
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n4. Promise.all()——并行执行：");

    function fetchData(name, delay) {
        return new Promise(resolve => {
            setTimeout(() => {
                resolve(`${name} (耗时${delay}ms)`);
            }, delay);
        });
    }

    // 三个请求互不依赖，应该并行
    const p1 = fetchData("用户信息", 300);
    const p2 = fetchData("订单列表", 500);
    const p3 = fetchData("商品信息", 200);

    const startTime = Date.now();
    Promise.all([p1, p2, p3])
        .then(([user, orders, products]) => {
            const elapsed = Date.now() - startTime;
            console.log(`  全部完成，耗时 ${elapsed}ms（取最慢的）`);
            console.log(`    结果1: ${user}`);
            console.log(`    结果2: ${orders}`);
            console.log(`    结果3: ${products}`);
            // 注意：总耗时接近 500ms（最慢的那个），而不是 300+500+200=1000ms
        })
        .catch(err => {
            // all 是"全部成功才成功"，有一个失败就失败
            console.log(`  至少一个失败: ${err.message}`);
        });
}, 2500);

// ----------------------------------------------------------
// 5. Promise.race()——竞速
// ----------------------------------------------------------
setTimeout(() => {
    console.log("\n5. Promise.race()——竞速：");

    function request(url, delay) {
        return new Promise((resolve) => {
            setTimeout(() => resolve(`${url} 响应`), delay);
        });
    }

    function timeout(ms) {
        return new Promise((_, reject) => {
            setTimeout(() => reject(new Error(`超时 (${ms}ms)`)), ms);
        });
    }

    // 模拟：如果请求超过 300ms，就超时
    const fastRequest = request("/api/fast", 100);  // 100ms 很快
    const slowRequest = request("/api/slow", 500);  // 500ms 很慢

    // 快请求 vs 超时
    Promise.race([fastRequest, timeout(300)])
        .then(result => console.log(`  快请求结果: ${result}`))
        .catch(err => console.log(`  快请求: ${err.message}`));

    // 慢请求 vs 超时
    Promise.race([slowRequest, timeout(300)])
        .then(result => console.log(`  慢请求结果: ${result}`))
        .catch(err => console.log(`  慢请求: ${err.message}`));
}, 3800);

// ----------------------------------------------------------
// 6. Promise.resolve() 和 Promise.reject()
// ----------------------------------------------------------
console.log("\n6. 快捷创建 Promise：");

// Promise.resolve()——创建一个已成功的 Promise
Promise.resolve(42).then(n => console.log(`  resolve 结果: ${n}`));

// Promise.reject()——创建一个已失败的 Promise
Promise.reject(new Error("预设错误"))
    .catch(err => console.log(`  reject 结果: ${err.message}`));

// ----------------------------------------------------------
// 7. 包装回调为 Promise (promisify)
// ----------------------------------------------------------
console.log("\n7. 包装回调函数为 Promise：");

// Node.js 经典的回调风格函数
function traditionalRead(filename, callback) {
    // 模拟：延迟后调用回调
    setTimeout(() => {
        if (Math.random() < 0.3) {
            callback(new Error(`${filename} 不存在`));
        } else {
            callback(null, `数据来自 ${filename}`);
        }
    }, 100);
}

// 包装成返回 Promise 的版本
function promisifyRead(filename) {
    return new Promise((resolve, reject) => {
        traditionalRead(filename, (err, data) => {
            if (err) reject(err);
            else resolve(data);
        });
    });
}

// 现在可以用 Promise 风格调用了
promisifyRead("config.json")
    .then(data => console.log(`  读取成功: ${data}`))
    .catch(err => console.log(`  读取失败: ${err.message}`))
    .finally(() => console.log("  读取操作完成"));

// ----------------------------------------------------------
// 8. 一个实用示例——用 Promise 做 sleep
// ----------------------------------------------------------
console.log("\n8. 实用工具——sleep 函数：");

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// 使用 sleep 实现串行延迟
async function demo() {
    console.log("  开始");
    await sleep(500);
    console.log("  过了 500ms");
    await sleep(300);
    console.log("  又过了 300ms");
    console.log("  结束");
}
demo();

// 注：这里的 await 语法会在下一节详细讲解
// 这里只是让你先睹为快

setTimeout(() => {
    console.log("\n========== Promise 演示结束 ==========");
}, 5000);
