/**
 * main.ts - 待办事项 Web 应用（增强版）
 *
 * 相比上一节的新增功能：
 * 1. 集中式状态管理（state 对象统一管理所有数据）
 * 2. localStorage 持久化（刷新页面数据不丢失）
 * 3. 按状态筛选（全部 / 未完成 / 已完成）
 * 4. 清空已完成的一键操作
 */

// ============================================================
// 类型定义
// ============================================================

/** 一条待办事项 */
interface Todo {
    id: number;
    text: string;
    completed: boolean;
}

/** 筛选类型 —— 联合类型确保只能是这三个值 */
type FilterType = "all" | "active" | "completed";

/** 应用的全部状态，集中在一个对象中管理 */
interface AppState {
    todos: Todo[];
    nextId: number;
    filter: FilterType;
}

// ============================================================
// 全局状态 —— 整个应用只有一个 state 变量
// ============================================================

const state: AppState = {
    todos: [],
    nextId: 1,
    filter: "all", // 默认显示全部
};

// ============================================================
// localStorage 键名
// ============================================================

const STORAGE_KEY = "my-todo-app-data";

// ============================================================
// DOM 元素引用
// ============================================================

const inputEl = document.getElementById("todo-input") as HTMLInputElement;
const addBtnEl = document.getElementById("add-btn") as HTMLButtonElement;
const listEl = document.getElementById("todo-list") as HTMLUListElement;
const statsEl = document.getElementById("stats") as HTMLDivElement;
const filterBtns = document.querySelectorAll(".filter-btn");
const clearCompletedBtnEl = document.getElementById(
    "clear-completed-btn"
) as HTMLButtonElement;

// 防御性检查
if (
    !inputEl ||
    !addBtnEl ||
    !listEl ||
    !statsEl ||
    !clearCompletedBtnEl
) {
    throw new Error(
        "页面缺少必要的 DOM 元素，请检查 index.html"
    );
}

// ============================================================
// localStorage 读写
// ============================================================

/**
 * 从 localStorage 加载状态
 * 如果数据存在且格式正确，就恢复到 state 中
 * 如果数据不存在或损坏，保持默认值
 */
function loadState(): void {
    const stored = localStorage.getItem(STORAGE_KEY);

    if (!stored) {
        return; // 第一次打开，用默认值
    }

    try {
        const parsed = JSON.parse(stored);

        // 安全检查：确保数据结构完整
        if (
            parsed &&
            Array.isArray(parsed.todos) &&
            typeof parsed.nextId === "number"
        ) {
            state.todos = parsed.todos;
            state.nextId = parsed.nextId;
            console.log(
                `从 localStorage 加载了 ${state.todos.length} 条待办`
            );
        }
    } catch (error) {
        console.error(
            "localStorage 数据损坏，已重置：",
            error
        );
        // 不恢复任何数据，使用默认值
    }
}

/**
 * 把当前状态保存到 localStorage
 * 只保存需要持久化的部分（todos 和 nextId）
 * filter 是 UI 状态不保存 —— 每次打开都默认显示"全部"
 */
function saveState(): void {
    const toSave = {
        todos: state.todos,
        nextId: state.nextId,
    };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(toSave));
}

// ============================================================
// 状态更新包装函数
// ============================================================

/**
 * 修改状态 -> 保存 -> 渲染 的三合一操作
 * 所有修改 state 的操作都通过这个函数执行
 * 确保"改了数据就一定会保存和刷新界面"
 *
 * @param updater - 一个修改 state 的回调函数
 */
function updateState(updater: () => void): void {
    updater(); // 第一步：执行修改
    saveState(); // 第二步：持久化
    render(); // 第三步：刷新界面
}

// ============================================================
// 数据操作函数
// ============================================================

function addTodo(): void {
    const text = inputEl.value.trim();

    if (text === "") {
        inputEl.placeholder = "输入不能为空，请输入点什么吧！";
        inputEl.focus();
        return;
    }

    updateState(() => {
        state.todos.push({
            id: state.nextId,
            text: text,
            completed: false,
        });
        state.nextId++;
    });

    inputEl.value = "";
    inputEl.placeholder = "输入新的待办事项...";
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
        const index = state.todos.findIndex(
            (t) => t.id === id
        );
        if (index !== -1) {
            state.todos.splice(index, 1);
        }
    });
}

function editTodo(id: number, newText: string): void {
    if (newText.trim() === "") return;

    updateState(() => {
        const todo = state.todos.find((t) => t.id === id);
        if (todo) {
            todo.text = newText.trim();
        }
    });
}

/**
 * 清空所有已完成的待办
 */
