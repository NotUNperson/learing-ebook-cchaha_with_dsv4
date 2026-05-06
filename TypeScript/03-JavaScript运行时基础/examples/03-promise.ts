/**
 * 03-promise.ts
 * Promise —— 优雅处理异步操作的"承诺"
 *
 * 运行方式：
 *   ts-node 03-promise.ts
 */

// ============================================================
// 第一部分：创建和消费 Promise
// ============================================================

console.log("=== 第一部分：创建 Promise ===");

/**
 * Promise 的三个状态（外卖订单类比）：
 *   pending   → 待确认（刚下单，商家还没接）
 *   fulfilled → 已接单/已完成（有结果了）
 *   rejected  → 已取消/退款（失败了）
 *
 * 一旦从 pending 变成 fulfilled 或 rejected，就永久定格。
 */

// 创建一个 Promise：模拟外卖下单
function orderFood(foodName: string): Promise<string> {
  // Promise 构造函数接受一个函数，函数的参数是 resolve 和 reject
  // resolve：成功时调用，把结果传出去
  // reject：失败时调用，把错误原因传出去
  return new Promise<string>((resolve, reject) => {
    console.log(`[下单] ${foodName}，等待商家接单...`);

    // 模拟商家接单需要 1~3 秒
    const delay: number = 1000 + Math.random() * 2000;

    setTimeout(() => {
      // 模拟 80% 的概率商家会接单
      const accepted: boolean = Math.random() < 0.8;

      if (accepted) {
        resolve(`${foodName} 已被商家接单，预计 ${(delay / 1000).toFixed(1)} 秒后送达`);
      } else {
        reject(`${foodName} 下单失败：商家太忙，不接单`);
      }
    }, delay);
  });
}

// 消费 Promise：用 .then() 处理成功，.catch() 处理失败
console.log("\n--- 点第一单 ---");
orderFood("黄焖鸡米饭")
  .then((message: string) => {
    // .then() 的第一个参数是成功时的回调
    console.log(`[成功] ${message}`);
  })
  .catch((error: string) => {
    // .catch() 是失败时的回调
    console.log(`[失败] ${error}`);
  })
  .finally(() => {
    // .finally() 无论成功失败都会执行
    console.log("[完成] 第一单处理完毕");
  });

// ============================================================
// 第二部分：链式调用 —— 解决回调地狱
// ============================================================

// 等第一单处理完，再演示链式调用
setTimeout(() => {
  console.log("\n=== 第二部分：链式调用 ===");

  function washVegetables(): Promise<string> {
    return new Promise((resolve) => {
      setTimeout(() => {
        console.log("  1. 菜洗好了");
        resolve("洗干净的白菜");
      }, 800);
    });
  }

  function cutVegetables(veg: string): Promise<string> {
    return new Promise((resolve) => {
      setTimeout(() => {
        const result: string = `切好的${veg}`;
        console.log(`  2. ${result}`);
        resolve(result);
      }, 800);
    });
  }

  function cookVegetables(veg: string): Promise<string> {
    return new Promise((resolve) => {
      setTimeout(() => {
        const result: string = `一盘美味的炒${veg}`;
        console.log(`  3. ${result}`);
        resolve(result);
      }, 800);
    });
  }

  console.log("做菜流水线（Promise 链式调用版本）：");

  // 每个 .then() 返回新 Promise，所以可以继续 .then()
  // 代码平铺直下，没有缩进地狱！
  washVegetables()                       // 步骤 1
    .then((cleanVeg) => cutVegetables(cleanVeg))  // 步骤 2
    .then((cutVeg) => cookVegetables(cutVeg))     // 步骤 3
    .then((dish) => {                    // 步骤 4
      console.log(`  上菜！${dish}`);
    })
    .catch((error) => {
      // 统一错误处理：任何一步出错都会到这里
      console.log(`做菜出问题了：${error}`);
    });

  /**
   * 对比回调版本（不用运行，对比一下结构即可）：
   *
   * washVegetables((cleanVeg) => {
   *   cutVegetables(cleanVeg, (cutVeg) => {
   *     cookVegetables(cutVeg, (dish) => {
   *       // 三层嵌套，向右缩进
   *     });
   *   });
   * });
   *
   * Promise 版本就是一行接一行的平铺，清晰很多。
   */

}, 3500);

