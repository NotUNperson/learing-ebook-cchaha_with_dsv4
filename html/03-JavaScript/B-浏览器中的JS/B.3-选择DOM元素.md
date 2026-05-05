# B.3 选择 DOM 元素

## 本节你会学到什么

- 老牌选择方法：`getElementById`、`getElementsByClassName`、`getElementsByTagName`
- 现代万能选择器：`querySelector` 和 `querySelectorAll`
- 动态集合 vs 静态集合的区别
- 为什么推荐默认使用 `querySelector` / `querySelectorAll`

## 正文

### 找人不能靠喊——你需要"寻人启事"

上节你知道了 DOM 是一棵树，`document` 是入口。现在的问题变成：树上这么多节点，我怎么找到我想要的那个？

类比：你站在一栋 30 层办公楼的大厅，要找"张三"。你能站在大厅喊"张——三——"吗？不能。你需要一个寻人启事——"3 楼 302 室，戴眼镜、穿蓝色衬衫的那个人"。

在 DOM 里，**选择器方法**就是这份"寻人启事"。它让你用不同的条件组合来精确地抓到页面上的元素。

### 老牌方法（兼容性好，历史悠久）

这些方法从 JavaScript 诞生之初就存在，几乎所有浏览器都支持。你会在老代码里大量看到它们。

#### getElementById —— 按身份证号找人

```javascript
var el = document.getElementById("header");
// 返回：id 为 "header" 的唯一元素，找不到返回 null
```

身份证号（id）在一个页面里必须是唯一的。`getElementById` 就是按身份证号找人——最多一个结果，找不到就 null。

这个方法是**最快的**选择方式（浏览器内部用哈希表查找），如果你的元素有 id，优先用它。

注意：方法名是 `getElementById`（单数 Element），不是 `getElementsById`。

#### getElementsByClassName —— 按"标签"找人（返回动态集合）

```javascript
var items = document.getElementsByClassName("item");
// 返回：一个 HTMLCollection（动态集合），包含所有 class 含 "item" 的元素
```

所有贴着"item"标签的元素都会进入这个集合。它的特点是**动态**——如果页面上新增或删除了带有 class="item" 的元素，这个集合会自动同步更新。

注意：方法名是 `getElementsByClassName`（复数 Elements），不是 `getElementByClassName`。

#### getElementsByTagName —— 按"物种"找人

```javascript
var paragraphs = document.getElementsByTagName("p");
// 返回：一个 HTMLCollection（动态集合），包含所有 <p> 元素
```

同样返回**动态集合**。

### 现代方法（推荐，CSS 选择器有多强它就有多强）

#### querySelector —— 选第一个匹配的

```javascript
var el = document.querySelector(".intro");     // class 选择器
var el = document.querySelector("#main");       // id 选择器
var el = document.querySelector("p");           // 标签选择器
var el = document.querySelector("ul > li");     // 子代组合器
var el = document.querySelector("input[type='email']"); // 属性选择器
```

`querySelector` 接收一个**CSS 选择器字符串**，返回**第一个**匹配的元素。你在 CSS 部分学过的所有选择器（标签、class、id、属性、伪类、组合器），全都可以直接拿来用。

#### querySelectorAll —— 选所有匹配的

```javascript
var items = document.querySelectorAll(".item");
// 返回：一个 NodeList（静态列表），包含所有匹配的元素
```

返回的是**静态 NodeList**——它是对当前页面状态的快照。页面后续的增删不会影响这个 NodeList。

### 动态集合 vs 静态列表——你必须知道的区别

这是新手最容易踩的坑之一：

```javascript
// 动态集合：getElementsByClassName 返回的 HTMLCollection
var dynamicList = document.getElementsByClassName("item");
console.log(dynamicList.length); // 假设是 3

// 新增一个 item
var newItem = document.createElement("div");
newItem.className = "item";
document.body.appendChild(newItem);

console.log(dynamicList.length); // 变成 4 了！——动态集合自动更新

// 静态列表：querySelectorAll 返回的 NodeList
var staticList = document.querySelectorAll(".item");
console.log(staticList.length);  // 假设是 4

document.body.appendChild(document.createElement("div")).className = "item";

console.log(staticList.length);  // 还是 4！——静态列表不变
```

**动态集合**像一个"实时查询"：每次访问 `.length` 时浏览器重新查一遍页面。
**静态列表**像一个"快照"：拍完照后就和页面后续变化无关了。

日常开发中，静态列表的行为更可预测，这也是推荐 `querySelectorAll` 的一个原因。

### 选择器方法速查表

| 方法 | 参数 | 返回类型 | 动态/静态 | 推荐度 |
|------|------|---------|-----------|--------|
| `getElementById` | id 字符串 | 单个元素/null | -- | 有 id 时首选 |
| `getElementsByClassName` | class 字符串 | HTMLCollection | 动态 | 老代码中常见 |
| `getElementsByTagName` | 标签名 | HTMLCollection | 动态 | 老代码中常见 |
| `querySelector` | CSS 选择器 | 单个元素/null | 静态 | **推荐！** |
| `querySelectorAll` | CSS 选择器 | NodeList | 静态 | **推荐！** |

### 关联 CSS 知识

你在 CSS 篇中学过的选择器现在全部能用上：

```javascript
// CSS 后代选择器 → querySelector
document.querySelectorAll("article p");      // article 里的所有 p

// CSS 子代选择器 →
document.querySelectorAll("ul > li");       // ul 的直接子 li

// CSS 属性选择器 →
document.querySelectorAll("input[required]"); // 所有 required 的 input

// CSS 伪类 →
document.querySelectorAll("li:first-child");  // 各列表的第一个 li
```

JS 没有发明新的选择方式，它直接复用了 CSS 的选择器语法——学一遍，两处用。

## 动手试试

1. 打开示例文件 `B.3-select.html`，观察 JS 代码如何选中不同元素
2. 按 F12 打开控制台，手动输入 `document.querySelectorAll("li")`，看看返回什么
3. 试一试：输入 `document.querySelector("li")` 和 `document.querySelectorAll("li")[0]`——它们返回的是同一个元素吗？
4. 对比实验：先用 `getElementsByClassName("highlight")` 获取一个动态集合，再用 JS 新增一个 `highlight` 元素，看看动态集合的 `.length` 变没变

## 本节小结

选择 DOM 元素有两种路径：老牌方法（getElementById 最快，getElementsByClassName/TagName 返回动态集合）和现代方法（querySelector/querySelectorAll 用 CSS 选择器，返回静态列表）。推荐默认使用 querySelector 系列——CSS 选择器有多强大，它们就有多强大。注意动态集合会自动同步页面变化，静态列表是快照。

## 下一节预告

B.4《修改元素内容》——抓到元素了，下一步自然是改它里面的文字和结构。textContent、innerHTML、innerText 三兄弟登场。
