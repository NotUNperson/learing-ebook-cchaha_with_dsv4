/**
 * index.ts - CLI 交互入口（扩展版）
 *
 * 添加了搜索、标签、导出、置顶等新功能的菜单入口。
 */

import * as readline from "readline";
import {
    createNote,
    listNotes,
    viewNote,
    deleteNote,
    updateNote,
    searchNotes,
    formatSearchResults,
    addTags,
    filterByTag,
    listTags,
    removeTag,
    exportToMarkdown,
    exportAllToMarkdown,
    togglePin,
} from "./commands";

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});

/** 当前列表排序方式 */
let currentSortBy: "time" | "title" = "time";

/**
 * 显示主菜单
 */
function showMenu(): void {
    console.log("\n" + "=".repeat(50));
    console.log("  Markdown 笔记管理器 v2.0");
    console.log("=".repeat(50));
    console.log("  1. 列出所有笔记");
    console.log("  2. 创建新笔记");
    console.log("  3. 查看笔记详情");
    console.log("  4. 删除笔记");
    console.log("  5. 更新笔记");
    console.log("  6. 搜索笔记");
    console.log("  7. 添加标签");
    console.log("  8. 移除标签");
    console.log("  9. 按标签筛选");
    console.log("  10. 标签统计");
    console.log("  11. 置顶/取消置顶");
    console.log("  12. 导出笔记为 Markdown");
    console.log("  0. 退出");
    console.log("=".repeat(50) + "\n");
}

function promptUser(): void {
    rl.question("请选择操作（输入数字）：", (choice) => {
        handleChoice(choice.trim());
    });
}

