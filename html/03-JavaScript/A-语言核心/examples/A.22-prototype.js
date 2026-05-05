// ============================================================
// A.22 原型与继承 示例代码
// 运行方式：node examples/A.22-prototype.js
// ============================================================

console.log("========== A.22 原型与继承 ==========\n");

// ----------------------------------------------------------
// 1. __proto__——每个对象都有的"通向原型的链接"
// ----------------------------------------------------------
console.log("1. 对象的 __proto__：");

// 普通对象字面量的 __proto__ 指向 Object.prototype
const plainObj = { x: 1 };
console.log("  plainObj.__proto__ === Object.prototype:", plainObj.__proto__ === Object.prototype); // true

// 数组的 __proto__ 指向 Array.prototype
const arr = [1, 2, 3];
console.log("  arr.__proto__ === Array.prototype:", arr.__proto__ === Array.prototype); // true

// 数组的原型链：arr -> Array.prototype -> Object.prototype -> null
console.log("  完整原型链：");
console.log("    arr.__proto__:", arr.__proto__.constructor.name);                    // Array
console.log("    arr.__proto__.__proto__:", arr.__proto__.__proto__.constructor.name); // Object
console.log("    arr.__proto__.__proto__.__proto__:", arr.__proto__.__proto__.__proto__); // null

// ----------------------------------------------------------
// 2. prototype——函数独有的属性
// ----------------------------------------------------------
console.log("\n2. 函数的 prototype：");

function Dog(name) {
    this.name = name;
}

// 在 Dog.prototype 上添加方法——所有 Dog 实例都能用
Dog.prototype.bark = function () {
    return `${this.name} 汪汪！`;
};

Dog.prototype.species = "犬科";

const dog1 = new Dog("旺财");
const dog2 = new Dog("来福");

// 实例没有 bark 方法，但通过 __proto__ 找到 Dog.prototype 上的 bark
console.log("  dog1.bark():", dog1.bark());
console.log("  dog2.bark():", dog2.bark());

// 关键关系：实例的 __proto__ === 构造函数的 prototype
console.log("  dog1.__proto__ === Dog.prototype:", dog1.__proto__ === Dog.prototype); // true

// 实例共享原型方法
console.log("  dog1.bark === dog2.bark:", dog1.bark === dog2.bark); // true（同一个函数）

// 实例共享原型属性
console.log("  dog1.species:", dog1.species);  // "犬科"——来自原型
console.log("  dog2.species:", dog2.species);  // "犬科"——同一个

// ----------------------------------------------------------
// 3. 原型链查找——属性查找的完整流程
// ----------------------------------------------------------
console.log("\n3. 原型链查找流程：");

function Animal(name) {
    this.name = name;
}
Animal.prototype.eat = function () {
    return `${this.name} 在吃东西`;
};

function Cat(name) {
    Animal.call(this, name);  // 调用父构造函数
}
// 关键步骤：设置 Cat.prototype 的原型为 Animal.prototype
Cat.prototype = Object.create(Animal.prototype);
Cat.prototype.constructor = Cat;  // 修正 constructor 指向
Cat.prototype.meow = function () {
    return `${this.name} 喵喵叫`;
};

const kitty = new Cat("小花");

// 属性查找：先找自己，再找 Cat.prototype，再找 Animal.prototype
console.log("  kitty.name:", kitty.name);     // "小花" ——自己的属性
console.log("  kitty.meow():", kitty.meow()); // "小花 喵喵叫" ——Cat.prototype
console.log("  kitty.eat():", kitty.eat());   // "小花 在吃东西" ——Animal.prototype

// 验证原型链结构
console.log("  原型链验证：");
console.log("    kitty.__proto__ === Cat.prototype:", kitty.__proto__ === Cat.prototype);                   // true
console.log("    Cat.prototype.__proto__ === Animal.prototype:", Cat.prototype.__proto__ === Animal.prototype); // true

