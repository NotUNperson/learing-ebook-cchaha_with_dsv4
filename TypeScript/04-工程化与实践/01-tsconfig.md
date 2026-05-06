# 01 tsconfig.json 详解：项目的"建筑蓝图"

## 本节你会学到什么

- 理解 tsconfig.json 就像房子的建筑蓝图，告诉 TypeScript 编译器"怎么建造"你的项目
- 掌握 target、module、outDir、rootDir 四个核心编译选项
- 学会用 include/exclude 精确控制哪些文件需要编译
- 能够创建一份可用的 tsconfig.json 并解释每行的作用
- 知道 strict 选项的存在（下一节会深入讲解）

## 正文

### 1. 没有蓝图的窘境

想象你要盖一栋房子。你没有图纸，工人全靠口头描述干活——"墙大概这么高，窗户大概这么大"。结果是什么？门框歪了，窗户尺寸不一，房间布局混乱。更糟的是，换一批工人来继续施工，他们完全不知道之前的工人做了什么，一切都要重新摸索。

写 TypeScript 项目也一样。没有 tsconfig.json，TypeScript 编译器（tsc）就像一个没有图纸的建筑工人。它不知道你想要什么输出格式，不知道哪些文件该编译、哪些该忽略，也不知道你的代码要跑在什么环境里。每次编译你都要在命令行敲一长串参数，换了电脑就得重新来一遍。

tsconfig.json 就是你的"项目蓝图"。把它放在项目根目录，整个团队就有了统一的编译标准。任何人 clone 你的项目，运行 `tsc` 就能得到完全一致的编译结果。

### 2. 一张蓝图长什么样

先看一份最精简的 tsconfig.json：

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

看起来像一份设置清单，对吧？它其实就是在说："把 src 目录下的 TypeScript 源码编译成 ES2020 标准的 JavaScript，用 CommonJS 模块格式，输出到 dist 目录，开启严格模式。"

### 3. target：你的代码要在哪里运行？

target 指定 TypeScript 编译后生成的 JavaScript 版本。类比：如果你把中文文章翻译成英文，你是要翻译成"现代美式英语"还是"莎士比亚时代的古英语"？

```json
"target": "ES2020"
```

这行意思是：生成的 JS 代码使用 ES2020 标准的语法。可选值从老的 `ES3`、`ES5` 一直到最新的 `ESNext`。

怎么选？想清楚你的代码要跑在什么环境：
- 跑在 Node.js 18+：放心用 `ES2022` 甚至 `ESNext`
- 跑在浏览器但不想兼容 IE：`ES2018` 或 `ES2020` 就够了
- 需要兼容非常老的浏览器：老老实实选 `ES5`

target 不会让你写的新语法报错——你仍然可以在 `.ts` 文件里用 `??`、`?.` 这些现代语法，tsc 会帮你把它们"降级"成目标版本支持的等价写法。

### 4. module：代码之间怎么"联络"？

module 决定 TypeScript 把你的代码"打包"成什么样的模块系统。类比：同样是一群人，你可以用对讲机通信（ES Modules），也可以用固定电话（CommonJS），或者靠喊（全局脚本）。

```json
"module": "commonjs"
```

常见选择：
- `commonjs`：Node.js 的传统模块系统，用 `require()` 和 `module.exports`
- `ES2015` / `ES2020` / `ESNext`：原生 ES Modules，用 `import` 和 `export`
- `none` / `system` / `amd`：特殊情况，基本用不到

选哪个取决于你的 target 和运行环境：
- Node.js 项目：`commonjs`（传统）或 `ES2020`（现代 Node 支持 ESM 后）
- 浏览器项目 + 打包工具（Webpack/Vite）：通常用 `ESNext`，让打包工具去处理
- 纯浏览器直接引用（不用打包工具）：用 `ES2015` 或以上

### 5. outDir 与 rootDir：入口和出口

这两个选项定义了编译的"输入从哪里来，输出到哪里去"。

