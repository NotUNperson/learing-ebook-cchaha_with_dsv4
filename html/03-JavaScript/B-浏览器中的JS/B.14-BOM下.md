# B.14 BOM（下）—— location、history、navigator

## 本节你会学到什么

- `location` 对象 —— 当前 URL 的一切信息
- `history` 对象 —— 浏览历史与 SPA 路由基础
- `navigator` 对象 —— 浏览器和设备信息
- `pushState` / `replaceState` —— 无刷新改 URL

## 正文

### 你的浏览器是一辆车

上一节学了 BOM 的上半部分——window、弹窗、定时器。现在来看下半部分。

想象你的浏览器是一辆车：
- **location**（地址栏） = 导航系统 —— 告诉你"现在在哪"，也能"导航到新地址"
- **history**（浏览记录） = 行车记录仪 —— 记录了你去过的地方，可以"后退""前进"
- **navigator**（设备信息） = 车辆手册 —— 告诉你这辆车是什么牌子、什么型号、有什么功能

### location —— 当前 URL 的完整解剖

`location` 对象包含当前页面的 URL 信息。假设当前 URL 是：

```
https://www.example.com:8080/page?id=123#section-1
```

那么：

```javascript
console.log(location.href);       // 完整 URL
console.log(location.protocol);   // "https:"
console.log(location.host);       // "www.example.com:8080"（含端口）
console.log(location.hostname);   // "www.example.com"
console.log(location.port);       // "8080"
console.log(location.pathname);   // "/page"
console.log(location.search);     // "?id=123"
console.log(location.hash);       // "#section-1"
```

#### 页面跳转

```javascript
// 跳转到新页面（产生历史记录，用户可以点"后退"回来）
location.href = "https://www.baidu.com";
// 等价于：
location.assign("https://www.baidu.com");

// 替换当前页面（不产生历史记录，用户不能后退）
location.replace("https://www.baidu.com");

// 重新加载当前页面
location.reload();  // 相当于 F5
```

#### 获取 URL 参数（query string）

```javascript
// URL: page.html?name=小明&age=20
var params = new URLSearchParams(location.search);
console.log(params.get("name"));  // "小明"
console.log(params.get("age"));   // "20"
```

### history —— 浏览历史的控制器

`history` 对象让你可以前进、后退，以及（最重要的）**无刷新改 URL**。

#### 基本导航

```javascript
history.back();     // 后退一页（相当于浏览器的"后退"按钮）
history.forward();  // 前进一页
history.go(-2);     // 后退两页
history.go(1);      // 前进一页
```

#### pushState / replaceState —— SPA 的基础

这两个方法是现代**单页应用（SPA）**路由的基础。它们可以在不刷新页面的情况下修改 URL：

```javascript
// pushState：新增一条历史记录（URL 变了，页面不刷新）
history.pushState({ page: "about" }, "", "/about");

// replaceState：替换当前历史记录（不新增，URL 变了，页面不刷新）
history.replaceState({ page: "home" }, "", "/home");
```

三个参数：
1. **state**：一个 JS 对象，可以存任何你想存的数据（后面会讲怎么取出来）
2. **title**：目前浏览器大多忽略这个参数，传 `""` 即可
3. **url**：新的 URL（同源，不跨域）

#### popstate 事件 —— 用户点后退/前进时触发

当用户点击浏览器的"后退"或"前进"按钮时，会触发 `popstate` 事件：

```javascript
window.addEventListener("popstate", function(event) {
  console.log("用户点了后退/前进");
  console.log("当前 state：", event.state);
  // event.state 就是你之前在 pushState 时存的数据
  // 根据 state 来更新页面内容
});
```

**重要**：`pushState` 和 `replaceState` 本身**不会**触发 `popstate` 事件。只有用户手动点后退/前进按钮才会触发。

这就是现代 SPA（如 React Router、Vue Router）的底层原理——用 `pushState` 改变 URL，用 `popstate` 监听用户后退，页面内容由 JS 根据 URL 动态渲染。

### navigator —— 了解浏览器和设备的"档案"

```javascript
console.log(navigator.userAgent);
// "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/..."

console.log(navigator.language);    // "zh-CN"（浏览器语言）
console.log(navigator.onLine);      // true/false（是否联网）
console.log(navigator.cookieEnabled); // true（是否启用了 cookie）

// 剪贴板 API（现代浏览器支持，需要用户授权）
// navigator.clipboard.writeText("要复制的文字");
// navigator.clipboard.readText().then(text => console.log(text));
```

**注意**：`navigator.userAgent` 可以读取，但**不应该用它来判断浏览器类型或版本**。UA 字符串容易被伪造，且各家浏览器互相模仿，很难解析准确。判断功能支持性应该用"特性检测"（feature detection），例如：

```javascript
// 不推荐：判断浏览器
if (navigator.userAgent.indexOf("Chrome") > -1) { /* ... */ }

// 推荐：检测功能是否存在
if ("geolocation" in navigator) {
  // 支持地理定位
}
```

### 关联 JS-A 知识

`pushState` 传入的 state 对象可以被 `JSON.stringify` 序列化。你在 A 篇学过的对象操作、字符串处理（URL 参数解析）在这里都有应用。

## 动手试试

1. 打开示例文件 `B.14-bom-2.html`，查看当前页面的 URL 各部分信息
2. 点击"pushState"按钮，观察地址栏 URL 变化（页面不刷新！）
3. 点几次 pushState 后，点浏览器的"后退"按钮，观察页面上的 state 变化
4. 在控制台输入 `history.length`，查看当前标签页的历史记录条数
5. 试试 `navigator.language` 和 `navigator.onLine` 的值

## 本节小结

`location` 提供 URL 的全部分解（href、pathname、search、hash），`assign`/`replace`/`reload` 控制跳转。`history` 提供导航（back/forward/go）和 SPA 路由基础（pushState/replaceState + popstate 事件）。`navigator` 提供浏览器和设备信息（但不要用 userAgent 判断浏览器）。`URLSearchParams` 可方便解析 URL 参数。

## 下一节预告

B.15《fetch 基础》——现在你能读懂 URL、能操作 DOM、能处理事件了。接下来学怎么用 JS 从服务器获取数据——fetch API 登场。
