/**
 * commands.ts - 笔记管理器的业务逻辑层（扩展版）
 *
 * 相比上一节，新增了搜索、标签系统、导出为 Markdown 文件。
 * 所有函数都是纯数据操作，不关心用户界面。
 */

import * as fs from "fs";
import * as path from "path";
import { Note, CreateNoteInput, SearchResult, TagCount } from "./types";
import { loadNotes, saveNotes } from "./storage";

// ============================================================
// 工具函数
// ============================================================

/**
 * 生成全局唯一 ID
 * 策略：时间戳转 36 进制 + 随机字符串
 */
function generateId(): string {
    return (
        Date.now().toString(36) +
        "-" +
        Math.random().toString(36).substring(2, 8)
    );
}

// ============================================================
// CRUD 操作
// ============================================================

/**
 * 创建一条新笔记
 */
export function createNote(input: CreateNoteInput): Note {
    const now = new Date().toISOString();

    const note: Note = {
        id: generateId(),
        title: input.title,
        content: input.content,
        createdAt: now,
        updatedAt: now,
        tags: input.tags || [], // 默认空标签数组
        pinned: false,          // 默认不置顶
    };

    const notes = loadNotes();
    notes.push(note);
    saveNotes(notes);

    return note;
}

/**
 * 列出所有笔记的摘要信息
 * @param sortBy - 排序方式："time" 按时间降序，"title" 按标题升序
 */
export function listNotes(sortBy: "time" | "title" = "time"): string {
    const notes = loadNotes();

    if (notes.length === 0) {
        return "暂无笔记。试试用「创建笔记」命令来写第一条笔记吧！";
    }

    // 复制数组，避免修改原数据
    const sorted = [...notes];

    // 置顶笔记优先，然后按 sortBy 排序
    sorted.sort((a, b) => {
        // pinned 为 true 的排在前面
        if (a.pinned && !b.pinned) return -1;
        if (!a.pinned && b.pinned) return 1;

        // pinned 相同时，按 sortBy 排序
        if (sortBy === "time") {
            return b.createdAt.localeCompare(a.createdAt); // 降序
        } else {
            return a.title.localeCompare(b.title); // 升序
        }
    });

    const lines = sorted.map((note, index) => {
        const preview =
            note.content.length > 50
                ? note.content.substring(0, 50) + "..."
                : note.content;

        const pinMark = note.pinned ? " [置顶]" : "";
        const tagStr =
            note.tags.length > 0 ? ` | 标签: ${note.tags.join(", ")}` : "";

        return (
            `[${index + 1}] ${note.title}${pinMark}${tagStr}\n` +
            `    ID: ${note.id}\n` +
            `    预览: ${preview}\n` +
            `    创建: ${note.createdAt}`
        );
    });

    return (
        `共有 ${notes.length} 条笔记（排序：${sortBy === "time" ? "按时间" : "按标题"}）：\n\n` +
        lines.join("\n\n")
    );
}

/**
 * 查看单条笔记的完整内容
 */
export function viewNote(id: string): string {
    const notes = loadNotes();
    const note = notes.find((n) => n.id.startsWith(id));

    if (!note) {
        return `未找到 ID 为 "${id}" 的笔记。请先运行「列出笔记」查看所有笔记的 ID。`;
    }

    const tagStr =
        note.tags.length > 0 ? `标签: ${note.tags.join(", ")}` : "标签: 无";
    const pinStr = note.pinned ? " [置顶]" : "";

    return (
        `标题: ${note.title}${pinStr}\n` +
        `${tagStr}\n` +
        `创建: ${note.createdAt}\n` +
        `更新: ${note.updatedAt}\n` +
        `---\n` +
        `${note.content}`
    );
}

/**
 * 删除一条笔记
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

/**
 * 更新一条笔记的标题或内容
 * @param id - 笔记 ID
 * @param input - 要更新的字段（Partial 让所有字段都可选）
 * @returns 更新后的笔记，或 null 表示未找到
 */
export function updateNote(
    id: string,
    input: Partial<CreateNoteInput>
): Note | null {
    const notes = loadNotes();
    const note = notes.find((n) => n.id.startsWith(id));

    if (!note) {
        return null;
    }

    // 只更新传入的字段，未传入的保持不变
    if (input.title !== undefined) {
        note.title = input.title;
    }
    if (input.content !== undefined) {
        note.content = input.content;
    }
    if (input.tags !== undefined) {
        note.tags = input.tags;
    }

    note.updatedAt = new Date().toISOString();
    saveNotes(notes);

    console.log(`笔记「${note.title}」已更新。`);
    return note;
}

// ============================================================
// 搜索功能
// ============================================================

/**
 * 按关键词搜索笔记
 * 搜索范围：标题 + 正文内容
 */
