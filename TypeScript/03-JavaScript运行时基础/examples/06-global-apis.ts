/**
 * 06-global-apis.ts
 * 常用全局 API —— 不用 import 就能用的内置工具
 *
 * 运行方式：
 *   ts-node 06-global-apis.ts
 */

// ============================================================
// 第一部分：console —— 日志输出全家桶
// ============================================================

console.log("=== 第一部分：console 日志输出 ===");

// console.log：普通日志，白色/默认色
console.log("[log] 这是普通日志");

// console.error：错误信息，在终端通常显示为红色
console.error("[error] 这是一个错误信息");

// console.warn：警告信息，在终端通常显示为黄色
console.warn("[warn] 这是一个警告信息");

// console.info：一般信息，部分环境显示蓝色
console.info("[info] 这是一个提示信息");

// --- console.table：把数据用表格的形式打印 ---
const students = [
  { name: "张三", age: 20, score: 88, grade: "B" },
  { name: "李四", age: 22, score: 95, grade: "A" },
  { name: "王五", age: 21, score: 73, grade: "C" },
  { name: "赵六", age: 20, score: 91, grade: "A" },
];

console.log("\n学生表格：");
console.table(students);

// 还可以只打印指定的列
console.log("\n只看名字和分数：");
console.table(students, ["name", "score"]);

// --- console.time / console.timeEnd：测量代码执行时间 ---
console.log("\n性能测量：");

console.time("countLoop");
let counter: number = 0;
for (let i = 0; i < 5000000; i++) {
  counter++;
}
console.timeEnd("countLoop"); // 输出类似：countLoop: 5.23ms
console.log(`循环后 counter = ${counter}`);

// ============================================================
// 第二部分：setTimeout / setInterval —— 定时与循环
// ============================================================

console.log("\n=== 第二部分：定时器 ===");

/**
 * setTimeout 是一次性定时器：延迟后执行一次
 * setInterval 是周期性定时器：每隔一段时间执行一次
 *
 * 类比：
 *   setTimeout  = 一次性闹钟（2小时后提醒我关火）
 *   setInterval = 循环闹钟（每工作25分钟提醒我休息5分钟）
 */

// 记录程序开始时间，方便观察
const programStart: number = Date.now();
function elapsed(): string {
  return `${((Date.now() - programStart) / 1000).toFixed(1)}s`;
}

console.log(`[${elapsed()}] 程序开始`);

// setTimeout 演示：2 秒后执行一次
const timeoutId = setTimeout(() => {
  console.log(`[${elapsed()}] setTimeout：2 秒到了！`);
}, 2000);

// setInterval 演示：每 0.8 秒执行一次，共执行 5 次
let tickCount: number = 0;
const intervalId = setInterval(() => {
  tickCount++;
  console.log(`[${elapsed()}] setInterval：第 ${tickCount} 次心跳`);

  if (tickCount >= 5) {
    // 第 5 次之后停止周期定时器
    clearInterval(intervalId);
    console.log(`[${elapsed()}] setInterval 已停止`);
  }
}, 800);

console.log(`[${elapsed()}] 定时器已设置完毕（这行在定时器触发前打印）`);

// 证明 setTimeout 和 setInterval 是非阻塞的
// "定时器已设置完毕" 会在任何定时器触发前打印

// ============================================================
// 第三部分：JSON —— 数据序列化与反序列化
// ============================================================

setTimeout(() => {
  console.log("\n=== 第三部分：JSON ===");

  /**
   * JSON = JavaScript Object Notation
   * 是一种轻量级的文本数据格式，独立于编程语言
   * 看起来像 JS 对象，但本质是纯文本字符串
   *
   * 类比：国际集装箱标准
   *   不管你的货是什么形状 → 打包进标准集装箱 → 任何货轮都能运
   *   JS 对象 → JSON.stringify → JSON 字符串 → 任何语言都能解析
   */

  // 一个复杂的 JS 对象
  const book: { title: string; author: string; pages: number; tags: string[]; published: Date } = {
    title: "深入理解 TypeScript",
    author: "Basarat",
    pages: 300,
    tags: ["编程", "前端", "TypeScript"],
    published: new Date("2024-01-15"),
  };

  // JSON.stringify：把对象"打包"成 JSON 字符串（序列化）
  const jsonStr: string = JSON.stringify(book);
  console.log("序列化后的 JSON 字符串：");
  console.log(jsonStr);
  // 注意：Date 对象被转成了 ISO 字符串 "2024-01-15T00:00:00.000Z"

  // JSON.stringify 的美化输出
  const prettyJson: string = JSON.stringify(book, null, 2);
  console.log("\n美化输出：");
  console.log(prettyJson);

  // JSON.parse：把 JSON 字符串"拆箱"还原成对象（反序列化）
  const parsed: typeof book = JSON.parse(jsonStr) as typeof book;
  console.log(`\n还原后的对象：书名 = ${parsed.title}, 作者 = ${parsed.author}`);
  // 注意：Date 变成了字符串，不再是 Date 对象
  console.log(`注意：published 类型 = ${typeof parsed.published}`);

  // 类型安全地处理 JSON
  interface BookData {
    title: string;
    author: string;
    pages: number;
    tags: string[];
  }

  const rawApiResponse: string = '{"title":"TS 入门","author":"佚名","pages":180,"tags":["入门"]}';
  // 用类型断言告诉 TS 这个 any 实际上是什么形状
  const safeBook: BookData = JSON.parse(rawApiResponse) as BookData;
  console.log(`\n类型安全的解析：${safeBook.title}（${safeBook.pages}页）`);

}, 2500);

