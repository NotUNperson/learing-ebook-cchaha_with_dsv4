/**
 * main.ts - 简易待办事项 Web 应用
 *
 * 核心概念：状态驱动视图
 * 流程：用户操作 -> 修改数据(todos数组) -> 调用render() -> 页面自动更新
 *
 * 每当你修改了 todos 数组，必须调用 render() 才能看到变化。
 * 这就像你改了食谱，需要重新烹饪才能吃到新菜。
 */

// ============================================================
// 类型定义
// ============================================================

/** 一条待办事项 */
interface Todo {
    /** 唯一标识，自增数字 */
    id: number;
    /** 待办事项的文字内容 */
    text: string;
    /** 是否已完成 */
    completed: boolean;
}

// ============================================================
// 全局状态 —— 整个应用的数据核心
// ============================================================

/** 所有待办事项的数组 */
const todos: Todo[] = [];

/** 下一个可用的 ID（每创建一条就 +1） */
let nextId: number = 1;

// ============================================================
// DOM 元素引用
// ============================================================

const inputEl = document.getElementById("todo-input") as HTMLInputElement;
const addBtnEl = document.getElementById("add-btn") as HTMLButtonElement;
const listEl = document.getElementById("todo-list") as HTMLUListElement;
const statsEl = document.getElementById("stats") as HTMLDivElement;

// 防御性检查：如果 HTML 里缺少元素，马上报错
if (!inputEl || !addBtnEl || !listEl || !statsEl) {
    throw new Error(
        "页面缺少必要的 DOM 元素（todo-input, add-btn, todo-list, stats），请检查 index.html"
    );
}

// ============================================================
// 数据操作函数（修改 todos 数组）
// ============================================================

/**
 * 添加一条新的待办事项
 */
function addTodo(): void {
    const text = inputEl.value.trim();

    // 空输入检查
    if (text === "") {
        inputEl.placeholder = "输入不能为空，请输入点什么吧！";
        inputEl.focus();
        return;
    }

    // 创建 Todo 对象
    const newTodo: Todo = {
        id: nextId,
        text: text,
        completed: false,
    };

    todos.push(newTodo);
    nextId++;

    // 清空输入框
    inputEl.value = "";
    inputEl.placeholder = "输入新的待办事项...";

    // 更新视图
    render();
}

/**
 * 切换一条待办的完成状态
 * @param id - 待办事项的 ID
 */
function toggleTodo(id: number): void {
    const todo = todos.find((t) => t.id === id);
    if (todo) {
        todo.completed = !todo.completed;
        render();
    }
}

/**
 * 删除一条待办事项
 * @param id - 要删除的待办 ID
 */
function deleteTodo(id: number): void {
    const index = todos.findIndex((t) => t.id === id);
    if (index !== -1) {
        todos.splice(index, 1);
        render();
    }
}

/**
 * 编辑一条待办事项的文字
 * @param id - 待办 ID
 * @param newText - 新的文字内容
 */
function editTodo(id: number, newText: string): void {
    const todo = todos.find((t) => t.id === id);
    if (todo && newText.trim() !== "") {
        todo.text = newText.trim();
        render();
    }
}

// ============================================================
// 渲染函数 —— 把数据变成 HTML
// ============================================================

/**
 * 转义 HTML 特殊字符，防止 XSS 攻击
 * 例如 "<script>" 会被转义成 "&lt;script&gt;"，显示为纯文本而不是执行
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

/**
 * 根据当前 todos 数组重新渲染整个页面
 * 这是"状态驱动视图"的体现 —— 数据变了，调用此函数，页面自动更新
 */
function render(): void {
    // ----- 1. 渲染待办列表 -----
    if (todos.length === 0) {
        // 空列表提示
        listEl.innerHTML = `
            <li class="empty-hint">
                还没有待办事项，在上面输入一条吧！
            </li>`;
    } else {
        // 遍历 todos，每条生成一行 HTML
        listEl.innerHTML = todos
            .map((todo) => {
                const completedClass = todo.completed
                    ? "completed"
                    : "";
                const toggleLabel = todo.completed
                    ? "撤销"
                    : "完成";

                return `
                    <li class="todo-item ${completedClass}" data-id="${todo.id}">
                        <span class="todo-text">${escapeHtml(
                            todo.text
                        )}</span>
                        <button class="toggle-btn" data-id="${todo.id}">
                            ${toggleLabel}
                        </button>
                        <button class="edit-btn" data-id="${todo.id}">
                            编辑
                        </button>
                        <button class="delete-btn" data-id="${todo.id}">
                            删除
                        </button>
                    </li>`;
            })
            .join(""); // 把数组拼接成单个字符串
    }

    // ----- 2. 渲染底部统计 -----
    const completedCount = todos.filter((t) => t.completed).length;
    statsEl.textContent = `共 ${todos.length} 条待办，其中 ${completedCount} 条已完成`;
}

// ============================================================
// 事件处理 —— 连接用户操作和数据处理
// ============================================================

/**
 * 注册所有事件监听器
 * 只调用一次，不随 render 反复绑定
 */
function setupEventListeners(): void {
    // 添加按钮 —— 点击添加
    addBtnEl.addEventListener("click", addTodo);

    // 输入框 —— 按回车也能添加
    inputEl.addEventListener("keydown", (e: KeyboardEvent) => {
        if (e.key === "Enter") {
            addTodo();
        }
    });

    // 事件委托：在 ul 上统一监听所有按钮的点击
    // 好处：不需要给每个按钮单独绑定事件，也不用在 render 后重新绑定
    listEl.addEventListener("click", (e: MouseEvent) => {
        const target = e.target as HTMLElement;

        // closest() 向上查找最近的 <button> 元素
        // 即使用户点到了按钮内部的文字，也能正确找到按钮
        const button = target.closest("button") as HTMLButtonElement | null;
        if (!button) return;

        // 从 data-id 属性中读取待办的 ID
        const idStr = button.dataset.id;
        if (!idStr) return;
        const id = parseInt(idStr, 10);

        // 根据按钮的 class 判断用户想执行什么操作
        if (button.classList.contains("toggle-btn")) {
            // 切换完成状态
            toggleTodo(id);
        } else if (button.classList.contains("delete-btn")) {
            // 删除待办
            deleteTodo(id);
        } else if (button.classList.contains("edit-btn")) {
            // 编辑待办
            const todo = todos.find((t) => t.id === id);
            if (todo) {
                const newText = prompt(
                    "请输入新的待办文字：",
                    todo.text
                );
                // prompt 返回 null 表示用户点了取消
                if (newText !== null) {
                    editTodo(id, newText);
                }
            }
        }
    });
}

// ============================================================
// 应用初始化
// ============================================================
function init(): void {
    setupEventListeners();
    render(); // 初始渲染（显示空列表提示和统计）
    inputEl.focus(); // 自动聚焦到输入框，方便用户直接打字
}

// 启动！
init();

console.log("待办事项应用已就绪！");
console.log("提示：添加一条待办试试，然后尝试完成、编辑、删除操作。");
