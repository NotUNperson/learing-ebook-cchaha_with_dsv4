# 02 - 项目一：Markdown 笔记管理器（CLI 版）

## 本节你会学到什么

- 用 TypeScript 的 `interface` 为项目定义清晰的数据模型
- 使用 Node.js 的 `fs` 模块同步读写 JSON 文件来持久化数据
- 设计一个简单的命令行交互流程（用 `readline` 模块）
- 体会"类型先行"的项目开发方式：先定义数据结构，再写业务逻辑
- 把之前学的泛型、联合类型、可选属性用到真实项目中

## 正文

### 从零开始想清楚一个项目

很多新手写代码的习惯是：打开编辑器，直接开始写。写到一半发现数据结构不对，推倒重来。TypeScript 给了我们一个更好的习惯：**先定义类型，再写代码**。

想象你要做一个笔记管理器。你会在脑海中先想："一条笔记有什么属性？" 答案很简单：
- 有一个标题
- 有一段内容（Markdown 格式）
- 有一个创建时间
- 可能会被修改

这四条信息，天然就是 `interface`。它不是写代码，它是在做"项目建模"。就像盖房子之前先画图纸，TypeScript 的 interface 就是你的图纸。

**生活类比**：你去餐馆点菜。服务员给你一张菜单（interface），上面写着"菜名、价格、辣度、份量"。厨师拿到你的订单后，知道"辣度必须是微辣/中辣/特辣之一"，不会出现"要放三勺辣椒"这种模糊表述。interface 就是这张菜单——它规定了数据长什么样，写代码的你和用你代码的人都有了共识。

### 项目结构

```
examples/02-markdown-notes/
├── src/
│   ├── types.ts          # 所有类型定义（Note 接口，搜索结果等）
│   ├── storage.ts        # 文件读写（保存/加载 JSON）
│   ├── commands.ts       # 业务逻辑（创建、查看、删除笔记）
│   └── index.ts          # CLI 入口（显示菜单，处理用户输入）
├── data/                 # 笔记数据存储目录（会自动创建）
├── tsconfig.json
└── package.json
```

### 第一步：定义数据模型（types.ts）

这是整个项目最重要的文件。我们在这里想清楚"一条笔记到底是什么"。

```typescript
// src/types.ts

/**
 * 一条笔记的核心数据结构
 * 用 interface 定义，确保项目中所有地方使用的是同一种笔记
 */
export interface Note {
    /** 唯一标识，用时间戳 + 随机数生成，确保不重复 */
    id: string;

    /** 笔记标题 */
    title: string;

    /** 笔记正文，支持 Markdown 语法 */
    content: string;

    /** 创建时间，ISO 8601 格式字符串，比如 "2026-05-06T10:30:00.000Z" */
    createdAt: string;

    /** 最后修改时间，首次创建时等于 createdAt */
    updatedAt: string;
}

/**
 * 创建新笔记时需要的参数
 * 只需要标题和内容，id 和时间由程序自动生成
 * 注意：这里用 Omit 从 Note 里排除掉自动生成的字段
 */
export type CreateNoteInput = Pick<Note, "title" | "content">;
```

这里有几个设计决策值得解释：

**为什么 `id` 是字符串而不是数字？** 因为我们要生成全局唯一 ID。用时间戳（如 `Date.now()`）加随机数拼成字符串是最简单的 UUID 替代方案。如果后续项目升级到多用户，数字 ID 容易重复，字符串 ID 更安全。

**为什么用 `Pick<Note, "title" | "content">` 而不是手动再写一个 interface？** 因为这叫"数据有单一来源"。如果将来 `Note` 的 `title` 改名或者加了校验逻辑，`CreateNoteInput` 会自动跟着变，不会出现两个地方定义不一样。这就像你的手机里面只有一个"妈妈"的联系人条目——不管在电话 app 还是短信 app 里点开，都是同一个人。

### 第二步：文件读写层（storage.ts）

数据存在内存里，程序关了就没了。我们需要把数据写到硬盘上。最简单的方式是用 JSON 文件：把所有笔记存成一个数组，用 `JSON.stringify` 序列化后写入 `.json` 文件。

```typescript
// src/storage.ts

import * as fs from "fs";
import * as path from "path";
import { Note } from "./types";

// 数据文件路径：项目根目录下的 data/notes.json
const DATA_DIR = path.join(__dirname, "..", "data");
const DATA_FILE = path.join(DATA_DIR, "notes.json");

/**
 * 确保 data 目录存在
 * 如果目录不存在就创建它（递归创建，类似 mkdir -p）
 */
function ensureDataDir(): void {
    if (!fs.existsSync(DATA_DIR)) {
        fs.mkdirSync(DATA_DIR, { recursive: true });
    }
}

/**
 * 从 JSON 文件读取所有笔记
 * 如果文件不存在（第一次运行），返回空数组
 */
export function loadNotes(): Note[] {
    ensureDataDir();

    // 如果文件还不存在，返回空数组
    if (!fs.existsSync(DATA_FILE)) {
        return [];
    }

    // 读取文件内容（Buffer 转 string）
    const raw = fs.readFileSync(DATA_FILE, "utf-8");

    // 空文件也返回空数组
    if (raw.trim() === "") {
        return [];
    }

    // JSON.parse 返回 any，我们断言为 Note[] 数组
    // 信任我们保存的数据格式正确
    const notes: Note[] = JSON.parse(raw);
    return notes;
}

/**
 * 把笔记数组写入 JSON 文件
 * 用 2 个空格缩进，方便人眼查看
 */
export function saveNotes(notes: Note[]): void {
    ensureDataDir();
    const json = JSON.stringify(notes, null, 2);
    fs.writeFileSync(DATA_FILE, json, "utf-8");
}
```