// ============================================================
// 第四部分：fetch —— HTTP 网络请求
// ============================================================

setTimeout(() => {
  console.log("\n=== 第四部分：fetch HTTP 请求 ===");

  /**
   * fetch 是发起 HTTP 请求的现代 API
   * 类比：fetch 就是快递员
   *   你给地址 → 他去取（GET）或送（POST）→ 回来给你包裹（Response）
   */

  // 定义 API 返回的数据结构（让 TS 帮我们做类型检查）
  interface Post {
    userId: number;
    id: number;
    title: string;
    body: string;
  }

  // 封装一个类型安全的 fetch 函数
  async function fetchPost(postId: number): Promise<Post> {
    console.log(`[fetch] 正在请求文章 ID=${postId}...`);

    // fetch 返回 Promise<Response>，所以用 await
    const response: Response = await fetch(
      `https://jsonplaceholder.typicode.com/posts/${postId}`
    );

    // 检查 HTTP 状态码是否成功（200-299 之间 ok 才为 true）
    if (!response.ok) {
      throw new Error(`HTTP 请求失败，状态码：${response.status}`);
    }

    // .json() 读取响应体并解析为 JSON（它也是异步的！）
    const data: Post = (await response.json()) as Post;
    console.log(`[fetch] 收到：${data.title.substring(0, 30)}...`);
    return data;
  }

  // 调用封装的函数
  fetchPost(1)
    .then((post: Post) => {
      console.log(`\n文章详情：`);
      console.log(`  标题：${post.title}`);
      console.log(`  内容：${post.body.substring(0, 60)}...`);
    })
    .catch((error: Error) => {
      console.error(`fetch 失败：${error.message}`);
    });

}, 5000);

// ============================================================
// 第五部分：fetch POST 请求
// ============================================================

setTimeout(() => {
  console.log("\n=== 第五部分：fetch POST 请求 ===");

  // POST 请求用于向服务器提交数据
  // 类比：你填了一张表格，交给快递员送给服务器

  interface CreatePostRequest {
    title: string;
    body: string;
    userId: number;
  }

  interface CreatePostResponse {
    id: number;
    title: string;
    body: string;
    userId: number;
  }

  async function createPost(): Promise<CreatePostResponse> {
    const newPost: CreatePostRequest = {
      title: "TS 运行时学习笔记",
      body: "今天学习了 fetch API，它可以用来发 HTTP 请求。",
      userId: 1,
    };

    console.log("[POST] 正在提交新文章...");

    const response: Response = await fetch(
      "https://jsonplaceholder.typicode.com/posts",
      {
        method: "POST", // 指定 HTTP 方法
        headers: {
          // 告诉服务器我们发送的是 JSON 格式
          "Content-Type": "application/json",
        },
        // 把 JS 对象序列化为 JSON 字符串放进请求体
        body: JSON.stringify(newPost),
      }
    );

    if (!response.ok) {
      throw new Error(`POST 失败：${response.status}`);
    }

    const result: CreatePostResponse = (await response.json()) as CreatePostResponse;
    return result;
  }

  createPost()
    .then((created: CreatePostResponse) => {
      console.log(`[POST] 创建成功！新文章 ID：${created.id}`);
      console.log(`  标题：${created.title}`);
    })
    .catch((error: Error) => {
      console.error(`[POST] 失败：${error.message}`);
    });

}, 7000);

// ============================================================
// 第六部分：全局 API 总结
// ============================================================

setTimeout(() => {
  console.log("\n=== 第六部分：全局 API 总结 ===");

  const summary: string = `
┌────────────────┬──────────────────────────────────────┐
│ 全局 API        │ 用途                                  │
├────────────────┼──────────────────────────────────────┤
│ console.log    │ 普通日志（白色）                        │
│ console.error  │ 错误日志（红色）                        │
│ console.warn   │ 警告日志（黄色）                        │
│ console.table  │ 表格形式的输出                          │
│ console.time   │ 性能测量（开始计时）                    │
│ console.timeEnd│ 性能测量（结束计时并打印）              │
├────────────────┼──────────────────────────────────────┤
│ setTimeout     │ 延迟执行一次（一次性闹钟）              │
│ setInterval    │ 周期性执行（循环闹钟）                  │
│ clearTimeout   │ 取消 setTimeout                        │
│ clearInterval  │ 取消 setInterval                       │
├────────────────┼──────────────────────────────────────┤
│ JSON.stringify │ 对象 → JSON 字符串（序列化/装箱）       │
│ JSON.parse     │ JSON 字符串 → 对象（反序列化/拆箱）     │
├────────────────┼──────────────────────────────────────┤
│ fetch          │ 发起 HTTP 网络请求（GET/POST/...）      │
│ Response.json()│ 把响应体解析为 JSON 对象                │
└────────────────┴──────────────────────────────────────┘

所有这些都是全局的 —— 不需要 import 任何东西就能直接使用。
它们由 Node.js 运行时（或浏览器环境）直接提供，就像汽车的标配方向盘和油门。
`;

  console.log(summary);

  console.log("全部演示结束！");
}, 9000);

// 程序总运行时间约 9 秒
