/**
 * commands.ts - 笔记管理器的业务逻辑层
 *
 * 所有对笔记的操作（增删改查）都在这里。
 * 它调用 storage.ts 读写文件，自己不关心文件怎么存的。
 */

import { Note, CreateNoteInput } from "./types";
import { loadNotes, saveNotes } from "./storage";

/**
 * 生成一个全局唯一的 ID
 * 策略：当前时间戳转 36 进制 + 随机字符串
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

    const notes = loadNotes();
    notes.push(note);
    saveNotes(notes);

    return note;
}

/**
 * 列出所有笔记的摘要信息
 * @returns 可直接打印的格式化字符串
 */
export function listNotes(): string {
    const notes = loadNotes();

    if (notes.length === 0) {
        return "暂无笔记。试试用「创建笔记」命令来写第一条笔记吧！";
    }

    const lines = notes.map((note, index) => {
        // 截取正文前 50 个字符作为预览
        const preview =
            note.content.length > 50
                ? note.content.substring(0, 50) + "..."
                : note.content;

        return (
            `[${index + 1}] ${note.title}\n` +
            `    ID: ${note.id}\n` +
            `    预览: ${preview}\n` +
            `    创建: ${note.createdAt}`
        );
    });

    return `共有 ${notes.length} 条笔记：\n\n` + lines.join("\n\n");
}

/**
 * 查看单条笔记的完整内容
 * @param id - 笔记 ID（支持模糊匹配，可只输入前几位）
 * @returns 笔记详情或错误信息
 */
export function viewNote(id: string): string {
    const notes = loadNotes();
    const note = notes.find((n) => n.id.startsWith(id));

    if (!note) {
        return `未找到 ID 为 "${id}" 的笔记。请先运行「列出笔记」查看所有笔记的 ID。`;
    }

    return (
        `标题: ${note.title}\n` +
        `创建: ${note.createdAt}\n` +
        `更新: ${note.updatedAt}\n` +
        `---\n` +
        `${note.content}`
    );
}

/**
 * 删除一条笔记
 * @param id - 笔记 ID（支持模糊匹配）
 * @returns 是否成功删除
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