```json
"outDir": "./dist",
"rootDir": "./src"
```

rootDir 是源码的"根目录"。编译器从这里开始查找 `.ts` 文件。如果你的所有源代码都在 `src/` 下，就设 `"./src"`。TypeScript 会根据这个值来推断输出目录中的文件夹结构。

outDir 是编译产物的"出口"。所有 `.ts` 文件编译成 `.js` 后，会按照 rootDir 下的目录结构原样放到 outDir 下。

打个比方：rootDir 是"原料仓库"，outDir 是"成品仓库"。你从原料仓库（src/）取出所有原料（.ts 文件），加工后（编译），按照原料仓库的货架结构（目录层级）存放到成品仓库（dist/）。

```
项目结构：
src/
  index.ts
  utils/helper.ts

编译后：
dist/
  index.js
  utils/helper.js
```

### 6. include 和 exclude：谁该进厂加工？

```json
"include": ["src"],
"exclude": ["node_modules", "dist"]
```

include 告诉编译器："只编译这些目录/文件"。exclude 告诉编译器："这些别碰"。exclude 的优先级比 include 高——如果一个文件同时被 include 匹配又被 exclude 匹配，它不会被编译。

为什么要设 exclude？有两个经典场景：
1. `node_modules`：你不想编译别人写的包，而且它们通常已经有 `.js` 文件了
2. `outDir`（即 `dist/`）：编译输出目录本身就是编译结果，递归编译它会无限循环

另外再补充一个实用的配置：`"include": ["src/**/*"]` 中的 `**/*` 表示"当前目录及所有子目录下的任意文件"。不写 `**/*` 也是可以的，TypeScript 会自动递归查找 `.ts` 文件。

### 7. 一张完整的"蓝图"怎么读

回到开头的那份配置，现在你应该能读懂每一行了：

```json
{
  "compilerOptions": {
    "target": "ES2020",      // 生成 ES2020 标准的 JS 代码
    "module": "commonjs",     // 使用 CommonJS 模块格式（require/export）
    "outDir": "./dist",       // 编译结果放到 dist 目录
    "rootDir": "./src",       // 源代码在 src 目录
    "strict": true            // 开启严格类型检查（下一节详解）
  },
  "include": ["src"],         // 只编译 src 目录下的文件
  "exclude": ["node_modules", "dist"]  // 排除 node_modules 和 dist
}
```

这份蓝图告诉 tsc：把 src 里的 TS 文件编译成 ES2020 CommonJS 格式的 JS 文件，输出到 dist，开严格检查。清晰、完整、任何人拿到项目都能看懂。

## 动手试试

1. 在 `examples/01-tsconfig/` 目录下创建一份 `tsconfig.json`（内容用上面的完整示例）
2. 在 `examples/01-tsconfig/` 下创建一个 `src/index.ts`，写入：
   ```typescript
   const greeting: string = "Hello, tsconfig!";
   console.log(greeting);
   ```
3. 在终端中 cd 到 `examples/01-tsconfig/`，运行 `npx tsc`
4. 观察 `dist/` 目录中是否生成了 `index.js`，打开查看它被编译成了什么样子
5. 修改 target 为 `"ES5"`，重新运行 `npx tsc`，对比生成的 JS 代码有什么变化

提示：如果你还没有安装 TypeScript 全局包，先运行 `npm install -g typescript`，或者直接在这个目录下用 `npx tsc`。

## 本节小结

tsconfig.json 是一份描述"怎样编译这个项目"的蓝图，target 决定输出版本，module 决定模块格式，rootDir/outDir 决定输入输出路径，include/exclude 决定编译范围——五者合在一起，让编译过程从"黑箱"变成"透明可控的流水线"。

## 下一节预告

既然 strict 选项这么重要，我们就来深入看看它到底做了什么，以及为什么开启 strict 模式能像系安全带一样保护你的代码免于大部分低级 bug。
