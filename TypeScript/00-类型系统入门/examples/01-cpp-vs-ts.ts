// ==========================================
// 01-cpp-vs-ts.ts
// 演示 TypeScript 与 C++ 的关键差异
// ==========================================

export {};  // 让这个文件成为一个独立的模块，避免全局作用域冲突

// --- C++ 对比 ---
// C++ 里你需要 include 头文件，写 main 函数，最后 return 0。
// TypeScript 不需要这些——代码从上到下直接执行。

// --- 1. 变量声明：可以显式标注类型，也可以不标注 ---

// 显式标注类型——类似 C++ 的 string name = "Alice";
// 不同点：类型写在冒号后面，而不是变量名前
let userName: string = "Alice";

// 不标注类型——TypeScript 会自动"猜"出这是 string
// C++ 里你也可以用 auto，但 auto 是编译期推导，和这里机制不同
let message = "Hello, World!";

// --- 2. 打印输出 ---
// console.log 类似 C++ 的 std::cout，但不需要 include 任何东西
console.log(message);
console.log("User name:", userName);

// --- 3. 变量可以随时改变类型？不，TypeScript 不允许 ---
// C++ 里 int a = 1; a = "hello"; 是编译错误。
// TypeScript 里如果不声明 any，改变类型也会报错：

let num = 42;          // TypeScript 推断 num 为 number 类型
// num = "hello";      // 取消注释这行，tsc 会报错：Type 'string' is not assignable to type 'number'.

// 但如果你用 any，就可以随便变——这就是"渐进类型"的"逃生舱"
let anything: any = 42;
anything = "hello";   // 没问题，因为 anything 是 any 类型
anything = true;      // 也没问题
console.log("anything 现在变成了:", anything);

// --- 4. 函数：不需要声明返回类型也可以 ---
// C++: int add(int a, int b) { return a + b; }
// TypeScript: 返回类型写在参数列表后面，不写也行（类型推断会推导出来）
function add(a: number, b: number): number {
    return a + b;
}

// 不写返回类型，TypeScript 也能推断出返回 number
function multiply(a: number, b: number) {
    return a * b;
}

console.log("2 + 3 =", add(2, 3));
console.log("4 * 5 =", multiply(4, 5));

// --- 5. 运行方式说明 ---
// 方式一：npx ts-node examples/01-cpp-vs-ts.ts
//   直接运行，不需要先手动编译
//
// 方式二：先编译再运行
//   npx tsc examples/01-cpp-vs-ts.ts   → 生成 01-cpp-vs-ts.js
//   node examples/01-cpp-vs-ts.js      → 运行生成的 JS 文件
//
// 打开生成的 .js 文件你会发现：所有类型标注（:string, :number 等）
// 全部消失了，因为 JavaScript 不认识这些标注。
