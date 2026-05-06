# 03 - 项目一扩展：搜索、标签与导出

## 本节你会学到什么

- 实现文本搜索功能：在笔记数组中按关键词筛选
- 为数据模型添加标签系统，体验扩展 interface 的实际流程
- 将笔记导出为标准的 `.md` 文件，体会 TypeScript 在文件生成中的便利
- 学会用 `Array.filter` 和 `Array.sort` 等数组方法写高可读性的业务逻辑
- 理解"增量开发"：在已有项目基础上加功能，而不是每次重写

## 正文

### 当一个小项目开始长大

上一节我们写了一个能创建、查看、删除笔记的 CLI 工具。现在假设你用了它一星期，记了 30 条笔记。问题来了：你想找一条关于"数据库"的笔记，但你得一条一条翻。你开始想要搜索功能。

这就是真实项目开发的节奏：先做出能用的 MVP（最小可用产品），然后根据实际使用中的痛点逐步加功能。TypeScript 的好处在这种"增量开发"中特别明显——你要给 Note 加一个"标签"字段，TypeScript 会告诉你所有引用 Note 的地方需不需要同步修改。

**生活类比**：你买了一套房子（基础项目），先装修了厨房和卧室（CRUD 功能）。住了一个月后发现杂物太多，需要储物间（标签系统）；发现衣服堆在地上不好找，需要衣柜（搜索功能）。你不会因为要加一个储物间就把整个房子拆了重建——好房子从一开始就预留了扩展空间。TypeScript 的 interface 就是你的"建筑图纸"，让你知道在哪儿加墙最安全。

### 第一步：扩展数据模型

在 `types.ts` 中，给 `Note` 接口添加两个新字段：

```typescript
// src/types.ts（在原有基础上添加）

export interface Note {
    id: string;
    title: string;
    content: string;
    createdAt: string;
    updatedAt: string;

    // ----- 新增字段 -----

    /** 标签列表，比如 ["typescript", "学习"] */
    tags: string[];

    /** 是否置顶笔记（标记为重要的笔记始终排在前面） */
    pinned: boolean;
}

// CreateNoteInput 也需要同步更新
// 现在创建笔记时可以选择性地带上标签
export type CreateNoteInput = Pick<Note, "title" | "content"> & {
    tags?: string[];
};

/**
 * 搜索结果的数据结构
 * 不仅返回匹配的笔记，还返回匹配原因（方便用户理解为什么搜到了这条）
 */
export interface SearchResult {
    note: Note;
    /** 匹配类型：是标题匹配还是正文匹配 */
    matchType: "title" | "content";
}
```

注意，我们没有修改 `id`、`title`、`content` 等已有字段的类型，只添加了新字段。这叫"向后兼容"——旧代码如果没用到 `tags`，不会有任何影响。但如果旧代码在创建 `Note` 对象时没有给 `tags` 赋值，TypeScript 会报错。所以我们需要去 `commands.ts` 的 `createNote` 函数中加上默认值：

```typescript
// commands.ts 中 createNote 的修改
const note: Note = {
    id: generateId(),
    title: input.title,
    content: input.content,
    createdAt: now,
    updatedAt: now,
    tags: input.tags || [],  // 新增：默认空标签数组
    pinned: false,           // 新增：默认不置顶
};
```

看到了吗？TypeScript 在编译阶段就帮你找到了所有需要修改的地方。如果是纯 JavaScript，你只能等到运行时才发现"tags is undefined"。

### 第二步：搜索功能

搜索的本质是：遍历所有笔记，检查标题或内容是否包含关键词。我们用 `Array.filter` 实现。

```typescript
// src/commands.ts 中新增

import { SearchResult } from "./types";

/**
 * 按关键词搜索笔记
 * 搜索范围：标题 + 正文内容
 * @param keyword - 搜索关键词
 * @returns 匹配的笔记列表（SearchResult 包含笔记和匹配类型）
 */
export function searchNotes(keyword: string): SearchResult[] {
    const notes = loadNotes();
    const lowerKeyword = keyword.toLowerCase();
    const results: SearchResult[] = [];

    for (const note of notes) {
        // 检查标题是否包含关键词
        if (note.title.toLowerCase().includes(lowerKeyword)) {
            results.push({ note, matchType: "title" });
            continue; // 标题已匹配，跳过内容检查（避免重复）
        }

        // 检查正文是否包含关键词
        if (note.content.toLowerCase().includes(lowerKeyword)) {
            results.push({ note, matchType: "content" });
        }
    }

    return results;
}

/**
 * 把搜索结果格式化为可打印的字符串
 */
export function formatSearchResults(results: SearchResult[], keyword: string): string {
    if (results.length === 0) {
        return `未找到与「${keyword}」匹配的笔记。`;
    }

    const lines = results.map((result, index) => {
        const matchLabel = result.matchType === "title" ? "标题匹配" : "正文匹配";
        const preview = result.note.content.length > 40
            ? result.note.content.substring(0, 40) + "..."
            : result.note.content;

        return (
            `[${index + 1}] ${result.note.title}  (${matchLabel})\n` +
            `    ID: ${result.note.id}\n` +
            `    标签: ${result.note.tags.length > 0 ? result.note.tags.join(", ") : "无"}\n` +
            `    预览: ${preview}`
        );
    });

    return `搜索「${keyword}」找到 ${results.length} 条结果：\n\n` + lines.join("\n\n");
}
```

