// ==========================================
// 05-arrays-tuples.ts
// 演示 TypeScript 的数组（类似 C++ 的 vector）与元组
// ==========================================

export {};  // 让这个文件成为一个独立的模块，避免全局作用域冲突

// ==========================================
// 一、数组声明：两种写法，效果相同
// ==========================================

// 写法一：类型后加 []（最常用，推荐）
let scores: number[] = [100, 95, 88, 72, 66];
console.log("初始分数:", scores);

// 写法二：泛型写法 Array<T>（类似 C++ 模板 vector<T>）
let scores2: Array<number> = [100, 95, 88, 72, 66];
console.log("分数2 (泛型写法):", scores2);

// C++ 对比：
//   std::vector<int> scores = {100, 95, 80};
//   TypeScript 的 number[] 本质上就是 "元素都是 number 类型的 JavaScript 数组"

// ==========================================
// 二、数组常用操作
// ==========================================

let fruits: string[] = ["apple", "banana"];
console.log("初始水果:", fruits);

// push：尾部插入，类似 C++ vector 的 push_back
fruits.push("orange");
console.log("push orange 后:", fruits);

// pop：尾部删除并返回被删除的元素，类似 C++ 的 pop_back
let removed = fruits.pop();
console.log("pop 出的元素:", removed);
console.log("pop 后:", fruits);

// unshift：头部插入，C++ vector 没有直接对应（vector 头部插入效率低）
fruits.unshift("grape");
console.log("unshift grape 后:", fruits);

// shift：头部删除并返回，类似队列出队
let shifted = fruits.shift();
console.log("shift 出的元素:", shifted);
console.log("shift 后:", fruits);

// 下标访问
console.log("第一个水果:", fruits[0]);

// 长度属性（注意是 .length，不是 .size()，也不是函数调用）
console.log("水果数量:", fruits.length);

// 越界访问：返回 undefined，不会崩溃！这和 C++ 完全不同
// C++ 里 v[1000] 是未定义行为，可能导致程序崩溃
console.log("越界访问 fruits[100]:", fruits[100]);  // undefined

// ==========================================
// 三、数组的高阶操作：map、filter、find
// ==========================================

let numbers: number[] = [1, 2, 3, 4, 5];
console.log("\n原始数组:", numbers);

// map：把每个元素映射成一个新值，返回新数组（不修改原数组）
// n => n * 2 是箭头函数，相当于 C++ 的 [](int n) { return n * 2; }
let doubled = numbers.map(n => n * 2);
console.log("每个元素乘 2:", doubled);

// filter：保留满足条件的元素，返回新数组
let evens = numbers.filter(n => n % 2 === 0);
console.log("筛选偶数:", evens);

// find：找第一个满足条件的元素，返回单个值（不是数组）
let firstBig = numbers.find(n => n > 3);
console.log("第一个大于 3 的数:", firstBig);

// findIndex：找第一个满足条件的元素的索引
let indexBig = numbers.findIndex(n => n > 3);
console.log("第一个大于 3 的数的索引:", indexBig);

// includes：检查数组是否包含某个值
console.log("数组包含 3 吗:", numbers.includes(3));
console.log("数组包含 10 吗:", numbers.includes(10));

// sort：排序（默认按字符串排序，数字排序需要传比较函数）
let unsorted = [3, 1, 4, 1, 5, 9, 2, 6];
let sorted = [...unsorted].sort((a, b) => a - b);  // a - b 表示升序
// 注意：sort 会修改原数组！所以用 [...unsorted] 先做了个浅拷贝
console.log("排序前:", unsorted);
console.log("排序后:", sorted);

// slice：切片，类似 Python 的 list 切片
console.log("前 3 个元素:", numbers.slice(0, 3));  // [1, 2, 3]

// ==========================================
// 四、元组（Tuple）：固定长度的混合类型数组
// ==========================================

// 元组在运行时就是普通数组，但 TypeScript 在编译期检查每个位置的类型
// 声明元组：用方括号包裹各位置的类型
let user: [number, string, boolean] = [1, "Alice", true];
console.log("\n用户元组:", user);

// 下标访问时，TypeScript 知道每个位置的类型
let userId: number = user[0];      // user[0] 的类型是 number
let userName: string = user[1];    // user[1] 的类型是 string
let isVip: boolean = user[2];      // user[2] 的类型是 boolean
console.log(`ID: ${userId}, 姓名: ${userName}, VIP: ${isVip}`);

// 如果放错类型，编译期就会报错：
// user[0] = "hello";  // ❌ 错误！第 0 个位置应该是 number，不是 string

// C++ 对比：
//   std::tuple<int, string, bool> user = {1, "Alice", true};
//   auto id = std::get<0>(user);  // C++ 用 std::get<> 而不是下标
//
// 区别：
//   1. TS 元组运行时就是数组，C++ 的 std::tuple 是独立类型
//   2. TS 用下标访问，C++ 用 std::get<N>
//   3. TS 元组可以调用数组方法（push 等），C++ 不行

// 坐标点示例
let point: [number, number] = [10, 20];
console.log("坐标:", point);

// 日期元组：[年, 月(缩写), 日]
let date: [number, string, number] = [2024, "Jan", 15];
console.log(`日期: ${date[1]} ${date[2]}, ${date[0]}`);

// 元组的数组：多个坐标点
let polygon: [number, number][] = [
    [0, 0],
    [10, 0],
    [10, 10],
    [0, 10],
];
console.log("矩形顶点:", polygon);

// ==========================================
// 五、数组与元组的运行时真面目
// ==========================================
// 在转译成 JavaScript 后，数组和元组没有任何区别——都是 JS 数组。
// 类型信息只在编译期存在，运行时完全消失。
// 这意味着 typeof 检查数组和元组都会返回 "object"。
console.log("\ntypeof []:", typeof []);
console.log("typeof [1, 'a', true]:", typeof [1, "a", true]);
console.log("Array.isArray([1,2,3]):", Array.isArray([1, 2, 3]));
