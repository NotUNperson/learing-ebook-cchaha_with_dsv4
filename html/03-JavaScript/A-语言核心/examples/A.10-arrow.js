/**
 * A.10 箭头函数 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.10-arrow.js
 */

// ============================================================
// 1. 箭头函数基本语法
// ============================================================

console.log("========== 箭头函数基本语法 ==========");

// 普通函数表达式
const addNormal = function(a, b) {
    return a + b;
};
console.log("普通函数:", addNormal(3, 5));  // 8

// 箭头函数（完整版）
const addArrow = (a, b) => {
    return a + b;
};
console.log("箭头函数（完整版）:", addArrow(3, 5));  // 8

// ============================================================
// 2. 简洁写法规则
// ============================================================

console.log("\n========== 简洁写法规则 ==========");

// 规则 1：只有一行 return 时，省略 {} 和 return
const add = (a, b) => a + b;
console.log("简洁版 add:", add(3, 5));  // 8

const multiply = (a, b) => a * b;
console.log("简洁版 multiply:", multiply(4, 5));  // 20

// 规则 2：只有一个参数时，可以省略参数的括号
const square = x => x * x;
console.log("square(5):", square(5));  // 25

const double = x => x * 2;
console.log("double(7):", double(7));  // 14

// 规则 3：没有参数时，必须写空括号
const sayHello = () => console.log("Hello!");
sayHello();

const getRandomNumber = () => Math.random();
console.log("random:", getRandomNumber());

// 规则 4：多行函数体必须用 {}，必须写 return
const calculateArea = (width, height) => {
    const area = width * height;
    const message = `宽 ${width} x 高 ${height} = 面积 ${area}`;
    console.log(message);
    return area;
};
console.log("面积:", calculateArea(10, 5));

// 规则 5：返回对象字面量时用 () 包裹
// 错误写法（被当成函数体）：
// const createPerson = (name, age) => { name: name, age: age };

// 正确写法：
const createPerson = (name, age) => ({ name, age });
console.log("createPerson:", createPerson("小明", 25));  // { name: '小明', age: 25 }

// ============================================================
// 3. 箭头函数和普通函数的 this 区别
// ============================================================

console.log("\n========== this 的区别 ==========");

// 在 Node.js 中，模块顶层 this 是空对象 {}
console.log("模块顶层 this:", this);

const person = {
    name: "小明",

    // 普通函数：this 指向调用者 (person 对象)
    greetNormal: function() {
        console.log("普通函数 - 你好，" + this.name);
    },

    // 箭头函数：this 继承自外层作用域（定义时的 this，不是 person）
    greetArrow: () => {
        console.log("箭头函数 - 你好，" + this.name);
        // this 是模块顶层的 {} 所以 this.name 是 undefined
    },

    // 在对象中，可以先用普通函数，内部用箭头函数
    greetDelayed: function() {
        // 普通函数中 this 是 person
        console.log("延迟问候 - 准备中...");

        // 模拟定时器回调（实际编码中常见场景）
        // 箭头函数的 this 继承自 greetDelayed 的 this（person）
        const innerArrow = () => {
            console.log("箭头回调 - 你好，" + this.name);
        };

        // 普通函数的 this 会丢失
        const innerNormal = function() {
            console.log("普通回调 - 你好，" + this.name);
        };

        innerArrow();   // this.name = "小明" -- 继承自外层
        innerNormal();  // this.name = undefined -- 调用者不是 person
    }
};

person.greetNormal();    // 普通函数 - 你好，小明
person.greetArrow();     // 箭头函数 - 你好，undefined
person.greetDelayed();   // innerArrow: 你好，小明 / innerNormal: 你好，undefined

// ============================================================
// 4. 箭头函数在数组方法中的优势
// ============================================================

console.log("\n========== 箭头函数在数组方法中 ==========");

const numbers = [1, 2, 3, 4, 5];

// 用普通函数
const squared1 = numbers.map(function(n) {
    return n * n;
});
console.log("平方（普通函数）:", squared1);

// 用箭头函数（简洁得多！）
const squared2 = numbers.map(n => n * n);
console.log("平方（箭头函数）:", squared2);

// 链式操作
const result = numbers
    .filter(n => n % 2 === 0)  // 取偶数 [2, 4]
    .map(n => n * 10);          // 乘 10 [20, 40]
console.log("链式操作:", result);

// ============================================================
// 5. 箭头函数不能做什么
// ============================================================

console.log("\n========== 箭头函数的限制 ==========");

// 不能用作构造函数
const PersonArrow = (name) => {
    this.name = name;
};
// const p = new PersonArrow("小明");  // TypeError: PersonArrow is not a constructor
console.log("箭头函数不能用 new 调用");

// 没有 arguments 对象
const showArgs = (...args) => {
    // 但可以用剩余参数 ...args
    console.log("剩余参数替代 arguments:", args);
};
showArgs(1, 2, 3);  // [1, 2, 3]

// ============================================================
// 6. 实用对比：何时用箭头函数 vs 普通函数
// ============================================================

console.log("\n========== 实际应用场景 ==========");

// 场景 1：数组处理 —— 用箭头函数
const names = ["alice", "bob", "charlie"];
const capitalized = names.map(name => name.charAt(0).toUpperCase() + name.slice(1));
console.log("首字母大写:", capitalized);

// 场景 2：对象方法 —— 用普通函数
const calculator = {
    value: 0,
    add: function(n) {
        this.value += n;
        return this;
    },
    getValue: function() {
        return this.value;
    }
};

calculator.add(5).add(10).add(3);
console.log("calculator 的值:", calculator.getValue());  // 18

// 场景 3：简短的条件函数 —— 用箭头函数
const isEven = n => n % 2 === 0;
const isPositive = n => n > 0;

console.log("10 是偶数吗？", isEven(10));      // true
console.log("-5 是正数吗？", isPositive(-5));  // false

// ============================================================
// 小结：
// - 箭头函数是函数表达式的简写：const f = (x) => x * 2;
// - 单行 return 可省 {} 和 return
// - 单参数可省 ()
// - 箭头函数的 this 继承自外层（词法绑定）
// - 短小逻辑、数组方法用箭头；对象方法用普通函数
// ============================================================
