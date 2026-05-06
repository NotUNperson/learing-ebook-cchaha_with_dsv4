// ==========================================
// 06-enum.ts
// 演示 TypeScript 的枚举（数字枚举 和 字符串枚举）
// 对比 C++ 的 enum / enum class
// ==========================================

export {};  // 让这个文件成为一个独立的模块，避免全局作用域冲突

// ==========================================
// 一、数字枚举：最基础的枚举
// 类似 C++ 的 enum { Red, Green, Blue }
// ==========================================

// 默认从 0 开始自增
enum Color {
    Red,    // 0
    Green,  // 1
    Blue,   // 2
}

console.log("Color.Red =", Color.Red);      // 0
console.log("Color.Green =", Color.Green);  // 1
console.log("Color.Blue =", Color.Blue);    // 2

// 反向映射：通过数字获取枚举成员的名字
// 这是 C++ 枚举做不到的！
console.log("Color[0] =", Color[0]);  // "Red"
console.log("Color[1] =", Color[1]);  // "Green"
console.log("Color[2] =", Color[2]);  // "Blue"

// ==========================================
// 二、手动设置枚举值
// ==========================================

// 可以指定起始值，后面的自动递增
enum Weekday {
    Monday = 1,   // 从 1 开始
    Tuesday,      // 2
    Wednesday,    // 3
    Thursday,     // 4
    Friday,       // 5
    Saturday,     // 6
    Sunday,       // 7
}

console.log("\n工作日:");
console.log("Monday =", Weekday.Monday);        // 1
console.log("Friday =", Weekday.Friday);        // 5
console.log("Sunday =", Weekday.Sunday);        // 7
console.log("Weekday[3] =", Weekday[3]);        // "Wednesday" —— 反向映射

// HTTP 状态码枚举
enum HttpStatus {
    OK = 200,
    BadRequest = 400,
    Unauthorized = 401,
    NotFound = 404,
    ServerError = 500,
}

function handleResponse(status: HttpStatus): string {
    // 利用反向映射打印状态码名称
    let statusName = HttpStatus[status] || "Unknown";
    return `收到响应：${status} (${statusName})`;
}

console.log(handleResponse(HttpStatus.OK));           // 200 (OK)
console.log(handleResponse(HttpStatus.NotFound));     // 404 (NotFound)

// ==========================================
// 三、数字枚举的陷阱：类型检查很松散
// ==========================================

// ⚠️ 陷阱：数字枚举可以接受任意数字！
// 这和 C++ 的 enum 类似，但与 C++ 的 enum class 完全不同
// 以下代码在 strict 模式下会报错，但在非 strict 或通过类型断言可以绕过：
let myColor: Color = Color.Red;
// 即使 TypeScript strict 模式不允许直接赋值任意数字，
// 数字枚举仍然比字符串枚举更松散——你可以通过计算得到"不存在"的枚举值
// 这也是为什么很多人推荐用字符串枚举或联合类型代替数字枚举
console.log("myColor 初始值:", myColor, "名称:", Color[myColor]);

// 演示：数字枚举可以包含不在枚举定义中的数字（通过类型断言）
// 这在实际项目中是一个潜在风险
let unknownColor = 999 as Color;
console.log("unknownColor:", unknownColor);
console.log("反向映射 Color[999] =", Color[999]);  // undefined（没有这个成员）

// C++ 对比：
//   C++ 的 enum 也可以隐式转为 int
//   但 C++ 的 enum class 必须用 static_cast 转换
//   TypeScript 没有 "enum class" 的概念

// ==========================================
// 四、字符串枚举：TypeScript 独有的特性
// ==========================================

// 每个成员的值都是字符串（C++ 不支持这种枚举）
enum Direction {
    Up = "UP",
    Down = "DOWN",
    Left = "LEFT",
    Right = "RIGHT",
}

let playerDir: Direction = Direction.Up;
console.log("\n方向:", playerDir);

// 字符串枚举的优势 1：不能反向映射（避免混淆）
// console.log(Direction["UP"]);  // ❌ 编译错误！

// 字符串枚举的优势 2：类型更安全——不能赋任意字符串
// playerDir = "UP";         // ❌ 编译错误！类型 "UP" 不能赋给 Direction
// playerDir = "DOWN";       // ❌ 也不行
// playerDir = Direction.Down;  // ✅ 只能赋枚举成员

// 实际应用：根据枚举值做分支
function move(dir: Direction): string {
    switch (dir) {
        case Direction.Up:    return "向上移动";
        case Direction.Down:  return "向下移动";
        case Direction.Left:  return "向左移动";
        case Direction.Right: return "向右移动";
        default:
            // TypeScript 知道这里永远执行不到（所有分支已覆盖）
            // 这个 exhaustive check 是字符串枚举的一大优势
            const _exhaustive: never = dir;
            return _exhaustive;
    }
}

console.log(move(Direction.Up));
console.log(move(Direction.Left));

// ==========================================
// 五、枚举的实际应用：扑克牌花色
// ==========================================

enum CardSuit {
    Hearts = "HEARTS",     // 红心
    Spades = "SPADES",     // 黑桃
    Diamonds = "DIAMONDS", // 方块
    Clubs = "CLUBS",       // 梅花
}

function describeCard(suit: CardSuit, rank: number): string {
    let suitName = "";
    switch (suit) {
        case CardSuit.Hearts:    suitName = "红心"; break;
        case CardSuit.Spades:    suitName = "黑桃"; break;
        case CardSuit.Diamonds:  suitName = "方块"; break;
        case CardSuit.Clubs:     suitName = "梅花"; break;
    }
    return `${suitName} ${rank}`;
}

console.log("\n" + describeCard(CardSuit.Hearts, 7));    // 红心 7
console.log(describeCard(CardSuit.Spades, 1));            // 黑桃 1

// ==========================================
// 六、枚举在运行时的真面目
// ==========================================
// TypeScript 枚举编译后会变成一个 JavaScript 对象
// 数字枚举：{ Red: 0, Green: 1, Blue: 2, 0: "Red", 1: "Green", 2: "Blue" }
// 字符串枚举：{ Up: "UP", Down: "DOWN", Left: "LEFT", Right: "RIGHT" }
// （注意：字符串枚举没有反向映射——Direction["UP"] 不存在）

console.log("\n=== 枚举的运行时形态 ===");
console.log("数字枚举 Color:", Color);
// 输出：{ '0': 'Red', '1': 'Green', '2': 'Blue', Red: 0, Green: 1, Blue: 2 }

console.log("字符串枚举 Direction:", Direction);
// 输出：{ Up: 'UP', Down: 'DOWN', Left: 'LEFT', Right: 'RIGHT' }
// 注意：没有反向映射）"UP", "DOWN" 等不是 Direction 的键

// C++ 对比：C++ 的枚举编译后直接就是整数，零运行时开销。
// TypeScript 的枚举在运行时是一个实实在在的对象，有内存开销。
// 对于简单的常量集合，你也可以考虑用 const enum 或联合类型（第 08 节）。
