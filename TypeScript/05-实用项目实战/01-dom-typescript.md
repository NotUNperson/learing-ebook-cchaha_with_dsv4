# 01 - TypeScript 与 DOM：让网页活起来

## 本节你会学到什么

- 掌握如何用 TypeScript 选择和操作 HTML 元素
- 理解事件类型（MouseEvent、KeyboardEvent 等）如何被 TypeScript 检查
- 学会使用类型断言（`as`）告诉 TypeScript 你比它更清楚元素的类型
- 能创建完整的 TypeScript + HTML 小项目并让它在浏览器里跑起来
- 体验类型检查如何帮你在写网页代码时少掉坑

## 正文

### 为什么 TypeScript 和网页天生是一对

还记得你学 C++ 时写一个控制台程序，要花很长时间才能看到图形界面吗？网页是另一种思路：你写一个 HTML 文件描述"页面上有什么"，然后用 JavaScript/TypeScript 控制它们怎么动。HTML 是骨架，TypeScript 是大脑。

但问题来了：JavaScript 作为一门动态语言，它对网页元素的类型感很弱。你写 `document.getElementById("btn")`，JavaScript 只知道你拿到的是"某个元素"，不知道它能不能被点击、有没有文字。TypeScript 出场后，它会说："你拿到的 `#btn` 是一个 `HTMLButtonElement`，它有 `disabled` 属性，它有 `textContent` 属性。" 就像你买了一个零件，TypeScript 给你一份详细的零件说明书。

**生活类比**：想象你去超市买了一盒牛奶。JavaScript 的做法是："这是一件商品，你可以结账。" TypeScript 的做法是："这是伊利纯牛奶，250ml，保质期到 2026 年 5 月 10 日，需要冷藏，适合搭配早餐。" 信息量完全不在一个档次。

### 第一个例子：点击按钮，改变文字

我们来做一个最简单的网页：一个按钮，一行文字。点击按钮后，文字会变。别看它简单，这里面已经用到了类型断言、事件类型、DOM 操作三大知识点。

先看 HTML 骨架：

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>TypeScript DOM 初体验</title>
</head>
<body>
    <h1 id="title">你好，世界</h1>
    <button id="change-btn">点击我换文字</button>

    <!-- 注意：浏览器不认识 .ts，所以必须引入编译后的 .js -->
    <script src="dist/main.js"></script>
</body>
</html>
```

再看 TypeScript 代码：

```typescript
// main.ts

// ----- 第一步：获取 DOM 元素 -----
// getElementById 的返回值类型是 HTMLElement | null
// HTMLElement 是比较泛的类型，它不知道自己是 h1 还是 button
// 所以我们用类型断言 as HTMLHeadingElement 告诉 TS："我确定这是标题"
const titleEl = document.getElementById("title") as HTMLHeadingElement;
const btnEl = document.getElementById("change-btn") as HTMLButtonElement;

// ----- 第二步：如果获取失败就提前退出 -----
// 这是防御性编程 —— 万一有人改 HTML 删掉了这些 id，程序不会崩
if (!titleEl || !btnEl) {
    throw new Error("找不到必要的 DOM 元素，请检查 HTML");
}

// ----- 第三步：绑定点击事件 -----
// 给 addEventListener 传入一个回调函数
// TypeScript 自动推断参数 e 的类型是 MouseEvent，因为 "click" 事件
// MouseEvent 类型有 clientX、clientY、target 等属性，TS 全知道
btnEl.addEventListener("click", (e: MouseEvent) => {
    // e.target 是被点击的元素（即按钮自己）
    // 类型是 EventTarget | null，我们断言它为 HTMLButtonElement
    const clickedBtn = e.target as HTMLButtonElement;

    // 修改标题文字
    titleEl.textContent = "你点击了按钮！文字已经改变。";

    // 让按钮自己变灰色，表示已经点过了
    clickedBtn.disabled = true;
    clickedBtn.textContent = "已点击";

    // 控制台也输出一行，证明事件确实触发了
    console.log(`按钮在坐标 (${e.clientX}, ${e.clientY}) 被点击`);
});
```

### 代码背后的类型故事

上面这个短短几十行代码，TypeScript 在背后默默帮你做了很多检查。我们来拆解几个关键点：

**1. 为什么需要类型断言 `as`？**

`document.getElementById` 的官方签名是 `(elementId: string) => HTMLElement | null`。它返回一个 `HTMLElement | null`，因为：
- `HTMLElement`：DOM 中最泛的"任意 HTML 元素"类型。它知道所有元素都有的属性（比如 `id`、`className`、`style`），但不知道 `h1` 特有的属性（比如 HTMLHeadingElement 的 `align`）或 `button` 特有的属性（比如 `disabled`）。
- `null`：元素可能不存在，所以也可能是 null。

所以我们用 `as HTMLHeadingElement` 把"普通元素"升级为"标题元素"，这样就能访问标题特有的属性和方法了。这就像你跟快递员说："这个包裹里装的是易碎品"——快递员本来只知道"这是一个包裹"，你额外告诉了他具体是什么。

**2. 事件类型是自动推断的**

当写 `btnEl.addEventListener("click", callback)` 时，TypeScript 会查一张"事件名到事件类型"的映射表：
- `"click"` -> `MouseEvent`
- `"keydown"` -> `KeyboardEvent`
- `"submit"` -> `SubmitEvent`

所以你不用显式写 `e: MouseEvent`，TS 也能自动推断。这里显式写是为了让读者看清楚类型是什么。

**3. `e.target` 是一个"模糊"的类型**

`MouseEvent` 上的 `target` 属性类型是 `EventTarget | null`，因为任何一个元素都可能被点击。如果我们需要访问按钮特有的 `disabled` 属性，就必须用 `as HTMLButtonElement` 断言。

### 如何编译和运行

因为浏览器只认 JavaScript，TypeScript 需要先编译。具体步骤：

```bash
# 进入这个示例的目录
cd examples/01-dom-basics

