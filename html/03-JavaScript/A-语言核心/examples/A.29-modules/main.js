// ============================================================
// main.js —— 主入口文件
// 演示：各种 import 方式
// 运行方式：cd examples/A.29-modules && node main.js
// ============================================================

console.log("========== A.29 模块化 ==========\n");

// ----------------------------------------------------------
// 1. 命名导入（Named Import）——用花括号
// ----------------------------------------------------------
console.log("1. 命名导入（从 math.js）：");

// 只导入需要的
import { PI, add, subtract, divide, Vector2D } from "./math.js";
// 注意：路径必须以 ./ 开头（相对路径），且需要 .js 后缀

console.log(`  PI = ${PI}`);
console.log(`  1 + 2 = ${add(1, 2)}`);
console.log(`  10 - 3 = ${subtract(10, 3)}`);
console.log(`  10 / 3 = ${divide(10, 3)}`);

const v = new Vector2D(3, 4);
console.log(`  向量 (3, 4) 的模 = ${v.magnitude()}`);

// ----------------------------------------------------------
// 2. 默认导入（Default Import）——不用花括号
// ----------------------------------------------------------
console.log("\n2. 默认导入（从 User.js）：");

// 默认导出不需要花括号，名字可以随意起
import User from "./User.js";

const user1 = new User("张三", "zhangsan@example.com");
const user2 = new User("李四", "lisi@example.com");

console.log(`  ${user1.getInfo()}`);
console.log(`  ${user2.getInfo()}`);

// ----------------------------------------------------------
// 3. 全部导入（Namespace Import）—— import * as
// ----------------------------------------------------------
console.log("\n3. 全部导入（从 helpers.js）：");

import * as helpers from "./helpers.js";

// 通过 namespace 访问所有导出
console.log(`  今天的日期: ${helpers.formatDate()}`);
console.log(`  随机数 (1-100): ${helpers.randomInt(1, 100)}`);

// 使用 async 函数来演示 sleep
const { sleep } = helpers;
console.log("  开始等待...");
await sleep(300);
console.log("  等待 300ms 完成");

// ----------------------------------------------------------
// 4. 混合导入——默认 + 命名同时
// ----------------------------------------------------------
console.log("\n4. 混合导入（从 config.js）：");

// 默认导入 + 命名导入同时进行
import defaultConfig, { APP_NAME, APP_VERSION, getEnv } from "./config.js";

console.log(`  应用名: ${APP_NAME}`);
console.log(`  版本: ${APP_VERSION}`);
console.log(`  环境: ${getEnv()}`);
console.log(`  默认配置:`, defaultConfig);

// ----------------------------------------------------------
// 5. 动态导入—— import() 返回 Promise
// ----------------------------------------------------------
console.log("\n5. 动态导入：");

// 模拟：根据条件决定导入哪个模块
const needAdvancedMath = true;

if (needAdvancedMath) {
    // import() 返回 Promise，可以用 await
    const mathModule = await import("./math.js");
    console.log(`  动态导入成功！PI * 2 = ${mathModule.PI * 2}`);
}

// 用于错误处理
try {
    const result = await import("./nonExistentModule.js");
} catch (err) {
    console.log("  捕获到动态导入错误（模块不存在）");
}

// ----------------------------------------------------------
// 6. ESM 与 CommonJS 对比总结
// ----------------------------------------------------------
console.log("\n6. ESM vs CommonJS 总结：");
console.log("  +------------------------------+----------------------+");
console.log("  |  特性                        |  ESM                 |");
console.log("  +------------------------------+----------------------+");
console.log("  |  语法                        |  import / export     |");
console.log("  |  CommonJS 语法               |  require / exports   |");
console.log("  |  加载时机                    |  静态（编译时）     |");
console.log("  |  CommonJS 加载               |  动态（运行时）     |");
console.log("  |  this 值（顶层）             |  undefined           |");
console.log("  |  CommonJS this               |  module.exports      |");
console.log("  |  浏览器支持                  |  原生支持            |");
console.log("  |  CommonJS 浏览器             |  需要打包工具       |");
console.log("  +------------------------------+----------------------+");

console.log("\n========== 模块化 演示结束 ==========");
