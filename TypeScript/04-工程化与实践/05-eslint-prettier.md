# 05 ESLint + Prettier：代码风格的"作文评分标准"

## 本节你会学到什么

- 理解为什么团队需要统一的代码风格——就像语文考试需要统一的作文评分标准
- 区分 ESLint 和 Prettier 的职责：一个管"内容质量"，一个管"格式美观"
- 掌握 ESLint 的基本配置方法：extends、rules、overrides
- 掌握 Prettier 的配置方法：为什么规则很少，以及怎么和 ESLint 不打架
- 能在自己的项目中配置 ESLint + Prettier，享受"保存即格式化"的流畅体验

## 正文

### 1. 同一个班的作文，截然不同的写法

假设你是一个语文老师，收了 50 篇作文。打开第一份：字迹潦草，段落之间没有空行，标点时而全角时而半角。第二份：字迹工整，但通篇没分段——一整页只有一个自然段。第三份：格式完美，但满篇错别字和语法错误。

你改得很痛苦，因为每份作文的"标准"都不一样。更麻烦的是，学生之间互评作文时争执不断——"你这个逗号用得不对！""我家的规矩就是这样的！"

这就是没有代码风格工具时的团队协作现状：A 用了 4 格缩进，B 用了 2 格；C 喜欢单引号，D 非要用双引号；E 习惯在文件末尾留一个空行，F 觉得这是浪费。每次提交代码，diff 里一半都是格式改动而不是实质性的修改，review 的人要花大量时间在"这里该不该换行"这种无意义讨论上。

解决方案就是制定一套"作文评分标准"，并且让这套标准自动化执行——你只要写好内容，格式由工具自动处理。这正是 ESLint 和 Prettier 做的事情。

### 2. ESLint：作文的内容评审

ESLint 负责检查代码的"内容质量"。它能发现：

- **错误用法**：你写了一个变量但从来没用过（`no-unused-vars`）
- **潜在 bug**：在条件判断里用了赋值 `=` 而不是比较 `===`（`no-cond-assign`）
- **最佳实践违规**：使用了 `var` 而不是 `const/let`（`no-var`）
- **TypeScript 专属问题**：声明了类型但没用上（`@typescript-eslint/no-unused-vars`）

ESLint 可以换成这样一个类比：它就像作文审阅员，检查你有没有写错别字（语法错误）、有没有前后矛盾（逻辑问题）、引用了别人但没标注出处（未使用的 import）。

一份基础 ESLint 配置（`.eslintrc.json`）：

```json
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "rules": {
    "no-console": "warn",
    "@typescript-eslint/no-unused-vars": "error",
    "prefer-const": "error"
  },
  "ignorePatterns": ["dist", "node_modules"]
}
```

解析一下：
- **`parser`**：告诉 ESLint 用 TypeScript 解析器来读你的 .ts 文件（ESLint 默认只认识 JavaScript 语法）
- **`plugins`**：加载 @typescript-eslint 插件，提供 TypeScript 专属规则
- **`extends`**：继承两套推荐的规则集（eslint 推荐 + TS 推荐），不需要自己一条一条写
- **`rules`**：覆盖或新增特定规则的级别（`"off"` 关闭，`"warn"` 警告，`"error"` 报错）
- **`ignorePatterns`**：哪些目录/文件不需要检查

### 3. Prettier：作文的排版美化

Prettier 只做一件事：把代码格式化成统一的样子。它不管你的代码有没有 bug，只管"好不好看"：

- 缩进是 2 格还是 4 格
- 用单引号还是双引号
- 行尾要不要加分号
- 一行最多多少个字符，超了自动换行
- 对象、数组的括号后要不要空格

Prettier 的核心理念是"意见固执的"（opinionated）——它不给你太多选择，因为选择越多，团队争议越大。它就像一个排版机器人，你给它一段乱七八糟的代码，它吐出来一段格式完美的代码。