为什么用同步版本的 `fs`（`readFileSync`、`writeFileSync`）而不是异步版本？因为这是一个简单的 CLI 工具——用户输入一个命令，程序执行，输出结果。同步代码逻辑清晰，不需要处理 Promise 链，对零基础读者更友好。等你熟练之后，完全可以把同步换成异步（`await fs.promises.readFile`），注意处理错误即可。

### 第三步：业务逻辑（commands.ts）

这一层是"笔记管理器的功能"——创建、查看、删除。它调用 storage 层读写文件，但自己只关心"怎么操作笔记"。

```typescript
// src/commands.ts

import { Note, CreateNoteInput } from "./types";
import { loadNotes, saveNotes } from "./storage";

/**
 * 生成唯一 ID
 * 用时间戳 + 随机数拼接，足够在单用户场景下保证唯一性
 */
function generateId(): string {
    return Date.now().toString(36) + "-" + Math.random().toString(36).substring(2, 8);
}

/**
 * 创建一条新笔记
 * @param input - 包含 title 和 content
 * @returns 创建好的完整 Note 对象
 */
export function createNote(input: CreateNoteInput): Note {
    const now = new Date().toISOString();

    const note: Note = {
        id: generateId(),
        title: input.title,
        content: input.content,
        createdAt: now,
        updatedAt: now,
    };

    // 加载已有笔记，追加新笔记，保存
    const notes = loadNotes();
    notes.push(note);
    saveNotes(notes);

    return note;
}

/**
 * 列出所有笔记（只显示基本信息，不显示完整正文）
 * @returns 格式化的字符串，可以直接打印到终端
 */
export function listNotes(): string {
    const notes = loadNotes();

    if (notes.length === 0) {
        return "暂无笔记。试试用「创建笔记」命令来写第一条笔记吧！";
    }

    // map 遍历每一条笔记，生成一行摘要
    const lines = notes.map((note, index) => {
        // 截取正文前 50 个字符作为预览
        const preview = note.content.length > 50
            ? note.content.substring(0, 50) + "..."
            : note.content;

        return `[${index + 1}] ${note.title}\n    ID: ${note.id}\n    预览: ${preview}\n    创建: ${note.createdAt}`;
    });

    return `共有 ${notes.length} 条笔记：\n\n` + lines.join("\n\n");
}

/**
 * 查看单条笔记的完整内容
 * @param id - 笔记 ID（可以是完整 ID 或前几位）
 * @returns 笔记的完整 Markdown 内容，或者错误信息
 */
export function viewNote(id: string): string {
    const notes = loadNotes();

    // 支持模糊匹配：用户可以用 ID 的前几个字符来查找
    const note = notes.find((n) => n.id.startsWith(id));

    if (!note) {
        return `未找到 ID 为 "${id}" 的笔记。请先运行「列出笔记」查看所有笔记的 ID。`;
    }

    return `标题: ${note.title}\n创建: ${note.createdAt}\n更新: ${note.updatedAt}\n---\n${note.content}`;
}

/**
 * 删除一条笔记
 * @param id - 笔记 ID
 * @returns 是否删除成功
 */
export function deleteNote(id: string): boolean {
    const notes = loadNotes();
    const index = notes.findIndex((n) => n.id.startsWith(id));

    if (index === -1) {
        return false;
    }

    const deleted = notes.splice(index, 1)[0];
    saveNotes(notes);
    console.log(`笔记「${deleted.title}」已删除。`);
    return true;
}
```

### 第四步：CLI 入口（index.ts）

最后一步是把所有功能串起来，给用户一个命令行的交互界面。

