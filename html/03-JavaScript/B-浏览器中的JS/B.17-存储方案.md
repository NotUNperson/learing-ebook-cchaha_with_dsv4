# B.17 存储方案

## 本节你会学到什么

- `localStorage`：持久化存储，数据不过期
- `sessionStorage`：会话级别存储，关闭标签页即清除
- cookie：老式存储，每次 HTTP 请求都会发送
- 三者的 API 对比与适用场景
- 对象存储需要 `JSON.stringify` / `JSON.parse`

## 正文

### 数据的"家"——存在哪？

前面你学会了发送请求、获取数据。但数据拿到以后呢？用户刷新页面，你的 JS 变量就全没了——变量只活在内存里，页面刷新就是一场"记忆清零"。

浏览器提供了几种**客户端存储**方案，让数据在页面刷新后依然存在。三种主流方案就像三种不同的"储物方式"：

### localStorage —— 持久化储物间

`localStorage` 是一个简单的键值存储，数据**持久保存**，除非用户手动清除或代码删除。

```javascript
// 存数据
localStorage.setItem("username", "张三");
localStorage.setItem("theme", "dark");

// 取数据
var username = localStorage.getItem("username");  // "张三"
var theme = localStorage.getItem("theme");        // "dark"

// 删数据
localStorage.removeItem("theme");

// 清空所有
localStorage.clear();
```

**重要限制**：`localStorage` **只能存字符串**。如果要存对象或数组，需要 JSON 转换：

```javascript
var user = { name: "张三", age: 28, role: "admin" };

// 存对象：JSON.stringify 转字符串
localStorage.setItem("user", JSON.stringify(user));

// 取对象：JSON.parse 转回对象
var savedUser = JSON.parse(localStorage.getItem("user"));
console.log(savedUser.name);  // "张三"
console.log(savedUser.age);   // 28
```

**容量限制**：约 5MB（不同浏览器略有差异）。

**作用域**：按**域名+协议**隔离。`https://a.com` 的数据，`https://b.com` 看不到。

### sessionStorage —— 临时的会话储物柜

`sessionStorage` 的 API 和 `localStorage` **完全一样**，但数据只在当前**标签页会话**期间存在——关闭标签页，数据即清除。

```javascript
// API 和 localStorage 一模一样！
sessionStorage.setItem("cart", JSON.stringify(cartItems));
var cart = JSON.parse(sessionStorage.getItem("cart"));
sessionStorage.removeItem("cart");
sessionStorage.clear();
```

适用场景：
- 表单分步填写（多页表单，关闭标签页丢弃进度）
- 购物车临时数据
- 页面间的临时状态传递

### cookie —— 老式的储物条（每次出门都带着）

cookie 是最老的客户端存储方式。它的独特之处在于：**每次 HTTP 请求，浏览器都会自动把 cookie 带上发给服务器**。

```javascript
// 设置 cookie（只能逐条设置）
document.cookie = "username=张三; max-age=86400; path=/";  // 存活 1 天
document.cookie = "theme=dark; max-age=31536000; path=/";  // 存活 1 年

// 读取 cookie（返回一个字符串，需要自己解析）
console.log(document.cookie);  // "username=张三; theme=dark"

// 删除 cookie（设置过期时间为过去）
document.cookie = "username=; max-age=0; path=/";
```

**cookie 的缺点**：
- 每次 HTTP 请求都携带（影响性能）
- 容量极小（约 4KB）
- 操作不便（需要手动解析字符串）
- 可以被服务器通过 `Set-Cookie` 响应头设置

**cookie 的独特价值**：正因为它会自动随请求发送，所以它目前仍然是**身份认证（登录态）**的主要载体。服务器登录后返回一个 session token（存于 cookie），后续请求自动带上，服务器就知道你是谁。

### 三者对比

| 特性 | localStorage | sessionStorage | cookie |
|------|-------------|---------------|--------|
| 容量 | ~5MB | ~5MB | ~4KB |
| 生命周期 | 永久（除非手动删除） | 关闭标签页即清除 | 可设过期时间 |
| 随 HTTP 请求发送 | 不发送 | 不发送 | 每次都发送 |
| API 易用性 | 简单（setItem/getItem） | 简单 | 麻烦（字符串操作） |
| 跨标签页共享 | 同域名下共享 | 不共享（每个标签页独立） | 共享 |
| 典型用途 | 存应用数据、用户偏好 | 存临时状态 | 身份认证令牌 |

### 实用演示：localStorage 保存主题偏好

```javascript
// 页面加载时读取保存的主题
var savedTheme = localStorage.getItem("theme") || "light";
applyTheme(savedTheme);

// 用户切换主题
function toggleTheme() {
  var newTheme = savedTheme === "light" ? "dark" : "light";
  localStorage.setItem("theme", newTheme);
  applyTheme(newTheme);
}
```

### 关联 JS-A 知识

- `JSON.stringify` 和 `JSON.parse` —— A 篇学过的序列化/反序列化，现在用于将 JS 对象存入 localStorage
- 键盘事件、表单事件 —— B.10 学过的，可用于"输入内容时自动保存草稿"

## 动手试试

1. 打开示例文件 `B.17-storage.html`，点击按钮存入数据，刷新页面再看数据还在不在
2. 打开浏览器开发者工具 → Application（应用）→ Storage（存储）→ Local Storage，查看存储的数据
3. 在控制台手动执行 `localStorage.setItem("test", "hello")`，然后在 Application 面板查看
4. 关闭标签页后重新打开，观察 localStorage 数据还在，而 sessionStorage 数据已消失
5. 对比：打开浏览器的 Application 面板，看看 cookie 区域有没有网站存了东西

## 本节小结

三种客户端存储：`localStorage`（持久化，约 5MB，只存字符串，适合应用数据）、`sessionStorage`（标签页会话级别，API 相同）、cookie（~4KB，每次请求都发送，目前主要用于身份认证）。存储对象时需要用 `JSON.stringify/parse` 做转换。建议：存应用数据用 `localStorage`，存临时状态用 `sessionStorage`，身份凭证交给 cookie。

## 下一节预告

B.18《综合练习：Todo App》——B 篇全部知识的收官练习。你将用 DOM 操作、事件委托、classList、localStorage 做一个完整的交互式 Todo 应用，刷新不丢数据。
