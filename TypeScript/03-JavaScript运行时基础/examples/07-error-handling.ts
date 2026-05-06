/**
 * 07-error-handling.ts
 * 错误处理 —— try/catch/finally 和自定义错误类
 *
 * 运行方式：
 *   ts-node 07-error-handling.ts
 */

// ============================================================
// 第一部分：try/catch/finally 基本结构
// ============================================================

console.log("=== 第一部分：try/catch/finally ===");

/**
 * 机场安检类比：
 *   try    = 把行李放进安检机
 *   throw  = 安检员发现问题，把行李拦下来
 *   catch  = 把有问题的行李拿到专门柜台处理
 *   finally = 安检机关机、打扫（无论有没有问题行李，都要做）
 */

// 一个会在特定条件下出错的函数
function divide(a: number, b: number): number {
  console.log(`  尝试计算 ${a} / ${b}`);
  if (b === 0) {
    // throw 会立即终止函数执行，就像 return，但它传递的是错误信息
    throw new Error("除数不能为零");
  }
  return a / b;
}

// 情况 1：正常执行
console.log("\n情况 1：正常除法");
try {
  const result: number = divide(10, 2);
  console.log(`  结果：${result}`);
} catch (error) {
  console.log(`  捕获错误：${(error as Error).message}`);
} finally {
  console.log("  [finally] 清理工作（无论成功失败都执行）");
}

// 情况 2：除以零
console.log("\n情况 2：除以零");
try {
  const result: number = divide(10, 0); // 这里会 throw
  console.log(`  结果：${result}`);     // 这行不会执行（异常跳过了）
} catch (error) {
  console.log(`  捕获错误：${(error as Error).message}`);
} finally {
  console.log("  [finally] 清理工作");
}

// ============================================================
// 第二部分：Error 的子类
// ============================================================

console.log("\n=== 第二部分：Error 的子类 ===");

/**
 * JavaScript 内置的 Error 类型：
 *   Error        - 通用错误
 *   RangeError   - 值不在合法范围内
 *   TypeError    - 值的类型不符合预期
 *   SyntaxError  - 语法错误
 *   ReferenceError - 引用未定义的变量
 */

// 演示 RangeError
function setAge(age: number): void {
  if (age < 0 || age > 150) {
    throw new RangeError(`年龄 ${age} 不在合法范围 (0-150)`);
  }
  console.log(`  年龄设置为：${age}`);
}

console.log("测试 RangeError：");
try {
  setAge(200); // 超出范围
} catch (error) {
  if (error instanceof RangeError) {
    console.log(`  [RangeError] ${error.message}`);
  } else {
    console.log(`  未知错误：${error}`);
  }
}

// ============================================================
// 第三部分：自定义错误类
// ============================================================

console.log("\n=== 第三部分：自定义错误类 ===");

/**
 * 自定义错误类可以携带更多上下文信息。
 * 比如一个网络错误，除了错误描述外，还可以携带 HTTP 状态码。
 *
 * 做法：继承 Error 类，添加自己的属性。
 */

// 自定义网络错误
class NetworkError extends Error {
  public statusCode: number;
  public url: string;

  constructor(message: string, statusCode: number, url: string) {
    super(message);            // 必须调用父类（Error）的构造函数
    this.name = "NetworkError"; // 设置错误类型名称
    this.statusCode = statusCode;
    this.url = url;

    // 这行是为了让 instanceof 正常工作（ES5 兼容）
    // 在 TypeScript 中通常不需要，但加上更安全
    Object.setPrototypeOf(this, NetworkError.prototype);
  }
}

// 自定义验证错误
class ValidationError extends Error {
  public fieldName: string;

  constructor(message: string, fieldName: string) {
    super(message);
    this.name = "ValidationError";
    this.fieldName = fieldName;
    Object.setPrototypeOf(this, ValidationError.prototype);
  }
}

// 模拟一个验证用户名不为空的函数
function validateUsername(username: string | null): string {
  if (username === null || username.trim() === "") {
    throw new ValidationError("用户名不能为空", "username");
  }
  if (username.length < 3) {
    throw new ValidationError("用户名至少3个字符", "username");
  }
  if (username.length > 20) {
    throw new ValidationError("用户名不能超过20个字符", "username");
  }
  return username;
}

// 测试不同的错误情况
function testValidation(input: string | null): void {
  console.log(`\n验证用户名 "${input}"：`);
  try {
    const valid: string = validateUsername(input);
    console.log(`  验证通过：${valid}`);
  } catch (error) {
    // 用 instanceof 区分不同类型的错误
    if (error instanceof ValidationError) {
      console.log(`  [验证错误] 字段 ${error.fieldName}: ${error.message}`);
    } else if (error instanceof Error) {
      console.log(`  [通用错误] ${error.message}`);
    } else {
      console.log(`  [未知错误] ${error}`);
    }
  }
}

testValidation(null);    // 空值
testValidation("ab");   // 太短
testValidation("一个超过二十个字符的非常长的用户名哈哈哈哈"); // 太长
testValidation("小明学TS"); // 合法

