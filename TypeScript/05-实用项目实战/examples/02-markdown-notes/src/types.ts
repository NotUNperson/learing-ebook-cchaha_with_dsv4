/**
 * types.ts - 笔记管理器的所有类型定义
 *
 * 项目的"数据蓝图"文件。所有模块都从这里引入类型，
 * 确保整个项目对"笔记长什么样"有统一的认识。
 */

/**
 * 一条笔记的核心数据结构
 */
export interface Note {
    /** 唯一标识，用时间戳 + 随机数生成 */
    id: string;

    /** 笔记标题 */
    title: string;

    /** 笔记正文，支持 Markdown 语法 */
    content: string;

    /** 创建时间，ISO 8601 格式 */
    createdAt: string;

    /** 最后修改时间 */
    updatedAt: string;
}

/**
 * 创建新笔记时的输入参数
 * 只需要标题和内容，id 和时间由程序自动生成
 */
export type CreateNoteInput = Pick<Note, "title" | "content">;