### 第三步：标签系统

标签是给笔记分类的最简单方式。你可以给一条笔记打上 `["typescript", "笔记"]`，然后按标签筛选。这比文件夹分类更灵活——一条笔记可以同时属于多个分类。

```typescript
// src/commands.ts 中新增

/**
 * 给笔记添加标签
 * @param noteId - 笔记 ID
 * @param tags - 要添加的标签列表
 * @returns 是否添加成功
 */
export function addTags(noteId: string, tags: string[]): boolean {
    const notes = loadNotes();
    const note = notes.find((n) => n.id.startsWith(noteId));

    if (!note) {
        return false;
    }

    // 去重：只添加尚未存在的标签
    const newTags = tags.filter((tag) => !note.tags.includes(tag));
    note.tags.push(...newTags);
    note.updatedAt = new Date().toISOString();

    saveNotes(notes);
    console.log(`已为「${note.title}」添加标签：${newTags.join(", ")}`);
    return true;
}

/**
 * 按标签筛选笔记
 * @param tag - 标签名
 * @returns 包含该标签的所有笔记
 */
export function filterByTag(tag: string): Note[] {
    const notes = loadNotes();
    return notes.filter((note) =>
        note.tags.some((t) => t.toLowerCase() === tag.toLowerCase())
    );
}

/**
 * 列出所有标签（去重）及每个标签下的笔记数量
 * @returns 统计结果字符串
 */
export function listTags(): string {
    const notes = loadNotes();
    const tagCounts: { [tag: string]: number } = {};

    for (const note of notes) {
        for (const tag of note.tags) {
            tagCounts[tag] = (tagCounts[tag] || 0) + 1;
        }
    }

    const tagNames = Object.keys(tagCounts);
    if (tagNames.length === 0) {
        return "暂无标签。在创建或更新笔记时可以添加标签。";
    }

    // 按使用次数降序排列
    tagNames.sort((a, b) => tagCounts[b] - tagCounts[a]);

    const lines = tagNames.map(
        (tag) => `  ${tag} —— ${tagCounts[tag]} 条笔记`
    );

    return "标签统计：\n" + lines.join("\n");
}
```

### 第四步：导出为 Markdown 文件

笔记存成 JSON 在程序里用很方便，但如果你想分享给没用这个工具的朋友，JSON 就没啥用了。导出为 `.md` 文件能让人在任何 Markdown 编辑器里看——甚至直接用文本编辑器打开都看得懂。

```typescript
// src/commands.ts 中新增

import * as fs from "fs";
import * as path from "path";

/**
 * 将单条笔记导出为 .md 文件
 * @param noteId - 笔记 ID
 * @param outputDir - 输出目录（默认为项目根目录下的 exports/）
 * @returns 导出文件的完整路径，或 null 表示失败
 */
export function exportToMarkdown(noteId: string, outputDir?: string): string | null {
    const notes = loadNotes();
    const note = notes.find((n) => n.id.startsWith(noteId));

    if (!note) {
        return null;
    }

    const dir = outputDir || path.join(__dirname, "..", "exports");

    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }

    // 把标题中的非法文件名字符替换为下划线
    const safeFileName = note.title.replace(/[<>:"/\\|?*]/g, "_") + ".md";
    const filePath = path.join(dir, safeFileName);

    // 生成 Markdown 内容
    const markdown = [
        `# ${note.title}`,
        "",
        // 如果有标签，以 YAML front matter 格式写在头部
        note.tags.length > 0 ? `> 标签：${note.tags.join(", ")}` : "",
        note.tags.length > 0 ? "" : "",
        `创建时间：${note.createdAt}`,
        `最后更新：${note.updatedAt}`,
        "",
        "---",
        "",
        note.content,
    ].join("\n");

    fs.writeFileSync(filePath, markdown, "utf-8");
    return filePath;
}

/**
 * 导出所有笔记为 Markdown 文件
 * @param outputDir - 输出目录
 * @returns 导出的文件数量
 */
export function exportAllToMarkdown(outputDir?: string): number {
    const notes = loadNotes();
    let count = 0;

    for (const note of notes) {
        const result = exportToMarkdown(note.id, outputDir);
        if (result) count++;
    }

    return count;
}
```

### 第五步：更新 CLI 菜单

在 `index.ts` 中扩充菜单选项：

```typescript
// index.ts 的 showMenu 函数中添加新选项
function showMenu(): void {
    console.log("\n" + "=".repeat(50));
    console.log("  Markdown 笔记管理器 v2.0");
    console.log("=".repeat(50));
    console.log("  1. 列出所有笔记");
    console.log("  2. 创建新笔记");
    console.log("  3. 查看笔记详情");
    console.log("  4. 删除笔记");
    console.log("  5. 搜索笔记");          // 新增
    console.log("  6. 添加标签");          // 新增
    console.log("  7. 按标签筛选");        // 新增
    console.log("  8. 标签统计");          // 新增
    console.log("  9. 导出笔记为 Markdown"); // 新增
    console.log("  0. 退出");
    console.log("=".repeat(50) + "\n");
}
```

然后在 `handleChoice` 的 `switch` 中添加对应的 case 分支：

```typescript
// 在 handleChoice 函数中添加

