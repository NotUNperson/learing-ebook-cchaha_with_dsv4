# 7. 错误处理

## 本节你会学到什么

- 使用 try/catch/finally 捕获和处理异常
- 使用 throw 抛出自定义错误
- 理解 Error 类及其子类（TypeError、RangeError 等）
- 在 TypeScript 中对 catch 到的错误对象做类型标注
- 设计"优雅降级"——出错时不崩溃而是返回一个友好的兜底方案

## 正文

### 错误是生活中的常态

你先想象一个 C++ 里的场景：你写了一个除法函数，要求用户输入两个数，然后计算 a / b。但用户可能输入一个 0 作为 b，也可能输入的不是数字，甚至可能程序都还没跑到除法那一步就崩了。C++ 用 try/catch/throw 来应对。

JavaScript 也有一套几乎一样的机制——事实上，C++ 的异常处理理念和 JavaScript 如出一辙，都是"把可能出错的地方圈起来，出错时跳到统一的处理区，不让整个程序崩溃"。

**机场安检类比：**

你把行李放进安检机（try 块）。如果行李有问题（比如超过 100ml 的液体），安检员会拦下来（throw），然后把行李拿到另一个柜台单独处理（catch 块）。安检机在处理你的行李之前和之后都要正常运转（finally 块负责开机、关机、清理）。

### try/catch/finally 基本结构

```typescript
try {
  // 可能会出错的代码，放在这里
  const result = dangerousOperation();
  console.log("成功了：" + result);
} catch (error) {
  // 如果 try 块里任何地方抛出了异常，代码跳到这儿
  console.log("出错了：" + error);
} finally {
  // 无论成功还是失败，这里的代码都会执行
  console.log("清理工作，比如关闭数据库连接");
}
```

执行流程有三种情况：
1. **try 全部正常执行完** -> 跳到 finally -> 结束
2. **try 中间抛异常** -> 跳过 try 剩余代码 -> 跳到 catch -> 跳到 finally -> 结束
3. **try 中有 return** -> 如果 finally 存在，finally 会在 return 前执行

如果 try 块中抛出的异常没有匹配的 catch 块（或根本没有 try/catch），异常会沿着调用栈"冒泡"上去——就像气泡从水底往上漂，直到某个调用层有 catch 接住它，或者一直漂到程序顶层导致崩溃。

### throw 抛出自定义错误

在 JavaScript 里，你可以 throw 任意值（字符串、数字、对象），但最佳实践是 throw `Error` 对象或其子类：

```typescript
function divide(a: number, b: number): number {
  if (b === 0) {
    // 抛出一个 Error 对象，附带描述信息
    throw new Error("除数不能为零");
    // 这行之后的代码不会执行，函数直接退出
  }
  return a / b;
}

try {
  console.log(divide(10, 0));
} catch (error) {
  console.log("计算失败：" + (error as Error).message);
}
```

### Error 的家族成员

JavaScript 内置了几种 Error 子类，用来区分不同的错误类型：

```typescript
// RangeError：值不在合法范围内
if (age < 0 || age > 150) {
  throw new RangeError(`年龄 ${age} 不在合法范围 (0-150) 内`);
}

// TypeError：类型不正确（TS 已经帮你避免了大部分，但运行时仍可能触发）
if (typeof value !== "string") {
  throw new TypeError("期望一个字符串");
}

// 自定义错误类——继承 Error
class NetworkError extends Error {
  public statusCode: number;

  constructor(message: string, statusCode: number) {
    super(message);           // 调用 Error 的构造函数
    this.name = "NetworkError";
    this.statusCode = statusCode;
  }
}

// 使用自定义错误
throw new NetworkError("服务器无响应", 500);
```

自定义错误类让你在 catch 块中可以通过 `instanceof` 区分不同类型的错误，从而采取不同的处理策略：

