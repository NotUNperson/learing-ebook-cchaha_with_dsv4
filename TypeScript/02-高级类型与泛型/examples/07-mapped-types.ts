// ============================================================
// 07 映射类型 — 示例代码
// 演示 Partial、Required、Readonly、Pick、Record 及手动实现
// ============================================================

// 先定义几个基础类型，后续映射类型会用到
interface User {
  id: number;
  name: string;
  email: string;
  age: number;
  isActive: boolean;
}

interface Product {
  id: number;
  name: string;
  price: number;
  description: string;
}

// -------------------- 1. 手工版 MyPartial<T>：所有属性变可选 --------------------
// 核心：在 [K in keyof T] 后面加 ?
type MyPartial<T> = {
  [K in keyof T]?: T[K];
};

// 使用内置 Partial（MyPartial 也是一样的效果）
type PartialUser = Partial<User>;
// 等同于 { id?: number; name?: string; email?: string; age?: number; isActive?: boolean; }

function updateUser(id: number, changes: Partial<User>): User {
  // changes 里可以只传要修改的字段，其他字段不用传
  const user: User = {
    id: 1,
    name: "张三",
    email: "zhang@test.com",
    age: 28,
    isActive: true,
  };
  // 合并更新：用 changes 覆盖 user 中对应的属性
  return { ...user, ...changes };
}

const updated = updateUser(1, { name: "张伟", age: 29 });
console.log("部分更新后:", updated);
// { id: 1, name: '张伟', email: 'zhang@test.com', age: 29, isActive: true }

// -------------------- 2. Required<T>：所有属性变必填 --------------------
// 关键：-? 移除可选修饰符
type MyRequired<T> = {
  [K in keyof T]-?: T[K];
};

interface Config {
  host?: string;
  port?: number;
  debug?: boolean;
}

type FullConfig = Required<Config>;
// { host: string; port: number; debug: boolean; } —— 全部变成必填

const fullConfig: FullConfig = {
  host: "localhost",
  port: 8080,
  debug: true,
}; // 三个属性一个都不能少

console.log("\n完整配置:", fullConfig);

// -------------------- 3. MyReadonly<T>：所有属性变只读 --------------------
// 关键：在 [K in keyof T] 前面加 readonly
type MyReadonly<T> = {
  readonly [K in keyof T]: T[K];
};

type ReadonlyUser = MyReadonly<User>;

const readUser: ReadonlyUser = {
  id: 1,
  name: "只读用户",
  email: "readonly@test.com",
  age: 30,
  isActive: true,
};

console.log("\n只读用户:", readUser.name);
// readUser.name = "新名字"; // 编译错误！readonly 属性不可修改

// -------------------- 4. Pick<T, K>：挑出指定的几个属性 --------------------
// K extends keyof T：只能挑 T 里存在的键
type MyPick<T, K extends keyof T> = {
  [P in K]: T[P];
};

// 只挑出 Product 的 id 和 name
type ProductSummary = Pick<Product, "id" | "name">;
// { id: number; name: string; }

const summary: ProductSummary = { id: 101, name: "无线耳机" };
console.log("\n商品摘要:", summary);

// 挑出 User 的联系方式相关字段
type UserContact = Pick<User, "email" | "name">;
const contact: UserContact = { name: "李四", email: "lisi@test.com" };
console.log("用户联系方式:", contact);

// -------------------- 5. Omit<T, K>：排除指定的属性（和 Pick 相反）--------------------
// Omit 也是内置类型，这里展示手动实现
type MyOmit<T, K extends keyof T> = {
  [P in Exclude<keyof T, K>]: T[P];
};

// 排除 age 和 isActive
type UserWithoutSensitive = MyOmit<User, "age" | "email">;
// { id: number; name: string; isActive: boolean; }

// -------------------- 6. Record<K, V>：创建键值映射 --------------------
type MyRecord<K extends keyof any, V> = {
  [P in K]: V;
};

// 三个角色，每个对应一个布尔权限
type Role = "admin" | "editor" | "viewer";
type Permissions = Record<Role, boolean>;

const permissions: Permissions = {
  admin: true,
  editor: true,
  viewer: false,
};

console.log("\n权限映射:", permissions);

// 更实用的例子：产品状态映射
type ProductStatus = "draft" | "published" | "archived";
type StatusLabel = Record<ProductStatus, string>;

const labels: StatusLabel = {
  draft: "草稿",
  published: "已发布",
  archived: "已归档",
};

console.log("状态标签:", labels);

// -------------------- 7. 修饰符操作：-readonly 移除只读、-? 移除可选 --------------------
// 有时候你需要把只读的变可写、可选的变必填
type Mutable<T> = {
  -readonly [K in keyof T]: T[K]; // 移除 readonly
};

type Concrete<T> = {
  [K in keyof T]-?: T[K]; // 移除 ?
};

// 测试：把 { readonly name: string; age?: number } 变成可写且必填
type ReadonlyAndOptional = {
  readonly title: string;
  description?: string;
};
type FullyMutable = Mutable<Concrete<ReadonlyAndOptional>>;
// { title: string; description: string; }

// -------------------- 8. 键重映射（Key Remapping）--------------------
// 用 as 关键字给映射出的键改名
type EventHandlers = {
  click: () => void;
  hover: () => void;
  keydown: (key: string) => void;
};

// 给所有属性名加上 on 前缀，并首字母大写
type PrefixedHandlers = {
  [K in keyof EventHandlers as `on${Capitalize<string & K>}`]: EventHandlers[K];
};
// { onClick: () => void; onHover: () => void; onKeydown: (key: string) => void; }

const handlers: PrefixedHandlers = {
  onClick: () => console.log("点击了"),
  onHover: () => console.log("悬停了"),
  onKeydown: (key: string) => console.log(`按下了 ${key}`),
};

console.log("\n事件处理器:");
handlers.onClick();
handlers.onHover();
handlers.onKeydown("Enter");

// -------------------- 9. 条件映射：过滤掉非字符串类型的属性 --------------------
// 映射类型 + as + never（排除某个键）可以做到"过滤"
type OnlyStringProps<T> = {
  [K in keyof T as T[K] extends string ? K : never]: T[K];
};

// 从 User 中只挑出值为 string 类型的属性
type UserStringProps = OnlyStringProps<User>;
// { name: string; email: string; }

console.log("\nUser 中的字符串属性被提取出来了（只能有 name 和 email）");

// ============================================================
// 动手试试答案：
//   interface Product { id: number; name: string; price: number; description: string; }
//   function createDraft(p: Partial<Product>): Partial<Product> { return p; }
//   type ProductSummary = Pick<Product, "id" | "name">;
//   type ProductStatusMap = Record<"success" | "error" | "pending", Product>;
//   type MyReadonly<T> = { readonly [K in keyof T]: T[K] };
// ============================================================
