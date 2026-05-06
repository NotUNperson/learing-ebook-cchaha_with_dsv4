# 05 - 项目二扩展：localStorage 持久化与状态筛选

## 本节你会学到什么

- 使用浏览器的 `localStorage` API 将数据保存到用户的硬盘上
- 理解"序列化"和"反序列化"在 Web 应用中的角色
- 掌握集中式状态管理模式：所有数据在一个 `state` 对象中
- 实现列表筛选功能（全部/未完成/已完成），体会 TypeScript 联合类型的实际应用
- 学会优雅地处理 JSON 解析错误（`try-catch`）

## 正文

### 页面一刷新，辛苦全白费

上一节我们写的待办应用有个致命缺陷：你辛辛苦苦加了 10 条待办，一刷新浏览器——全没了。这是因为 `todos` 数组只存在浏览器的内存里，页面关闭、刷新后内存就会被清空。

我们需要一种方式把数据存到用户的硬盘上。浏览器提供了 `localStorage`——一个键值对存储，跟 JSON 文件类似，但完全在浏览器内操作，不需要文件系统权限。

**生活类比**：`todos` 数组是你的"脑海中的购物清单"——你一边逛超市一边记住要买什么，但一觉醒来（刷新页面）就全忘了。`localStorage` 是一张"写在纸条上的购物清单"——你走进超市看一眼纸条就知道要买什么，逛完回家纸条还在，明天出门还能接着用。

### 一个重要的概念：序列化

`localStorage` 只能存字符串。你不能说 `localStorage.setItem("todos", todos)`——那存进去的是 `"[object Object]"`，毫无意义。

我们需要两步转换：
- **存的时候**：对象 -> JSON 字符串（`JSON.stringify`），这叫**序列化**
- **取的时候**：JSON 字符串 -> 对象（`JSON.parse`），这叫**反序列化**

就像你搬家时把家具拆成零件（序列化）装进箱子运到新家，再组装起来（反序列化）。JSON 就是拆装说明书。

### 第一步：重构为集中式状态管理

在上一节，`todos` 和 `nextId` 是分散的全局变量。现在我们把它们统一放进一个 `state` 对象里：

```typescript
/**
 * 应用的所有状态集中管理
 * 思路：整个应用只有一个 state 对象
 * render 函数只读取 state 来渲染页面
 * 其他函数修改 state 后调用 render
 */
interface AppState {
    todos: Todo[];
    nextId: number;
    /** 当前筛选条件 */
    filter: "all" | "active" | "completed";
}

const state: AppState = {
    todos: [],
    nextId: 1,
    filter: "all",
};
```

为什么要把 `filter` 也放进 state？因为"当前筛选条件"也是一种状态——用户选择"只看未完成"后，这个选择应该在整个应用生命周期内持续有效，直到用户切换到别的筛选。这和 `todos` 一样是"应用记住了什么"，而不是"转瞬即逝的一次操作"。

**生活类比**：`state` 对象就像你的"个人档案夹"。里面有你的待办清单（todos）、编号器（nextId）、还有一张贴纸写着"我只想看未完成的"（filter）。任何时候你打开这个夹子，都能知道所有信息。

### 第二步：存取 localStorage

```typescript
/**
 * 存储键名
 * 用一个常量避免到处写字符串 "my-todo-app-data"
 */
const STORAGE_KEY = "my-todo-app-data";

/**
 * 从 localStorage 加载状态
 * 如果 localStorage 里有数据就用它初始化 state
 * 如果没有（第一次打开）就保持 state 的默认值
 */
function loadState(): void {
    // 读取存储的字符串
    const stored = localStorage.getItem(STORAGE_KEY);

    // 如果没有任何存储数据（第一次打开），用默认值
    if (!stored) {
        return;
    }

    try {
        const parsed = JSON.parse(stored);

        // 安全检查：确认解析出的数据有正确的结构
        if (parsed && Array.isArray(parsed.todos) && typeof parsed.nextId === "number") {
            state.todos = parsed.todos;
            state.nextId = parsed.nextId;
        }
        // 如果结构不对，就忽略（当第一次打开处理）
    } catch (error) {
        // JSON.parse 可能因为数据损坏而抛出异常
        // 损坏的数据直接忽略，用默认值重来
        console.error("localStorage 数据损坏，已使用默认值重新开始：", error);
    }
}

/**
 * 把当前状态保存到 localStorage
 * 每次修改 state 后都调用一次
 */
function saveState(): void {
    // 只保存需要持久化的部分（todos 和 nextId）
    const toSave = {
        todos: state.todos,
        nextId: state.nextId,
    };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(toSave));
}
```

