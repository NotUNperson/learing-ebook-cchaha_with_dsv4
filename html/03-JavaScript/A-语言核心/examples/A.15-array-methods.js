/**
 * A.15 数组常用方法 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.15-array-methods.js
 */

// ============================================================
// 1. map -- 流水线加工：每个元素变成新东西
// ============================================================

console.log("========== map ==========");

const numbers = [1, 2, 3, 4, 5];

// 每个数字乘以 2
const doubled = numbers.map(function(n) {
    return n * 2;
});
console.log("乘以 2:", doubled);  // [2, 4, 6, 8, 10]

// 箭头函数写法（更简洁）
const squared = numbers.map(n => n * n);
console.log("平方:", squared);   // [1, 4, 9, 16, 25]

// 提取对象数组中的属性
const users = [
    { name: "小明", age: 20 },
    { name: "小红", age: 22 },
    { name: "小刚", age: 18 }
];
const names = users.map(user => user.name);
console.log("提取名字:", names);  // ["小明", "小红", "小刚"]

// map 的回调参数：(元素, 索引, 原数组)
const withIndex = numbers.map((n, i) => `[${i}] ${n}`);
console.log("带索引:", withIndex);

// 原数组不会改变
console.log("原数组不变:", numbers);  // [1, 2, 3, 4, 5]

// ============================================================
// 2. filter -- 筛选符合条件的元素
// ============================================================

console.log("\n========== filter ==========");

const allNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// 筛选偶数
const evens = allNumbers.filter(n => n % 2 === 0);
console.log("偶数:", evens);  // [2, 4, 6, 8, 10]

// 筛选大于 5 的
const big = allNumbers.filter(n => n > 5);
console.log("大于 5:", big);  // [6, 7, 8, 9, 10]

// 筛选对象
const adults = users.filter(user => user.age >= 20);
console.log("成年人:", adults);  // [{小明,20}, {小红,22}]

// filter 也不改变原数组
console.log("原数组不变:", allNumbers);  // [1, 2, 3, ...]

// ============================================================
// 3. reduce -- 归并：滚雪球
// ============================================================

console.log("\n========== reduce ==========");

// 求和
const sum = numbers.reduce(function(acc, n) {
    console.log(`  acc=${acc}, n=${n} -> acc+n=${acc + n}`);
    return acc + n;
}, 0);
console.log("总和:", sum);  // 15

// 箭头函数简洁版
const sumArrow = numbers.reduce((acc, n) => acc + n, 0);
console.log("总和（箭头）:", sumArrow);  // 15

// reduce 其他用途
console.log("\n--- reduce 的其他用途 ---");

// 求乘积
const product = numbers.reduce((acc, n) => acc * n, 1);
console.log("乘积:", product);  // 120

// 求最大值
const max = [3, 7, 2, 9, 1, 5].reduce((acc, n) => n > acc ? n : acc, -Infinity);
console.log("最大值:", max);  // 9

// 求最小值
const min = [3, 7, 2, 9, 1, 5].reduce((acc, n) => n < acc ? n : acc, Infinity);
console.log("最小值:", min);  // 1

// 统计元素出现次数
const items = ["苹果", "香蕉", "苹果", "橙子", "香蕉", "苹果"];
const countMap = items.reduce((acc, item) => {
    acc[item] = (acc[item] || 0) + 1;
    return acc;
}, {});
console.log("统计次数:", countMap);  // { 苹果: 3, 香蕉: 2, 橙子: 1 }

// 展平二维数组
const nested = [[1, 2], [3, 4], [5, 6]];
const flat = nested.reduce((acc, row) => acc.concat(row), []);
console.log("展平:", flat);  // [1, 2, 3, 4, 5, 6]

// 不传初始值：用第一个元素作为初始值
const noInitial = [1, 2, 3, 4].reduce((acc, n) => {
    console.log(`  acc=${acc}, n=${n}`);
    return acc + n;
});
console.log("无初始值求和:", noInitial);  // 10
// 注意：第一次调用时 acc=1（第一个元素），n=2（第二个元素）

// ============================================================
// 4. find / findIndex -- 找到第一个
// ============================================================

console.log("\n========== find / findIndex ==========");

const data = [10, 20, 30, 40, 50];

const found = data.find(n => n > 25);
console.log("第一个 > 25:", found);  // 30

