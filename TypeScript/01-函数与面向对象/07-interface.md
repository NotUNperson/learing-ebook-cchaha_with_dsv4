# 07 接口 interface

## 本节你会学到什么

- 用 `interface` 关键字描述对象的"形状"（属性名 + 类型）
- 使用接口作为函数参数的类型标注
- 定义可选属性（`?`）和只读属性（`readonly`）的接口
- 理解 interface 和 C++ struct 的本质区别
- 知道接口描述的是"结构"而非"行为"

## 正文

### 描述形状——不只是类型

到目前为止，我们学会了声明简单类型：`number`、`string`、`boolean`。也学会了用类来描述带行为的对象。但有时候，你需要的不是一个完整的类，而只是"描述一个对象应该长什么样"。

比如你有一个函数，它接收一个"用户信息"作为参数。用户信息有 `name`（string）、`age`（number）、`email`（string）。你不用写一个类，只需要描述这个对象的"形状"——这就是 **interface** 的用武之地。

### interface 基本语法

```typescript
interface User {
    name: string;
    age: number;
    email: string;
}

function sendEmail(user: User, message: string): void {
    console.log(`发送邮件给 ${user.name}（${user.email}）：${message}`);
}

// 只要对象有 name、age、email 这三个属性就行了
// 不需要来自某个特定的类
const alice = {
    name: "Alice",
    age: 25,
    email: "alice@example.com"
};

sendEmail(alice, "欢迎注册！");
```

interface 做的事情很简单：它说"满足这个接口的对象，必须有 name（string）、age（number）、email（string）"。

**生活类比**：interface 就像一份"入职要求"。公司招人时不会在意你是从哪里毕业的（哪个 class 的实例），只要你有要求的能力（属性）就合格。`interface User` 就是"我们需要一个 name（姓名）、age（年龄）、email（邮箱）的人"。任何对象只要具备这三个属性，就能传给 `sendEmail`。

### 可选属性：有些属性不是必须的

就像简历上的"获奖经历"——有更好，没有也行。接口中用 `?` 标记可选属性：

```typescript
interface UserProfile {
    name: string;
    age: number;
    email: string;
    phone?: string;       // 可选：没有也行
    bio?: string;         // 可选：个人简介
}

function printProfile(profile: UserProfile): void {
    console.log(`${profile.name}，${profile.age} 岁`);
    if (profile.phone) {
        console.log(`  电话：${profile.phone}`);
    }
    if (profile.bio) {
        console.log(`  简介：${profile.bio}`);
    }
}
```

### readonly 属性：创建后不能改

```typescript
interface Product {
    readonly id: string;
    name: string;
    price: number;
}

const keyboard: Product = {
    id: "KB-001",
    name: "机械键盘",
    price: 299
};

// keyboard.id = "KB-002";  // 错误！readonly 不能改
keyboard.price = 259;       // OK，price 不是 readonly
```

### interface 和 C++ struct 的对比

如果你从 C++ 过来，看到 interface 可能会想："这不就是 struct 吗？"

答案：**是也不是**。它们都用来聚合数据，但有几个关键区别。

首先是语法对比：

```cpp
// C++ struct
struct User {
    string name;
    int age;
    string email;
};
```

```typescript
// TypeScript interface
interface User {
    name: string;
    age: number;
    email: string;
}
```

长得确实很像，只是类型位置不同（TypeScript 放在冒号后面）。

**但核心区别在于哲学层面：**

| 特性 | C++ struct | TypeScript interface |
|------|-----------|---------------------|
| 本质 | 数据结构（在内存中真实存在） | 类型约束（纯编译时概念） |
| 运行时 | 占用内存，CPU 直接操作 | 编译后完全消失，不存在 |
| 方法 | 可以有成员函数 | 只有属性签名（行为通过 class 实现） |
| 实例化 | `User u;` 可以直接声明变量 | 不能 `new`，只能用来标注对象字面量 |
| 继承 | 支持（public/private/protected 继承） | 支持 extends，但无访问控制 |
| 目的 | 组织数据和相关操作 | 纯粹描述对象形状 |

最重要的区别：**C++ struct 是实实在在存在于运行时的数据结构**——它占用内存，编译成机器码后 CPU 通过偏移量访问成员。**TypeScript interface 是纯粹的编译时概念**——JavaScript 运行时根本不知道 interface 的存在，它只存在于 TypeScript 的类型检查阶段。

用个比喻：C++ struct 是"一座真实的房子"，有墙壁、有门、有电。TypeScript interface 是"建筑图纸"——它描述了房子的形状，但你不能住进图纸里。你真正住的是按照图纸盖的房子（也就是符合接口的对象）。

### interface 的优势：结构化类型（鸭式辩型）

TypeScript 的类型系统是"结构化"的。什么意思？它只看对象有没有需要的属性，不看对象来自哪里。这叫"鸭式辩型"（Duck Typing）：

> 如果它走起路来像鸭子，叫起来像鸭子，那它就是鸭子。

```typescript
interface Named {
    name: string;
}

function sayHello(entity: Named): void {
    console.log(`Hello, ${entity.name}!`);
}

// 这些都可以传给 sayHello，因为它们都有 name 属性
sayHello({ name: "Alice" });          // 普通对象
sayHello({ name: "Bob", age: 30 });   // 有额外属性也没关系

class Person {
    constructor(public name: string) {}
}
sayHello(new Person("Charlie"));      // 类的实例也可以

// 甚至一个来自不同"世界"的对象，只要有 name 就行
const cat = { name: "咪咪", color: "橘色" };
sayHello(cat);  // 输出：Hello, 咪咪！
```

这跟 C++ 完全不同。C++ 的类型是"名义的"（nominal）——你必须声明"我是这个类型"才算数。TypeScript 只看实际结构。

### 接口可以嵌套

一个接口的属性可以是另一个接口：

```typescript
interface Address {
    city: string;
    street: string;
    zipCode: string;
}

interface Employee {
    name: string;
    position: string;
    address: Address;  // 使用另一个接口作为属性类型
}

const emp: Employee = {
    name: "李雷",
    position: "工程师",
    address: {
        city: "北京",
        street: "中关村大街 1 号",
        zipCode: "100080"
    }
};
```

## 动手试试

定义以下接口并创建符合它们的对象：

1. `Book` 接口：`title`（string）、`author`（string）、`pages`（number）、`isbn`（readonly string）、`publishedYear?`（可选 number）
2. 创建一个 `book1`，所有属性都填
3. 创建一个 `book2`，不填 `publishedYear`
4. 写一个 `printBookInfo` 函数，参数类型是 `Book`，打印书籍信息（publishedYear 存在则打印，否则打印"未知"）
5. 尝试修改 `book1.isbn`，观察编译错误

## 本节小结

interface 是 TypeScript 的"类型图纸"，它只描述对象的形状（有哪些属性、各是什么类型），编译后完全消失——这点和 C++ 作为运行实体的 struct 有本质区别。

## 下一节预告

下一节我们把 interface 和 type 别名放在一起比较，搞清楚它们各自的适用场景，还有 interface 独有的"声明合并"特性。
