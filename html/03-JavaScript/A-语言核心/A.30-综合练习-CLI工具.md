# A.30 综合练习--CLI 工具

## 本节你会学到什么

- 综合运用前 29 节的知识，独立完成一个完整的 Node.js 命令行工具
- 使用 `fs/promises` 模块读写 JSON 文件作为数据存储
- 解析命令行参数（`process.argv`）
- 用 class 封装业务逻辑、用 async/await 处理异步 I/O
- 这是 A 篇的收官练习——检验你 JS 语言核心的掌握程度

## 正文

### 项目：命令行 TODO 列表管理器

我们要写一个命令行工具 `todo`，功能包括：

- **添加任务**：`node todo.js add "学习 JavaScript"`
- **列出任务**：`node todo.js list`（显示所有任务及其状态）
- **完成任务**：`node todo.js done 1`（把编号为 1 的任务标记为完成）
- **删除任务**：`node todo.js delete 2`（删除编号为 2 的任务）
- **清理已完成**：`node todo.js clear`（删除所有已完成的任务）

数据存储在 `tasks.json` 文件中，每条任务包含：
```json
{
    "id": 1,
    "title": "学习 JavaScript",
    "completed": false,
    "createdAt": "2024-01-15T10:00:00.000Z"
}
```

### 项目结构

虽然所有代码可以写在一个文件里，但我们可以做简单的模块拆分：

```
todo.js          —— 主入口，解析命令行参数，调度各模块
todo-storage.js  —— 负责 JSON 文件的读写（数据层）
todo-tasks.js    —— 任务管理逻辑（业务层）
tasks.json       —— 数据文件（运行时自动创建）
```

如果你不想拆分，全部写在一个文件里也可以——重点是用好前面学的知识。

### 用到的知识点

你会在写这个工具的过程中用到：

| 知识点 | 在项目中的运用 |
|--------|---------------|
| class (A.21) | `TaskManager` 类管理任务列表 |
| 对象/数组操作 (A.16-18) | 任务的增删改查、过滤、查找 |
| async/await (A.27) | 异步文件读写 |
| Promise (A.26) | 包装异步操作 |
| 错误处理 (A.24) | try/catch 处理文件读写错误 |
| 数组方法 (前 15 节) | `find`、`filter`、`map`、`push`、`splice` |
| 模板字符串 | 格式化输出 |
| 解构 | 提取对象属性 |
| 模块化 (A.29) | 如果拆分文件 |
| Map (A.23) | 可选，用于按 id 索引任务 |

### 实现思路

**1. 数据存储层（storage）**

```javascript
import { readFile, writeFile } from "fs/promises";
import { existsSync } from "fs";

const DATA_FILE = "tasks.json";

export async function loadTasks() {
    if (!existsSync(DATA_FILE)) return [];
    const raw = await readFile(DATA_FILE, "utf8");
    return JSON.parse(raw);
}

export async function saveTasks(tasks) {
    await writeFile(DATA_FILE, JSON.stringify(tasks, null, 2), "utf8");
}
```

**2. 业务逻辑层（TaskManager）**

```javascript
class TaskManager {
    constructor() {
        this.tasks = [];
    }

    async load() {
        this.tasks = await loadTasks();
        this.tasks.sort((a, b) => a.id - b.id);
    }

    async save() {
        this.tasks.sort((a, b) => a.id - b.id);
        await saveTasks(this.tasks);
    }

    add(title) {
        const newTask = {
            id: this.tasks.length > 0 ? Math.max(...this.tasks.map(t => t.id)) + 1 : 1,
            title,
            completed: false,
            createdAt: new Date().toISOString(),
        };
        this.tasks.push(newTask);
        return newTask;
    }

    list() {
        return this.tasks;
    }

    markDone(id) {
        const task = this.tasks.find(t => t.id === id);
        if (!task) throw new Error(`任务 #${id} 不存在`);
        task.completed = true;
        return task;
    }

    delete(id) {
        const index = this.tasks.findIndex(t => t.id === id);
        if (index === -1) throw new Error(`任务 #${id} 不存在`);
        this.tasks.splice(index, 1);
    }

    clearCompleted() {
        const before = this.tasks.length;
        this.tasks = this.tasks.filter(t => !t.completed);
        return before - this.tasks.length;
    }
}
```

**3. 主入口**

```javascript
const command = process.argv[2];
const argument = process.argv[3];

const manager = new TaskManager();
await manager.load();

switch (command) {
    case "add":
        const task = manager.add(argument);
        console.log(`已添加任务 #${task.id}: ${task.title}`);
        await manager.save();
        break;
    case "list":
        // 格式化打印所有任务
        break;
    case "done":
        manager.markDone(Number(argument));
        console.log(`任务 #${argument} 已标记为完成`);
        await manager.save();
        break;
    case "delete":
        manager.delete(Number(argument));
        console.log(`任务 #${argument} 已删除`);
        await manager.save();
        break;
    case "clear":
        const count = manager.clearCompleted();
        console.log(`已清理 ${count} 个已完成任务`);
        await manager.save();
        break;
    default:
        console.log("用法：node todo.js <add|list|done|delete|clear> [参数]");
}
```

### 格式化输出小技巧

让输出更美观：

```javascript
tasks.forEach(task => {
    const status = task.completed ? "[x]" : "[ ]";
    const line = `${status} #${task.id} ${task.title}`;
    console.log(task.completed
        ? `\x1b[32m${line}\x1b[0m`   // 绿色（已完成）
        : line                          // 默认色
    );
});
```

## 与 C 语言的对比

无直接对应，但概念上可以类比：C 语言写命令行工具通常是：解析 `argv`（和 JS 一样的 `argv` 数组）、用 `fopen/fread/fwrite` 做文件 I/O、用 struct 封装数据、手动管理内存。JS 版本的核心优势在于：JSON 的读写天然匹配 JS 对象（不需要解析/序列化库）；垃圾回收让内存管理消失；async/await 让文件 I/O 不阻塞。但思维过程是一样的——解析命令、操作数据、持久化存储。

## 动手试试

1. 完成 `todo.js` 的所有功能
2. 添加一个新命令 `search <关键词>`——列出标题包含关键词的任务
3. 添加 `--json` 参数支持 `list` 以 JSON 格式输出

## 本节小结

- 综合运用 class、数组操作、async/await、错误处理、模板字符串等知识
- `fs/promises` 提供异步文件读写 API，和 async/await 天然搭配
- `process.argv` 获取命令行参数，`argv[0]` 是 node，`argv[1]` 是脚本路径，从 `argv[2]` 开始是实际参数
- `JSON.stringify(obj, null, 2)` 让 JSON 输出带缩进，方便阅读
- 这个工具是可以扩展的起点——你可以继续加入优先级、分类、截止日期等功能

## 课程总结

A 篇（语言核心）到此结束。30 节课程带你从变量声明走到了 CLI 工具开发。回顾一下你走过的路：

- 基础语法（变量、类型、运算符、流程控制）
- 函数（声明、参数、闭包、箭头函数）
- 对象与数组（字面量、操作、解构、展开）
- 面向对象（构造函数、class、原型链、this）
- 数据结构（Set、Map）
- 错误处理（try/catch、自定义 Error）
- 异步编程（回调、Promise、async/await、事件循环）
- 工程化（模块化、CLI 工具）

这些是 JavaScript 语言的核心。下一站是 B 篇——浏览器中的 JavaScript，你将学会操作 DOM、处理事件、与服务器通信，让你写的代码在网页中真正"活"起来。
