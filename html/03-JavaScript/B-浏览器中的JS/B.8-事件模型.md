# B.8 事件模型

## 本节你会学到什么

- 什么是"事件"——用户在页面上的操作
- 事件流三阶段：捕获、目标、冒泡
- `addEventListener` 的用法和第三个参数的含义
- 用嵌套 div 演示冒泡过程

## 正文

### 页面是"死"的，直到事件让它活起来

此前学的一切——选择元素、修改内容、增删节点——都是 JS **主动**对页面做事情。但真正的网页交互是**双向**的：用户点击按钮、按下键盘、滚动页面，JS **被动**收到通知然后响应。

这套"通知-响应"机制就叫**事件（Event）**。

类比：你家的门铃。没人按的时候，门铃静静地挂着。有人按了（事件发生），门铃响了（响应），你去开门。事件的三个要素：
1. **事件源**：门铃按钮（哪个元素触发了事件）
2. **事件类型**："被按下"（click? keydown? scroll?）
3. **事件处理器**：响铃、开门（JS 函数，事件发生后做什么）

### 事件流：从大门走到卧室

当一个事件发生时（比如你在一个嵌套的 div 上点击），浏览器并不是只通知这一个 div。事件要**走一段旅程**。这段旅程分三个阶段：

**阶段 1——捕获（Capture）：从外到内**
浏览器从最外层的 `document` 开始，逐层向内，一直走到你真正点击的那个元素。

**阶段 2——目标（Target）：到达**
事件到达你真正点击的那个元素。

**阶段 3——冒泡（Bubble）：从内到外**
事件从目标元素逐层向外，一直冒到 `document`。就像水里的气泡，从水底往上浮。

```
 点击一个嵌套 div 时：

     document
        |
       html          ← 捕获阶段（从外到内）
        |
       body
        |
    ┌──div#outer────┐
    │  ┌─div#inner─┐│
    │  │  点这里！  ││   ← 目标阶段
    │  └───────────┘│
    └───────────────┘
        |
       body          ← 冒泡阶段（从内到外）
        |
       html
        |
     document
```

### addEventListener —— 登记"事件响应员"

```javascript
var btn = document.querySelector("button");

btn.addEventListener("click", function() {
  console.log("按钮被点击了！");
});
```

`addEventListener` 接收三个参数：
1. **事件类型**（字符串）：`"click"`, `"keydown"`, `"scroll"`, `"submit"` 等
2. **处理函数**：事件发生时执行的函数
3. **第三个参数**（布尔值或对象，决定在哪个阶段触发）：
   - `false`（默认）：在**冒泡**阶段触发（最常用）
   - `true`：在**捕获**阶段触发（较少用）

```javascript
// 在捕获阶段触发事件
element.addEventListener("click", handler, true);

// 在冒泡阶段触发事件（默认，最常用）
element.addEventListener("click", handler, false);
// 等价于：
element.addEventListener("click", handler);
```

### 为什么默认用冒泡阶段？

因为冒泡阶段"由内而外"，更符合直觉。你点击了一个按钮，处理函数自然应该针对"这个按钮"来写。而且冒泡也是"事件委托"的基础（B.9 详讲）——你可以把监听器放在父元素上，子元素的事件会冒泡上来。

### 整段演示：嵌套 div 的点击事件

```html
<div id="outer" style="padding: 40px; background: #eee;">
  外层 div
  <div id="inner" style="padding: 20px; background: #ccc;">
    内层 div（点这里）
  </div>
</div>

<script>
  var outer = document.getElementById("outer");
  var inner = document.getElementById("inner");

  // 冒泡阶段（默认，从内到外）
  outer.addEventListener("click", function() {
    console.log("外层 div 收到点击（冒泡阶段）");
  });

  inner.addEventListener("click", function() {
    console.log("内层 div 收到点击");
  });
</script>
```

当你点击内层 div 时，控制台输出：
1. "内层 div 收到点击"（先触发内层的）
2. "外层 div 收到点击（冒泡阶段）"（再冒泡到外层的）

### onclick 属性 vs addEventListener

你在老代码中可能经常看到 `element.onclick = function(){}` 或 HTML 里的 `onclick` 属性。和 `addEventListener` 的区别是：

| 特性 | onclick 属性 | addEventListener |
|------|-------------|-----------------|
| 同一事件绑多个处理函数 | 不支持（后者覆盖前者） | 支持 |
| 控制触发阶段 | 只有冒泡 | 可选择捕获/冒泡 |
| 移除监听 | 赋 null | 用 removeEventListener |
| 写在 HTML 属性里 | 支持 | 不支持 |

**推荐：一律用 `addEventListener`。** 原因：可绑多个处理函数、可在捕获阶段触发、可单独移除。

### 关联 JS-A 知识

事件处理函数就是你在 A 篇学过的"回调函数"（callback）——把函数当参数传给另一个函数，等条件满足时被调用。`addEventListener` 的第二个参数就是一个回调函数。

## 动手试试

1. 打开示例文件 `B.8-events.html`，点击嵌套的不同颜色的方块，观察控制台输出顺序
2. 观察：点击内层方块时，外层的监听器也触发了——这就是冒泡
3. 在控制台中，注意捕获阶段的输出排在冒泡阶段**之前**（即使捕获监听器绑在更外层的元素上）
4. 试着给某个监听器加上第三个参数 `true`，观察捕获和冒泡的输出顺序变化

## 本节小结

事件是浏览器对用户操作的响应机制。事件流分三阶段：捕获（从外到内）→ 目标 → 冒泡（从内到外）。`addEventListener` 用于登记事件处理器，默认在冒泡阶段触发。单元素的 onclick 属性只能绑一个处理函数，推荐一律用 `addEventListener`。

## 下一节预告

B.9《事件对象与委托》——事件触发时，浏览器自动传入了一个 `event` 对象，它包含了这次点击的全部信息。而且利用冒泡机制，我们可以把监听器绑在父元素上，减少监听器数量——事件委托。
