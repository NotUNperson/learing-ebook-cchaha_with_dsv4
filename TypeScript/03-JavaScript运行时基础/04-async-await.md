# 4. async/await

## 本节你会学到什么

- 理解 async/await 是什么——Promise 的"语法糖"，让异步代码像同步代码一样写
- 用 async 声明异步函数，用 await 等待 Promise 完成
- 对比 Promise.then() 链和 async/await 写法，体会哪个更直观
- 用 try/catch 在 async 函数中捕获错误
- 用"剧本"类比理解 await 的行为——剧本顺序写，但幕后可以同时干活

## 正文

### Promise 还不够"像人话"吗

上一节我们学会了用 Promise 的链式调用让代码平铺直下。但坦白说，对于习惯了 C++ 逐行顺序执行的你来说，`.then()` 总有种"异样感"——你不能只写 `const result = awaitSomeAsyncThing()`，而要用箭头函数把后续逻辑包起来。

看一段实际代码。假设你要调用两个 API，第二个 API 依赖第一个的返回结果：

**Promise 写法：**
```typescript
function getUserAndOrders(userId: number): Promise<void> {
  return fetchUser(userId)           // 先拿用户信息
    .then((user) => {
      console.log(user.name);
      return fetchOrders(user.id);   // 再拿他的订单
    })
    .then((orders) => {
      console.log(orders);
    })
    .catch((error) => {
      console.log("出错了：" + error);
    });
}
```

逻辑没错，但阅读时需要"跳转"——你得在每个 `.then()` 里理解当前拿到的变量是什么。如果步骤更多，或者中间需要条件判断（如果用户是 VIP 就走分支 A 否则走分支 B），链条会变得很尴尬。

### async/await 来了

ES2017 引入了 `async` 和 `await` 两个关键字。它们不改变 Promise 的底层机制，只是给你一个**更接近直觉**的写法。官方说法叫"语法糖"——糖衣包在药丸外面，药还是那个药（Promise），但吃起来不苦了。

**用 async/await 重写上一段：**
```typescript
async function getUserAndOrders(userId: number): Promise<void> {
  try {
    const user = await fetchUser(userId);     // 等待用户信息
    console.log(user.name);

    const orders = await fetchOrders(user.id); // 再等订单
    console.log(orders);
  } catch (error) {
    console.log("出错了：" + error);
  }
}
```

对比两种写法，async/await 版本有什么不同？

1. 函数前面加了 `async` 关键字。这等于告诉 JS："这个函数里有 await，它返回 Promise"。
2. `await` 写在异步调用前面，表示"在这里暂停，等这个 Promise 完成，拿到结果，然后继续往下执行"。
3. 错误处理用的是你熟悉的 `try/catch`，不再是 `.catch()`。

代码读起来像**同步代码**：从上到下，一行一行，和 C++ 里的函数几乎一样。但实际上它仍是异步的——在 await 暂停期间，JS 引擎可以去做别的事。

### 剧本类比

**导演拍电影的剧本：**

剧本是顺序写的：
1. 主角走进房间
2. 主角打开电脑
3. 主角开始写代码

但拍摄时，场景 1 和场景 2 的道具组可以**同时**布置不同的场地。导演不用站在场景 2 的场地干等——场景 1 拍完了，场景 2 也布置好了，直接拍。

**async/await 就是这个剧本。** 你按顺序写：
```typescript
const userData = await fetch("/api/user");
const config = await fetch("/api/config");
renderPage(userData, config);
```

JS 引擎在 await 第一个 fetch 时，把这个 fetch 交给后台线程处理，自己去做别的事（比如处理其他请求）。第一个 fetch 返回后，回到 await 的位置继续，再发起第二个 fetch，再让出控制权。

**关键理解：** `await` 暂停的是**当前这个 async 函数的执行**，不是整个程序。其他函数、事件循环都在照常运转。所以这不是"卡死了"，而是"我去喝杯水，你弄好了叫我"。

### async 函数总是返回 Promise

无论你写不写 `return new Promise(...)`，加了 `async` 的函数**自动**把返回值包装成 Promise：

```typescript
async function getGreeting(): Promise<string> {
  return "你好";  // 看起来返回 string，实际返回 Promise<string>
}

// 等价于：
function getGreeting2(): Promise<string> {
  return Promise.resolve("你好");
}

// 所以你可以 .then() 或 await 它：
getGreeting().then((msg) => console.log(msg));
const msg = await getGreeting();
```

### 多个 await 的顺序问题

如果你有两个不相关的异步任务，别一个一个等：

```typescript
// 错误：总耗时 = 2 秒 + 3 秒 = 5 秒
async function serialBad(): Promise<void> {
  const data1 = await fetchSlowData(2000);  // 等 2 秒
  const data2 = await fetchSlowData(3000);  // 再等 3 秒
}

// 正确：总耗时 = max(2, 3) = 3 秒（两个请求同时发出）
async function parallelGood(): Promise<void> {
  const promise1 = fetchSlowData(2000);  // 不 await，拿到 Promise 对象
  const promise2 = fetchSlowData(3000);  // 同上，两个请求同时开始了

  const data1 = await promise1;  // 现在等结果（可能已经好了）
  const data2 = await promise2;
}

// 或者用 Promise.all，效果一样：
async function parallelAll(): Promise<void> {
  const [data1, data2] = await Promise.all([
    fetchSlowData(2000),
    fetchSlowData(3000),
  ]);
}
```

这个技巧很重要：**先发起所有的异步操作（拿到 Promise），再 await 它们**。就像你先在所有锅里倒上水打开火，然后等水烧开，而不是先烧一锅、倒掉、再烧下一锅。

### try/catch 处理 async 函数的错误

async/await 使用传统的 `try/catch` 而不是 `.catch()`：

```typescript
async function riskyOperation(): Promise<void> {
  try {
    const result1 = await mightFail1();
    const result2 = await mightFail2(result1);
    console.log("一切顺利：" + result2);
  } catch (error) {
    // 任何一行 await 抛出错误，都会跳到这里
    console.log("出错了：" + error);
  } finally {
    console.log("不管成功失败，清理工作在这里做");
  }
}
```

如果一个函数同时用了 try/catch 和 .catch()，哪个会捕获？如果一个 async 函数没有内部 try/catch，错误会冒泡到调用方，就像普通异常一样。

## 动手试试

1. 写一个 async 函数 `makeBreakfast`，依次做：煮咖啡（2 秒）、烤面包（1.5 秒）、煎蛋（1 秒），每步完成后打印一条消息。
2. 重写为并行版本：煮咖啡和烤面包同时开始，两者都好了再煎蛋。
3. 在并行版本里故意让某个步骤失败（比如"煤气没了"），用 try/catch 捕获并打印。
4. 对比串行和并行版本的执行总时间差异。

## 本节小结

async/await 是 Promise 的"人话版"，让你用同步的编写方式（一行一行，try/catch）写异步逻辑；底层还是 Promise 和事件循环，但代码的可读性大幅提升。

## 下一节预告

到目前为止，我们所有的代码都写在一个文件里。真实项目不可能这样——几千行代码揉在一起谁也看不懂。下一节学习 TypeScript 的模块系统，把代码拆成多个文件，各管各的。
