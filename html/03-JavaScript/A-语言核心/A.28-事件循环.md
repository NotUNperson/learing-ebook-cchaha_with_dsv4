# A.28 事件循环

## 本节你会学到什么

- JavaScript 是单线程的——"一个厨师，一口锅"，但异步机制让它不卡顿
- 调用栈（Call Stack）——当前在执行的函数们
- 宏任务（Task Queue）和微任务（Microtask Queue）——排队的两种队列
- 微任务优先于宏任务——`Promise.then` 比 `setTimeout` 先执行
- `setTimeout(fn, 0)` 不是立即执行——它在等当前栈清空

## 正文

### 单线程的 JS——一个厨师的故事

**生活类比**：想象一家小饭馆，只有一个厨师（单线程）、一口炒锅（调用栈）。客人点菜后，厨师不能让锅空着，但也必须一个一个炒。如果一个菜需要等（比如炖汤要 30 分钟），厨师不会傻站着等——他把汤炖上（交给定时器/系统），先去炒别的菜。汤好了自然有人端回来（回调进入队列）。

JavaScript 就是这样的"单线程、非阻塞"模型：
- **单线程**：同一时刻只能执行一段代码
- **非阻塞**：耗时操作（I/O、计时器）交给系统处理，JS 继续执行后续代码
- **事件循环**：不断检查"有没有事要做"，有就做，没有就等

### 事件循环的三要素

```
┌─────────────────────────────┐
│         调用栈               │  ← 当前正在执行的函数
│    (Call Stack)             │     后进先出（栈）
│                             │
├─────────────────────────────┤
│        微任务队列            │  ← Promise.then / MutationObserver
│   (Microtask Queue)         │     优先级高！
│                             │
├─────────────────────────────┤
│        宏任务队列            │  ← setTimeout / setInterval / I/O
│   (Macrotask / Task Queue)  │     优先级低
└─────────────────────────────┘
```

事件循环的流程（一个 tick）：
1. 从**宏任务队列**取一个任务执行（"取一张票进场"）
2. 执行完这个宏任务后，把**微任务队列清空**（全部排队中的微任务执行完）
3. 需要的话更新渲染（浏览器）
4. 回到第 1 步

### 调用栈——当前在执行什么

```javascript
function baz() {
    console.log("baz");
}
function bar() {
    baz();
}
function foo() {
    bar();
}
foo();
// 调用栈变化：
// foo 入栈 → bar 入栈 → baz 入栈 → baz 出栈 → bar 出栈 → foo 出栈
```

栈是后进先出（LIFO），和 C 语言的函数调用栈一样。

### 微任务 vs 宏任务——优先级演示

```javascript
console.log("1. 同步");

setTimeout(() => console.log("4. setTimeout"), 0);

Promise.resolve().then(() => console.log("3. Promise.then"));

console.log("2. 同步");

// 输出顺序：1 → 2 → 3 → 4
// 为什么 Promise 比 setTimeout 先？
// 因为微任务（Promise.then）在宏任务（setTimeout）之前清空
```

**理解这个顺序的关键**：
- 同步代码先完整执行（打印 1、2）
- 同步代码执行完毕后，检查微任务队列——有 Promise.then，执行（打印 3）
- 微任务队列清空后，才从宏任务队列取下一个——setTimeout（打印 4）

### setTimeout(fn, 0) 的真正含义

```javascript
console.log("A");
setTimeout(() => console.log("C"), 0);
console.log("B");
// 输出：A → B → C
```

`setTimeout(fn, 0)` 不是说"0 毫秒后立即执行"，而是说"尽快把 fn 放进宏任务队列"。fn 的实际执行时机取决于：
- 当前调用栈是否已清空
- 宏任务队列前的微任务队列是否已清空
- 队列前方是否有更早排队的宏任务

### 微任务的完整类型

- `Promise.then()` / `Promise.catch()` / `Promise.finally()`
- `async/await` 内部（await 后面的代码是微任务）
- `queueMicrotask(() => {})` ——直接添加微任务
- `MutationObserver`（浏览器环境）

### 面试经典题——分解执行顺序

```javascript
console.log("start");

setTimeout(() => console.log("timeout"), 0);

Promise.resolve()
    .then(() => console.log("promise1"))
    .then(() => console.log("promise2"));

console.log("end");

// 执行顺序分析：
// 同步：start → end
// 微任务：promise1 → promise2
// 宏任务：timeout
//
// 最终：start → end → promise1 → promise2 → timeout
```

### 为什么这很重要

理解事件循环是调试异步代码的基础。当你的 `setTimeout` 回调"明明设置了 0ms 却总是不及时执行"，当你的 Promise 链结果和你预期的不一样——追根溯源都是事件循环的调度规则。

在前端开发中，事件循环还决定了 UI 更新的时机。长时间占用调用栈会"卡死"页面（界面无响应），因为渲染也在事件循环中排队。

## 与 C 语言的对比

C 语言默认是同步阻塞的。`read()` 系统调用会阻塞线程直到数据就绪。要实现类似 JS 的事件驱动模型，你需要 libevent/libuv（Node.js 底层用的就是 libuv）或者自己写 select/epoll 循环。JS 的事件循环把这一切封装好了，你只需提供回调函数，循环自动管理。这种模型特别适合 I/O 密集型应用（如 Web 服务器）。

## 动手试试

1. 写一段包含 `setTimeout(fn, 0)` 和 `Promise.resolve().then()` 的代码，预测输出并验证
2. 在微任务内部再添加一个微任务（嵌套 `.then()`），观察执行顺序
3. 用 `queueMicrotask` 添加微任务，和 Promise.then 对比顺序

## 本节小结

- JS 单线程 + 非阻塞 + 事件循环 = "一个厨师，一口锅，但不等菜"
- 调用栈（LIFO）执行同步代码，两个任务队列执行异步代码
- 每次事件循环 tick：一个宏任务 → 清空所有微任务 → 可能渲染 → 下一个宏任务
- 微任务（Promise.then）优先于宏任务（setTimeout）
- `setTimeout(fn, 0)` 不等于"立即执行"，等于"尽快排入宏任务队列"

## 下一节预告

A.29 模块化——把代码拆分到不同文件，用 import/export 组织起来。告别"一个文件写到底"的时代。
