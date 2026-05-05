# B.16 fetch 进阶

## 本节你会学到什么

- POST 请求：method、body、headers 配置
- 请求体格式：JSON、FormData、URLSearchParams
- Headers 对象：Content-Type 等
- 文件上传：input[type="file"] + FormData
- 请求取消：AbortController + signal

## 正文

### 快递员不只是取件——还能送件

上一节你学会了用 fetch 发 GET 请求——从服务器"取"数据。但真正的 Web 应用还需要"送"数据：提交表单、上传头像、创建文章、删除记录。这些操作使用不同的 HTTP 方法（POST、PUT、DELETE 等），并且需要携带**请求体（body）**。

类比：fetch 就像一个快递员。GET 是他去收件（拿到包裹），POST 是他把包裹送到指定地址。你需要在包裹上贴标签（headers），说明里面的东西是什么格式。

### POST 请求的基本结构

```javascript
fetch("/api/users", {
  method: "POST",             // HTTP 方法
  headers: {
    "Content-Type": "application/json"  // 告诉服务器：我发的是 JSON
  },
  body: JSON.stringify({      // 请求体——JS 对象需要转成 JSON 字符串
    name: "张三",
    email: "zhangsan@example.com"
  })
})
  .then(function(response) {
    if (!response.ok) throw new Error("HTTP " + response.status);
    return response.json();
  })
  .then(function(data) {
    console.log("创建成功：", data);
  })
  .catch(function(error) {
    console.error("出错：", error.message);
  });
```

### 三种请求体格式

#### JSON（最常用）

```javascript
fetch("/api/users", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    name: "张三",
    age: 28
  })
});
```

#### FormData（表单数据，支持文件上传）

```javascript
var formData = new FormData();
formData.append("username", "zhangsan");
formData.append("avatar", fileInput.files[0]);  // 文件！

fetch("/api/upload", {
  method: "POST",
  body: formData  // 注意：不要手动设 Content-Type！浏览器会自动设 multipart/form-data + boundary
});
```

#### URLSearchParams（简单表单键值对）

```javascript
var params = new URLSearchParams();
params.append("username", "zhangsan");
params.append("password", "123456");

fetch("/api/login", {
  method: "POST",
  headers: { "Content-Type": "application/x-www-form-urlencoded" },
  body: params
});
```

### Headers 对象

```javascript
var headers = new Headers();
headers.append("Content-Type", "application/json");
headers.append("Authorization", "Bearer my-token-abc123");

fetch("/api/data", {
  method: "GET",
  headers: headers
});
```

常用的请求头：
| Header | 含义 |
|--------|------|
| `Content-Type` | 请求体的格式 |
| `Authorization` | 认证令牌 |
| `Accept` | 期望的响应格式 |

### 文件上传

文件上传用 `<input type="file">` + FormData + fetch：

```javascript
var fileInput = document.querySelector("input[type='file']");
var file = fileInput.files[0];  // 用户选择的文件

var formData = new FormData();
formData.append("avatar", file);
formData.append("description", "我的头像");

fetch("/api/upload", {
  method: "POST",
  body: formData  // 自动设置 Content-Type 为 multipart/form-data
})
  .then(function(response) {
    if (!response.ok) throw new Error("上传失败：" + response.status);
    return response.json();
  })
  .then(function(result) {
    console.log("上传成功！", result);
  });
```

### AbortController —— 取消请求

有时候用户离开页面、或者点了取消按钮，你需要中断正在进行的 fetch。这需要 `AbortController`：

```javascript
// 创建一个控制器
var controller = new AbortController();

// 发起请求时绑定 signal
fetch("/api/slow-data", {
  signal: controller.signal  // 把信号传进去
})
  .then(function(response) { return response.json(); })
  .then(function(data) { console.log(data); })
  .catch(function(error) {
    if (error.name === "AbortError") {
      console.log("请求被用户取消了！");
    } else {
      console.error("其他错误：", error);
    }
  });

// 用户在 2 秒后点取消
setTimeout(function() {
  controller.abort();  // 取消请求！
  console.log("请求已取消");
}, 2000);
```

`AbortController` 就像一个"电视遥控器"——你随时可以按下停止键，正在发送（或接收）的请求就会被中断。`catch` 中捕获的 `AbortError` 表示这个取消行为。

### 关联 JS-A 知识

- `JSON.stringify` 和 `JSON.parse` 在 A 篇学过了——现在它们用于序列化请求体和解析响应体
- `FormData` 类似于 A 篇学过的 `Map`——key-value 对，可以用 `.append()` 添加
- `AbortController` 的 signal 模式是 JS 中"取消操作"的标准模式

## 动手试试

1. 打开示例文件 `B.16-fetch-advanced.html`（需要 HTTP 服务器，`python -m http.server 8000`）
2. 尝试在"模拟 POST"区域填写数据并发起请求
3. 在"文件上传"区域选择一个文件，观察 FormData 的构建过程
4. 点击"发起慢请求"后立即点击"取消请求"，观察 AbortController 的效果
5. 打开浏览器开发者工具的 Network（网络）面板，观察每次请求的 Method、Headers、Body

## 本节小结

fetch 进阶操作：POST 需要配置 `method`、`headers`、`body`。请求体格式有三种——JSON（`Content-Type: application/json`，最常用）、FormData（表单+文件，自动设 Content-Type）、URLSearchParams（简单键值对）。`AbortController` + `signal` 可以随时取消请求（像遥控器中途关电视）。

## 下一节预告

B.17《存储方案》——数据拿到了，但一刷新就没了？不能每次都重新请求。浏览器提供了三种本地存储方案：localStorage、sessionStorage、cookie。