几个设计要点：

**1. 为什么 `loadState` 要检查数据结构？** 你永远不知道 `localStorage` 里存了什么。可能用户之前用过另一个版本的应用，数据结构不一样。可能用户手动改了 localStorage。TypeScript 编译时能帮你检查代码里的类型，但运行时来自外部的数据（文件、网络、localStorage）必须自己验证。

**2. 为什么用 `try-catch`？** `JSON.parse` 遇到格式不正确的字符串会抛出异常。如果不捕获，整个应用就崩了。`try-catch` 像是在河上过桥——你知道桥可能不结实（数据可能损坏），所以在桥下放了安全网。

**3. 为什么 `saveState` 只保存 `todos` 和 `nextId` 而不保存 `filter`？** `filter` 是 UI 状态，不是业务数据。用户每次重新打开应用，默认展示"全部"更合理（否则如果上次选了"已完成"但列表是空的，用户会觉得应用坏了）。这个选择不是绝对的——你可以根据自己的喜好决定是否保存 filter 状态。

### 第三步：修改数据操作函数

原来的 `addTodo`、`toggleTodo`、`deleteTodo` 都需要加一行 `saveState()`。我们也可以用一个更优雅的方式：一个包装函数。

```typescript
/**
 * 修改 state 后自动保存和渲染
 * 这是一个"副作用管理器"——所有修改 state 的操作都走这里
 */
function updateState(updater: () => void): void {
    updater();     // 执行具体的修改逻辑
    saveState();   // 持久化到 localStorage
    render();      // 刷新页面
}
```

现在所有操作函数都可以写成这样：

```typescript
function addTodo(): void {
    const text = inputEl.value.trim();
    if (text === "") return;

    updateState(() => {
        state.todos.push({
            id: state.nextId,
            text: text,
            completed: false,
        });
        state.nextId++;
    });

    inputEl.value = "";
}

function toggleTodo(id: number): void {
    updateState(() => {
        const todo = state.todos.find((t) => t.id === id);
        if (todo) {
            todo.completed = !todo.completed;
        }
    });
}

function deleteTodo(id: number): void {
    updateState(() => {
        const index = state.todos.findIndex((t) => t.id === id);
        if (index !== -1) {
            state.todos.splice(index, 1);
        }
    });
}
```

`updateState` 的设计叫"高阶函数包裹"。它让你写出"我只关心改什么数据，保存和渲染是自动的"这样的代码。就像你在网上购物——你只管选商品加购物车（updater 回调），支付和物流（saveState + render）是平台自动处理的。

### 第四步：实现筛选功能

筛选的逻辑其实很简单：根据 `state.filter` 的值，决定 `render` 函数给用户展示哪些待办。

```typescript
/**
 * 筛选类型：用联合类型让 TypeScript 确保 filter 值只能是这三个之一
 */
type FilterType = "all" | "active" | "completed";

/**
 * 切换筛选条件
 */
function setFilter(filter: FilterType): void {
    state.filter = filter;
    render(); // 只重新渲染，不需要保存（filter 是非持久化的 UI 状态）
}
```

然后在 `render` 函数中根据 filter 决定展示哪些：

```typescript
function render(): void {
    // 根据 filter 获取要显示的待办列表
    const displayedTodos = state.todos.filter((todo) => {
        switch (state.filter) {
            case "active":
                return !todo.completed;      // 只显示未完成的
            case "completed":
                return todo.completed;       // 只显示已完成的
            case "all":
            default:
                return true;                 // 显示全部
        }
    });

    // ... 后续渲染用 displayedTodos 代替原来的 state.todos
}
```

注意，筛选不改变原始 `state.todos` 数组，而是生成一个"视图子集"。这就像你有一本通讯录（完整数据），但你可以选择只显示姓张的人（筛选视图）。原始数据不受影响。

### 第五步：UI 中的筛选按钮

在 HTML 中添加筛选按钮组：

```html
<!-- 筛选按钮组 -->
<div class="filter-area">
    <button class="filter-btn active" data-filter="all">全部</button>
    <button class="filter-btn" data-filter="active">未完成</button>
    <button class="filter-btn" data-filter="completed">已完成</button>
</div>
```

在 TypeScript 中一并获取和绑定：

