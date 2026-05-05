// ============================================================
// A.24 错误处理 示例代码
// 运行方式：node examples/A.24-error.js
// ============================================================

console.log("========== A.24 错误处理 ==========\n");

// ----------------------------------------------------------
// 1. try/catch/finally 基本结构
// ----------------------------------------------------------
console.log("1. try/catch/finally 基本结构：");

function divide(a, b) {
    if (b === 0) {
        throw new Error("除数不能为零！");
    }
    return a / b;
}

// 正常情况
try {
    const result = divide(10, 2);
    console.log("  10 / 2 =", result);
} catch (error) {
    console.log("  出错:", error.message);
} finally {
    console.log("  第一次计算结束（finally 总执行）");
}

// 出错情况
try {
    const result = divide(10, 0);
    console.log("  这行不会执行");
} catch (error) {
    console.log("  捕获到错误:", error.message);
    // error 对象有 name、message、stack 属性
    console.log("    错误类型:", error.name);
} finally {
    console.log("  第二次计算结束（finally 总执行）");
}

// ----------------------------------------------------------
// 2. throw 可以抛出任何类型，但推荐 Error
// ----------------------------------------------------------
console.log("\n2. throw 不同值：");

// 不推荐：抛出字符串
try {
    throw "一个字符串错误";
} catch (e) {
    console.log("  捕获到字符串:", e);
    console.log("  typeof e:", typeof e);  // "string"——没有 stack 信息，很难调试
}

// 推荐：抛出 Error 实例
try {
    throw new Error("一个 Error 实例");
} catch (e) {
    console.log("  捕获到 Error:", e.message);
    console.log("  e instanceof Error:", e instanceof Error); // true
    console.log("  堆栈信息（stack）：");
    console.log("    " + e.stack.split("\n").slice(0, 3).join("\n    "));
}

// ----------------------------------------------------------
// 3. 内置错误类型
// ----------------------------------------------------------
console.log("\n3. 内置错误类型：");

// TypeError——对非预期类型的值进行操作
try {
    null.toString();
} catch (e) {
    console.log("  TypeError:", e.message);
    console.log("  e instanceof TypeError:", e instanceof TypeError);
}

// ReferenceError——引用不存在的变量
try {
    // eslint-disable-next-line no-undef
    undefinedVariable;
} catch (e) {
    console.log("  ReferenceError:", e.message);
    console.log("  e instanceof ReferenceError:", e instanceof ReferenceError);
}

// RangeError——数值超出范围
try {
    new Array(-1);
} catch (e) {
    console.log("  RangeError:", e.message);
    console.log("  e instanceof RangeError:", e instanceof RangeError);
}

// ----------------------------------------------------------
// 4. 自定义 Error 类
// ----------------------------------------------------------
console.log("\n4. 自定义 Error 类：");

class ValidationError extends Error {
    constructor(message, field) {
        super(message);                 // 调用 Error 的构造函数
        this.name = "ValidationError"; // 设置错误名称
        this.field = field;            // 自定义属性
    }
}

class NetworkError extends Error {
    constructor(message, statusCode) {
        super(message);
        this.name = "NetworkError";
        this.statusCode = statusCode;
    }
}

// 使用自定义错误
function validateUser(user) {
    if (!user.name || user.name.trim() === "") {
        throw new ValidationError("用户名不能为空", "name");
    }
    if (typeof user.age !== "number" || user.age < 0 || user.age > 150) {
        throw new ValidationError(`年龄不合理：${user.age}`, "age");
    }
    return true;
}

// 测试各种输入
const testUsers = [
    { name: "张三", age: 25 },      // 正常
    { name: "", age: 25 },          // 用户名为空
    { name: "李四", age: -5 },      // 年龄异常
    { name: "王五", age: 200 },     // 年龄不合理
];

for (const user of testUsers) {
    try {
        validateUser(user);
        console.log(`  用户 ${user.name || "(空)"} 验证通过`);
    } catch (e) {
        if (e instanceof ValidationError) {
            console.log(`  验证失败 [${e.field}]: ${e.message}`);
        } else {
            console.log(`  未知错误: ${e.message}`);
        }
    }
}

// ----------------------------------------------------------
// 5. 区分不同错误类型
// ----------------------------------------------------------
console.log("\n5. 在 catch 中区分错误类型：");

function processData(data) {
    if (!data) throw new TypeError("data 不能为 null");
    if (data.length > 100) throw new RangeError("数据长度超出限制");
    return data.toUpperCase();
}

const testCases = [null, "abc", "x".repeat(200)];

for (const data of testCases) {
    try {
        const result = processData(data);
        console.log(`  处理成功: ${result}`);
    } catch (e) {
        // JS 的 catch 只有一个参数，需要手动区分类型
        if (e instanceof TypeError) {
            console.log("  类型错误:", e.message);
        } else if (e instanceof RangeError) {
            console.log("  范围错误:", e.message);
        } else {
            console.log("  其他错误:", e.message);
        }
    }
}

// ----------------------------------------------------------
// 6. finally——清理资源
// ----------------------------------------------------------
console.log("\n6. finally 用于资源清理：");

function pretendFileOperation(willFail) {
    console.log("  [文件] 打开文件");

    try {
        if (willFail) {
            throw new Error("写入磁盘失败");
        }
        console.log("  [文件] 写入成功");
    } catch (e) {
        console.log("  [文件] 错误:", e.message);
    } finally {
        // 无论成功还是失败，都要关闭文件
        console.log("  [文件] 关闭文件（finally 保证）");
    }
}

console.log("  正常写入：");
pretendFileOperation(false);

console.log("\n  失败写入：");
pretendFileOperation(true);

// ----------------------------------------------------------
// 7. 错误冒泡——未捕获的错误沿调用栈向上传播
// ----------------------------------------------------------
console.log("\n7. 错误冒泡——未捕获的错误向上传播：");

function level3() {
    throw new Error("底层错误");
}

function level2() {
    // level2 没有 try/catch，错误继续向上
    level3();
}

function level1() {
    try {
        level2();
    } catch (e) {
        console.log("  在 level1 捕获到:", e.message);
        console.log("  错误经过了 level2 但没有被截住");
    }
}

level1();

// ----------------------------------------------------------
// 8. 实践中不要滥用 try/catch
// ----------------------------------------------------------
console.log("\n8. 实践建议——不要用异常控制流程：");

// 不好的写法——用 try/catch 做常规判断
function badExample(input) {
    try {
        return JSON.parse(input);
    } catch {
        return null;
    }
}

// 好的写法——先判断再处理
function goodExample(input) {
    if (!input || typeof input !== "string") {
        return null;
    }
    try {
        return JSON.parse(input);
    } catch {
        // JSON 格式错误是真正的"意外"情况，适合 try/catch
        return null;
    }
}

console.log("  bad:", badExample("not json"));
console.log("  good:", goodExample('{"valid": true}'));

console.log("\n========== 错误处理 演示结束 ==========");
