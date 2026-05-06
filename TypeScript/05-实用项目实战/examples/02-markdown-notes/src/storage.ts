/**
 * storage.ts - 笔记数据的持久化层
 *
 * 负责把笔记数组保存到 JSON 文件和从文件读取。
 * 使用同步 API（readFileSync / writeFileSync）简化代码逻辑。
 */

import * as fs from "fs";
import * as path from "path";
import { Note } from "./types";

// data 目录和 JSON 文件路径
const DATA_DIR = path.join(__dirname, "..", "data");
const DATA_FILE = path.join(DATA_DIR, "notes.json");

/**
 * 确保 data 目录存在，不存在则创建
 */
function ensureDataDir(): void {
    if (!fs.existsSync(DATA_DIR)) {
        fs.mkdirSync(DATA_DIR, { recursive: true });
    }
}

/**
 * 从 JSON 文件加载所有笔记
 * @returns 笔记数组（文件不存在或为空时返回空数组）
 */
export function loadNotes(): Note[] {
    ensureDataDir();

    if (!fs.existsSync(DATA_FILE)) {
        return [];
    }

    const raw = fs.readFileSync(DATA_FILE, "utf-8");

    if (raw.trim() === "") {
        return [];
    }

    const notes: Note[] = JSON.parse(raw);
    return notes;
}

/**
 * 将笔记数组保存到 JSON 文件
 * @param notes - 要保存的笔记数组
 */
export function saveNotes(notes: Note[]): void {
    ensureDataDir();
    const json = JSON.stringify(notes, null, 2);
    fs.writeFileSync(DATA_FILE, json, "utf-8");
}
