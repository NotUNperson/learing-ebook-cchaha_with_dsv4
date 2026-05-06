# 05 数组与元组

## 本节你会学到什么

- 用 `number[]` 和 `Array<number>` 两种语法声明数组
- 理解 TypeScript 数组和 C++ 的 `std::vector` 的异同
- 掌握元组（tuple）的概念，知道它和 C++ 元组的区别
- 学会数组的常用操作（push、pop、map、filter）以及类型检查如何保护它们

## 正文

单个变量只能存一个值，实际编程中我们几乎总是在处理一组数据。这一节我们来学 TypeScript 怎么管理"一组东西"。

### 数组：TypeScript 的"vector"

在 C++ 里，如果你需要一个动态大小的容器，你会用 `std::vector`：

```cpp
std::vector<int> scores = {100, 95, 80};
scores.push_back(60);
```

在 TypeScript 里，等价的东西叫**数组**。有两种写法，效果完全一样：

```typescript
// 写法一：类型后面加 []（最常用）
let scores: number[] = [100, 95, 80];

// 写法二：泛型写法（从 Java/C++ 模板来的思路）
let scores2: Array<number> = [100, 95, 80];
```

大多数人用第一种写法（`number[]`），因为它更短、读起来也更自然："number 的数组"。第二种写法（`Array<number>`）在需要更复杂的泛型表达时会用到，后面遇到再细说。

数组的常用操作：

```typescript
let fruits: string[] = ["apple", "banana"];

fruits.push("orange");        // 尾部插入，类似 C++ 的 push_back
fruits.pop();                 // 尾部删除并返回，类似 C++ 的 pop_back
fruits.unshift("grape");      // 头部插入，类似 C++ 的 insert(0, ...)
fruits.shift();               // 头部删除，C++ vector 没有直接对应
let first = fruits[0];        // 下标访问，类型是 string
let length = fruits.length;   // 长度，注意不是 .size()
```

**生活类比**：数组就像快递驿站的一整排储物柜。每个柜子（数组元素）的尺寸是一样的，只能放同一种类型的包裹（一个 `number[]` 的数组只能放数字）。你可以打开任意一个柜子（`arr[3]`）、往最后加一个柜子（`push`）、移除最后一个柜子（`pop`）。

### TypeScript 数组 vs C++ vector 的区别

| 特性 | C++ std::vector | TypeScript 数组 |
|------|-----------------|-----------------|
| 声明语法 | `vector<int> v;` | `let v: number[];` |
| 尾部插入 | `push_back(x)` | `push(x)` |
| 尾部删除 | `pop_back()` | `pop()` |
| 大小 | `.size()` | `.length`（是属性不是函数） |
| 下标访问 | `v[0]` | `arr[0]` |
| 越界访问 | 未定义行为（危险！） | 返回 `undefined`（更安全） |
| 存储 | 当类型是 `int` 时，存的是值 | 引用类型，数组中存的是引用 |
| 混合类型 | 模板参数限定，所有元素同一类型 | 如果不标注，可推断为联合类型 |

一个重要的运行时差异：在 C++ 里访问 `v[100]`（数组越界）是**未定义行为**，程序可能崩溃、可能不崩、可能产生奇怪的结果——非常危险。在 TypeScript 里，`arr[100]` 合法地返回 `undefined`，程序不会崩溃，只是你拿到了一个 `undefined`。这更安全，但也意味着你要自己检查下标是否在范围内。

### 数组的高阶操作：map 和 filter

C++ 也有类似的东西（通过 `<algorithm>` 头文件），但 TypeScript 的数组方法用起来更自然：

```typescript
let numbers: number[] = [1, 2, 3, 4, 5];

// map：把每个元素都"映射"成一个新值，返回新数组
let doubled = numbers.map(n => n * 2);
// doubled = [2, 4, 6, 8, 10]

// filter：保留满足条件的元素，返回新数组
let evens = numbers.filter(n => n % 2 === 0);
// evens = [2, 4]

// find：找第一个满足条件的元素
let found = numbers.find(n => n > 3);
// found = 4
```

这里的 `n => n * 2` 叫**箭头函数**（也叫 lambda），相当于 C++ 的 `[](int n) { return n * 2; }`，但语法更短。我们后面会专门讲函数，现在知道它能用就行。

### 元组（Tuple）：知道每个位置是什么类型的数组

数组要求所有元素都是同一种类型。但有时候你需要一个"混合类型但是位置固定的"数据结构。比如，表示一个二维坐标 `[x, y]`，x 是 number，y 也是 number，但这个是 2 个元素的固定结构。

更常见的需求是表示数据库的一行——比如一个用户记录：`[id, name, isVip]`，id 是 number，name 是 string，isVip 是 boolean。这就是**元组**的用武之地：

```typescript
// 元组：每个位置有独立的类型
let user: [number, string, boolean] = [1, "Alice", true];

let id = user[0];     // 类型是 number
let name = user[1];   // 类型是 string
let vip = user[2];    // 类型是 boolean
```

TypeScript 知道第 0 个元素是 number、第 1 个是 string、第 2 个是 boolean。如果你写 `user[0] = "hello"`，编译器会报错，因为它期待第 0 个位置是 number。

**生活类比**：元组就像是填好的表格的一行。第一列是"编号"（数字）、第二列是"姓名"（文字）、第三列是"是否VIP"（打勾/不打勾）。每一列的格式是固定的，不能在第一列填名字。

### TypeScript 元组 vs C++ 元组

```cpp
// C++ 元组（C++11 引入）
std::tuple<int, string, bool> user = {1, "Alice", true};
auto id = std::get<0>(user);     // 用序号访问
auto name = std::get<1>(user);
```

```typescript
// TypeScript 元组
let user: [number, string, boolean] = [1, "Alice", true];
let id = user[0];   // 直接用下标访问
let name = user[1];
```

关键区别：
1. TypeScript 的元组在**运行时就是普通的 JavaScript 数组**。类型信息只在编译期存在。C++ 的 `std::tuple` 是一个真正的独立类型，在内存布局上和数组完全不同。
2. TypeScript 的元组用下标访问，C++ 的用 `std::get<N>()` 模板函数访问。
3. TypeScript 的元组可以调用数组的方法（如 `push`），C++ 的不能。

一个需要注意的陷阱：TypeScript 的元组在**编译期之后**就是普通数组，所以 `user.push(999)` 在运行时是可以的，但 TypeScript 编译器会尽量阻止你这样做（取决于 TS 版本和配置）。

## 动手试试

1. 声明一个 `number[]` 数组，包含 5 个分数。用 `push` 加一个分数，用 `pop` 移除最后一个，打印每一步的结果。
2. 用 `map` 把每个分数加 10 分，打印新数组。用 `filter` 筛选出大于 60 分的分数。
3. 声明一个元组 `let point: [number, number] = [10, 20]`，尝试访问 `point[0]` 和 `point[1]`。尝试写 `point[2]`，看 IDE 有没有警告。
4. 声明另一个元组表示日期：`[number, string, number]` 表示 `[年, 月（英文缩写）, 日]`，比如 `[2024, "Jan", 15]`。

## 本节小结

数组存同类型数据（`number[]` 类似 C++ 的 `vector<int>`），元组存固定位置不同类型的数据（类似 C++ 的 `std::tuple` 但运行时就是数组）；数组的 `map`/`filter` 让数据变换非常方便。

## 下一节预告

数组和元组都是运行时数据结构。下一节我们学一个"只在编译期有意义"的东西——枚举（enum），看看它是不是真的和 C++ 的 enum 一样。