function handleChoice(choice: string): void {
    switch (choice) {
        case "1":
            console.log("\n" + listNotes(currentSortBy));
            rl.question(
                "\n按 T 切换按标题排序，按 D 切换按时间排序，直接回车返回：",
                (sub) => {
                    if (sub.trim().toLowerCase() === "t") {
                        currentSortBy = "title";
                    } else if (sub.trim().toLowerCase() === "d") {
                        currentSortBy = "time";
                    }
                    promptUser();
                }
            );
            return;

        case "2":
            rl.question("请输入笔记标题：", (title) => {
                if (!title.trim()) {
                    console.log("标题不能为空。");
                    promptUser();
                    return;
                }
                rl.question(
                    "请输入笔记内容（支持 Markdown）：",
                    (content) => {
                        if (!content.trim()) {
                            console.log("内容不能为空。");
                            promptUser();
                            return;
                        }
                        rl.question(
                            "请输入标签（多个用逗号分隔，可选，直接回车跳过）：",
                            (tagsInput) => {
                                const tags = tagsInput
                                    ? tagsInput
                                          .split(",")
                                          .map((t) => t.trim())
                                          .filter((t) => t)
                                    : [];
                                const note = createNote({
                                    title: title.trim(),
                                    content: content.trim(),
                                    tags,
                                });
                                console.log(
                                    `笔记「${note.title}」创建成功！ID: ${note.id}`
                                );
                                if (tags.length > 0) {
                                    console.log(
                                        `标签：${tags.join(", ")}`
                                    );
                                }
                                promptUser();
                            }
                        );
                    }
                );
            });
            return;

        case "3":
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
            rl.question("请输入要删除的笔记 ID（或前几位）：", (id) => {
                if (!id.trim()) {
                    console.log("ID 不能为空。");
                    promptUser();
                    return;
                }
                const success = deleteNote(id.trim());
                if (!success) {
                    console.log(
                        `未找到 ID 为 "${id.trim()}" 的笔记。`
                    );
                }
                promptUser();
            });
            return;

        case "5":
            rl.question("请输入要更新的笔记 ID：", (id) => {
                if (!id.trim()) {
                    console.log("ID 不能为空。");
                    promptUser();
                    return;
                }
                rl.question(
                    "请输入新标题（留空保持不变）：",
                    (title) => {
                        rl.question(
                            "请输入新内容（留空保持不变）：",
                            (content) => {
                                rl.question(
                                    "请输入新标签，多个用逗号分隔（留空保持不变）：",
                                    (tagsInput) => {
                                        const tags = tagsInput
                                            ? tagsInput
                                                  .split(",")
                                                  .map((t) =>
                                                      t.trim()
                                                  )
                                                  .filter((t) => t)
                                            : undefined;

                                        const input: any = {};
                                        if (title.trim())
                                            input.title =
                                                title.trim();
                                        if (content.trim())
                                            input.content =
                                                content.trim();
                                        if (tags !== undefined)
                                            input.tags = tags;

                                        if (
                                            Object.keys(input)
                                                .length === 0
                                        ) {
                                            console.log(
                                                "没有输入任何更新内容。"
                                            );
                                            promptUser();
                                            return;
                                        }

                                        const result = updateNote(
                                            id.trim(),
                                            input
                                        );
                                        if (!result) {
                                            console.log(
                                                `未找到 ID 为 "${id.trim()}" 的笔记。`
                                            );
                                        }
                                        promptUser();
                                    }
                                );
                            }
                        );
                    }
                );
            });
            return;

        case "6":
            rl.question("请输入搜索关键词：", (keyword) => {
                if (!keyword.trim()) {
                    console.log("关键词不能为空。");
                    promptUser();
                    return;
                }
                const results = searchNotes(keyword.trim());
                console.log(
                    "\n" +
                        formatSearchResults(results, keyword.trim())
                );
                promptUser();
            });
            return;

        case "7":
            rl.question("请输入笔记 ID：", (noteId) => {
                if (!noteId.trim()) {
                    console.log("ID 不能为空。");
                    promptUser();
                    return;
                }
                rl.question(
                    "请输入标签（多个用逗号分隔）：",
                    (tagsInput) => {
                        const tags = tagsInput
                            .split(",")
                            .map((t) => t.trim())
                            .filter((t) => t);
                        if (tags.length === 0) {
                            console.log("至少需要输入一个标签。");
                            promptUser();
                            return;
                        }
                        const success = addTags(noteId.trim(), tags);
                        if (!success) {
                            console.log(
                                `未找到 ID 为 "${noteId.trim()}" 的笔记。`
                            );
                        }
                        promptUser();
                    }
                );
            });
            return;

        case "8":
            rl.question("请输入笔记 ID：", (noteId) => {
                if (!noteId.trim()) {
                    console.log("ID 不能为空。");
                    promptUser();
                    return;
                }
                rl.question("请输入要移除的标签名：", (tag) => {
                    if (!tag.trim()) {
                        console.log("标签不能为空。");
                        promptUser();
                        return;
                    }
                    const success = removeTag(
                        noteId.trim(),
                        tag.trim()
                    );
                    if (!success) {
                        console.log(
                            `未找到 ID 为 "${noteId.trim()}" 的笔记。`
                        );
                    }
                    promptUser();
                });
            });
            return;

        case "9":
            rl.question("请输入标签名：", (tag) => {
                if (!tag.trim()) {
                    console.log("标签不能为空。");
                    promptUser();
                    return;
                }
                const notes = filterByTag(tag.trim());
                if (notes.length === 0) {
                    console.log(
                        `没有带标签「${tag.trim()}」的笔记。`
                    );
                } else {
                    console.log(
                        `\n标签「${tag.trim()}」下的 ${
                            notes.length
                        } 条笔记：`
                    );
                    notes.forEach((n, i) =>
                        console.log(
                            `  [${i + 1}] ${n.title}  (${n.tags.join(
                                ", "
                            )})`
                        )
                    );
                }
                promptUser();
            });
            return;

        case "10":
            console.log("\n" + listTags());
            break;

        case "11":
            rl.question("请输入笔记 ID：", (noteId) => {
                if (!noteId.trim()) {
                    console.log("ID 不能为空。");
                    promptUser();
                    return;
                }
                const success = togglePin(noteId.trim());
                if (!success) {
                    console.log(
                        `未找到 ID 为 "${noteId.trim()}" 的笔记。`
                    );
                }
                promptUser();
            });
            return;

        case "12":
            rl.question(
                "输入笔记 ID（或输入 all 导出全部）：",
                (id) => {
                    if (id.trim().toLowerCase() === "all") {
                        const count = exportAllToMarkdown();
                        console.log(
                            `已导出全部 ${count} 条笔记到 exports/ 目录。`
                        );
                    } else if (id.trim()) {
                        const filePath = exportToMarkdown(id.trim());
                        if (filePath) {
                            console.log(`已导出到：${filePath}`);
                        } else {
                            console.log(
                                `未找到 ID 为 "${id.trim()}" 的笔记。`
                            );
                        }
                    } else {
                        console.log("请输入有效的 ID 或 all。");
                    }
                    promptUser();
                }
            );
            return;

        case "0":
            console.log("再见！");
            rl.close();
            return;

        default:
            console.log("无效的选项，请输入 0-12 之间的数字。");
            break;
    }

    promptUser();
}

// ============================================================
// 程序入口
// ============================================================
console.log("欢迎使用 Markdown 笔记管理器 v2.0！");
showMenu();
promptUser();