一份 Prettier 配置（`.prettierrc`）：

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "all",
  "printWidth": 100
}
```

| 选项 | 含义 | 示例 |
|------|------|------|
| `semi: true` | 语句末尾加分号 | `const x = 1;` |
| `singleQuote: true` | 用单引号 | `import { foo } from 'bar'` |
| `tabWidth: 2` | 缩进 2 格 | |
| `trailingComma: "all"` | 多行结构最后加逗号 | `{ a: 1, b: 2, }` |
| `printWidth: 100` | 一行最多 100 字符 | 超了自动换行 |

Prettier 的类比很简单：它就像语文考试的卷面分标准——"字迹工整、段落分明、标点规范"。它不关心你的作文内容好不好，只关心看起来是否整洁。

### 4. ESLint 和 Prettier 怎么不打架？

这两个工具天然有重叠区域——ESLint 也有一些格式规则（比如 `no-mixed-spaces-and-tabs`、`comma-dangle`），Prettier 也会决定许多格式细节。如果不处理，它们会对同一行代码产生不同的"正确格式"，就像两个健身教练一个让你"深蹲脚尖朝前"，一个让你"脚尖外八"。

解决方法是 `eslint-config-prettier`——它的唯一作用就是"关掉 ESLint 中所有和 Prettier 冲突的规则"。

```bash
npm install -D eslint-config-prettier
```

然后在 `.eslintrc.json` 的 extends 数组最后加上它：

```json
{
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"  // 必须在最后！它的作用就是覆盖前面的格式规则
  ]
}
```

顺序很重要：prettier 必须放在 extends 数组的最后，这样它才能覆盖掉前面配置中所有和格式相关的规则。就像最终裁判——前面的评审员可以提意见，但 Prettier 有最终决定权。

### 5. 工作流：保存即格式化

配置好后，你的日常体验是这样的：

1. 写代码时尽情发挥，缩进乱一点、换行随便一点，没关系
2. 按 `Ctrl+S` 保存——Prettier 自动把格式整理好，ESLint 在编辑器中实时标出问题（红色波浪线）
3. 根据波浪线提示修复代码内容问题
4. 提交代码前运行 `npm run lint`，确认没有任何 ESLint 报错

大部分现代编辑器（VS Code、WebStorm）都有 ESLint 和 Prettier 插件。安装后配置"保存时自动格式化"，你就再也不用手动调整缩进和换行了。

### 6. 配置文件的位置和格式

ESLint 配置文件有多种格式可选：`.eslintrc.json`、`.eslintrc.js`、`.eslintrc.yaml`，甚至可以直接写在 `package.json` 的 `eslintConfig` 字段里。新项目推荐用 `.eslintrc.json`。

Prettier 同样支持多种格式：`.prettierrc`、`.prettierrc.json`、`prettier.config.js`。推荐用 `.prettierrc`（不带扩展名的 JSON 格式）。

## 动手试试

`examples/05-eslint-prettier/` 目录下有一份故意写得"风格不统一"的 TypeScript 文件。请完成：

1. 在该目录下运行 `npm init -y`（如果还没有 package.json）
2. 安装依赖：
   ```bash
   npm i -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin prettier eslint-config-prettier
   ```
3. 创建 `.eslintrc.json`（内容参考上面的示例）
4. 创建 `.prettierrc`（内容参考上面的示例）
5. 在 `package.json` 的 scripts 中添加：
   ```json
   "lint": "eslint . --ext .ts",
   "format": "prettier --write ."
   ```
6. 运行 `npm run lint`，观察 ESLint 报了什么错误
7. 运行 `npm run format`，观察 Prettier 把代码格式化成什么样了
8. 手动修复 ESLint 报告的代码质量问题（不是格式问题哦）

## 本节小结

ESLint 是"内容评审员"——检查代码有没有 bug 和不良实践；Prettier 是"排版机器人"——保证格式统一美观；两者配合，团队代码就像同一个语文老师教出来的，风格一致，协作流畅。

## 下一节预告

ESLint 和 Prettier 管好了你自己的代码质量。但当你 `npm install` 别人的包时，TypeScript 怎么知道那个包里面有什么类型？答案就在下一节——类型声明文件 `.d.ts`。
