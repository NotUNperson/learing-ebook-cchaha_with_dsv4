# 05 类的基本语法

## 本节你会学到什么

- 用 `class` 关键字定义一个 TypeScript 类
- 理解构造函数 `constructor` 和 `this` 的用法
- 使用 `new` 关键字创建类的实例
- 掌握三种访问修饰符：`public`、`private`、`protected`
- 对比 TypeScript 的 class 和 C++ 的 class 在语法和设计上的异同

## 正文

### 从结构体到类——给数据配上行为

你已经学过了 TypeScript 的基本类型和函数。到目前为止，数据和函数是分开的——变量归变量，函数归函数。但在真实世界里，事物往往同时拥有"属性"和"行为"。

想象你有一个"遥控器"。遥控器有属性（品牌、颜色、当前电量），也有行为（开机、关机、换频道）。在程序里，你不会想用一堆分散的变量和函数来表示一个遥控器——你会想把它们打包在一起。这就是**类（class）**。

### 一个最简单的 TypeScript 类

先不写 C++ 对比，看一个纯 TypeScript 的类：

```typescript
class RemoteControl {
    brand: string;
    powerOn: boolean;

    constructor(brand: string) {
        this.brand = brand;
        this.powerOn = false;  // 出厂默认关机
    }

    pressPower(): void {
        this.powerOn = !this.powerOn;
        const status = this.powerOn ? "开机" : "关机";
        console.log(`${this.brand} 遥控器：${status}`);
    }
}

// 创建实例
const myRemote = new RemoteControl("索尼");
myRemote.pressPower();  // 索尼 遥控器：开机
myRemote.pressPower();  // 索尼 遥控器：关机
```

让我们逐行拆解：

**1. `class RemoteControl`** —— 声明一个类，就像声明一个自定义类型。和 C++ 一样，类名通常用大写字母开头（PascalCase）。

**2. `brand: string;` 和 `powerOn: boolean;`** —— 这是**属性声明**。告诉 TypeScript 这个类的每个实例都有这两个属性，以及它们的类型。注意这里没有 `let` 或 `const`，直接写属性名和类型。

**3. `constructor(brand: string)`** —— **构造函数**。当你用 `new` 创建实例时，构造函数自动执行。它接收参数（这里是品牌名），用来初始化属性。和 C++ 的构造函数概念完全相同。

**4. `this.brand = brand;`** —— `this` 指向当前实例。因为构造函数参数叫 `brand`，属性也叫 `brand`，所以用 `this.` 来区分"这个实例的属性"和"传进来的参数"。

**5. `pressPower(): void`** —— 一个**方法**（也就是属于类的函数）。叫"方法"纯粹是因为它属于一个类，语法上和普通函数没有本质区别。

**6. `new RemoteControl("索尼")`** —— `new` 关键字创建实例。和 C++ 一样，`new` 触发构造函数，返回一个对象。不同的是 TypeScript 的对象用 `new` 分配在堆上，不需要手动 `delete`（有垃圾回收）。

### 和 C++ class 的对比

如果你熟悉 C++ 的 class，这里有一些需要适应的差异：

| 特性 | C++ | TypeScript |
|------|-----|------------|
| 属性声明 | 在类体中声明 `int m_value;` | 类体中声明 `value: number;` |
| 类型位置 | 类型在变量名前 | 类型在变量名后（冒号分隔） |
| 构造函数 | `ClassName(int v) : m_value(v) {}` | `constructor(v: number) { this.value = v; }` |
| 构造时初始化 | 初始化列表 `: m_value(v)` | 构造函数体内 `this.value = v` |
| 内存管理 | 需要手动 delete 或用智能指针 | 自动垃圾回收，不需要手动释放 |
| 头文件 | 通常分 `.h` 和 `.cpp` | 一个 `.ts` 文件搞定 |
| 结尾分号 | `};` | 不需要 `;` |
| 默认访问 | `private` | `public` |

