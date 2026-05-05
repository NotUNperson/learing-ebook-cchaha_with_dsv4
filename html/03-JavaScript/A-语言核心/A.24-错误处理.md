# A.24 错误处理

## 本节你会学到什么

- `try/catch/finally` 的基本语法——捕获并处理错误
- `throw` 抛出错误，可以抛出任何类型但推荐 Error 实例
- 自定义 Error 类——通过继承 Error 来创建业务专属的错误类型
- `finally` 块——不管有没有出错都会执行的代码
- 常见的内置错误类型：TypeError、ReferenceError、SyntaxError、RangeError

## 正文

### 错误处理为什么重要

**生活类比**：你在 ATM 取钱。正常流程是：插卡 → 输密码 → 输入金额 → 取钱。但可能出现各种意外：密码错了、余额不足、机器没钞了、卡被吞了。如果程序不处理这些"意外"，就会崩溃——就像 ATM 突然黑屏死机。try/catch 就是告诉程序："如果出错了，不要死，按备选方案来。"

### try/catch/finally 基本结构

```javascript
try {
    // 可能出错的代码
    const result = riskyFunction();
    console.log("成功了：", result);
} catch (error) {
    // 出错时执行
    console.log("出错了：", error.message);
} finally {
    // 不管有没有错，都执行
    console.log("清理工作完成");
}
```

和 C++ 的 try/catch 很像，但有一个关键区别：**JS 的 catch 只有一个参数**，没有类型化的 catch 块。你不能写 `catch (TypeError e)` 和 `catch (RangeError e)` 分开处理——只有一个 `catch`，你得在 catch 块内部通过 `instanceof` 判断错误类型。

### throw——抛出错误

```javascript
function divide(a, b) {
    if (b === 0) {
        throw new Error("除数不能为零");
    }
    return a / b;
}

try {
    console.log(divide(10, 0));
} catch (e) {
    console.log(e.message); // "除数不能为零"
}
```

虽然可以 `throw "出错了"`（抛出字符串），但**强烈建议总是抛出 Error 实例**，因为 Error 实例附带堆栈追踪信息（stack），调试价值巨大。

### 常见的错误类型

| 错误类型 | 触发场景 |
|---------|----------|
| `TypeError` | 对非函数类型的值调用，访问 null 的属性等 |
| `ReferenceError` | 引用未定义的变量 |
| `SyntaxError` | 语法错误（通常代码无法运行，不需要 catch）|
| `RangeError` | 数值超出有效范围（如 `new Array(-1)`）|

```javascript
try {
    null.toString();  // TypeError
} catch (e) {
    console.log(e.name);     // "TypeError"
    console.log(e.message);  // "Cannot read properties of null"
    console.log(e.stack);    // 堆栈追踪——调试神器
}
```

### 自定义 Error

当内置的 Error 类型不足以描述你的业务错误时，可以自定义：

```javascript
class ValidationError extends Error {
    constructor(message, field) {
        super(message);
        this.name = "ValidationError";
        this.field = field;
    }
}

function validateUser(user) {
    if (!user.name) {
        throw new ValidationError("用户名不能为空", "name");
    }
    if (user.age < 0) {
        throw new ValidationError("年龄不能为负数", "age");
    }
}
```

自定义 Error 的好处是你可以用 `instanceof` 区分不同类型的错误，做有针对性的处理。

### finally 块——总执行

`finally` 最典型的场景是资源清理：

```javascript
function processFile() {
    // 模拟：打开文件
    console.log("文件已打开");

    try {
        // 处理文件...可能出错
        throw new Error("文件格式错误");
    } catch (e) {
        console.log("处理异常：", e.message);
    } finally {
        // 不管是否出错，关闭文件
        console.log("文件已关闭（finally 保证）");
    }
}
```

在 A.26 学 Promise 时，你会发现 `.finally()` 和 `try...finally` 是同样的理念。

### 一个实践建议

不要用 try/catch 去处理"可预见的条件"——用 if/else：

```javascript
// 不好的风格——用异常控制流程
try {
    const user = JSON.parse(input);
} catch {
    user = null;
}

// 好的风格——先判断
const user = input ? JSON.parse(input) : null;
// 但如果 JSON 格式确实可能出错，try/catch 是合适的
```

## 与 C 语言的对比

C 语言没有 try/catch。错误处理全靠返回值检查（`if (result == -1) { perror(...); }`）、`errno` 和 `setjmp/longjmp`（类似异常跳转但极少使用）。JavaScipt 的 try/catch 和 C++ 的异常更接近——可以跨多层函数调用传播，不需要每层都检查返回值。但 JS 的 catch 没有类型筛选，需要手动 instanceof 判断。

## 动手试试

1. 写一个除法函数，除数为 0 时 throw Error
2. 用 try/catch/finally 调用它，在 finally 中打印"计算结束"
3. 自定义一个 `NetworkError` 类（继承 Error），添加 `statusCode` 属性

## 本节小结

- `try` 包裹可能出错的代码，`catch` 处理错误，`finally` 总执行
- JS 的 catch 只有一个参数，需要在内部用 `instanceof` 区分错误类型
- 总是 throw Error 实例（而非字符串），便于调试
- 自定义 Error 类通过 `extends Error` 实现，区分业务错误
- 不要滥用异常控制流程——可预见的条件用 if/else

## 下一节预告

A.25 回调函数——JavaScript 异步编程的"原始形态"。理解回调是理解 Promise 和 async/await 的前提。
