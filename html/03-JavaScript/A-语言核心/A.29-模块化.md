# A.29 模块化

## 本节你会学到什么

- 为什么需要模块化——把代码分散到独立文件中，告别全局变量污染
- ESM（ES Modules）——现代标准：`export` 导出、`import` 导入
- CommonJS ——Node.js 老标准：`require()` 和 `module.exports`
- ESM 和 CommonJS 的关键区别
- 动态导入 `import()` ——返回 Promise，实现按需加载

## 正文

### 没有模块化会怎样

**生活类比**：你和一个室友合租。如果所有东西都堆在客厅（全局作用域），衣服、书、碗筷混在一起，找什么都费劲，而且容易互相踩到对方的东西。模块化就是把各自的物品放进各自的房间——每个模块有自己的空间，互不干扰。

在 JavaScript 中，如果所有代码写在一个文件里：
- 变量全部是全局的，team A 的 `user` 变量可能覆盖 team B 的 `user`
- 依赖关系混乱——"这个函数定义在哪？"
- 代码难以复用——要复制粘贴

### ESM（ES Modules）——现代标准

ESM 是现代 JavaScript 的标准模块系统，使用 `export` 和 `import`。

#### 导出（export）

**命名导出**——一个模块可以导出多个东西：

```javascript
// helpers.js
export const PI = 3.14159;

export function add(a, b) {
    return a + b;
}

export class Calculator {
    multiply(a, b) { return a * b; }
}
```

**默认导出**——每个模块可以有一个默认导出：

```javascript
// user.js
export default class User {
    constructor(name) {
        this.name = name;
    }
}
```

可以混合使用命名导出和默认导出。

#### 导入（import）

```javascript
// 命名导入（用花括号）
import { PI, add, Calculator } from "./helpers.js";

// 默认导入（不用花括号）
import User from "./user.js";

// 混合导入
import User, { helper } from "./module.js";

// 全部导入（namespace import）
import * as helpers from "./helpers.js";
console.log(helpers.PI);
console.log(helpers.add(1, 2));
```

注意：ESM 的导入路径必须以 `./` 或 `../` 开头（相对路径），或者是完整 URL。不能省略文件扩展名（有些打包工具允许，但原生 ESM 需要 `.js` 后缀）。

### 在 Node.js 中使用 ESM

Node.js 默认使用 CommonJS。要启用 ESM，有两种方式：

**方式一**：在 `package.json` 中设置 `"type": "module"`：
```json
{
    "name": "my-project",
    "type": "module"
}
```

**方式二**：文件名使用 `.mjs` 扩展名。

### CommonJS——Node.js 老标准

```javascript
// 导出
module.exports = {
    add(a, b) { return a + b; },
    PI: 3.14159,
};

// 或者单个导出
exports.add = function(a, b) { return a + b; };

// 导入
const math = require("./math");
console.log(math.add(1, 2));
```

### ESM vs CommonJS 区别

| 特性 | ESM | CommonJS |
|------|-----|----------|
| 语法 | `import` / `export` | `require()` / `module.exports` |
| 加载时机 | 静态（编译时确定依赖） | 动态（运行时加载） |
| 是否同步 | 异步加载 | 同步加载 |
| 默认严格模式 | 是 | 否 |
| this 值 | `undefined` | 指向 `module.exports` |
| 适用环境 | 浏览器 + Node.js | 主要在 Node.js |

最重要的区别：**ESM 是静态的**——导入导出关系在代码运行前就能确定，这让打包工具可以做"Tree Shaking"优化（去掉未使用的代码）。CommonJS 是动态的，`require` 可以在 `if` 里调用，运行时才加载。

### 动态导入 import()

`import()` 是一个类似函数的表达式（但不是函数，没有 call/apply），返回一个 Promise：

```javascript
// 条件按需加载
if (条件) {
    const module = await import("./heavyModule.js");
    module.doSomething();
}

// 异常处理
import("./maybeMissing.js")
    .then(module => module.init())
    .catch(err => console.log("模块加载失败"));
```

这是懒加载（lazy loading）的基础——只在需要时才加载模块，减少初始加载时间。

## 与 C 语言的对比

无直接对应，但概念上可以类比：C 用 `#include` 将头文件内容"粘贴"到源文件中——这是文本替换，不是模块系统。C 的多个 `.c` 文件通过链接器组合，但函数和全局变量的名字是全局可见的（除非用 `static` 限制为文件作用域）。JS 的模块化更加结构化——显式地声明哪些东西"可以给别人用"（export）以及"需要从谁那里拿"（import），而不是无差别的全局可见。

## 动手试试

（请参考 `examples/A.29-modules/` 目录中的完整示例）

1. 创建 `math.js` 模块，导出 `add`、`subtract`、`PI`
2. 创建 `main.js`，导入并使用
3. 尝试用默认导出导出一个 class，再用 `import` 导入

## 本节小结

- ESM 是现代标准：`export` 导出（命名/默认），`import` 导入（命名/默认/全部）
- CommonJS 是 Node.js 老标准：`require()` / `module.exports`
- ESM 是静态的（编译时分析），CommonJS 是动态的（运行时加载）
- `import()` 动态导入返回 Promise，实现按需加载
- Node.js 启用 ESM 需要在 `package.json` 中设 `"type": "module"`

## 下一节预告

A.30 综合练习——用前面 29 节学到的知识，写一个 Node.js 命令行 TODO 工具。这是 A 篇的收官之战。
