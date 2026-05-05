// ============================================================
// A.20 构造函数与 new 示例代码
// 运行方式：node examples/A.20-constructor.js
// ============================================================

console.log("========== A.20 构造函数与 new ==========\n");

// ----------------------------------------------------------
// 1. 基本构造函数——用 new 创建对象
// ----------------------------------------------------------
console.log("1. 基本构造函数：");

// 构造函数首字母大写（约定，非强制）
function User(name, age) {
    // 这里的 this 指向新创建的对象实例
    this.name = name;
    this.age = age;
    this.introduce = function () {
        return `我叫 ${this.name}，${this.age} 岁`;
    };
}

const u1 = new User("张三", 20);
const u2 = new User("李四", 22);

console.log("  u1:", u1);
console.log("  u2:", u2);
console.log("  u1.introduce():", u1.introduce());
console.log("  u2.introduce():", u2.introduce());

// ----------------------------------------------------------
// 2. new 做了哪四件事——手动模拟
// ----------------------------------------------------------
console.log("\n2. 模拟 new 做的事情：");

function myNew(constructor, ...args) {
    // 第1步：创建一个空对象
    const obj = {};

    // 第2步：把这个空对象的 __proto__ 指向构造函数的 prototype
    Object.setPrototypeOf(obj, constructor.prototype);

    // 第3步：用 call 把 this 绑定到空对象，执行构造函数
    const result = constructor.call(obj, ...args);

    // 第4步：如果构造函数返回了对象，就用那个；否则返回空对象
    return typeof result === "object" && result !== null ? result : obj;
}

// 用我们自己的 myNew 创建对象
const u3 = myNew(User, "王五", 25);
console.log("  手动 new 创建:", u3);
console.log("  u3.introduce():", u3.introduce());

// ----------------------------------------------------------
// 3. 方法应该放在 prototype 上——避免每个实例都创建函数
// ----------------------------------------------------------
console.log("\n3. 共享方法 vs 实例方法：");

// 对比：构造函数内定义方法 vs prototype 上定义方法
function Animal(name) {
    this.name = name;
    this.eat = function () {
        // 每个实例都会创建一个新的 eat 函数
        return `${this.name} 在吃东西`;
    };
}

// prototype 上的方法——所有实例共享一个函数
Animal.prototype.sleep = function () {
    return `${this.name} 在睡觉`;
};

const a1 = new Animal("小猫");
const a2 = new Animal("小狗");

// eat 是每个实例独有的——不同函数
console.log("  eat 是同一个函数吗？", a1.eat === a2.eat);  // false！浪费内存

// sleep 是所有实例共享的——同一个函数
console.log("  sleep 是同一个函数吗？", a1.sleep === a2.sleep); // true！节省内存

console.log("  a1.sleep():", a1.sleep());
console.log("  a2.sleep():", a2.sleep());

// ----------------------------------------------------------
// 4. instanceof——判断对象是否由某个构造函数创建
// ----------------------------------------------------------
console.log("\n4. instanceof 检查：");

function Book(title, author) {
    this.title = title;
    this.author = author;
}

const book1 = new Book("三体", "刘慈欣");
const book2 = { title: "活着", author: "余华" };  // 字面量创建

console.log("  book1 instanceof Book:", book1 instanceof Book);     // true
console.log("  book2 instanceof Book:", book2 instanceof Book);     // false
console.log("  book1 instanceof Object:", book1 instanceof Object); // true（一切皆对象）

// ----------------------------------------------------------
// 5. 忘记 new 的陷阱与防御
// ----------------------------------------------------------
console.log("\n5. 忘记 new 的防御：");

// 有防御的构造函数
function Student(name, grade) {
    // 如果调用者忘了 new，this 不是 Student 的实例
    if (!(this instanceof Student)) {
        // 自动补上 new，返回正确的结果
        console.log("    检测到忘记 new，自动补充");
        return new Student(name, grade);
    }
    this.name = name;
    this.grade = grade;
}

// 忘了 new——但有防御，不会出错
const s1 = Student("小明", "大一");  // 没写 new
console.log("  忘记 new（有防御）:", s1);

// 正确使用 new
const s2 = new Student("小红", "大二");
console.log("  正确使用 new:", s2);

// 结论：构造函数首字母大写是一个强烈的视觉提示——看到大写就想起 new

// ----------------------------------------------------------
// 6. 构造函数里返回对象会怎样
// ----------------------------------------------------------
console.log("\n6. 构造函数返回值：");

function NormalCtor() {
    this.value = 42;
    return "hello";  // 返回原始值——忽略
}
console.log("  返回字符串:", new NormalCtor()); // { value: 42 }，忽略字符串

function ObjectCtor() {
    this.value = 42;
    return { override: true };  // 返回对象——覆盖 this
}
console.log("  返回对象:", new ObjectCtor()); // { override: true }，覆盖了

// 日常开发中几乎不会在构造函数里写 return，知道有这回事就行

// ----------------------------------------------------------
// 7. 实践：一个完整的构造函数模式
// ----------------------------------------------------------
console.log("\n7. 综合实践——产品管理：");

function Product(name, price, category) {
    this.name = name;
    this.price = price;
    this.category = category;
    this.createdAt = new Date();  // 自动记录创建时间
}

// 共享方法放在 prototype 上
Product.prototype.getInfo = function () {
    return `[${this.category}] ${this.name} - ¥${this.price}`;
};

Product.prototype.discount = function (percent) {
    this.price = this.price * (1 - percent / 100);
    return this;  // 返回 this 支持链式调用
};

const p1 = new Product("机械键盘", 399, "数码");
const p2 = new Product("JavaScript 高级程序设计", 89, "图书");

console.log("  p1:", p1.getInfo());
console.log("  p2:", p2.getInfo());

// 打折
p1.discount(20);
console.log("  p1 打8折后:", p1.getInfo());

console.log("\n========== 构造函数与 new 演示结束 ==========");
