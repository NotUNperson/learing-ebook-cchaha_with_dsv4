# A.21 class 语法

## 本节你会学到什么

- `class` 是构造函数的语法糖，写起来像传统 OOP 但本质仍是原型
- `constructor` 方法、普通方法、getter/setter 的定义
- 静态方法——属于类本身而非实例的方法
- `typeof SomeClass === 'function'` ——class 的本质就是函数
- 和 C++ 的 class 做概念对比，理解 JS 的独特设计

## 正文

### class 是语法糖

在 A.20 我们学了构造函数，但那种写法不够直观：

```javascript
function User(name, age) {
    this.name = name;
    this.age = age;
}
User.prototype.greet = function() { ... };
```

属性和方法分两个地方定义，看着不像一个整体。ES6 引入的 class 语法让代码组织得更清晰：

```javascript
class User {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }
    greet() {
        return `你好，我是 ${this.name}`;
    }
}
```

注意：class 只是语法糖——底层仍然是构造函数和原型。证据：

```javascript
typeof User === "function"  // true！class 本质就是 function
```

**生活类比**：class 就像"套餐"。以前你要分别点汉堡、薯条、可乐（构造函数 + 原型方法），现在你可以直接说"来个 1 号套餐"（class），更方便，但后厨做的东西和单点是一样的。

### constructor——构造函数

`constructor` 是类中一个特殊的方法，在 `new` 时自动调用：

```javascript
class Point {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }
}
const p = new Point(3, 4);  // constructor(3, 4) 被调用
```

如果不写 constructor，JS 会自动补一个空的 `constructor() {}`。

### 方法定义

在 class 内部定义的方法，会自动挂到 `原型` 上，所有实例共享：

```javascript
class Point {
    constructor(x, y) { this.x = x; this.y = y; }
    distance() { return Math.sqrt(this.x ** 2 + this.y ** 2); }
}

const p1 = new Point(3, 4);
const p2 = new Point(5, 12);
console.log(p1.distance === p2.distance); // true——同一个函数
```

### getter 和 setter——计算属性

getter 定义读取时的行为，setter 定义赋值时的行为。用 `get` 和 `set` 关键字：

```javascript
class Circle {
    constructor(radius) {
        this._radius = radius;
    }
    // getter——像访问普通属性一样调用
    get area() {
        return Math.PI * this._radius ** 2;
    }
    get diameter() {
        return this._radius * 2;
    }
    // setter——像赋值一样触发
    set diameter(d) {
        this._radius = d / 2;
    }
}

const c = new Circle(5);
console.log(c.area);      // 78.54...  ——像属性一样读取
console.log(c.diameter);   // 10
c.diameter = 20;           // 像属性一样赋值，触发了 setter
console.log(c._radius);   // 10
```

注意 `_radius` 的下划线是约定，表示"这是内部属性，最好不要直接改"。它本身没有任何保护，只是一种沟通。

### 静态方法——属于类本身

用 `static` 关键字定义的方法不挂在实例上，而是挂在类自身：

```javascript
class MathHelper {
    static add(a, b) { return a + b; }
    static multiply(a, b) { return a * b; }
}

console.log(MathHelper.add(3, 5));   // 8  ——直接用类名调用
console.log(MathHelper.multiply(3, 5)); // 15

// const h = new MathHelper();
// h.add(3, 5);  // 报错！实例上没有 add
```

静态方法的典型场景：工具函数、工厂方法（创建特定配置的实例）。

### 关于 this 的提醒

class 中定义的方法，当作为回调传递时仍会丢失 this（和普通函数一样）：

```javascript
class Button {
    constructor(label) {
        this.label = label;
    }
    click() {
        console.log(this.label);
    }
}

const btn = new Button("提交");
btn.click();              // "提交"——隐式绑定，this 是 btn
setTimeout(btn.click, 0); // undefined——this 丢失了！
```

解决方案：用箭头函数属性或 bind。

### 字段声明（ES2022）

在现代 JS 中，你可以在 class 体内直接声明字段，不用在 constructor 里赋值：

```javascript
class User {
    name = "未知";    // 字段声明+默认值
    age = 0;
    constructor(name, age) {
        this.name = name;  // 覆盖默认值
        this.age = age;
    }
}
```

## 与 C 语言的对比

JS 的 class 和 C++ 的 class 看起来像，但有本质区别：
- C++ class 是编译期的蓝图，记忆体布局在编译时确定；JS class 运行时动态组装
- C++ 有真正的 private/public/protected 访问控制；JS 目前只有约定（下划线前缀）和较新的 # 私有字段
- C++ 支持多重继承；JS 通过原型链只支持单继承（每个对象只有一个 `__proto__`）
- JS 的 class 本质是 function，typeof 就能看出来——这在 C++ 中不可想象

## 动手试试

1. 用 class 定义一个 `Rectangle` 类，包含 `width` 和 `height`，加上 `area` getter
2. 添加一个静态方法 `square(size)`，它返回一个宽高相等的 Rectangle 实例
3. 用 `typeof` 检查你定义的类，验证它确实是 "function"

## 本节小结

- class 是构造函数+原型的语法糖，`typeof ClassName === 'function'`
- `constructor` 在 new 时自动调用，方法自动挂到原型上共享
- getter/setter 用 `get`/`set` 关键字，像属性一样用
- `static` 方法挂在类自身上，实例无法调用
- class 方法作回调时仍会丢失 this，需要注意绑定

## 下一节预告

A.22 原型与继承——揭开 class 语法糖的底层，深入理解 JavaScript 最独特的原型链机制。这是 JS 的"灵魂"所在。