最重要的一点：**C++ 的 class 默认是 private 访问，TypeScript 的 class 默认是 public**。这意味着在 TypeScript 中，如果你不写访问修饰符，所有属性和方法都是"对外开放"的。

### 访问修饰符：public、private、protected

访问修饰符控制谁可以访问类的成员。这是一个重要的概念——不是所有内部数据都应该暴露给外部。

**生活类比**：想象你有一台自动贩卖机。前面板上有投币口、选择按钮、取物口——这些是 `public` 的，所有人都能用。机器内部的制冷压缩机、账单计数器——这些是 `private` 的，只有机器自己能操作。维修工有特殊钥匙，可以接触一些内部零件但不至于所有——这些是 `protected` 的。

```typescript
class VendingMachine {
    public brand: string;          // 任何人可以读写
    private internalTemp: number;  // 只有这个类内部可以访问
    protected serialNumber: string; // 这个类和子类可以访问

    constructor(brand: string, serial: string) {
        this.brand = brand;
        this.internalTemp = 4;      // 默认 4 度
        this.serialNumber = serial;
    }

    public dispense(): void {
        this.cool();  // 内部调用 private 方法
        console.log("出货中...");
    }

    private cool(): void {
        console.log("冷却系统运行，当前温度：" + this.internalTemp);
    }
}

const machine = new VendingMachine("可口可乐", "SN12345");
console.log(machine.brand);    // OK — public
machine.dispense();            // OK — public
// machine.internalTemp = 10;  // 错误！private 不能外部访问
// machine.cool();             // 错误！private 不能外部访问
```

三个访问修饰符的含义：

| 修饰符 | 类内部访问 | 子类访问 | 外部访问 |
|--------|----------|---------|---------|
| `public` | 可以 | 可以 | 可以 |
| `protected` | 可以 | 可以 | 不可以 |
| `private` | 可以 | 不可以 | 不可以 |

这和 C++ 几乎一模一样，概念上没有差别。唯一的区别是 C++ 的默认是 `private`，而 TypeScript 的默认是 `public`。

### 方法：类内部的函数

在 TypeScript 中，类的方法写法和普通函数几乎一样：

```typescript
class Calculator {
    private result: number = 0;

    public add(n: number): void {
        this.result += n;
    }

    public getResult(): number {
        return this.result;
    }
}
```

注意方法前面不需要写 `function` 关键字。在类内部，方法名直接跟参数列表和函数体。这和 C++ 一样——类内部的方法不需要额外的关键字。

### 为什么需要访问控制？

你可能会问："写个小程序而已，全用 public 不是更简单吗？"

访问控制的价值在程序变大时才会体现。当一个类有几十个属性和方法时，如果全部 public，其他代码可能不小心修改了不该改的数据，导致 bug 难以追踪。用 private 把内部数据"锁起来"，让外部只能通过你设计的 public 方法来操作，就像给数据装了一扇门——你可以控制谁能进来、进来干什么。

这和 C++ 的封装思想完全一致。如果你理解 C++ 为什么要用 private，在 TypeScript 中同理。

## 动手试试

创建一个 `BankAccount`（银行账户）类：

1. 属性：`ownerName: string`（public）、`balance: number`（private）、`accountNumber: string`（public readonly——先用 public 代替，下节学 readonly）
2. 构造函数接收 `ownerName` 和 `accountNumber`，初始余额为 0
3. 方法 `deposit(amount: number): void`（存款）
4. 方法 `withdraw(amount: number): boolean`（取款，余额不足返回 false）
5. 方法 `getBalance(): number`（查询余额）
6. 创建两个账户，互相转账（从一个取款，向另一个存款）

## 本节小结

TypeScript 的 class 和 C++ 的 class 在概念上高度一致：都有构造函数、this、访问修饰符——只是语法上类型写在冒号后面，且默认访问级别是 public。

## 下一节预告

下一节我们学习 TypeScript 独有的构造函数简写语法——直接在构造函数参数上声明和初始化属性，省去大量样板代码。
