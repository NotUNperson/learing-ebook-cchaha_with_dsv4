# 08 interface vs type 别名

## 本节你会学到什么

- 识别 interface 和 type 别名的共同点与差异
- 知道什么时候应该用 interface，什么时候应该用 type
- 理解 interface 独有的"声明合并"特性
- 熟悉 type 擅长的联合类型和交叉类型
- 在项目中做出正确的选择，而不是凭感觉

## 正文

### 两种方式，同一个目的

你已经学过 type 别名（在类型系统入门中）和 interface（上一节）。现在把它们放在一起看：

```typescript
// 用 type 别名描述一个用户
type UserWithType = {
    name: string;
    age: number;
};

// 用 interface 描述同样的形状
interface UserWithInterface {
    name: string;
    age: number;
}
```

看起来几乎一模一样，是吧？在描述"对象形状"这件事上，type 和 interface 确实有很大重叠。

**生活类比**：type 和 interface 就像两种不同的填表方式。type 像手写——自由、灵活、什么都能写。interface 像用模板——有固定格式、可以扩展，但不能脱离模板的框架。

### 共同点：这些事两者都能做

在下面这些场景中，type 和 interface 完全可以互换：

**1. 描述对象形状**

```typescript
type Point = { x: number; y: number; };
interface Point { x: number; y: number; }
```

**2. 可选属性和只读属性**

```typescript
type Config = { readonly id: string; timeout?: number; };
interface Config { readonly id: string; timeout?: number; }
```

**3. 函数签名**

```typescript
type AddFn = (a: number, b: number) => number;
interface AddFn { (a: number, b: number): number; }
```

**4. 扩展（extends）**

```typescript
// type 用交叉类型（&）
type Animal = { name: string; };
type Dog = Animal & { bark(): void; };

// interface 用 extends
interface Animal { name: string; }
interface Dog extends Animal { bark(): void; }
```

### 差异一：type 能做而 interface 不能做的

type 的灵活性比 interface 大得多。type 能做这些：

**1. 基本类型的别名**

```typescript
type MyNumber = number;
type Name = string;
// interface 做不到——它只能描述对象
```

**2. 联合类型和元组类型**

```typescript
type Status = "success" | "error" | "pending";   // 联合类型
type StringOrNumber = string | number;            // 联合类型
type Point2D = [number, number];                   // 元组类型
type Point3D = [number, number, number];           // 元组类型
// interface 做不到——这些不是对象形状
```

**3. 映射类型**

```typescript
type Readonly<T> = { readonly [K in keyof T]: T[K] };
// interface 做不到
```

总结：type 是真正的"类型别名"——它可以代表任何类型。interface 只能描述对象形状。

### 差异二：interface 能做而 type 不能做的

interface 有一个 type 没有的特殊能力：**声明合并**。

如果你在代码中的两个不同位置定义了同名的 interface，TypeScript 会把它们**合并**成一个：

```typescript
// 文件 A（可能是第三方库）
interface User {
    name: string;
}

// 文件 B（你自己的代码）
interface User {
    age: number;       // 自动合并！
    email: string;     // 自动合并！
}

// 使用时：User 现在有三个属性
const user: User = {
    name: "Alice",
    age: 25,
    email: "alice@example.com"
};
```

而 type 做不到这一点——重复定义会报错：

```typescript
type User = { name: string; };
// type User = { age: number; };  // 错误！重复标识符
```

**声明合并有什么用？** 最常见的场景是给第三方库的类型"打补丁"。比如你用的某个 npm 包定义了一个 interface，你想给它加一个属性，不用 fork 那个包——直接在自己的代码里声明同名 interface 就行。

**生活类比**：interface 像是可以贴在墙上的便利贴——你可以分多次补充信息，新的便利贴不会覆盖旧的，而是合并在一起。type 像是铅笔写的——你擦了重写，旧的就没用了。

### 差异三：extends 的语义差异

interface 用 `extends`，Type 用 `&`（交叉类型），但它们在处理冲突时的行为不同：

```typescript
interface A { value: number; }
interface B { value: string; }

// interface extends：如果属性冲突，会报错
// interface C extends A, B { }  // 错误！

// type 交叉：value 的类型变成 number & string（即 never，不可能存在）
type C = A & B;  // { value: never }
// 不报错，但 value 的类型是 never（永远无法赋值的类型）
```

这意味着 interface 的 extends 是"发现了冲突就提醒你"，而 type 的 `&` 是"发现了冲突就合并成 never"。实际上大多数场景你不会遇到这种冲突，知道存在这个差异就行。

### 社区惯例：什么时候用什么？

虽然没有硬性规定，但 TypeScript 社区有一些不成文的惯例：

**优先用 interface 的场景：**
- 描述对象形状（尤其是公开 API 的类型）
- 需要 extends 或者被 extends 的（类可以实现接口）
- 需要声明合并（给第三方库补类型）

**优先用 type 的场景：**
- 联合类型和元组类型
- 基本类型的别名
- 需要映射类型、条件类型等高级类型操作
- 函数类型签名

**一个简单的判断标准：**
> 如果你是在描述一个"东西"（对象、实体），用 interface。如果你是在做"类型组合"（联合、元组、别名），用 type。

如果你不确定，用 interface 通常更安全——因为它有声明合并，而 type 没有，万一将来需要扩展，interface 更灵活。

### 实战对比

```typescript
// 场景 1：API 响应的数据结构 → interface
interface ApiResponse {
    code: number;
    data: object;
    message: string;
}

// 场景 2：函数签名 → type 更简洁
type Callback = (err: Error | null, result: string) => void;

// 场景 3：状态类型（联合类型）→ 只能用 type
type LoadingState = "idle" | "loading" | "success" | "error";

// 场景 4：配置对象（可能需要扩展）→ interface
interface AppConfig {
    readonly apiUrl: string;
    timeout: number;
    retryCount?: number;
}

// 场景 5：坐标元组 → 只能用 type
type Coordinate = [number, number];
```

### 一个特别的注意事项：type 和 interface 都可以被 class 实现

```typescript
interface Person {
    name: string;
    greet(): void;
}

class Student implements Person {
    constructor(public name: string) {}
    greet() { console.log(`我是 ${this.name}`); }
}
```

class 也可以用 `implements` 配合 type——但只有对象形状的 type 才行。联合类型的 type 不能 implements。

## 动手试试

1. 写一个 type 别名 `HttpMethod`，是 `"GET" | "POST" | "PUT" | "DELETE"` 的联合类型
2. 写一个 interface `RequestConfig`，包含 `url`（string）、`method`（HttpMethod）、`headers?`（对象，可选）、`timeout?`（number，可选，默认不写）
3. 写一个函数 `execute`，接收 `RequestConfig` 类型参数，打印出请求信息
4. 在同一个文件中，再声明一个 `RequestConfig` interface（加一个 `retryCount` 属性），观察声明合并的效果
5. 测试：创建一个符合合并后 interface 的对象，传入 `execute`

## 本节小结

type 是万能别名（啥都能命名），interface 是对象形状专家（有声明合并能力）——两者互补，根据场景选择。

## 下一节预告

最后一节是综合练习——我们用一个"学生成绩管理系统"把前八节函数、类、接口的知识串起来，来一场实战热身。
