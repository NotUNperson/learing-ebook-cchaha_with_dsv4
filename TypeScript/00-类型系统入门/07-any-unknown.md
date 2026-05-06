# 07 any 与 unknown：类型系统里的"逃生舱"

## 本节你会学到什么

- 理解 `any` 是什么，为什么会有它，以及为什么"尽量不用"
- 掌握 `unknown` 的用法，知道它为什么比 `any` 更安全
- 学会类型收窄——在使用 `unknown` 之前，如何安全地确定它"到底是什么"
- 在 C++ 的体系里找到 `any` 和 `unknown` 的类比（`void*`、`std::any`）

## 正文

前面几节我们一直在讲"变量有明确的类型"——number、string、boolean、枚举。但现实中，你总会遇到"类型不确定"的情况。比如：你从 API 拿到的数据、用户输入的内容、一个你没见过的三方库的返回值。

TypeScript 给了你两个处理这种情况的工具：`any` 和 `unknown`。它们一个像是"万能钥匙"（什么锁都能开，但也容易闯祸），另一个像是"保险柜"（需要先验证身份才能打开）。

### any：关掉了所有类型检查

`any` 字面意思就是"任意类型"。一个 `any` 类型的变量可以做任何事：

```typescript
let something: any = 42;
something = "hello";       // 可以，随便换类型
something = true;          // 可以
something.foo.bar.baz();   // 可以！即使 foo 根本不存在，编译器也不管
```

`any` 做的事情很简单：**把 TypeScript 的类型检查全部关掉**。它就相当于告诉编译器："别管我，我知道我在做什么。"结果就是，如果你对一个 `any` 变量做了一些错误操作，编译阶段不会有任何提示，错误会在运行时炸出来。

**生活类比**：`any` 就像一扇没有任何锁的门。任何人（任何类型的值）都能进来，你想在里面做什么都行——但小偷也能进来。你把安全感（类型安全）完全放弃了。

### C++ 类比：void*

如果你会 C++，可以把 `any` 类比为 C++ 的 `void*`：

```cpp
// C++
void* ptr = &someInt;     // void* 可以指向任何类型
int* p = (int*) ptr;      // 需要手动转换回来，转错了就是未定义行为
```

`void*` 放弃了类型安全，你必须靠自己的记忆和注释来记住"这个东西到底是什么类型"。`any` 也是这样。

C++17 也引入了一个 `std::any`，但它需要先 `std::any_cast<>` 才能使用其中的值——这更像是 TypeScript 的 `unknown`。

### 为什么会有 any？

你不能在所有地方都用 `any` 吗？技术上可以，但那等于"不学 TypeScript，只写 JavaScript"。`any` 存在的原因有两个：

1. **渐进迁移**：你有一个旧的 JavaScript 项目，慢慢加 TypeScript。那些还没加类型的代码，临时用 `any` 标记，后面再改。
2. **确实不知道类型**：某些极端场景下（比如动态 JSON 反序列化），你真正处理的就是"不知道什么类型"的数据。

`any` 是 TypeScript 类型系统的一个"逃生舱"——当你不知道怎么给某个东西标注类型时，可以先用 `any` 逃出去。但优秀 TypeScript 代码的标志之一就是：`any` 出现的次数极少。

### unknown：安全的"不知道"

`unknown` 和 `any` 一样，表示"可以是任何类型"。但有一个关键区别：**在对 `unknown` 做任何操作之前，你必须先"收窄"它的类型**。

```typescript
let data: unknown;

data = "hello";
data = 42;
data = { name: "Alice" };
// 以上都 OK——unknown 可以接受任何值

// 但你不能直接使用它：
// data.toUpperCase();     // 编译错误！data 的类型是 unknown，不一定有 toUpperCase
// data + 1;               // 编译错误！unknown 不能做加法
```

想使用 `unknown` 变量，你必须先通过某种方式确定它到底是什么：

```typescript
let data: unknown = "hello";

// 方式一：typeof 类型收窄
if (typeof data === "string") {
    console.log(data.toUpperCase());  // ✅ 在这个 if 块里，data 是 string
}

// 方式二：instanceof 类型收窄
if (data instanceof Date) {
    console.log(data.getFullYear());  // ✅ 在这个 if 块里，data 是 Date
}

// 方式三：类型断言（小心使用）
let str = data as string;  // 你告诉编译器 "相信我，它是 string"
// 如果 data 其实不是 string，运行时会出错，但编译期不报错
```

**生活类比**：`unknown` 像一个上了锁的快递包裹。快递员把包裹交给你，你不知道里面是什么。在打开之前（类型收窄之前），你什么都不能对包裹做——你不能说"这个包裹可以吃"（调用方法），也不能说"这个包裹很轻"（访问属性）。你必须先用 `typeof` 这把"剪刀"把包裹打开，看到里面到底是什么（是食品、是衣物、是电子设备），然后才能做相应的操作。

### any 的传染性（危险！）

`any` 还有一个危险的特性：**传染性**。一旦你用了 `any`，它就会"污染"和它相关的所有类型：

```typescript
let x: any = "hello";
let y: string = x;  // 这行编译通过！any 污染了 y
// y 的类型标注是 string，但实际上它"吃"了一个 any，
// TypeScript 不会在这里报错，但你失去了类型安全
```

这就像在一桶清水里滴了一滴墨水——整桶水都会被染色。

### 实践建议

| 场景 | 用什么 | 理由 |
|------|--------|------|
| 从 API 拿到 JSON 数据 | `unknown` 然后收窄 | 你不知道后端返回了什么 |
| 旧 JS 代码临时没类型 | `any`（短期），目标是改成具体类型 | 渐进迁移的过渡 |
| 用户输入 | `unknown` 然后验证 | 用户什么都可能输入 |
| JSON.parse 的返回值 | `unknown`（默认就是） | TypeScript 标准库把 JSON.parse 的返回类型标记为 `any`，但你应该把它当成 `unknown` |
| 函数参数实在是"什么都可以" | 重载或用泛型，不是 any | 总有比 any 更好的方案 |

**一句话**：能用具体类型就用具体类型；实在不知道就用 `unknown` 然后收窄；`any` 是你实在没办法时的最后选择。

## 动手试试

1. 声明一个 `any` 类型的变量，依次赋值为数字、字符串、数组。然后调用一个不存在的方法（如 `.fly()`），看编译器会不会报错。
2. 声明一个 `unknown` 类型的变量，赋值为 `"hello world"`。尝试直接调用 `.toUpperCase()`，看编译器报什么错。
3. 用 `typeof` 类型收窄，在 `if` 分支里安全地使用这个 `unknown` 变量。
4. 模拟处理 API 返回值：写一个函数 `function processApiResponse(data: unknown): string`，在里面用 `typeof` 判断 data 是 string 还是 number，分别返回不同格式的字符串。
5. 声明一个 `any` 变量 `x`，然后 `let y: string = x`，看编译器是否允许——理解 `any` 的传染性。

## 本节小结

`any` 关掉所有类型检查，写起来方便但失去了安全网；`unknown` 是安全的"不知道"，在使用前必须用 `typeof` 或 `instanceof` 收窄类型——日常代码中应该优先选 `unknown`。

## 下一节预告

`unknown` 收窄用的是 `typeof` 判断分支。这带出一个更强大的概念：一个变量可以"是这种类型，也可以是那种类型"。下一节我们正式学**联合类型**和**类型别名**。
