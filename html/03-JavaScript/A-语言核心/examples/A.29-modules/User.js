// ============================================================
// User.js —— 用户模型模块
// 演示：默认导出（default export）
// 一个模块只能有一个默认导出
// ============================================================

// 默认导出——导出一个 class
export default class User {
    constructor(name, email) {
        this.name = name;
        this.email = email;
        this.createdAt = new Date();
    }

    getInfo() {
        return `用户: ${this.name} (${this.email})`;
    }
}
