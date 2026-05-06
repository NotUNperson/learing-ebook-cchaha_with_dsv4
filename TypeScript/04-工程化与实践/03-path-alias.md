# 03 路径别名：告别 `../../../` 地狱

## 本节你会学到什么

- 认识"深层路径地狱"问题：当 import 路径变成 `../../../../../utils/helper` 时发生了什么
- 用 path alias（路径别名）把深层引用变成干净的 `@/utils/helper`
- 掌握 tsconfig.json 中 baseUrl 和 paths 的配合使用
- 理解 paths 配置中的通配符 `*` 怎么工作
- 知道如何在 Node.js 运行时正确解析路径别名（tsconfig-paths 工具）

## 正文

### 1. 图书馆里的噩梦

假设你在一个巨大的图书馆里找一本书。图书馆的目录系统告诉你："你要找的书在'社会科学 / 经济学 / 微观经济学 / 消费者行为 / 价格弹性 / 第3卷 / 第5章 / 第2页'"。你要穿过七层书架，爬三段楼梯，拐五个弯，才能拿到它。

而更好的做法是什么？给常用的区域起个简称。"经济学区域"在 E 区，"计算机科学区域"在 C 区。你只需要记住"E 区 / 价格弹性 / 第3卷"，而不是从入口开始描述全部路径。

TypeScript 项目里的 import 路径，就经常变成"图书馆噩梦"：

```typescript
// 坏味道：深不见底的相对路径
import { formatDate } from "../../../../utils/date";
import { apiClient } from "../../../services/api";
import { UserModel } from "../../../models/user";
import { calculateTax } from "../../utils/tax";
```

这几个 import 散落在一个深层嵌套的文件里。你能一眼看明白它们在引用项目的哪些模块吗？更糟的是，当你移动文件位置后，所有这些 import 路径全都要改——因为 `../../` 这种相对路径是"以当前文件所在位置为起点"来寻址的。

### 2. 路径别名的魔法

TypeScript 提供了一套解决方案：**路径别名（path alias）**。你可以在 tsconfig.json 里声明一个"缩写"：

```json
{
  "compilerOptions": {
    "baseUrl": "./src",
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```

配置完之后，上面的烂 import 变成这样：

```typescript
// 清爽！一目了然
import { formatDate } from "@/utils/date";
import { apiClient } from "@/services/api";
import { UserModel } from "@/models/user";
import { calculateTax } from "@/utils/tax";
```

`@/` 就像图书馆里的"E 区"简称——它永远指向 `src/` 目录，不管你当前文件在哪一层嵌套。你再也不用在 import 里做心算："我现在在 src/components/dashboard/widgets/ 下，去 utils 要退几层来着？"

### 3. baseUrl 和 paths 是怎么配合的

这两个选项必须一起用才能生效：

- **`baseUrl`**：告诉 TypeScript，"路径别名的起点在哪里"。通常设为 `"./src"` 或 `"."`。
- **`paths`**：定义具体的别名映射。"别名"对应的"真实路径"，是一个数组，TypeScript 会按顺序查找。

