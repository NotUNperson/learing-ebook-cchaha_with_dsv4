// ============================================================
// A.21 class 语法 示例代码
// 运行方式：node examples/A.21-class.js
// ============================================================

console.log("========== A.21 class 语法 ==========\n");

// ----------------------------------------------------------
// 1. 基本 class 定义——构造方法+方法
// ----------------------------------------------------------
console.log("1. 基本 class 定义：");

class User {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }

    greet() {
        return `你好，我是 ${this.name}，${this.age} 岁`;
    }

    // 方法可以调用其他方法
    introduce() {
        const greeting = this.greet();  // 用 this 调用同类方法
        return `${greeting}。很高兴认识你！`;
    }
}

// 用 new 创建实例——和构造函数完全一样
const u1 = new User("张三", 20);
const u2 = new User("李四", 25);

console.log("  u1.greet():", u1.greet());
console.log("  u2.introduce():", u2.introduce());

// 关键证明：class 本质就是 function
console.log("  typeof User:", typeof User);  // "function"！

// ----------------------------------------------------------
// 2. class 方法的本质——方法在原型上共享
// ----------------------------------------------------------
console.log("\n2. class 方法的本质——挂在原型上：");

console.log("  u1.greet === u2.greet:", u1.greet === u2.greet);  // true
console.log("  说明：所有实例共享同一个方法（在原型上）");

// 和构造函数+prototype 对比
function OldUser(name, age) {
    this.name = name;
    this.age = age;
}
OldUser.prototype.greet = function () {
    return `你好，我是 ${this.name}`;
};

const o1 = new OldUser("王五", 30);
const o2 = new OldUser("赵六", 35);
console.log("  old 方式的方法也是共享的:", o1.greet === o2.greet);  // true

// ----------------------------------------------------------
// 3. getter 和 setter
// ----------------------------------------------------------
console.log("\n3. getter 和 setter：");

class Circle {
    constructor(radius) {
        this._radius = radius;  // _ 前缀约定：这是内部属性
    }

    // getter——读取属性时自动调用
    get area() {
        return Math.PI * this._radius ** 2;
    }

    get diameter() {
        return this._radius * 2;
    }

    // setter——设置属性时自动调用
    set diameter(d) {
        console.log(`  [setter] 设置直径为 ${d}，计算半径...`);
        this._radius = d / 2;
    }

    // 普通方法
    describe() {
        return `半径 ${this._radius}，直径 ${this.diameter}，面积 ${this.area.toFixed(2)}`;
    }
}

const c = new Circle(5);
console.log("  " + c.describe());
// 输出：半径 5，直径 10，面积 78.54

// setter 触发
c.diameter = 20;  // 触发了 set diameter()，自动设置 _radius = 10
console.log("  修改直径后:", c.describe());

// ----------------------------------------------------------
// 4. 静态方法——属于类本身，不属于实例
// ----------------------------------------------------------
console.log("\n4. 静态方法：");

class Calculator {
    // 静态方法：不需要实例就能调用
    static add(a, b) {
        return a + b;
    }

    static multiply(a, b) {
        return a * b;
    }

    // 静态工厂方法——一种常见模式
    static createFromJson(jsonStr) {
        const data = JSON.parse(jsonStr);
        return new Calculator();  // 可以创建实例
    }

    // 普通方法——需要实例
    subtract(a, b) {
        return a - b;
    }
}

console.log("  Calculator.add(3, 5):", Calculator.add(3, 5));       // 8
console.log("  Calculator.multiply(3, 5):", Calculator.multiply(3, 5)); // 15

const calc = new Calculator();
console.log("  calc.subtract(10, 3):", calc.subtract(10, 3));  // 7
// calc.add(3, 5);  // TypeError！实例上没有静态方法

// ----------------------------------------------------------
// 5. class 中 this 丢失问题（和普通函数一样）
// ----------------------------------------------------------
console.log("\n5. class 方法的 this 丢失陷阱：");

class Button {
    constructor(label) {
        this.label = label;
        this.clickCount = 0;
    }

    // 普通方法——作为回调时 this 会丢失
    handleClick() {
        console.log(`  普通方法：按钮"${this.label}"被点击`);
    }

    // 箭头函数作为 class 字段——this 永久绑定到实例
    handleClickArrow = () => {
        this.clickCount++;
        console.log(`  箭头方法：按钮"${this.label}"被点击（第 ${this.clickCount} 次）`);
    };
}

const btn = new Button("提交");

// 模拟：直接调用（隐式绑定——没问题）
btn.handleClick();       // 正常
btn.handleClickArrow();  // 正常

// 模拟：作为回调传给第三方（this 丢失场景）
const callback = btn.handleClick;
// callback();  // 如果运行会报错：Cannot read property 'label' of undefined

const callbackArrow = btn.handleClickArrow;
callbackArrow();  // 正常！箭头函数 this 永远指向 btn

// 解决方案1：bind
const boundCallback = btn.handleClick.bind(btn);
boundCallback();  // 正常

// 解决方案2：用箭头函数包裹
setTimeout(() => btn.handleClick(), 0);  // 正常

// ----------------------------------------------------------
// 6. ES2022 字段声明——在 constructor 外声明属性
// ----------------------------------------------------------
console.log("\n6. 字段声明（较新语法）：");

class Product {
    // 直接在 class 体内声明字段+默认值
    name = "未命名";
    price = 0;
    category = "其他";
    createdAt = new Date();  // 每次 new 都会创建新的 Date

    constructor(name, price, category) {
        // 覆盖默认值
        if (name) this.name = name;
        if (price) this.price = price;
        if (category) this.category = category;
    }

    getInfo() {
        return `[${this.category}] ${this.name} - ¥${this.price}`;
    }
}

const p1 = new Product("机械键盘", 399, "数码");
const p2 = new Product();  // 全用默认值
console.log("  p1:", p1.getInfo());
console.log("  p2:", p2.getInfo());

// ----------------------------------------------------------
// 7. 综合：一个完整的模型类
// ----------------------------------------------------------
console.log("\n7. 综合示例——温度转换器：");

class Temperature {
    constructor(celsius) {
        this.celsius = celsius;
    }

    // getter：获取华氏度
    get fahrenheit() {
        return this.celsius * 9 / 5 + 32;
    }

    // setter：从华氏度设置
    set fahrenheit(f) {
        this.celsius = (f - 32) * 5 / 9;
    }

    // getter：获取开尔文
    get kelvin() {
        return this.celsius + 273.15;
    }

    describe() {
        return `${this.celsius}°C = ${this.fahrenheit}°F = ${this.kelvin}K`;
    }

    // 静态工厂方法
    static fromFahrenheit(f) {
        const celsius = (f - 32) * 5 / 9;
        return new Temperature(celsius);
    }
}

const temp = new Temperature(25);
console.log(`  ${temp.describe()}`);

const temp2 = Temperature.fromFahrenheit(68);
console.log(`  ${temp2.describe()}`);  // 20°C

console.log("\n========== class 语法 演示结束 ==========");
