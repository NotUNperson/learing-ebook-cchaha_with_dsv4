/**
 * 04-async-await.ts
 * async/await —— 用同步写法写异步代码
 *
 * 运行方式：
 *   ts-node 04-async-await.ts
 */

// ============================================================
// 第一部分：基本语法 —— async 和 await
// ============================================================

/**
 * async/await 是 Promise 的"语法糖"
 * 语法糖 = 本质没变（还是 Promise），但写法更甜（更直观）
 *
 * 规则：
 * 1. async 关键字放在 function 前面，表示这个函数返回 Promise
 * 2. await 关键字放在 Promise 前面，表示"等它完成，拿结果"
 * 3. await 只能在 async 函数内部使用
 */

// 模拟一个"需要等一会儿才返回结果"的异步函数
function fetchUserName(userId: number): Promise<string> {
  return new Promise((resolve) => {
    console.log(`  [请求] 获取用户 ID=${userId} 的名字...`);
    setTimeout(() => {
      resolve(`用户_${userId}`);
    }, 1000);
  });
}

// ============================================================
// 第二部分：用 async/await 消费 Promise
// ============================================================

console.log("=== 第二部分：async/await 基本用法 ===");

// async 函数：看起来像普通函数，但内部可以用 await
async function getUserInfo(): Promise<void> {
  console.log("开始获取用户信息...");

  // await：暂停当前 async 函数，等 Promise 完成，拿到结果
  const name1: string = await fetchUserName(101);
  console.log(`  收到：${name1}`);

  const name2: string = await fetchUserName(202);
  console.log(`  收到：${name2}`);

  console.log("所有用户信息获取完毕！");
}

// 调用 async 函数
getUserInfo().then(() => {
  // async 函数返回 Promise，所以可以用 .then() 或继续 await
  // 但更常见的做法是在另一个 async 函数里 await 它
  console.log("getUserInfo 调用完毕\n");
});

// 注意：上面的 getUserInfo 不会阻塞后面的代码
// 它内部有 await 暂停，但整个程序的流程不卡死
console.log("[主线程] 在 getUserInfo 等待的同时，我还能跑这行！");

// ============================================================
// 第三部分：对比 Promise.then() 和 async/await
// ============================================================

// 等前面的异步操作完成后再演示对比
setTimeout(() => {
  console.log("\n=== 第三部分：Promise vs async/await 对比 ===");

  function delay(ms: number): Promise<string> {
    return new Promise((resolve) => {
      setTimeout(() => resolve(`等待了 ${ms}ms`), ms);
    });
  }

  // Promise.then() 版本（也是正确的，但读起来有些跳转感）
  function withPromiseChain(): void {
    console.log("[Promise 链版本]");
    delay(500)
      .then((r1) => {
        console.log(`  第一步：${r1}`);
        return delay(600);
      })
      .then((r2) => {
        console.log(`  第二步：${r2}`);
        return delay(400);
      })
      .then((r3) => {
        console.log(`  第三步：${r3}`);
        console.log("  [Promise 链] 完成！");
      });
  }

  // async/await 版本（读起来像同步代码，一行一行从上到下）
  async function withAsyncAwait(): Promise<void> {
    console.log("[async/await 版本]");
    const r1: string = await delay(500);
    console.log(`  第一步：${r1}`);
    const r2: string = await delay(600);
    console.log(`  第二步：${r2}`);
    const r3: string = await delay(400);
    console.log(`  第三步：${r3}`);
    console.log("  [async/await] 完成！");
  }

  withPromiseChain();
  withAsyncAwait();

}, 2500);

// ============================================================
// 第四部分：并行执行 —— 不要一个一个等
// ============================================================

