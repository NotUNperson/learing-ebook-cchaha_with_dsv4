# 02 可选参数、默认参数与剩余参数

## 本节你会学到什么

- 用 `?` 标记函数的可选参数
- 用 `=` 给参数设置默认值
- 用 `...` 收集任意数量的参数（剩余参数）
- 对比 C++ 中对应的概念（默认参数、可变参数）
- 知道可选参数必须放在必选参数后面

## 正文

### 参数不够用？让函数更灵活

上一节我们写的函数，每个参数都是"必须填"的——少一个都不行。这就像你去便利店买东西，店员非要你把家庭住址也填了才卖给你一瓶水——太死板了。

现实中的函数常常需要灵活处理："这个参数大多数情况用默认值就行，只有特殊情况才需要改"，或者"我不确定用户会传几个参数进来"。TypeScript 提供了三种机制来应对这些场景：可选参数、默认参数、剩余参数。

### 可选参数：用 `?` 表示"可以不来"

想象你去咖啡店点咖啡。你可以说"一杯拿铁"，也可以说"一杯拿铁，加糖"。糖是可选的——不说不加，说了才加。

在 TypeScript 中，在参数名后面加一个问号 `?`，这个参数就变成了可选的：

```typescript
function orderCoffee(type: string, sugar?: boolean): string {
    if (sugar) {
        return `一杯${type}，加糖`;
    }
    return `一杯${type}`;
}

console.log(orderCoffee("拿铁"));         // 一杯拿铁
console.log(orderCoffee("拿铁", true));   // 一杯拿铁，加糖
```

注意，可选参数内部的值可能为 `undefined`（用户没传）。所以你在函数体里使用可选参数前，通常要先判断它是否存在。

**和 C++ 的对比**：C++ 没有"可选参数"这个语法概念。C++ 靠的是默认参数——你给参数一个默认值，用户省略时就用默认值。TypeScript 的 `?` 更纯粹，它只是一个"存在性"标记，不要求你提供默认值。如果用户没传，这个参数就是 `undefined`。

**重要规则**：可选参数必须放在必选参数的**后面**。下面这样写会报错：

```typescript
// 错误！可选参数不能放在必选参数前面
function bad(optional?: string, required: number) { }
```

原因很简单：如果你调用 `bad(42)`，TypeScript 不知道 42 是给 optional 还是给 required 的。把可选参数放后面就解决了这个歧义。

### 默认参数：用 `=` 表示"不来就用这个"

默认参数比可选参数更进一步：它不仅允许用户省略参数，还提供了一个"后备值"。就像你点奶茶，没说糖量的话默认半糖。

```typescript
function orderMilkTea(type: string, sugar: string = "半糖"): string {
    return `一杯${type}，${sugar}`;
}

console.log(orderMilkTea("珍珠奶茶"));               // 一杯珍珠奶茶，半糖
console.log(orderMilkTea("珍珠奶茶", "无糖"));       // 一杯珍珠奶茶，无糖
```

**和 C++ 的对比**：这个和 C++ 的默认参数几乎一模一样。C++ 的写法是 `void f(int a = 10)`，TypeScript 是 `f(a: number = 10)`。只是类型标注的位置不同而已。两者都遵循同样的规则：带默认值的参数必须放在没有默认值的参数后面。

**默认参数和可选参数的区别**：

| 特性 | 可选参数 `?` | 默认参数 `=` |
|------|-------------|-------------|
| 省略时的值 | `undefined` | 你指定的默认值 |
| 需要后续判断 | 通常需要 | 不需要（始终有值） |
| 推荐场景 | 值的有无本身就是信息 | 大多数情况用某个固定值 |

通常来说，如果你有一个合理的默认值，优先用默认参数——它会让你的函数体更干净，不用到处判断 `undefined`。

### 剩余参数：用 `...` 表示"来多少都行"

有时候你不知道用户会传几个参数。比如写一个求和函数，可能是两个数相加，也可能是十个。C++ 里你可能想到 `std::initializer_list` 或者变参模板，TypeScript 里用剩余参数（Rest Parameter）优雅得多：

```typescript
function sum(...numbers: number[]): number {
    let total = 0;
    for (const n of numbers) {
        total += n;
    }
    return total;
}

console.log(sum(1, 2));          // 3
console.log(sum(1, 2, 3, 4, 5)); // 15
console.log(sum());              // 0（没有参数时，numbers 是空数组）
```

`...numbers: number[]` 的意思是："把所有传进来的参数收集起来，放进一个叫 numbers 的数字数组里"。你可以传 0 个、3 个、100 个——TypeScript 都给你收进数组。

**和 C++ 的对比**：

| C++ 变长参数方式 | TypeScript 方式 |
|-----------------|----------------|
| `void f(int count, ...)`  (C 风格 va_list) | `f(...args: number[])` |
| `template<typename... Args>` (变参模板) | `f(...args: any[])` |
| `void f(std::initializer_list<int>)` | `f(...args: number[])` |

C++ 有好几种处理变长参数的方式，各有各的复杂度和坑（va_arg 类型不安全，模板编译慢）。TypeScript 的剩余参数把所有参数收成一个类型安全的数组，简单直接。

### 三种方式可以混用

你可以把可选、默认、剩余参数组合使用：

```typescript
function createReport(
    title: string,           // 必选
    author: string = "匿名", // 默认参数
    ...scores: number[]      // 剩余参数
): string {
    const avg = scores.length > 0
        ? scores.reduce((a, b) => a + b, 0) / scores.length
        : 0;
    return `${title}（作者：${author}）平均分：${avg}`;
}

console.log(createReport("期中考试"));                    // 期中考试（作者：匿名）平均分：0
console.log(createReport("期中考试", "王老师", 85, 92, 78)); // 期中考试（作者：王老师）平均分：85
```

## 动手试试

写一个函数 `formatOrder`，模拟外卖订单格式化：

1. `item` 参数是必选的，字符串，表示商品名
2. `quantity` 参数带默认值 1
3. `notes` 是可选的字符串（备注）
4. 用剩余参数 `...toppings: string[]` 接收任意数量的"加料"（如"加蛋"、"加辣"）
5. 返回格式化的订单字符串，例如：`"牛肉面 x2（加蛋、加辣）备注：少汤"`

测试几种不同的调用方式（只传 item、传 item+quantity、全传）。

## 本节小结

`?` 让参数可选，`=` 提供默认值，`...` 收集多出来的参数——三者让 TypeScript 函数的调用方式灵活又不失类型安全。

## 下一节预告

下一节我们学习箭头函数，一种更简洁的函数写法，看看它和 C++ 的 lambda 表达式有什么异同。
