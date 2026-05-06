# 04 - 项目二：简易待办事项 Web 应用

## 本节你会学到什么

- 用 TypeScript 构建一个完整的单页面 Web 应用
- 定义 TODO 数据接口并实现渲染函数
- 理解"状态驱动视图"模式：修改数据 -> 重新渲染 -> 页面自动更新
- 熟练运用事件绑定和事件委托处理用户交互
- 掌握 TypeScript 编译后如何在 HTML 中正确引入 JS

## 正文

### 从 CLI 回到浏览器：开发心智模型的切换

前面两节我们写的是命令行工具——终端输入、终端输出，像跟电脑发电报。从这一节开始，我们要把战场搬回到浏览器。网页应用的体验完全不同：用户用鼠标点击、用键盘打字，界面即时反馈。

但核心逻辑是一样的——你还是需要定义数据结构（像是什么是一条待办事项），然后写操作数据的函数（添加、删除、标记完成），最后把它们连接到界面上。

**生活类比**：CLI 工具像一个对讲机——你对着它喊"给我来一杯咖啡"，它回复"已下单，预计 3 分钟"。Web 应用像一个自动售货机——你看到一排漂亮的按钮，按下去饮料就出来了，整个过程赏心悦目。虽然都是帮你买到饮料，但体验的复杂度差了一个量级。

### 先定义数据结构

待办事项比笔记更简单——每条待办只需要这几个属性：

```typescript
/**
 * 一条待办事项
 */
interface Todo {
    /** 唯一标识，用自增数字最简单 */
    id: number;

    /** 待办事项的文字描述 */
    text: string;

    /** 是否已完成 */
    completed: boolean;
}
```

就这么简单。一共三个字段。但你很快会发现，就是这三个字段支撑了一个完整的应用。

### 项目结构

```
examples/04-todo-web-app/
├── index.html           # 页面骨架
├── src/
│   └── main.ts          # 所有逻辑（待办管理 + 渲染 + 事件处理）
├── dist/                # 编译输出（由 tsc 自动生成）
├── tsconfig.json
└── package.json
```

对于这个规模的项目，不分多个文件反而更清晰。等代码量真正上来了再拆分。很多初学者被"一定要拆文件"的观念绑架，导致一个待办应用拆出七八个文件，每个文件只有十几行，反而增加了理解成本。

### HTML 骨架

页面分成三个区域：顶部输入区、中部待办列表、底部统计信息。

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>待办事项</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>我的待办事项</h1>

        <!-- 输入区域 -->
        <div class="input-area">
            <input type="text" id="todo-input" placeholder="输入新的待办事项..." />
            <button id="add-btn">添加</button>
        </div>

        <!-- 待办列表（由 TypeScript 动态生成） -->
        <ul id="todo-list"></ul>

        <!-- 底部统计 -->
        <div id="stats" class="stats">
            共 0 条待办，其中 0 条已完成
        </div>
    </div>

    <script src="dist/main.js"></script>
</body>
</html>
```

关键点：
- `<ul id="todo-list">` 是一个空容器，里面的内容全部由 TypeScript 动态生成。这叫"数据驱动视图"——列表长什么样，由数据决定，不用手动写死 HTML。
- `<script>` 标签引用的是 `dist/main.js`，不是 `src/main.ts`。浏览器只认编译后的 JavaScript。

### TypeScript 核心逻辑

整个应用的状态只存三个东西：
1. `todos`（所有待办的数组）
2. `nextId`（下一个可用的 ID）
3. DOM 元素的引用

```typescript
// main.ts

// ============================================================
// 类型定义
// ============================================================
interface Todo {
    id: number;
    text: string;
    completed: boolean;
}

// ============================================================
// 全局状态
// ============================================================
// 用 const 声明数组引用，但数组内容（添加/删除元素）是可以改变的
// 就像你有一张购物清单（const list），你可以在上面增减条目，只是不能把清单换成另一张纸
const todos: Todo[] = [];

let nextId: number = 1;