setTimeout(() => {
  console.log("\n=== 第四部分：并行 vs 串行 ===");

  /**
   * 剧本类比：
   * 剧本按顺序写（场景1 → 场景2 → 场景3），但幕后可以同时布置多个场景
   * 同理，你可以先"下单"发起所有请求，然后再一个一个等结果
   */

  function fetchData(id: number, time: number): Promise<string> {
    return new Promise((resolve) => {
      console.log(`  [请求] 开始获取 data_${id}（耗时 ${time}ms）`);
      setTimeout(() => resolve(`data_${id}_结果`), time);
    });
  }

  // 串行版本：一个接一个等（慢）
  async function serialFetch(): Promise<void> {
    console.log("[串行] 开始（总耗时应为 500+700+600=1800ms）");
    const start: number = Date.now();

    const d1: string = await fetchData(1, 500);  // 等 500ms
    const d2: string = await fetchData(2, 700);  // 等 700ms
    const d3: string = await fetchData(3, 600);  // 等 600ms

    console.log(`[串行] 结果：${d1}, ${d2}, ${d3}`);
    console.log(`[串行] 实际耗时：${Date.now() - start}ms`);
  }

  // 并行版本：同时发起三个请求（快）
  async function parallelFetch(): Promise<void> {
    console.log("[并行] 开始（总耗时应为 max(500,700,600)=700ms）");
    const start: number = Date.now();

    // 关键技巧：先拿到 Promise 对象（不 await），三个请求同时开始
    const p1: Promise<string> = fetchData(1, 500);
    const p2: Promise<string> = fetchData(2, 700);
    const p3: Promise<string> = fetchData(3, 600);

    // 然后一个一个 await（此时它们已经在后台执行了）
    const d1: string = await p1;
    const d2: string = await p2;
    const d3: string = await p3;

    console.log(`[并行] 结果：${d1}, ${d2}, ${d3}`);
    console.log(`[并行] 实际耗时：${Date.now() - start}ms`);
  }

  // 并行升级版：用 Promise.all（效果一样，更简洁）
  async function parallelWithAll(): Promise<void> {
    console.log("[Promise.all] 开始");
    const start: number = Date.now();

    const [d1, d2, d3]: string[] = await Promise.all([
      fetchData(1, 500),
      fetchData(2, 700),
      fetchData(3, 600),
    ]);

    console.log(`[Promise.all] 结果：${d1}, ${d2}, ${d3}`);
    console.log(`[Promise.all] 实际耗时：${Date.now() - start}ms`);
  }

  // 依次演示三种方式
  async function demonstrate(): Promise<void> {
    await serialFetch();
    console.log();
    await parallelFetch();
    console.log();
    await parallelWithAll();
  }

  demonstrate();

}, 5000);

// ============================================================
// 第五部分：错误处理 —— try/catch
// ============================================================

setTimeout(() => {
  console.log("\n=== 第五部分：错误处理 ===");

  function mightFail(step: string, shouldFail: boolean): Promise<string> {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        if (shouldFail) {
          reject(new Error(`${step} 失败了：系统异常`));
        } else {
          resolve(`${step} 成功`);
        }
      }, 500);
    });
  }

  async function runWithErrorHandling(): Promise<void> {
    try {
      console.log("开始执行可能有错误的任务...");
      const r1: string = await mightFail("步骤1", false);
      console.log(`  ${r1}`);
      const r2: string = await mightFail("步骤2", true);  // 这里会失败
      console.log(`  ${r2}`);  // 这行不会执行，因为上面抛异常了
      const r3: string = await mightFail("步骤3", false);
      console.log(`  ${r3}`);
    } catch (error) {
      // 任何一步 await 抛出错误，都会跳到这里
      console.log(`[捕获错误] ${(error as Error).message}`);
      console.log("  可以在这里做恢复操作，比如返回默认值");
    } finally {
      // finally 里的代码无论成功失败都会执行
      console.log("[finally] 清理工作（关闭连接、隐藏加载动画等）");
    }
  }

  runWithErrorHandling();

}, 11000);

// ============================================================
// 第六部分：async 函数总是返回 Promise
// ============================================================

setTimeout(() => {
  console.log("\n=== 第六部分：async 函数的返回值 ===");

  // 即使你 return 一个普通值，async 函数也会自动包成 Promise
  async function add(a: number, b: number): Promise<number> {
    return a + b;  // 看起来返回 number，实际返回 Promise<number>
  }

  // 所以可以 await 它
  async function test(): Promise<void> {
    const result: number = await add(3, 7);
    console.log(`3 + 7 = ${result}`);
  }

  test();

  // 也可以 .then() 它
  add(10, 20).then((sum) => {
    console.log(`10 + 20 = ${sum}`);
  });

  console.log("\n全部演示结束！");
}, 13000);

// 整个演示大约需要 13~14 秒，因为各部分用 setTimeout 错开
