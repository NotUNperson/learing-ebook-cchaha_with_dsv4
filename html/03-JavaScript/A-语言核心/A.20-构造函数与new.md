# A.20 构造函数与 new

## 本节你会学到什么

- `new` 关键字在背后默默做了四件事
- 如何用构造函数批量创建相同"模板"的对象
- 构造函数的命名约定——首字母大写
- `instanceof` 运算符——判断一个对象是否由某个构造函数创建
- 和 C 语言的 `malloc` + 初始化对比理解 new 做了什么

## 正文

### 为什么需要构造函数

在 A.16 我们学会了创建单个对象：

```javascript
const user1 = { name: "张三", age: 20 };
const user2 = { name: "李四", age: 22 };
const user3 = { name: "王五", age: 25 };
```

三个用户，写了三次，每次都要手动复制粘贴属性名。如果有 100 个用户呢？

**生活类比**：你开了一家奶茶店，每杯奶茶都需要贴标签（顾客名、甜度、加料）。如果每位顾客来了都手写一张标签——费时又容易出错。更聪明的做法是用一台贴标机（构造函数），输入顾客信息，它自动吐出标签。构造函数就是创建对象的"贴标机"。

### 构造函数长什么样

构造函数就是一个普通的 function，只不过调用时前面加 `new`：

```javascript
function User(name, age) {
    this.name = name;   // this 指向新创建的对象
    this.age = age;
    this.introduce = function() {
        return `我叫 ${this.name}，${this.age} 岁`;
    };
}

const u1 = new User("张三", 20);
const u2 = new User("李四", 22);

console.log(u1.introduce());  // "我叫 张三，20 岁"
console.log(u2.introduce());  // "我叫 李四，22 岁"
```

构造函数首字母大写（`User` 而不是 `user`），这是约定，不是语法要求。但这个约定很重要——它提醒调用者"这个函数要用 new 来调用"。

### new 在背后做了哪四件事

当你写 `const obj = new Func(arg)` 时，JS 引擎执行了：

1. **创建一个空对象**：`const obj = {};`
2. **设置原型**：把 `obj.__proto__` 指向 `Func.prototype`（让 obj 能访问构造函数原型上的方法）
3. **绑定 this 并执行**：`Func.call(obj, arg)`，在构造函数内部用 this 为新对象添加属性
4. **返回对象**：如果构造函数没有返回对象，自动返回 obj

用伪代码理解：

```javascript
function myNew(constructor, ...args) {
    const obj = {};                           // 1. 创建空对象
    obj.__proto__ = constructor.prototype;    // 2. 设置原型
    const result = constructor.call(obj, ...args); // 3. 执行构造函数
    return typeof result === "object" ? result : obj; // 4. 返回
}
```

### 在构造函数中定义方法的问题

上面的例子把 `introduce` 方法写在了构造函数里。这有个问题：**每创建一个实例，就创建一个新的函数对象**，100 个实例就有 100 个 `introduce` 函数，浪费内存。

解决方案是使用 **prototype**（原型），让所有实例共享同一个方法：

```javascript
function User(name, age) {
    this.name = name;
    this.age = age;
}

// 方法定义在 prototype 上——所有实例共享
User.prototype.introduce = function() {
    return `我叫 ${this.name}，${this.age} 岁`;
};

const u1 = new User("张三", 20);
const u2 = new User("李四", 22);

console.log(u1.introduce === u2.introduce); // true！同一个函数
```

关于原型的详细机制，见 A.22 节。

### instanceof——判断"血缘关系"

```javascript
console.log(u1 instanceof User);  // true——u1 是由 User 创建的
console.log(u1 instanceof Object); // true——所有对象都是 Object 的后代
console.log({} instanceof User);   // false——普通对象字面量不是 User 创建的
```

### 不写 new 会怎样

如果在构造函数里用了 `this`，却忘了 new，后果严重：this 指向全局（非严格模式）或 undefined（严格模式），你添加的属性会被写到全局或直接报错。

解决方案：在构造函数内部检测是否用了 new：

```javascript
function User(name, age) {
    if (!(this instanceof User)) {
        return new User(name, age);  // 自动补上 new
    }
    this.name = name;
    this.age = age;
}
```

## 与 C 语言的对比

在 C 中，你需要手动 `malloc(sizeof(struct User))` 分配内存，然后逐个初始化字段，用完还要 `free`。JS 的 `new` 把创建对象、设置原型、初始化属性三件事封装在一起了，而且 JS 的垃圾回收自动处理释放，不用你手动 free。本质上是把 C 中需要三条语句完成的事变成了一条。

## 动手试试

1. 写一个 `Book` 构造函数，包含书名、作者、价格三个属性
2. 在 `Book.prototype` 上添加一个 `getInfo()` 方法，返回书的简介字符串
3. 分别用 `new` 和不写 `new` 调用，观察区别

## 本节小结

- `new` 做四件事：创建空对象、设置原型、绑定 this 执行、返回对象
- 构造函数首字母大写是约定，提醒调用者使用 new
- 共享方法应放在 `prototype` 上，避免每个实例都创建一份
- `instanceof` 检查实例与构造函数的关系
- 忘记 `new` 是常见 bug——this 会变成 undefined（严格模式）

## 下一节预告

A.21 class 语法——ES6 引入的 class 是构造函数的"语法糖"，让 JavaScript 写起来更像传统的面向对象语言。但它本质还是原型。