// ============================================================
// DOM 元素引用（用 as 断言精确类型）
// ============================================================
const inputEl = document.getElementById("todo-input") as HTMLInputElement;
const addBtnEl = document.getElementById("add-btn") as HTMLButtonElement;
const listEl = document.getElementById("todo-list") as HTMLUListElement;
const statsEl = document.getElementById("stats") as HTMLDivElement;

// 防御性检查
if (!inputEl || !addBtnEl || !listEl || !statsEl) {
    throw new Error("页面缺少必要的 DOM 元素，请检查 index.html");
}
```

### 添加待办事项

```typescript
/**
 * 添加一条新的待办事项
 * 三步走：创建对象 -> 加入数组 -> 重新渲染
 */
function addTodo(): void {
    // 1. 获取用户输入并去头尾空格
    const text = inputEl.value.trim();

    // 2. 空输入直接忽略（给用户反馈）
    if (text === "") {
        inputEl.placeholder = "输入不能为空！";
        inputEl.focus();
        return;
    }

    // 3. 创建 Todo 对象并推入数组
    const newTodo: Todo = {
        id: nextId,
        text: text,
        completed: false,
    };
    todos.push(newTodo);
    nextId++;

    // 4. 清空输入框，恢复提示文字
    inputEl.value = "";
    inputEl.placeholder = "输入新的待办事项...";

    // 5. 重新渲染页面
    render();
}
```

### 切换完成状态

```typescript
/**
 * 切换一条待办的完成状态
 * @param id - 待办事项的 ID
 */
function toggleTodo(id: number): void {
    // find 返回数组中的对象引用，修改它会直接修改原数组元素
    const todo = todos.find((t) => t.id === id);

    if (todo) {
        // 翻转完成状态：true 变 false，false 变 true
        todo.completed = !todo.completed;
        render();
    }
}
```

这里为什么 `todo.completed = !todo.completed` 能直接修改数组元素？因为 `const todos` 限制的是"引用不能变"，但数组内部每个元素（对象）的属性是可以修改的。就像你有一份打印出来的名单（数组引用固定），你可以在某个人名字旁边打勾——不影响名单本身的物理存在。

### 删除待办事项

```typescript
/**
 * 删除一条待办事项
 * @param id - 要删除的待办 ID
 */
function deleteTodo(id: number): void {
    // findIndex 返回索引，没找到返回 -1
    const index = todos.findIndex((t) => t.id === id);

    if (index !== -1) {
        todos.splice(index, 1); // 从数组中移除该元素
        render();
    }
}
```

### 渲染函数：状态 -> 视图

这是整个应用最核心的函数。它的职责是：**接受当前的 `todos` 数组，生成对应的 HTML 字符串，塞进页面**。

```typescript
/**
 * 根据当前 todos 数组重新渲染整个列表
 * 这是"状态驱动视图"的核心——只要数据变了，就调一次 render
 */
function render(): void {
    // ----- 第一步：生成列表 HTML -----
    // 如果数组为空，显示一句提示
    if (todos.length === 0) {
        listEl.innerHTML = `<li class="empty-hint">还没有待办事项，在上面输入一条吧！</li>`;
    } else {
        // map 将每条 todo 转换为一段 HTML 字符串，再 join 拼起来
        listEl.innerHTML = todos
            .map((todo) => {
                // 如果 completed 为 true，给 li 加上 "completed" 这个 class
                const completedClass = todo.completed ? "completed" : "";
                // 给按钮添加 data-id 属性，事件处理时从中读取 ID
                return `
                    <li class="todo-item ${completedClass}" data-id="${todo.id}">
                        <span class="todo-text">${escapeHtml(todo.text)}</span>
                        <button class="toggle-btn" data-id="${todo.id}">
                            ${todo.completed ? "撤销" : "完成"}
                        </button>
                        <button class="delete-btn" data-id="${todo.id}">
                            删除
                        </button>
                    </li>
                `;
            })
            .join("");
    }

    // ----- 第二步：更新底部统计 -----
    const completedCount = todos.filter((t) => t.completed).length;
    statsEl.textContent = `共 ${todos.length} 条待办，其中 ${completedCount} 条已完成`;
}

/**
 * 转义 HTML 特殊字符，防止 XSS 攻击
 * 如果用户输入 <script>alert("hack")</script>，转义后变成无害的文本
 */
