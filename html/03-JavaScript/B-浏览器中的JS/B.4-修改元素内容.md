# B.4 修改元素内容

## 本节你会学到什么

- `textContent`：纯文本，安全高效，日常首选
- `innerHTML`：解析 HTML 标签，但需警惕 XSS 注入
- `innerText`：视觉可见文本，比 textContent 慢
- 三者的区别对比与推荐使用场景

## 正文

### 修改"牌子上的字"

上一节你学会了怎么"找到"一个元素。找到以后自然要"动"它——最基础的操作就是改它里面的内容。

想象你面前立着一块公告牌。你想改公告牌上的字，有三种方式：

1. 用白板擦擦干净，用黑笔写上新内容（纯文本，安全）
2. 把整个版面拆了，换一块新牌子，上面可以画表格、加粗字、贴图片（支持 HTML）
3. 只换掉"用户眼睛能看到的"那部分文字（视觉文本）

### textContent —— 纯文本，最安全

```javascript
var el = document.querySelector("h1");
el.textContent = "新标题";
```

`textContent` 只处理**纯文本**。即使你给它一段 HTML 字符串，它也会把尖括号当普通字符显示：

```javascript
el.textContent = "<strong>重要通知</strong>";
// 页面上显示：<strong>重要通知</strong>（尖括号原样输出，不解析）
```

这就像白板——你在上面写什么就是什么，不会被"解读"出额外含义。

**推荐指数：最高。** 当你只是想改文字内容时，用 `textContent`。

### innerHTML —— 能解析 HTML，但危险

```javascript
var el = document.querySelector("div");
el.innerHTML = "<strong>重要通知</strong><p>请查收邮件</p>";
// 页面上显示：粗体的"重要通知"和一段"请查收邮件"（HTML 被解析了）
```

`innerHTML` 会把字符串当 HTML 来解析。这就像你把整块公告牌换成了一块新板子。

**但有一个严重的安全问题：XSS（跨站脚本注入）。**

```javascript
// 危险！用户输入"<img src=x onerror='alert(1)'>"会被执行
var userInput = "用户输入的内容";
el.innerHTML = userInput;  // 如果 userInput 里有 script 或事件属性，会执行！
```

任何时候，只要 `innerHTML` 的内容来自**用户输入**（评论区、搜索框、URL 参数等），就可能被恶意脚本注入。除非你100%确定内容是安全的，否则用 `textContent`。

### innerText —— 视觉文本，会触发回流

```javascript
el.innerText = "Hello World";
```

`innerText` 的行为和 CSS 相关：它只取**渲染后用户看得见的**文本。一个被 `display: none` 隐藏的元素，它的 `innerText` 是空字符串，而 `textContent` 仍然能取出里面的文字。

而且 `innerText` 会触发浏览器**回流**（重新计算布局），`textContent` 不会。所以 `innerText` 比 `textContent` 慢。

### 三者对比表

| 属性 | 解析 HTML | 取隐藏文本 | 写性能 | 使用场景 |
|------|-----------|-----------|--------|---------|
| `textContent` | 不解析 | 能取到 | 快 | **日常首选，改文字** |
| `innerHTML` | 解析 | 能取到 | 快 | 需要插入 HTML 结构时 |
| `innerText` | 不解析 | 取不到 | 慢（触发回流） | 极少使用 |

### 取值也是同理

这三个属性不仅可以写，也可以读：

```javascript
var div = document.querySelector("div");
console.log(div.textContent);  // 所有文本，包括隐藏元素的
console.log(div.innerHTML);    // HTML 源代码字符串
console.log(div.innerText);    // 只取渲染可见的文本
```

### 关联 JS-A 知识

你在 A 篇中学过的字符串操作（`+` 拼接、模板字符串）可以用来构建动态内容：

```javascript
var name = "小明";
var score = 95;
el.textContent = name + "的分数是：" + score + "分";
// 或用模板字符串：`${name}的分数是：${score}分`
```

## 动手试试

1. 打开示例文件 `B.4-content.html`，依次点击三个按钮，观察同一段文字如何被不同方式修改
2. 打开控制台，用 `document.querySelector("#result").textContent` 读取当前内容
3. 尝试在"不安全"输入框中输入 `<img src=x onerror='alert("XSS!")'>`，然后用 innerHTML 方式插入——理解为什么不要用 innerHTML 直接放用户输入
4. 对比：隐藏区域的文字，用 `textContent` 和 `innerText` 分别读取，看结果有何不同

## 本节小结

修改元素内容有三种方式：`textContent`（纯文本，安全，首选）、`innerHTML`（解析 HTML，但小心 XSS）、`innerText`（视觉文本，触发回流，慢）。日常规则：改文字用 `textContent`，插 HTML 用 `innerHTML`（但要确认内容是可信的）。用户输入永远不要直接放进 `innerHTML`。

## 下一节预告

B.5《修改属性》——内容能改了，那元素的属性（href、src、class、data-* 等）怎么改？点号访问法 vs getAttribute/setAttribute。
