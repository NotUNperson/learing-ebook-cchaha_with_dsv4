# 06 构造函数参数属性与 readonly

## 本节你会学到什么

- 使用 TypeScript 的构造函数参数属性（Parameter Properties）简写来一次声明并初始化属性
- 理解 `readonly` 修饰符的作用和适用场景
- 对比 C++ 的 `const` 成员变量和初始化列表
- 知道什么时候该用简写，什么时候该用传统写法

## 正文

### 重复代码太多？TypeScript 的"一条龙"服务

上一节我们写的类，构造函数里几乎全是在做同一件事：把参数赋给属性。看这段代码：

```typescript
class Student {
    name: string;
    age: number;
    grade: string;

    constructor(name: string, age: number, grade: string) {
        this.name = name;
        this.age = age;
        this.grade = grade;
    }
}
```

三行属性声明 + 三行赋值 = 六行代码，实际上在表达同一个意思："这个类有三个属性，在创建时通过构造函数设置"。

这种模式太常见了，TypeScript 提供了一个简写语法——**构造函数参数属性（Parameter Properties）**，让你在参数上直接标注访问修饰符，一条语句同时完成属性声明和赋值：

```typescript
class Student {
    constructor(
        public name: string,
        public age: number,
        public grade: string
    ) {
        // 构造函数体可以是空的！
        // TypeScript 自动帮你做了三件事：
        // 1. 声明 name 属性，类型为 string
        // 2. 声明 age 属性，类型为 number
        // 3. 把构造函数参数的值赋给对应的属性
    }
}

const s = new Student("小明", 16, "高一(3)班");
console.log(s.name);   // "小明" —— 自动成为 public 属性
console.log(s.age);    // 16
```

三行搞定原来六行的事，而且意思更清楚——一眼就能看出这个类有哪些属性，构造时需要传什么。

### 怎么理解这个魔法？

其实不是魔法，TypeScript 在编译时帮你做了"展开"：你在参数前面写了 `public`，TypeScript 就在背后帮你生成属性声明和赋值语句。编译出来的 JavaScript 和手写六行是完全一样的。

**生活类比**：就像你去餐厅点"套餐 A"，不用分别点主食、配菜、饮料。套餐名已经暗含了这三样东西。`public name: string` 就是一个"套餐"——它暗含了"声明属性 + 接收参数 + 赋值"三道工序。

### 三种访问修饰符都能用

`public`、`private`、`protected` 都可以用在构造函数参数上：

```typescript
class BankAccount {
    constructor(
        public ownerName: string,       // 外部可读
        private balance: number = 0,    // 内部才能访问，默认 0
        protected accountId: string     // 子类可访问
    ) {
        // 空函数体也可以
    }

    deposit(amount: number): void {
        this.balance += amount;  // OK，private 在类内部
    }
}

const acc = new BankAccount("Alice", 100, "001");
console.log(acc.ownerName);  // OK —— public
// acc.balance;  // 错误 —— private
// acc.accountId; // 错误 —— protected
```

### 和 C++ 初始化列表的对比

C++ 程序员习惯这样写：

```cpp
class Student {
public:
    string name;
    int age;
    Student(string n, int a) : name(n), age(a) {}  // 初始化列表
};
```

| 特性 | C++ | TypeScript |
|------|-----|------------|
| 简洁声明 | 初始化列表 `: name(n), age(a)` | 参数属性 `public name: string` |
| 位置 | 构造函数签名后面 | 构造函数参数位置 |
| 默认值 | 需要在初始化列表指定 | 参数默认值 `= 0` |
| const 成员 | `const int age;` 只能用初始化列表 | 用 `readonly`（下面讲） |
| 类型位置 | 类型在前 | 类型在后 |

TypeScript 的方式更紧凑——所有信息（访问级别、名称、类型）集中在一个地方。C++ 的方式更传统——声明、初始化列表、构造函数体各司其职。

### readonly：一次写入，终身只读

有时候你希望属性在创建时设置一次，之后就不能再改了。C++ 里用 `const` 成员变量实现这一点。TypeScript 里用 `readonly`：

```typescript
class Product {
    constructor(
        public readonly id: string,      // 创建后不能改
        public name: string,             // 可以随时改
        public readonly createdAt: Date  // 创建后不能改
    ) {}

    updateName(newName: string): void {
        this.name = newName;   // OK，name 不是 readonly
        // this.id = "xxx";    // 错误！readonly 属性不能重新赋值
    }
}

const p = new Product("P001", "机械键盘", new Date());
console.log(p.id);    // "P001"
// p.id = "P002";     // 错误！外部也不能改 readonly 属性
```

### readonly 的适用场景

什么时候该用 readonly？一个简单的判断标准：问自己"这个值在整个生命周期中会变吗？"

- 商品 ID：不会变 → `readonly`
- 创建时间：不会变 → `readonly`
- 用户名：可能会改 → 不用 readonly
- 账户余额：每天都在变 → 不用 readonly

### 不能简写的情况

构造函数参数属性并不是万能的。以下情况不能（或不应该）使用简写：

**1. 属性值需要计算或转换**

```typescript
class Person {
    public fullName: string;

    constructor(firstName: string, lastName: string) {
        // 属性值来自参数的计算，不能用简写
        this.fullName = `${lastName} ${firstName}`;
    }
}
```

**2. 参数名和属性名不同**

```typescript
class User {
    private birthYear: number;

    constructor(age: number) {
        // 参数是 age，属性是 birthYear——不同名，不能简写
        this.birthYear = new Date().getFullYear() - age;
    }
}
```

**3. 需要在赋值前做验证**

```typescript
class Account {
    private balance: number;

    constructor(initialBalance: number) {
        // 需要验证，不能简写
        if (initialBalance < 0) {
            throw new Error("初始余额不能为负");
        }
        this.balance = initialBalance;
    }
}
```

总结：构造函数参数属性适合"直接赋值"场景。如果你需要计算、转换、验证，就走传统写法。

## 动手试试

用构造函数参数属性重写上一节的 `BankAccount` 类：

1. 使用参数属性声明 `ownerName`（public）、`accountNumber`（public readonly）、`balance`（private，默认 0）
2. 保留 `deposit`、`withdraw`、`getBalance` 方法
3. 额外添加一个 `createdAt` 属性（public readonly，在构造函数中用 `new Date()` 初始化——这个不能用参数属性，因为不是从参数来的）

## 本节小结

构造函数参数属性让你用一个修饰符同时完成声明和赋值，readonly 让属性在创建后不可修改——两个都是减少样板代码的利器。

## 下一节预告

下一节我们学习接口（interface）——一种描述对象"形状"的方式，看看它和 C++ 的 struct 有什么微妙的不同。
