# 04 npm 包管理：TypeScript 世界的"超级市场"

## 本节你会学到什么

- 理解 npm 是 JavaScript/TypeScript 生态的"超级市场"——任何人都可以发布包，任何人都可以免费使用
- 读懂 package.json 的关键字段：name、version、dependencies、devDependencies、scripts
- 搞清 `dependencies` 和 `devDependencies` 的区别：超市买"食材"和买"厨具"的区别
- 掌握 `npm install`、`npx`、`npm run` 的日常使用方法
- 能在 scripts 中编写自己的构建和运行脚本

## 正文

### 1. 一个没有超市的世界

想象你生活在一个没有超市的世界。你需要什么都要自己做——自己做酱油、自己晒盐、自己种菜、自己磨面粉。光是准备一顿饭的材料就要花掉一整天，更别说做饭本身了。

幸运的是，你生活在一个有超市的世界。酱油是现成的，面粉是现成的，甚至还有预制菜——你只需要买回来，简单加工一下，就能端上桌。

npm 就是 JavaScript/TypeScript 世界里的超级市场。它是 **N**ode **P**ackage **M**anager（Node 包管理器）的缩写。全世界数百万开发者把自己写好的代码打包成"包（package）"，发布到 npm 注册表上。你需要什么功能，`npm install` 一下就能用，不需要从头造轮子。

### 2. package.json：你的"购物清单"

每个使用 npm 的项目根目录下都有一个 `package.json`。它是项目的"身份证"兼"购物清单"——记录了项目叫什么、版本是多少、依赖了哪些外部的包。

一份典型的 package.json 长这样：

```json
{
  "name": "my-ts-project",
  "version": "1.0.0",
  "description": "我的第一个 TypeScript 工程",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsc && node dist/index.js"
  },
  "dependencies": {
    "lodash": "^4.17.21"
  },
  "devDependencies": {
    "typescript": "^5.4.0",
    "@types/node": "^20.0.0"
  }
}
```

我们逐行来看这份清单。

### 3. 身份证字段：name 和 version

```json
"name": "my-ts-project",
"version": "1.0.0"
```

name 是这个包的名字。如果你要发布这个包到 npm，这个名字必须在全平台唯一。如果你只是在本地开发（不发布），名字随便起，主要是给人看。

version 遵循"语义化版本"规则，格式是 `主版本.次版本.补丁版本`（比如 `1.2.3`）。类比：主版本号是"产品代际"（iPhone 15 vs iPhone 16），次版本号是"功能更新"（iOS 17.1 vs 17.2），补丁版本号是"bug 修复"（17.2.1 vs 17.2.2）。

### 4. dependencies 和 devDependencies：食材 vs 厨具

```json
"dependencies": {
  "lodash": "^4.17.21"
},
"devDependencies": {
  "typescript": "^5.4.0",
  "@types/node": "^20.0.0"
}
```

这是 package.json 里最核心也最容易混淆的概念。

**dependencies（运行时依赖）= 食材**：你的程序运行时**必须**用到的包。比如你的代码里有 `import _ from "lodash"`，那 lodash 就是 dependencies。没有它，你的程序就像"没有酱油的红烧肉"——做不出来。

**devDependencies（开发依赖）= 厨具**：只有在**开发过程中**才用到的包。TypeScript 编译器（tsc）就是一个典型的 devDependency——你写代码时需要它把 TS 编译成 JS，但程序发布到线上后，运行的是编译好的 JS，根本不需要 tsc。

类比：去超市买做红烧肉的材料——五花肉、酱油、葱姜是 dependencies（成品本身需要）；炒锅、菜刀、砧板是 devDependencies（工具，成品不需要带着它们出门）。

```bash
# 安装一个运行依赖（会自动加到 dependencies）
npm install lodash

# 安装一个开发依赖（会自动加到 devDependencies）
npm install --save-dev typescript

# 简写
npm i lodash           # i 是 install 的缩写
npm i -D typescript    # -D 是 --save-dev 的缩写
```

### 5. 版本号前面的那些符号

```json
"lodash": "^4.17.21"
```

版本号前面的 `^`、`~` 是什么？

| 写法 | 含义 | 允许的版本范围 |
|------|------|---------------|
| `^4.17.21` | 兼容的次版本更新 | `>=4.17.21` 且 `<5.0.0` |
| `~4.17.21` | 兼容的补丁更新 | `>=4.17.21` 且 `<4.18.0` |
| `4.17.21` | 精确版本 | 就是 `4.17.21` |

