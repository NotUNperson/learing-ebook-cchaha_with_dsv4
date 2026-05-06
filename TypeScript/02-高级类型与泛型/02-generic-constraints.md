# 02 泛型约束

## 本节你会学到什么

- 理解为什么有时需要限制泛型参数的范围
- 掌握用 `extends` 关键字给泛型加约束
- 理解"约束"不是限制自由，而是保证安全
- 将 TS 的 `extends` 约束与 C++ 的 `concept`/`requires` 做对比
- 学会用类型参数自身做约束（`K extends keyof T` 等）

## 正文

上一节我们学会了 `<T>`——泛型让函数能处理任意类型。但有时候，"任意类型"太宽了。

想象你要用一台榨汁机。榨汁机不是万能机器——你往里扔石头它就会坏。榨汁机能处理的东西有一个约束：**必须是水果**。苹果、橙子、西瓜都可以，但石头不行。

TypeScript 的泛型也是一样。有时候你的函数依赖某个类型"有某个属性"或"有某个方法"，你就需要告诉 TypeScript 这个约束，让它在调用时就检查，而不是等到运行时才发现问题。

### 一个需要约束的场景

比如你写一个函数，接收一个对象，返回它的 `length` 属性：

```typescript
function getLength<T>(obj: T): number {
  return obj.length; // 编译错误！T 类型上不存在属性 "length"
}
```

TypeScript 拒绝编译。因为 `T` 可以是任何类型——`number`、`boolean`，这些东西都没有 `length`。

怎么解决？用 `extends` 加约束：

```typescript
function getLength<T extends { length: number }>(obj: T): number {
  return obj.length; // 现在 OK 了！
}
```

`T extends { length: number }` 的意思是：T 可以是任何类型，但它必须"拥有" `length: number` 这个属性。就像榨汁机的入口大小决定了能放进来的水果的尺寸上限。

现在：

```typescript
getLength("hello");        // OK，string 有 length
getLength([1, 2, 3]);      // OK，数组有 length
getLength({ length: 10 }); // OK，对象有 length 属性
// getLength(123);          // 编译错误！number 没有 length
```

### 形象类比：插头和插座

不同电器的插头必须符合国家标准的插座形状才能通电。这个"标准插座形状"就是一个约束。TypeScript 的 `extends` 约束就是这个标准——你的类型必须"长得像"某个形状。

```typescript
// 约束：T 必须是一个有 name 属性的对象（即"长得像" { name: string }）
function greet<T extends { name: string }>(obj: T): string {
  return `你好，${obj.name}！`;
}

greet({ name: "小明", age: 18 }); // OK，有 name 就行，多出来的属性无所谓
// greet({ age: 18 });            // 编译错误！没有 name 属性
```

### 用类型参数做约束

约束还可以用另一个类型参数的属性来限制：

```typescript
// K 必须能作为 T 的 key 来使用
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

这就像你有一串钥匙（K），但你只能拿这把钥匙去开对应的锁（T 的某个属性）。你不能拿车钥匙去开房门。

```typescript
const user = { id: 1, name: "张三", email: "zhang@example.com" };

getProperty(user, "name");  // 返回 "张三"，类型是 string
// getProperty(user, "age"); // 编译错误！"age" 不是 user 的 key
```

### 和 C++ 的对比

C++20 引入了 concept，可以给模板参数加约束：

```cpp
// C++20 写法
#include <concepts>

template<typename T>
  requires std::integral<T>   // T 必须是整数类型
T add(T a, T b) {
    return a + b;
}
```

**相同点：**
- 都是给泛型/模板参数加限制条件
- 都是在编译期拒绝不符合条件的调用
- 都能让错误信息更清楚（在调用处报错，而不是在函数体内某个深层调用处报错）

**不同点：**
- TypeScript 的约束基于**结构类型**（只要长得像就行，不要求继承关系），C++ 的 concept 更像**名义类型检查**和编译期谓词
- TS 的 `extends` 既可以做约束也可以做条件类型（后面会学），C++ 的 `requires` 只用于约束
- TS 的约束是声明式的、比较直观；C++ 的 concept 功能更强但更复杂

### 多重约束

有时需要 T 同时满足多个条件，用 `&` 连接：

```typescript
interface HasName {
  name: string;
}

interface HasAge {
  age: number;
}

// T 必须同时有 name 和 age
function introduce<T extends HasName & HasAge>(person: T): string {
  return `${person.name} 今年 ${person.age} 岁。`;
}
```

### 约束的"洋葱"心态

约束就像一个洋葱——你一层层剥开，发现里面可以放任何满足要求的东西。约束不是限制自由，而是**保证进来的东西不会让你的函数崩溃**。这就像餐厅的后厨：进来的食材必须符合食品安全标准，但具体是鸡肉、牛肉还是豆腐，取决于当天菜单。

## 动手试试

1. 写一个泛型函数 `longest<T extends { length: number }>`，接收两个参数，返回 `length` 更大的那个
2. 用 `string` 测试：传入 `"hi"` 和 `"hello"`，应该返回 `"hello"`
3. 用数组测试：传入 `[1, 2]` 和 `[3, 4, 5]`，应该返回 `[3, 4, 5]`
4. 试试传入 `number`（如 `longest(3, 5)`），看编译器报什么错

答案参考 `examples/02-generic-constraints.ts`。

## 本节小结

`extends` 约束让泛型从"任意类型"变成"满足条件的类型"，就像给榨汁机装了尺寸合适的入口，只允许水果通过。

## 下一节预告

泛型不仅能在函数上用。下一节我们把它搬到接口和类上，创建通用的容器类型。
