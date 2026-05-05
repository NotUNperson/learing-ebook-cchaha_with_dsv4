# B.13 BOM（上）—— window、弹窗、定时器

## 本节你会学到什么

- BOM 是什么，它和 DOM 的区别与关系
- `window` 对象 —— 浏览器中的"全局对象"
- `alert` / `prompt` / `confirm` —— 弹窗三兄弟
- `setTimeout` / `setInterval` —— 定时器
- `requestAnimationFrame` —— 流畅动画的基石

## 正文

### BOM 是什么——浏览器是更大的"操作系统"

之前所有章节，我们都在操作页面本身（DOM）。但页面是跑在**浏览器**这个更大的环境里的。浏览器本身也是一堆对象的集合——这些对象统称为 **BOM（Browser Object Model，浏览器对象模型）**。

类比：
- **DOM** = 你家里的家具、墙壁、地板——你每天触碰的东西
- **BOM** = 房子所在的小区——门卫（弹窗）、物业广播（定时器）、地理位置（URL）、门牌号（地址栏）等

BOM 的核心是 **`window`** 对象。实际上，你在全局写的所有变量和函数，都是挂在 `window` 上的。

### window —— 浏览器中的"全局对象"

在浏览器中，`window` 是全局对象：

```javascript
var name = "小明";
console.log(window.name);  // "小明" —— 全局变量自动成为 window 的属性

function sayHi() {
  console.log("Hi");
}
window.sayHi();  // "Hi" —— 全局函数自动成为 window 的方法
```

这也意味着你在 A 篇学过的 `console.log`、`Array`、`Object`、`parseInt` 等，其实全都是 `window` 的属性：`window.console.log(...)`，只是 `window.` 前缀通常被省略。

### 弹窗三兄弟（alert / prompt / confirm）

这三个方法都是 `window` 的方法，会弹出浏览器原生对话框。它们的特点是**会阻塞页面**——对话框打开时，整个页面的 JS 执行暂停，直到用户关闭对话框。

#### alert —— "通知你一件事"

```javascript
alert("你好，世界！");
```

弹出一个提示框，只有一个"确定"按钮。适用于简单的调试输出或确实需要用户注意的通知。

#### prompt —— "问你一个问题"

```javascript
var name = prompt("你叫什么名字？", "默认值");
console.log(name);  // 用户输入的内容，点取消返回 null
```

弹出一个带输入框的对话框。第一个参数是提示文字，第二个参数是默认值（可选）。

#### confirm —— "你确定吗？"

```javascript
var ok = confirm("确定要删除吗？");
if (ok) {
  console.log("用户点了确定");
} else {
  console.log("用户点了取消");
}
```

弹出确认对话框，返回 `true`（确定）或 `false`（取消）。

> **重要提示**：弹窗三兄弟在现代 Web 开发中已经较少使用。它们会阻塞页面、无法自定义样式、用户体验差。多数场景下，开发者会自己用 HTML+CSS 写弹窗组件。但你仍然需要认识它们——看老代码、快速调试时很常见。

### setTimeout —— 像闹钟，延迟执行一次

```javascript
// 3 秒后执行一次
setTimeout(function() {
  console.log("3 秒到了！");
}, 3000);  // 单位是毫秒，3000 = 3 秒

// 可以取消
var timerId = setTimeout(function() {
  console.log("这行不会执行");
}, 5000);
clearTimeout(timerId);  // 取消！
```

类比：你设了一个闹钟——"3 分钟后提醒我关火"。如果在响之前你主动把闹钟关了（clearTimeout），它就不会响。

### setInterval —— 像心跳，周期重复执行

```javascript
// 每秒执行一次
var count = 0;
var intervalId = setInterval(function() {
  count++;
  console.log("第 " + count + " 秒");
  if (count >= 10) {
    clearInterval(intervalId);  // 10 次后停止
    console.log("计时结束！");
  }
}, 1000);
```

类比：心跳每秒钟跳一次，直到你说停。`clearInterval` 就是"停"的指令。

**注意**：`setInterval` 有累积风险——如果回调函数执行时间超过了间隔时间，下一次调度会在前一个执行完后立即触发，造成"堆积"。对于需要精确时序的循环任务，更推荐用 `setTimeout` 递归：

```javascript
function tick() {
  console.log("tick");
  setTimeout(tick, 1000);  // 执行完才调度下一个
}
tick();
```

### requestAnimationFrame —— 流畅动画的基石

`requestAnimationFrame` 是浏览器专门为动画设计的 API。它会在**下一帧**绘制前调用你的回调函数（通常 60 帧/秒）：

```javascript
function animate() {
  // 更新动画状态
  box.style.left = x + "px";
  x++;

  // 请求下一帧
  requestAnimationFrame(animate);
}

// 开始动画
requestAnimationFrame(animate);
```

和 `setInterval` 相比，`requestAnimationFrame` 的优势：
- 自动适配屏幕刷新率（60Hz 屏幕就是 60fps，120Hz 就是 120fps）
- 页面不可见时自动暂停（省电省资源）
- 不会出现掉帧或撕裂

### 关联 JS-A 知识

`setTimeout` 和 `setInterval` 的回调函数是**异步**执行的——你在 A 篇学到的同步执行顺序在这里不适用。即使定时器的延迟设为 0，回调也不会立即执行，而是要等当前同步代码执行完。

```javascript
console.log("1");
setTimeout(function() {
  console.log("2");  // 即使延迟是 0，也不会在 "3" 之前输出
}, 0);
console.log("3");
// 输出：1 3 2
```

## 动手试试

1. 打开示例文件 `B.13-bom-1.html`，测试三种弹窗的效果
2. 点击"启动计时器"按钮，观察数字每秒变化；点击"停止"观察 clearInterval 的效果
3. 尝试用 `setTimeout` 做一个"3 秒后自动消失"的提示条
4. 观察 requestAnimationFrame 动画的流畅度，和 F12 控制台中定时器日志的对比

## 本节小结

BOM 是比 DOM 更上层的浏览器对象模型，核心是 `window` 全局对象。弹窗三兄弟（alert/prompt/confirm）简单但会阻塞页面。定时器：`setTimeout` 延迟执行一次，`setInterval` 周期重复执行（需警惕堆积）。`requestAnimationFrame` 是动画最佳实践（自动适配帧率、页面不可见时自动暂停）。

## 下一节预告

B.14《BOM（下）》——接下来看地址栏（location）、浏览器历史（history）和设备信息（navigator），这些是现代单页应用（SPA）路由的基础。
