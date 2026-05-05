# B.9 事件对象与委托

## 本节你会学到什么

- `event` 对象的核心属性：`type`、`target`、`currentTarget`
- `preventDefault()` 阻止默认行为
- `stopPropagation()` 阻止冒泡
- 事件委托的原理与好处——利用冒泡，父元素监听子元素

## 正文

### 收到一封信，信封上写了什么？

上一节你学会了"登记事件响应员"（addEventListener）。现在当事件触发时，浏览器不只是调用你的函数——它还会**自动传入一个参数**：`event` 对象。

这个 `event` 对象就像一封信的信封：信封上写着谁发的（target）、发给谁（currentTarget）、什么类型（type），还有邮戳、时间等附加信息。

```javascript
element.addEventListener("click", function(event) {
  // event 就是浏览器自动传入的"信封"
  console.log(event.type);          // "click"
  console.log(event.target);        // 实际被点的元素
  console.log(event.currentTarget); // 监听器绑在哪
  console.log(event.clientX);       // 鼠标的 X 坐标
  console.log(event.clientY);       // 鼠标的 Y 坐标
});
```

### event.target vs event.currentTarget —— 分清"谁触发的"和"谁在听的"

这两个属性是新手最容易混淆的：

- **`event.target`**：**实际触发事件的元素**——你手指真正碰到的那个元素（事件流的最深层元素，永远不变）
- **`event.currentTarget`**：**当前处理事件的元素**——监听器绑在哪个元素上（在冒泡过程中会变）

```html
<div id="outer">
  <button id="inner">点我</button>
</div>

<script>
var outer = document.getElementById("outer");

outer.addEventListener("click", function(event) {
  console.log(event.target);        // <button id="inner">   —— 你点的是按钮！
  console.log(event.currentTarget); // <div id="outer">      —— 监听器绑在 div 上
});
</script>
```

类比：你敲了张三家的门（`target` = 门），但开门的可能是张三他爸（`currentTarget` = 张三他爸）。

### preventDefault() —— 阻止浏览器的"默认动作"

有些 HTML 元素有**默认行为**：`<a>` 会跳转、`<form>` 的 submit 按钮会提交并刷新页面、右键会弹出菜单。

```javascript
// 阻止链接跳转
var link = document.querySelector("a");
link.addEventListener("click", function(event) {
  event.preventDefault();  // 链接不会跳转了！
  console.log("链接被点击，但跳转被阻止了");
});

// 阻止表单提交（B.12 详讲）
form.addEventListener("submit", function(event) {
  event.preventDefault();  // 表单不提交了，用 JS 自己处理
  // ...验证数据、发 AJAX 等
});
```

`preventDefault()` 就像在门铃上加了一个开关——你关掉它，门铃就不响了。但注意：**preventDefault 不阻止事件冒泡**——事件还会继续往上冒，只是默认行为被取消了。

### stopPropagation() —— 阻止事件冒泡

如果你不想让事件继续往上冒（只在你这一层处理就够了），用 `stopPropagation()`：

```javascript
var inner = document.querySelector("#inner");
var outer = document.querySelector("#outer");

inner.addEventListener("click", function(event) {
  event.stopPropagation();  // 事件到此为止，不会再冒泡到 outer
  console.log("内层处理完毕，事件不再往上冒");
});

outer.addEventListener("click", function() {
  console.log("这行不会打印——因为冒泡被 stopPropagation 阻断了");
});
```

`stopPropagation()` 就像在水管中间加了一个阀门——关掉它，气泡就不会再往上浮了。

> 注意：不要滥用 `stopPropagation()`。事件委托（下面讲）依赖冒泡，如果你在一个地方阻断了冒泡，外层的事件委托就会失效。

### 事件委托 —— 利用冒泡的巧妙设计

事件委托是 DOM 编程中最重要的技巧之一。它的思想很简单：

**不要给每一个子元素都绑监听器。把监听器绑在它们的共同父元素上，利用冒泡机制来处理子元素的事件。**

#### 为什么需要委托？

假设你有一个 TODO 列表，用户可以动态添加和删除任务。每个任务旁边有一个"删除"按钮。

**不用委托的写法（低效）：**
```javascript
// 每次新增任务都要给新按钮单独绑事件
function addTask(text) {
  var li = document.createElement("li");
  li.textContent = text;
  var btn = document.createElement("button");
  btn.textContent = "删除";
  btn.addEventListener("click", function() {
    li.remove();
  });
  li.append(btn);
  ul.append(li);
}
// 问题：每新增一个任务，就要多一个监听器。如果有一千个任务呢？
```

**用委托的写法（优雅，高效）：**
```javascript
// 只在父元素 ul 上注册一个监听器
ul.addEventListener("click", function(event) {
  // event.target 是实际被点的元素
  if (event.target.tagName === "BUTTON") {
    // 找到按钮所在的 li 并删除
    event.target.closest("li").remove();
  }
});

// 新增任务时不需要绑任何事件！事件会自动冒泡到 ul
function addTask(text) {
  var li = document.createElement("li");
  li.textContent = text;
  var btn = document.createElement("button");
  btn.textContent = "删除";
  li.append(btn);
  ul.append(li);
}
```

#### 委托的好处

1. **减少监听器数量**：一千个子元素也只需要一个父元素上的监听器
2. **动态元素自动生效**：后添加的子元素会自动拥有事件处理（因为它的事件会冒泡上来）
3. **代码更简洁**：新增元素时不需要再关心事件绑定

#### closest() —— 事件委托的好搭档

`closest("选择器")` 从当前元素开始，逐层向上查找，返回第一个匹配的祖先元素（包括自己）。

```javascript
// 无论用户点了按钮、按钮里的文字、还是按钮旁边，都能找到所在的 li
event.target.closest("li").remove();
```

### 关联 JS-A 知识

事件委托本质上是你学过的"算法思维"——把重复的事情抽象到更高的层级去处理。就像你在数据结构课上学过的：与其在一千个节点上分别操作，不如在它们的父节点上操作一次。

## 动手试试

1. 打开示例文件 `B.9-delegation.html`，点击列表项的"删除"按钮，观察只有 ul 上有一个监听器
2. 在控制台中查看 `event.target` 和 `event.currentTarget` 的区别
3. 尝试点击一个"完成"按钮旁边的空白区域（比如按钮外的 li 文字区域），观察事件委托如何用 closest() 处理
4. 新增几个任务，不用重新绑事件，点击删除也能正常工作——这就是委托的威力

## 本节小结

`event` 对象提供了事件的完整信息：`type`（事件类型）、`target`（实际触发元素）、`currentTarget`（监听器绑定元素）。`preventDefault()` 取消默认行为，`stopPropagation()` 阻止冒泡。**事件委托**利用冒泡机制，把监听器绑在父元素上，通过 `event.target` 判断来源——减少监听器数量、动态元素自动获得事件处理、代码更简洁。

## 下一节预告

B.10《常用事件类型》——现在你会绑定事件、读 event 对象、用事件委托了。接下来系统地了解浏览器提供了哪些事件类型：鼠标、键盘、表单、文档。