`^` 最常用，意思是"版本 4.17.21 及以上，但不能跨大版本"。它的逻辑是：大版本更新（从 4 到 5）可能有不兼容的改动，自动升级有风险；但次版本和补丁版本理论上只是新增功能和修 bug，可以放心升级。

类比：你点了一杯"中杯拿铁，常温"。`^` 的意思是"中杯或以上都可以，但不能变成大杯（加了太多）"。`~` 的意思是"中杯，糖分可以微调"。精确版本的意思是"就这杯，一模一样，换一杯都不行"。

### 6. node_modules 和 package-lock.json

当你运行 `npm install` 时，npm 会做两件事：
1. 把 dependencies 和 devDependencies 里列出的所有包下载到 `node_modules/` 目录
2. 生成或更新 `package-lock.json`，记录每个包的确切版本和依赖树

`node_modules/` 这个目录**非常大**，而且里面的内容是从 npm 下载的，可以随时重新生成，所以永远不要把它提交到 git。在 `.gitignore` 里加上 `node_modules/` 是每个项目的标配。

`package-lock.json` 表面上看很枯燥（几千行 JSON），但它很重要——它确保了团队所有人 `npm install` 后得到完全一致的依赖树。类比：package.json 是"今晚聚餐，每人带一个菜"，package-lock.json 是"张三带鱼香肉丝（李四饭店，2024年3月版），王五带拍黄瓜（自己做的，配方见附件）"——精确到每个菜的来源。

### 7. scripts：一键运行的"自动化按钮"

```json
"scripts": {
  "build": "tsc",
  "start": "node dist/index.js",
  "dev": "tsc && node dist/index.js"
}
```

scripts 让你把常用命令封装成"按钮"，用 `npm run <名称>` 来一键触发：

```bash
npm run build   # 执行 tsc，编译 TypeScript
npm run start   # 执行 node dist/index.js，运行编译后的代码
npm run dev     # 先编译，再运行（&& 表示前面的命令成功才执行后面的）
```

这有什么用？你可能觉得"直接输命令也不麻烦啊"。但考虑这些场景：
- 你的构建命令是 `tsc --project tsconfig.prod.json && node scripts/postbuild.js`——每次打这么长，烦不烦？
- 新同事入职，他不需要知道你怎么编译项目，只需要知道 `npm run build`
- CI/CD 系统（自动化部署）只认 `npm run build` 这个标准接口

scripts 的意义不在于"省略几个按键"，而在于"把操作标准化"。类比：微波炉上"热牛奶"按钮——它背后是一套温度和时间参数，但你不需要知道细节，按一下就行。

### 8. npx：不用安装也能跑

`npx` 是一个随 npm 一起安装的工具，它可以**直接运行一个未安装的包**：

```bash
# 不安装 TypeScript 到全局或项目，直接运行一次 tsc
npx tsc --version

# 不安装，直接运行 ts-node（一个能在 Node.js 里直接跑 TS 的工具）
npx ts-node src/index.ts
```

npx 的作用像"一次性的试用品"——你去超市想试试新出的辣椒酱，不用买一整瓶，试吃角有个小碟子给你尝一口。尝完觉得好再买（npm install），不好拉倒。

## 动手试试

`examples/04-npm/` 目录下有一份 `package.json`，但 scripts 和 devDependencies 是空的。请完成以下步骤：

1. 在 `examples/04-npm/` 下运行 `npm init -y`（如果还没有 package.json）
2. 安装 TypeScript 作为开发依赖：`npm i -D typescript`
3. 安装 lodash 作为运行依赖：`npm i lodash`
4. 在 `scripts` 中增加：
   - `"build": "tsc"` —— 编译 TypeScript
   - `"start": "node dist/index.js"` —— 运行编译后的代码
5. 创建 `src/index.ts`，写入一段使用 lodash 的代码
6. 运行 `npm run build` 然后 `npm run start`，确认一切正常

观察 `node_modules/` 里装了多少东西，体会一下"超市"有多少货架。

## 本节小结

npm 是 JavaScript/TypeScript 世界的超级市场——package.json 是你的购物清单，dependencies 是食材（程序运行时必须），devDependencies 是厨具（开发时用），scripts 是一键操作的自动化按钮，npx 让你试吃不花钱。

## 下一节预告

依赖装好了，项目能跑了。但你和同事写的代码风格不一致怎么办？一个缩进 2 格，一个缩进 4 格；一个用单引号，一个用双引号。下节我们就请出两位"代码管家"——ESLint 和 Prettier。