把 baseUrl 想象成"地图的中心点"——市中心的钟楼。paths 就像"以钟楼为参照物的方向指示"：`@` = "从钟楼往西走"，`@utils` = "从钟楼往南第二个路口"。

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@utils/*": ["src/utils/*"],
      "@components/*": ["src/components/*"]
    }
  }
}
```

上面的配置定义了三个别名：

| 别名 | 实际指向 | import 示例 |
|------|---------|-------------|
| `@/*` | `src/*` | `import App from "@/App"` => `src/App` |
| `@utils/*` | `src/utils/*` | `import { formatDate } from "@utils/date"` => `src/utils/date` |
| `@components/*` | `src/components/*` | `import Button from "@components/Button"` => `src/components/Button` |

`*` 是通配符，匹配任意字符串。`@/*` 中的 `*` 会捕获 `@/` 后面的整个路径，然后映射到 `src/*` 中 `*` 的位置。比如 `@/utils/date` => 捕获 `utils/date` => 映射到 `src/utils/date`。

### 4. 常见别名约定

业界有几个常用的别名惯例：

| 别名 | 指向 | 用途 |
|------|------|------|
| `@/` | `src/` | 项目源码根目录（最常用） |
| `~` | `src/` | 同 @/，部分项目使用 |
| `@components/` | `src/components/` | 专门指向组件目录 |
| `@utils/` | `src/utils/` | 专门指向工具函数目录 |

使用一致的前缀，你的 import 列表读起来就像一份"项目地图"——一眼看出这个文件依赖了哪些模块。

### 5. TypeScript 编译后，路径别名去哪了？

一个重要的问题：TypeScript 编译器**不会**自动把路径别名转换成实际路径。这意味着：

- 如果你只用 `tsc` 编译，生成的 `.js` 文件里 `@/utils/date` 还是 `@/utils/date`
- Node.js 不认识 `@/` 这个前缀，运行时会报错：`Cannot find module '@/utils/date'`

这就是路径别名的"翻译问题"——TypeScript 编译器只负责类型检查和语法转换，不负责把别名翻译成真实路径。类比：你给快递员一个内部代号（"送到'总办'"），但快递公司的导航系统只认门牌号，不认识"总办"。

解决方案有两种：

**方案一：运行时使用 tsconfig-paths**

```bash
npm install --save-dev tsconfig-paths
```

然后在运行脚本里使用：

```bash
# 原来的运行命令
node dist/index.js

# 替换为
node -r tsconfig-paths/register dist/index.js
```

`tsconfig-paths/register` 会在 Node.js 启动时读取你的 tsconfig.json，把 `@/` 翻译成真实路径。

**方案二：用打包工具（推荐）**

如果你用 Webpack、Vite 或 esbuild 等打包工具，它们本身就支持路径别名解析。你在打包配置里也声明一次别名，打包工具就会在最终输出中把 `@/` 替换掉。

这是更推荐的方案，因为生产环境通常不需要 tsconfig-paths 这个额外依赖。

### 6. 一个小技巧：多个别名覆盖不同层

如果你的项目分为"公共工具"和"业务模块"，可以用不同前缀区分：

```json
{
  "compilerOptions": {
    "baseUrl": "./src",
    "paths": {
      "@shared/*": ["shared/*"],
      "@features/*": ["features/*"],
      "@/*": ["*"]
    }
  }
}
```

这样 import 路径本身就带有"语义"——读代码的人一看就知道哪些是共享模块，哪些是业务模块。

## 动手试试

`examples/03-path-alias/` 下有一个模拟的小项目，目录结构是这样的：

```
src/
  index.ts
  utils/
    date.ts      （导出 formatDate 函数）
    math.ts      （导出 add 函数）
  components/
    Button.ts    （导出 Button 类）
```

当前 `src/index.ts` 使用深层的相对路径引用这些模块。请完成以下步骤：

1. 查看 `src/index.ts` 中现有的相对路径 import
2. 在 `tsconfig.json` 中配置 `baseUrl` 和 `paths`，让 `@/` 指向 `./src/`
3. 把 `src/index.ts` 中的相对路径 import 全部替换为 `@/` 别名
4. 运行 `npx tsc` 确认编译通过
5. （可选）安装 `tsconfig-paths`，用 `node -r tsconfig-paths/register dist/index.js` 验证运行时也能正常执行

## 本节小结

路径别名把 import 从"以当前文件为参照物的迷路地图"变成"以项目根目录为参照物的清晰路标"——`@/utils/date` 不管写在哪，永远指向同一个地方，移动文件不再是一场灾难。

## 下一节预告

有了路径别名，项目结构清爽了不少。但你的项目现在还"赤手空拳"——没有借助任何第三方库。接下来我们就要学习 TypeScript 世界的"超级市场"：npm 包管理。
