# 6. 常用全局 API

## 本节你会学到什么

- 使用 console.log / error / warn / table 输出不同级别的信息
- 使用 setTimeout 和 setInterval 做定时任务和周期性任务
- 使用 JSON.parse 和 JSON.stringify 在对象和字符串之间转换
- 使用 fetch 发起 HTTP 网络请求
- 理解这些 API 为什么是"全局"的 —— 不 import 也能直接用

## 正文

### 什么是"全局 API"

在 C++ 里，有些东西不需要 `#include`，上来就能用——比如 `int`、`return`、`if`。在 Node.js 里，某些常用的 API 被挂在"全局作用域"上，你不需要 import 任何包，在任何 `.ts` 文件里直接写函数名就能用。它们是 Node.js 运行时自带的"标配工具"。

就好像你买了一辆车，方向盘、油门、刹车是标配——不用额外选装。全局 API 就是 JavaScript 运行环境（Node.js 或浏览器）标配的这些"方向盘"。

### console —— 你的调试向导弹

`console` 是使用频率最高的全局 API。它不止有 `console.log`：

```typescript
console.log("普通日志");          // 一般信息，白字
console.error("出错了！");        // 错误信息，红字（终端中）
console.warn("警告：磁盘空间不足"); // 警告信息，黄字
console.info("提示信息");          // 提示信息，蓝字（部分环境支持）
```

不同级别的输出在终端里显示不同颜色，方便你一眼区分"正常日志"和"严重错误"。

**表格输出** —— 打印数组或对象时特别直观：

```typescript
const users = [
  { name: "小明", age: 25, city: "北京" },
  { name: "小红", age: 22, city: "上海" },
];
console.table(users);
```

**测量性能：**
```typescript
console.time("myLoop");
for (let i = 0; i < 1000000; i++) { /* 做点事 */ }
console.timeEnd("myLoop");
// 输出：myLoop: 3.45ms
```

`console` 就像一个控制台的"仪表盘"——你不只看，还能分紧急程度、看表格、测性能，是所有程序员的入门帮手。

### setTimeout / setInterval —— 你的闹钟和定时器

`setTimeout` 我们之前用过了——延迟执行一次。它的兄弟 `setInterval` 是**周期性执行**。

```typescript
// 每隔 1 秒打印一次心跳
const timerId = setInterval(() => {
  console.log("心跳...");
}, 1000);

// 10 秒后停止
setTimeout(() => {
  clearInterval(timerId);  // 取消周期性定时器
  console.log("心跳停止");
}, 10000);
```

`clearTimeout(id)` 取消 setTimeout，`clearInterval(id)` 取消 setInterval。id 就是调用它们时拿到的一个数字返回值。

**类比：闹钟设定** —— `setTimeout` 是一次性闹钟（两小时后提醒我关火），`setInterval` 是循环闹钟（每工作 25 分钟提醒我休息 5 分钟）。两者都可以用 `clearXxx` 取消。

**重要提示：** `setInterval` 不会因为回调执行时间过长而"跳过"一次。如果你的回调要跑 3 秒，间隔是 1 秒，那实际是连续执行的——前一个刚结束，后一个已经在排队了。如果回调执行时间不确定，用递归 `setTimeout` 代替 `setInterval` 会更安全。

### JSON —— 数据界的"集装箱标准"

JSON（JavaScript Object Notation）是一种数据格式，看起来像 JavaScript 对象，但本质是**纯文本字符串**。它就像国际物流中的标准集装箱——不管你的货（数据）是什么形状，打包进集装箱（序列化）后就可以通过任何运输方式（网络、文件）传过去，到了目的地再拆箱（反序列化）。

