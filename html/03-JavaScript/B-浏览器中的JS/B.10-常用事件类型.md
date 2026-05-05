# B.10 常用事件类型

## 本节你会学到什么

- 鼠标事件：click、dblclick、mouseenter/leave、mouseover/out、mousemove
- 键盘事件：keydown、keyup，用 `event.key` 判断哪个键
- 表单事件：input、change、submit、focus/blur
- 文档事件：DOMContentLoaded vs load

## 正文

### 你的页面是一座"感应门之城"

现代网页不是静态的——用户动鼠标、敲键盘、提交表单、滚动页面，每个动作都产生事件。浏览器提供了几十种事件类型，但日常开发中你只需要掌握不到十种。

想象你走进一座智能大楼：
- 你走到门口，门自动打开——**鼠标事件**
- 你在密码锁上输入密码——**键盘事件**
- 你填了一张访客登记表——**表单事件**
- 大楼的整体框架搭建完毕——**文档事件**

### 鼠标事件

| 事件 | 触发时机 | 是否冒泡 | 说明 |
|------|---------|---------|------|
| `click` | 按下并释放 | 冒泡 | 最常用 |
| `dblclick` | 快速双击 | 冒泡 | 双击 |
| `mousedown` | 按下鼠标键 | 冒泡 | 按下去就触发 |
| `mouseup` | 释放鼠标键 | 冒泡 | 松开时触发 |
| `mouseenter` | 鼠标进入元素 | 不冒泡 | 进入自身触发，**子元素不算** |
| `mouseleave` | 鼠标离开元素 | 不冒泡 | 离开自身触发，**子元素不算** |
| `mouseover` | 鼠标进入元素 | 冒泡 | 进入自身和子元素都触发 |
| `mouseout` | 鼠标离开元素 | 冒泡 | 离开自身和子元素都触发 |
| `mousemove` | 鼠标在元素上移动 | 冒泡 | 频率极高，不要做重活 |

**推荐：一般用 `mouseenter` / `mouseleave`**，因为它们不会因为移动到子元素上而反复触发。

```javascript
var box = document.querySelector(".box");

box.addEventListener("mouseenter", function() {
  box.style.background = "#e8f4fd";
});

box.addEventListener("mouseleave", function() {
  box.style.background = "";
});
```

### 键盘事件

| 事件 | 触发时机 | 说明 |
|------|---------|------|
| `keydown` | 按下键 | 最常用，按住不放会重复触发 |
| `keyup` | 释放键 | 只触发一次 |
| `keypress` | 按下字符键 | 已废弃，不要再用 |

**用 `event.key` 判断按了哪个键：**

```javascript
document.addEventListener("keydown", function(event) {
  console.log(event.key);  // "a", "Enter", "Escape", "ArrowUp"...

  if (event.key === "Escape") {
    closeModal();
  }
  if (event.key === "Enter") {
    submitForm();
  }
});
```

`event.key` 的值是人可读的键名：字母返回 "a"-"z"，特殊键返回 "Enter"、"Escape"、"Backspace"、"ArrowUp"、"ArrowDown"、" "（空格）等。

另外还有 `event.ctrlKey`、`event.shiftKey`、`event.altKey` 可以判断组合键：

```javascript
document.addEventListener("keydown", function(event) {
  if (event.ctrlKey && event.key === "s") {
    event.preventDefault();  // 阻止浏览器保存网页
    console.log("Ctrl+S 被按下了");
  }
});
```

### 表单事件

| 事件 | 触发时机 | 说明 |
|------|---------|------|
| `input` | 输入框值发生变化 | 实时触发，适合搜索框、字数统计 |
| `change` | 值改变且失焦 | 适合下拉框、复选框 |
| `submit` | 表单提交 | 用于验证和 AJAX 提交（B.12） |
| `focus` | 元素获得焦点 | 不冒泡 |
| `blur` | 元素失去焦点 | 不冒泡 |

`input` vs `change` 的区别很重要：

```javascript
var input = document.querySelector("input");

// input：每输入一个字符都触发（实时）
input.addEventListener("input", function() {
  console.log("input 事件：", input.value);
});

// change：输入完毕、焦点离开后才触发
input.addEventListener("change", function() {
  console.log("change 事件：", input.value);
});
```

### 文档生命周期事件

| 事件 | 触发时机 | 说明 |
|------|---------|------|
| `DOMContentLoaded` | HTML 解析完毕，DOM 树构建完成 | 不需要等图片/CSS/JS（用 defer 的脚本不需要等这个事件） |
| `load` | 页面上一切资源加载完毕 | 包括图片、CSS、iframe 等 |
| `beforeunload` | 用户即将离开页面 | 可以提示"有未保存的更改" |

```javascript
// DOMContentLoaded：DOM 好了，不等图片
document.addEventListener("DOMContentLoaded", function() {
  console.log("DOM 已就绪！可以操作元素了");
});

// load：一切都好了
window.addEventListener("load", function() {
  console.log("所有资源（包括图片）都加载完了");
});
```

**注意**：如果你用了 `<script defer>`（B.1 讲的），脚本本身就是在 DOM 解析完后执行的，不需要再监听 `DOMContentLoaded`。如果你把脚本放在 body 底部也一样。只有在 script 写在 head 里且不加 defer 时，才需要用 `DOMContentLoaded` 确保 DOM 就绪。

### 关联 JS-A 知识

事件处理函数和你在 A 篇学过的回调函数是同一个概念。`event` 对象本身就是一个普通的 JS 对象——有属性（`.type`、`.key`、`.target` 等），可以像你操作任何对象一样操作它。

## 动手试试

1. 打开示例文件 `B.10-event-types.html`，依次测试各种事件类型
2. 在"鼠标事件"区域移动鼠标，观察 mouseenter/leave 和 mouseover/out 的区别
3. 在键盘区域按各种键，观察 event.key 的值——试着按方向键、Esc、Enter
4. 在表单区域分别用 input 和 change 事件测试，理解两者的触发时机差异

## 本节小结

事件类型分四大类：鼠标（click/dblclick/mouseenter+mouseleave 推荐）、键盘（keydown+event.key 判断键值）、表单（input 实时 vs change 失焦后、submit）、文档（DOMContentLoaded vs load）。日常开发中掌握这十来个事件类型就足够了。

## 下一节预告

B.11《操作 class 与 style》——现在你既能选元素也能响应事件了，但怎么动态改变元素的外观？CSS 中定义的 class 怎么在 JS 中切换？内联样式怎么设？classList API 登场。
