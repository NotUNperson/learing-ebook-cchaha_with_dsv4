# A.25 回调函数

## 本节你会学到什么

- 回调的本质：把函数当作参数传给另一个函数，"完事了打给我"
- 同步回调 vs 异步回调——同一个概念，两种执行时机
- Node.js 经典的回调模式：`(err, result) => { ... }`
- 回调地狱——层层嵌套的代码为什么难以维护
- 为什么需要 Promise——回调地狱就是它的"前传"

## 正文

### 回调是什么

**生活类比**：你去干洗店送衣服。店员说："衣服明天洗好，你留个电话，完事了我打给你。"这个"留电话"的动作就是回调——你把一个联系方式（函数）交给了对方（另一个函数），对方在合适的时候（衣服洗好了）联系你（调用你给的函数）。

在代码里，回调就是**把函数 A 作为参数传给函数 B，B 在某个时刻调用 A**：

```javascript
function 干洗店(衣服, 洗好后的通知) {
    console.log("开始洗：" + 衣服);
    // ...洗衣服需要时间...
    洗好后的通知(衣服 + "（已洗干净）");
}

干洗店("羽绒服", function(结果) {
    console.log("收到通知：" + 结果);
});
```

### 同步回调 vs 异步回调

**同步回调**在执行时马上调用，像你去快餐店点餐——当面看着做、做完就拿：

```javascript
const arr = [1, 2, 3, 4, 5];

// forEach 接收的回调是同步的——马上执行
arr.forEach(function(item, index) {
    console.log(index, item);
});
console.log("forEach 执行完毕"); // 这行在 forEach 全部完成后才执行
```

**异步回调**不马上执行，在未来的某个时刻才被调用。像干洗店——你留了电话就走了，不用在那干等：

```javascript
console.log("A");
setTimeout(function() {
    console.log("B（2秒后）");
}, 2000);
console.log("C");

// 输出顺序：A → C → B
// B 虽然写在前面，但 2 秒后才执行，C 先打印了
```

### Node.js 经典回调模式——错误优先

Node.js 的大多数内置 API 使用一种固定模式的回调：

```javascript
fs.readFile(path, function(err, data) {
    if (err) {
        // 第一个参数是错误对象——没有错就是 null
        console.log("读取失败:", err);
        return;
    }
    // 第二个参数是结果
    console.log(data);
});
```

这就是"错误优先回调"（error-first callback），约定：
- 回调的第一个参数是 error（没有错则为 null）
- 第二个参数才是结果

### 回调地狱（Callback Hell）

当你需要做一串异步操作时——比如"读取文件A，根据内容读取文件B，再根据B的内容读取文件C"——代码会变成这样：

```javascript
fs.readFile("a.txt", function(err, dataA) {
    if (err) { console.log(err); return; }
    fs.readFile("b.txt", function(err, dataB) {
        if (err) { console.log(err); return; }
        fs.readFile("c.txt", function(err, dataC) {
            if (err) { console.log(err); return; }
            console.log(dataA + dataB + dataC);
        });
    });
});
```

代码向右一直缩进，像金字塔也像楼梯，俗称"回调地狱"。问题不仅仅是难看：

- **可读性差**——逻辑被嵌套结构打散
- **错误处理重复**——每一层都要写 if(err)
- **难以复用**——中间的逻辑很难抽出来

### 为什么需要更好的方案

回调本身不难理解，但当异步任务变复杂时（顺序执行、并行执行、条件分支），回调的局限性暴露无遗。这就是为什么 ES6 引入了 Promise，ES2017 引入了 async/await——都是为了解决同一个问题：**让异步代码更容易写、更容易读。**

但理解回调仍然是理解 Promise 的前提。Promise 的 `.then()` 本质就是"规范化了传参方式的回调"。

## 与 C 语言的对比

C 语言中也有回调——通过函数指针实现（`void (*callback)(int)`）。比如 `qsort` 就接收一个比较函数作为回调。但 C 没有"事件循环"的概念，所以没有真正的异步回调。JS 中回调的核心价值在于配合事件循环实现"不阻塞的 I/O"，这在 C 中需要多线程才能做到。

## 动手试试

1. 用 `setTimeout` 模拟一个异步操作，接收回调，2 秒后执行回调
2. 写一个 `simulatedReadFile(path, callback)` 函数，随机成功/失败，失败时传 err
3. 嵌套 3 个 `setTimeout`（每个等 1 秒），观察缩进和输出顺序

## 本节小结

- 回调是把函数作为参数传给另一个函数，由它在合适的时机调用
- 同步回调立即执行（forEach），异步回调推迟执行（setTimeout）
- Node.js 错误优先回调：`(err, result) => {}`
- 回调地狱：多层嵌套 → 代码难读、错误处理重复
- 回调是异步编程的"原始形态"，Promise 是进化版

## 下一节预告

A.26 Promise——异步编程的"承诺"。解决回调地狱的利器，三种状态，链式调用，优雅的错误处理。
