# 1. 如何运行 TypeScript

## 本节你会学到什么

- 安装 Node.js，理解它是 JavaScript 的"操作系统"
- 使用 tsc（TypeScript 编译器）把 .ts 编译成 .js
- 使用 ts-node 直接运行 .ts 文件，跳过手动编译步骤
- 对比 TypeScript 的运行流程和 C++ 的编译运行流程
- 写出并运行你的第一个 TypeScript 程序

## 正文

### 你和电脑之间的翻译官

想象你要去一个只会说法语的面包店买可颂。你不会法语，面包师不会中文。这时候你需要一个翻译——你把中文告诉翻译，翻译用法语告诉面包师，面包师做好可颂，翻译再把"谢谢"传达给你。

编程语言也需要"翻译"。计算机的 CPU 只懂机器指令（0101 二进制），几乎没人直接写二进制。于是我们有了各种编程语言，它们通过不同的"翻译方式"最终变成机器能执行的指令。

**C++ 的做法**是：你在写代码时就已经请好翻译了（编译器 g++/cl.exe），它把你的 .cpp 文件一口气翻译成 .exe（Windows）或可执行文件（Linux/Mac）。你双击运行这个 .exe，操作系统直接加载它。这个过程叫**编译型**——翻译和运行是分开的两个步骤。

**JavaScript 的做法**不一样。JavaScript 代码本身不直接跟 CPU 对话，它跟一个叫"JavaScript 引擎"的中间人对话。你写好的 .js 文件直接交给引擎，引擎一边读一边执行。这个过程叫**解释型**（现代引擎实际上会做即时编译 JIT，但你可以先理解为"边读边跑"）。

TypeScript 在中间又加了一层：TypeScript 代码先要"脱掉类型外衣"变成 JavaScript，然后才交给引擎执行。你可以理解为：你写了一封带批注的信（.ts），先把批注撕掉，得到一封干净的普通信（.js），再把普通信寄出去。

### Node.js 是什么

浏览器里内嵌了一个 JavaScript 引擎（Chrome 的叫 V8，Firefox 的叫 SpiderMonkey），用来执行网页里的 JS 代码。但如果你想让 JS 在浏览器之外运行——比如写个命令行工具、写个服务器——你需要一个独立的环境。

Node.js 就是这样一个环境。它把 Chrome 的 V8 引擎单独拿出来，外面包了一层功能（读写文件、网络请求等），让 JavaScript 可以像 Python 或 C++ 一样在操作系统层面运行。

**类比**：如果 V8 引擎是一台发动机，那么 Chrome 是一辆整车（带方向盘、座椅、音响），Node.js 是另一辆整车——同样装 V8 发动机，但内饰和功能不同，专为服务器和命令行工具设计。

### 安装 Node.js

去 [nodejs.org](https://nodejs.org) 下载 LTS（长期支持）版本安装。安装完成后打开终端（命令提示符或 PowerShell 或 bash），输入：

```bash
node --version
```

如果看到版本号（比如 `v20.11.0`），就成功了。

Node.js 安装时自带 npm（Node Package Manager），它是 JavaScript 世界的"应用商店"，用来下载别人写好的库。你也会看到它。

### 安装 TypeScript 工具

打开终端，输入：

```bash
npm install -g typescript ts-node
```

- `npm install` 是从"应用商店"下载软件。
- `-g` 是 global，意思是全局安装，安装后在任何目录都能用。
- `typescript` 是官方的 TypeScript 包，里面有 `tsc`（TypeScript Compiler）命令行工具。
- `ts-node` 是一个便捷工具，让你直接运行 .ts 文件，它内部会先编译再执行，一步到位。

验证安装：

```bash
tsc --version
ts-node --version
```

### 第一个 TypeScript 程序

创建一个文件 `hello.ts`，内容如下：

```typescript
// hello.ts —— 你的第一个 TypeScript 程序

// 类型注解：明确告诉 TS，这个变量是 string 类型
const greeting: string = "Hello, TypeScript!";

// console.log 是 Node.js 提供的全局函数，用于在终端打印文本
console.log(greeting);

// 加一点计算
const a: number = 10;
const b: number = 20;
console.log(`${a} + ${b} = ${a + b}`);
```

用 ts-node 运行：

```bash
ts-node hello.ts
```

你应该看到：

```
Hello, TypeScript!
10 + 20 = 30
```

### 对比 C++ 的流程

如果你写过 C++，你可能熟悉下面的流程：

**C++ 流程：**
1. 写 `main.cpp`（源代码）
2. 运行 `g++ main.cpp -o main.exe`（编译+链接）
3. 双击或在终端运行 `main.exe`（执行）

**TypeScript 流程（用 tsc）：**
1. 写 `hello.ts`（源代码）
2. 运行 `tsc hello.ts`（编译成 `hello.js`）
3. 运行 `node hello.js`（执行）

**TypeScript 流程（用 ts-node，更简单）：**
1. 写 `hello.ts`
2. 运行 `ts-node hello.ts`

ts-node 把步骤 2 和 3 合并了，对学习和小项目非常方便。

**关键区别：** C++ 编译后生成的是机器码（CPU 直接执行），TypeScript 编译后生成的是 JavaScript 代码（还需要 JS 引擎解释执行）。所以 TypeScript 的运行链条是：TS 源码 -> JS 代码 -> JS 引擎执行。多了一层间接，但换来了跨平台（同一份 JS 在不同操作系统上都能跑，不需要重新编译）和灵活性。

### tsconfig.json

在实际项目中，你通常不会每次手动传参数给 tsc。你会在项目根目录放一个 `tsconfig.json`，告诉 tsc 怎么编译：

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": true,
    "outDir": "./dist"
  },
  "include": ["./src"]
}
```

- `target`: 编译出来的 JS 版本。ES2020 表示用 2020 年的 JS 标准，支持的引擎更多。
- `module`: 模块系统。commonjs 是 Node.js 的传统模块格式（我们后面会专门讲模块）。
- `strict`: 开启所有严格类型检查。强烈建议开启，这样 TS 才能更好地帮你找错。
- `outDir`: 编译后的 .js 文件放到哪个目录。
- `include`: 编译哪些文件。

把这个文件放在项目根目录，然后在项目目录运行 `tsc`（不带文件名），tsc 会自动读取 `tsconfig.json` 并按配置编译。

## 动手试试

1. 打开终端，确认 `node --version`、`tsc --version`、`ts-node --version` 都能正常输出。
2. 新建一个文件 `test.ts`，定义一个变量 `yourName: string`，值是你的名字，用 `console.log` 打印一句问候。
3. 用 `ts-node test.ts` 运行它。
4. 再用 `tsc test.ts` 编译，观察生成的 `test.js` 文件内容。看看类型注解是不是被去掉了。
5. 把 `yourName` 改成数字类型，看看 tsc 会不会报错。

## 本节小结

TypeScript 代码经过编译变成 JavaScript 再交给 Node.js 执行——比起 C++ 的直接编译成机器码，多了一层间接，但获得了跨平台和更灵活的开发体验。

## 下一节预告

程序在 Node.js 里运行起来后，你会发现它默认是"一行接一行"跑的。但真实世界充满了"等一等再做"的场景（比如读文件、发网络请求）。下一节我们学习 JavaScript 如何处理这些"等等再做"的事情——回调函数和事件循环。