case "5":
    rl.question("请输入搜索关键词：", (keyword) => {
        if (!keyword.trim()) {
            console.log("关键词不能为空。");
            promptUser();
            return;
        }
        const results = searchNotes(keyword.trim());
        console.log("\n" + formatSearchResults(results, keyword.trim()));
        promptUser();
    });
    return;

case "6":
    rl.question("请输入笔记 ID：", (noteId) => {
        if (!noteId.trim()) { console.log("ID 不能为空。"); promptUser(); return; }
        rl.question("请输入标签（多个用逗号分隔，如：typescript,学习）：", (tagsInput) => {
            const tags = tagsInput.split(",").map((t) => t.trim()).filter((t) => t);
            if (tags.length === 0) { console.log("至少需要输入一个标签。"); promptUser(); return; }
            const success = addTags(noteId.trim(), tags);
            if (!success) console.log(`未找到 ID 为 "${noteId.trim()}" 的笔记。`);
            promptUser();
        });
    });
    return;

case "7":
    rl.question("请输入标签名：", (tag) => {
        if (!tag.trim()) { console.log("标签不能为空。"); promptUser(); return; }
        const notes = filterByTag(tag.trim());
        if (notes.length === 0) {
            console.log(`没有带标签「${tag.trim()}」的笔记。`);
        } else {
            console.log(`\n标签「${tag.trim()}」下的 ${notes.length} 条笔记：`);
            notes.forEach((n, i) => console.log(`  [${i + 1}] ${n.title}  (${n.tags.join(", ")})`));
        }
        promptUser();
    });
    return;

case "8":
    console.log("\n" + listTags());
    break;

case "9":
    rl.question("输入笔记 ID（或输入 all 导出全部）：", (id) => {
        if (id.trim().toLowerCase() === "all") {
            const count = exportAllToMarkdown();
            console.log(`已导出全部 ${count} 条笔记到 exports/ 目录。`);
        } else {
            const filePath = exportToMarkdown(id.trim());
            if (filePath) {
                console.log(`已导出到：${filePath}`);
            } else {
                console.log(`未找到 ID 为 "${id.trim()}" 的笔记。`);
            }
        }
        promptUser();
    });
    return;
```

### 完整的目录结构

完成后的项目结构：

```
examples/03-markdown-notes-advanced/
├── src/
│   ├── types.ts          # 扩展后的 Note 接口 + SearchResult 类型
│   ├── storage.ts        # 读写 JSON（与上一节相同）
│   ├── commands.ts       # 所有业务逻辑（CRUD + 搜索 + 标签 + 导出）
│   └── index.ts          # 扩充后的 CLI 菜单
├── data/                 # 笔记 JSON 存储
├── exports/              # 导出的 Markdown 文件
├── tsconfig.json
└── package.json
```

### 从增量的角度看待 TypeScript

你有没有注意到，从第 2 节到这第 3 节，我们没有写任何"重构代码"——所有改动都是在原有文件上追加内容。TypeScript 的静态类型检查让我们安心地做增量开发：

1. 先改 `types.ts` 加字段，编译器立刻告诉你哪些地方漏了初始化
2. 在 `commands.ts` 追加新函数，和旧函数互不干扰
3. 在 `index.ts` 追加新菜单项，旧菜单项照常工作

**生活类比**：这就像在乐高城堡上加一个塔楼。你不需要拆掉已经搭好的城墙，只需要找到合适的连接点（interface），把新零件（新函数）卡上去就行。TypeScript 就是告诉你"这里可以连接，那里不行"的说明图纸。

## 动手试试

**任务**：在"列出笔记"功能中加入排序选项。

**具体步骤**：
1. 修改 `listNotes` 函数，接受一个 `sortBy` 参数（类型为 `"time" | "title"`，默认 `"time"`）。
2. 当 `sortBy` 为 `"time"` 时，按 `createdAt` 降序（最新的在前）。
3. 当 `sortBy` 为 `"title"` 时，按 `title` 字母序升序（用 `localeCompare` 方法）。
4. 在 CLI 的"列出笔记"选项中，先打印排序后的列表，再询问是否要切换排序方式。
5. 测试两个排序方式都能正常工作。

**提示**：`Array.sort` 会修改原数组，所以建议先复制一份：`const sorted = [...notes].sort(...)`。时间字符串可以直接用 `>` 比较。标题比较用 `a.title.localeCompare(b.title)`。

## 本节小结

搜索、标签、导出——三个看似独立的功能，本质上都是对 `Note[]` 数组的变换操作，TypeScript 帮你确保每种变换的输入输出类型都严丝合缝。

## 下一节预告

换一个项目方向：从 CLI 回到浏览器，用 TypeScript 写一个完整的待办事项 Web 应用，把 DOM 操作、事件处理、状态管理全部串起来。
