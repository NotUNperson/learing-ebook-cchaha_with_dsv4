// ============================================================
// A.16 对象字面量 示例代码
// 运行方式：node examples/A.16-objects.js
// ============================================================

console.log("========== A.16 对象字面量 ==========\n");

// ----------------------------------------------------------
// 1. 对象字面量创建——最基础的创建方式
// ----------------------------------------------------------
// 类比：填写一张个人信息表，每个字段对应一个键值对
const person = {
    name: "张三",   // 字符串类型的值
    age: 20,        // 数字类型的值
    job: "学生",    // 最后一个属性后面可以加逗号（尾随逗号，推荐加上）
};

console.log("1. 基础对象：", person);
// 输出：{ name: '张三', age: 20, job: '学生' }

// ----------------------------------------------------------
// 2. 属性访问——点号 vs 方括号
// ----------------------------------------------------------

// 2.1 点号访问（最常用，推荐）
console.log("\n2. 属性访问：");
console.log("  点号访问 name:", person.name);   // "张三"
console.log("  点号访问 age:", person.age);     // 20

// 2.2 方括号访问——键名是字符串，可以是变量
console.log("  方括号访问 name:", person["name"]); // "张三"

// 方括号的真正威力：键名可以来自变量！
const fieldName = "job";  // 这个变量的值在运行时才确定
console.log(`  动态键 ${fieldName}:`, person[fieldName]); // "学生"

// 什么情况下必须用方括号？
// - 属性名包含特殊字符（如空格、连字符）
// - 属性名是数字
// - 属性名存储在变量中
const specialObj = {
    "first-name": "John",  // 带连字符的属性名
    "123": "数字属性",
};
// console.log(specialObj.first-name);  // 语法错误！会解释为 (specialObj.first) - name
console.log('  特殊属性名 "first-name":', specialObj["first-name"]); // "John"
console.log('  数字属性名 "123":', specialObj["123"]);               // "数字属性"

// ----------------------------------------------------------
// 3. 属性值简写（ES6）——变量名就是属性名
// ----------------------------------------------------------
// 场景：你已经有了一堆变量，想装进对象
console.log("\n3. 属性值简写：");

const name = "李四";
const age = 22;
const city = "北京";

// 老写法——又臭又长
const oldWay = {
    name: name,
    age: age,
    city: city,
};
console.log("  老写法:", oldWay);

// ES6 简写——清爽
const newWay = { name, age, city };
console.log("  简写法:", newWay);
// 两者结果完全一样：{ name: '李四', age: 22, city: '北京' }

// ----------------------------------------------------------
// 4. 方法简写（ES6）——对象里的函数叫"方法"
// ----------------------------------------------------------
console.log("\n4. 方法简写：");

// 老写法：属性名 : function() {}
const calculator1 = {
    add: function(a, b) {
        return a + b;
    },
};

// ES6 简写：直接写函数名()
const calculator2 = {
    add(a, b) {     // 省略了冒号和 function 关键字
        return a + b;
    },
};

console.log("  老写法 3 + 5 =", calculator1.add(3, 5));  // 8
console.log("  简写法 3 + 5 =", calculator2.add(3, 5));  // 8

// ----------------------------------------------------------
// 5. this 关键字初探——方法里引用对象自身
// ----------------------------------------------------------
console.log("\n5. this 关键字初探：");

const student = {
    name: "王五",
    grade: "大一",
    // 方法中使用 this 引用当前对象
    introduce() {
        // this.name 就是 student.name
        return `我叫 ${this.name}，读 ${this.grade}`;
    },
    // 方法中可以修改对象自身的属性
    upgrade() {
        this.grade = "大二";
        console.log(`  ${this.name} 升级了！现在是 ${this.grade}`);
    },
};

console.log("  " + student.introduce()); // "我叫 王五，读 大一"
student.upgrade();                        // "王五 升级了！现在是 大二"

// ----------------------------------------------------------
// 6. 对象的值可以是任意类型——包括数组、函数、甚至另一个对象
// ----------------------------------------------------------
console.log("\n6. 嵌套对象和混合类型：");

const user = {
    name: "赵六",
    hobbies: ["编程", "篮球", "吉他"],       // 数组
    // 嵌套对象
    address: {
        city: "上海",
        street: "南京路 100 号",
    },
    // 值可以是函数（方法）
    showHobbies() {
        console.log(`  ${this.name} 的爱好：`);
        // forEach 遍历数组
        this.hobbies.forEach((hobby, index) => {
            console.log(`    ${index + 1}. ${hobby}`);
        });
    },
};

console.log("  用户:", user);
user.showHobbies();

// ----------------------------------------------------------
// 7. 与 C struct 的关键区别示例
// ----------------------------------------------------------
console.log("\n7. JS 对象可以在运行时随时增删属性（C struct 做不到）：");

const dynamic = { x: 1, y: 2 };
console.log("  初始:", dynamic);  // { x: 1, y: 2 }

// 随时添加新属性
dynamic.z = 3;
console.log("  添加 z 后:", dynamic);  // { x: 1, y: 2, z: 3 }

// 随时删除属性
delete dynamic.x;
console.log("  删除 x 后:", dynamic);  // { y: 2, z: 3 }

// 甚至可以把函数作为属性加进去
dynamic.sayHello = function() {
    console.log("  Hello！我是动态添加的方法");
};
dynamic.sayHello();  // 调用动态添加的方法

console.log("\n========== 对象字面量 演示结束 ==========");
