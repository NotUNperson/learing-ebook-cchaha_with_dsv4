# A.10 箭头函数

## 本节你会学到什么

- 箭头函数语法：`(a, b) => a + b`
- 单行自动返回（省略 `{}` 和 `return`）
- 多行体用 `{}`，需要显式 `return`
- 单参数可省略括号
- 箭头函数的 `this` 继承自外层（重点）
- 箭头函数不能用作构造函数
- 什么时候用箭头函数，什么时候用普通函数

## 正文

### 一、箭头函数的基本语法

ES6 引入的箭头函数（Arrow Function）是函数表达式的简写形式。用 `=>`（等号+大于号）代替 `function` 关键字。

```javascript
// 普通函数表达式
const add = function(a, b) {
    return a + b;
};

// 箭头函数（完全等价）
const addArrow = (a, b) => {
    return a + b;
};

console.log(addArrow(3, 5));  // 8
```

`=>` 读作"箭头"或"胖箭头"。你可以想象成：左边是输入参数，右边是输出——"参数射向结果"。

### 二、简洁写法规则

箭头函数有几种简写形式：

**规则 1：如果函数体只有一条 return 语句，可以省略 `{}` 和 `return`**

```javascript
// 完整写法
const add = (a, b) => {
    return a + b;
};

// 简洁写法（只有一条 return 语句）
const addShort = (a, b) => a + b;

console.log(addShort(3, 5));  // 8
```

**规则 2：如果只有一个参数，可以省略参数的括号**

```javascript
// 完整写法
const square = (x) => {
    return x * x;
};

// 简洁写法（单参数可省略括号）
const squareShort = x => x * x;

console.log(squareShort(5));  // 25
```

**规则 3：没有参数时，必须写空括号**

```javascript
const sayHello = () => console.log("Hello!");
sayHello();
```

**规则 4：多行函数体必须用 `{}`，需要显式 `return`**

```javascript
const greet = (name) => {
    const message = "你好，" + name;
    console.log(message);
    return message;  // 必须写 return
};
```

**规则 5：返回对象字面量时，需要用括号包裹**

```javascript
// 错误：{} 被当成函数体
// const createPerson = (name, age) => { name: name, age: age };

// 正确：用 () 包裹对象
const createPerson = (name, age) => ({ name: name, age: age });

console.log(createPerson("小明", 25));  // { name: '小明', age: 25 }
```

### 三、箭头函数的 `this` -- 核心区别

箭头函数和普通函数最重要的区别在于 `this` 的指向。

**普通函数**的 `this` 由"谁调用我"决定（动态绑定）。

**箭头函数**的 `this` 由"我在哪里被定义"决定（词法绑定），继承自外层作用域。

> 生活类比：普通函数的 `this` 像是"租房"--每次被调用，this 都可能是不同的"房东"。箭头函数的 `this` 像是"自己的房子"--this 永远是你出生时那个"家"，无论你在哪里被调用，你的"户口"不变。

```javascript
// 演示 this 的区别
const person = {
    name: "小明",

    // 普通函数：this 指向调用者（person 对象）
    greetNormal: function() {
        console.log("普通函数 - 你好，" + this.name);
    },

    // 箭头函数：this 继承自外层（这里是全局作用域，没有 name）
    greetArrow: () => {
        console.log("箭头函数 - 你好，" + this.name);
    }
};

person.greetNormal();  // "普通函数 - 你好，小明"
person.greetArrow();   // "箭头函数 - 你好，undefined" -- this 不是 person！

// 在 Node.js 中，模块顶层的 this 是 {}（一个空对象）
console.log("模块顶层的 this:", this);
```

在事件处理和对象方法中，这两种 this 行为会导致完全不同的结果。我们在 B 篇（浏览器中的 JS）会深入讲解 `this`。

> 初学者实用法则：在对象方法中需要访问对象自己时用普通函数；在回调、数组方法（map/filter 等）中写短小逻辑时用箭头函数。

### 四、箭头函数不能做什么

箭头函数和普通函数有以下几个区别：

1. **不能用作构造函数**：不能用 `new` 调用
2. **没有 `arguments` 对象**（但可以用剩余参数 `...args`）
3. **不能用作生成器函数**（不能使用 `yield`）
4. **`this` 固定继承自外层**，无法用 `call`/`apply`/`bind` 改变

```javascript
// 箭头函数不能用 new
const Person = (name) => {
    this.name = name;
};
// const p = new Person("小明");  // TypeError: Person is not a constructor
```

### 五、什么时候用箭头函数

| 场景 | 用箭头函数 | 用普通函数 |
|------|-----------|-----------|
| 简短的回调函数 | 推荐 | 也可以 |
| 数组方法（map, filter 等） | 推荐 | 也可以 |
| 需要自己的 `this`（对象方法） | 不推荐 | 推荐 |
| 构造函数 | 不能用 | 必须用 |
| 需要 `arguments` 对象 | 不能用 | 用普通函数 |

**简单口诀**：短小逻辑用箭头，对象方法用普通。不确定时，写普通函数总不会错。

---

## 动手试试

1. 把 A.9 中写的 `add` 函数改写成箭头函数，测试是否得出相同结果。
2. 写一个箭头函数 `isEven = n => ...`，判断一个数是否为偶数（一行搞定）。
3. 写一个对象，包含一个普通方法和一个箭头方法，都尝试访问 `this`，对比输出。

---

## 与 C 语言的对比

C 语言没有箭头函数（或任何等价的语法糖）。C 语言中所有"函数"都是编译时确定的，不存在"更简洁的函数定义方式"这个概念。箭头函数是 JS 从函数式编程语言中借鉴的特性，特别适合写短小的回调逻辑。如果你有 C 语言背景，可以理解为：箭头函数是一种更紧凑的函数指针写法。

---

## 本节小结

- 箭头函数：`(a, b) => a + b`
- 单行 return 可以省略 `{}` 和 `return`
- 单参数可以省略 `()`：`x => x * x`
- 箭头函数的 `this` 继承自外层（词法绑定），普通函数的 `this` 由调用者决定
- 箭头函数不能用作构造函数
- 短小逻辑优先用箭头函数，对象方法用普通函数

---

## 下一节预告

学会了函数的各种写法，下一节深入函数的"进"和"出"：默认参数、剩余参数 `...args`、返回值详解。你会看到 JS 处理函数参数的灵活程度远超 C 语言。
