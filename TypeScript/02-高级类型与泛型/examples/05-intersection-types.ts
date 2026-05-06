// ============================================================
// 05 交叉类型 & — 示例代码
// 演示 & 合并多个类型、& 和 | 的区别、实际应用场景
// ============================================================

// -------------------- 1. 基础：& 把两个类型合成一个 --------------------
// Person 有 name，Employee 有 employeeId 和 department
// Person & Employee 必须三个属性都有
type Person = { name: string; age: number };
type Employee = { employeeId: number; department: string };

type EmployeePerson = Person & Employee;

// 必须同时提供三个属性，缺一不可
const zhangsan: EmployeePerson = {
  name: "张三",
  age: 28,
  employeeId: 1001,
  department: "技术部",
};

console.log("员工信息:", zhangsan);
// 输出：{ name: '张三', age: 28, employeeId: 1001, department: '技术部' }

// zhangsan 可以访问所有四个属性
console.log(`${zhangsan.name} 在 ${zhangsan.department} 工作`);

// -------------------- 2. 交叉 vs 联合：核心区别 --------------------
// | = "或"（满足其一即可）
// & = "且"（两个都要满足）

type Coder = { canCode: boolean; languages: string[] };
type Designer = { canDesign: boolean; tool: string };

// 联合：要么是 Coder，要么是 Designer
type TechStaff_Union = Coder | Designer;
const staff1: TechStaff_Union = { canCode: true, languages: ["TS"] };        // OK — Coder
const staff2: TechStaff_Union = { canDesign: true, tool: "Figma" };         // OK — Designer
// 但你不能直接访问 staff1.languages —— TS 不确定它是不是 Coder

// 交叉：既是 Coder 又是 Designer（全栈人才！）
type TechStaff_Intersection = Coder & Designer;
const fullStack: TechStaff_Intersection = {
  canCode: true,
  languages: ["TypeScript", "Python"],
  canDesign: true,
  tool: "Figma",
}; // 四个属性缺一不可

console.log("\n全栈工程师:", fullStack);
// fullStack 可以自由访问所有四个属性

// -------------------- 3. 乐高拼搭：组合多个小接口成大类型 --------------------
// 实战中常用的"混入(Mixin)"模式：把通用特性拆成小接口，用 & 拼

interface Timestamped {
  createdAt: Date;
  updatedAt: Date;
}

interface SoftDeletable {
  isDeleted: boolean;
  deletedAt?: Date;
}

interface Ownable {
  ownerId: number;
}

// 基础文章数据
interface ArticleData {
  id: number;
  title: string;
  content: string;
}

// 拼出完整的数据库文章模型
type FullArticle = ArticleData & Timestamped & SoftDeletable & Ownable;

const article: FullArticle = {
  id: 1,
  title: "TypeScript 交叉类型入门",
  content: "交叉类型用 & 来合并多个类型...",
  createdAt: new Date("2026-01-01"),
  updatedAt: new Date("2026-05-01"),
  isDeleted: false,
  ownerId: 42,
  // deletedAt 是可选的，不用提供
};

console.log("\n文章:", article.title);
console.log("创建时间:", article.createdAt.toLocaleDateString());

// -------------------- 4. 交叉类型 + 泛型：给泛型"附加"属性 --------------------
// 一个实用模式：给泛型数据加上时间戳
function addTimestamp<T>(data: T): T & Timestamped {
  const now = new Date();
  return {
    ...data,
    createdAt: now,
    updatedAt: now,
  };
}

const userData = { id: 1, name: "李四" };
const userWithTimestamp = addTimestamp(userData);
console.log("\n带时间戳的用户:", userWithTimestamp);
// 类型是 { id: number; name: string } & Timestamped

// -------------------- 5. 属性冲突：基本类型冲突 -> never --------------------
type A = { value: string };
type B = { value: number };

// A & B 的 value 属性类型是 string & number
// string & number 不可能存在，结果就是 never
type Conflict = A & B;

// 你永远没法给 Conflict 的 value 赋值
// const conf: Conflict = { value: ??? }; // 没有一个值能同时是 string 又 number

// 实际中应避免属性冲突

// -------------------- 6. 对比 C++ --------------------
// C++ 多重继承：
// class Flyable { public: void fly(); };
// class Swimmable { public: void swim(); };
// class Duck : public Flyable, public Swimmable {};
//
// 相同点：组合多个"组件"的能力
// 不同点：
//   - C++ 组合的是行为（方法实现），TS 组合的是结构（属性形状）
//   - C++ 有菱形继承问题，TS 交叉类型不存在此问题
//   - TS & 是纯编译期概念，不生成运行时代码

// ============================================================
// 动手试试答案：
//   interface CanWalk { walk(): string; }
//   interface CanSwim { swim(): string; }
//   interface CanFly { fly(): string; }
//   type SuperAnimal = CanWalk & CanSwim & CanFly;
//
//   const superDuck: SuperAnimal = {
//     walk() { return "鸭子走路"; },
//     swim() { return "鸭子游泳"; },
//     fly() { return "鸭子飞翔"; },
//   };
// ============================================================