function escapeHtml(text: string): string {
    const map: Record<string, string> = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#039;",
    };
    return text.replace(/[&<>"']/g, (char) => map[char]);
}
```

注意 `escapeHtml` 函数。这是一个安全机制：如果用户输入 `<script>alert("恶作剧")</script>`，直接拼进 `innerHTML` 就会执行这段脚本（XSS 攻击）。转义后它变成了纯文本显示，不会执行。

### 事件委托：用更少的代码处理更多的事件

现在我们有列表了，但点击"完成"和"删除"按钮还不会触发任何操作。最直接的做法是给每个按钮绑定事件，但这有两个问题：
1. 每次 `render()` 都会销毁所有旧 DOM 再创建新 DOM，旧的绑定就丢了
2. 如果列表有 100 条，绑定 200 个事件处理器很浪费

解决方案叫**事件委托**（Event Delegation）：把事件监听器绑在父元素（`<ul>`）上，利用事件冒泡机制，判断具体是哪个子元素被点击了。

```typescript
/**
 * 注册全局事件处理器（只绑定一次，不随 render 重复绑定）
 */
function setupEventListeners(): void {
    // ----- 添加按钮的点击事件 -----
    addBtnEl.addEventListener("click", addTodo);

    // ----- 输入框的键盘事件：按回车也能添加 -----
    inputEl.addEventListener("keydown", (e: KeyboardEvent) => {
        if (e.key === "Enter") {
            addTodo();
        }
    });

    // ----- 事件委托：在 ul 上监听点击 -----
    listEl.addEventListener("click", (e: MouseEvent) => {
        // 1. 找到被点击的具体按钮
        const target = e.target as HTMLElement;

        // 2. 获取按钮上的 data-id 属性
        // closest() 向上查找最近的匹配元素（处理点击到按钮内的文字等情况）
        const button = target.closest("button") as HTMLButtonElement | null;
        if (!button) return;

        const idStr = button.dataset.id;
        if (!idStr) return;

        const id = parseInt(idStr, 10);

        // 3. 根据按钮的 class 判断用户想做什么
        if (button.classList.contains("toggle-btn")) {
            toggleTodo(id);
        } else if (button.classList.contains("delete-btn")) {
            deleteTodo(id);
        }
    });
}
```

`closest()` 方法很好用——即使用户点到了按钮内部的文字而不是按钮本身，`closest("button")` 也会向上查找最近的 `<button>` 父元素。这解决了"有时候点不准按钮"的问题。

### 初始化

```typescript
/**
 * 应用启动
 */
function init(): void {
    setupEventListeners();
    render(); // 初始渲染（显示空列表提示）
    inputEl.focus(); // 自动聚焦到输入框，方便用户直接打字
}

init();
```

### 编译和运行

```bash
cd examples/04-todo-web-app
npm init -y
npm install typescript --save-dev

# tsconfig.json 注意：module 不要设成 commonjs
npx tsc --init

# 修改 tsconfig.json 中的关键配置（见下方）
npx tsc

# 直接在浏览器中打开 index.html 即可
```

tsconfig.json 关键配置：

```json
{
    "compilerOptions": {
        "target": "ES2016",
        "outDir": "./dist",
        "rootDir": "./src",
        "strict": true,
        "esModuleInterop": true,
        "sourceMap": true
    },
    "include": ["src/**/*"]
}
```

和第一节一样，**不设置 `module`**，让 TypeScript 使用浏览器原生支持的输出格式。

### 完整的数据流

当你点击"添加"按钮时的完整数据流：

```
用户输入 "买牛奶"
    -> addTodo() 创建 Todo 对象 { id: 1, text: "买牛奶", completed: false }
    -> todos.push(newTodo) 把对象放进数组
    -> render() 读取整个 todos 数组
    -> 遍历数组，生成一段 HTML 字符串
    -> listEl.innerHTML = ... 更新页面
    -> 用户看到列表中出现了一条待办
```

**生活类比**：这就像用收银机。你扫描商品（用户交互），商品出现在屏幕列表上（数据改变），总金额自动更新（render），收据打印出来（页面渲染）。你不会每扫一件商品就手动算一遍总价、重写一遍收据——系统自动搞定。你的 TypeScript 代码就是这套自动化系统。

### CSS 快速美化

```css
/* style.css */
* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: 'Segoe UI', sans-serif;
    background: #f0f2f5;
    display: flex;
    justify-content: center;
    padding-top: 50px;
    min-height: 100vh;
}

