# A.27 async/await

## 本节你会学到什么

- `async/await` 是 Promise 的语法糖——让异步代码"看起来像"同步代码
- `async` 函数自动返回 Promise，`await` 暂停执行直到 Promise 完成
- 用 `try/catch` 包裹 `await` 做错误处理——比 `.catch()` 链更自然
- 多个 `await` 是串行的，需要并行时还是用 `Promise.all`
- 顶层 await 和常见陷阱

## 正文

### 为什么需要 async/await

Promise 已经解决了回调地狱，但 `then` 链仍然不够直观。对比一下：

**Promise 链：**
```javascript
fetchUser(id)
    .then(user => fetchOrders(user.id))
    .then(orders => fetchProductDetails(orders))
    .then(details => console.log(details))
    .catch(err => console.log(err));
```

**async/await：**
```javascript
try {
    const user = await fetchUser(id);
    const orders = await fetchOrders(user.id);
    const details = await fetchProductDetails(orders);
    console.log(details);
} catch (err) {
    console.log(err);
}
```

**生活类比**：Promise 链像是你给每个步骤贴了张便签（"做完了做下一步"）；async/await 像是你坐下来一步步走流程——先做这步，等它完成，再做下步。代码看起来和你脑子里的流程是一样的。

### async——声明异步函数

在函数前加 `async` 关键字，这个函数就自动返回一个 Promise：

```javascript
async function greet() {
    return "你好";  // 自动包装成 Promise.resolve("你好")
}

greet().then(msg => console.log(msg)); // "你好"

// 等价于
function greetPromise() {
    return Promise.resolve("你好");
}
```

`async` 函数的返回值规则：
- 返回普通值 → 自动包装为 `Promise.resolve(值)`
- 抛出错误 → 自动包装为 `Promise.reject(错误)`
- 返回 Promise → 不做额外包装

### await——等待 Promise 完成

`await` **只能在 async 函数内部使用**。它暂停当前 async 函数的执行，等待后面的 Promise 完成，然后取出结果值：

```javascript
async function fetchData() {
    console.log("开始获取数据...");
    const data = await fetch("/api/data");  // 等这里完成才往下走
    console.log("数据：", data);
    return data;
}
```

关键理解：**await 只阻塞当前 async 函数内部的代码，不阻塞外部的代码**。外部调用者该干啥干啥。这就好比你排队买咖啡——你在队伍里等着（await），但排队外面的人还在自由活动。

### 错误处理——try/catch 包裹 await

和 Promise 的 `.catch()` 不同，async/await 使用熟悉的 `try/catch`：

```javascript
async function loadUser(id) {
    try {
        const user = await fetchUser(id);
        const orders = await fetchOrders(user.id);
        return { user, orders };
    } catch (err) {
        console.log("加载失败：", err.message);
        return null;  // 返回一个安全的默认值
    }
}
```

这比 `.catch()` 链更自然——不用在链的末尾统一处理，而是在每个可能出错的步骤前后包裹 try/catch，错误处理的粒度更灵活。

### 串行 vs 并行

**串行**——一个接一个：

```javascript
const user = await fetchUser(id);       // 等这个完成
const orders = await fetchOrders(id);   // 再等这个完成
// 总时间 = 两个请求时间之和
```

**并行**——同时进行：

```javascript
const [user, orders] = await Promise.all([
    fetchUser(id),
    fetchOrders(id),
]);
// 总时间 = 最慢的那个请求的时间
```

这个区别很重要：如果两个请求互不依赖，用 `Promise.all` 并发能省下大量时间。

### 顶层 await（ES2022）

在 ES 模块中，可以在模块顶层直接使用 `await`（不需要 async 函数包裹）：

```javascript
// 在 .mjs 文件或 package.json 中 "type": "module" 下可用
const data = await fetch("/api/config");
export default data;
```

但在 CommonJS 中不支持。

### 常见陷阱——循环中的 await

**陷阱：串行不需要并行的操作**：

```javascript
// 不好的写法——一个接一个，很慢
for (const id of ids) {
    const user = await fetchUser(id);  // 串行，总时间累加
}

// 好的写法——并行请求
const users = await Promise.all(ids.map(id => fetchUser(id)));
```

**陷阱：forEach 中的 async 回调不会等待**：

```javascript
// 这个不会等！
items.forEach(async (item) => {
    await processItem(item);  // forEach 不 await async 回调
});
console.log("完成");  // 这行会先执行！

// 应该用 for...of
for (const item of items) {
    await processItem(item);  // 正确，会等待
}
```

## 与 C 语言的对比

C 语言没有 async/await。你能做到的最接近的实现是用线程（pthread）+ 条件变量，或者用状态机+协程库（如 libco）。JS 的 async/await 让你在单线程环境下写出看起来像同步的异步代码——不阻塞主线程，但代码结构像同步流程。这是 JS 在异步编程领域的独特优势。

## 动手试试

1. 写一个 `async function fetchWithRetry()`，失败时最多重试 3 次
2. 用 `if` 判断和 `await` 实现条件异步——如果缓存有数据直接返回，否则请求
3. 故意在 `forEach` 里用 `await`，然后改成 `for...of`，对比行为差异

## 本节小结

- `async` 函数自动返回 Promise，`await` 只能在 async 函数内使用
- `await` 暂停函数内部执行但不阻塞外部，取出 Promise 的结果值
- 错误处理用 `try/catch` 包裹 `await`，比 `.catch()` 链更自然
- 互不依赖的请求用 `Promise.all` 并行执行，避免不必要的串行等待
- 不要在 `forEach` 里用 `await`——`for...of` 才是正确的写法

## 下一节预告

A.28 事件循环——揭开 JavaScript 异步执行的底层机制。理解调用栈、任务队列、微任务和宏任务，彻底搞懂"JS 是如何做到单线程不阻塞的"。
