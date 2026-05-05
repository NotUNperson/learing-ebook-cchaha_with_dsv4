# A.1 JavaScript 是什么

## 本节你会学到什么

- JavaScript 的诞生故事--网景公司 10 天创造的语言
- JavaScript 和 Java 到底是什么关系（答案是：没关系，纯蹭名字）
- ECMAScript 标准化是怎么回事，ES6 为什么是里程碑
- JS 能干嘛：从前只能跑浏览器，现在服务端、移动端、桌面端都能跑
- Node.js 是什么：让 JS 脱离浏览器运行的环境
- 用 Node.js 跑你的第一行 JS 代码

## 正文

### 一、JavaScript 的诞生--一个"10 天"的传奇

1995 年，网景公司（Netscape）的浏览器 Navigator 正主宰着互联网世界。当时的网页是纯静态的，就像一本印好内容的书，翻到哪页都一样。网景觉得这样太无聊了，想要一种"让网页动起来"的语言。

这个任务交给了一位叫 Brendan Eich 的工程师。网景给他的时间只有 **10 天**。Brendan Eich 在 10 天里赶出了一门语言的雏形，最初叫 Mocha，后来改叫 LiveScript，最后定名为 **JavaScript**。

为什么叫 JavaScript？因为当时 Java（由 Sun 公司推出）非常火，网景想借 Java 的名气来推广自己的语言。**JavaScript 和 Java 除了名字像，本质上没有半毛钱关系。** 就像"日本海棠"不是海棠，只是名字里带了"海棠"两个字而已。

> 一个有趣的事实：因为写得太赶，JavaScript 早期留下了一些设计缺陷（比如 `typeof null === "object"` 这个著名的 bug），这些缺陷因为兼容性原因保留至今。理解这些"怪癖"是我们学习 JS 的一部分。

### 二、标准化之路：从混乱到 ECMAScript

JavaScript 诞生后，微软在 IE 浏览器里搞了一个叫 JScript 的兼容版本，两个版本慢慢出现了差异。开发者写代码时不得不做各种兼容处理，非常痛苦。

1997 年，网景把 JavaScript 提交给 ECMA 国际组织进行标准化。标准化后的语言叫 **ECMAScript**（简称 ES）。我们说的"JavaScript"其实就是 ECMAScript 的实现。

重要的版本节点：

| 版本 | 年份 | 意义 |
|------|------|------|
| ES3 | 1999 | 第一个广泛使用的版本 |
| ES5 | 2009 | 严格模式、JSON、数组新方法 |
| **ES6 (ES2015)** | **2015** | **里程碑！** let/const、箭头函数、class、模块、Promise... |
| ES2016+ | 每年 | 每年发布小版本，持续进化 |

**ES6 是最大的一个版本**，它让 JavaScript 从一门"玩具脚本语言"变成了可以编写大型应用的严肃语言。本教程会重点覆盖 ES6 及之后的内容。

### 三、JavaScript 能干嘛

以前 JavaScript 只有一个工作：在浏览器里操作网页（做点动画、表单验证）。现在完全不同了：

- **浏览器端**（传统主场）：操作 DOM、处理事件、前端框架（React/Vue/Angular）
- **服务端**：Node.js 让 JS 能写后端服务，处理数据库、文件、网络请求
- **移动端**：React Native、Flutter 等可以用 JS 开发手机 App
- **桌面端**：Electron 让 JS 可以写桌面软件（VS Code 就是用 JS/TypeScript 写的！）
- **其他**：游戏开发、IoT 物联网、命令行工具...

JavaScript 现在是世界上使用人数最多的编程语言之一。你学它不亏。

### 四、Node.js 是什么

**Node.js 是一个让 JavaScript 脱离浏览器运行的环境。**

你可以把 Node.js 理解为：把 Chrome 浏览器的 V8 JS 引擎拆出来，加上文件系统、网络、进程等系统能力，打包成一个独立的运行时。

有了 Node.js，你就可以像运行 C 程序一样运行 JS 程序：

```bash
node hello.js
```

本教程的 A 篇（语言核心）完全不涉及浏览器/DOM，所有示例都是用 Node.js 在命令行运行的。这样可以让你专注于 JavaScript 语言本身。

### 五、你的第一行 JS 代码

打开终端（Terminal），输入：

```bash
node -e "console.log('Hello, World!');"
```

你会看到：

```
Hello, World!
```

解释一下：
- `node` 是 Node.js 的命令
- `-e` 表示"执行后面这段字符串里的代码"（e = execute）
- `console.log()` 是 JS 里打印输出的函数，类似 C 语言里的 `printf`
- 单引号 `'Hello, World!'` 是一个字符串

你也可以把代码写进文件。新建一个 `hello.js` 文件，内容为：

```javascript
// 我的第一个 JS 程序
console.log("Hello, World!");
console.log("JavaScript，我来啦！");
```

然后在终端运行：

```bash
node hello.js
```

输出：

```
Hello, World!
JavaScript，我来啦！
```

恭喜！你已经是一个能写出并运行 JS 程序的人了。

---

## 动手试试

1. 在终端运行 `node -e "console.log('你的名字')"`，把 `'你的名字'` 换成你真正的名字。
2. 试一下 `node -e "console.log(1 + 2)"`，看看 Node.js 能不能当计算器用。
3. 创建一个 `.js` 文件，用 `console.log()` 打印三行不同的文字，然后用 `node` 运行它。

---

## 与 C 语言的对比

在 C 语言中，你要写 `#include <stdio.h>`，写 `main` 函数，用 `printf` 输出，然后编译成 `.exe` 才能运行。在 JS 中，你可以直接写 `console.log()` 然后用 Node.js 解释执行，**不需要编译、不需要 main 函数、不需要 include 任何头文件**。这是一种更轻量的编程体验。

---

## 本节小结

- JavaScript 是 Brendan Eich 在 10 天内创造的语言，和 Java 没有关系
- 标准化后的 JS 叫 ECMAScript，ES6 是最重要的里程碑版本
- JS 现在可以在浏览器、服务端、移动端、桌面端运行
- Node.js 让 JS 脱离浏览器运行，是本教程 A 篇的运行环境
- `console.log()` 是 JS 的打印输出函数，类似 C 的 `printf`

---

## 下一节预告

下一节我们正式开始写代码，学习 JS 的变量声明：`let`、`const` 和 `var`，以及它们和 C 语言变量有哪些相同和不同。
