# A.19 this 关键字

## 本节你会学到什么

- `this` 是"当前执行语境中的'我'"，它的值取决于**函数的调用方式**，而非定义方式
- 四种 this 绑定规则：默认绑定、隐式绑定、显式绑定、new 绑定
- 箭头函数没有自己的 `this`，从定义时的外层作用域继承
- 快速判断法则："谁调用的就指向谁"

## 正文

### this 是什么——"当前语境中的'我'"

**生活类比**：你在不同场合说"我"，指代的都是你自己。但如果在聊天群里，10 个人都说"我今天吃了火锅"，每个"我"指代的人不同。"我"的含义取决于"谁在说"。

JavaScript 中的 `this` 就是这样一个词——它在函数被调用时才确定，指向"当前是谁在调用这个函数"。**this 是动态的，不是静态的。**

这和 C 语言完全不同。C 语言中你在结构体的函数里必须明确传 `struct Person *self`，自己管理"这个操作针对哪个对象"。JS 的 this 帮你自动处理了这件事。

### 四种 this 绑定规则

#### 1. 默认绑定——独立函数调用

最"光杆"的调用方式，没有对象、没有 new、没有 call/apply/bind：

```javascript
function showThis() {
    console.log(this);
}

showThis(); // 浏览器非严格模式：window；Node/严格模式：undefined
```

在 Node.js 的 ES 模块中（默认严格模式），独立函数调用时 `this` 是 `undefined`。这是最容易写 bug 的地方。

#### 2. 隐式绑定——"谁调用的就指向谁"

```javascript
const obj = {
    name: "张三",
    greet() {
        console.log("你好，" + this.name);
    },
};

obj.greet(); // this 指向 obj，输出"你好，张三"
```

规则：看函数调用时**点号前面是谁**。`obj.greet()` 中点号前面是 `obj`，所以 this 指向 obj。

**隐式丢失陷阱**：

```javascript
const fn = obj.greet;   // 把方法赋值给变量
fn();  // this 是 undefined！因为调用时点号前面没有东西了
```

这就像你把一个人的话录下来，换了个场合播放。"我"就不再指代原来说话的人了。

#### 3. 显式绑定——手动指定 this

`call`、`apply`、`bind` 三个方法可以强制指定 this：

```javascript
function greet() {
    console.log("你好，" + this.name);
}

const user = { name: "李四" };

greet.call(user);   // call：逐个传参
greet.apply(user);  // apply：数组传参
const boundGreet = greet.bind(user); // bind：返回绑定 this 的新函数
boundGreet();
```

`call` 和 `apply` 立即执行，区别只是传参方式。`bind` 不立即执行，而是返回一个绑定了 this 的新函数。

记忆口诀：**call 逗号传，apply 数组传，bind 绑了再传。**

#### 4. new 绑定——构造函数中的 this

用 `new` 调用函数时，this 指向新创建的那个对象实例。详见 A.20 节。

### 箭头函数的 this——从定义处继承

箭头函数没有自己的 this，它从**定义时所在的外层作用域**继承 this：

```javascript
const obj = {
    name: "王五",
    // 普通函数
    greetNormal() {
        setTimeout(function() {
            console.log("普通函数 this.name:", this.name);  // undefined
        }, 100);
    },
    // 箭头函数
    greetArrow() {
        setTimeout(() => {
            console.log("箭头函数 this.name:", this.name);  // "王五"
        }, 100);
    },
};
```

在 `greetNormal` 中，`setTimeout` 的回调是普通函数，独立调用时 this 为 undefined（严格模式）。在 `greetArrow` 中，箭头函数没有自己的 this，它从 `greetArrow` 方法中继承——而 `greetArrow` 是被 `obj` 调用的，this 是 `obj`。

这个差异极其重要，在实际开发中箭头函数常常就是为了解决 this 丢失问题。

### 优先级和总结

四种绑定规则的优先级从高到低：
1. **new 绑定**（new 调用，this 指向新实例）
2. **显式绑定**（call/apply/bind）
3. **隐式绑定**（obj.method()）
4. **默认绑定**（独立调用，严格模式 undefined）

快速判断法则（按顺序检查）：
- 函数是用 new 调用的吗？→ this 是新对象
- 用了 call/apply/bind 吗？→ this 是绑定的对象
- 是 `对象.方法()` 形式调用的吗？→ this 是那个对象
- 都不是？→ 严格模式 undefined，非严格模式全局对象

## 与 C 语言的对比

C 语言中不存在 this 的概念。如果你用 C 写面向对象的代码，需要显式地传递 `struct Person *self` 作为第一个参数，然后在函数内部通过 `self->name` 访问成员。JS 的 this 把这个模式自动化了，但也因此引入了绑定规则的复杂性——C 的方式虽然啰嗦，但绝不会搞混是谁。

## 动手试试

1. 写一个方法，用 `setTimeout` + 普通函数回调打印 `this.name`，观察输出
2. 把回调改成箭头函数，再观察输出
3. 用 `call`/`apply`/`bind` 显式绑定 this，体会三者的区别

## 本节小结

- `this` 是动态的，取决于**调用方式**而非定义位置
- 四种规则按优先级：new > 显式 > 隐式 > 默认
- 快速判断法："谁调用的就指向谁"（隐式绑定的情况）
- 箭头函数没有自己的 this，从外层作用域继承——解决回调中 this 丢失的利器
- bind 返回绑定后的新函数，call/apply 立即执行

## 下一节预告

A.20 构造函数与 new——用 `new` 关键字批量创建对象，看看 new 在背后偷偷做了哪四件事。