```typescript
// 获取所有筛选按钮（querySelectorAll 返回 NodeList，需要用 Array.from 转换）
const filterBtns = document.querySelectorAll(".filter-btn");

function setupEventListeners(): void {
    // ... 原有的添加、事件委托等代码 ...

    // 筛选按钮的点击事件
    filterBtns.forEach((btn) => {
        btn.addEventListener("click", (e: MouseEvent) => {
            const target = e.target as HTMLElement;
            const filter = target.dataset.filter as FilterType;

            if (!filter) return;

            // 更新筛选状态
            setFilter(filter);

            // 更新按钮的高亮样式：移除所有 "active"，加到当前按钮上
            filterBtns.forEach((b) => b.classList.remove("active"));
            target.classList.add("active");
        });
    });
}
```

### 完整的改造后数据流

```
用户打开页面
  -> loadState() 从 localStorage 读取数据填充 state
  -> render() 用 state.todos 生成 HTML
  -> 用户看到之前的待办列表

用户点击"添加"
  -> updateState(updater) 执行修改
  -> updater() 修改 state.todos
  -> saveState() 保存到 localStorage
  -> render() 刷新页面

用户点击"未完成"筛选
  -> setFilter("active") 修改 state.filter
  -> render() 重新读取 state.filter + state.todos
  -> render() 只生成未完成待办的 HTML
  -> 用户看到筛选后的列表（但 localStorage 中的完整数据不变）

用户刷新页面
  -> loadState() 读取 localStorage（包含完整的待办数据）
  -> state.filter 重置为 "all"（不持久化）
  -> render() 显示全部待办
```

### 技术对比：localStorage vs 文件系统

| 维度 | localStorage（浏览器） | fs 模块（Node.js） |
|---|---|---|
| 数据在哪 | 浏览器的内部数据库 | 硬盘上的文件 |
| API 风格 | `getItem` / `setItem`（字符串） | `readFileSync` / `writeFileSync`（Buffer） |
| 是否自动同步 | 是（同步 API） | 可选择同步或异步 |
| 大小限制 | 通常 5-10 MB | 取决于硬盘空间 |
| 可以共用吗 | 不同域名隔离 | 所有程序共享 |
| 需要安装依赖吗 | 不需要 | 需要 @types/node |

**生活类比**：localStorage 是"你手机上的备忘录 App 里的数据"——只有这个 App 能访问，手机丢了数据就没了。文件系统是"你桌面上放的记事本"——任何路过的人都能翻看，但你可以复印、邮寄、备份到 U 盘。

### 常见问题

**浏览器隐私模式下 localStorage 会怎样？** 大多数浏览器的隐私模式（无痕模式）中，localStorage 仍然可用，但在关闭窗口后会被清空。这不是 bug，是隐私模式的预期行为。

**localStorage 满了怎么办？** `setItem` 满了会抛出 `QuotaExceededError`。对于待办应用来说永远不会满（5MB 能存几十万条待办），但如果你存图片就会出现。生产环境中需要 `try-catch`。

**用户清除了浏览器数据怎么办？** 数据会丢失。对于真正的产品，你需要一个云端同步方案（把数据存到服务器），但那超出本教程范围了。

## 动手试试

**任务**：添加一个"清空所有已完成"按钮。

**具体步骤**：
1. 在 HTML 的筛选按钮区域旁加一个"清空已完成"按钮。
2. 在 `updateState` 的回调中，用 `filter` 方法保留所有 `completed !== true` 的待办，替换 `state.todos`。
3. 添加事件监听器并绑定该功能。
4. 测试：添加几条待办，完成其中几条，点击"清空已完成"——已完成的消失，未完成的保留。

**提示**：
```typescript
function clearCompleted(): void {
    updateState(() => {
        state.todos = state.todos.filter((t) => !t.completed);
    });
}
```

三行代码就完成了。这是因为 `updateState` 帮你处理了保存和渲染。

**进阶挑战**：清空前弹出一个 `confirm("确定要清空所有已完成的待办吗？")` 确认框。`confirm` 返回 `boolean`——用户点"确定"返回 `true`，点"取消"返回 `false`。

## 本节小结

localStorage 让数据从"关网页就忘"变成"关电脑还记"，集中式 state 管理让代码更清晰，筛选功能让你的应用从玩具进化到工具。

## 下一节预告

毕业练习——从这两个项目中挑一个，自主扩展一个新功能。我们会给你思路引导和关键代码片段，但不再提供完整源码。这是你从"跟着做"到"独立做"的最后一公里。
