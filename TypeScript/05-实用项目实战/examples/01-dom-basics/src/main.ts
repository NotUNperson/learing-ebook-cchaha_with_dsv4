/**
 * main.ts - TypeScript DOM 操作入门示例
 *
 * 这个文件演示了如何在 TypeScript 中：
 * 1. 获取 DOM 元素并使用类型断言
 * 2. 绑定鼠标事件（click）和键盘事件（keydown）
 * 3. 操作元素属性和内容
 */

// ============================================================
// 第一步：获取 DOM 元素（使用类型断言精确指定类型）
// ============================================================

// getElementById 返回 HTMLElement | null
// 我们用 "as" 把它断言为更具体的类型：标题、按钮、输入框
const titleEl = document.getElementById("title") as HTMLHeadingElement;
const btnEl = document.getElementById("change-btn") as HTMLButtonElement;
const resetBtnEl = document.getElementById("reset-btn") as HTMLButtonElement;
const inputEl = document.getElementById("my-input") as HTMLInputElement;

// 计数器相关元素
const countBtnEl = document.getElementById("count-btn") as HTMLButtonElement;
const countDisplayEl = document.getElementById("count-display") as HTMLSpanElement;
const countResetBtnEl = document.getElementById("count-reset-btn") as HTMLButtonElement;

// ============================================================
// 第二步：防御性检查 —— 确保所有元素都存在
// ============================================================
// 这是好习惯：万一 HTML 被改动了，程序不会莫名其妙崩溃
if (!titleEl || !btnEl || !resetBtnEl || !inputEl || !countBtnEl || !countDisplayEl || !countResetBtnEl) {
    throw new Error("部分 DOM 元素未找到，请检查 index.html 中的 id 属性");
}

// ============================================================
// 第三步：保存原始标题（用于"重置"功能）
// ============================================================
const originalTitle = titleEl.textContent || "你好，世界";

// ============================================================
// 第四步：绑定"改变文字"按钮的点击事件
// ============================================================
btnEl.addEventListener("click", (e: MouseEvent) => {
    // e 的类型自动推断为 MouseEvent
    // 它有 clientX（鼠标在视口中的 X 坐标）和 clientY（Y 坐标）
    const clickedBtn = e.target as HTMLButtonElement;

    // 修改标题文字
    titleEl.textContent = "你点击了按钮！文字已经改变。";

    // 让按钮变灰，提示用户已经点过了
    clickedBtn.disabled = true;
    clickedBtn.textContent = "已点击";

    // 输出点击坐标到控制台
    console.log(`按钮在坐标 (${e.clientX}, ${e.clientY}) 被点击`);
});

// ============================================================
// 第五步：绑定"重置标题"按钮
// ============================================================
resetBtnEl.addEventListener("click", () => {
    // 恢复原始标题
    titleEl.textContent = originalTitle;

    // 恢复"改变文字"按钮的状态
    btnEl.disabled = false;
    btnEl.textContent = "点击我换文字";

    console.log("标题已重置");
});

// ============================================================
// 第六步：绑定输入框的键盘事件
// ============================================================
inputEl.addEventListener("keydown", (e: KeyboardEvent) => {
    // e.key 是用户按下的键的字符串表示
    // 常见值："Enter"、"Escape"、"ArrowUp"、"a"、"Backspace" 等
    if (e.key === "Enter") {
        const newText = inputEl.value.trim();

        // 如果输入了有效文字，就更新标题
        if (newText) {
            titleEl.textContent = newText;
            console.log(`标题已更新为：${newText}`);
        }

        // 清空输入框并让输入框失去焦点
        inputEl.value = "";
        inputEl.blur();
    }
});

// ============================================================
// 第七步：计数器功能
// ============================================================
let count = 0; // 计数变量放在回调函数外部，才能"记住"上次的值

countBtnEl.addEventListener("click", () => {
    count++; // 每次点击 +1
    countDisplayEl.textContent = String(count); // 更新显示（textContent 需要字符串）
    console.log(`计数：${count}`);
});

// 重置计数器按钮
countResetBtnEl.addEventListener("click", () => {
    count = 0;
    countDisplayEl.textContent = "0";
    console.log("计数器已重置");
});

// ============================================================
// 初始化日志
// ============================================================
console.log("TypeScript DOM 示例已就绪！");
console.log(`当前标题：${titleEl.textContent}`);
