# A.26 Promise

## 本节你会学到什么

- Promise 是"异步操作的承诺"——有三种状态且不可逆
- `.then()` 处理成功、`.catch()` 处理失败、`.finally()` 总执行
- 链式调用——每个 `.then()` 返回新 Promise，彻底解决回调地狱
- `Promise.all()` 同时等待多个 Promise、`Promise.race()` 竞速
- 用 Promise 包装回调风格的函数（promisify）

## 正文

### Promise 是什么——一份"承诺"

**生活类比**：你订了一份外卖。

- 下单后，订单状态是"**进行中**（pending）"——骑手还没到。
- 骑手送到了，状态变为"**已送达**（fulfilled）"——你可以去拿吃的。
- 如果店铺关门了，状态变为"**已取消**（rejected）"——你得退款。

Promise 就是 JS 中的"外卖订单"。它代表一个异步操作的最终结果——要么成功（fulfilled），要么失败（rejected）。状态一旦改变就**不可逆**——送达了就不能再取消，取消了就不能再送达。

```javascript
const promise = new Promise((resolve, reject) => {
    // 异步操作
    setTimeout(() => {
        const success = Math.random() > 0.5;
        if (success) {
            resolve("数据获取成功！"); // 成功时调用 resolve
        } else {
            reject(new Error("网络错误")); // 失败时调用 reject
        }
    }, 1000);
});
```

### 三种状态

```
pending（进行中）
   ├── resolve() → fulfilled（成功）——不可逆
   └── reject()  → rejected（失败）——不可逆
```

### .then()、.catch()、.finally()

```javascript
promise
    .then(result => {
        console.log("成功啦：", result);
        return result + " 已处理";  // 返回的值会进入下一个 then
    })
    .then(processed => {
        console.log("第二步：", processed);
    })
    .catch(error => {
        console.log("出错了：", error.message);
    })
    .finally(() => {
        console.log("不管成功失败，这行总执行");
    });
```

关键是：**每个 `.then()` 返回一个新的 Promise**。这正是 Promise 能解决回调地狱的原因——不再需要嵌套，用链式调用平铺逻辑。

### 链式调用——解决回调地狱

回到 A.25 的文件读取场景。用 Promise 改写：

```javascript
readFile("a.txt")
    .then(dataA => {
        console.log("A:", dataA);
        return readFile("b.txt");  // 返回新的 Promise
    })
    .then(dataB => {
        console.log("B:", dataB);
        return readFile("c.txt");
    })
    .then(dataC => {
        console.log("C:", dataC);
    })
    .catch(err => {
        // 一个 catch 捕获链上任何错误！
        console.log("某个环节出错了：", err.message);
    });
```

对比回调版本：
- 代码是**平铺的**，不是向右缩进的
- **一个 catch** 处理所有错误
- 每一步的返回值能自然传给下一步

### Promise.all()——同时等待多个

场景：你需要同时获取用户资料、订单列表、商品信息——三个请求互不依赖，可以并行：

```javascript
const p1 = fetch("/api/user");
const p2 = fetch("/api/orders");
const p3 = fetch("/api/products");

Promise.all([p1, p2, p3])
    .then(([user, orders, products]) => {
        console.log("全部完成！");
    })
    .catch(err => {
        // 只要有一个 reject，就进 catch
        console.log("至少一个请求失败了：", err);
    });
```

`Promise.all` 的特点：
- 所有 Promise 都成功 → 返回所有结果的数组
- 只要有一个失败 → 立即 reject（不会等其他完成）

### Promise.race()——竞速

```javascript
const request = fetch("/api/data");
const timeout = new Promise((_, reject) =>
    setTimeout(() => reject(new Error("请求超时")), 5000)
);

Promise.race([request, timeout])
    .then(data => console.log("数据收到了"))
    .catch(err => console.log("要么超时，要么出错"));
```

谁先完成（不管成功失败），`race` 就返回谁的结果。

### Promise.resolve() 和 Promise.reject()

快速创建已完成/已拒绝的 Promise：

```javascript
Promise.resolve(42).then(n => console.log(n));        // 42
Promise.reject(new Error("失败")).catch(e => console.log(e.message));
```

### 用 Promise 包装回调风格的函数

把 Node.js 回调风格的函数转为返回 Promise 的函数：

```javascript
const fs = require("fs");

function readFilePromise(path) {
    return new Promise((resolve, reject) => {
        fs.readFile(path, "utf8", (err, data) => {
            if (err) reject(err);
            else resolve(data);
        });
    });
}
```

## 与 C 语言的对比

C 语言没有内置的异步编程模型——你需要多线程（pthread）、回调函数指针或协程库。Promise 的设计灵感一部分来自函数式编程中的"Future"概念，在 C 中你通常用状态机+回调来实现类似效果，代码量要大得多。

## 动手试试

1. 用 `new Promise` 包装 `setTimeout`，创建一个等待指定毫秒的 `sleep(ms)` 函数
2. 用 `Promise.all` 同时执行 3 个不同延迟的 sleep，观察输出顺序
3. 写一个链式调用：读取 A → 根据 A 内容决定是否读 B → 最终输出

## 本节小结

- Promise 代表异步操作的最终结果，三种状态：pending → fulfilled/rejected（不可逆）
- `.then(fn)` 处理成功，`.catch(fn)` 处理失败，`.finally(fn)` 总执行
- 链式调用的核心：每个 `.then()` 返回新 Promise，平铺代替嵌套
- `Promise.all` 并行等待多个，全部成功才成功；`Promise.race` 取最快
- 转换回调风格 API 为 Promise 风格是一种常见模式

## 下一节预告

A.27 async/await——Promise 的"语法糖"，让异步代码看起来像同步代码一样直观。
