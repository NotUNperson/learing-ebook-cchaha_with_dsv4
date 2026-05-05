// ============================================================
// math.js —— 数学工具模块
// 演示：命名导出（named export）
// 一个模块可以导出多个命名项
// ============================================================

// 导出常量
export const PI = 3.14159;
export const E = 2.71828;

// 导出函数
export function add(a, b) {
    return a + b;
}

export function subtract(a, b) {
    return a - b;
}

export function multiply(a, b) {
    return a * b;
}

export function divide(a, b) {
    if (b === 0) {
        throw new Error("除数不能为零");
    }
    return a / b;
}

// 可以导出 class
export class Vector2D {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }

    magnitude() {
        return Math.sqrt(this.x ** 2 + this.y ** 2);
    }
}
