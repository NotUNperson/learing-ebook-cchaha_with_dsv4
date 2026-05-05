/**
 * A.14 数组基础 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.14-arrays-basic.js
 */

// ============================================================
// 1. 创建数组
// ============================================================

console.log("========== 创建数组 ==========");

// 字面量（推荐！）
const fruits = ["苹果", "香蕉", "橙子"];
console.log("水果数组:", fruits);

const numbers = [1, 2, 3, 4, 5];
console.log("数字数组:", numbers);

const empty = [];  // 空数组
console.log("空数组:", empty);

// 混合类型——JS 数组可以存任何类型
const mixed = [1, "hello", true, null, { name: "小明" }, [1, 2]];
console.log("混合类型数组:", mixed);

// 构造函数方式（了解即可）
const arr1 = new Array(3);       // [empty × 3]，不是 [3]！
console.log("new Array(3):", arr1, "长度:", arr1.length);

const arr2 = new Array(1, 2, 3); // [1, 2, 3]
console.log("new Array(1, 2, 3):", arr2);

// ============================================================
// 2. 索引访问
// ============================================================

console.log("\n========== 索引访问 ==========");

const snacks = ["薯片", "巧克力", "饼干", "果冻"];

console.log("snacks[0]:", snacks[0]);   // "薯片"
console.log("snacks[1]:", snacks[1]);   // "巧克力"
console.log("snacks[3]:", snacks[3]);   // "果冻"

// 越界访问——返回 undefined，不报错！
console.log("snacks[10]:", snacks[10]);     // undefined
console.log("snacks[-1]:", snacks[-1]);     // undefined（不支持负数索引）

// 修改元素
snacks[1] = "棒棒糖";
console.log("修改后:", snacks);  // ["薯片", "棒棒糖", "饼干", "果冻"]

// 添加元素（通过索引）
snacks[4] = "瓜子";  // 在索引 4 处添加
console.log("添加后:", snacks);  // ["薯片", "棒棒糖", "饼干", "果冻", "瓜子"]

// ============================================================
// 3. length 属性 -- 可读可写！
// ============================================================

console.log("\n========== length 属性 ==========");

const list = [1, 2, 3, 4, 5];
console.log("原始数组:", list, "长度:", list.length);  // 5

// 截断数组
list.length = 3;
console.log("length = 3 后:", list);  // [1, 2, 3]

// 清空数组
list.length = 0;
console.log("length = 0 后:", list);  // []
console.log("长度:", list.length);    // 0

// 扩大 length 创建空位
const padded = [1, 2];
padded.length = 5;
console.log("扩大 length 后:", padded);  // [1, 2, <3 empty items>]
console.log("padded[3]:", padded[3]);    // undefined

// ============================================================
// 4. 遍历数组的方式
// ============================================================

console.log("\n========== 遍历数组 ==========");

const colors = ["红", "黄", "蓝", "绿"];

// 方式 1：经典 for 循环（C 风格）
console.log("--- 经典 for ---");
for (let i = 0; i < colors.length; i++) {
    console.log(`  [${i}] ${colors[i]}`);
}

// 方式 2：for-of（推荐！）
console.log("\n--- for-of（推荐）---");
for (let color of colors) {
    console.log("  " + color);
}

// 方式 3：forEach（函数式）
console.log("\n--- forEach ---");
colors.forEach(function(color, index) {
    console.log(`  [${index}] ${color}`);
});

// 箭头函数版 forEach（更简洁）
console.log("\n--- forEach 箭头函数版 ---");
colors.forEach((color, i) => {
    console.log(`  ${i}: ${color}`);
});

// 方式 4：不要用 for-in！
console.log("\n--- for-in（不要用于数组！）---");
for (let key in colors) {
    console.log(`  key: ${key} (类型: ${typeof key})`);  // "0", "1", ... 是字符串！
}

// ============================================================
// 5. JS 数组 vs C 数组的本质区别
// ============================================================

console.log("\n========== JS 数组的灵活性 ==========");

// 混合类型——C 语言做不到
const everything = [
    42,
    "hello",
    true,
    null,
    undefined,
    { name: "小明" },
    [1, 2, 3],
    function() { return "我是函数！"; }
];

console.log("混合数组元素和类型:");
everything.forEach((item, i) => {
    console.log(`  [${i}] ${item} (${typeof item})`);
});

console.log("\n调用数组中的函数:", everything[7]());  // "我是函数！"

// ============================================================
// 6. 多维数组
// ============================================================

console.log("\n========== 多维数组 ==========");

// 二维数组（矩阵）
const matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
];

console.log("矩阵:");
console.log(`  [0][0] = ${matrix[0][0]}`);  // 1
console.log(`  [1][2] = ${matrix[1][2]}`);  // 6
console.log(`  [2][1] = ${matrix[2][1]}`);  // 8

// 遍历二维数组
console.log("\n遍历矩阵:");
for (let row of matrix) {
    let line = "";
    for (let cell of row) {
        line += cell + " ";
    }
    console.log("  " + line);
}

// 不规则二维数组（每行长度不同）
console.log("\n不规则二维数组（杨辉三角）:");
const triangle = [
    [1],
    [2, 3],
    [4, 5, 6],
    [7, 8, 9, 10]
];

for (let row of triangle) {
    console.log("  " + row.join(" "));
}

// ============================================================
// 7. 实用函数：创建二维数组
// ============================================================

console.log("\n========== 实用函数：创建二维数组 ==========");

function createMatrix(rows, cols, initialValue) {
    const matrix = [];
    for (let i = 0; i < rows; i++) {
        const row = [];
        for (let j = 0; j < cols; j++) {
            row.push(initialValue);
        }
        matrix.push(row);
    }
    return matrix;
}

const myMatrix = createMatrix(3, 4, 0);
console.log("3x4 全零矩阵:");
for (let row of myMatrix) {
    console.log("  " + row.join(" "));
}

// ============================================================
// 小结：
// - 用 [] 创建数组，不建议用 new Array()
// - 索引从 0 开始，越界返回 undefined
// - length 可读写，arr.length = 0 清空数组
// - 遍历：for-of（推荐）> forEach > 经典 for
// - JS 数组可以存任意类型，更像"列表"
// - 多维数组 = 数组套数组
// ============================================================