// ============================================================
// 第三部分：Promise.all —— 并行执行
// ============================================================

setTimeout(() => {
  console.log("\n=== 第三部分：Promise.all 并行执行 ===");

  /**
   * Promise.all 类比：你在外卖平台同时点了三个菜
   * 三个商家同时开始做（并行），你等到三份都到齐再开吃
   */

  // 模拟一个"做一道菜"的异步函数
  function cookDish(name: string, time: number): Promise<string> {
    return new Promise((resolve) => {
      console.log(`  [开始] 厨师开始做 ${name}（需要 ${time / 1000} 秒）`);
      setTimeout(() => {
        console.log(`  [完成] ${name} 做好了！`);
        resolve(`美味的${name}`);
      }, time);
    });
  }

  console.log("三菜并做：三个厨师同时开工！");

  const startTime: number = Date.now();

  // 三个 Promise 同时创建，同时开始计时
  const dishA: Promise<string> = cookDish("红烧肉", 3000);
  const dishB: Promise<string> = cookDish("清蒸鱼", 2000);
  const dishC: Promise<string> = cookDish("炒青菜", 1500);

  // Promise.all：等全部都完成
  Promise.all([dishA, dishB, dishC])
    .then((dishes: string[]) => {
      const totalTime: number = Date.now() - startTime;
      console.log("\n三菜齐了：");
      dishes.forEach((d, i) => console.log(`  ${i + 1}. ${d}`));
      // 总时间接近最慢的那道菜（3 秒），而不是三个菜加起来的时间
      // 因为它们同时在做（并行）
      console.log(`总耗时约 ${(totalTime / 1000).toFixed(1)} 秒`);
      console.log("（如果是串行，需要 3+2+1.5=6.5 秒）");
    });

}, 6500);

// ============================================================
// 第四部分：Promise.race —— 谁先完成用谁
// ============================================================

setTimeout(() => {
  console.log("\n=== 第四部分：Promise.race ===");

  // 模拟从两个快递公司同时下单，谁先到用谁
  function deliverFrom(company: string, time: number): Promise<string> {
    return new Promise((resolve) => {
      setTimeout(() => resolve(`${company} 送到了`), time);
    });
  }

  console.log("从两家快递同时下单，看看谁先到：");

  const sf: Promise<string> = deliverFrom("顺丰快递", 2000);
  const yd: Promise<string> = deliverFrom("圆通快递", 3500);

  Promise.race([sf, yd]).then((winner: string) => {
    console.log(`[race 结果] 赢家是：${winner}`);
  });

}, 9500);

// ============================================================
// 第五部分：错误处理最佳实践
// ============================================================

setTimeout(() => {
  console.log("\n=== 第五部分：错误处理 ===");

  // 模拟一个可能出错的步骤链
  function step1(): Promise<string> {
    return Promise.resolve("步骤1完成"); // Promise.resolve 是快速创建一个成功的 Promise
  }

  function step2(data: string): Promise<string> {
    return Promise.resolve(`${data} → 步骤2完成`);
  }

  function step3(data: string): Promise<string> {
    // 这个步骤有 50% 概率失败
    if (Math.random() < 0.5) {
      return Promise.reject(new Error("步骤3出错：原料用完了"));
    }
    return Promise.resolve(`${data} → 步骤3完成`);
  }

  function step4(data: string): Promise<string> {
    return Promise.resolve(`${data} → 全部完成！`);
  }

  step1()
    .then(step2)
    .then(step3)
    .then(step4)
    .then((result: string) => {
      console.log("成功：" + result);
    })
    .catch((error: Error) => {
      // 无论 step1/2/3/4 哪一步出错，都在这统一处理
      console.log(`失败：${error.message}`);
    })
    .finally(() => {
      console.log("（finally：清理工作，比如关闭文件连接）");
    });

}, 12500);

// 程序会等所有定时器走完，大约 13 秒后自动退出
