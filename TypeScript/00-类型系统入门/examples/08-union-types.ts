// ==========================================
// 08-union-types.ts
// 演示联合类型 |、类型别名 type、类型收窄
// ==========================================

export {};  // 让这个文件成为一个独立的模块，避免全局作用域冲突

// ==========================================
// 一、联合类型：用 | 表示"或"
// ==========================================

// 一个参数可以是 number 或 string
function printId(id: number | string): void {
    console.log("ID:", id);
}

printId(101);
printId("user-2024");

// 联合类型变量可以赋不同的类型
let value: number | string;
value = 42;
console.log("value 是数字:", value);
value = "hello";
console.log("value 是字符串:", value);
// value = true;  // ❌ 编译错误！true 不是 number | string

// ==========================================
// 二、类型收窄：用 typeof 判断分支
// ==========================================

// 联合类型的变量在使用时需要先"收窄"——确定它到底是哪种类型
function formatValue(value: number | string): string {
    // typeof 收窄：TypeScript 知道在这个 if 块里 value 是 string
    if (typeof value === "string") {
        return value.trim().toUpperCase();
    }
    // 走到这里，TypeScript 知道 value 只能是 number 了
    return value.toFixed(2);
}

console.log(formatValue("  hello  "));  // "HELLO"
console.log(formatValue(3.14159));       // "3.14"

// 更复杂的类型收窄：联合了三种类型
type InputType = number | string | boolean;

function describe(input: InputType): string {
    if (typeof input === "number") {
        return `数字: ${input}（平方是 ${input * input}）`;
    } else if (typeof input === "string") {
        return `文本: "${input}"（长度 ${input.length}）`;
    } else {
        // TypeScript 自动推断这里是 boolean
        return `布尔值: ${input ? "真" : "假"}`;
    }
}

console.log(describe(42));
console.log(describe("TypeScript"));
console.log(describe(true));

// ==========================================
// 三、类型别名：用 type 给类型起名字
// ==========================================

// 类似 C++ 的 using UserId = int;
type UserId = number | string;
type Point = [number, number];      // 二维坐标
type PlayerScore = number;          // 玩家分数（语义化别名）

// 类型别名让函数签名更简洁
function getUser(id: UserId): string {
    return `获取用户 ${id} 的信息`;
}

function getDistance(a: Point, b: Point): number {
    let dx = a[0] - b[0];
    let dy = a[1] - b[1];
    return Math.sqrt(dx * dx + dy * dy);
}

console.log(getUser(1001));
console.log(getUser("user-abc"));
console.log("距离:", getDistance([0, 0], [3, 4]).toFixed(2));

// ==========================================
// 四、字面量联合类型：枚举的轻量替代
// ==========================================

// 定义只能取特定字符串的类型
type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";
type OrderStatus = "pending" | "shipped" | "delivered" | "cancelled";

let method: HttpMethod = "GET";
// method = "PATCH";  // ❌ 编译错误！"PATCH" 不在 HttpMethod 的范围内
console.log("请求方法:", method);

let orderStatus: OrderStatus = "pending";
console.log("订单状态:", orderStatus);
orderStatus = "shipped";
console.log("订单状态变更:", orderStatus);
// orderStatus = "returned";  // ❌ 编译错误！"returned" 不在范围内

// 字面量联合类型 + 类型收窄 = 类型安全的枚举式处理
function handleOrderStatus(s: OrderStatus): string {
    switch (s) {
        case "pending":   return "订单待处理";
        case "shipped":   return "订单已发货";
        case "delivered": return "订单已送达";
        case "cancelled": return "订单已取消";
        default:
            // 这里 TypeScript 知道 s 是 never——所有情况都覆盖了
            const exhaust: never = s;
            return exhaust;
    }
}

console.log(handleOrderStatus("pending"));
console.log(handleOrderStatus("delivered"));

// 字面量联合类型 vs 枚举：
//   联合类型：零运行时开销，编译后就是普通字符串
//   枚举：有运行时对象，可以反向映射
//   简单场景推荐用字面量联合类型

// ==========================================
// 五、实际应用：计算面积（根据形状收窄）
// ==========================================

type Shape = "circle" | "rectangle" | "triangle";

// 函数：根据形状类型和参数计算面积
// 注意：为了安全，用额外参数传递尺寸
function calculateArea(shape: Shape, param1: number, param2?: number): number {
    if (shape === "circle") {
        // 圆的面积 = pi * r^2
        return Math.PI * param1 * param1;
    } else if (shape === "rectangle") {
        // 矩形面积 = width * height
        // param2 一定存在（TypeScript 不知道，但我们主动防护）
        if (param2 === undefined) {
            throw new Error("矩形需要宽度和高度两个参数");
        }
        return param1 * param2;
    } else {
        // triangle: 三角形面积 = (底 * 高) / 2
        if (param2 === undefined) {
            throw new Error("三角形需要底和高两个参数");
        }
        return (param1 * param2) / 2;
    }
}

console.log("\n=== 面积计算 ===");
console.log("圆形面积 (r=3):", calculateArea("circle", 3).toFixed(2));
console.log("矩形面积 (4x5):", calculateArea("rectangle", 4, 5));
console.log("三角形面积 (底6,高8):", calculateArea("triangle", 6, 8));

// ==========================================
// 六、C++ 对比
// ==========================================
// C++ 的 std::variant<int, string> 类似于 TS 的 number | string
// 但 std::variant 需要 std::visit 或 std::get 来取出值
// TypeScript 直接用 typeof 收窄，语法更自然
//
// C++ 没有字面量联合类型的原生支持（可以用 enum class 近似）
// TypeScript 的字面量联合类型是类型系统层面的能力
