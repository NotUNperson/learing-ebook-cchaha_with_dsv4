/**
 * 02-optional-default-rest.ts
 * 主题：可选参数（?）、默认参数（=）与剩余参数（...）
 *
 * 本节演示如何让 TypeScript 函数的参数变得更灵活，
 * 并与 C++ 的默认参数和可变参数进行对比。
 */

// ==================== 可选参数（?） ====================

/**
 * 点咖啡函数
 * - type 是必选参数，表示咖啡种类
 * - sugar 是可选参数（用 ? 标记），表示是否加糖
 *
 * 如果 sugar 没传，它的值是 undefined
 * 对比 C++：C++ 没有"可选参数"语法，只能靠默认参数模拟
 */
function orderCoffee(type: string, sugar?: boolean): string {
    // 使用可选参数前，通常需要判断它是否存在
    if (sugar) {
        return `一杯${type}，加糖`;
    }
    return `一杯${type}`;
}

console.log(orderCoffee("拿铁"));           // 输出: 一杯拿铁
console.log(orderCoffee("美式", true));     // 输出: 一杯美式，加糖
console.log(orderCoffee("卡布奇诺", false)); // 输出: 一杯卡布奇诺


/**
 * 重要规则：可选参数必须放在必选参数的后面
 * 下面的代码会报错（你可以取消注释验证）：
 *
 * function bad(optional?: string, required: number) { }
 * // 错误：必选参数不能跟在可选参数后面
 */


// ==================== 默认参数（=） ====================

/**
 * 点奶茶函数
 * - type 是必选参数
 * - sugar 有默认值 "半糖"
 *
 * 和 C++ 的 void f(int a = 10) 几乎一样，
 * 只是 TypeScript 把类型标注放在了参数名后面
 */
function orderMilkTea(type: string, sugar: string = "半糖"): string {
    return `一杯${type}，${sugar}`;
}

console.log(orderMilkTea("珍珠奶茶"));             // 输出: 一杯珍珠奶茶，半糖
console.log(orderMilkTea("椰果奶茶", "无糖"));      // 输出: 一杯椰果奶茶，无糖


/**
 * 默认参数和可选参数的区别：
 * - 可选参数（?）：省略时值为 undefined，函数体内通常需要判断
 * - 默认参数（=）：省略时使用默认值，函数体内不需要特殊处理
 *
 * 通常来说，有合理默认值时优先用默认参数，代码更简洁
 */


// ==================== 剩余参数（...） ====================

/**
 * 求和函数——可以接受任意数量的数字
 * - ...numbers: number[] 把所有传入的数字收集成一个数组
 *
 * 对比 C++ 的变长参数：
 * - C 风格 va_list: 类型不安全，需要手动管理
 * - std::initializer_list: 比较接近，但语法更繁琐
 * - 变参模板: 功能强大但编译慢，语法复杂
 *
 * TypeScript 用 ... 一条语法解决，安全又简单
 */
function sum(...numbers: number[]): number {
    let total = 0;
    for (const n of numbers) {
        total += n;
    }
    return total;
}

console.log("sum() =", sum());                    // 输出: 0（空数组）
console.log("sum(1, 2) =", sum(1, 2));            // 输出: 3
console.log("sum(1, 2, 3, 4, 5) =", sum(1, 2, 3, 4, 5)); // 输出: 15


/**
 * 剩余参数也可以接收字符串
 * 这里演示接收任意数量的字符串标签
 */
function joinTags(...tags: string[]): string {
    // 用 join 方法把数组拼接成字符串，用 "、" 分隔
    return tags.join("、");
}

console.log(joinTags());                        // 输出: ""（空字符串）
console.log(joinTags("热门", "推荐"));           // 输出: 热门、推荐
console.log(joinTags("新书", "畅销", "限时"));   // 输出: 新书、畅销、限时


// ==================== 三种方式混用 ====================

/**
 * 生成报告的函数
 * - title: 必选参数（报告标题）
 * - author: 默认参数（作者，默认为 "匿名"）
 * - ...scores: 剩余参数（所有成绩）
 *
 * 注意参数顺序：必选 → 默认 → 剩余，这个顺序是固定的
 */
function createReport(
    title: string,
    author: string = "匿名",
    ...scores: number[]
): string {
    // 计算平均分（如果没有成绩则为 0）
    const avg = scores.length > 0
        ? scores.reduce((total, s) => total + s, 0) / scores.length
        : 0;
    return `${title}（作者：${author}）平均分：${avg.toFixed(1)}`;
}

// 测试不同组合
console.log(createReport("期中考试"));
// 输出: 期中考试（作者：匿名）平均分：0.0

console.log(createReport("期中考试", "王老师", 85, 92, 78));
// 输出: 期中考试（作者：王老师）平均分：85.0


// ==================== 动手试试答案参考 ====================

/**
 * 外卖订单格式化函数
 * - item: 必选，商品名
 * - quantity: 默认 1，数量
 * - notes: 可选，备注
 * - toppings: 剩余参数，加料
 */
function formatOrder(
    item: string,
    quantity: number = 1,
    notes?: string,
    ...toppings: string[]
): string {
    // 构建加料部分
    const toppingText = toppings.length > 0
        ? `（${toppings.join("、")}）`
        : "";

    // 构建备注部分
    const noteText = notes !== undefined
        ? ` 备注：${notes}`
        : "";

    return `${item} x${quantity}${toppingText}${noteText}`;
}

// 只传必选参数
console.log(formatOrder("牛肉面"));
// 输出: 牛肉面 x1

// 传 item + quantity
console.log(formatOrder("牛肉面", 2));
// 输出: 牛肉面 x2

// 传 item + quantity + notes + toppings
console.log(formatOrder("牛肉面", 2, "少汤", "加蛋", "加辣"));
// 输出: 牛肉面 x2（加蛋、加辣） 备注：少汤
