# 01 函数声明与类型签名

## 本节你会学到什么

- 写出带有参数类型标注的 TypeScript 函数
- 标注函数的返回值类型
- 理解 TypeScript 函数声明与 C++ 函数声明的核心区别
- 看懂 TypeScript 的类型签名（type signature）表示法
- 知道类型推断在函数返回值上的表现

## 正文

### 函数，你并不陌生

如果你写过 C++，函数对你来说已经是老朋友了。C++ 里的函数长这样：

```cpp
int add(int a, int b) {
    return a + b;
}
```

TypeScript 的函数和 C++ 长得非常像，几乎可以无缝切换。来看一个等价的 TypeScript 版本：

```typescript
function add(a: number, b: number): number {
    return a + b;
}
```

是不是看着眼熟？让我们来拆解一下。

### TypeScript 函数声明的构成

想象你在餐厅点餐。你告诉服务员："我要一碗牛肉面，大份的"。这就是一个"函数调用"——你给服务员输入信息（菜品名、规格），服务员给你输出结果（一碗面）。菜单上写的"牛肉面：小份/大份，价格 XX 元"就是"函数签名"——它规定了输入是什么类型、输出是什么类型。

TypeScript 的函数签名包含两个核心部分：

**1. 参数的类型标注**

每个参数后面用冒号 `:` 标注类型。就像菜单上写清楚"大份还是小份"，TypeScript 要求你写清楚参数是什么类型：

```typescript
function greet(name: string, age: number) {
    console.log(`${name} 今年 ${age} 岁了`);
}
```

这里 `name: string` 就是说"name 这个参数必须是字符串"，`age: number` 意思是"age 这个参数必须是数字"。如果你调用时传错了类型，TypeScript 会直接在编辑器里给你标红——就像餐厅服务员告诉你"我们没有'蓝色'这种口味"。

**2. 返回值的类型标注**

参数列表后面的 `: number` 是返回值类型。这告诉 TypeScript（也告诉读代码的人）：这个函数会返回一个数字。

```typescript
function multiply(x: number, y: number): number {
    return x * y;
}
```

如果你忘了写 `return`，或者 `return` 了一个字符串，TypeScript 会报错。这就像你点了一碗面，厨房不能给你上一盘饺子——类型不对。

### 和 C++ 的对比

| 特性 | C++ | TypeScript |
|------|-----|------------|
| 参数类型位置 | `int add(int a, int b)` | `add(a: number, b: number)` |
| 返回值类型位置 | 函数名前 | 参数列表后 |
| 类型推断 | C++11 有 `auto` | TypeScript 可以自动推断返回值类型 |
| 编译检查 | 编译时报错 | 编辑时实时报错 |

最明显的差异是类型标注的位置。C++ 把类型写在变量名前面（`int a`），TypeScript 把类型写在变量名后面，用冒号隔开（`a: number`）。

你可以把 TypeScript 的这种写法理解为："变量 a，它的类型是 number"——语序更像自然语言。

### 返回值类型可以省略吗？

可以。TypeScript 很聪明，它能根据 `return` 语句自动推断返回值类型：

```typescript
function add(a: number, b: number) {  // 没写返回值类型
    return a + b;  // TypeScript 推断出返回值是 number
}

const result = add(1, 2);  // result 的类型被推断为 number
```

但是，**建议你始终显式标注返回值类型**。原因很简单：如果你原本想返回 `number`，但不小心写错了逻辑返回了别的类型，显式标注能让 TypeScript 立刻发现这个问题。就像你出门前看一眼门牌号，比走错了再回头要省时间。

### void 类型

如果函数不返回任何值（就像 C++ 里的 `void`），TypeScript 用 `void` 标注：

```typescript
function logMessage(msg: string): void {
    console.log(msg);
    // 没有 return 语句
}
```

这和 C++ 的 `void` 概念完全一样，只是位置换到了参数列表后面。

### 类型签名（Type Signature）表示法

当你阅读 TypeScript 文档或别人的代码时，经常会看到这样的写法：

```
(a: number, b: number) => number
```

这就是**类型签名**——函数的"身份证"。它只描述参数类型和返回值类型，不包含函数体。拆解来看：

- `(a: number, b: number)` 是参数列表，每个参数带类型
- `=> number` 表示返回值是 `number`

注意这里的 `=>` 和箭头函数的 `=>` 长得一样但含义不同。在类型签名中，`=>` 只是"返回"的意思。你可以在变量声明中使用：

```typescript
// 声明一个变量，它的类型是"接收两个数字、返回一个数字的函数"
let myFunc: (a: number, b: number) => number;

// 然后可以把符合这个签名的函数赋值给它
myFunc = function add(x: number, y: number): number {
    return x + y;
};
```

这就像是先定义了一个"岗位要求"（类型签名），然后再找一个符合要求的人来上岗（赋值函数）。

## 动手试试

写一个函数 `calculateArea`，接收两个参数：`width: number` 和 `height: number`，返回 `number` 类型的面积。

1. 先写出带完整类型标注的版本（参数 + 返回值都标注）
2. 再写一个省略返回值类型标注的版本，观察 TypeScript 是否能正确推断
3. 故意传一个字符串参数进去，看看编辑器报什么错

提示：在 VS Code 中运行 `tsc --noEmit` 可以只检查类型而不生成 JS 文件。

## 本节小结

TypeScript 函数声明和 C++ 很相似，只是类型标注放在参数和返回值后面，用冒号连接，这种"后置标注"的方式读起来更接近自然语言。

## 下一节预告

下一节我们学习如何让函数的参数变得更灵活——可选参数、默认值和可变数量的参数，让一个函数适应更多使用场景。