function clearCompleted(): void {
    // 统计有多少条会被清除
    const completedCount = state.todos.filter(
        (t) => t.completed
    ).length;

    if (completedCount === 0) {
        console.log("没有已完成的待办需要清空。");
        return;
    }

    // 确认操作
    const confirmed = confirm(
        `确定要清空 ${completedCount} 条已完成的待办吗？`
    );

    if (!confirmed) return;

    updateState(() => {
        // filter 返回新数组，替换原有的 todos
        state.todos = state.todos.filter((t) => !t.completed);
    });

    console.log(`已清空 ${completedCount} 条已完成的待办。`);
}

/**
 * 切换筛选条件
 */
function setFilter(filter: FilterType): void {
    state.filter = filter;
    // 注意：筛选不保存到 localStorage（只是临时 UI 状态）
    render();
}

// ============================================================
// 渲染函数
// ============================================================

function escapeHtml(text: string): string {
    const map: Record<string, string> = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#039;",
    };
    return text.replace(
        /[&<>"']/g,
        (char) => map[char]
    );
}

function render(): void {
    // ----- 1. 根据 filter 筛选要显示的待办 -----
    const displayedTodos = state.todos.filter((todo) => {
        switch (state.filter) {
            case "active":
                return !todo.completed;
            case "completed":
                return todo.completed;
            case "all":
            default:
                return true;
        }
    });

    // ----- 2. 渲染列表 -----
    if (displayedTodos.length === 0) {
        // 根据当前筛选条件显示不同的空状态提示
        let emptyMessage = "还没有待办事项，在上面输入一条吧！";
        if (state.filter === "active" && state.todos.length > 0) {
            emptyMessage = "所有待办都已完成，太棒了！";
        } else if (
            state.filter === "completed" &&
            state.todos.length > 0
        ) {
            emptyMessage =
                "还没有已完成的待办，加油完成几个吧！";
        }

        listEl.innerHTML = `<li class="empty-hint">${emptyMessage}</li>`;
    } else {
        listEl.innerHTML = displayedTodos
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
            .join("");
    }

    // ----- 3. 更新统计信息 -----
    const totalCount = state.todos.length;
    const completedCount = state.todos.filter(
        (t) => t.completed
    ).length;
    const activeCount = totalCount - completedCount;

    let filterLabel = "";
    switch (state.filter) {
        case "all":
            filterLabel = `共 ${totalCount} 条待办，其中 ${completedCount} 条已完成`;
            break;
        case "active":
            filterLabel = `${activeCount} 条未完成的待办`;
            break;
        case "completed":
            filterLabel = `${completedCount} 条已完成的待办`;
            break;
    }

    statsEl.textContent = filterLabel;
}

// ============================================================
// 事件处理
// ============================================================

function setupEventListeners(): void {
    // 添加按钮
    addBtnEl.addEventListener("click", addTodo);

    // 输入框按回车
    inputEl.addEventListener(
        "keydown",
        (e: KeyboardEvent) => {
            if (e.key === "Enter") {
                addTodo();
            }
        }
    );

    // 事件委托：列表中的按钮点击
    listEl.addEventListener("click", (e: MouseEvent) => {
        const target = e.target as HTMLElement;
        const button = target.closest(
            "button"
        ) as HTMLButtonElement | null;
        if (!button) return;

        const idStr = button.dataset.id;
        if (!idStr) return;
        const id = parseInt(idStr, 10);

        if (button.classList.contains("toggle-btn")) {
            toggleTodo(id);
        } else if (
            button.classList.contains("delete-btn")
        ) {
            deleteTodo(id);
        } else if (
            button.classList.contains("edit-btn")
        ) {
            const todo = state.todos.find(
                (t) => t.id === id
            );
            if (todo) {
                const newText = prompt(
                    "请输入新的待办文字：",
                    todo.text
                );
                if (newText !== null) {
                    editTodo(id, newText);
                }
            }
        }
    });

    // 筛选按钮
    filterBtns.forEach((btn) => {
        btn.addEventListener(
            "click",
            (e: MouseEvent) => {
                const target = e.target as HTMLElement;
                const filter = target.dataset
                    .filter as FilterType;
                if (!filter) return;

                setFilter(filter);

                // 更新按钮高亮样式
                filterBtns.forEach((b) =>
                    b.classList.remove("active")
                );
                target.classList.add("active");
            }
        );
    });

    // 清空已完成按钮
    clearCompletedBtnEl.addEventListener(
        "click",
        clearCompleted
    );
}

// ============================================================
// 应用初始化
// ============================================================

function init(): void {
    loadState(); // 先加载持久化数据
    setupEventListeners(); // 注册事件
    render(); // 初始渲染
    inputEl.focus(); // 自动聚焦

    console.log(
        `待办事项应用已就绪！共 ${state.todos.length} 条待办。`
    );
}

// 启动！
init();
