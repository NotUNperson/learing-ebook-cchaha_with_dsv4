# 06 - 毕业练习：自主扩展你的项目

## 本节你会学到什么

- 在已有项目基础上独立设计和实现新功能
- 识别一个"扩展需求"需要修改哪些层（类型层、数据层、渲染层）
- 从需求出发推导实现方案，而不是从代码出发
- 体会"类型先行"的开发方式在独立项目中如何指导你
- 完成从"跟着教程写"到"自己独立写"的关键跨越

## 正文

### 恭喜你走到这里

回顾一下你做了什么：

1. 学会了 TypeScript 操作 DOM，让网页动起来
2. 用 Node.js 写了一个 CLI 笔记管理器，从类型定义到文件读写再到菜单交互
3. 给笔记管理器加了搜索、标签、导出功能
4. 用浏览器原生 API 写了一个待办事项 Web 应用
5. 给待办应用加了 localStorage 持久化和状态筛选

你不只是"学会了 TypeScript 语法"——你已经用 TypeScript 完成了两个完整的项目，经历了从需求到成品的全流程。

现在到了最关键的一步：**不拿完整的参考代码，自己扩展一个新功能**。这是从"跟着做"到"独立做"的最后一公里。

**生活类比**：前面五节像是驾校教练坐在副驾驶，告诉你"现在踩离合、挂一档、松手刹"。这一节是你拿到实习驾照后第一次独自上路。路还是那条路（TypeScript 还是 TypeScript），但你得自己判断什么时候加速、什么时候打灯。紧张是正常的，但你已经具备了上路所需的所有技能。

### 选一个项目，选一个方向

你有两个基础项目可以选择：

**项目 A：Markdown 笔记管理器（CLI）**

你已经实现了：CRUD、搜索、标签、导出。可以考虑的扩展方向：

| 扩展方向 | 难度 | 涉及的技术点 |
|---|---|---|
| 笔记分类统计 | 低 | 数据聚合、遍历计算 |
| 批量导入（从文件夹导入多个 .md） | 中 | 文件系统遍历、glob 模式、正则 |
| 笔记模板（如"每日复盘"模板） | 中 | 模板字符串、日期处理 |
| 简单的 Markdown 预览（终端输出格式化） | 中高 | 字符串处理、正则替换 |
| 导出为 CSV 表格 | 低 | 字符串拼接、文件写入 |
| 导入/导出为 ZIP 压缩包 | 高 | 需要额外了解 archiver 等库 |

**项目 B：待办事项 Web 应用**

你已经实现了：添加、完成、删除、编辑、筛选、持久化。可以考虑的扩展方向：

| 扩展方向 | 难度 | 涉及的技术点 |
|---|---|---|
| 截止日期 + 排序 | 低 | Date 对象、sort 比较函数 |
| 优先级标记（高/中/低） | 低 | 枚举、CSS 颜色、filter |
| 批量操作（全选完成/删除） | 中 | 复选框渲染、批量状态更新 |
| 分类/分组（工作、个人、学习） | 中 | 枚举/联合类型、分组渲染 |
| 拖拽排序 | 高 | 拖拽事件类型、数组重排算法 |
| 主题切换（亮色/暗色） | 中 | CSS 变量、localStorage 保存偏好 |

### 扩展实战一：给待办加截止日期和排序（路线引导）

我们以项目 B 的"截止日期 + 排序"为例，演示完整的思考路径——不是给你完整代码，而是给你"钓鱼的方法"。

**第一步：你希望用户看到什么？**

不要从代码开始想，从最终效果开始想。你希望：
- 添加待办时可以选一个截止日期
- 列表每条待办旁边显示截止日期
- 快到期或已过期的用红色标注
- 可以按截止日期排序（近的在前）

**第二步：你需要改哪些数据结构？**

`Todo` 接口要加一个字段：

```typescript
interface Todo {
    id: number;
    text: string;
    completed: boolean;

    // 新增字段
    dueDate: string | null;  // ISO 格式日期字符串，null 表示没有截止日期
    priority: "high" | "medium" | "low"; // 也可以顺便加上优先级
}
```

为什么 `dueDate` 用 `string | null` 而不是 `Date`？因为 `Date` 对象不能直接存进 JSON（`JSON.stringify` 会把它变成字符串）。用字符串存储，需要时再 `new Date(dueDate)` 转回 Date 对象。

**第三步：HTML 需要加什么？**

```html
<!-- 在输入区域，加一个日期选择器 -->
<input type="date" id="due-date-input" />

<!-- 排序按钮 -->
<button id="sort-btn">按截止日期排序</button>
```

**第四步：代码逻辑怎么改？**

创建待办时，读取日期输入框的值：

```typescript
const dueDateInputEl = document.getElementById("due-date-input") as HTMLInputElement;

function addTodo(): void {
    const text = inputEl.value.trim();
    if (text === "") return;

    // 读取截止日期（为空表示不设截止）
    const dueDate = dueDateInputEl.value || null; // "" 转为 null

    updateState(() => {
        state.todos.push({
            id: state.nextId,
            text: text,
            completed: false,
            dueDate: dueDate, // 新增
            priority: "medium", // 默认中优先级
        });
        state.nextId++;
    });

    inputEl.value = "";
    dueDateInputEl.value = ""; // 清空日期选择
}
```

