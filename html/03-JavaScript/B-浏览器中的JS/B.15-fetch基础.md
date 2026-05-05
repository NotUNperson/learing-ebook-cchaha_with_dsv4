# B.15 fetch 基础

## 本节你会学到什么

- `fetch` 的基本语法——现代浏览器内置的网络请求方式
- Response 对象的常用方法：`json()`、`text()`、`blob()`
- HTTP 错误处理：`res.ok` 检查
- `async/await` 风格写 fetch（更干净）
- 运行 fetch 需要 HTTP 服务器环境

## 正文

### 网页的"生命线"——网络请求

到现在为止，你的所有数据要么是 HTML 里写死的，要么是用户填表单给你的。但真正的 Web 应用需要和**服务器**通信——获取新闻列表、提交订单、上传头像、查询天气。

在浏览器中，做网络请求的现代方式是 **fetch API**。它就像一个"快递员"——你告诉它去哪取东西（URL），它去取回来（或送出去），然后通知你结果。

### 最基本的 fetch 用法

```javascript
// 发一个 GET 请求，获取数据
fetch("https://api.example.com/users")
  .then(function(response) {
    // response 是服务器返回的"包裹"
    return response.json();  // 把包裹里的 JSON 数据解析出来
  })
  .then(function(data) {
    // data 就是解析好的 JS 对象
    console.log("获取到的用户数据：", data);
  })
  .catch(function(error) {
    console.error("请求失败：", error);
  });
```

拆解这个流程：
1. `fetch(url)` —— 向指定 URL 发出请求，返回一个 Promise
2. `.then(response => ...)` —— 收到响应后，`response` 对象包含状态码、headers 等
3. `response.json()` —— 把响应体解析为 JS 对象（也是异步的，返回 Promise）
4. `.then(data => ...)` —— 拿到解析好的数据，做你想做的事
5. `.catch(...)` —— 只在**网络故障**时触发（断网、DNS 解析失败等）

### Response 对象的三种解析方法

| 方法 | 返回值 | 适用场景 |
|------|--------|---------|
| `response.json()` | JS 对象/数组 | JSON API（最常见） |
| `response.text()` | 字符串 | 纯文本、HTML、XML |
| `response.blob()` | Blob 对象 | 图片、音视频、文件下载 |

```javascript
// 获取 JSON
fetch("/api/data").then(r => r.json()).then(d => console.log(d));

// 获取文本
fetch("/page.html").then(r => r.text()).then(t => console.log(t));

// 获取图片（blob）
fetch("/photo.jpg")
  .then(r => r.blob())
  .then(blob => {
    var url = URL.createObjectURL(blob);
    document.querySelector("img").src = url;
  });
```

### 重要：fetch 的错误处理不是你想的那样

这是 fetch 最容易踩的坑：

```javascript
fetch("/api/nonexistent")
  .then(function(response) {
    console.log(response.status);  // 404
    console.log(response.ok);      // false
    // 注意：即使状态码是 404 或 500，fetch 也不会 reject！
    // .catch() 不会被触发！
  })
  .catch(function(error) {
    // 只在网络故障（断网、DNS 失败）时才会进这里
    console.error("网络错误：", error);
  });
```

也就是说：**fetch 只在网络层面失败时才 reject。HTTP 层面的错误（404、500 等）仍然会 resolve。** 你需要手动检查 `response.ok`：

```javascript
fetch(url)
  .then(function(response) {
    if (!response.ok) {
      throw new Error("HTTP 错误：" + response.status);
    }
    return response.json();
  })
  .then(function(data) {
    console.log("数据：", data);
  })
  .catch(function(error) {
    console.error("请求失败：", error.message);
  });
```

### async/await 风格的 fetch（更干净）

如果你在 A 篇学了 async/await，可以这样写：

```javascript
async function fetchUsers() {
  try {
    var response = await fetch("/api/users");
    if (!response.ok) {
      throw new Error("HTTP " + response.status);
    }
    var data = await response.json();
    console.log("用户数据：", data);
  } catch (error) {
    console.error("出错：", error.message);
  }
}
fetchUsers();
```

这比 `.then()` 链更接近你熟悉的同步代码风格。

### 重要提示：需要一个 HTTP 服务器

fetch 涉及网络请求，直接用浏览器打开本地 HTML 文件（`file://` 协议）会受到跨域限制。你需要把文件放在一个 HTTP 服务器下。

**启动本地服务器的方法**（回顾 0.6 节学过的）：

```bash
# 在项目目录下运行：
python -m http.server 8000
# 然后浏览器打开 http://localhost:8000
```

本节的示例也包含了调用免费公开 API 的演示（这些不需要本地服务器），以及调用本地 JSON 文件的演示（需要本地服务器）。

### 关联 JS-A 知识

fetch 返回的 Promise 是你在 A 篇学过的异步编程机制的延续。`.then()` 链式调用、`Promise.all()` 并发、`async/await` 语法，都可以在这里使用。例如并发请求：

```javascript
// 同时请求多个 API
Promise.all([
  fetch("/api/users").then(r => r.json()),
  fetch("/api/posts").then(r => r.json())
]).then(function([users, posts]) {
  console.log("用户：", users);
  console.log("文章：", posts);
});
```

## 动手试试

1. 打开 `B.15-fetch-basic/index.html`（确保已启动本地服务器 `python -m http.server 8000`）
2. 点击"获取 JSON 数据"按钮，观察从本地 `data.json` 文件加载的数据
3. 点击"调用公开 API"按钮，观察从真实 API 获取的数据
4. 故意把 URL 改成一个不存在的地址，观察 `res.ok` 和 `.catch` 的行为差异
5. 打开控制台，查看每个请求的 status 和耗时

## 本节小结

fetch 是现代浏览器内置的网络请求 API。基本流程：`fetch(url)` → `response.json()/text()/blob()` → `data`。关键注意事项：fetch 只在网络故障时 reject，HTTP 错误（404/500）不会 reject——需要手动检查 `response.ok`。async/await 让代码更接近同步风格。fetch 需要 HTTP 服务器环境。

## 下一节预告

B.16《fetch 进阶》——GET 只是开始。怎么发 POST 请求？怎么带请求头？怎么上传文件？怎么中途取消请求？
