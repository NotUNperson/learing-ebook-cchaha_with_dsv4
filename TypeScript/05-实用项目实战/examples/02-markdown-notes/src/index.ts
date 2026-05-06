/**
 * index.ts - CLI 交互入口
 *
 * 显示菜单、接收用户输入、调用 commands 层的函数。
 * 这是用户唯一直接面对的文件。
 */

import * as readline from "readline";
import { createNote, listNotes, viewNote, deleteNote } from "./commands";

// readline 接口：连接终端的输入和输出
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
 * 提示用户输入并分发到对应处理函数
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
            console.log("\n" + listNotes());
            break;

        case "2":
            // 创建笔记需要两步输入，所以用嵌套回调
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
                    const note = createNote({
                        title: title.trim(),
                        content: content.trim(),
                    });
                    console.log(
                        `笔记「${note.title}」创建成功！ID: ${note.id}`
                    );
                    promptUser();
                });
            });
            // 重要：异步操作中，直接 return 防止走到底部的 promptUser()
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

    // 只有非异步的分支才会走到这里继续提示
    promptUser();
}

// ============================================================
// 程序入口
// ============================================================
console.log("欢迎使用 Markdown 笔记管理器！");
showMenu();
promptUser();
