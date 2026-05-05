/**
 * A.11 参数与返回值 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.11-params.js
 */

// ============================================================
// 1. 参数灵活：多了忽略，少了 undefined
// ============================================================

console.log("========== JS 参数的灵活性 ==========");

function greet(name) {
    console.log("你好，" + name);
}

greet("小明");           // "你好，小明"
greet();                  // "你好，undefined" -- 没传参数
greet("张三", "李四");   // "你好，张三" -- 多余参数被忽略

// JS 不会因为参数数量不匹配而报错

// ============================================================
// 2. 默认参数（ES6）
// ============================================================

console.log("\n========== 默认参数 ==========");

// ES6 默认参数——直接在参数列表中写 = 值
function greetWithDefault(name = "世界") {
    console.log("你好，" + name);
}

greetWithDefault("小明");      // "你好，小明"
greetWithDefault();             // "你好，世界" -- 默认值
greetWithDefault(undefined);    // "你好，世界" -- undefined 触发默认值
greetWithDefault(null);         // "你好，null" -- null 不会触发默认值！

// 多个默认参数
function createGreeting(greeting = "你好", name = "世界") {
    console.log(greeting + "，" + name);
}

createGreeting();                          // "你好，世界"
createGreeting("早上好");                  // "早上好，世界"
createGreeting("Good Morning", "Alice");   // "Good Morning，Alice"
createGreeting(undefined, "小明");         // "你好，小明" -- 第一个用默认值

// 默认参数可以使用前面的参数
function sum(a, b = a * 2) {
    return a + b;
}
console.log("sum(5) =", sum(5));       // 15 (5 + 10)
console.log("sum(5, 3) =", sum(5, 3)); // 8  (5 + 3)

// 默认参数也可以是函数调用
function getDefaultScore() {
    console.log("getDefaultScore 被调用了");
    return 60;
}
function calcScore(score = getDefaultScore()) {
    console.log("最终分数:", score);
}
calcScore(95);  // 不调用 getDefaultScore
calcScore();    // 调用 getDefaultScore —— 注意：每次调用时都会重新求值

// ============================================================
// 3. 剩余参数 ...args（Rest Parameters）
// ============================================================

console.log("\n========== 剩余参数 ...args ==========");

// 把剩余的所有参数收集到数组中
function sumAll(...numbers) {
    console.log("收到的参数数组:", numbers);
    let total = 0;
    for (let n of numbers) {
        total += n;
    }
    return total;
}

console.log("sumAll(1, 2, 3):", sumAll(1, 2, 3));                // 6
console.log("sumAll(10, 20, 30, 40):", sumAll(10, 20, 30, 40)); // 100
console.log("sumAll():", sumAll());                               // 0

// 剩余参数必须是最后一个参数
function logAll(tag, ...messages) {
    for (let msg of messages) {
        console.log("[" + tag + "]", msg);
    }
}

logAll("INFO", "服务器启动", "监听端口 3000", "等待连接");

// 因为 ...args 是真数组，可以直接用数组方法
function maxOf(...numbers) {
    if (numbers.length === 0) return undefined;
    return Math.max(...numbers);  // ... 也可以用作"展开"运算符
}
console.log("maxOf(3, 7, 2, 9, 1):", maxOf(3, 7, 2, 9, 1));  // 9

// ============================================================
// 4. arguments 对象（老式方法，了解即可）
// ============================================================

console.log("\n========== arguments 对象（老式方法） ==========");

function oldStyle() {
    console.log("传入参数个数:", arguments.length);
    for (let i = 0; i < arguments.length; i++) {
        console.log("  参数[" + i + "]:", arguments[i]);
    }
    // arguments 不是真正的数组！不能直接使用 forEach、map 等
    // 如果需要用数组方法，得先转换：
    // const argsArray = Array.from(arguments);
}

oldStyle(1, "hello", true);

// 箭头函数中没有 arguments！
const arrowFunc = () => {
    // console.log(arguments);  // 报错！箭头函数没有 arguments
    console.log("箭头函数中没有 arguments，请用 ...args");
};
arrowFunc(1, 2, 3);

// ============================================================
// 5. return -- 返回值与函数终止
// ============================================================

console.log("\n========== return 返回值 ==========");

// return 立即终止函数
function findFirstEven(numbers) {
    for (let n of numbers) {
        if (n % 2 === 0) {
            return n;  // 找到就立刻返回，循环提前结束
        }
    }
    return null;  // 没找到
}

console.log("findFirstEven([1,3,5,7,8,10]):", findFirstEven([1, 3, 5, 7, 8, 10])); // 8
console.log("findFirstEven([1,3,5,7]):", findFirstEven([1, 3, 5, 7]));             // null

// 没有 return 返回 undefined
function doSomething() {
    console.log("函数体执行了");
    // 没有 return 语句
}
let result = doSomething();
console.log("没有 return 的函数返回值:", result);  // undefined

// return 后面不写值也返回 undefined
function returnNothing() {
    return;
}
console.log("return 不带值:", returnNothing());  // undefined

// ============================================================
// 6. 返回多种类型 & 返回多个值
// ============================================================

console.log("\n========== 返回多种类型 ==========");

// 返回对象
function createPerson(name, age) {
    return { name, age };  // ES6 简写，等同于 { name: name, age: age }
}
console.log("createPerson:", createPerson("小明", 25));

// 返回数组
function splitName(fullName) {
    return fullName.split(" ");
}
console.log("splitName:", splitName("张三 三"));

// 返回函数（高阶函数）
function createAdder(base) {
    return function(n) {
        return base + n;
    };
}
const add5 = createAdder(5);
const add10 = createAdder(10);
console.log("add5(3) =", add5(3));     // 8
console.log("add10(3) =", add10(3));   // 13

// 返回多个值——装进对象
function getMinMax(numbers) {
    let min = Math.min(...numbers);
    let max = Math.max(...numbers);
    return { min, max };
}
let minMax = getMinMax([3, 1, 7, 5, 9]);
console.log("getMinMax:", minMax);  // { min: 1, max: 9 }
console.log("最小值:", minMax.min, "最大值:", minMax.max);

// 使用解构赋值接收多个返回值（ES6）
let { min, max } = getMinMax([10, 2, 8, 4]);
console.log(`最小值: ${min}, 最大值: ${max}`);  // 最小值: 2, 最大值: 10

// ============================================================
// 7. 综合示例：平均值函数
// ============================================================

console.log("\n========== 综合示例：平均值 ==========");

function average(...numbers) {
    if (numbers.length === 0) return 0;
    let total = 0;
    for (let n of numbers) {
        total += n;
    }
    return total / numbers.length;
}

console.log("average(80, 90, 100):", average(80, 90, 100));  // 90
console.log("average(1, 2, 3, 4, 5):", average(1, 2, 3, 4, 5));  // 3
console.log("average():", average());  // 0

// ============================================================
// 小结：
// - 参数个数可以不匹配，少了是 undefined，多了被忽略
// - 默认参数：function f(name = "默认")
// - 剩余参数 ...args 是数组，比 arguments 好
// - return 终止函数并返回，无 return 返回 undefined
// - 函数可以返回任何类型
// ============================================================