渲染时，显示日期并标注是否过期：

```typescript
function renderTodoItem(todo: Todo): string {
    // 计算是否过期
    let dueDateDisplay = "";
    if (todo.dueDate) {
        const dueDate = new Date(todo.dueDate);
        const today = new Date();
        today.setHours(0, 0, 0, 0); // 重置时间部分，只比较日期

        const isOverdue = dueDate < today;
        const dateStr = dueDate.toLocaleDateString("zh-CN");
        const className = isOverdue ? "overdue" : "on-time";

        dueDateDisplay = `<span class="due-date ${className}">截止: ${dateStr}</span>`;
    }

    // ... 拼进返回的 HTML 字符串中
}
```

排序功能：

```typescript
function sortByDueDate(): void {
    // 不修改 state.todos 的顺序（那会影响"添加顺序"），而是做一个排序后的拷贝
    // 在 render 中决定用哪个列表
    // 或者，在 state 中加一个 sortBy 字段
}

// 在 render 中
let displayedTodos = getFilteredTodos(state.todos, state.filter);

if (state.sortBy === "dueDate") {
    displayedTodos = [...displayedTodos].sort((a, b) => {
        if (!a.dueDate) return 1;      // 没有截止日期的排后面
        if (!b.dueDate) return -1;
        return a.dueDate.localeCompare(b.dueDate);
    });
}
```

**关键提示**：排序时先用 `[...arr]` 复制数组，避免修改 `state.todos` 的原始顺序。这很重要——你想保持数据本身的创建顺序，排序只是在"展示层面"的调整。

### 扩展实战二：给笔记管理器加分类统计（路线引导）

以项目 A 的"分类统计"为例。

**第一步：你想要统计什么？**

- 每种标签各自有多少条笔记
- 本月创建了多少条笔记
- 平均每条笔记有多少字
- 最近 7 天创建了多少条

**第二步：需要新模块吗？**

不需要。`listTags()` 已经有了最基础的标签统计。你要做的是扩展它，或者新建一个 `stats.ts` 模块。

**第三步：关键代码片段**

```typescript
// src/stats.ts

import { Note } from "./types";
import { loadNotes } from "./storage";

export interface NoteStats {
    /** 总笔记数 */
    totalNotes: number;

    /** 总字符数（所有笔记内容的总长度） */
    totalChars: number;

    /** 平均每条笔记的字符数 */
    avgChars: number;

    /** 标签分布 */
    tagDistribution: { tag: string; count: number }[];

    /** 本月新增笔记数 */
    notesThisMonth: number;

    /** 最近 7 天新增笔记数 */
    notesLast7Days: number;
}

export function calculateStats(): NoteStats {
    const notes = loadNotes();
    const now = new Date();

    // 本月第一天
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    // 7 天前
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    // 计算本月新增
    const notesThisMonth = notes.filter(
        (n) => new Date(n.createdAt) >= startOfMonth
    ).length;

    // 计算 7 天内新增
    const notesLast7Days = notes.filter(
        (n) => new Date(n.createdAt) >= sevenDaysAgo
    ).length;

    // 计算总字符数和平均
    const totalChars = notes.reduce((sum, n) => sum + n.content.length, 0);
    const avgChars = notes.length > 0 ? Math.round(totalChars / notes.length) : 0;

    // 计算标签分布（复用之前的逻辑）
    const tagCounts: { [tag: string]: number } = {};
    for (const note of notes) {
        for (const tag of note.tags) {
            tagCounts[tag] = (tagCounts[tag] || 0) + 1;
        }
    }
    const tagDistribution = Object.entries(tagCounts)
        .map(([tag, count]) => ({ tag, count }))
        .sort((a, b) => b.count - a.count);

    return {
        totalNotes: notes.length,
        totalChars,
        avgChars,
        tagDistribution,
        notesThisMonth,
        notesLast7Days,
    };
}
```

### 扩展实战三：给待办加主题切换（路线引导）

这是一个看起来简单但涉及多处修改的功能。

**第一步：CSS 变量**

先定义两套颜色主题。使用 CSS 自定义属性（变量）：

```css
/* 亮色主题（默认） */
:root,
[data-theme="light"] {
    --bg-color: #f0f2f5;
    --container-bg: white;
    --text-color: #333;
    --text-secondary: #888;
    --border-color: #e0e0e0;
    --item-bg: #fafafa;
    --item-hover-bg: #f0f0f0;
    --input-border: #e0e0e0;
    --input-focus-border: #4a90d9;
}

/* 暗色主题 */
[data-theme="dark"] {
    --bg-color: #1a1a2e;
    --container-bg: #16213e;
    --text-color: #e0e0e0;
    --text-secondary: #aaa;
    --border-color: #2a2a4a;
    --item-bg: #1e1e3a;
    --item-hover-bg: #2a2a4a;
    --input-border: #2a2a4a;
    --input-focus-border: #5a90d9;
}
```

