# 03 泛型接口与泛型类

## 本节你会学到什么

- 将泛型思想从函数扩展到接口和类
- 用 `interface Box<T>` 定义通用的容器接口
- 用 `class Stack<T>` 实现类型安全的数据结构
- 对比 C++ 的模板类，理解异同
- 理解泛型的"传染性"：一个用泛型的类，它的方法也可以用同一个 T

## 正文

上一节我们学会了泛型函数。但泛型不止可以用在函数上——它可以用在任何需要"通用化类型"的地方，包括接口和类。

### 生活类比：快递盒

想象你网购了一个手机，快递公司用纸盒包装好送给你。下次你买了一本书，快递公司还是用纸盒包装。盒子的大小可能不同，但盒子的结构是一样的：有六个面，可以封口，可以写地址。

在编程里，这个"纸盒"就是一个泛型容器。盒子里装的东西（手机、书、衣服）就是泛型参数 `T`。盒子的操作——装东西、取东西、检查是否空的——不关心里面具体是什么，只关心"有没有东西"。

### 泛型接口

泛型接口就是用 `<T>` 声明一个类型变量，在接口内部使用它：

```typescript
// 一个通用的盒子接口
interface Box<T> {
  content: T;                    // 盒子里的东西，类型是 T
  put(item: T): void;            // 放东西进去
  take(): T;                     // 取东西出来
}
```

现在我们用不同的 `T` 来"实例化"这个接口：

```typescript
const numberBox: Box<number> = {
  content: 42,
  put(item) { this.content = item; },
  take() { return this.content; },
};

const stringBox: Box<string> = {
  content: "hello",
  put(item) { this.content = item; },
  take() { return this.content; },
};
```

`Box<number>` 里所有用到 `T` 的地方都变成了 `number`，`Box<string>` 里都变成了 `string`。同一个接口定义，根据传入的 `T` 不同，产生不同的具体类型。

### 泛型类

泛型类的思路一样。以"栈"为例——一种后进先出的数据结构，就像一叠盘子，你只能取最上面的那个：

```typescript
class Stack<T> {
  private items: T[] = [];       // 内部用数组存数据

  push(item: T): void {
    this.items.push(item);        // 压入一个 T 类型的元素
  }

  pop(): T | undefined {
    return this.items.pop();      // 弹出一个 T 类型的元素
  }

  peek(): T | undefined {
    return this.items[this.items.length - 1]; // 看一眼最上面的
  }

  get size(): number {
    return this.items.length;     // getter，返回栈的大小
  }
}
```

使用起来很直观：

```typescript
const numberStack = new Stack<number>();
numberStack.push(1);
numberStack.push(2);
numberStack.push(3);
console.log(numberStack.pop()); // 3
console.log(numberStack.pop()); // 2

const stringStack = new Stack<string>();
stringStack.push("hello");
stringStack.push("world");
// stringStack.push(42);         // 编译错误！不能往 string 栈里塞数字
```

注意最后一行的注释：`Stack<string>` 的 `push` 方法只接受 `string`。你不可能往一个字符串栈里塞数字——这就是泛型带来的类型安全。

### 泛型接口继承

泛型接口可以被继承，继承时可以保持泛型，也可以"固定"泛型参数：

```typescript
// 保持泛型：SafeBox<T> 也是一个泛型接口
interface SafeBox<T> extends Box<T> {
  isLocked: boolean;
  lock(): void;
  unlock(code: string): boolean;
}

// 固定泛型：NumberBox 不再有泛型参数，它就是一个专门装数字的盒子
interface NumberBox extends Box<number> {
  sum(): number;
}
```

### 和 C++ 的对比

C++ 的模板类是最接近 TS 泛型类的概念：

```cpp
// C++ 版本
template<typename T>
class Stack {
private:
    std::vector<T> items;
public:
    void push(T item) { items.push_back(item); }
    T pop() { /* ... */ }
};
```

**相同点：**
- 都是用 `<T>` 声明类型参数
- 都是在实例化时确定具体类型（`Stack<int>` vs `new Stack<number>()`）
- 都保证类型安全——只能往 `Stack<int>` 里放 `int`

**不同点：**
- C++ 的模板类对不同类型生成**完全独立的类**（`Stack<int>` 和 `Stack<string>` 是运行时完全不同的类型）。TS 泛型在编译后是**同一个类**，类型信息被擦除
- C++ 模板支持偏特化（对某些类型做特殊处理），TS 不支持
- TS 泛型类可以配合接口使用类型约束（`class Stack<T extends HasId>`），C++ 用 concept 或 SFINAE 实现类似功能

### 现实中的例子：Result 类型

很多项目中会定义一个通用的"结果"类型，用来表示操作是否成功：

```typescript
interface Result<T> {
  success: boolean;
  data?: T;         // 成功时携带的数据
  error?: string;   // 失败时的错误信息
}

function parseJSON<T>(json: string): Result<T> {
  try {
    const data = JSON.parse(json) as T;
    return { success: true, data };
  } catch (e) {
    return { success: false, error: String(e) };
  }
}
```

`Result<T>` 是一个"壳子"，不管 `T` 是什么，它都能包裹起来，并提供统一的操作成功/失败信息。就像快递信封——不管里面装的是合同、支票还是明信片，信封本身的格式是一样的。

## 动手试试

1. 定义一个泛型类 `Queue<T>`（队列），有 `enqueue`（入队）、`dequeue`（出队）、`peek`（查看队首）、`size`（大小）四个成员
2. 创建一个 `Queue<number>`，入队 1、2、3，然后依次出队，打印结果（应该是 1、2、3，因为队列是先进先出）
3. 创建一个 `Queue<string>`，入队 "a"、"b"、"c"，测试同样流程

答案参考 `examples/03-generic-interfaces.ts`。

## 本节小结

泛型接口和泛型类让你可以创建类型安全的通用容器，就像快递公司的包装盒——结构一样，里面装的东西可以五花八门。

## 下一节预告

有时候一个变量可能是多种类型中的一种。下一节学习类型守卫，告诉 TypeScript 如何在代码中精确判断"它现在到底是什么类型"。