// ----------------------------------------------------------
// 4. Object.create() ——直接指定原型创建对象
// ----------------------------------------------------------
console.log("\n4. Object.create()：");

const vehicle = {
    type: "交通工具",
    start() {
        return `${this.name} 启动了（类型：${this.type}）`;
    },
};

// 创建一个原型为 vehicle 的对象
const car = Object.create(vehicle);
car.name = "小汽车";
car.wheels = 4;

console.log("  car.name:", car.name);       // "小汽车" ——自己的
console.log("  car.start():", car.start()); // 从 vehicle 继承的
console.log("  car.type:", car.type);       // "交通工具" ——从原型继承
console.log("  car.__proto__ === vehicle:", car.__proto__ === vehicle); // true

// Object.create(null) ——创建一个没有原型的对象（纯数据容器）
const pureData = Object.create(null);
pureData.key = "value";
console.log('  pureData.toString:', pureData.toString); // undefined！没有 toString 方法
// 普通对象有 toString 是因为 Object.prototype 上有，但 pureData 没有原型

// ----------------------------------------------------------
// 5. ES6 class extends——语法糖下的继承
// ----------------------------------------------------------
console.log("\n5. ES6 extends 继承：");

class Animal2 {
    constructor(name) {
        this.name = name;
    }

    eat() {
        return `${this.name} 在吃东西`;
    }

    // 静态方法也能被继承
    static classify() {
        return "我是动物";
    }
}

class Dog2 extends Animal2 {
    constructor(name, breed) {
        super(name);      // 必须调用 super() 才能使用 this
        this.breed = breed;
    }

    // 覆盖父类方法
    eat() {
        return `${this.name}（${this.breed}）在狼吞虎咽地吃`;
    }

    bark() {
        return `${this.name} 汪汪！`;
    }
}

const dog = new Dog2("旺财", "金毛");
console.log("  dog.eat():", dog.eat());
console.log("  dog.bark():", dog.bark());
console.log("  Dog2.classify():", Dog2.classify());  // 继承了静态方法

// 本质仍然是原型链
console.log("  dog.__proto__ === Dog2.prototype:", dog.__proto__ === Dog2.prototype);                         // true
console.log("  Dog2.prototype.__proto__ === Animal2.prototype:", Dog2.prototype.__proto__ === Animal2.prototype); // true
console.log("  Dog2.__proto__ === Animal2:", Dog2.__proto__ === Animal2);  // true（静态方法继承）

// ----------------------------------------------------------
// 6. super 关键字——调用父类的方法
// ----------------------------------------------------------
console.log("\n6. super 关键字：");

class Person {
    constructor(name) {
        this.name = name;
    }

    greet() {
        return `你好，我是 ${this.name}`;
    }
}

class Student extends Person {
    constructor(name, grade) {
        super(name);     // 调用父类 constructor 设置 name
        this.grade = grade;
    }

    greet() {
        // super.greet() 调用父类的 greet 方法
        const parentGreeting = super.greet();
        return `${parentGreeting}，读 ${this.grade}`;
    }
}

const stu = new Student("小明", "大三");
console.log("  " + stu.greet()); // "你好，我是 小明，读 大三"

// ----------------------------------------------------------
// 7. 检查原型关系的方法
// ----------------------------------------------------------
console.log("\n7. 原型关系检查：");

console.log("  dog instanceof Dog2:", dog instanceof Dog2);         // true
console.log("  dog instanceof Animal2:", dog instanceof Animal2);   // true
console.log("  dog instanceof Object:", dog instanceof Object);     // true

console.log("  Dog2.prototype.isPrototypeOf(dog):", Dog2.prototype.isPrototypeOf(dog));       // true
console.log("  Animal2.prototype.isPrototypeOf(dog):", Animal2.prototype.isPrototypeOf(dog)); // true

console.log("  Object.getPrototypeOf(dog) === Dog2.prototype:", Object.getPrototypeOf(dog) === Dog2.prototype); // true

console.log("\n========== 原型与继承 演示结束 ==========");
