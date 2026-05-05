// ============================================================
// helpers.js —— 辅助工具模块
// 演示：CommonJS 导出风格说明（实际用 ESM）
// 供 main.js 用 import * as 全部导入
// ============================================================

export function formatDate(date) {
    const d = date || new Date();
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, "0");
    const day = String(d.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
}

export function randomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

export function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}
