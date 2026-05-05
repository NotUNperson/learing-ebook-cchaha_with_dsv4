// ============================================================
// A.30 综合练习——命令行 TODO 工具
// 运行方式：node examples/A.30-cli-tool.js <命令> [参数]
//
// 示例：
//   node examples/A.30-cli-tool.js add "学习 JavaScript"
//   node examples/A.30-cli-tool.js list
//   node examples/A.30-cli-tool.js done 1
//   node examples/A.30-cli-tool.js delete 2
//   node examples/A.30-cli-tool.js clear
// ============================================================

import { readFile, writeFile } from "fs/promises";
import { existsSync } from "fs";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

// 为了在 ES 模块中获取 __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// 数据文件存放在 examples 目录下
const DATA_FILE = resolve(__dirname, "todo-tasks.json");

// ============================================================
// 1. 数据存储层——负责 JSON 文件的读写
// ============================================================
// 类比：图书馆的仓库管理员，只管"存"和"取"

/**
 * 从 JSON 文件加载任务列表
 * 如果文件不存在，返回空数组（首次使用）
 * @returns {Promise<Array>} 任务数组
 */
async function loadTasks() {
    try {
        if (!existsSync(DATA_FILE)) {
            console.log("  （数据文件不存在，创建新的任务列表）");
            return [];
        }
        const raw = await readFile(DATA_FILE, "utf8");
        // JSON.parse 将 JSON 字符串转为 JS 对象
        return JSON.parse(raw);
    } catch (err) {
        // 如果文件损坏或格式错误，返回空数组
        console.error("  加载数据失败，使用空列表:", err.message);
        return [];
    }
}

/**
 * 将任务列表保存到 JSON 文件
 * JSON.stringify(value, null, 2) 让输出带缩进，方便人工查看
 * @param {Array} tasks
 */
async function saveTasks(tasks) {
    try {
        const json = JSON.stringify(tasks, null, 2);
        await writeFile(DATA_FILE, json, "utf8");
    } catch (err) {
        throw new Error(`无法保存数据: ${err.message}`);
    }
}

// ============================================================
// 2. 业务逻辑层——TaskManager 类
// ============================================================
// 类比：图书馆的管理员，知道如何管理图书

class TaskManager {
    constructor() {
        // 任务数组——每条任务是一个对象
        // { id: 1, title: "xxx", completed: false, createdAt: "..." }
        this.tasks = [];
    }

    /**
     * 从文件加载任务到内存
     */
    async load() {
        this.tasks = await loadTasks();
        // 按 id 排序，保证顺序
        this.tasks.sort((a, b) => a.id - b.id);
    }

    /**
     * 将内存中的任务保存到文件
     */
    async save() {
        this.tasks.sort((a, b) => a.id - b.id);
        await saveTasks(this.tasks);
    }

    /**
     * 添加新任务
     * @param {string} title - 任务标题
     * @returns {Object} 新创建的任务对象
     */
    add(title) {
        // 生成新 id：当前最大 id + 1，如果没有任务则从 1 开始
        const maxId = this.tasks.length > 0
            ? Math.max(...this.tasks.map(t => t.id))
            : 0;

        const newTask = {
            id: maxId + 1,
            title: title,
            completed: false,
            createdAt: new Date().toISOString(),  // ISO 8601 格式
        };

        this.tasks.push(newTask);
        return newTask;
    }

    /**
     * 列出所有任务
     * @param {Object} options - 过滤选项
     * @param {boolean} [options.showAll=true] - 是否显示已完成的任务
     * @returns {Array} 任务数组
     */
    list(options = {}) {
        const { showAll = true } = options;
        if (showAll) {
            return [...this.tasks];  // 返回副本，防止外部修改
        }
        return this.tasks.filter(t => !t.completed);
    }

    /**
     * 将指定任务标记为完成
     * @param {number} id - 任务编号
     * @returns {Object} 更新后的任务
     */
    markDone(id) {
        // Array.find 查找第一个匹配的元素
        const task = this.tasks.find(t => t.id === id);
        if (!task) {
            throw new Error(`任务 #${id} 不存在`);
        }
        if (task.completed) {
            console.log(`  任务 #${id} 已经完成了，无需重复操作`);
        }
        task.completed = true;
        return task;
    }

    /**
     * 删除指定任务
     * @param {number} id - 任务编号
     */
    deleteTask(id) {
        // findIndex 查找索引位置
        const index = this.tasks.findIndex(t => t.id === id);
        if (index === -1) {
            throw new Error(`任务 #${id} 不存在`);
        }
        // splice(index, 1) 在 index 位置删除 1 个元素
        const removed = this.tasks.splice(index, 1)[0];
        return removed;
    }

    /**
     * 清理所有已完成的任务
     * @returns {number} 被清理的任务数量
     */
    clearCompleted() {
        const before = this.tasks.length;
        // filter 保留未完成的任务
        this.tasks = this.tasks.filter(t => !t.completed);
        return before - this.tasks.length;
    }

    /**
     * 获取统计信息
     * @returns {{ total: number, completed: number, pending: number }}
     */
    stats() {
        const total = this.tasks.length;
        const completed = this.tasks.filter(t => t.completed).length;
        const pending = total - completed;
        return { total, completed, pending };
    }
}

// ============================================================
// 3. 输出格式化——让打印更好看
// ============================================================

/**
 * 格式化显示任务列表
 * 用 ANSI 转义码给已完成的任务显示绿色
 * \x1b[32m = 绿色开始, \x1b[0m = 颜色重置
 */
