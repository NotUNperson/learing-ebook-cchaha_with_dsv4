/**
 * A.12 作用域与闭包 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.12-scope.js
 */

// ============================================================
// 1. 词法作用域 -- 作用域在写代码时就决定了
// ============================================================

console.log("========== 词法作用域 ==========");

let globalName = "全局小明";  // 全局作用域

function outer() {
    let outerName = "外层小强";  // outer 函数作用域

    function inner() {
        let innerName = "内层小红";  // inner 函数作用域
        console.log("inner 可以访问:", innerName, outerName, globalName);
    }

    inner();
    // console.log(innerName);  // 报错！外层无法访问内层变量
}

outer();
// console.log(outerName);  // 报错！全局无法访问 outer 内部变量

// ============================================================
// 2. 块作用域（let/const）vs 函数作用域（var）
// ============================================================

console.log("\n========== 块作用域 vs 函数作用域 ==========");

// let/const：块作用域
{
    let blockLet = "let 在块内";
    const blockConst = "const 在块内";
    console.log("块内可以访问:", blockLet, blockConst);
}
// console.log(blockLet);  // 报错！let 变量在块外不可见

// var：没有块作用域
{
    var blockVar = "var 可以逃出块";
}
console.log("块外可以访问 var:", blockVar);  // "var 可以逃出块"

// var 只被函数边界限制
function testVar() {
    var insideFunction = "var 在函数内";
    console.log(insideFunction);
}
testVar();
// console.log(insideFunction);  // 报错！var 在函数外不可见

// ============================================================
// 3. 闭包 -- 函数记住诞生时的环境
// ============================================================

console.log("\n========== 闭包（核心概念） ==========");

// 最基础的闭包示例
function createCounter() {
    let count = 0;  // count 是 createCounter 的局部变量

    // 返回一个函数，这个函数"记住"了 count
    return function() {
        count++;
        return count;
    };
}

const counter1 = createCounter();
console.log("counter1():", counter1());  // 1
console.log("counter1():", counter1());  // 2
console.log("counter1():", counter1());  // 3

// counter2 有自己独立的 count 变量
const counter2 = createCounter();
console.log("counter2():", counter2());  // 1
console.log("counter2():", counter2());  // 2

// counter1 不受 counter2 影响
console.log("counter1():", counter1());  // 4

console.log("\ncounter1 和 counter2 各有各的'背包'，互不影响");

// ============================================================
// 4. 闭包的用途：数据私有
// ============================================================

console.log("\n========== 闭包用途 1：数据私有 ==========");

function createPerson(name, age) {
    // name 和 age 是私有的，外部无法直接访问
    return {
        getName: function() {
            return name;
        },
        getAge: function() {
            return age;
        },
        haveBirthday: function() {
            age++;
            console.log(name + " 过生日了！现在 " + age + " 岁");
        },
        greet: function() {
            console.log("你好，我是" + name);
        }
    };
}

const person = createPerson("小明", 20);
console.log("名字:", person.getName());  // "小明"
console.log("年龄:", person.getAge());    // 20
person.greet();                            // "你好，我是小明"
person.haveBirthday();                     // "小明 过生日了！现在 21 岁"
console.log("新年龄:", person.getAge());   // 21

// 无法直接访问私有变量
console.log("直接访问 person.name:", person.name);  // undefined

// ============================================================
// 5. 闭包的用途：工厂函数
// ============================================================

console.log("\n========== 闭包用途 2：工厂函数 ==========");

function createMultiplier(factor) {
    return function(n) {
        return n * factor;  // factor 被闭包记住
    };
}

const double = createMultiplier(2);
const triple = createMultiplier(3);
const tenTimes = createMultiplier(10);

console.log("double(5) =", double(5));        // 10
console.log("triple(5) =", triple(5));        // 15
console.log("tenTimes(5) =", tenTimes(5));    // 50

// ============================================================
// 6. 闭包经典面试题：循环中的闭包
// ============================================================

