# 07 综合练习：从零搭建 TypeScript 工程模板

## 本节你会学到什么

- 把前六节学到的知识组装成一个完整、可复用的项目模板
- 掌握从零搭建 TypeScript 工程的标准流程（目录 -> 配置 -> 依赖 -> 验证）
- 理解一个规范的 TypeScript 项目有哪些"必备组件"
- 学会在 VS Code 中配置"保存即格式化"
- 能在 10 分钟内搭建一个可用于真实开发的 TypeScript 工程骨架

## 正文

### 1. 搭乐高 vs 乱堆砖块

小时候玩过乐高吗？打开一盒新乐高，第一步不是随手抓起两块就拼——你会先把零件分类摊开，找到说明书，从第一页开始按步骤来。按照说明书搭出来的城堡，结构稳固、比例协调。不看说明书胡乱拼的结果，往往是一碰就散。

搭建一个 TypeScript 工程也一样。项目目录结构、编译配置、代码规范、依赖管理——这些东西不是"边写边加"的，而是在写第一行代码之前就搭好的骨架。很多人一开始急着写代码，等写到 500 行才发现"这个 import 路径好难看""那个变量为什么被推断成 any""同事的代码格式和我的完全不一样"——这时候再回头补配置，比一开始就搭好比麻烦五倍。

这一节我们把前六节学的所有东西串起来，按"说明书"的标准流程，从零开始搭一个完整的 TypeScript 工程模板。以后每次开新项目，你都可以复制这个模板，投入即用。

### 2. 标准流程：七步搭建法

一个规范的 TypeScript 工程的搭建顺序是这样的：

```
第 1 步：创建目录结构
第 2 步：初始化 npm 项目（package.json）
第 3 步：安装 TypeScript 和类型声明
第 4 步：编写 tsconfig.json
第 5 步：安装并配置 ESLint + Prettier
第 6 步：配置路径别名
第 7 步：编写入口文件并验证一切正常
```

每一步都对应我们前面学过的一个知识点。下面我们逐步走一遍。

### 3. 第 1 步：创建目录结构

一个好的目录设计不用复杂，但必须清晰。对于小型项目，这个结构足够了：

```
my-ts-project/
  src/                 # 所有源代码放在这里
    index.ts           # 入口文件
    utils/             # 工具函数
    types/             # 自定义类型声明（如果需要）
  dist/                # 编译输出（不要手动创建，tsc 会自动生成）
  .eslintrc.json        # ESLint 配置
  .prettierrc           # Prettier 配置
  .gitignore            # Git 忽略规则
  tsconfig.json         # TypeScript 编译配置
  package.json          # npm 项目配置
```

这个结构的"神髓"在于：**源码和编译产物分离**。src/ 里是你写的原始代码，dist/ 里是 tsc 生成的 JS 文件。你永远修改 src/，永远不手动碰 dist/。这就像厨房里的"备菜区"和"上菜区"——备菜区是你的工作台，上菜区是成品，你不会在成品盘上改刀。

### 4. 第 2 步：初始化 npm 项目

在项目根目录下执行：

```bash
npm init -y
```

`-y` 是 `--yes` 的缩写，意思是"全部用默认值，别问我"。生成的 package.json 很基础，后续我们会手动往里加东西。

### 5. 第 3 步：安装 TypeScript 和类型声明

```bash
# 安装 TypeScript 编译器（开发依赖）
npm install --save-dev typescript

# 安装 Node.js 类型声明（开发依赖）
npm install --save-dev @types/node
```

`@types/node` 包含了 Node.js 所有内置 API 的类型声明（`fs`、`path`、`process` 等），安装后你在 TypeScript 中使用这些 API 时就会有智能提示和类型检查。

### 6. 第 4 步：编写 tsconfig.json

在项目根目录创建 `tsconfig.json`：

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "baseUrl": "./src",
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

这里比第一章多加了三个选项，解释一下：

- **`esModuleInterop: true`**：让 CommonJS 模块和 ES Modules 之间互操作更顺畅。开启后你可以用 `import express from "express"` 这种写法，即使 express 实际上是 CommonJS 导出的。不用纠结原理，新项目一律开启。
- **`forceConsistentCasingInFileNames: true`**：强制文件名大小写一致。Windows 不区分大小写（`Foo.ts` 和 `foo.ts` 是同一个文件），但 Linux 区分。开启这个选项可以在 Windows 上模拟 Linux 的行为，避免部署到 Linux 服务器时出问题。
- **`skipLibCheck: true`**：跳过 `.d.ts` 文件的类型检查。这能显著加快编译速度，而且 `.d.ts` 文件是别人写的，出了问题也不是你的责任。

### 7. 第 5 步：安装并配置 ESLint + Prettier

```bash
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin prettier eslint-config-prettier
```

创建 `.eslintrc.json`：

```json
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"
  ],
  "rules": {
    "no-console": "warn",
    "@typescript-eslint/no-unused-vars": "error",
    "prefer-const": "error"
  },
  "ignorePatterns": ["dist", "node_modules"]
}
```