function displayTasks(tasks) {
    if (tasks.length === 0) {
        console.log("  （暂无任务，用 add 命令添加一个吧）");
        return;
    }

    console.log("\n  编号 | 状态 | 任务标题");
    console.log("  -----|------|------------------");

    for (const task of tasks) {
        const status = task.completed ? "[x]" : "[ ]";
        const idStr = String(task.id).padStart(4, " ");
        const line = `${idStr} | ${status} | ${task.title}`;

        if (task.completed) {
            // 绿色输出——已完成的任务
            console.log(`  \x1b[32m${line}\x1b[0m`);
        } else {
            console.log(`  ${line}`);
        }
    }
}

/**
 * 显示统计信息
 */
function displayStats(stats) {
    const percent = stats.total > 0
        ? Math.round(stats.completed / stats.total * 100)
        : 0;
    console.log(`\n  总计: ${stats.total} | 已完成: ${stats.completed} | 未完成: ${stats.pending} | 进度: ${percent}%`);
}

// ============================================================
// 4. 错误处理辅助
// ============================================================
// 自定义错误类——区分不同类型的错误

class TodoError extends Error {
    constructor(message) {
        super(message);
        this.name = "TodoError";
    }
}

// ============================================================
// 5. 主入口——解析命令、执行操作
// ============================================================

async function main() {
    console.log("========== A.30 TODO 命令行工具 ==========");

    // process.argv[0] = node 的路径
    // process.argv[1] = 脚本的路径
    // process.argv[2] = 第一个参数（命令）
    // process.argv[3] = 第二个参数（参数值）
    const args = process.argv.slice(2);  // 去掉前两个
    const command = args[0];
    const argument = args.slice(1).join(" ");  // 后续参数合并（标题可能含空格）

    // 参数校验——没有命令就显示帮助
    if (!command) {
        showHelp();
        return;
    }

    // 创建管理器并加载数据
    const manager = new TaskManager();

    try {
        await manager.load();

        // 根据命令执行相应操作
        switch (command) {
            case "add": {
                if (!argument) {
                    throw new TodoError("请提供任务标题，例如：node examples/A.30-cli-tool.js add \"学习 JavaScript\"");
                }
                const task = manager.add(argument);
                console.log(`\n  ✓ 已添加任务 #${task.id}: ${task.title}`);
                await manager.save();
                break;
            }

            case "list": {
                const showAll = !args.includes("--pending");
                const tasks = manager.list({ showAll });
                console.log(`\n  TODO 列表（共 ${tasks.length} 项）：`);
                displayTasks(tasks);
                displayStats(manager.stats());
                break;
            }

            case "done": {
                const id = parseInt(argument, 10);
                if (isNaN(id)) {
                    throw new TodoError("请提供任务编号，例如：node examples/A.30-cli-tool.js done 1");
                }
                const task = manager.markDone(id);
                console.log(`\n  ✓ 任务 #${id} 已标记为完成: ${task.title}`);
                await manager.save();
                break;
            }

            case "delete": {
                const id = parseInt(argument, 10);
                if (isNaN(id)) {
                    throw new TodoError("请提供任务编号，例如：node examples/A.30-cli-tool.js delete 1");
                }
                const removed = manager.deleteTask(id);
                console.log(`\n  ✓ 任务 #${id} 已删除: ${removed.title}`);
                await manager.save();
                break;
            }

            case "clear": {
                const count = manager.clearCompleted();
                if (count === 0) {
                    console.log("\n  没有已完成的任务需要清理");
                } else {
                    console.log(`\n  ✓ 已清理 ${count} 个已完成任务`);
                }
                await manager.save();
                break;
            }

            case "stats": {
                displayStats(manager.stats());
                break;
            }

            default: {
                console.log(`\n  未知命令: ${command}`);
                showHelp();
                break;
            }
        }

    } catch (err) {
        // 统一的错误处理
        console.error(`\n  错误: ${err.message}`);
        if (err instanceof TodoError) {
            // 业务错误——正常返回码
            process.exitCode = 0;
        } else {
            // 系统错误——打印更多信息
            console.error(`  类型: ${err.name}`);
            process.exitCode = 1;
        }
    }
}

/**
 * 显示帮助信息
 */
function showHelp() {
    console.log("\n  TODO 命令行工具——使用说明：");
    console.log("  ────────────────────────────────");
    console.log("  add <标题>        添加新任务");
    console.log("  list              列出所有任务");
    console.log("  list --pending    只列出未完成的任务");
    console.log("  done <编号>       标记任务为已完成");
    console.log("  delete <编号>     删除任务");
    console.log("  clear             清理所有已完成任务");
    console.log("  stats             显示统计信息");
    console.log("  ────────────────────────────────");
    console.log("\n  示例：");
    console.log('    node examples/A.30-cli-tool.js add "学习 JavaScript"');
    console.log("    node examples/A.30-cli-tool.js add \"做数据结构作业\"");
    console.log("    node examples/A.30-cli-tool.js list");
    console.log("    node examples/A.30-cli-tool.js done 1");
    console.log("    node examples/A.30-cli-tool.js delete 2");
    console.log("    node examples/A.30-cli-tool.js stats");
    console.log("    node examples/A.30-cli-tool.js clear");
    console.log("");
}

// 执行主函数
main().catch(err => {
    // 最外层兜底——理论上不应该走到这里
    console.error("程序异常退出:", err);
    process.exit(1);
});