```typescript
// src/index.ts

import * as readline from "readline";
import { createNote, listNotes, viewNote, deleteNote } from "./commands";

// 创建 readline 接口，用于在终端和用户互动
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});

/**
 * 显示主菜单
 */
function showMenu(): void {
    console.log("\n" + "=".repeat(50));
    console.log("  Markdown 笔记管理器");
    console.log("=".repeat(50));
    console.log("  1. 列出所有笔记");
    console.log("  2. 创建新笔记");
    console.log("  3. 查看笔记详情");
    console.log("  4. 删除笔记");
    console.log("  0. 退出");
    console.log("=".repeat(50) + "\n");
}

/**
 * 提示用户输入并处理
 */
function promptUser(): void {
    rl.question("请选择操作（输入数字）：", (choice) => {
        handleChoice(choice.trim());
    });
}

/**
 * 根据用户选择执行对应操作
 */
function handleChoice(choice: string): void {
    switch (choice) {
        case "1":
            // 列出所有笔记
            console.log("\n" + listNotes());
            break;

        case "2":
            // 创建新笔记 —— 顺序提示输入标题和内容
            rl.question("请输入笔记标题：", (title) => {
                if (!title.trim()) {
                    console.log("标题不能为空。");
                    promptUser();
                    return;
                }

                rl.question("请输入笔记内容（支持 Markdown）：", (content) => {
                    if (!content.trim()) {
                        console.log("内容不能为空。");
                        promptUser();
                        return;
                    }

                    const note = createNote({ title: title.trim(), content: content.trim() });
                    console.log(`笔记「${note.title}」创建成功！ID: ${note.id}`);
                    promptUser();
                });
            });
            return;  // 重要：因为 rl.question 是异步的，直接 return 避免后面再执行 promptUser

        case "3":
            // 查看笔记详情 —— 需要用户输入 ID
            rl.question("请输入笔记 ID（或前几位）：", (id) => {
                if (!id.trim()) {
                    console.log("ID 不能为空。");
                    promptUser();
                    return;
                }
                console.log("\n" + viewNote(id.trim()));
                promptUser();
            });
            return;

        case "4":
            // 删除笔记
            rl.question("请输入要删除的笔记 ID（或前几位）：", (id) => {
                if (!id.trim()) {
                    console.log("ID 不能为空。");
                    promptUser();
                    return;
                }
                const success = deleteNote(id.trim());
                if (!success) {
                    console.log(`未找到 ID 为 "${id.trim()}" 的笔记。`);
                }
                promptUser();
            });
            return;

        case "0":
            console.log("再见！");
            rl.close();
            return;

        default:
            console.log("无效的选项，请输入 0-4 之间的数字。");
            break;
    }

    // 如果不是 case 2/3/4/0（它们自己会处理后续流程），继续提示
    promptUser();
}

// ============================================================
// 程序启动
// ============================================================
console.log("欢迎使用 Markdown 笔记管理器！");
showMenu();
promptUser();
```

### 编译和运行

```bash
# 进入项目目录
cd examples/02-markdown-notes

# 初始化并安装依赖
npm init -y
npm install typescript --save-dev
npm install @types/node --save-dev   # Node.js 类型声明

# 编译
npx tsc

# 运行
node dist/index.js
```

### tsconfig.json 配置

```json
{
    "compilerOptions": {
        "target": "ES2020",
        "module": "commonjs",
        "outDir": "./dist",
        "rootDir": "./src",
        "strict": true,
        "esModuleInterop": true,
        "moduleResolution": "node",
        "sourceMap": true
    },
    "include": ["src/**/*"]
}
```

注意这里 `module: "commonjs"` 是给 Node.js 用的，和第一节浏览器项目不同。`moduleResolution: "node"` 让 TypeScript 能正确找到 `@types/node` 里的类型。

### 项目开发心得

你现在回头看这个项目，它是一个四层结构：
1. **types.ts** —— 数据模型层（"笔记长什么样"）
2. **storage.ts** —— 存储层（"笔记怎么存到硬盘上"）
3. **commands.ts** —— 业务逻辑层（"能对笔记做什么"）
4. **index.ts** —— 表示层（"用户怎么操作"）

这种分层思想是所有大型项目的基石。就像去餐厅吃饭，你是顾客（index.ts），告诉服务员（commands.ts）你要什么菜；服务员不需要知道厨师（storage.ts）是从哪个冰柜拿的食材，厨师也不需要知道是哪个顾客点的菜。每层只管自己的事。

## 动手试试

**任务**：根据 ID 更新一条笔记的标题或内容。

**具体步骤**：
1. 在 `commands.ts` 中新增一个 `updateNote(id: string, input: Partial<CreateNoteInput>): Note | null` 函数。
2. 用 `Partial<>` 工具类型让 `title` 和 `content` 都变成可选的——这样用户可以只更新标题、只更新内容，或者两个都更新。
3. 在函数中：加载所有笔记 -> 找到对应 ID 的笔记 -> 用传入的值覆盖 -> 更新 `updatedAt` 时间 -> 保存 -> 返回更新后的笔记。
4. 在 `index.ts` 的菜单中添加第 5 个选项"更新笔记"。
5. 编译并测试。

**提示**：`Partial<CreateNoteInput>` 等价于 `{ title?: string; content?: string; }`。你需要检查哪个字段传了值（`input.title !== undefined`），然后只更新那些字段。

## 本节小结

一个完整的 CLI 笔记管理器，教你用 TypeScript 把 interface、文件读写、模块组织串成一条线，体验"类型先行"的开发方式带来的清晰感。

## 下一节预告

在这个项目的基础上，加上搜索功能、标签系统，以及把笔记导出为真正的 Markdown 文件——让笔记管理器变得更实用。
