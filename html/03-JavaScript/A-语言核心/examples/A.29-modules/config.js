// ============================================================
// config.js —— 配置模块（混合导出）
// 演示：命名导出 + 默认导出的混合使用
// ============================================================

// 命名导出
export const APP_NAME = "A29 模块化示例";
export const APP_VERSION = "1.0.0";

export function getEnv() {
    return process.env.NODE_ENV || "development";
}

// 默认导出
const defaultConfig = {
    debug: true,
    maxRetries: 3,
    timeout: 5000,
};

export default defaultConfig;
