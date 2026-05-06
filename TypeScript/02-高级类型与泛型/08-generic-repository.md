# 08 综合练习：泛型数据仓库

## 本节你会学到什么

- 综合运用泛型、泛型约束、交叉类型、映射类型、keyof 打造一个真实可用的数据仓库
- 理解"仓库模式"（Repository Pattern）中的类型安全写法
- 学会设计类型安全的 `add`、`remove`、`findById`、`findBy`、`update` 方法
- 体会泛型系统如何让编译器变成你的"第一道防线"
- 通过完整项目巩固前面七节的所有知识

## 正文

前面七节我们分别学了泛型的各个"零件"。这一节我们要把零件组装成一台完整的机器——一个类型安全的**通用数据仓库**。

### 什么是仓库模式

想象一个图书馆。你需要存书、找书、借书、还书。你不能让读者直接进书库翻找（那会乱套），而是通过管理员完成这些操作。管理员就是"仓库"——它封装了数据的存取逻辑，对外提供统一的接口。

在编程里，仓库模式（Repository Pattern）做的是同一件事：它把数据的具体存储方式（内存、数据库、文件）封装起来，对外只暴露 `add`、`remove`、`findById`、`findBy`、`update` 等方法。使用者不需要知道数据是存在变量里还是 MySQL 里。

### 数据必须有 ID

我们要建的仓库有一个前提：存进去的每一条数据，都必须有 `id` 字段。这样我们才能按 ID 查找、删除或更新。

```typescript
// 存进仓库的数据必须满足这个接口
interface Identifiable {
  id: number;
}

// 用户数据
interface User extends Identifiable {
  name: string;
  email: string;
}

// 商品数据
interface Product extends Identifiable {
  name: string;
  price: number;
}
```

通过 `extends Identifiable` 这个约束，我们确保了任何存进仓库的东西都有 `id`。这就跟图书馆要求每本书必须有索书号是同样的道理。

### 设计仓库类

我们的泛型仓库类 `Repository<T>` 需要对 `T` 加约束：`T extends Identifiable`。这样仓库里的每一个元素都是"有身份证号"的。

```typescript
class Repository<T extends Identifiable> {
  private items: T[] = [];

  // 添加一条记录
  add(item: T): T { ... }

  // 按 ID 查找
  findById(id: number): T | undefined { ... }

  // 按任意属性查找（返回匹配的数组）
  findBy<K extends keyof T>(key: K, value: T[K]): T[] { ... }

  // 按 ID 删除
  remove(id: number): boolean { ... }

  // 按 ID 更新（部分更新，用 Partial<T>）
  update(id: number, changes: Partial<T>): T | undefined { ... }

  // 获取所有记录
  getAll(): T[] { ... }
}
```

这里面用到了我们学过的每一个知识点：

- `Repository<T extends Identifiable>`：泛型类 + 泛型约束（第 2、3 节）
- `findBy<K extends keyof T>(key: K, value: T[K])`：keyof、索引访问类型、泛型约束（第 2、6 节）
- `update(id: number, changes: Partial<T>)`：映射类型 `Partial`（第 7 节）
- 方法的返回值用 `T` 和 `T | undefined`：精确追踪类型

### findBy 方法详解

`findBy` 是整个仓库里最"聪明"的方法。让我们一行行拆解：

```typescript
findBy<K extends keyof T>(key: K, value: T[K]): T[] {
  return this.items.filter((item) => item[key] === value);
}
```

- `K extends keyof T`：K 只能是 T 的键名（比如 `"name"` 或 `"email"`）
- `value: T[K]`：value 的类型必须和 T[K] 一致——如果 key 是 `"name"`，value 必须是 `string`；如果 key 是 `"price"`，value 必须是 `number`
- 返回值是 `T[]`：找到的所有匹配项

这意味着编译器可以阻止这种错误：

```typescript
const repo = new Repository<User>();
repo.findBy("name", 123);  // 编译错误！name 是 string，123 不是
repo.findBy("age", 18);    // 编译错误！User 没有 age 属性
```

整段代码从头到尾都是类型安全的，不用运行就能发现低级错误。

### 更新操作的精度

`update(id, changes: Partial<T>)` 用了 `Partial<T>`。这意味着你只需要传你想改的字段：

```typescript
const userRepo = new Repository<User>();
userRepo.add({ id: 1, name: "张三", email: "zhang@test.com" });

// 只改名字，不改邮箱
userRepo.update(1, { name: "张三丰" });
// T 类型确保你不能这样做：
// userRepo.update(1, { name: 123 }); // 编译错误
```

### 完整代码示例

完整的 `Repository` 实现和测试代码请参考 `examples/08-generic-repository.ts`。文件里包含了 `User` 和 `Product` 两个仓库的完整测试。

### 生活类比：智能储物柜

这个仓库就像一个智能储物柜系统。每件物品都有一个条形码（`id`），柜子系统保证：

1. 存东西时扫描条形码——不能存没有码的物品
2. 取东西时输入码——不会取错
3. 找东西时可以按"类型"或"颜色"等属性过滤——系统自动只让你选合法的过滤条件
4. 修改物品标签时，扫码后只改你指定的内容——不能把"红色的衣服"的颜色改成一个数字

一切都是**类型驱动**的。你不用再担心把字符串赋给数字字段这种低级错误——编译器在你保存文件的那一刻就告诉你了。

### 回顾：七种武器

到现在为止，你掌握了七种"武器"：

| 序号 | 武器 | 用途 |
|------|------|------|
| 1 | 泛型函数 `<T>` | 一次定义，多种类型 |
| 2 | 泛型约束 `extends` | 限制类型参数的范围 |
| 3 | 泛型类 `class Stack<T>` | 类型安全的通用容器 |
| 4 | 类型守卫 `x is Type` | 在代码分支中收窄类型 |
| 5 | 交叉类型 `&` | 把多个类型合并成一个 |
| 6 | keyof + 索引访问 | 提取键名和值类型 |
| 7 | 映射类型 | 批量改变类型的属性 |

这一节的 `Repository<T>` 把七种武器集于一身，是一个真实的、可以直接复制到项目里使用的模式。

## 动手试试

1. 创建一份 `Repository` 的完整实现（或直接用示例文件）
2. 创建一个 `Task` 接口：`{ id: number; title: string; completed: boolean; priority: "low" | "medium" | "high" }`
3. 实例化一个 `Repository<Task>`
4. 添加 3 条任务
5. 用 `findBy` 按 `completed` 查找所有未完成任务
6. 用 `update` 把其中一条任务标记为已完成
7. 用 `remove` 删除一条任务
8. 打印所有剩余任务

具体答案已在 `examples/08-generic-repository.ts` 中提供。

## 本节小结

泛型数据仓库把零散的泛型知识编织成一张完整的"类型安全网"，让你对数据的每一次操作都受到编译器的严格守护。

## 下一节预告

恭喜！"高级类型与泛型"模块全部完成。下一模块将进入 TypeScript 的类型体操（条件类型、模板字面量类型以及 infer 等高级类型工具），在泛型的基础上更进一步。