// ============================================================
// 第四部分：在 async 函数中使用 try/catch
// ============================================================

console.log("\n=== 第四部分：async 函数中的错误处理 ===");

/**
 * async 函数里的 try/catch 使用方式和非 async 函数一样，
 * 只是 await 抛出的错误（Promise reject）也会被 catch 捕获。
 */

// 模拟一个可能出错的异步操作
function fetchUserData(userId: number): Promise<{ id: number; name: string }> {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (userId <= 0) {
        // Promise.reject 的效果类似于 throw，但发生在异步回调中
        reject(new Error(`无效的用户 ID: ${userId}（必须 > 0）`));
      } else if (userId > 1000) {
        reject(new Error(`用户 ID ${userId} 不存在`));
      } else {
        resolve({ id: userId, name: `用户_${userId}` });
      }
    }, 500);
  });
}

// async 函数中捕获错误
async function getUser(userId: number): Promise<void> {
  try {
    console.log(`  请求用户 ID=${userId}...`);
    const user = await fetchUserData(userId);
    console.log(`  成功：${user.name}`);
  } catch (error) {
    // await 抛出的错误（Promise reject）也会被这里 catch
    console.log(`  失败：${(error as Error).message}`);
  }
}

async function runAsyncTests(): Promise<void> {
  await getUser(100);   // 正常
  await getUser(-1);    // 无效 ID
  await getUser(2000);  // 不存在
  await getUser(42);    // 正常
}

runAsyncTests().then(() => {
  // ============================================================
  // 第五部分：优雅降级
  // ============================================================

  console.log("\n=== 第五部分：优雅降级 ===");

  /**
   * 优雅降级 = 出错了不崩溃，返回一个兜底值
   *
   * 类比：电梯停电时启动备用电源，缓缓降到最近楼层
   *   到不了目的楼层，但至少没摔下去
   *
   * 在代码中：不 throw 让程序崩溃，而是返回一个友好的兜底字符串或默认值
   */

  // 模拟一个不稳定的外部 API
  async function unstableApiCall(): Promise<string> {
    // 50% 概率成功，50% 概率失败
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        if (Math.random() < 0.5) {
          resolve("API 返回的数据：今天天气晴，25 度");
        } else {
          reject(new Error("API 服务器无响应"));
        }
      }, 300);
    });
  }

  // 带优雅降级的版本
  async function fetchWeatherSafely(): Promise<string> {
    try {
      const data: string = await unstableApiCall();
      return data; // 成功时返回实际数据
    } catch (error) {
      // 失败时返回兜底信息，而不是让程序崩溃
      const errMsg: string = (error as Error).message;
      console.log(`  [降级] 因为 "${errMsg}"，使用兜底数据`);
      return "暂时无法获取天气，请稍后再试（兜底信息）";
    }
  }

  console.log("模拟 5 次天气查询：");
  const fetches: Promise<void>[] = [];
  for (let i = 0; i < 5; i++) {
    fetches.push(
      fetchWeatherSafely().then((result: string) => {
        console.log(`  第 ${i + 1} 次结果：${result}`);
      })
    );
  }

  // 等所有请求完成
  Promise.all(fetches).then(() => {
    console.log("\n（即使部分请求失败，程序也没有崩溃）");
  });

});

// ============================================================
// 第六部分：catch 错误类型标注 —— TypeScript 的坑
// ============================================================

setTimeout(() => {
  console.log("\n=== 第六部分：TypeScript 中 catch 的类型问题 ===");

  /**
   * 在严格模式下（strict: true），catch 捕获的 error 类型是 unknown
   * 你不能直接 error.message，必须做类型收窄
   */

  try {
    // 故意抛一个字符串（不推荐，但有人会这么做）
    throw "这是一个字符串错误";
  } catch (error: unknown) {
    // TypeScript 会阻止你直接访问 error.message
    // 必须做类型收窄：

    if (error instanceof Error) {
      // 如果它是 Error 对象
      console.log(`  方式1（Error 对象）：${error.message}`);
    } else if (typeof error === "string") {
      // 如果它是字符串
      console.log(`  方式2（字符串）：${error}`);
    } else {
      // 其他类型
      console.log(`  方式3（其他）：${String(error)}`);
    }
  }

  // 如果在 tsconfig.json 中 strict: false（不推荐），error 默认是 any
  // 这时可以直接访问 error.message，但如果 error 不是 Error 对象就会出问题

  const bestPractice: string = `
错误处理最佳实践：
  1. 永远 throw Error 对象（不要 throw 字符串或数字）
  2. catch 后用 instanceof 做类型收窄（不要直接断言）
  3. 用自定义 Error 子类携带更多上下文
  4. 异步代码中 try/catch 包住 await
  5. 对外暴露的 API 做优雅降级，不要让用户看到崩溃
`;

  console.log(bestPractice);

  console.log("全部演示结束！");
}, 3500);

// 总运行时间约 3~4 秒
