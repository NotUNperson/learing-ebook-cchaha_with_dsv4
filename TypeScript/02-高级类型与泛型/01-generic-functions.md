# 01 泛型函数

## 本节你会学到什么

- 理解为什么需要泛型：避免重复代码和丧失类型安全
- 掌握 TypeScript 泛型函数的 `<T>` 语法
- 将泛型与 C++ 的 `template<typename T>` 做对比，快速衔接
- 看懂编译器如何根据调用参数"自动推断"类型参数
- 写出自己的第一个泛型工具函数

## 正文

想象你去超市买饮料。超市有一个自动售货机，它有一个投放口和一个取物口。不管你投进去的是可乐、雪碧还是矿泉水，售货机的工作流程都一样：接收瓶子，制冷，等你来取。售货机不需要为每种饮料单独造一台机器——它只需要一个"通用的"机械结构。

这个售货机就是一个**泛型**。它处理的不是具体是哪一种饮料，而是"某种饮料"这个抽象概念。

在编程里，我们经常遇到类似的场景。比如你想写一个函数，接收一个数组，返回数组的第一个元素：

```typescript
// 如果不用泛型，你可能会这样写：
function firstNumber(arr: number[]): number {
  return arr[0];
}

function firstString(arr: string[]): string {
  return arr[0];
}

function firstBoolean(arr: boolean[]): boolean {
  return arr[0];
}
```

三种函数逻辑完全一样，唯一的区别就是类型。这就像为可乐、雪碧、矿泉水各造一台售货机，显然很蠢。更糟糕的是，如果有人传进来一个 `User[]`，你得再写一个新的函数。

另一个选择是用 `any`：

```typescript
function firstAny(arr: any[]): any {
  return arr[0];
}
```

这样确实省事了，但你丢掉了类型安全。`firstAny([1, 2, 3])` 的返回值是 `any`，编译器不知道它是 `number`，你后面调用 `.toFixed()` 它也不会报错——即使可能出问题。

泛型就是解决这个困境的方案。它让你写一个函数，既通用又类型安全：

```typescript
function first<T>(arr: T[]): T {
  return arr[0];
}
```

`<T>` 里的 `T` 是一个**类型变量**，就像一个占位符。调用函数时，TypeScript 会根据你传入的实参自动"推导"出 `T` 是什么：

```typescript
const n = first([1, 2, 3]);     // T 被推导为 number，n 的类型是 number
const s = first(["a", "b"]);     // T 被推导为 string，s 的类型是 string
```

### 和 C++ 的对比

如果你学过 C++ 的模板，这个你应该很熟悉：

```cpp
// C++ 版本
template<typename T>
T first(const std::vector<T>& arr) {
    return arr[0];
}
```

**相同点：**
- 都是在定义时用一个占位符 `T` 代表"待定的类型"
- 都是在调用时由编译器自动推导 `T` 的具体类型
- 都避免了为每种类型重复写代码

**不同点：**
- C++ 模板是在编译期对每种用到的类型各生成一份代码（模板实例化），TypeScript 泛型则是"擦除"的——编译后的 JavaScript 里没有 `T`，只有一份代码
- C++ 的 `template` 可以处理值参数（如 `template<int N>`），TypeScript 的泛型只能处理类型
- TypeScript 的泛型推断更"懒"也更智能：你不写 `<number>` 它也能猜出来；C++ 的函数模板虽然也能推导，但遇到复杂情况经常需要显式指定

### 多个类型参数

泛型函数可以有多个类型参数。想象你有一台分类机，它把两种不同的物品配对放一起：

```typescript
function makePair<A, B>(first: A, second: B): [A, B] {
  return [first, second];
}

const pair = makePair("hello", 42);  // pair 的类型是 [string, number]
```

### 泛型不仅仅用于数组

泛型可以用在任何需要"通用化类型"的地方。比如一个简单的缓存工具：

```typescript
function cache<T>(key: string, value: T): { key: string; value: T } {
  return { key, value };
}
```

不管你存的是数字、字符串还是对象，这个函数都能正确处理，并且返回值保持了精确的类型信息。

### 手动指定类型参数

虽然大多数时候 TypeScript 能自动推导，有时你也需要手动指定：

```typescript
function createArray<T>(length: number, fill: T): T[] {
  return new Array(length).fill(fill);
}

// 手动指定 T 为 string
const names = createArray<string>(3, "hello");
// names 的类型是 string[]
```

## 动手试试

1. 写一个泛型函数 `last<T>`，接收一个 `T[]`，返回最后一个元素
2. 写一个泛型函数 `swap<T>`，接收一个 `[T, T]` 元组，返回交换后的 `[T, T]`
3. 调用这两个函数，分别传 `number[]` 和 `string[]`，用鼠标悬停在返回值上看类型推断是否正确

答案参考 `examples/01-generic-functions.ts`。

## 本节小结

泛型让函数既能处理多种类型，又保持严格的类型安全——就像一台能处理各种饮料的通用售货机。

## 下一节预告

泛型参数也可以有限制条件。下一节我们学习泛型约束，告诉 TypeScript "T 必须满足某些条件"。
