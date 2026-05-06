# 5. 模块系统

## 本节你会学到什么

- 理解模块化的核心思想：把代码拆成"各自负责一件事"的小文件
- 掌握 ES module 的 import 和 export 语法
- 区分默认导出（export default）和命名导出（export）
- 了解 import 别名（as）和重导出
- 对比 C++ 的 #include 和 JS 的 import——编译时 vs 运行时

## 正文

### 为什么需要模块

你在 C++ 里可能经历过：项目大了以后，`.h` 和 `.cpp` 文件会按功能分门别类存放。`string_utils.h` 专门放字符串处理，`file_io.h` 专门放文件读写。这是一种**模块化**思维——每个文件管好自己的一亩三分地。

JavaScript 在出生的头十年里（1995-2015 年左右），没有原生的模块系统。在浏览器里，所有的 `<script>` 标签共用一个全局作用域，变量满天飞，很容易互相覆盖。Node.js 后来创造了 CommonJS 模块规范（`require()`/`module.exports`），但这只适用于 Node.js，不能直接在浏览器中用。

直到 ES2015（也叫 ES6），JavaScript 才有了语言层面的模块标准——**ES Module（ESM）**。TypeScript 完美支持它，这也是今天推荐的写法。

**类比：工具箱 vs 散落一地的工具**

没有模块的代码像把所有工具（螺丝刀、扳手、锤子）胡乱丢在地上。要用螺丝刀？你在一堆工具里翻。模块化后，你有一个工具箱，分了好几个格子：螺丝刀一个格子、电动工具一个格子、测量工具一个格子。需要什么直接去对应的格子拿，清清楚楚。

### 导出（export）

一个文件要把东西分享给别人，就用 `export`。两种方式：

**命名导出（Named Export）：**

```typescript
// math.ts —— 专门负责数学计算
export function add(a: number, b: number): number {
  return a + b;
}

export function multiply(a: number, b: number): number {
  return a * b;
}

export const PI: number = 3.14159;
```

一个文件可以导出多个东西，每个都有自己的名字。

**默认导出（Default Export）：**

```typescript
// user-service.ts —— 专门负责用户相关操作
export default class UserService {
  login(username: string): void {
    console.log(`${username} 登录了`);
  }
}

// 一个文件只能有一个默认导出
```

默认导出适合"一个文件主要提供一个东西"的场景，比如一个类、一个配置对象。

一个文件里可以同时有命名导出和默认导出（但不常见，建议一个文件坚持一种风格）。

### 导入（import）

别人导出，你导入：

**导入命名导出：**
```typescript
// 必须用花括号，名字必须和导出时一致
import { add, multiply, PI } from "./math";

console.log(add(2, 3));       // 5
console.log(multiply(4, PI)); // 约 12.57
```

**别名（如果名字冲突）：**
```typescript
import { add as mathAdd } from "./math";
import { add as stringAdd } from "./string-ops";

console.log(mathAdd(1, 2));      // 数字加法
console.log(stringAdd("a", "b")); // 字符串加法（拼接）
```

**导入默认导出：**
```typescript
// 不用花括号，名字可以随便起
import UserService from "./user-service";

const service = new UserService();
service.login("小明");
```

**同时导入：**
```typescript
import UserService, { UserType } from "./user-service";
```

**导入所有命名导出到一个对象：**
```typescript
import * as MathUtils from "./math";
console.log(MathUtils.add(1, 2));
```

### 对比 C++ 的 #include

这是很多从 C++ 转过来的同学容易混淆的地方：

| 特性 | C++ `#include` | JS `import` |
|------|---------------|-------------|
| 发生时机 | **编译时**（预处理器） | **运行时**（由 JS 引擎解析） |
| 作用方式 | **文本替换**（把 .h 文件内容原样粘贴到 .cpp 里） | **符号导入**（只引入你用到的那个东西，不是粘贴全文） |
| 重复包含 | 需要 `#ifndef` / `#pragma once` 防止重复 | 引擎自动处理，同一个模块只加载一次 |
| 循环引用 | 可能导致编译错误（A 包含 B，B 包含 A） | 可以处理，但最好避免 |
| 作用域 | 所有包含的内容都进入当前作用域 | 必须显式 import 才能用 |

**核心区别：** `#include` 更像一个高级的"复制粘贴"——预处理器把你 include 的文件内容直接贴进你的代码。而 `import` 是运行时的模块链接——JS 引擎找到那个模块文件，执行它，然后把导出的符号交给你。所以你只能在文件最顶层写 `import`（也有动态 `import()` 做特殊场景），不能像 `#include` 一样在函数中间写。

### 在 TypeScript 里使用 ES Module

Node.js 对 ES Module 的支持需要一点配置。有两种常见方式：

**方式一：使用 `.mts` 文件扩展名（推荐学习时用）**
将文件命名为 `foo.mts`，Node.js 会自动按 ES Module 处理。

**方式二：在 `package.json` 里设置**
```json
{
  "type": "module"
}
```
这样 `.ts` 文件都会被当作 ES Module。

**方式三：在 `tsconfig.json` 里配置**
```json
{
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "node"
  }
}
```

对于本课程的学习，我们直接使用 ts-node 配合 ES Module 配置即可。

### 重导出（Re-export）

有时候你有一个"汇总模块"，把多个模块的内容聚合再导出：

```typescript
// index.ts —— 汇总模块
export { add, multiply } from "./math";
export { default as UserService } from "./user-service";
```

这样使用者只需要 `import { add, UserService } from "./index"`，不用分别导入两个文件。这在大型项目中非常常见——每个文件夹一个 `index.ts` 做汇总，对外暴露一个干净的接口。

## 动手试试

1. 创建两个文件：`calculator.ts`（导出 add、subtract、multiply、divide 四个命名导出）和 `main.ts`（导入并使用它们）。
2. 在 `calculator.ts` 中，把 multiply 改为默认导出，其他三个为命名导出。然后在 `main.ts` 中同时导入默认导出和命名导出。
3. 试试导入别名：把 add 重命名为 plus，然后调用 plus(1, 2)。
4. 对比：如果用 C++ 的思维（#include 是粘贴），推测为什么 `import` 不用 `#pragma once`？

## 本节小结

ES Module 是 JS 的官方模块系统，export 对外分享，import 引入别人分享的东西，分命名导出和默认导出两种模式；和 C++ 的 #include 不同，import 是运行时符号导入而非编译时文本粘贴。

## 下一节预告

Node.js 除了模块系统，还内置了大量开箱即用的工具函数——打印日志、定时器、JSON 解析、网络请求。下一节我们逛一遍这个"工具箱"，掌握最常用的全局 API。