const notFound = data.find(n => n > 100);
console.log("找不存在的:", notFound);  // undefined

// findIndex 返回索引
console.log("第一个 > 25 的索引:", data.findIndex(n => n > 25));    // 2
console.log("找不存在的索引:", data.findIndex(n => n > 100));       // -1

// ============================================================
// 5. some / every -- 存在判断 / 全部判断
// ============================================================

console.log("\n========== some / every ==========");

const scores = [85, 92, 78, 60, 95];

// some：至少有一个吗？
console.log("有 >= 90 分的吗？", scores.some(s => s >= 90));   // true
console.log("有 < 50 分的吗？", scores.some(s => s < 50));     // false

// every：全部满足吗？
console.log("全部 >= 60 吗？", scores.every(s => s >= 60));    // true
console.log("全部 >= 80 吗？", scores.every(s => s >= 80));    // false

// some 和 every 的短路行为
// some 找到一个 true 就停止
// every 找到一个 false 就停止

// ============================================================
// 6. 链式调用 -- 方法组合
// ============================================================

console.log("\n========== 链式调用 ==========");

const students = [
    { name: "小明", score: 85 },
    { name: "小红", score: 92 },
    { name: "小刚", score: 45 },
    { name: "小丽", score: 78 },
    { name: "小华", score: 60 }
];

// 链式调用：筛选及格 -> 提取名字 -> 转大写
const passedNames = students
    .filter(s => s.score >= 60)       // 筛选及格的
    .map(s => s.name)                  // 提取名字
    .filter(name => name.length > 1)   // 名字长度 > 1
    .map(name => name.toUpperCase());  // 转大写

console.log("及格学生名单（大写）:", passedNames);

// 统计及格学生的平均分
const passedAverage = students
    .filter(s => s.score >= 60)
    .map(s => s.score)
    .reduce((sum, score, _, arr) => sum + score / arr.length, 0);

console.log("及格学生平均分:", passedAverage);  // 78.75

// 一步式：统计全部学生的总分
const totalScore = students.reduce((acc, s) => acc + s.score, 0);
console.log("总分:", totalScore);  // 360
console.log("平均分:", totalScore / students.length);  // 72

// ============================================================
// 7. 实战练习：数据处理
// ============================================================

console.log("\n========== 实战：数据处理流水线 ==========");

// 场景：处理一组数字
const raw = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// 流水线：取偶数 -> 乘以 3 -> 取大于 10 的 -> 求和
const result = raw
    .filter(n => n % 2 === 0)    // [2, 4, 6, 8, 10]
    .map(n => n * 3)              // [6, 12, 18, 24, 30]
    .filter(n => n > 10)          // [12, 18, 24, 30]
    .reduce((sum, n) => sum + n, 0);  // 84

console.log("流水线结果:", result);  // 84

// 分组功能：用 reduce 实现 groupBy
console.log("\n--- 用 reduce 实现 groupBy ---");

function groupBy(arr, keyFn) {
    return arr.reduce((groups, item) => {
        const key = keyFn(item);
        if (!groups[key]) {
            groups[key] = [];
        }
        groups[key].push(item);
        return groups;
    }, {});
}

// 按年龄分组
const groupedByAge = groupBy(users, user => user.age >= 20 ? "成年" : "未成年");
console.log("按年龄分组:", JSON.stringify(groupedByAge, null, 2));

// ============================================================
// 8. 方法速查
// ============================================================

console.log("\n========== 方法速查 ==========");
console.log("map      - 每个元素加工，返回新数组");
console.log("filter   - 筛选符合条件的元素");
console.log("reduce   - 归并成一个值（滚雪球）");
console.log("find     - 找到第一个符合条件的元素");
console.log("findIndex- 找到第一个符合条件的索引");
console.log("some     - 至少有一个符合？返回布尔");
console.log("every    - 全部符合？返回布尔");
console.log("\n以上方法都不改变原数组");

// ============================================================
// 小结：
// - map：每条数据进流水线，出来变了样
// - filter：筛子，符合条件的留下
// - reduce：滚雪球，数组→单个值（最强大）
// - find：找到第一个，some/every：布尔判断
// - 链式调用：.filter().map().reduce() 组合使用
// - 这些方法接受回调，体现函数是一等公民
// ============================================================