创建 `.prettierrc`：

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "all",
  "printWidth": 100
}
```

在 `package.json` 的 `scripts` 中添加：

```json
{
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsc && node dist/index.js",
    "lint": "eslint src --ext .ts",
    "format": "prettier --write src"
  }
}
```

### 8. 第 6 步：配置 .gitignore

这是经常被初学者忽略但极其重要的一步。在项目根目录创建 `.gitignore`：

```
node_modules/
dist/
*.js.map
.env
```

解释一下每行：
- `node_modules/`：依赖包目录，非常大，随时可通过 `npm install` 重新生成，绝对不提交
- `dist/`：编译输出目录，也是生成的，不提交
- `*.js.map`：source map 文件，调试用的，发布时不需要
- `.env`：环境变量文件，通常包含密钥、数据库密码等敏感信息，绝不能提交到公开仓库

### 9. 第 7 步：编写入口文件并验证

创建 `src/index.ts`：

```typescript
/**
 * 我的 TypeScript 工程
 * 入口文件
 */

// 使用路径别名导入工具函数
import { greet, add } from "@/utils/helpers";
import * as path from "path";

function main(): void {
  console.log("=== TypeScript 工程模板启动 ===");
  console.log(greet("TypeScript 学习者"));
  console.log(`当前工作目录：${path.resolve(".")}`);
  console.log(`3 + 5 = ${add(3, 5)}`);
}

main();
```

创建 `src/utils/helpers.ts`：

```typescript
/**
 * 工具函数模块
 */

export function greet(name: string): string {
  return `你好，${name}！欢迎使用 TypeScript 工程模板。`;
}

export function add(a: number, b: number): number {
  return a + b;
}
```

然后逐条验证：

```bash
# 1. 编译——应该没有错误
npm run build

# 2. 运行——应该输出正确的结果
npm run start

# 3. 代码检查——应该没有错误（允许有 console.warn）
npm run lint

# 4. 格式化——把代码整理成统一风格
npm run format

# 5. 一键编译+运行
npm run dev
```

如果以上五条命令全部通过，恭喜——你的 TypeScript 工程模板搭建成功！

### 10. 进阶：VS Code 集成

做了这么多配置，当然要让编辑器配合。在项目根目录创建 `.vscode/settings.json`：

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "typescript.tsdk": "node_modules/typescript/lib"
}
```

这四行配置做了什么？
1. `formatOnSave`：保存文件时自动格式化
2. `defaultFormatter`：用 Prettier 作为默认格式化工具
3. `codeActionsOnSave`：保存时自动修复 ESLint 能自动修复的问题（比如把 `let` 改成 `const`）
4. `typescript.tsdk`：告诉 VS Code 用项目本地的 TypeScript 版本，而不是 VS Code 自带的（版本一致很重要）

配上这些设置后，你的日常体验是：写代码 -> 按 Ctrl+S -> 自动格式化 + 自动修复。丝滑得像热刀切黄油。

### 11. 这个模板能复用吗？

当然能。你可以把这个目录打包成一个"模板"：

- 把整个项目文件夹复制一份
- 修改 `package.json` 中的 `name` 字段为你新项目的名字
- 删除 `dist/` 目录（如果存在的话）
- `npm install` 重新安装依赖
- 开始写新代码

或者更高级的做法：把模板放到 GitHub 上，每次开新项目就从那个仓库 clone。很多团队内部都有一个"starter template"仓库，就是这个用途。

## 动手试试

你的任务就是在 `examples/07-scaffold/` 下执行上述完整的七步流程：

1. 在 `examples/07-scaffold/` 下创建上述目录结构（src/、src/utils/）
2. 运行 `npm init -y`
3. 安装 TypeScript、@types/node、ESLint 全家桶
4. 编写 `tsconfig.json`（含路径别名）
5. 编写 `.eslintrc.json` 和 `.prettierrc`
6. 在 `package.json` 的 `scripts` 中添加 build、start、dev、lint、format
7. 编写 `src/utils/helpers.ts`（导出 greet 和 add 函数）
8. 编写 `src/index.ts`（入口文件，使用路径别名导入 helpers）
9. 创建 `.gitignore`
10. 依次运行 `npm run build`、`npm run start`、`npm run lint`、`npm run format`、`npm run dev`

如果所有命令都顺利执行且输出正确，你就是一个合格的 TypeScript 工程搭建者了。

**检查清单（全部通过才算完成）：**
- [ ] `npm run build` 无报错，`dist/` 下生成了 `.js` 文件
- [ ] `npm run start` 输出了正确的 greet 和计算信息
- [ ] `npm run lint` 无报错（至少无 error 级别的）
- [ ] `npm run format` 无报错
- [ ] `npm run dev` 一键编译+运行成功

## 本节小结

搭建 TypeScript 工程就像搭乐高——目录结构是分类摊开的零件，tsconfig 是说明书，npm 依赖是标准积木块，ESLint/Prettier 是质量检查员；按七步流程走完，你就拥有了一个"开箱即用"的工程模板，此后开新项目只需复制粘贴加修改名字。

## 下一节预告

恭喜！TypeScript 工程化与实战部分到这里就全部结束了。从 tsconfig 到 strict 模式，从路径别名到 npm 管理，从代码规范到声明文件，再到最终的综合搭建——你已经具备了像真正的软件工程师那样组织和构建 TypeScript 项目的能力。接下来，是时候把这些知识用到你自己的项目中了。
