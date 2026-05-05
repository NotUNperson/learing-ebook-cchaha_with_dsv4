# B.7 删除与替换节点

## 本节你会学到什么

- `element.remove()` —— 现代方法，直接删除自己
- `parent.removeChild(child)` —— 老方法，需要知道父元素
- `parent.replaceChild(newChild, oldChild)` —— 替换子节点
- 清空所有子节点的多种方式：`innerHTML = ""`、循环 `removeChild`

## 正文

### 拆掉不需要的"房间"

上一节你是建筑队——造墙、安门、加窗户（创建和插入节点）。但建好了不满意怎么办？你得会**拆**。

在 DOM 里，删除和替换也是非常重要的操作。一个动态页面需要能够移除旧内容、替换过时信息。

### remove() —— 自己删自己（现代方法，推荐）

```javascript
var el = document.querySelector("#old-banner");
el.remove();
// el 从页面上消失了
```

`remove()` 是最直接的方式——元素自己调用，自己从 DOM 树上脱离。就像一块积木自己从拼搭中抽了出来。

注意：`remove()` 只是把元素从 DOM 树上取下，它还没有被销毁。如果你把它存在变量里，可以再插回去：

```javascript
var saved = document.querySelector("#banner");
saved.remove();       // 从页面消失
// ... 过一会 ...
document.body.append(saved);  // 又回来了！
```

### removeChild —— 老方法，需要找"爸爸"

```javascript
var parent = document.querySelector("ul");
var child = document.querySelector("li");
parent.removeChild(child);
```

`removeChild` 必须在父元素上调用，传入要删除的子元素。相比 `remove()`，它要多一步——你得先找到父元素。现在有新项目可以直接用 `remove()`，但阅读老代码时会经常看到 `removeChild`。

### replaceChild —— 以新换旧

```javascript
var parent = document.querySelector("ul");
var oldItem = document.querySelector("li.old");
var newItem = document.createElement("li");
newItem.textContent = "我是新来的";

parent.replaceChild(newItem, oldItem);
```

`replaceChild(newChild, oldChild)` 在父元素上调用，用新节点替换旧节点。就像换灯泡——把旧的拧下来，新的拧上去。

现代替代方案（更简洁）：

```javascript
oldItem.replaceWith(newItem);  // 用新元素替换旧元素，不需要找父元素
```

### 清空所有子节点 —— 三种方式

**方式一：innerHTML = ""（最简洁）**

```javascript
var ul = document.querySelector("ul");
ul.innerHTML = "";  // 一瞬间全清空
```

**方式二：循环 removeChild（逐个删除）**

```javascript
var ul = document.querySelector("ul");
while (ul.firstChild) {
  ul.removeChild(ul.firstChild);
}
```

**方式三：循环 remove()（逐个自删）**

```javascript
var ul = document.querySelector("ul");
var children = ul.children;
while (children.length > 0) {
  children[0].remove();
}
```

三种方式都能清空，`innerHTML = ""` 最简短，但要注意这也会清除子元素上绑定的 JS 事件（B.8 会讲）。

### 用循环删除特定项

实际开发中，你往往不是清空全部，而是删除特定的：

```javascript
// 删除所有 class 为 "done" 的 li
var doneItems = document.querySelectorAll("li.done");
doneItems.forEach(function(item) {
  item.remove();
});
```

或者删除列表中的某一项（比如点击删除按钮时）：

```javascript
// 在点击事件中，删除被点的那个元素的父元素
button.addEventListener("click", function(e) {
  e.target.closest("li").remove();
  // closest 是向上查找最近的匹配祖先元素（这个方法非常实用！）
});
```

（事件监听的细节我们会在 B.8 和 B.9 详细学，这里先用 `onclick` 属性演示。）

## 动手试试

1. 打开示例文件 `B.7-remove.html`，点击各种删除按钮，观察列表的变化
2. 使用"逐个删除"按钮，看列表项一个一个消失
3. 打开控制台，试试 `document.querySelector("li").remove()` 只删第一个 li
4. 尝试把一个被 remove 掉的元素用变量保存下来，然后重新 append 回去
5. 用 `querySelectorAll` 选中所有某一类的元素，一次性全部 remove

## 本节小结

删除节点推荐用 `element.remove()`（自己删自己）；老方法是 `parent.removeChild(child)`（需要知道父元素）。替换节点用 `parent.replaceChild(new, old)` 或更现代的 `old.replaceWith(new)`。清空所有子节点 `innerHTML = ""` 最简洁，循环 `removeChild` 更精确。被 remove 的元素只是脱离 DOM 树，可以被重新插入。

## 下一节预告

B.8《事件模型》——页面元素能增删改了，但它还是"死"的——用户点它、按键盘、滚动都没有反应。接下来学习如何让页面响应用户操作：事件。