然后把原有 CSS 中的硬编码颜色替换为 `var(--bg-color)` 这样的变量引用。

**第二步：TypeScript 逻辑**

```typescript
// 在 state 中加一个 theme 字段
interface AppState {
    // ... 原有字段
    theme: "light" | "dark";
}

// 初始化时从 localStorage 读取主题偏好
const savedTheme = localStorage.getItem("todo-app-theme") as "light" | "dark" | null;
if (savedTheme === "light" || savedTheme === "dark") {
    state.theme = savedTheme;
}

function toggleTheme(): void {
    // 切换主题
    state.theme = state.theme === "light" ? "dark" : "light";

    // 应用到 HTML 元素（通过 data-theme 属性触发 CSS 变量切换）
    document.documentElement.setAttribute("data-theme", state.theme);

    // 保存偏好到 localStorage
    localStorage.setItem("todo-app-theme", state.theme);
}
```

**第三步：HTML 添加切换按钮**

```html
<button id="theme-toggle-btn">
    <span class="theme-icon-light">🌙</span>
    <span class="theme-icon-dark">☀️</span>
</button>
```

### 三种扩展的共性总结

不管你选哪个方向，开发的步骤都是一样的：

1. **想清楚最终效果**（用户看到什么、能做什么）
2. **改数据模型**（`interface` 加什么字段）
3. **改存储逻辑**（新字段是否需要迁移旧数据？是否需要新的 localStorage key？）
4. **改渲染/输出逻辑**（新字段如何展示在界面上）
5. **改交互逻辑**（用户如何触发新功能）
6. **编译、测试、修 bug**（这步一定会有，是正常的工作节奏）

**生活类比**：这就像装修房子。你不能直接冲进去抡锤子。你得先想清楚"我要把这里改成书房"（最终效果），然后看需要加几面墙（数据模型），墙壁的材质用什么（存储逻辑），墙刷什么颜色（渲染逻辑），门装在哪里（交互逻辑）。顺序对了，事半功倍。

### 老代码需要"迁移"吗？

当你给 `Todo` 加了一个新字段 `dueDate`，之前没有截止日期的旧待办怎么办？

最简单的方案：在 `loadState` 时做一次"数据迁移"：

```typescript
function loadState(): void {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (!stored) return;

    try {
        const parsed = JSON.parse(stored);

        if (parsed && Array.isArray(parsed.todos)) {
            // 给没有 dueDate 的旧数据补上默认值
            state.todos = parsed.todos.map((todo: any) => ({
                ...todo,
                dueDate: todo.dueDate || null,
                priority: todo.priority || "medium",
            }));
            state.nextId = parsed.nextId || 1;
        }
    } catch (error) {
        console.error("数据迁移失败：", error);
    }
}
```

这个技术叫"向前兼容迁移"——新版本代码能兼容旧版本保存的数据。在实际工作中非常重要：你不可能要求所有用户清空数据再用新版本。

## 动手试试

**任务**：选择一个项目，独立实现一个扩展。

**具体步骤**：

1. **选择方向和难度**。从上方表格中选一个，建议从"低"或"中"难度开始。第一目标是跑通，第二目标是好看。

2. **画一张"四层图"**。在纸上或脑子里画出：
   - 类型层：interface 加什么字段？
   - 数据层：存储逻辑要不要变？
   - 业务层：操作函数怎么写？（用 `updateState` 或 `loadNotes/saveNotes` 模式）
   - 渲染层：HTML 加什么？render 函数怎么改？

3. **逐层实现**。按顺序改代码。每改完一层就编译一次，确认 TypeScript 不报错。

4. **运行测试**。打开浏览器或终端，手动操作几遍。故意输入异常数据（空值、超长字符串等），看会不会崩。

5. **调试**。如果出问题，利用你学过的 `console.log` 大法定位。99% 的问题出在一个很小的拼写或逻辑错误上。

**可选的两个起点模板**：
- 如果你想基于待办应用扩展，拷贝 `examples/05-todo-persistence` 到 `examples/06-final-project/todo-extension/`。
- 如果你想基于笔记管理器扩展，拷贝 `examples/03-markdown-notes-advanced` 到 `examples/06-final-project/notes-extension/`。

**验收标准**（你自己确认就算通过）：
- TypeScript 编译无错误（`npx tsc` 不报错）
- 新功能能正常使用（手动操作一遍，功能完整）
- 旧功能不受影响（原有的 CRUD 等操作依然正常）
- 代码有适当的注释（一个月后的自己能看懂）

**当你卡住时**：这是正常的。每个开发者都会卡住。回到本节，重读"三种扩展的共性总结"中的 6 个步骤。回到数据模型想：我到底想让用户看到什么？代码只是把"想要的结果"翻译成 TypeScript 而已。

## 本节小结

你已经学会了 TypeScript 的全套核心概念和两个完整的项目实践，现在独立扩展一个功能，完成从"学员"到"开发者"的蜕变。

## 下一节预告

这是本教程的最后一节。没有下一节了。之后的路是你自己的——想写什么项目，TypeScript 都是你的工具箱。
