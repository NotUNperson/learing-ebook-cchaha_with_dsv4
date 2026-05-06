# 3. Promise

## 本节你会学到什么

- 理解 Promise 是什么——一个承诺未来会给你结果的对象
- 用 .then() 和 .catch() 处理异步任务的成功和失败
- 用 Promise.all() 同时等待多个任务完成
- 理解 Promise 链式调用如何解决回调地狱
- 用"点外卖"的四步流程类比 Promise 的一生

## 正文

### 回调地狱的痛点

上一节我们看到了回调地狱——层层嵌套的代码像一颗洋葱，剥开一层还有一层。三个步骤还算能忍，五个步骤呢？十个呢？

```typescript
// 回调地狱：3 层还行，10 层就疯了
step1((r1) => {
  step2(r1, (r2) => {
    step3(r2, (r3) => {
      step4(r3, (r4) => {
        // 我已经分不清自己在第几层了……
      });
    });
  });
});
```

核心问题不是缩进丑，而是：
1. **错误处理困难**——每层都要处理错误，或者根本不知道在哪层出错
2. **逻辑被拆散**——本来一个"做完 A 做 B 做 C"的线性流程，被拆成了嵌套片段
3. **难以复用**——这个链条无法单独传给别人使用

这就是 Promise 要解决的。

### Promise 是什么

**外卖平台类比：**

你用手机点了一份黄焖鸡米饭。点完以后你不是坐在那干等——你得到一个订单号（这就是 Promise）。手机显示订单状态经历了四个阶段：

1. **待确认**（pending）——订单提交了，商家还没接
2. **已接单**（商家接了）——你可以松口气，知道有饭吃了（fulfilled / resolved）
3. **已取消**（商家不接或退款）——没得吃了（rejected）
4. **最终状态**——要么送达（成功），要么退款（失败），不会再变来变去

Promise 和这个订单号完全一样：

- `pending`：待定状态，任务还在进行中
- `fulfilled`（也叫 resolved）：成功了，你有结果了
- `rejected`：失败了，你有原因了
- Promise 一旦从 pending 变成 fulfilled 或 rejected，就**永远定格**，不会反复横跳

转成代码：

```typescript
// 创建一个 Promise
const deliveryPromise: Promise<string> = new Promise((resolve, reject) => {
  // 模拟商家接单需要 2 秒
  setTimeout(() => {
    const merchantAccepted: boolean = true; // 商家接单了
    if (merchantAccepted) {
      resolve("黄焖鸡米饭正在路上"); // 成功回调
    } else {
      reject("商家不接单");          // 失败回调
    }
  }, 2000);
});

// 消费者：拿到 Promise，用 .then() 处理成功，.catch() 处理失败
deliveryPromise
  .then((message: string) => {
    console.log("好消息：" + message);
  })
  .catch((error: string) => {
    console.log("坏消息：" + error);
  });
```

### .then() 和 .catch() 的链式调用

Promise 的杀手锏特性是**链式调用**。每个 `.then()` 返回的还是一个新的 Promise，所以你可以继续 `.then()`，一路平铺下去，**没有缩进地狱**。

回到上一节的做菜例子，用 Promise 重写：

```typescript
function washVegetables(): Promise<string> {
  return new Promise((resolve) => {
    setTimeout(() => resolve("洗干净的白菜"), 1000);
  });
}

function cutVegetables(veg: string): Promise<string> {
  return new Promise((resolve) => {
    setTimeout(() => resolve("切好的" + veg), 1000);
  });
}

function cookVegetables(veg: string): Promise<string> {
  return new Promise((resolve) => {
    setTimeout(() => resolve("一盘美味的炒" + veg), 1000);
  });
}

// 链式调用：三个步骤平铺在同一层级，清晰无比
washVegetables()                          // ① 洗菜
  .then((cleanVeg) => cutVegetables(cleanVeg))  // ② 切菜
  .then((cutVeg) => cookVegetables(cutVeg))     // ③ 炒菜
  .then((dish) => {                       // ④ 上菜
    console.log("完成！" + dish);
  });
```

对比回调版本，代码从"向右缩进的金字塔"变成了"笔直向下的流水线"。每个步骤的输入输出清清楚楚，哪一步出问题也一目了然。

### Promise.all() —— 同时等待多个任务

外卖平台不只送一家店。你可能同时点了米饭、炒菜、饮料，三个订单并行，希望全部到齐后再开吃。厨房也是：两个灶同时开火做菜，效率更高。

```typescript
// 三个异步任务同时开始（模拟三个厨师同时做菜）
const dish1: Promise<string> = cookVegetables("白菜");
const dish2: Promise<string> = cookVegetables("土豆");
const dish3: Promise<string> = cookVegetables("豆腐");

// Promise.all：等全部完成
Promise.all([dish1, dish2, dish3]).then((dishes: string[]) => {
  console.log("三菜齐了！");
  console.log(dishes); // ["一盘美味的炒白菜", "一盘美味的炒土豆", "一盘美味的炒豆腐"]
});
```

`Promise.all` 的特点：
- 接受一个 Promise 数组
- 等所有 Promise 都成功，返回一个包含所有结果的数组
- 如果其中任何一个失败，整个 `Promise.all` 也失败

还有 `Promise.race`：谁先完成（或失败）就用谁的结果，不等人。相当于"哪个外卖先到吃哪个"。

### 错误处理

用 `.catch()` 统一捕获链条中任何一步的错误，不需要每步都写错误处理：

```typescript
doStep1()
  .then((r1) => doStep2(r1))
  .then((r2) => doStep3(r2))
  .catch((error) => {
    console.log("出错了：" + error);
    // 不管是 step1、step2 还是 step3 出错，都到这里
  })
  .finally(() => {
    console.log("无论成功失败，这里都会执行");
  });
```

`finally` 里的代码无论成功还是失败都会执行，适合放"关闭文件"或"隐藏加载动画"这类清理操作。

## 动手试试

1. 创建一个返回 Promise 的函数，模拟"查快递"：随机 60% 概率成功（返回快递位置），40% 概率失败（返回"丢件了"）。
2. 用 `.then()` 和 `.catch()` 消费这个 Promise。
3. 写三个"查快递"的调用，用 `Promise.all` 同时查询三个快递单号。
4. 在 `.catch()` 里统一处理错误，打印友好的提示。

## 本节小结

Promise 是把异步任务包装成"未来某个时刻会有结果"的对象，用 .then() 链式编排顺序任务，用 .catch() 统一处理错误，用 Promise.all() 并行执行多个任务——比回调嵌套清晰得多。

## 下一节预告

Promise 已经让异步代码比回调好读很多，但还是要写 .then() 和箭头函数。有没有办法让异步代码"看起来像同步代码"？有，下一节的主角——async/await，就是为此而生的。
