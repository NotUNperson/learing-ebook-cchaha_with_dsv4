# A.22 原型与继承

## 本节你会学到什么

- `prototype`（函数属性）和 `__proto__`（对象属性）的区别和联系
- 原型链查找机制——属性查找沿着 `__proto__` 链向上追溯
- `Object.create(proto)` ——以指定原型创建对象
- ES6 `extends` 继承——class 语法下的继承写法，本质仍是原型链
- 理解原型链是理解"JS 中一切皆对象"这句话的关键

## 正文

### 原型是什么——JS 最独特的机制

**生活类比**：你和你的家族。你身上有一些特质（名字、身高）是你自己的。但如果你没有某项特质——比如你不知道你的曾祖父是谁——你沿着"族谱"往上查：问你爸，你爸不知道就问你爷爷，爷爷不知道再往上。这个"沿着族谱一层层向上查找"的机制，就是原型链。

JavaScript 的对象也有这样的"族谱"。当你访问 `obj.prop` 时：
1. 先看 obj 自己有没有 prop
2. 没有？看 obj 的 `__proto__`（父辈）有没有
3. 还没有？看 `__proto__.__proto__`（爷爷辈）
4. 一直找到 `null`（到顶了）

```javascript
const parent = { familyName: "张" };
const child = { name: "小明" };

// 设置 child 的原型为 parent
Object.setPrototypeOf(child, parent);

console.log(child.name);        // "小明" ——自己的属性
console.log(child.familyName);  // "张" ——从原型上继承来的
console.log(child.unknown);     // undefined ——原型链上也没有
```

### prototype 和 __proto__ 的区别

这是最容易混淆的两个概念，务必区分：

| 项目 | prototype | __proto__ |
|------|-----------|-----------|
| 属于谁 | **函数**独有 | **所有对象**都有 |
| 作用 | new 时，用来设置新对象的 __proto__ | 指向自己的原型对象 |
| 通俗理解 | 函数的"模板库" | 通往"模板库"的链接 |

```javascript
function Dog(name) {
    this.name = name;
}
Dog.prototype.bark = function() {
    return `${this.name} 汪汪！`;
};

const dog = new Dog("旺财");

console.log(Dog.prototype);          // { bark: [Function] }
console.log(dog.__proto__);          // { bark: [Function] }  和上面一样！
console.log(dog.__proto__ === Dog.prototype); // true

// dog 自己没有 bark，但能从原型上找到
console.log(dog.bark());  // "旺财 汪汪！"
```

运行 `new Dog("旺财")` 时，JS 把 `dog.__proto__` 指向了 `Dog.prototype`。所以 dog 能"继承" `Dog.prototype` 上的所有方法。

### 原型链的终点

一直沿着 `__proto__` 往上走，最终会到达 `null`：

```javascript
const arr = [1, 2, 3];
arr.__proto__ === Array.prototype;              // true
arr.__proto__.__proto__ === Object.prototype;    // true
arr.__proto__.__proto__.__proto__ === null;      // true ——到顶了
```

这就是为什么数组既有数组方法（push、pop），又有对象方法（hasOwnProperty）——方法沿着原型链一层层被找到。

### Object.create(proto)

创建一个新对象，直接指定其原型：

```javascript
const animal = {
    eat() { console.log("吃东西"); },
};

const cat = Object.create(animal);
cat.meow = function() { console.log("喵"); };

cat.eat();  // 从 animal 原型继承的
cat.meow(); // 自己的

console.log(cat.__proto__ === animal);  // true
```

### ES6 extends 继承

class 语法下的继承，本质仍然是原型链：

```javascript
class Animal {
    constructor(name) {
        this.name = name;
    }
    eat() {
        console.log(`${this.name} 在吃东西`);
    }
}

class Dog extends Animal {
    constructor(name, breed) {
        super(name);       // 调用父类的 constructor
        this.breed = breed;
    }
    bark() {
        console.log(`${this.name} 汪汪叫`);
    }
}

const dog = new Dog("旺财", "金毛");
dog.eat();   // 继承自 Animal
dog.bark();  // Dog 自己的

// 验证原型链
console.log(dog.__proto__ === Dog.prototype);             // true
console.log(Dog.prototype.__proto__ === Animal.prototype); // true！
```

`extends` 在背后做了这件事：`Dog.prototype.__proto__ = Animal.prototype`。也就是说，Dog 的原型的原型是 Animal 的原型——一条两层的继承链。

### 方法覆盖（Override）

子类可以定义和父类同名的属性或方法，覆盖父类的：

```javascript
class Animal {
    speak() { return "???"; }
}

class Cat extends Animal {
    speak() { return "喵喵喵"; }  // 覆盖父类的 speak
}

class Dog extends Animal {
    speak() {
        return super.speak() + " 汪汪汪";  // 调用父类方法 + 自己的
    }
}
```

### 原型 vs 类继承

| 对比维度 | JS 原型链 | C++/Java 类继承 |
|---------|-----------|----------------|
| 实现方式 | 对象的运行时链接 | 编译期类层次 |
| 灵活性 | 可以动态改变原型 | 编译后固定 |
| 继承数量 | 单继承（一个 __proto__） | C++ 支持多继承 |
| 查找方式 | 运行时沿链向上查找 | 编译期确定虚表 |

## 与 C 语言的对比

C 语言没有运行时的继承概念。你能做到的最相似的事是"结构体嵌套"——在一个 struct 里包含另一个 struct（组合），但这需要手动转发方法调用。JS 的原型链是真正的运行时继承——`obj.__proto__.proto...` 这条链可以在程序运行中动态改变（虽然不推荐），这是 C 完全无法想象的动态性。

## 动手试试

1. 创建一个 `vehicle` 对象，包含 `start()` 方法。用 `Object.create(vehicle)` 创建一个 `car` 对象
2. 写两个 class，一个继承另一个，用 `console.log` 打印实例的 `__proto__` 链验证继承关系
3. 在子类中覆盖父类的方法，并用 `super` 调用父类的版本

## 本节小结

- `prototype` 是函数属性，`__proto__` 是所有对象都有的链接——二者成对出现
- 属性查找沿 `__proto__` 链向上追溯，到 null 为止
- `new` 做的事之一就是把 `instance.__proto__` 指向 `Constructor.prototype`
- `extends` 本质是设置了两层原型链：`子.prototype.__proto__ = 父.prototype`
- 理解原型链是理解 JS 对象模型的钥匙

## 下一节预告

A.23 Set 与 Map——两种比普通对象和数组更"专业"的集合数据结构。Set 自动去重，Map 的键可以是任意类型。
