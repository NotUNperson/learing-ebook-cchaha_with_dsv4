# 毕业练习：自主扩展模板

这个目录是给你用来做毕业练习的。

## 使用方式

1. 选择一个基础项目：
   - 待办事项 Web 应用：拷贝 `../05-todo-persistence/` 到 `./todo-extension/`
   - 笔记管理器 CLI：拷贝 `../03-markdown-notes-advanced/` 到 `./notes-extension/`

2. 选择一个扩展方向（详见 06-final-project.md）

3. 按"四层图"（类型-数据-业务-渲染）逐层实现

4. 编译测试，直到功能正常

## 示例：基于待办应用的"截止日期"扩展

改动的文件及大致位置：

- `src/main.ts`：
  - Todo 接口加 `dueDate: string | null` 字段
  - index.html 中加 `<input type="date">` 的 DOM 引用
  - addTodo() 中读取日期值
  - render() 中显示日期并标注过期
  - 加 sortByDueDate() 函数
  - state 中加 sortBy 字段

- `index.html`：
  - 加日期选择器
  - 加排序按钮

- `style.css`：
  - 加 `.overdue`（红色）和 `.on-time`（绿色）样式

---

Happy coding! 你已经有能力独立完成这个练习了。
