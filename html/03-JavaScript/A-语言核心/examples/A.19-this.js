// ============================================================
// A.19 this 关键字 示例代码
// 运行方式：node examples/A.19-this.js
// ============================================================

console.log("========== A.19 this 关键字 ==========\n");

// ----------------------------------------------------------
// 1. 默认绑定——独立函数调用
// ----------------------------------------------------------
console.log("1. 默认绑定——独立函数调用：");

function showThis() {
    "use strict";  // 显式声明严格模式
    console.log("  独立调用 this:", this);  // undefined
}
showThis();

// Node.js 的 ES 模块默认严格模式，独立调用 this === undefined
// 注意：在浏览器非严格模式下，this 会是 window 对象

// ----------------------------------------------------------
// 2. 隐式绑定——"谁调用的就指向谁"
// ----------------------------------------------------------
console.log("\n2. 隐式绑定——点号前面的对象：");

const student = {
    name: "张三",
    age: 20,
    introduce() {
        console.log(`  我叫 ${this.name}，今年 ${this.age} 岁`);
    },
    // 方法中修改自身
    birthday() {
        this.age += 1;
        console.log(`  ${this.name} 过生日了，现在 ${this.age} 岁`);
    },
};

student.introduce();  // this = student
student.birthday();   // this = student（age 从 20 变为 21）

// ----------------------------------------------------------
// 3. 隐式丢失——this 丢失的经典陷阱
// ----------------------------------------------------------
console.log("\n3. 隐式丢失——把方法赋值给变量后调用：");

const fn = student.introduce;  // 把方法"摘"下来
// fn();  // 如果运行这行，this 是 undefined（独立调用），访问 this.name 会报错

console.log("  (fn() 会导致 TypeError，因为 this 是 undefined）");
console.log("  解决方式1：用 bind 绑定");
const boundFn = student.introduce.bind(student);
boundFn();  // 正确，this 绑定到了 student

// 另一个常见陷阱：回调函数
console.log("\n  setTimeout 回调中的 this 丢失：");

const counter = {
    count: 0,
    start() {
        // 普通函数作为回调——this 丢失
        setTimeout(function () {
            // this 是 undefined（严格模式独立调用）或全局对象
            console.log("    普通回调 this.count:", this && this.count);
        }, 10);

        // 箭头函数作为回调——this 继承自 start() 的 this
        setTimeout(() => {
            this.count++;
            console.log("    箭头回调 this.count:", this.count);  // 1
        }, 20);
    },
};

counter.start();

// ----------------------------------------------------------
// 4. 显式绑定——call / apply / bind
// ----------------------------------------------------------
console.log("\n4. 显式绑定——call / apply / bind：");

function greet(greeting, punctuation) {
    console.log(`  ${greeting}，我是 ${this.name}${punctuation}`);
}

const user1 = { name: "李四" };
const user2 = { name: "王五" };

// call——逐个传参：call(对象, 参数1, 参数2, ...)
console.log("  call 方式：");
greet.call(user1, "大家好", "！");

// apply——数组传参：apply(对象, [参数1, 参数2, ...])
console.log("  apply 方式：");
greet.apply(user2, ["早上好", "。"]);

// bind——不立即执行，返回绑定后的新函数
console.log("  bind 方式：");
const greetLi = greet.bind(user1, "你好");  // 还可以预绑定参数
greetLi("~");   // 调用时只需传剩余参数
greetLi("..."); // 可以反复使用

// 记忆口诀：call 逗号传，apply 数组传，bind 绑了再传

// ----------------------------------------------------------
// 5. 箭头函数的 this——从定义处外层继承
// ----------------------------------------------------------
console.log("\n5. 箭头函数的 this 继承：");

const team = {
    name: "火箭队",
    members: ["小明", "小红", "小刚"],
    // 普通方法
    printMembersWrong() {
        // 普通函数 forEach 回调——this 丢失
        this.members.forEach(function (member) {
            // this 是 undefined，this.name 报错
            // console.log(`  ${member} 属于 ${this.name}`);
        });
        console.log("  普通回调：this 丢失，无法访问 this.name");
    },
    // 箭头函数方法——正确
    printMembersRight() {
        // 箭头函数没有自己的 this，从 printMembersRight 继承
        this.members.forEach((member) => {
            console.log(`  ${member} 属于 ${this.name}`);
        });
    },
    // 另一种解决方案：保存 this
    printMembersSaveThis() {
        const self = this;  // 老派做法：把 this 存到变量里
        this.members.forEach(function (member) {
            console.log(`  ${member} (self方式) 属于 ${self.name}`);
        });
    },
};

team.printMembersWrong();
team.printMembersRight();
team.printMembersSaveThis();

// ----------------------------------------------------------
// 6. this 绑定优先级演示
// ----------------------------------------------------------
console.log("\n6. 绑定优先级：");

const obj = {
    name: "对象A",
    show() {
        console.log(`  this.name = ${this.name}`);
    },
};

const anotherObj = { name: "对象B" };

// 隐式绑定 vs 显式绑定——显式绑定更高
console.log("  隐式调用 + 显式绑定（call 赢）:");
obj.show.call(anotherObj);  // 输出"对象B"，call 覆盖了隐式绑定

// bind 返回的函数是"硬绑定"，之后的 call 也无法覆盖
const hardBound = obj.show.bind(anotherObj);
hardBound.call(obj);  // 仍然是"对象B"，bind 的优先级最高

// ----------------------------------------------------------
// 7. 综合示例：事件处理中的 this（模拟）
// ----------------------------------------------------------
console.log("\n7. 综合示例——模拟事件处理器：");

class Button {
    constructor(label) {
        this.label = label;
        this.clickCount = 0;
    }

    // 普通方法——适合作为事件处理器（但注意 this 丢失问题）
    handleClick() {
        this.clickCount++;
        console.log(`  按钮"${this.label}"被点击了 ${this.clickCount} 次`);
    }

    // 箭头函数属性——this 永远绑定到实例（一种常见模式）
    handleClickArrow = () => {
        this.clickCount++;
        console.log(`  [箭头] 按钮"${this.label}"被点击了 ${this.clickCount} 次`);
    };
}

const btn = new Button("提交");
// 模拟事件触发——直接调用方法
btn.handleClick();        // 隐式绑定，this = btn
btn.handleClickArrow();   // 箭头函数，this 始终是 btn

// 模拟回调场景——把方法传递给别人的情况
const callback = btn.handleClick;
// callback();  // 报错！this 丢失
const callbackArrow = btn.handleClickArrow;
callbackArrow();  // 正确！箭头函数的 this 永远绑定到定义时的实例

console.log("\n========== this 关键字 演示结束 ==========");
