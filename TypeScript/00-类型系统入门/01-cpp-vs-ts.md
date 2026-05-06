# 01 C++ 与 TypeScript：相似与不同

## 本节你会学到什么

- 理解 TypeScript 和 C++ 在"编译"这件事上的本质区别
- 明白 TypeScript 的类型系统为什么叫"渐进类型"
- 知道 TypeScript 代码在哪里运行，和 C++ 的运行环境有何不同
- 看到第一个 TypeScript 程序，并理解它和 C++ 的 hello world 哪里不一样

## 正文

如果你刚接触 TypeScript，脑子里可能有个模糊的问题：这东西和 C++ 到底有什么关系？都是"有类型的语言"，但是学起来感觉完全不一样。这一节我们就来把这两个东西摆在一起，看看它们到底哪里像、哪里不像。

### 编译 vs 转译：一个变成机器码，一个变成 JavaScript

在 C++ 里，你写完代码后，编译器（比如 g++ 或者 MSVC）会把你的 `.cpp` 文件变成二进制的机器码，然后操作系统直接执行这个二进制文件。这个过程叫**编译**。

举个例子，你在 C++ 里写：

```cpp
int add(int a, int b) {
    return a + b;
}
```

编译器做的事情是：把这段文本翻译成 CPU 能直接"吃"的指令。翻译完之后，你的源码文件就"退休"了---真正跑起来的是一堆二进制数字。

TypeScript 的做法完全不同。TypeScript 编译器（`tsc`）做的事情叫**转译**：它把你的 `.ts` 文件变成 `.js` 文件。然后，你需要在 Node.js 或者浏览器里运行这个 `.js` 文件。也就是说，TypeScript **永远不会直接变成机器码**，它永远会先变成 JavaScript，再由 JavaScript 引擎去执行。

那 TypeScript 的类型检查到哪里去了？答案是：**只在转译阶段起作用**。`tsc` 会检查你写的类型对不对，如果有问题就报错。但一旦检查通过，转译出来的 JavaScript 文件里，所有的类型标注都会被删掉。这有点像你去机场过安检---安检员（TypeScript 编译器）会检查你的行李（类型）有没有问题，没问题就让你过去，但他不会跟着你一起上飞机。上了飞机之后（运行时），只有你本人（JavaScript 代码）在。

### 静态类型 vs 渐进类型：可以写类型，也可以不写

C++ 是**静态类型**语言。每个变量在声明时就必须指定类型，而且这个类型在编译期就确定下来了，运行的时候绝不会变。

```cpp
int age = 25;       // age 永远是一个 int
auto name = "Tom";  // auto 只是语法糖，编译器还是会推导出 const char*
```

TypeScript 是**渐进类型**语言。这意味着你可以给变量标注类型，也可以不标。如果你不标，TypeScript 会尽量"猜"出类型（这个"猜"的正式名称叫**类型推断**，我们第 04 节会细讲）。如果你标了，那编译器就会按照你标的类型来做检查。

```typescript
let age = 25;             // TypeScript 猜出 age 是 number，不用你写
let name: string = "Tom"; // 你也可以显式标注类型
let anything: any = 42;   // any 表示"这东西什么类型都行"——C++ 里没有这种东西
```

可以把 TypeScript 的类型标注想象成给快递盒贴标签。你可以贴"易碎"标签（标注类型），快递员（编译器）就会按照标签来处理。但即使你不贴标签（不标注类型），快递员也会看看盒子大小、重量自己判断（类型推断）该怎么搬。而在 C++ 里，你**必须**贴标签，不贴就发不出去。

"渐进"这个词的意思是：你可以从一个完全没有类型的 JavaScript 项目开始，**渐**渐地给代码加上类型标注，变成 TypeScript。不需要一次全改完。

### 运行环境：操作系统 vs JavaScript 引擎

C++ 编译出来的程序直接在操作系统上跑。你可以访问文件系统、操作内存、发网络请求——权限很大，什么都干得了。

TypeScript 转译成 JavaScript 之后，只能在 JavaScript 运行时里跑。最常见的两个运行时是**浏览器**和 **Node.js**。它们能做的事情是受限的：浏览器里的 JS 不能随便读写你电脑上的文件（安全限制），Node.js 可以读写文件但用的是另外一套 API。

这导致一个很有意思的差别：C++ 的 `int` 永远是 4 个字节（在大多数平台上），但 TypeScript 的 `number` 底层对应的是 JavaScript 的 `number`，而 JavaScript 的 `number` 是 64 位浮点数。TypeScript 的 `number` 和 C++ 的 `int` 虽然看起来都叫"数字"，但底层是完全不同的东西。

### 第一个 TypeScript 程序

我们来看一个最简单的 TypeScript 程序。对比 C++ 的 hello world，看看多了什么、少了什么：

**C++ 版：**
```cpp
#include <iostream>
int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
```

**TypeScript 版：**
```typescript
let message: string = "Hello, World!";
console.log(message);
```

几个关键区别：

1. TypeScript 没有 `main` 函数。代码从上到下直接执行，不需要一个"入口"。
2. TypeScript 不需要 `#include`。它用 `import` 来引入模块，但如果只打印一句话，什么都不用引入。
3. TypeScript 没有 `return 0`。程序执行完自然就结束了。
4. `console.log` 类似于 `std::cout`，但更简洁。不需要写 `std::` 前缀，直接就能用。

## 动手试试

1. 确保你的电脑上已经安装了 Node.js（打开命令行，输入 `node -v`，如果显示版本号就说明装好了）。
2. 安装 TypeScript：在命令行里输入 `npm install -g typescript`（Mac/Linux 可能需要加 `sudo`）。
3. 创建一个 `hello.ts` 文件，把上面的 TypeScript 代码抄进去。
4. 用 `tsc hello.ts` 编译它，你会看到生成了一个 `hello.js` 文件。
5. 用 `node hello.js` 运行生成的 JavaScript 文件，看输出。
6. 打开 `hello.js`，找找类型标注 `: string` 还在不在——它已经没了。

## 本节小结

TypeScript 是在 JavaScript 之上加了一层类型检查，编译后类型全部消失，代码变成纯 JavaScript 在 Node.js 或浏览器里运行——和 C++ 编译成机器码完全不同。

## 下一节预告

下一节我们开始写实际的 TypeScript 代码，先学变量声明——`let` 和 `const`，以及它们和 C++ 的 `int`、`const int` 有什么对应关系。
