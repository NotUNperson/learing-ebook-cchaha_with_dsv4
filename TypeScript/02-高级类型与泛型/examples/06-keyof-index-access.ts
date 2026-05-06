// ============================================================
// 06 keyof 与索引访问类型 — 示例代码
// 演示 keyof 提取键名、T[K] 获取值类型、两者的组合使用
// ============================================================

// -------------------- 1. keyof：提取所有键名 --------------------
// keyof 作用于一个类型，返回该类型所有键名组成的联合类型

interface User {
  id: number;
  name: string;
  email: string;
  isActive: boolean;
}

type UserKeys = keyof User;
// UserKeys = "id" | "name" | "email" | "isActive"

// 可以用它来限制函数参数
function getUserPropertyLabel(key: keyof User): string {
  // key 只能是 User 的实际键名
  return `查询字段: ${key}`;
}

console.log(getUserPropertyLabel("name"));   // OK: "查询字段: name"
console.log(getUserPropertyLabel("email"));  // OK: "查询字段: email"
// getUserPropertyLabel("age"); // 编译错误！"age" 不是 User 的键

// -------------------- 2. 索引访问类型 T[K]：获取值类型 --------------------
// T[K] 在类型层面"取出"某个键对应的值类型
// 注意：K 必须是类型（字面量类型），不能是运行时值

type UserNameType = User["name"];       // string
type UserIdType = User["id"];           // number
type UserActiveType = User["isActive"]; // boolean

// 可以声明一个符合该类型的变量
const userId: User["id"] = 42;        // number 类型
const userName: User["name"] = "小明"; // string 类型

console.log("ID 类型示例:", userId);
console.log("Name 类型示例:", userName);

// -------------------- 3. keyof + 泛型：类型安全的属性访问器 --------------------
// 这是 keyof 和索引访问用的最多的组合模式
// K extends keyof T 确保 key 是对象 T 的真实属性名
// T[K] 确保返回值类型和属性值类型精确匹配

function getValue<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const user: User = {
  id: 1,
  name: "张三",
  email: "zhangsan@example.com",
  isActive: true,
};

// 返回类型自动精确：传 "name" 返回 string，传 "id" 返回 number
const uName: string = getValue(user, "name");    // "张三"
const uId: number = getValue(user, "id");          // 1
const uActive: boolean = getValue(user, "isActive"); // true

console.log("\n--- 属性访问器 ---");
console.log("姓名:", uName);
console.log("ID:", uId);
console.log("活跃:", uActive);

// getValue(user, "age"); // 编译错误：'age' 不是 User 的属性

// -------------------- 4. T[keyof T]：获取所有值类型的联合 --------------------
// 不用指定具体的键，一次性取出"可能有哪些类型的值"

type UserValueTypes = User[keyof User];
// UserValueTypes = string | number | boolean

// 实战用法：写一个类型安全的属性更新函数
function updateProperty<T, K extends keyof T>(obj: T, key: K, value: T[K]): void {
  // T[K] 保证了 value 的类型和 obj[key] 完全一致
  obj[key] = value;
}

// 正确的更新
updateProperty(user, "name", "李四");    // OK: string -> string
updateProperty(user, "id", 100);         // OK: number -> number
updateProperty(user, "isActive", false); // OK: boolean -> boolean
// updateProperty(user, "name", 123);    // 编译错误！不能把 number 赋给 string 属性

console.log("\n--- 更新后 ---");
console.log("姓名:", user.name);       // 李四
console.log("ID:", user.id);           // 100
console.log("活跃:", user.isActive);   // false

// -------------------- 5. 嵌套对象的索引访问：链式 T[K1][K2] --------------------
// 可以像访问嵌套对象一样，链式获取深层类型

interface Company {
  name: string;
  address: {
    city: string;
    street: string;
    zipCode: string;
  };
}

// 获取嵌套属性的类型
type CityType = Company["address"]["city"]; // string
type AddressType = Company["address"];       // { city: string; street: string; zipCode: string }

const city: CityType = "北京";
console.log("\n城市:", city);

// -------------------- 6. 数组的 keyof 和索引访问 --------------------
// 数组本质上也是对象，键包括：数字索引 + 数组方法名

type StringArray = string[];

// keyof string[] 得到所有 key: length, push, pop, 0, 1, 2...
type ArrayKeys = keyof StringArray; // number | "length" | "push" | ...
// 最主要的键是 number（数字索引）

// 获取数组元素的类型：通过 number 索引
type ArrayElement = StringArray[number]; // string
// 这个技巧非常重要——从数组中提取元素类型

// 泛型版本：提取任意数组的元素类型
type ElementOf<T extends unknown[]> = T[number];

type StrElement = ElementOf<string[]>;  // string
type NumElement = ElementOf<number[]>;  // number
type BoolElement = ElementOf<boolean[]>; // boolean

console.log("\n数组元素类型提取:");
const arr: StrElement = "hello"; // OK，因为 StrElement = string

// -------------------- 7. 完整实战：字典（查词）类比 --------------------
// 像一个查字典的工具：keyof 列出所有词条，T[K] 给出释义

interface WordDict {
  apple: string;
  banana: string;
  cherry: string;
}

// 列出所有词条
type WordEntries = keyof WordDict; // "apple" | "banana" | "cherry"

// 类型安全的查字典函数
function lookup<T extends Record<string, string>, K extends keyof T>(
  dict: T,
  word: K
): T[K] {
  return dict[word];
}

const dict: WordDict = {
  apple: "苹果",
  banana: "香蕉",
  cherry: "樱桃",
};

console.log("\n--- 查字典 ---");
console.log('apple 的意思是:', lookup(dict, "apple"));   // "苹果"
console.log('cherry 的意思是:', lookup(dict, "cherry")); // "樱桃"
// lookup(dict, "orange"); // 编译错误！orange 不在词典中

// ============================================================
// 动手试试答案：
//   interface Product { id: number; name: string; price: number; inStock: boolean; }
//   type ProductKeys = keyof Product; // "id" | "name" | "price" | "inStock"
//   function getProductInfo(p: Product, key: ProductKeys): string {
//     return `${key}: ${p[key]}`;
//   }
// ============================================================
