# B.11 操作 class 与 style

## 本节你会学到什么

- `classList` API：`add`、`remove`、`toggle`、`contains`、`replace`
- `style` 对象：设置内联样式（权重最高）
- `getComputedStyle()`：获取计算后的最终样式（只读）
- 最佳实践：改样式用 class，JS 只负责切换类名

## 正文

### 给演员换戏服，而不是在演员身上画衣服

CSS 已经定义好了各种"戏服"（class）——`.highlight { background: yellow; }`、`.hidden { display: none; }`。你的 JS 要做的，是在合适的时机给元素**穿上或脱下**这些戏服，而不是直接往元素身上画（内联 style）。

类比：你是话剧导演。每个演员进化妆间时已经准备好了多套戏服（CSS 类）。你的工作是：第一幕让他穿西装（`add("suit")`），第二幕换军装（`remove("suit"); add("uniform")`）。你不会拿着画笔直接在演员身上画一件西装——那太慢了，而且很难洗。

### classList API —— 类名操作的瑞士军刀

`classList` 是最推荐的类名操作方式。它提供了全套方法：

```javascript
var el = document.querySelector("div");

// 添加一个类（如果已经有了则不重复添加）
el.classList.add("highlight");

// 删除一个类
el.classList.remove("highlight");

// 切换——有则删，无则加（最常用！）
el.classList.toggle("active");
// 相当于：
// if (el.classList.contains("active")) {
//   el.classList.remove("active");
// } else {
//   el.classList.add("active");
// }

// 判断是否存在
if (el.classList.contains("highlight")) {
  console.log("有 highlight 类");
}

// 用新类替换旧类
el.classList.replace("old-class", "new-class");
```

`toggle` 是使用频率最高的——它可以接受第二个参数（布尔值），强制添加或删除：

```javascript
// 第二个参数 true = 强制添加，false = 强制删除
el.classList.toggle("active", isActive);  // isActive 为 true 则一定有 active
```

### 为什么不要直接操作 className 字符串

老代码中你可能会看到：

```javascript
el.className = "highlight active";     // 粗暴覆盖，之前的所有类名全丢了！
el.className += " active";             // 拼接，容易多出空格或重复
```

`className` 是一个字符串。你每次修改都要小心处理空格、去重、避免误删其他类。而 `classList` 自动处理了这些，安全又省心。

### style 对象 —— 直接设置内联样式

有时你需要动态计算样式值（比如颜色由用户拖动滑块决定），没法预先写在 CSS 里。这时用 `style` 对象：

```javascript
var el = document.querySelector("div");

// 设置单个样式（CSS 属性名转驼峰：background-color → backgroundColor）
el.style.color = "red";
el.style.backgroundColor = "#333";
el.style.fontSize = "20px";
el.style.display = "none";

// 批量设置（用 cssText）
el.style.cssText = "color: red; font-size: 20px; padding: 10px;";
```

注意：`style` 对象设置的是**内联样式**（即 HTML 的 `style=""` 属性），权重为 1000，会覆盖 CSS 文件中的规则。

**原则**：能用 class 解决的问题，不要用 `style.xxx` 写死。`style` 只用于**值在运行时动态计算**的情况。

### getComputedStyle —— 读取最终生效的样式

你可能会好奇：一个元素最终显示成什么样？它的字体大小到底是多少 px？这些信息不在 `element.style` 里（`element.style` 只反映内联样式）。你需要 `getComputedStyle()`：

```javascript
var el = document.querySelector("h1");
var styles = getComputedStyle(el);

console.log(styles.fontSize);      // "32px" —— CSS 中定义的计算后实际值
console.log(styles.color);         // "rgb(0, 0, 0)" —— 总是 rgb 格式
console.log(styles.display);       // "block"
console.log(styles.marginTop);     // "21.44px"
```

`getComputedStyle` 返回的对象是**只读**的——你不能通过它来修改样式，只能读。

一个常见用途：判断元素是否可见、获取动画当前值等。

### 最佳实践：职责分离

| 职责 | 负责方 | 方式 |
|------|--------|------|
| 定义样式（颜色、大小、布局） | CSS | 写 `.class { ... }` |
| 切换状态（亮/暗、显示/隐藏） | JS | `classList.toggle/add/remove` |
| 动态计算值（进度条宽度、拖拽位置） | JS | `style.width = ...` |

一句话：**JS 管行为（什么时候变），CSS 管外观（变成什么样）。**

### 关联 CSS 知识

你在 CSS 篇中学过的所有选择器、伪类、过渡动画，都可以和这里的 classList 配合使用：

```css
/* CSS 中定义过渡 */
.box {
  transition: all 0.3s ease;
}
.box.active {
  background: #ff9800;
  transform: scale(1.05);
}
```

```javascript
// JS 只需一行切换
el.classList.toggle("active");
// CSS 自动负责动画效果！过渡由 CSS transition 完成
```

## 动手试试

1. 打开示例文件 `B.11-class-style.html`，点击按钮切换元素的 class，观察外观变化
2. 在控制台输入 `getComputedStyle(document.querySelector("h1")).fontSize`，查看计算后的字体大小
3. 试用 `toggle` 方法：在控制台对某个元素执行 `document.querySelector("#toggle-demo").classList.toggle("active")` 多次，观察来回切换
4. 对比：直接用 `style.color = "red"` 和通过 `classList.add("red-text")`，思考哪种方式更灵活

## 本节小结

操作样式的推荐方式是 classList API：`add`、`remove`、`toggle`（开关，最常用）、`contains`、`replace`。避免直接操作 `className` 字符串。`style` 对象用于动态计算值（设置内联样式）。`getComputedStyle()` 读取最终计算样式（只读）。最佳实践：CSS 负责定义样式，JS 负责用 classList 切换类名。

## 下一节预告

B.12《表单取值与校验》——表单是网页和用户交换数据的主渠道。怎么用 JS 取到表单各字段的值？怎么校验用户输入？
