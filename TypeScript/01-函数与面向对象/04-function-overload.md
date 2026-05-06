# 04 函数重载

## 本节你会学到什么

- 理解 TypeScript 函数重载的"多重签名 + 单一实现"模式
- 写出有多个调用签名的函数
- 对比 C++ 函数重载与 TypeScript 的异同
- 知道什么时候需要用函数重载，什么时候不需要
- 理解实现签名的参数类型必须兼容所有调用签名

## 正文

### 一个函数，多种调用方式

先看一个真实场景：你在写一个函数叫 `getInfo`，它可能接收一个数字 ID，也可能接收一个名字字符串。两种情况下返回的结果格式也不同。

用之前学到的联合类型可以这样写：

```typescript
function getInfo(id: number | string): string | object {
    if (typeof id === "number") {
        return `用户 #${id}`;
    } else {
        return { name: id, id: Math.random() };
    }
}
```

这个写法能跑，但有一个问题：TypeScript 不知道传入 `number` 和传入 `string` 后，返回值分别是什么类型。当你写：

```typescript
const result = getInfo(42);
// result 的类型是 string | object，TypeScript 不知道应该是 string 还是 object
```

每次使用 result 之前都要做类型判断，很麻烦。这就是函数重载要解决的问题。

### TypeScript 函数重载："菜单"和"厨房"

把 TypeScript 的函数重载想象成一家餐厅：

- **菜单**上写着："牛肉面，小份 15 元"、"牛肉面，大份 20 元"。顾客看菜单就知道点什么、花多少钱。
- **厨房**里只有一个做面的师傅，他根据订单来操作——小份少了面，大份多了面，但做的流程是一样的。

在 TypeScript 中，**菜单 = 重载签名**，**厨房 = 实现签名**。

```typescript
// 重载签名 1（菜单第一行）：传入数字，返回字符串
function getInfo(id: number): string;

// 重载签名 2（菜单第二行）：传入字符串，返回对象
function getInfo(name: string): object;

// 实现签名（厨房）：真正干活的函数，类型范围必须覆盖所有重载签名
function getInfo(input: number | string): string | object {
    if (typeof input === "number") {
        return `用户 #${input}`;
    } else {
        return { name: input, id: Math.floor(Math.random() * 10000) };
    }
}

// 现在 TypeScript 知道了：
const a = getInfo(42);        // a 的类型是 string（精确！）
const b = getInfo("张三");    // b 的类型是 object（精确！）
```

关键点在于：
1. **重载签名**写在实现签名的正上方，只有参数和返回值类型，没有函数体
2. **实现签名**是所有重载签名的"并集"，参数类型和返回值类型必须能覆盖所有重载签名
3. **调用时**只能匹配重载签名，实现签名对调用者不可见

### 和 C++ 函数重载的对比

C++ 程序员对函数重载应该很熟：

```cpp
// C++ 重载：每个版本都有独立的函数体
int add(int a, int b)        { return a + b; }
double add(double a, double b) { return a + b; }
```

| 对比项 | C++ | TypeScript |
|--------|-----|------------|
| 实现方式 | 多个独立函数体 | 一个实现函数体 |
| 类型检查 | 编译时根据参数类型匹配 | 编译时根据重载签名匹配 |
| 重载数量 | 没有限制 | 没有硬性限制，但太多会降低可读性 |
| 返回值类型 | 可以不同但不能仅靠返回值区分 | 可以不同 |
| 底层机制 | 名称修饰（name mangling） | 纯类型层面，运行时不区分 |

最重要的区别：**C++ 的每个重载是独立的函数**（编译后名字都不一样），**TypeScript 的重载是纯类型层面的**——运行时只有一个函数，重载签名为的是获得精确的类型推断。

### 什么时候需要重载？

重载的核心价值是：**同一个函数，不同参数组合对应不同的返回值类型**。如果只是参数类型不同但返回值类型相同，联合类型就够了：

```typescript
// 不需要重载——用联合类型就够了
function log(value: string | number): void {
    console.log(value);
}

// 需要重载——参数类型影响了返回值类型
function convert(value: number): string;
function convert(value: string): number;
function convert(value: number | string): number | string {
    if (typeof value === "number") {
        return value.toString();
    } else {
        return parseInt(value, 10);
    }
}
```

在 `convert` 的例子中，输入 `number` 返回 `string`，输入 `string` 返回 `number`。如果不用重载，返回值类型只能是 `number | string`，丢失了对应关系。

### 重载签名的顺序很重要

TypeScript 会从上到下匹配重载签名。把更具体的签名放在上面，更宽泛的放在下面：

```typescript
// 好：具体在前
function process(input: string): string;  // 先匹配 string
function process(input: number): number;  // 再匹配 number
function process(input: string | number): string | number { /* ... */ }

// 不好：宽泛在前会吞掉后面的匹配
// 如果有一个 any 类型的重载放在第一行，后面都白写了
```

### 另一个例子：日期格式化

```typescript
// 重载签名：不同参数，不同返回
function formatDate(timestamp: number): string;           // 时间戳 → 日期字符串
function formatDate(date: Date): string;                  // Date 对象 → 日期字符串
function formatDate(year: number, month: number, day: number): string; // 年月日 → 日期字符串

// 实现签名
function formatDate(
    arg1: number | Date,
    arg2?: number,
    arg3?: number
): string {
    if (arg1 instanceof Date) {
        return `${arg1.getFullYear()}-${arg1.getMonth() + 1}-${arg1.getDate()}`;
    } else if (arg2 !== undefined && arg3 !== undefined) {
        return `${arg1}-${arg2}-${arg3}`;
    } else {
        const date = new Date(arg1);
        return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
    }
}
```

这里三个重载签名为同一个函数提供了三种不同的调用方式，每种都返回 string。这是重载的经典应用场景。

## 动手试试

写一个 `calculate` 函数的重载：

1. 接收两个 `number` 和一个操作符 `"add" | "subtract" | "multiply" | "divide"`，返回 `number`
2. 接收一个 `number` 数组，返回这些数的总和 `number`
3. 接收一个字符串计算表达式如 `"3+5"`，返回计算结果 `number`

提示：实现签名需要处理三种情况，用 `typeof` 和 `Array.isArray` 来区分。

## 本节小结

TypeScript 函数重载 = 多个类型签名 + 一个实现，和 C++ 的"每个重载一个独立函数体"不同，本质上是在编译时做更精确的类型分发。

## 下一节预告

下一节我们正式进入面向对象的世界，学习 TypeScript 的 class 语法——构造函数、this、访问修饰符，看看和 C++ 的 class 有什么不同。
