# B.6 创建与插入节点

## 本节你会学到什么

- `document.createElement` —— 凭空造一个元素
- `append` 和 `prepend` —— 现代方法，推荐使用
- `insertAdjacentHTML` —— 四个位置，高效插 HTML
- `appendChild` —— 老方法，现在被 `append` 取代

## 正文

### 你不是修改页面，你是"盖房子"

前几节我们学会了找到元素、改内容、改属性。但这些都是"动已有的东西"。如果页面上根本没有这个元素呢？你得**从零创建**它。

类比：你不是在改一座老房子的墙面——你是在盖一间新屋子。你需要先造出墙、屋顶、门窗（创建元素），然后把它们安装到合适的位置（插入 DOM）。

### 第一步：createElement —— 在"工厂"里做零件

```javascript
// 创建一个新元素（但还没放到页面上）
var newP = document.createElement("p");
```

`document.createElement("标签名")` 会在内存中创建一个**新元素节点**。注意：这时候页面上还看不到它——它只在内存里，像个刚从工厂生产出来的零件，还没安装。

创建之后，你可以立即设置它的属性和内容：

```javascript
var newP = document.createElement("p");
newP.textContent = "你好，我是新创建的段落！";
newP.className = "intro";
newP.id = "first-intro";
// 此时元素在内存中，页面上看不到
```

### 第二步：append —— 安装到页面上

```javascript
// 把新元素追加到 body 的末尾
document.body.append(newP);
// 现在页面上出现了！
```

`append` 是**现代方法**（推荐），它把元素插入到父元素的**末尾**。比老方法 `appendChild` 更好用：

```javascript
// append 可以做 appendChild 做不到的事：
parent.append(child1, child2, child3);  // 一次插入多个！
parent.append("直接放一段文字");          // 可以直接插文本！
parent.append(child, "和文字混着来");    // 混插！
```

### 插入位置不止"末尾"——prepend、before、after

除了 `append`（插末尾）和 `prepend`（插开头），还有两个更灵活的：

```javascript
// prepend：插入到父元素的最开头
parent.prepend(newP);  // 成为第一个子元素

// before：插入到元素自己的前面（作为兄弟）
existingEl.before(newP);

// after：插入到元素自己的后面（作为兄弟）
existingEl.after(newP);
```

用"家族树"类比来记：
- `parent.append(child)` —— 把新孩子放在最后
- `parent.prepend(child)` —— 把新孩子放在最前
- `el.before(sibling)` —— 插在自己前面（新弟弟）
- `el.after(sibling)` —— 插在自己后面（新哥哥）

### insertAdjacentHTML —— 效率之王（插 HTML 字符串）

如果你要插入一段 HTML 字符串（而不仅仅是纯文本），`insertAdjacentHTML` 是最高效的方式：

```javascript
var el = document.querySelector("div");

// 四个位置参数：
el.insertAdjacentHTML("beforebegin", "<p>在 el 之前</p>");   // el 的前面（兄弟）
el.insertAdjacentHTML("afterbegin",  "<p>在 el 内部开头</p>"); // el 的第一个子元素
el.insertAdjacentHTML("beforeend",   "<p>在 el 内部末尾</p>"); // el 的最后一个子元素
el.insertAdjacentHTML("afterend",    "<p>在 el 之后</p>");     // el 的后面（兄弟）
```

四个位置名很好记：
- `beforebegin` = 在开始标签之前
- `afterbegin` = 在开始标签之后
- `beforeend` = 在结束标签之前
- `afterend` = 在结束标签之后

```
<!-- beforebegin -->
<div id="target">
  <!-- afterbegin -->
  原有内容
  <!-- beforeend -->
</div>
<!-- afterend -->
```

### append vs appendChild —— 为什么推荐前者

| 特性 | append | appendChild |
|------|--------|-------------|
| 一次插入多个 | 支持 | 不支持 |
| 插入纯文本 | 支持 | 不支持 |
| 返回值 | 无 | 返回插入的节点 |
| 浏览器兼容 | 现代浏览器都支持 | 所有浏览器都支持 |

除非你要兼容 IE11，否则一律用 `append`。

### 一个完整的创建-插入流程

```javascript
// 1. 创建
var li = document.createElement("li");
li.textContent = "买牛奶";
li.className = "todo-item";

// 2. 插入
document.querySelector("ul").append(li);

// 完成！页面上多了一个列表项
```

### 关联 CSS 知识

你创建的元素也可以立即添加 class（`li.className = "..."` 或 `li.classList.add("...")`），这样 CSS 里的样式规则就能立刻对它生效。(B.11 详讲 classList)

## 动手试试

1. 打开示例文件 `B.6-create.html`，点击按钮观察页面如何动态生成新元素
2. 打开控制台，手动创建元素：`var div = document.createElement("div"); div.textContent = "我是手动创建的!"; document.body.append(div);`
3. 试试 `insertAdjacentHTML`：在控制台选中页面上的某个元素，用它的 `insertAdjacentHTML` 方法在四个不同位置插入文字，观察区别
4. 尝试用 `prepend` 在列表最前面插入一项

## 本节小结

创建元素的入口是 `document.createElement("标签名")`。插入方式有：`append`（末尾追加，推荐）、`prepend`（开头插入）、`before`/`after`（兄弟位置插入）、`insertAdjacentHTML`（四个位置，最高效插 HTML 字符串）。推荐用 `append` 替代老方法 `appendChild`。

## 下一节预告

B.7《删除与替换节点》——能创建就能删除。辛辛苦苦加进去的元素怎么拿掉？remove、removeChild、replaceChild 登场。
