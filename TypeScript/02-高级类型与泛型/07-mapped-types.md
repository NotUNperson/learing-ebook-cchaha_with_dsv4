# 07 映射类型

## 本节你会学到什么

- 理解映射类型的语法 `[K in keyof T]`：像复印机一样"逐页处理"每个属性
- 掌握内置工具类型：`Partial<T>`、`Required<T>`、`Readonly<T>`
- 学会 `Pick<T, K>` 挑选属性、`Record<K, V>` 创建映射
- 知道什么时候应该自己写映射类型，而不是手动修改接口
- 用 `+` 和 `-` 修饰符精确控制属性的 readonly 和可选性

## 正文

### 复印机类比

你有一份 10 页的合同原件。你现在需要做三件事：

1. **草稿版**：复印一份，但每页都可以是空白（所有条款都变成"可选"的）——这相当于 `Partial<T>`
2. **终稿版**：复印一份，但每页都盖章"最终确认，不可修改"——这相当于 `Readonly<T>`
3. **摘要版**：只复印前 3 页——这相当于 `Pick<T, K>`

复印机的核心能力是：**对原件逐页处理，批量产生新文档**。映射类型（Mapped Types）就是 TypeScript 世界里这样一台复印机。

### 映射类型的基本语法

映射类型用 `in` 关键字遍历一个联合类型中的每个成员：

```typescript
type MappedExample = {
  [K in "name" | "age" | "email"]: string;
};
// 等同于：
// { name: string; age: string; email: string; }
```

更常见的写法是：用 `keyof T` 遍历某个类型的所有键：

```typescript
type CloneWithString<T> = {
  [K in keyof T]: string;  // 把 T 的所有属性的值类型都改成 string
};
```

`[K in keyof T]` 可以读作："对于 T 的每个键 K，执行冒号后面的操作"。

### Partial<T>：所有属性变可选

`Partial` 是 TypeScript 内置类型，但它的实现只有一行，你可以自己写出来：

```typescript
type MyPartial<T> = {
  [K in keyof T]?: T[K];  // 注意这个 ?，它让每个属性变成可选的
};

// 使用
interface User {
  id: number;
  name: string;
  email: string;
}

type PartialUser = MyPartial<User>;
// { id?: number; name?: string; email?: string; }
```

什么时候用？比如更新用户信息，你只想修改部分字段：

```typescript
function updateUser(id: number, changes: Partial<User>): void {
  // changes 里可以只有 name，也可以只有 email，也可以都有
}
```

这就像你填一份表格，有的格你可以不填——因为它是"部分更新"。

### Required<T>：所有属性变必填

和 `Partial` 相反，`Required` 把可选属性变成必填：

```typescript
type MyRequired<T> = {
  [K in keyof T]-?: T[K];  // -? 移除可选修饰符
};

// 使用
interface Config {
  host?: string;
  port?: number;
  debug?: boolean;
}

type FullConfig = Required<Config>;
// { host: string; port: number; debug: boolean; } — 全部必填
```

### Readonly<T>：所有属性变只读

```typescript
type MyReadonly<T> = {
  readonly [K in keyof T]: T[K];
};

// 使用
type ReadonlyUser = Readonly<User>;
// { readonly id: number; readonly name: string; readonly email: string; }

const user: ReadonlyUser = { id: 1, name: "张三", email: "zhang@test.com" };
// user.name = "李四"; // 编译错误！readonly 属性不能修改
```

用复印机类比：你给原件每页上都盖了一个"禁止修改"的章。复印出来之后，任何人都可以看，但不能在上面写字。

### Pick<T, K>：挑选属性

有时候你不需要所有属性，只要其中的几个：

```typescript
type MyPick<T, K extends keyof T> = {
  [P in K]: T[P];  // 只对 K 中的键进行映射
};

// 使用
type UserPreview = Pick<User, "id" | "name">;
// { id: number; name: string; } — 只有两个属性
```

`K extends keyof T` 的约束保证了 K 里只能是 T 的真实键名，不能乱写。

### Record<K, V>：创建映射

`Record<K, V>` 用一个键的集合和一个值类型构造出对象类型：

```typescript
type MyRecord<K extends keyof any, V> = {
  [P in K]: V;
};

// 使用
type Role = "admin" | "editor" | "viewer";
type Permissions = Record<Role, boolean>;
// { admin: boolean; editor: boolean; viewer: boolean; }

const perms: Permissions = {
  admin: true,
  editor: false,
  viewer: false,
};
```

### 加修饰符和去修饰符

映射类型中，你可以在 `readonly` 和 `?` 前面加 `+`（添加）或 `-`（移除）：

| 修饰符 | 含义 |
|--------|------|
| `readonly` | 添加只读 |
| `-readonly` | 移除只读 |
| `?` | 添加可选 |
| `-?` | 移除可选 |

```typescript
// 全部变为可写（移除 readonly）
type Mutable<T> = {
  -readonly [K in keyof T]: T[K];
};

// 全部变为必填（移除 ?）
type Concrete<T> = {
  [K in keyof T]-?: T[K];
};
```

### 用映射类型重命名键

你还可以给映射出来的键改名：

```typescript
// 给所有属性名加上 on 前缀，常用于事件处理器类型
type OnEvent<T> = {
  [K in keyof T as `on${Capitalize<string & K>}`]: T[K];
};

// 使用
type EventMap = { click: () => void; hover: () => void };
type Handlers = OnEvent<EventMap>;
// { onClick: () => void; onHover: () => void; }
```

这里的 `as` 关键字可以重新映射键名，结合模板字面量类型就能实现属性的重命名。

### 和 C++ 的对比

C++ 没有直接的映射类型等价物。最接近的是模板元编程中使用 `std::tuple` 和各种 traits：

```cpp
// C++ 没有 Partial<T>，需要大量样板代码
// std::optional 勉强对应 ?，但没有批量的遍历机制
```

**不同点：** 映射类型是 TypeScript 类型系统独有的一大优势。它让你用几行代码就能批量操作类型的属性，而不需要像 C++ 那样为每个类型手动写特化。这源于 TypeScript 的"结构类型"基础——TypeScript 不关心类型的"名"，只关心它的"形状"，因此形状的变换可以用声明式语法轻松表达。

## 动手试试

1. 定义一个接口 `Product { id: number; name: string; price: number; description: string; }`
2. 用 `Partial<Product>` 创建一个函数 `createDraft`，接收一个 `Partial<Product>` 并返回它
3. 用 `Pick<Product, "id" | "name">` 创建一个 `ProductSummary` 类型
4. 用 `Record<"success" | "error" | "pending", Product>` 创建一个状态到产品的映射
5. 试试自己实现一个 `MyReadonly<T>` 并测试只读效果

答案参考 `examples/07-mapped-types.ts`。

## 本节小结

映射类型是 TypeScript 的"复印机"——按 `keyof` 列出的页，对每页统一做变换，批量产出新类型，是 TypeScript 类型编程最核心的利器。

## 下一节预告

所有知识都学完了，下一节做一个综合练习——用泛型、约束、交叉类型、映射类型等构建一个完整的类型安全数据仓库。