```typescript
// JavaScript 对象（在内存中，有类型、有方法）
const person = {
  name: "小明",
  age: 25,
  hobbies: ["游泳", "编程"],
};

// JSON.stringify：把对象打包成 JSON 字符串（序列化）
const jsonString: string = JSON.stringify(person);
console.log(jsonString);
// 输出：{"name":"小明","age":25,"hobbies":["游泳","编程"]}
// 注意：所有 key 都加上了双引号，这是 JSON 的语法要求

// JSON.parse：把 JSON 字符串拆箱还原成对象（反序列化）
const parsed = JSON.parse(jsonString);
console.log(parsed.name);  // "小明"
console.log(parsed.age);   // 25
```

**经典的坑：** `JSON.parse` 返回的类型是 `any`。你需要手动标注类型：

```typescript
interface User {
  name: string;
  age: number;
}

const rawData = '{"name":"小明","age":25}';
const user: User = JSON.parse(rawData) as User;  // 类型断言
// 或者更好的做法，配合类型守卫验证
```

`JSON.stringify` 也有参数可以美化输出：

```typescript
const pretty = JSON.stringify(person, null, 2);
// 第二个参数是 replacer（过滤器），第三个是缩进空格数
console.log(pretty);
// {
//   "name": "小明",
//   "age": 25,
//   "hobbies": [
//     "游泳",
//     "编程"
//   ]
// }
```

### fetch —— 你的 HTTP 快递员

`fetch` 是发起 HTTP 请求（网络请求）的现代 API。它内建在浏览器中，Node.js 从 18 版本开始也原生支持。

**类比：** fetch 是邮递员。你给它一个地址（URL），它替你去那个地址拿东西（GET 请求）或者送东西（POST 请求），然后把包裹（响应）交给你。

```typescript
async function getUserInfo(): Promise<void> {
  // fetch 返回一个 Promise<Response>
  const response: Response = await fetch("https://api.example.com/user/1");

  if (!response.ok) {
    // HTTP 状态码不是 2xx 时（比如 404, 500），ok 为 false
    console.error(`请求失败：${response.status}`);
    return;
  }

  // .json() 也是异步的——它读取整个响应体并解析为 JSON
  const data = await response.json();
  console.log(data);
}
```

**GET 请求（获取数据，不带请求体）：**
```typescript
const resp = await fetch("https://jsonplaceholder.typicode.com/posts/1");
const post = await resp.json();
console.log(post.title);
```

**带类型安全地消费 fetch 结果（TypeScript 的优势）：**
```typescript
interface Post {
  id: number;
  title: string;
  body: string;
}

async function getPost(id: number): Promise<Post> {
  const resp = await fetch(`https://jsonplaceholder.typicode.com/posts/${id}`);
  if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
  const data: Post = await resp.json() as Post;
  return data;
}

const post: Post = await getPost(1);
console.log(post.title); // TS 知道 post 有 title 属性
```

**POST 请求（发送数据）：**
```typescript
const resp = await fetch("https://api.example.com/submit", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",  // 告诉服务器：我发的是 JSON
  },
  body: JSON.stringify({ name: "小明", score: 95 }),  // 把对象打成 JSON 字符串
});
```

## 动手试试

1. 用 `console.table` 打印一个包含 3 本书信息的数组（书名、作者、页数）。
2. 用 `setInterval` 每秒打印一次当前时间，用 `console.time` 记录 5 秒总耗时，5 秒后 `clearInterval` 停止。
3. 把一个嵌套对象（含数组、日期）用 `JSON.stringify` 序列化并打印，再用 `JSON.parse` 还原。
4. 用 `fetch` 请求 `https://jsonplaceholder.typicode.com/users`，解析 JSON，用 `console.table` 打印前 3 个用户的名字和邮箱。

## 本节小结

console、setTimeout/setInterval、JSON、fetch 是 Node.js 运行时内建的"标配工具"，不需要 import 就能用，分别负责日志输出、定时任务、数据序列化和网络请求——它们是日常开发中使用频率最高的四个全局 API 族群。

## 下一节预告

网络请求可能会失败（断网了、服务器宕机了），定时器里可能抛出意外。面对这些不可控的情况，我们需要一套错误处理机制。下一节学习 try/catch/finally 和 TypeScript 中的错误类型标注。
