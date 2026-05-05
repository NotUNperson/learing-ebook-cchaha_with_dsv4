# B.5 修改属性

## 本节你会学到什么

- 标准属性的点号直接操作（`img.src`, `a.href`, `input.value` 等）
- `getAttribute` / `setAttribute` 通用方法
- `data-*` 自定义属性与 `dataset` API
- `class` 的简要引入（详讲见 B.11）

## 正文

### 改变一件物品的"属性标签"

想象你手里有一张商品标签，上面写着：
- 名称：苹果
- 价格：5 元
- 产地：山东

如果你想改变产地，你直接擦掉"山东"改成"陕西"就行。HTML 元素的属性（Attribute）也一样——一个 `<img>` 有 `src`（图片地址），一个 `<a>` 有 `href`（链接目标），一个 `<input>` 有 `value`（填写内容）。JS 可以随时读和改这些属性。

### 方式一：点号直接访问（最方便）

对于 HTML 的标准属性（浏览器内置的），你可以直接用 `.` 语法读写：

```javascript
// 图片
var img = document.querySelector("img");
img.src = "new-photo.jpg";       // 换一张图
img.alt = "一张新照片";           // 改替代文本
console.log(img.width);           // 读宽度

// 链接
var link = document.querySelector("a");
link.href = "https://example.com"; // 改链接目标
link.target = "_blank";            // 新窗口打开

// 输入框
var input = document.querySelector("input");
input.value = "新内容";            // 改输入框的值
input.disabled = true;             // 禁用它
```

就像直接撕下旧标签贴上新的——直接、快速、自然。

### 方式二：getAttribute / setAttribute（通用，任何属性都能操作）

点号访问只对**标准属性**有效。如果你有自定义属性（或者属性名和 JS 保留字冲突），用 `getAttribute` / `setAttribute`：

```javascript
var el = document.querySelector("div");

// 读取
var id = el.getAttribute("id");         // 等价于 el.id
var cls = el.getAttribute("class");     // 等价于 el.className（注意不是 el.class）

// 写入
el.setAttribute("title", "我是提示文字");
el.setAttribute("data-role", "admin");  // 自定义属性（下面详讲）

// 删除
el.removeAttribute("title");
```

**注意**：`class` 属性在 JS 中通过 `className` 或 `classList` 操作（B.11 详讲），因为 `class` 是 JS 的保留字，不能直接用 `.class`。

### 方式三：data-* 自定义属性 + dataset API

HTML5 允许你用 `data-` 前缀定义自己的属性：

```html
<div id="user-card" data-user-id="42" data-role="admin" data-last-login="2026-01-15">
  用户信息
</div>
```

在 JS 中，你可以通过 `dataset` 对象来操作这些 `data-*` 属性：

```javascript
var card = document.querySelector("#user-card");

// 读取（data-user-id 变成 dataset.userId，连字符转驼峰）
console.log(card.dataset.userId);     // "42"
console.log(card.dataset.role);       // "admin"
console.log(card.dataset.lastLogin);  // "2026-01-15"

// 写入
card.dataset.status = "active";
// 上面对应的 HTML 属性变为：data-status="active"

// 删除
delete card.dataset.lastLogin;
```

命名规则：`data-user-id` 变成 `dataset.userId`，`data-last-login` 变成 `dataset.lastLogin`。连字符后面的字母转成大写（camelCase 驼峰命名）。

### 常用属性速查

| 属性 | 读取 | 设置 | 说明 |
|------|------|------|------|
| `id` | `el.id` | `el.id = "x"` | 唯一标识 |
| `class` | `el.className` | 用 classList（B.11） | 类名 |
| `src` | `img.src` | `img.src = "..."` | 图片地址 |
| `href` | `a.href` | `a.href = "..."` | 链接地址 |
| `value` | `input.value` | `input.value = "..."` | 输入框内容 |
| `checked` | `checkbox.checked` | `checkbox.checked = true` | 复选框 |
| `disabled` | `el.disabled` | `el.disabled = true` | 禁用 |
| `hidden` | `el.hidden` | `el.hidden = true` | 隐藏元素 |

### 点号 vs getAttribute 的一个陷阱

有一个细节值得注意——两者在读取某些属性时返回值可能不同：

```javascript
var link = document.querySelector("a");

// 点号访问：返回解析后的绝对 URL
console.log(link.href);  // "https://example.com/page"

// getAttribute：返回 HTML 里写的原始字符串
console.log(link.getAttribute("href")); // "/page"（原始值）
```

通常情况下用点号就够了。需要原始值的时候用 `getAttribute`。

## 动手试试

1. 打开示例文件 `B.5-attributes.html`，点击按钮观察图片如何被替换
2. 在控制台输入 `document.querySelector("img").src` 查看图片地址
3. 试试修改 `data-*` 属性：在控制台输入 `document.querySelector("#card").dataset.role = "vip"`，然后查看元素面板的变化
4. 尝试用 `getAttribute` 和点号分别读取同一个 checkbox 的 `checked` 属性，看看有什么区别

## 本节小结

操作属性有三种方式：点号直接访问（`el.src`，最方便，适用于标准属性）、`getAttribute/setAttribute`（通用方法，任何属性都行）、`dataset` 对象（专用于 `data-*` 自定义属性，自动驼峰转换）。`class` 属性的操作通过 `classList`（B.11 详讲）。

## 下一节预告

B.6《创建与插入节点》——现在你会改现有的元素了，但如果页面上还没有的元素怎么变出来？我们来学 createElement 和 append。
