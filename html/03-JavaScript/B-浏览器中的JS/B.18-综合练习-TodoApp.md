# B.18 综合练习：Todo App（B 篇收官）

## 本节你会学到什么

- 综合运用 B 篇所有知识，构建完整可用的 Todo App
- DOM 操作：创建、修改、删除元素（B.6/B.7）
- 事件委托：在 ul 上统一监听所有按钮事件（B.9）
- classList：切换任务完成状态（B.11）
- localStorage：持久化存储（B.17）
- 完整的"前端小应用"开发思路

## 正文

### 从零到一，造一个真正的"小应用"

B 篇从 script 标签开始，一步步教你操作 DOM、响应事件、发送请求、存储数据。现在是时候把这些知识**拧成一股绳**，做出一个完整的、可以真正使用的 Todo App（待办事项应用）。

这个 Todo App 麻雀虽小五脏俱全。它包含了：
- 添加任务（DOM 创建+插入）
- 标记完成/取消完成（classList toggle）
- 删除任务（DOM 删除）
- 统计剩余未完成数量
- 持久化存储（localStorage，刷新不丢数据）
- 事件委托（只在 ul 上注册一个监听器）

### 功能需求拆解

在做任何项目之前，先把需求拆成小块：

1. **添加任务**：用户在输入框输入文字，点"添加"按钮或按回车，任务出现在列表中
2. **切换完成状态**：点击任务项，文字添加删除线（完成）或去除删除线（取消完成）
3. **删除任务**：点击任务旁的删除按钮，任务从列表中移除
4. **统计**：实时显示"共 N 项，X 项未完成"
5. **持久化**：刷新页面后数据不丢失，用 localStorage

### 技术方案选择

| 问题 | 解决方案 | 对应章节 |
|------|---------|---------|
| 如何选中元素？ | `querySelector` / `getElementById` | B.3 |
| 如何创建任务项？ | `createElement` + `append` | B.6 |
| 如何删除任务？ | `element.remove()` | B.7 |
| 如何绑定点击事件？ | 事件委托（只在 ul 上绑定） | B.9 |
| 如何切换完成状态？ | `classList.toggle("done")` | B.11 |
| 如何保存数据？ | `localStorage.setItem` + `JSON.stringify` | B.17 |
| 如何读取数据？ | `localStorage.getItem` + `JSON.parse` | B.17 |
| 如何让 CSS 过渡生效？ | CSS 定义 `.done` 样式 + JS 只切换类名 | B.11 + CSS |
| 如何阻止输入框回车提交？ | form 的 `submit` 事件 + `preventDefault` | B.10/B.12 |

### 关键代码思路

#### 数据结构

用一个数组保存所有任务：

```javascript
var todos = [
  { id: 1, text: "学 HTML", done: false },
  { id: 2, text: "学 CSS", done: true },
  { id: 3, text: "学 JavaScript", done: false }
];
```

存到 localStorage 时用 `JSON.stringify(todos)`，取出来用 `JSON.parse(...)`。

#### 渲染函数

一个核心函数 `renderTodos()`，负责把 `todos` 数组变成页面上的列表项。任何时候数据变了，调用一次 `renderTodos()`，页面就同步更新。

#### 事件委托

在 `<ul>` 上绑一个 `click` 监听器，通过 `event.target.dataset.action` 判断用户点了"完成"还是"删除"按钮，用 `event.target.closest("li")` 找到对应的任务项。

### 关联全套前端三件套

这个 Todo App 虽然不大，但它完整地串联了你学过的所有前端知识：

- **HTML**：提供页面结构（表单、列表、按钮）—— B 篇所有内容的基础
- **CSS**：定义 `.done { text-decoration: line-through; }` 等样式，JS 只负责切换类名
- **JS（A 篇）**：数组操作、对象、函数、条件判断、循环
- **JS（B 篇）**：DOM 选择/创建/修改/删除、事件委托、classList、localStorage

你已经能用这三把武器，从零构建一个可用的 Web 应用了。

## 动手试试

1. 打开 `B.18-todo-app.html`，添加几个任务
2. 点击任务项切换完成状态，观察统计数据的变化
3. 删除一个任务
4. **刷新页面**——惊喜！任务数据还在（localStorage 持久化了）
5. 打开浏览器开发者工具 → Application → Local Storage，查看 `todo-app-data` 键的数据结构
6. 尝试自己扩展功能：比如添加"全部完成"/"清除已完成"按钮

## 本节小结

B 篇收官练习：用 DOM 操作（createElement/remove/classList）、事件委托（在 ul 上统一监听）、localStorage 持久化，构建了一个完整的 Todo App。这个应用体现了"数据驱动视图"的思想——数据（todos 数组）是核心，视图（页面上的列表）是数据的反映。数据变，视图跟着变。

## 课程结语

恭喜！你已经完成了前端三件套（HTML + CSS + JavaScript）的全部学习路径。

从 HTML 的骨架标签，到 CSS 的盒子模型和布局，再到 JS 的语言核心和浏览器 API，你现在已经具备了构建完整 Web 前端应用的基础能力。

接下来你可以朝这些方向继续深入：
- React / Vue 等前端框架（理解它们底层就是对这些 DOM API 的封装）
- Node.js 后端开发（JS 在服务器端的应用）
- TypeScript（给 JS 加上类型系统）
- 前端工程化（Webpack、Vite、模块化开发）

记住：这些框架和工具，底层都是你今天学到的这些 DOM API。理解了原理，学什么都快。
