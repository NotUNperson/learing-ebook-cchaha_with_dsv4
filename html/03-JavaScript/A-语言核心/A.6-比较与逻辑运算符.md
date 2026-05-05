# A.6 比较与逻辑运算符

## 本节你会学到什么

- 比较运算符：`>` `<` `>=` `<=` `==` `===` `!=` `!==`
- 逻辑运算符：`&&`（与）、`||`（或）、`!`（非）
- 短路求值：`&&` 和 `||` 的"偷懒"机制
- 用短路求值写简洁代码：默认值和条件执行
- `??` 空值合并运算符（比 `||` 更精确）
- 三元运算符：`条件 ? 值1 : 值2`

## 正文

### 一、比较运算符

比较运算符用来比较两个值，返回布尔值（`true` 或 `false`）。和 C 语言基本一致。

```javascript
console.log(10 > 5);    // true
console.log(10 < 5);    // false
console.log(10 >= 10);  // true
console.log(10 <= 9);   // false
```

**严格相等和不等**（推荐使用）：

```javascript
console.log(5 === 5);    // true
console.log(5 === "5");  // false  ← 类型不同
console.log(5 !== "5");  // true   ← 类型不同
```

**宽松相等和不等**（不推荐）：

```javascript
console.log(5 == "5");   // true  ← 自动类型转换
console.log(5 != "5");   // false
```

关于 `===` 和 `==` 的详细区别，上一节已经讲过，这里复习一下：**默认用 `===`**。

> 生活类比：`>=` 和 `<=` 中，等号永远写在右边（不能写成 `=>`，那是箭头函数！）。你可以这样记：等号是"底座"，先有大于/小于的"尖嘴"，再放上等号的"底座"。

### 二、字符串也可以比较

JS 中字符串按字典序（Unicode 编码）比较：

```javascript
console.log("a" < "b");        // true
console.log("apple" < "banana"); // true
console.log("Apple" < "apple");  // true -- 大写字母编码小于小写
console.log("10" > "2");        // false -- 字典序："1" 的编码 < "2" 的编码
```

> 注意：字符串比较是按字符一个一个比的，`"10" < "2"` 结果是 `true`（因为 `"1"` 的编码 < `"2"` 的编码）。这和数字比较逻辑完全不同。如果要比较"数字大小"，请先转成 number。

### 三、逻辑运算符

#### `&&` ——逻辑与（AND）

两边都为 `true` 才返回 `true`：

```javascript
console.log(true && true);    // true
console.log(true && false);   // false
console.log(false && true);   // false
console.log(false && false);  // false

let age = 20;
let hasTicket = true;
console.log(age >= 18 && hasTicket);  // true -- 两个条件都满足
```

#### `||` ——逻辑或（OR）

只要有一边为 `true` 就返回 `true`：

```javascript
console.log(true || true);    // true
console.log(true || false);   // true
console.log(false || true);   // true
console.log(false || false);  // false

let isVIP = false;
let hasInvitation = true;
console.log(isVIP || hasInvitation);  // true -- 有一个满足就行
```

#### `!` ——逻辑非（NOT）

取反：

```javascript
console.log(!true);      // false
console.log(!false);     // true
console.log(!0);         // true -- 0 是假值，取反为 true
console.log(!"hello");   // false -- 非空字符串是真值，取反为 false
```

### 四、短路求值——`&&` 和 `||` 的"偷懒"机制

这是 JS 中一个强大且常用的特性。

**`&&` 的短路**：如果左边是假值，右边根本不会执行（因为无论右边是什么，整体都是 `false`）。

**`||` 的短路**：如果左边是真值，右边不会执行（因为无论右边是什么，整体都是 `true`）。

```javascript
// && 短路
false && console.log("这行永远不会打印");  // 不打印

// || 短路
true || console.log("这行也永远不会打印");  // 不打印
```

利用短路求值，可以写出很简洁的代码：

```javascript
// 用 || 设置默认值
let name = "";                        // 空字符串是假值
let displayName = name || "匿名用户";  // 取右边
console.log(displayName);             // "匿名用户"

// 用 && 做条件执行
let isLoggedIn = true;
isLoggedIn && console.log("欢迎回来！");  // 只有登录时才打印

// 传统写法 vs 短路写法
// 传统写法：
if (isLoggedIn) {
    console.log("欢迎回来！");
}
// 短路写法（更简洁）：
isLoggedIn && console.log("欢迎回来！");
```

