# 06 keyof 与索引访问类型

## 本节你会学到什么

- 用 `keyof` 运算符从对象类型中提取所有键名，得到一个联合类型
- 用索引访问 `T[K]` 获取某个键对应值的类型
- 将 `keyof` 与泛型约束结合，写出更安全的属性访问函数
- 理解 `T[keyof T]`：获取对象类型所有值类型的联合
- 用"查字典"类比理解这两个运算符

## 正文

### 查字典类比

你有一本中英文字典。你想做两件事：

1. 列出字典里所有"词条"（键名）——这些是你可以查的词
2. 查某个词条对应的"释义"（值类型）——这就是 `T[K]` 做的事

`keyof` 就是"列出所有词条"，索引访问 `T[K]` 就是"给出词条 K 对应的释义"。

```typescript
const dictionary = {
  apple: "苹果",
  banana: "香蕉",
  cherry: "樱桃",
};

// 用 typeof + keyof 获取字典的键名联合类型
type Dict = typeof dictionary;
type DictKeys = keyof Dict;        // "apple" | "banana" | "cherry"

// 用索引访问获取某个键的值类型
type AppleValue = Dict["apple"];   // string
```

### keyof：提取所有键名

`keyof` 作用于一个**类型**（不是值），返回该类型所有键名组成的联合类型：

```typescript
interface User {
  id: number;
  name: string;
  email: string;
  isActive: boolean;
}

type UserKeys = keyof User;
// UserKeys = "id" | "name" | "email" | "isActive"
```

拿到了这个联合类型，你就可以用它来做各种限制。比如写一个函数，只允许传入 `User` 的实际键名：

```typescript
function getUserProperty(key: keyof User): string {
  // key 只能是 "id" | "name" | "email" | "isActive" 之一
  return `你要查询的属性是: ${key}`;
}

getUserProperty("name");  // OK
// getUserProperty("age");  // 编译错误！
```

这就好比你去图书馆查书，你只能说查"书名"、"作者"、"ISBN"这几个字段，不能说查"颜色"，因为书没有颜色这个属性。

### 索引访问类型 T[K]：获取值的类型

`T[K]` 的写法看起来像访问数组元素，但它是在**类型层面**获取类型：

```typescript
type UserNameType = User["name"];       // string
type UserIdType = User["id"];           // number
type UserActiveType = User["isActive"]; // boolean
```

注意：`T[K]` 里的 `K` 必须是**类型**，不是值。所以不能写 `User["name"]` 然后期望 `"name"` 是运行时字符串——它在这里是**字面量类型**。

### keyof + 泛型：打造类型安全的属性访问器

把 `keyof` 和泛型约束结合起来，就能写出非常安全的工具函数：

```typescript
function getValue<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const user: User = { id: 1, name: "张三", email: "zhang@test.com", isActive: true };

const uName = getValue(user, "name");   // uName 类型是 string
const uId = getValue(user, "id");       // uId 类型是 number
// getValue(user, "age");               // 编译错误！"age" 不是 User 的键
```

这代码的妙处在于：它不仅阻止你传入不存在的键，而且返回值的类型是精确的——传 `"name"` 返回 `string`，传 `"id"` 返回 `number`。TypeScript 从头到尾都帮你追踪。

### T[keyof T]：获取所有值类型的联合

有时候你不需要特定的值类型，而是想知道"这个对象的值可能是哪些类型"：

```typescript
type UserValues = User[keyof User];
// UserValues = string | number | boolean
//（因为 User 的值有 string、number、boolean 三种）

// 实际用途：写一个通用的"更新对象某个属性"的函数
function updateProperty<T, K extends keyof T>(
  obj: T,
  key: K,
  value: T[K]       // value 的类型必须和 obj[key] 的类型一致
): void {
  obj[key] = value;
}

updateProperty(user, "name", "李四");   // OK，string 配 string
updateProperty(user, "id", 100);        // OK，number 配 number
// updateProperty(user, "name", 123);   // 编译错误！name 是 string，不能赋 number
```

`T[K]` 出现在参数位置时，TypeScript 会自动把 `value` 的类型约束为"该键对应的值的类型"。这比写 `value: string | number | boolean` 精确得多。

### 数组类型的 keyof 和索引访问

数组也是一种对象，它的键是数字索引和一些方法名：

```typescript
type ArrayKeys = keyof string[];      
// "length" | "push" | "pop" | "concat" | ... (很多方法名) 以及 number

type ArrayElement = string[][number]; // string
// string[][0] 的类型就是 string，所以 [number] 取了数组元素的类型
```

这个技巧常用在泛型里提取数组元素类型：

```typescript
type ElementOf<T> = T extends (infer U)[] ? U : never;
// 或者更简单的写法（如果 T 确定是数组）：
type ElementOf2<T extends unknown[]> = T[number];
```

### keyof 用于映射类型的准备

`keyof` 是后续章节"映射类型"的关键基础。映射类型的核心思路就是：

1. 用 `keyof` 拿到所有键的联合
2. 遍历这个联合中的每个键
3. 对每个键对应的值类型做变换

这就像复印机扫描原件——`keyof` 是"列出了原件有几页"，索引访问是"看到了每页的内容"，后续的映射类型就是"对每页做缩放、加滤镜等处理"。

### 和 C++ 的对比

C++ 没有直接对应 `keyof` 和索引访问类型的机制——这是 TypeScript 类型系统非常独特的一点。C++ 的元编程需要借助模板特化和 SFINAE 等技巧来实现类似效果：

```cpp
// C++ 没有 keyof，但可以通过宏或特化做到类似的事
// 以下仅示意，非常繁琐：
template<typename T>
struct get_keys; // 需要针对每个结构体手动特化
```

**相同点：** 都是在编译期操作类型信息。**不同点：** TypeScript 内置了 `keyof` 和 `T[K]`，用起来非常自然；C++ 要实现同样功能需要大量的模板元编程技巧，可读性差很多。这体现了 TypeScript 类型系统的一个设计哲学——让常见的类型操作变得简单直观。

## 动手试试

1. 定义一个 `Product` 接口，包含 `id: number`、`name: string`、`price: number`、`inStock: boolean`
2. 用 `keyof` 提取出 `ProductKeys` 类型，看看它包含哪些值
3. 写一个函数 `getProductInfo(product: Product, key: ProductKeys): string`，根据传入的键返回 `"商品ID: 001"` 或 `"商品名: 手机"` 等
4. 试试传入一个不存在的键（如 `"color"`），看编译器报错

答案参考 `examples/06-keyof-index-access.ts`。

## 本节小结

`keyof` 是"请列出所有词条"，`T[K]` 是"请给我 K 这个条目对应的释义"——它们配合泛型，让你能写出类型极其精确的属性和值访问代码。

## 下一节预告

有了 `keyof` 我们就可以"遍历"对象的键了。下一节学习映射类型，用 `[K in keyof T]` 批量转换属性，就像复印机对每一页做处理。
