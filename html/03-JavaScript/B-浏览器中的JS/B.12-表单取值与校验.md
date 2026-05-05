# B.12 表单取值与校验

## 本节你会学到什么

- 表单各类控件的取值方式：文本框、复选框、单选框、下拉框
- Constraint Validation API：内置校验能力
- `checkValidity()`、`reportValidity()`、`validity` 对象
- `setCustomValidity()` 自定义错误信息
- 阻止默认表单提交，用 JS 自己处理数据

## 正文

### 表单——用户和你"对话"的渠道

网页的核心是"交互"。而表单（`<form>`）是交互中最重要的一环——用户通过表单输入数据，JS 读取数据、校验数据、发送数据。就像你去银行办业务，柜员递给你一张表格让你填——表单就是那张纸，JS 就是柜员，负责收表格、检查填没填对、然后帮你处理。

### 取到表单控件的值

不同类型的表单控件，取值方式略有不同：

#### 文本框类（input[type="text"/"email"/"password"]、textarea）

```javascript
var input = document.querySelector("input");
console.log(input.value);  // "用户输入的内容"
```

#### 复选框（checkbox）

```javascript
var checkbox = document.querySelector("input[type='checkbox']");
console.log(checkbox.checked);  // true 或 false
// 注意：不是 checkbox.value！value 属性是提交时的值
```

#### 单选框（radio）

```javascript
// 同一组 radio（name 相同），找到被选中的那个
var checked = document.querySelector("input[name='gender']:checked");
console.log(checked ? checked.value : "没选");
```

#### 下拉框（select）

```javascript
var select = document.querySelector("select");
console.log(select.value);  // 当前选中的 option 的 value
```

### 快速取整个表单的所有值 —— FormData

```javascript
var form = document.querySelector("form");
var formData = new FormData(form);

// 读取单个字段
console.log(formData.get("username"));
console.log(formData.get("email"));

// 遍历所有字段
for (var pair of formData.entries()) {
  console.log(pair[0] + " = " + pair[1]);
}
```

`FormData` 是一个类似字典的对象，key 是表单控件的 `name` 属性，value 是用户填的值。它不仅可以用来读取数据，还是 AJAX 上传的载体（B.16 详讲）。

### Constraint Validation API —— 浏览器内置的校验能力

HTML5 为表单提供了内置的校验功能。你不需要写额外 JS，浏览器就能帮你做基础校验——前提是你用了正确的 HTML 属性：

```html
<input type="email" required minlength="3" maxlength="50">
<input type="number" min="1" max="100" required>
<input type="text" pattern="[A-Za-z]+" required>
```

这些 HTML 属性（required、minlength、pattern、type="email" 等）被称为**约束验证属性**。浏览器在表单项旁会显示默认的提示气泡。

在 JS 中，你可以通过以下 API 来控制校验：

#### checkValidity() —— 静默校验

```javascript
var input = document.querySelector("input");
if (!input.checkValidity()) {
  console.log("校验不通过！");
  // 但不会显示错误提示
}
```

#### reportValidity() —— 校验并显示提示

```javascript
if (!input.reportValidity()) {
  // 校验不通过，浏览器自动显示错误气泡
  return;
}
```

#### validity 对象 —— 细粒度错误状态

```javascript
var input = document.querySelector("input");
var v = input.validity;

console.log(v.valid);          // 整体是否通过
console.log(v.valueMissing);   // 必填但没填
console.log(v.typeMismatch);   // 类型不匹配（比如 email 输入的不是 email 格式）
console.log(v.tooShort);       // 长度不足
console.log(v.tooLong);        // 长度超出
console.log(v.rangeUnderflow); // 数值小于 min
console.log(v.rangeOverflow);  // 数值大于 max
console.log(v.patternMismatch);// 不匹配正则 pattern
```

#### setCustomValidity() —— 自定义错误信息

```javascript
var input = document.querySelector("input");
input.setCustomValidity("用户名必须以字母开头，长度 3-20 个字符");
// 之后 checkValidity() 会返回 false，reportValidity() 会显示这条信息
```

清空自定义错误：
```javascript
input.setCustomValidity("");  // 设为空字符串即清除
```

### 阻止默认提交，用 JS 自己处理

现代 Web 应用绝大多数都用 JS 拦截表单提交，自己处理数据：

```javascript
var form = document.querySelector("form");

form.addEventListener("submit", function(event) {
  event.preventDefault();  // 阻止浏览器默认提交

  // 校验
  if (!form.reportValidity()) {
    return;  // 校验不通过，不处理
  }

  // 取数据
  var formData = new FormData(form);

  // 用 JS 处理数据（比如发 fetch 请求——B.15 会讲）
  console.log("用户名：", formData.get("username"));
  console.log("邮箱：", formData.get("email"));

  // 清空表单
  form.reset();
  alert("表单处理完成！");
});
```

这样做的好处：
- 页面不会刷新（传统表单提交会导致页面跳转/刷新）
- 可以在提交前做额外的自定义校验
- 可以用 AJAX 异步发送数据（用户体验更好）

### 关联 HTML 知识

你学过的 HTML 表单知识（input 的 type 属性、required、placeholder、label 的 for 属性等）现在和 JS 结合起来——HTML 负责结构，JS 负责行为（取值、校验、提交）。

## 动手试试

1. 打开示例文件 `B.12-forms.html`，填写表单并点击提交，观察校验结果
2. 故意留空一些必填项、输入无效的 email，看看 `reportValidity()` 的效果
3. 打开控制台，在提交成功后查看 `FormData` 的输出
4. 试着用 `validity` 对象检查某个输入框的详细错误状态

## 本节小结

表单取值：文本框用 `.value`，复选框用 `.checked`，单选框用 `:checked`，下拉框用 `select.value`。`FormData` 可一次性取出整个表单的数据。Constraint Validation API 提供内置校验：`checkValidity()` 静默检查，`reportValidity()` 显示提示，`validity` 对象给出细粒度错误状态。`setCustomValidity()` 自定义错误信息。推荐用 `e.preventDefault()` 拦截提交，用 JS 自己处理数据。

## 下一节预告

B.13《BOM（上）》——前面一直在操作 DOM（页面内容），但浏览器本身也提供了很多 API：弹窗、定时器、动画帧——这些不属于 DOM，属于 BOM（浏览器对象模型）。