console.log("\n========== 循环中的闭包（面试题） ==========");

// 问题代码（用 var）：
console.log("--- 用 var（问题）---");
for (var i = 0; i < 3; i++) {
    // 注意：我们模拟 setTimeout 的行为，直接调用函数
    const fn = function() {
        console.log("var 循环 i =", i);
    };
    // fn 不会立即执行，但如果延迟执行，所有 fn 都会输出 3
}
// 演示：所有函数引用的是同一个 i
console.log("循环结束后的 i:", i);  // 3

// 解决方案 1：闭包（ES6 之前）
console.log("\n--- 解决方案 1：闭包捕获 ---");
for (var j = 0; j < 3; j++) {
    (function(capturedJ) {
        // 立即执行函数，capturedJ 被闭包捕获
        console.log("闭包捕获 j =", capturedJ);  // 0, 1, 2
    })(j);
}

// 解决方案 2：用 let（ES6，最简单！）
console.log("\n--- 解决方案 2：用 let（推荐）---");
for (let k = 0; k < 3; k++) {
    console.log("let 循环 k =", k);  // 0, 1, 2
}
// let 每次迭代创建新的绑定，天然就是"闭包"效果

// ============================================================
// 7. 深入理解闭包：背包类比
// ============================================================

console.log("\n========== 深入理解：背包类比 ==========");

function createBackpack(initialValue) {
    console.log("创建背包，初始值:", initialValue);
    let content = initialValue;

    return {
        put: function(item) {
            console.log("放入了:", item);
            content += ", " + item;
        },
        peek: function() {
            console.log("背包里的东西:", content);
            return content;
        }
    };
}

const myBackpack = createBackpack("书");
// 此时 createBackpack 已经执行完毕了，但...

myBackpack.peek();           // "背包里的东西: 书"
myBackpack.put("铅笔");      // "放入了: 铅笔"
myBackpack.peek();           // "背包里的东西: 书, 铅笔"
myBackpack.put("笔记本");    // "放入了: 笔记本"
myBackpack.peek();           // "背包里的东西: 书, 铅笔, 笔记本"

// myBackpack 一直可以访问 content 变量，
// 即使 createBackpack 早就执行完了！
// 这就是闭包——函数把变量"背"走了

// ============================================================
// 8. 闭包实战：银行账户
// ============================================================

console.log("\n========== 实战：银行账户 ==========");

function createBankAccount(owner, initialBalance) {
    let balance = initialBalance;  // 私有变量——余额

    return {
        getOwner: () => owner,
        getBalance: () => balance,
        deposit: (amount) => {
            if (amount > 0) {
                balance += amount;
                console.log(`${owner} 存入 ${amount} 元，余额: ${balance}`);
            } else {
                console.log("存款金额必须大于 0");
            }
        },
        withdraw: (amount) => {
            if (amount > 0 && amount <= balance) {
                balance -= amount;
                console.log(`${owner} 取出 ${amount} 元，余额: ${balance}`);
            } else if (amount > balance) {
                console.log("余额不足！当前余额:", balance);
            } else {
                console.log("取款金额必须大于 0");
            }
        }
    };
}

const aliceAccount = createBankAccount("Alice", 1000);
aliceAccount.deposit(500);   // "Alice 存入 500 元，余额: 1500"
aliceAccount.withdraw(200);  // "Alice 取出 200 元，余额: 1300"
aliceAccount.withdraw(2000); // "余额不足！当前余额: 1300"
console.log("当前余额:", aliceAccount.getBalance());  // 1300
// console.log(aliceAccount.balance);  // undefined -- 无法直接访问！

// ============================================================
// 小结：
// - 词法作用域：作用域在写代码时就决定
// - let/const 有块作用域，var 只有函数作用域
// - 闭包 = 函数 + 它记住的外部变量（"背包"）
// - 闭包用于：数据私有、工厂函数、回调
// - 理解闭包是 JS 进阶的基石
// ============================================================
