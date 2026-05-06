# 06 声明文件 .d.ts：给 JavaScript 穿上"类型外套"

## 本节你会学到什么

- 理解为什么需要 .d.ts 声明文件——就像给外国友人配一个翻译，让 TypeScript 能"读懂"纯 JavaScript 代码
- 知道 `@types` 仓库是什么，以及怎么找到某个包的官方类型声明
- 学会写一个简单的 .d.ts 文件，为一个 JS 模块声明类型
- 掌握 ambient declarations（全局类型声明）的用法
- 能解决"导入一个 JS 库但 TS 说找不到类型"的经典问题

## 正文

### 1. 翻译官的故事

假设你是一个只说中文的老板，要和一个只说英文的美国客户谈生意。你不可能在开会前三个月学会英语，也不可能指望客户学会中文。最好的办法是什么？带一个翻译。

在 TypeScript 的世界里，情况类似。TypeScript 就像那位"只说中文"的老板——它只能理解带类型标注的代码。但 npm 上有数百万个纯 JavaScript 包，它们的源码全是 JS，没有任何类型信息。TypeScript 不认识它们，会直接拒绝合作：

```typescript
import _ from "lodash";  // 错误！Could not find a declaration file for module 'lodash'.
```

错误信息的意思是："我找到了 lodash 这个包的 JS 代码，但我不知道它里面有什么函数、什么类型，所以我拒绝让你用它。"

解决方案就是给纯 JavaScript 库配一个"翻译"——也就是类型声明文件（`.d.ts`）。它告诉 TypeScript："这个 JS 模块有哪些函数、每个函数的参数和返回值是什么类型。" 有了 .d.ts，TypeScript 就能像使用 TS 原生代码一样安全地使用 JS 库。

### 2. @types 仓库：现成的翻译官

绝大多数流行的 JS 库，都已经有人帮它们写好了类型声明文件，存放在 DefinitelyTyped 社区仓库里。你通过 npm 的 `@types` scope 来安装：

```bash
# lodash 本身是纯 JS 包，没有自带类型
npm install lodash

# 安装社区贡献的类型声明文件
npm install --save-dev @types/lodash
```

`@types/lodash` 安装后，会在 `node_modules/@types/lodash/` 下放置一堆 `.d.ts` 文件。TypeScript 编译器会自动到 `node_modules/@types/` 下查找类型声明——你什么都不用配置，只需要 `npm install`。

类比：`@types` 就像一个"翻译公司"。全世界的开发者把各种 JS 库的"说明书"（类型声明）上传到这里。你需要某个 JS 库的类型声明时，到翻译公司查一下——大概率已经有了。

常见的 `@types` 包：

| JS 库 | 类型声明包 | 用途 |
|-------|-----------|------|
| lodash | `@types/lodash` | 工具函数库 |
| express | `@types/express` | Web 服务器框架 |
| react | `@types/react` | React 核心库 |
| node | `@types/node` | Node.js 内置 API |
| jest | `@types/jest` | 测试框架 |

注意：越来越多的现代库已经把 `.d.ts` 文件直接放在自己的包里了（在 `package.json` 的 `"types"` 字段指向 `.d.ts` 文件）。这类库不需要单独安装 `@types` 包。

### 3. 自己写一个 .d.ts 文件

不是所有 JS 库都有现成的类型声明。有时候你会用到一个冷门的库，或者自己写了一个 JS 模块给前端同事用。这时就需要手写 `.d.ts` 文件。

假设你有一个纯 JS 模块 `calculator.js`：

```javascript
// calculator.js —— 一个纯 JavaScript 的计算器模块
function add(a, b) {
  return a + b;
}

function subtract(a, b) {
  return a - b;
}

// CommonJS 导出
module.exports = { add, subtract };
```

现在你要在 TypeScript 文件里引入它。创建一个同名的 `calculator.d.ts`：

```typescript
// calculator.d.ts —— 为 calculator.js 写的类型声明文件
export function add(a: number, b: number): number;
export function subtract(a: number, b: number): number;
```

然后 TypeScript 文件就可以安全使用了：

```typescript
import { add, subtract } from "./calculator";

const result = add(1, 2);       // TypeScript 知道 result 是 number
const wrong = add("1", "2");    // 类型错误！参数必须是 number
```

.d.ts 文件的规则很简单：
- 只写类型声明，不写实现代码（没有函数体 `{}`，只有函数签名）
- 文件扩展名必须是 `.d.ts`
- TypeScript 会自动查找和 `.js` 文件同名的 `.d.ts` 文件