> 生活类比：`&&` 像一个严格的门卫——第一个条件不合格就别想进门，连第二个条件都不问。`||` 像一个宽松的门卫——第一个条件合格就直接放行，第二个条件看都不看。

### 五、`||` 的常见陷阱：0 和空字符串的问题

`||` 会把所有假值都当做"不合格"，包括 `0`、`""`、`false`：

```javascript
let score = 0;
let displayScore = score || 60;     // 60！因为 0 是假值，被跳过了
console.log(displayScore);          // 60  ← 这可能不是你想要的结果！

let username = "";
let displayName = username || "用户"; // "用户" -- 空字符串被跳过了
```

你本来想表达"如果没有设置分数，默认 60 分"，但 0 分被你误判成了"没设置"。这就是 `||` 的局限性。

### 六、`??` ——空值合并运算符（Nullish Coalescing）

ES2020 引入了 `??` 运算符来解决上述问题。**`??` 只在左侧为 `null` 或 `undefined` 时才取右侧的值**。

```javascript
// ?? 比 || 更精确
let score = 0;
console.log(score || 60);   // 60 -- 0 被当成了"空"（不够精确）
console.log(score ?? 60);   // 0  -- 0 是有效值，保留！（正确）

let name = "";
console.log(name || "匿名"); // "匿名" -- "" 被当成了"空"
console.log(name ?? "匿名"); // "" -- 空字符串是有效的，保留！

let nothing = null;
console.log(nothing ?? "默认值"); // "默认值" -- null 被正确识别
```

**结论**：想给变量一个默认值时，优先考虑 `??`，除非你确实想把 `0`、`""`、`false` 也当"空"处理。

### 七、三元运算符

三元运算符 `? :` 是 `if-else` 的简写形式。和 C 语言一模一样：

```javascript
// 语法：条件 ? 表达式1 : 表达式2

let age = 20;
let status = age >= 18 ? "成年人" : "未成年人";
console.log(status);  // "成年人"

// 可以嵌套，但不推荐（难读）
let score = 85;
let grade = score >= 90 ? "A" : score >= 80 ? "B" : score >= 70 ? "C" : "D";
console.log(grade);  // "B"
```

三元运算符适合简单的"二选一"场景。如果是复杂的多分支判断，用 `if-else` 更清晰。

---

## 动手试试

1. 比较 `"apple"` 和 `"Banana"`，观察大小写对比较结果的影响。
2. 写一个变量 `userInput = null`，然后用 `??` 和 `||` 分别给它一个默认值，对比结果。
3. 用短路求值写一句代码：只有当变量 `debug = true` 时才打印 `"调试信息"`。
4. 用三元运算符判断一个年份是否是闰年（能被 4 整除但不能被 100 整除，或者能被 400 整除）。

---

## 与 C 语言的对比

比较运算符 (`> < >= <=`) 和逻辑运算符 (`&& || !`) 的语法和 C 完全一样。主要区别在于：(1) C 语言没有 `===`，C 的 `==` 就等同于 JS 的 `===`（因为 C 有编译时类型检查，不会发生隐式类型转换比较）；(2) JS 的 `||` 和 `&&` 返回的是**操作数本身的值**（不只是 0/1），利用短路可以实现更灵活的写法；(3) C 没有 `??` 空值合并运算符。

---

## 本节小结

- 比较运算符和 C 一样，但 JS 有 `===`/`!==` 严格版
- `&&`、`||`、`!` 逻辑运算符，支持短路求值
- `||` 短路可做默认值，但会把 `0`/`""`/`false` 当"空"
- `??` 更精确，只在 `null`/`undefined` 时取默认值
- 三元运算符 `条件 ? 值1 : 值2` 和 C 一样

---

## 下一节预告

学了运算符，接下来就是真正的程序逻辑控制。下一节讲条件分支：`if-else` 和 `switch`，还会重点讲 JS 的"真值/假值"概念，你会在那里明白为什么 `if ([])` 会执行。