export function searchNotes(keyword: string): SearchResult[] {
    const notes = loadNotes();
    const lowerKeyword = keyword.toLowerCase();
    const results: SearchResult[] = [];

    for (const note of notes) {
        // 检查标题是否包含关键词
        if (note.title.toLowerCase().includes(lowerKeyword)) {
            results.push({ note, matchType: "title" });
            continue; // 标题已匹配，跳过内容检查避免重复
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
export function formatSearchResults(
    results: SearchResult[],
    keyword: string
): string {
    if (results.length === 0) {
        return `未找到与「${keyword}」匹配的笔记。`;
    }

    const lines = results.map((result, index) => {
        const matchLabel =
            result.matchType === "title" ? "标题匹配" : "正文匹配";
        const preview =
            result.note.content.length > 40
                ? result.note.content.substring(0, 40) + "..."
                : result.note.content;

        return (
            `[${index + 1}] ${result.note.title}  (${matchLabel})\n` +
            `    ID: ${result.note.id}\n` +
            `    标签: ${
                result.note.tags.length > 0
                    ? result.note.tags.join(", ")
                    : "无"
            }\n` +
            `    预览: ${preview}`
        );
    });

    return (
        `搜索「${keyword}」找到 ${results.length} 条结果：\n\n` +
        lines.join("\n\n")
    );
}

// ============================================================
// 标签系统
// ============================================================

/**
 * 给笔记添加标签（去重）
 */
export function addTags(noteId: string, tags: string[]): boolean {
    const notes = loadNotes();
    const note = notes.find((n) => n.id.startsWith(noteId));

    if (!note) {
        return false;
    }

    // 只添加尚未存在的标签
    const newTags = tags.filter((tag) => !note.tags.includes(tag));

    if (newTags.length === 0) {
        console.log("所有标签已存在，未做更改。");
        return true;
    }

    note.tags.push(...newTags);
    note.updatedAt = new Date().toISOString();

    saveNotes(notes);
    console.log(
        `已为「${note.title}」添加标签：${newTags.join(", ")}`
    );
    return true;
}

/**
 * 按标签筛选笔记
 */
export function filterByTag(tag: string): Note[] {
    const notes = loadNotes();
    return notes.filter((note) =>
        note.tags.some((t) => t.toLowerCase() === tag.toLowerCase())
    );
}

/**
 * 列出所有标签及每个标签下的笔记数量
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

/**
 * 移除笔记的指定标签
 * @returns 移除是否成功
 */
export function removeTag(noteId: string, tag: string): boolean {
    const notes = loadNotes();
    const note = notes.find((n) => n.id.startsWith(noteId));

    if (!note) {
        return false;
    }

    const index = note.tags.findIndex(
        (t) => t.toLowerCase() === tag.toLowerCase()
    );
    if (index === -1) {
        console.log(`笔记「${note.title}」没有标签「${tag}」。`);
        return true;
    }

    note.tags.splice(index, 1);
    note.updatedAt = new Date().toISOString();
    saveNotes(notes);
    console.log(`已从「${note.title}」移除标签「${tag}」。`);
    return true;
}

// ============================================================
// 导出功能
// ============================================================

/**
 * 将单条笔记导出为 .md 文件
 * @param noteId - 笔记 ID
 * @param outputDir - 输出目录（默认为 exports/）
 * @returns 导出文件的完整路径，或 null 表示失败
 */
export function exportToMarkdown(
    noteId: string,
    outputDir?: string
): string | null {
    const notes = loadNotes();
    const note = notes.find((n) => n.id.startsWith(noteId));

    if (!note) {
        return null;
    }

    const dir = outputDir || path.join(__dirname, "..", "exports");

    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }

    // 文件名的非法字符替换为下划线
    const safeFileName =
        note.title.replace(/[<>:"/\\|?*]/g, "_") + ".md";
    const filePath = path.join(dir, safeFileName);

    // 生成 Markdown 内容
    const tagLine =
        note.tags.length > 0 ? `> 标签：${note.tags.join(", ")}` : "";
    const pinLine = note.pinned ? `> [置顶笔记]` : "";

    const frontMatter = [tagLine, pinLine].filter(Boolean).join("\n");

    const markdown = [
        `# ${note.title}`,
        "",
        frontMatter,
        frontMatter ? "" : "",
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

// ============================================================
// 置顶功能
// ============================================================

/**
 * 切换笔记的置顶状态
 */
export function togglePin(noteId: string): boolean {
    const notes = loadNotes();
    const note = notes.find((n) => n.id.startsWith(noteId));

    if (!note) {
        return false;
    }

    note.pinned = !note.pinned;
    note.updatedAt = new Date().toISOString();
    saveNotes(notes);

    console.log(
        `笔记「${note.title}」${note.pinned ? "已置顶" : "已取消置顶"}。`
    );
    return true;
}