# 初始化 npm 项目（只需要 tsconfig.json 的话这一步可跳过）
npm init -y

# 安装 TypeScript（本地安装，版本锁定，推荐）
npm install typescript --save-dev

# 生成 tsconfig.json 配置文件
npx tsc --init

# 编译 TypeScript：输出到 dist/main.js
npx tsc

# 用浏览器直接打开 index.html 即可看到效果
# 或者用 VS Code 的 Live Server 插件更方便
```

tsconfig.json 里需要注意的配置：

```json
{
    "compilerOptions": {
        "target": "ES2016",
        "module": "commonjs",
        "outDir": "./dist",
        "rootDir": "./src",
        "strict": true,
        "esModuleInterop": true
    },
    "include": ["src/**/*"]
}
```

但这里有个坑：`module: "commonjs"` 是给 Node.js 用的，浏览器会用 `require`，这就出错了。对于浏览器项目，最简单的做法是不用模块系统。我们稍作调整：

```json
{
    "compilerOptions": {
        "target": "ES2016",
        "outDir": "./dist",
        "rootDir": "./src",
        "strict": true,
        "esModuleInterop": true
    },
    "include": ["src/**/*"]
}
```

去掉 `module` 设置，TypeScript 默认会根据 `target` 选择，或者输出为浏览器能直接理解的代码（没有 `import/export` 时）。

### 润色一下：添加键盘事件

为了让示例更丰富，我们再添加一个输入框，按回车也能改变标题：

```typescript
// 在 main.ts 中追加

const inputEl = document.getElementById("my-input") as HTMLInputElement;
if (!inputEl) {
    throw new Error("找不到输入框元素");
}

inputEl.addEventListener("keydown", (e: KeyboardEvent) => {
    // keydown 事件的类型是 KeyboardEvent，有 key、code、altKey 等属性
    if (e.key === "Enter") {
        // 读取输入框的值，设置为标题文字
        const newText = inputEl.value.trim();
        if (newText) {
            titleEl.textContent = newText;
            inputEl.value = "";          // 清空输入框
            inputEl.blur();              // 让输入框失去焦点（收起键盘）
        }
    }
});
```

现在，键盘事件的类型自动是 `KeyboardEvent`，你写错属性名（比如写成 `e.keyCode` —— 这是旧 API）TypeScript 会直接报错。这就是类型安全在实战中的价值。

### DOM 常用类型速查表

| 你写的代码 | 返回/关联的类型 | 关键属性 |
|---|---|---|
| `document.getElementById("x")` | `HTMLElement \| null` | id, className, style, textContent |
| `document.querySelector(".x")` | `Element \| null` | 更泛，不一定是 HTML |
| `document.querySelector("a")` | `HTMLAnchorElement \| null` | href, target |
| `document.querySelector("input")` | `HTMLInputElement \| null` | value, checked, disabled |
| `document.querySelector("img")` | `HTMLImageElement \| null` | src, alt, width, height |
| `addEventListener("click", fn)` | `fn` 参数是 `MouseEvent` | clientX, clientY, button, target |
| `addEventListener("keydown", fn)` | `fn` 参数是 `KeyboardEvent` | key, code, altKey, ctrlKey, shiftKey |

注意：`querySelector` 是最灵活的选择器。TypeScript 很聪明——如果你传给 `querySelector` 一个标签名（如 `"a"`），它会自动推断出 `HTMLAnchorElement`。但如果传的是类名（如 `".my-class"`），它就推断不出来了，此时需要你自己用 `as` 断言。

## 动手试试

**任务**：在现有代码基础上，添加一个计数器。

**具体步骤**：
1. 在 HTML 中添加一个新按钮 `<button id="count-btn">点击计数</button>` 和一个显示计数的 `<span id="count-display">0</span>`。
2. 在 TypeScript 中获取这两个元素（使用 `as` 断言，分别断言为 `HTMLButtonElement` 和 `HTMLSpanElement`）。
3. 绑定点击事件，每次点击让计数 +1，并更新 span 的文字。
4. 编译后刷新浏览器，看计数器是否正常工作。

**提示**：你需要声明一个 `let count = 0;` 变量在事件回调外部，这样它才能"记忆"状态。

**进阶挑战**：再加一个"重置"按钮，把计数变回 0。

## 本节小结

TypeScript 让 DOM 操作从"摸着石头过河"变成"看着地图走"——类型断言帮你精确锁定元素类型，事件类型自动检查让你的回调函数参数不出错。

## 下一节预告

我们将开始第一个完整项目：用 TypeScript 写一个命令行笔记管理器，学会定义接口、读写文件、组织项目结构。