.container {
    background: white;
    width: 500px;
    border-radius: 12px;
    padding: 30px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

h1 { text-align: center; color: #333; margin-bottom: 20px; }

.input-area { display: flex; gap: 10px; margin-bottom: 20px; }

#todo-input {
    flex: 1;
    padding: 12px;
    border: 2px solid #e0e0e0;
    border-radius: 8px;
    font-size: 16px;
    outline: none;
    transition: border-color 0.2s;
}
#todo-input:focus { border-color: #4a90d9; }

#add-btn {
    padding: 12px 24px;
    background: #4a90d9;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    cursor: pointer;
    transition: background 0.2s;
}
#add-btn:hover { background: #357abd; }

.todo-item {
    display: flex;
    align-items: center;
    padding: 12px 16px;
    background: #fafafa;
    border-radius: 8px;
    margin-bottom: 8px;
    transition: background 0.2s;
}
.todo-item:hover { background: #f0f0f0; }

.todo-text { flex: 1; font-size: 16px; }

/* 已完成的待办：文字加删除线并变灰 */
.todo-item.completed .todo-text {
    text-decoration: line-through;
    color: #999;
}

.toggle-btn, .delete-btn {
    padding: 6px 14px;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    cursor: pointer;
    margin-left: 8px;
    transition: background 0.2s;
}

.toggle-btn { background: #f0ad4e; color: white; }
.toggle-btn:hover { background: #ec971f; }

.delete-btn { background: #d9534f; color: white; }
.delete-btn:hover { background: #c9302c; }

.stats {
    text-align: center;
    color: #888;
    font-size: 14px;
    margin-top: 20px;
    padding-top: 16px;
    border-top: 1px solid #e0e0e0;
}

.empty-hint {
    text-align: center;
    color: #aaa;
    padding: 40px 0;
    list-style: none;
}
```

### 常见坑：为什么点了按钮没反应？

1. **忘记调用 `render()`**：修改数据后一定要调 `render()`。如果只改了数组不重渲染，页面不会自己更新。
2. **TS 编译失败**：打开浏览器的开发者工具（F12），看 Console 是否有 JS 报错。确认 `dist/main.js` 存在且内容正确。
3. **`todos` 数组是 `const` 怎么还能 push？**：`const` 只保证变量引用不变（你不能 `todos = []`），但数组内容是可以修改的。这跟 C++ 的 `T* const`（指针不变）类似，不是 `const T*`（指向的内容不变）。

## 动手试试

**任务**：为待办事项添加"编辑"功能。

**具体步骤**：
1. 在 `interface Todo` 中不需要加新字段，保持简单。
2. 在列表每项的 HTML 渲染中添加一个"编辑"按钮（`<button class="edit-btn" data-id="...">编辑</button>`）。
3. 在事件委托中处理 `edit-btn` 的点击：弹出 `prompt("请输入新的待办文字：", todo.text)`，如果用户输入了有效文字，就更新该 todo 的 text 并重新渲染。
4. 在 `commands` 逻辑区添加 `editTodo(id: number, newText: string): void` 函数。
5. 测试：点击编辑 -> 输入新文字 -> 确定 -> 列表刷新。

**提示**：`prompt()` 返回的是 `string | null`（用户取消时返回 null）。你需要处理取消的情况。`window.prompt` 虽然是旧的浏览器 API，但对于学习项目完全够用。

## 本节小结

状态驱动视图是前端开发的灵魂——你只管修改数据，渲染函数负责把它变成好看的 HTML，TypeScript 在中间确保你改数据时不会改出乱码来。

## 下一节预告

现在每次刷新页面，待办都丢了。下一节我们会加入 `localStorage` 持久化，让数据扎根在浏览器里，以及加上按状态筛选功能。
