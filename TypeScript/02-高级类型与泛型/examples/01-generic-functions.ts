// ============================================================
// 01 泛型函数 — 示例代码
// 演示 <T> 语法、类型推断、多个类型参数、手动指定类型参数
// ============================================================

// -------------------- 1. 不用泛型的痛苦 --------------------
// 为每种类型写一个函数，逻辑完全一样，只是类型不同
function firstNumber(arr: number[]): number {
  return arr[0];
}

function firstString(arr: string[]): string {
  return arr[0];
}

// 如果用 any，类型信息就丢了
function firstAny(arr: any[]): any {
  return arr[0];
}

const a = firstAny([1, 2, 3]); // a 的类型是 any，编译器不知道它是 number
// a.toFixed(2); // 语法上不会报错，但运行时可能出问题，因为 a 可能是 string

// -------------------- 2. 泛型函数 — 一次定义，多种类型 --------------------
// <T> 声明了一个类型变量 T，arr 是 T[]，返回值也是 T
function first<T>(arr: T[]): T {
  return arr[0];
}

// TypeScript 会根据传入的数组自动推导 T 是什么
const n1 = first([10, 20, 30]);     // n1: number  — T 被推导为 number
const s1 = first(["x", "y", "z"]);  // s1: string  — T 被推导为 string
const b1 = first([true, false]);    // b1: boolean — T 被推导为 boolean

console.log("first number:", n1);   // 10
console.log("first string:", s1);   // x
console.log("first boolean:", b1);  // true

// 对比 C++：
// template<typename T>
// T first(const std::vector<T>& arr) { return arr[0]; }
// 相同：都用占位符 T，都是编译期推导类型
// 不同：TS 泛型编译为 JS 后 T 被擦除，不生成多份代码

// -------------------- 3. 多个类型参数 --------------------
// 可以声明多个类型变量，比如 A 和 B
function makePair<A, B>(firstVal: A, secondVal: B): [A, B] {
  return [firstVal, secondVal];
}

const pair1 = makePair("score", 100);   // [string, number]
const pair2 = makePair(true, new Date()); // [boolean, Date]

console.log("pair1:", pair1); // ["score", 100]
console.log("pair2:", pair2); // [true, 2026-05-06...]

// -------------------- 4. 多个同类型参数 --------------------
// 两个参数都用同一个 T，保证类型一致
function areEqual<T>(a: T, b: T): boolean {
  return a === b;
}

console.log("areEqual(1, 2):", areEqual(1, 2));          // false
console.log("areEqual('hi', 'hi'):", areEqual("hi", "hi")); // true
// areEqual(1, "1"); // 编译报错：T 不能同时是 number 又 string

// -------------------- 5. 手动指定类型参数 --------------------
// 大部分情况编译器能推导，但有时需要手动指定
function createArray<T>(length: number, fill: T): T[] {
  // 创建一个长度为 length 的数组，用 fill 填充每一项
  return new Array(length).fill(fill);
}

// 手动指定 T 为 string
const names1 = createArray<string>(3, "hello"); // string[]
console.log("names1:", names1); // ["hello", "hello", "hello"]

// 编译器推导也 OK
const nums1 = createArray(4, 0); // number[]
console.log("nums1:", nums1); // [0, 0, 0, 0]

// -------------------- 6. 泛型 + 箭头函数 --------------------
// 箭头函数也可以用泛型，<T> 写在参数括号前面
const identity = <T>(value: T): T => {
  return value;
};

const idNum = identity(42);      // number
const idStr = identity("hello"); // string
console.log("identity number:", idNum, "| identity string:", idStr);

// -------------------- 7. 返回元组的泛型函数 --------------------
// 把数组拆成 [first, ...rest] 的形式
function splitHead<T>(arr: T[]): [T, T[]] {
  const [head, ...tail] = arr;
  return [head, tail];
}

const [head, tail] = splitHead([1, 2, 3, 4]);
console.log("head:", head, "| tail:", tail); // head: 1 | tail: [2, 3, 4]

// ============================================================
// 动手试试答案：
//   1. function last<T>(arr: T[]): T { return arr[arr.length - 1]; }
//   2. function swap<T>(tuple: [T, T]): [T, T] { return [tuple[1], tuple[0]]; }
// ============================================================
