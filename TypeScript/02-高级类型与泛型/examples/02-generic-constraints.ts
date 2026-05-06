// ============================================================
// 02 泛型约束 — 示例代码
// 演示用 extends 限定泛型参数必须满足的条件
// ============================================================

// -------------------- 1. 基础约束：T 必须拥有 length 属性 --------------------
// 没有约束的话，T 可以是 number（没有 length），编译报错
// 用 T extends { length: number } 告诉 TS：T 必须有 length 属性
function getLength<T extends { length: number }>(obj: T): number {
  return obj.length;
}

// string 有 length 属性 —— 通过
console.log("string length:", getLength("Hello World")); // 11

// 数组有 length 属性 —— 通过
console.log("array length:", getLength([1, 2, 3, 4, 5])); // 5

// 自定义对象只要有 length 属性也能通过
console.log("custom object:", getLength({ length: 10, color: "red" })); // 10

// getLength(123); // 编译错误：number 类型没有 length 属性

// -------------------- 2. 约束特定属性的存在 --------------------
// 有时你需要的不只是 length，而是更具体的属性
interface HasName {
  name: string;
}

// T 必须是一个包含 name: string 的对象
function greet<T extends HasName>(obj: T): string {
  // TS 知道 obj 一定有 name，所以可以安全访问
  return `你好，${obj.name}！`;
}

console.log(greet({ name: "小明" }));       // 你好，小明！
console.log(greet({ name: "小红", age: 18 })); // 你好，小红！—— 多的属性不影响

// greet({ age: 18 }); // 编译错误：缺少 name 属性

// -------------------- 3. 用类型参数约束另一个类型参数 --------------------
// K extends keyof T：K 必须是 T 的某个键名
// 这保证了我们不会用不存在的键去访问对象
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const user = {
  id: 1001,
  name: "张三",
  email: "zhangsan@example.com",
  isAdmin: false,
};

console.log("用户姓名:", getProperty(user, "name"));     // "张三" (string)
console.log("用户邮箱:", getProperty(user, "email"));    // "zhangsan@example.com" (string)
console.log("是否管理员:", getProperty(user, "isAdmin")); // false (boolean)
console.log("用户ID:", getProperty(user, "id"));          // 1001 (number)

// getProperty(user, "age"); // 编译错误：'age' 不是 user 的属性

// -------------------- 4. 约束 + 多个类型参数 --------------------
// T 必须有 length，同时函数的第二个参数也必须是同样的类型
function longerOne<T extends { length: number }>(a: T, b: T): T {
  return a.length >= b.length ? a : b;
}

console.log("更长的字符串:", longerOne("hi", "hello"));     // "hello"
console.log("更长的数组:", longerOne([1, 2], [3, 4, 5])); // [3, 4, 5]

// longerOne("hi", [1, 2]); // 编译错误：T 不能同时是 string 又是 number[]

// -------------------- 5. 多重约束 — 用 & 连接 --------------------
// T 必须同时满足 HasName 和 HasAge
interface HasAge {
  age: number;
}

function introduce<T extends HasName & HasAge>(person: T): string {
  return `${person.name} 今年 ${person.age} 岁。`;
}

const student = { name: "李华", age: 20, grade: "大三" };
console.log(introduce(student)); // 李华 今年 20 岁。

// introduce({ name: "王五" }); // 编译错误：缺少 age 属性

// -------------------- 6. 对比 C++ concept --------------------
// C++20 写法（伪代码，不可在 TS 中运行）：
// template<typename T>
//   requires has_length<T>   // concept 约束
// T getLengthCpp(T obj) { return obj.length; }
//
// 相同点：都是编译期检查，防止不符合条件的调用
// 不同点：
//   - TS 基于结构类型（属性存在即可），C++ concept 更接近名义类型+编译谓词
//   - TS extends 还可以做条件类型（后面的章节），C++ requires 只做约束
//   - TS 更声明式、直观，C++ 更强大但也更复杂

// ============================================================
// 动手试试答案：
//   function longest<T extends { length: number }>(a: T, b: T): T {
//     return a.length > b.length ? a : b;
//   }
//   longest("hi", "hello") -> "hello"
//   longest([1, 2], [3, 4, 5]) -> [3, 4, 5]
// ============================================================
