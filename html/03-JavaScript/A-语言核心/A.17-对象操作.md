# A.17 对象操作

## 本节你会学到什么

- 属性的增删改查：添加、修改、删除、判断属性是否存在
- `Object.keys()` / `Object.values()` / `Object.entries()` ——把对象转成数组来处理
- 可选链 `?.` ——安全访问深层属性，不存在就返回 undefined 而不报错
- 计算属性名 `[表达式]` ——用表达式的结果作为属性名

## 正文

### 属性的增删改查（CRUD）

对象的核心操作就是四个字：增、删、改、查。这和数据库的 CRUD 是一回事，只不过操作对象简单得多。

**查（Read）**——前面已经学过，用 `.` 或 `[ ]`。

**增/改（Create/Update）**——直接赋值就行，如果属性不存在就创建，存在就覆盖：

```javascript
const obj = { name: "张三" };

obj.age = 20;       // 增：age 原来没有，现在创建了
obj.name = "李四";  // 改：name 原来有，现在覆盖了
```

**删（Delete）**——用 `delete` 运算符：

```javascript
delete obj.age;  // age 属性被删除
```

### 判断属性是否存在

三种常用方式：

| 方式 | 说明 | 注意事项 |
|------|------|----------|
| `"key" in obj` | 检查自身+原型链 | 最安全，推荐 |
| `obj.hasOwnProperty("key")` | 只检查自身属性 | 不查原型链 |
| `obj.key !== undefined` | 比较值 | 如果属性的值就是 undefined 会误判 |

```javascript
const obj = { name: "张三", score: undefined };

console.log("name" in obj);              // true
console.log(obj.hasOwnProperty("name")); // true

// 陷阱：score 的值是 undefined，但属性确实存在
console.log("score" in obj);             // true（属性存在）
console.log(obj.score !== undefined);    // false（值确实是 undefined）
```

### Object.keys() / Object.values() / Object.entries()

这三个方法是把对象"拆开"来处理的利器。它们都返回数组，让你可以用 `forEach`、`map`、`filter` 等数组方法来处理对象。

```javascript
const user = { name: "张三", age: 20, job: "学生" };

console.log(Object.keys(user));      // ["name", "age", "job"]
console.log(Object.values(user));    // ["张三", 20, "学生"]
console.log(Object.entries(user));   
// [["name","张三"], ["age",20], ["job","学生"]]
```

`Object.entries()` 返回二维数组特别适合遍历——结合数组解构可以写出非常简洁的代码：

```javascript
for (const [key, value] of Object.entries(user)) {
    console.log(`${key}: ${value}`);
}
```

### 可选链（Optional Chaining `?.`）

这是 ES2020 引入的语法，解决了一个常见痛点：**访问深层嵌套属性时，中间某层不存在就会抛错**。

**生活类比**：你要去朋友家的地下室拿东西。正常流程是：走进客厅 → 找楼梯 → 下地下室 → 拿东西。但如果朋友家根本没有地下室呢？你会一脚踩空（报错）。可选链就像每走一步都先伸手摸一下——"这里有楼梯吗？哦没有，那我返回 undefined 而不是摔下去。"

```javascript
// 没有可选链时，要这样层层检查
let city;
if (user && user.address && user.address.city) {
    city = user.address.city;
} else {
    city = "未知";
}

// 有了可选链，一行搞定
const city = user?.address?.city ?? "未知";
```

`?.` 的规则很简单：如果 `?.` 左边的值是 `null` 或 `undefined`，直接返回 `undefined`，不会继续访问右边的属性。否则正常访问。

注意：可选链不仅用于属性访问（`obj?.prop`），还能用于方法调用（`obj?.method?.()`）和数组索引（`arr?.[0]`）。

### 计算属性名

有时候属性名不是写死的，而是要运行时动态计算的。ES6 提供了计算属性名：

```javascript
const prefix = "user_";
const id = 42;

const obj = {
    [prefix + id]: "张三",   // 属性名是 "user_42"
    [prefix + "name"]: "李四", // 属性名是 "user_name"
};

console.log(obj.user_42);   // "张三"
console.log(obj.user_name); // "李四"
```

方括号里可以是任意表达式——函数调用、三元运算符、模板字符串都可以。

## 与 C 语言的对比

C 语言中，struct 的字段是编译期确定的，你想知道一个结构体有哪些字段只能查头文件。JS 提供了 `Object.keys()` 这样的运行时反射能力，程序可以在运行时检查、遍历对象的结构——这是两种思路的根本差异。

## 动手试试

1. 创建一个空对象，逐步添加属性、修改、删除，每一步打印对象
2. 用 `Object.keys()` 遍历一个对象的所有键，打印"键: 值"
3. 构造一个嵌套对象（三层深），分别用传统方式和可选链访问最深层的属性

## 本节小结

- 增/改直接赋值，删用 `delete`，查用 `.` 或 `[ ]`
- `in` 检查属性存在（含原型链），`hasOwnProperty` 只查自身
- `Object.keys/values/entries` 把对象转为数组，方便遍历
- 可选链 `?.` 安全访问深层属性，中间为 null/undefined 就短路返回 undefined
- 计算属性名 `[expr]` 允许动态生成属性名

## 下一节预告

A.18 解构与展开——从对象和数组中"抽取"数据的新姿势，一种让代码更简洁的语法糖。
