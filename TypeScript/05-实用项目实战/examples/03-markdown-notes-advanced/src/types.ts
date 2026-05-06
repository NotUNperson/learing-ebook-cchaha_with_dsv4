/**
 * types.ts - 笔记管理器的所有类型定义（扩展版）
 *
 * 相比上一节，新增了 tags 和 pinned 字段，
 * 以及 SearchResult 类型用于搜索功能，
 * TagCount 类型用于标签统计。
 */

export interface Note {
    /** 唯一标识 */
    id: string;

    /** 笔记标题 */
    title: string;

    /** 笔记正文，支持 Markdown 语法 */
    content: string;

    /** 创建时间，ISO 8601 格式 */
    createdAt: string;

    /** 最后修改时间 */
    updatedAt: string;

    /** 标签列表，例如 ["typescript", "学习笔记"] */
    tags: string[];

    /** 是否置顶（标记为重要的笔记始终排在前面） */
    pinned: boolean;
}

/**
 * 创建新笔记时的输入参数
 * title 和 content 必填，tags 可选
 */
export type CreateNoteInput = Pick<Note, "title" | "content"> & {
    tags?: string[];
};

/**
 * 搜索结果 —— 除了笔记本身，还记录是标题匹配还是内容匹配
 */
export interface SearchResult {
    note: Note;
    /** 匹配类型 */
    matchType: "title" | "content";
}

/**
 * 标签统计
 */
export interface TagCount {
    tag: string;
    count: number;
}
