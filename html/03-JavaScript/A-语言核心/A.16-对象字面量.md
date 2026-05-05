# A.16 对象字面量

## 本节你会学到什么

- 对象是 JavaScript 最核心的数据结构，本质是"键值对"的集合
- 用对象字面量 `{ }` 创建对象，用 `.` 和 `[ ]` 两种方式访问属性
- 属性值简写：当变量名和属性名相同时，可以省略冒号
- 方法简写：在对象里定义函数可以省略 `: function`
- 和 C 语言 struct 的关键区别：JS 对象运行时可以随时增删属性，极其灵活

## 正文

### 什么是对象

想象你在填写一张个人信息表：

| 字段 | 值 |
|------|-----|
| 姓名 | 张三 |
| 年龄 | 20 |
| 职业 | 学生 |

这张表就是一个"对象"——每一行都是一个"键值对"（key-value pair），"姓名"是键，"张三"是值。

在 JavaScript 中，对象就是这样的键值对集合。这是 JS 最重要、最核心的数据结构，没有之一。你几乎无时无刻不在用对象。

### 对象字面量

创建对象最简单的方式是**对象字面量**（object literal），用一对花括号 `{ }` 包裹键值对：

```javascript
const person = {
    name: "张三",
    age: 20,
    job: "学生"
};
```

### 属性访问的两种方式

**点号访问**（最常用）：

```javascript
console.log(person.name);  // "张三"
console.log(person.age);   // 20
```

**方括号访问**（键名是变量或包含特殊字符时使用）：

```javascript
const key = "name";
console.log(person[key]);  // "张三"，key 是变量，运行时决定访问哪个属性

console.log(person["job"]); // "学生"，方括号里写字符串也行
```

点号的限制是：点号后面的名字必须是合法的标识符（不能有空格、不能以数字开头等）。方括号则没有这个限制，只要是字符串就行。更重要的是，方括号里可以放**变量**，这是动态访问属性的关键手段。

### 属性值简写

经常有这样的场景：你已经有了变量，想把它们组装成对象：

```javascript
const name = "李四";
const age = 22;

// 传统写法
const user1 = { name: name, age: age };

// ES6 属性值简写：变量名=属性名时，省略冒号
const user2 = { name, age };

console.log(user1); // { name: '李四', age: 22 }
console.log(user2); // { name: '李四', age: 22 }  完全一样
```

这种简写在实际项目中非常常见。

### 方法简写

对象里可以放函数，这种函数称为"方法"（method）。ES6 提供了更简洁的写法：

```javascript
// 传统写法：属性名后跟冒号和 function
const obj1 = {
    sayHi: function() {
        console.log("你好");
    }
};

// ES6 方法简写：直接写函数名和括号
const obj2 = {
    sayHi() {
        console.log("你好");
    }
};
```

两种写法功能完全相同，但方法简写更简洁，是现代代码的标准写法。

### 方法的 this

在方法内部，`this` 指向调用该方法的对象本身：

```javascript
const person = {
    name: "张三",
    greet() {
        console.log("你好，我是" + this.name);  // this 指向 person
    }
};

person.greet(); // "你好，我是张三"
```

关于 `this` 的详细规则，我们在 A.19 节会深入讲解。

## 与 C 语言的对比

C 语言的 struct 字段在编译时就固定了，不能运行时增删；JS 对象则完全不同——你可以随时 `obj.newField = xxx` 添加新属性，或者 `delete obj.field` 删除属性。这种自由度类似于 C 中动态维护一个哈希表，而 JS 把这个能力内置到了语言核心。

## 动手试试

1. 创建一个代表你自己的对象，包含姓名、年龄、爱好（数组）
2. 用变量存储一个属性名，通过方括号动态读取那个属性的值
3. 定义一个包含 `greet()` 方法的对象，方法里用 `this.name` 打印问候语

## 本节小结

- 对象是键值对的集合，用 `{}` 字面量创建
- 访问属性用 `.`（静态）或 `[变量]`（动态）
- 属性值简写 `{ name, age }` 等价于 `{ name: name, age: age }`
- 方法简写 `{ sayHi() {} }` 替代了 `{ sayHi: function() {} }`
- JS 对象比 C struct 灵活得多，运行时可随意增删属性

## 下一节预告

A.17 对象操作——在掌握了创建对象的基础上，学习属性的增删改查、Object.keys/values/entries、可选链等实用操作。