类比：calculator.js 是一道菜（有实际内容），calculator.d.ts 是这道菜的营养成分表（说明含有什么、不含什么）。营养成分表不能吃（没有实现代码），但看了它你就知道吃了会怎么样（类型安全）。

### 4. declare 关键字：全局类型声明

有时候你需要告诉 TypeScript，某个"全局存在的东西"的类型——比如浏览器环境下的 `window`，Node.js 环境下的 `process`，或者 HTML 脚本标签引入的第三方库。

```typescript
// 声明一个全局变量，TypeScript 不会质疑它"存在不存在"
declare var APP_VERSION: string;

// 声明一个全局函数
declare function initializeApp(config: { apiKey: string }): void;

// 声明一个全局类
declare class Logger {
  log(message: string): void;
}

// 声明一个模块（告诉 TS 这个 JS 模块"差不多长这样"）
declare module "my-legacy-lib" {
  export function doSomething(input: string): boolean;
}
```

`declare` 关键字的含义是："TypeScript 编译器，你听着——这个东西（变量/函数/模块）确实存在，它会在运行时出现。你不要检查它有没有定义，只管检查我用得对不对。" `declare` 只是声明"存在"，不生成任何 JavaScript 代码。

类比：你在机场接机，举着一个写有客人名字的牌子。客人还没到，但你知道他会来——你现在就认这个名字（类型检查），等他到了（运行时），你就能立刻认出他。`declare` 就是那个牌子。

`declare module` 是一个特别的用法——它告诉 TypeScript 某个 npm 包"大概长什么样"。如果你用的 JS 库没有官方类型声明，也没有 `@types` 包，你可以在项目根目录创建一个 `types/` 文件夹，在里面做模块声明：

```
项目结构：
src/
types/
  my-legacy-lib.d.ts    （为 my-legacy-lib 写的类型声明）
tsconfig.json
```

并在 `tsconfig.json` 中引用：

```json
{
  "compilerOptions": {
    "typeRoots": ["./node_modules/@types", "./types"]
  }
}
```

### 5. .d.ts 文件的结构：模块声明 vs 全局声明

.d.ts 文件分两种模式：

**模块声明模式**：文件里有顶层 `import` 或 `export`。这意味着它是一个"模块"，里面声明的东西只在导入时才可见。

**全局声明模式**：文件里没有顶层 `import` 或 `export`。这意味着它是一个"脚本"，里面声明的东西在整个项目里全局可用。

```typescript
// 全局声明（没有 import/export 顶层语句）
declare var GLOBAL_CONFIG: { env: string };  // 整个项目都能直接用 GLOBAL_CONFIG

// 模块声明（有顶层 export）
export function calculate(x: number): number;  // 必须 import 才能用
```

### 6. 什么时候用哪种方式？

| 场景 | 用什么 |
|------|--------|
| 用 lodash、express 等流行库 | `npm install --save-dev @types/<包名>` |
| 用自带类型的现代库（如 axios） | 不需要额外操作，直接用 |
| 用冷门 JS 库，没有 @types | 在 `types/` 目录下写 `declare module "库名" { }` |
| 项目中有自定义 JS 模块 | 和 JS 文件同目录放同名 `.d.ts` 文件 |
| 声明浏览器/Node.js 全局变量 | 在 `.d.ts` 中用 `declare` 声明 |

## 动手试试

`examples/06-declaration-files/` 目录下有一个 `math-utils.js`（纯 JS 模块）和一个 `main.ts`（尝试引用它）。请完成：

1. 阅读 `math-utils.js`，理解它导出了什么函数
2. 在相同目录下创建 `math-utils.d.ts`，为 `math-utils.js` 中的所有函数声明类型
3. 让 `main.ts` 能正确编译——TypeScript 能检查出 `main.ts` 中对 `math-utils` 的错误调用
4. 在同一个目录下创建一个 `types.d.ts`，用 `declare` 关键字声明一个全局变量 `APP_NAME: string`，然后在 `main.ts` 中使用它
5. 运行 `npx tsc` 确保编译通过

## 本节小结

.d.ts 声明文件是 TypeScript 和 JavaScript 之间的"翻译"——@types 是社区翻译馆，declaration files 是你自己写的翻译稿，declare 关键字是你给 TypeScript 的"口头承诺"；三管齐下，TypeScript 就能和整个 JavaScript 生态无缝协作。

## 下一节预告

学完了 tsconfig、strict、路径别名、npm、ESLint/Prettier、声明文件这六大组件，是时候把它们组装起来了。下一节是综合练习——从零搭建一个完整的 TypeScript 工程模板。