```typescript
try {
  await fetchData();
} catch (error) {
  if (error instanceof NetworkError) {
    console.log(`网络错误（状态码 ${error.statusCode}），稍后重试`);
    retry();
  } else if (error instanceof TypeError) {
    console.log("数据类型错误，检查代码逻辑");
  } else {
    console.log("未知错误：" + error);
  }
}
```

### TypeScript 中对 catch 错误做类型标注

这是一个历史遗留问题：`catch` 捕获的错误在 TypeScript 中默认为 `unknown` 类型（严格模式下）或 `any` 类型（宽松模式下）。你不能直接 `error.message`，需要先做类型收窄：

```typescript
try {
  riskyStuff();
} catch (error) {
  // 方式一：类型断言
  console.log((error as Error).message);

  // 方式二：类型守卫（推荐，更安全）
  if (error instanceof Error) {
    console.log(error.message);
    console.log(error.stack);  // 调用栈，调试时有用
  } else if (typeof error === "string") {
    console.log(error);        // 有人 throw 了一个字符串
  } else {
    console.log("发生了一个无法识别的错误");
  }

  // 方式三：如果确定只可能是 Error，直接断言
  const err = error as Error;
  console.log(err.message);
}
```

`tsconfig.json` 中 `strict: true` 会把 catch 变量设为 `unknown`，这迫使你显式处理，降低了"我以为它是 Error 但其实不是"的 bug。

### 优雅降级 —— 别让用户看到崩溃

写 CLI 工具或服务端程序时，错误处理的核心原则是：**尽量别崩溃，给用户一个友好的交代**。

```typescript
async function fetchWeather(city: string): Promise<string> {
  try {
    const response = await fetch(`https://api.weather.com/${city}`);
    if (!response.ok) {
      throw new Error(`天气 API 返回了 ${response.status}`);
    }
    const data = await response.json();
    return `${city} 当前气温 ${data.temp} 度`;
  } catch (error) {
    // 优雅降级：不崩溃，返回一个兜底信息
    console.error("天气查询失败：" + (error as Error).message);
    return `${city} 的天气暂时无法获取，请稍后再试`;
  }
}
```

这种"出错时返回兜底值"的策略叫**优雅降级（graceful degradation）**。就像电梯停电时，不会直接自由落体，而是启动备用电源缓缓降到最近楼层——虽然到不了目的楼层，但至少没摔下去。

### 什么时候该 throw，什么时候该返回错误值

并不是所有"不合预期"的情况都要 throw。简单原则：
- **预料的错误、可以恢复的错误** -> 返回错误值或 null（比如用户没填表单）
- **意想不到的错误、无法恢复的错误** -> throw（比如数据库连不上、文件权限不够）

但对于 Node.js 中的异步代码，Promise 本身已经提供了 reject 通道，很多时候你可以直接 `Promise.reject()` 而不是 throw，它们的效果在异步场景下等价。

## 动手试试

1. 写一个函数 `safeDivide(a: number, b: number): number`，当 b 为 0 时 throw `new Error("除数不能为零")`，在调用处用 try/catch 捕获并打印。
2. 创建一个自定义错误类 `ValidationError`，继承 Error，增加一个 `fieldName: string` 属性。写一个函数验证"用户名不能为空"，为空时 throw ValidationError，在 catch 中根据 `instanceof` 判断错误类型并打印不同信息。
3. 写一个 async 函数，里面调用 fetch 去一个不存在的网址，用 try/catch 捕获错误并返回兜底字符串，体验"优雅降级"。

## 本节小结

JavaScript 的 try/catch/finally 和 throw 与 C++ 异常处理理念一致——把可能出错的代码圈起来，出错时跳到处理区，用 finally 保证清理代码执行；自定义 Error 类可以携带更多上下文信息，帮助精细化的错误判断。

## 下一节预告

我们已经学完了所有需要的零件——变量、类型、函数、异步、模块、全局 API、错误处理。下一节是综合练习：用所有这些知识写一个命令行天气查询工具，把 fetch、JSON 解析、类型定义、async/await、错误处理串起来。
