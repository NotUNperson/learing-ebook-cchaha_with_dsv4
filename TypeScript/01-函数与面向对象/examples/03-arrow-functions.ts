/**
 * 03-arrow-functions.ts
 * 主题：箭头函数 () => {}
 *
 * 本节演示箭头函数的基本语法、简写规则，
 * 并与 C++ lambda 表达式进行对比，
 * 同时简单介绍 this 绑定的区别。
 */

// ==================== 基本语法 ====================

/**
 * 传统函数写法
 * 关键字 function + 函数名 + 参数 + 函数体
 */
function oldDouble(n: number): number {
    return n * 2;
}

/**
 * 箭头函数写法
 * 参数 => 函数体
 * 读作："n goes to n * 2"，即"接收 n，返回 n 乘以 2"
 *
 * 对比 C++ lambda: [](int n) { return n * 2; }
 * - TypeScript 没有捕获列表 []
 * - TypeScript 有显式的 => 箭头
 * - 类型标注位置不同（n: number vs int n）
 */
const arrowDouble = (n: number): number => {
    return n * 2;
};

console.log("oldDouble(5) =", oldDouble(5));       // 输出: 10
console.log("arrowDouble(5) =", arrowDouble(5));   // 输出: 10


// ==================== 简写规则 ====================

/**
 * 规则一：函数体只有一行表达式时，省略 {} 和 return
 *
 * 完整写法：(n: number): number => { return n * 2; }
 * 简写：    (n: number): number => n * 2;
 *
 * 不带大括号时，=> 后面的表达式结果自动作为返回值
 */
const shortDouble = (n: number): number => n * 2;
console.log("shortDouble(5) =", shortDouble(5));   // 输出: 10


/**
 * 规则二：只有一个参数时，可以省略参数的括号 ()
 *
 * 带括号：(x: number) => x * x
 * 省略括号：x => x * x（类型标注也可以省略，让 TypeScript 推断）
 */
const square = (x: number) => x * x;
console.log("square(6) =", square(6));             // 输出: 36

// 没有参数时，括号不能省——必须是 () => ...
const sayHello = () => "Hello!";
console.log(sayHello());                           // 输出: Hello!

// 多个参数时，括号也不能省
const add = (a: number, b: number) => a + b;
console.log("add(3, 7) =", add(3, 7));            // 输出: 10


/**
 * 规则三：一个参数 + 单行表达式 + 省略类型 = 最简洁形式
 * 这种写法在数组操作中非常常见
 */
const triple = (x: number) => x * 3;
console.log("triple(4) =", triple(4));             // 输出: 12


// ==================== 数组操作中的箭头函数 ====================

const scores = [85, 92, 78, 95, 88, 55, 43];

/**
 * filter：筛选符合条件的元素
 * 这里筛选出大于等于 60 的分数（及格线）
 */
const passed = scores.filter((s: number) => s >= 60);
console.log("及格的分数:", passed);  // 输出: [85, 92, 78, 95, 88]


/**
 * map：对每个元素做变换
 * 这里把每个分数加 5 分
 */
const curved = scores.map((s: number) => s + 5);
console.log("加分后的分数:", curved);
// 输出: [90, 97, 83, 100, 93, 60, 48]


/**
 * reduce：将数组归约为一个值
 * 这里计算总分
 * - (sum, s) => sum + s  ：累加器函数
 * - 0                     ：初始值
 */
const total = scores.reduce((sum, s) => sum + s, 0);
console.log("总分:", total);  // 输出: 536


/**
 * 链式调用：map + filter + reduce 一条龙
 * 步骤：平方 → 筛选出 > 5000 的 → 求和
 */
const result = scores
    .map(s => s * s)           // [7225, 8464, 6084, 9025, 7744, 3025, 1849]
    .filter(sq => sq > 5000)   // [7225, 8464, 6084, 9025, 7744]
    .reduce((sum, sq) => sum + sq, 0);

console.log("平方后大于5000的分数之和:", result);  // 输出: 38542


// ==================== 箭头函数 this 行为 ====================

/**
 * 普通函数的 this：取决于谁调用了这个函数
 */
const normalPerson = {
    name: "小红",
    greet: function () {
        console.log("[普通函数] 你好，我是" + this.name);
    }
};

normalPerson.greet();  // 输出: [普通函数] 你好，我是小红


/**
 * 箭头函数 vs 普通函数的 this 行为
 *
 * 普通函数的 this：取决于谁调用了这个函数（动态绑定）
 * 箭头函数的 this：取决于定义时的外层作用域（词法绑定）
 *
 * 对比 C++：
 * - 普通函数的 this 类似 C++ 的隐式 this 指针——谁调用指向谁
 * - 箭头函数的 this 类似 C++ lambda 的 [this] 捕获——定义时锁定
 *
 * 下面的示例使用普通 function 方法来演示正确的 this 绑定：
 * 普通 function 方法中的 this 会自动指向调用者（即 arrowPerson 对象）
 */
const arrowPerson = {
    name: "小明",
    // 使用普通 function 作为方法——this 在调用时自动指向 arrowPerson
    greet: function () {
        console.log("[普通函数方法] 你好，我是" + this.name);
    },
    // 使用箭头函数作为方法——不推荐！
    // 因为箭头函数的 this 是词法绑定的，在顶层作用域 this 不指向 arrowPerson
    greetArrow: () => {
        // 这里的 this 指向的是定义 arrowPerson 时的外层作用域的 this
        // 在模块顶层，this 可能是 undefined 或 globalThis
        console.log("[箭头函数方法] this.name 不可用（this 不在我们期望的对象上）");
    }
};

arrowPerson.greet();
// 输出: [普通函数方法] 你好，我是小明

arrowPerson.greetArrow();
// 输出: [箭头函数方法] this.name 不可用（this 不在我们期望的对象上）


/**
 * 实际场景：箭头函数在回调中保持 this
 *
 * 这是箭头函数真正有用的场景——
 * 在 setTimeout 等回调中，普通函数的 this 会丢失，
 * 箭头函数的 this 保持和外层一致
 */
const counter = {
    count: 0,
    // 普通函数作为方法（这里用普通函数是对的）
    start: function () {
        // 箭头函数回调：this 和外层（start 函数）的 this 一致
        // 所以 this.count 可以正确访问到 counter.count
        setInterval(() => {
            this.count++;
            console.log("计数:", this.count);
        }, 1000);
    }
};

// 如果你想要试试，取消下面的注释（注意它会一直运行）：
// counter.start();


// ==================== 多行箭头函数 ====================

/**
 * 当函数体有多行时，必须使用 {} 和 return
 * 不能使用简写形式
 */
const calculateGrade = (score: number): string => {
    // 多行逻辑：必须用大括号包裹
    if (score >= 90) {
        return "A";
    } else if (score >= 80) {
        return "B";
    } else if (score >= 70) {
        return "C";
    } else if (score >= 60) {
        return "D";
    } else {
        return "F";
    }
};

console.log("95 分 →", calculateGrade(95));   // 输出: A
console.log("72 分 →", calculateGrade(72));   // 输出: C
console.log("58 分 →", calculateGrade(58));   // 输出: F
