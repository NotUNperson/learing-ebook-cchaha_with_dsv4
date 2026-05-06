// ==========================================
// 07-any-unknown.ts
// 演示 any 和 unknown 的区别、类型收窄
// ==========================================

export {};  // 让这个文件成为一个独立的模块，避免全局作用域冲突

// ==========================================
// 一、any：关掉所有类型检查
// ==========================================

// any 类型的变量可以赋任何值，做任何操作，编译器完全不检查
let anything: any = 42;
console.log("anything 初始值:", anything);

anything = "hello";          // ✅ 可以变成字符串
anything = true;             // ✅ 可以变成布尔
anything = { foo: "bar" };   // ✅ 可以变成对象
console.log("anything 现在:", anything);

// any 变量可以调用任何方法——即使这个方法不存在！
// 以下代码编译通过，但运行时会报错：
// anything.fly();            // 运行时错误：anything.fly is not a function
// anything.hello.world();    // 运行时错误：Cannot read properties of undefined

// ⚠️ any 的传染性：any 赋值给其他类型变量时，不会报错
let dangerous: any = "I'm actually a string";
let supposedlyNumber: number = dangerous;  // 编译通过！但运行时 dangerous 是字符串
// supposedlyNumber 的类型标注是 number，但实际上它的值是 "I'm actually a string"
// 这种"类型标注和实际值不一致"的情况是 bug 的温床
console.log("supposedlyNumber =", supposedlyNumber);

// C++ 类比：void* ——可以指向任何类型，但需要手动 cast 回来
// void* ptr = &someInt; int* p = (int*)ptr;  ——类型安全完全由你负责

// ==========================================
// 二、unknown：安全的"不知道"
// ==========================================

// unknown 也可以接受任何值，但不能直接使用
let data: unknown;

data = "Hello World";
console.log("data =", data);

data = 42;
console.log("data 现在是:", data);

data = { name: "Alice", age: 25 };
console.log("data 现在是:", data);

// ❌ 不能直接使用 unknown 类型的变量：
// data.toUpperCase();    // 编译错误！Object is of type 'unknown'
// data.name;             // 编译错误！
// data + 1;              // 编译错误！

// ==========================================
// 三、类型收窄（Type Narrowing）
// 在使用 unknown 之前，必须先确定它的类型
// ==========================================

let input: unknown = "TypeScript 真好玩";

// 方法一：typeof 类型收窄
if (typeof input === "string") {
    // 在这个 if 块里，TypeScript 知道 input 是 string
    let upper = input.toUpperCase();    // ✅ 可以调用 string 的方法
    console.log("输入是大写的:", upper);
    console.log("字符串长度:", input.length);
} else if (typeof input === "number") {
    // 在这个 if 块里，TypeScript 知道 input 是 number
    console.log("数字的两倍:", input * 2);
} else if (typeof input === "boolean") {
    console.log("布尔值取反:", !input);
} else {
    console.log("未知类型:", typeof input);
}

// 方法二：instanceof 类型收窄（用于判断是否是某个类的实例）
let maybeDate: unknown = new Date();
if (maybeDate instanceof Date) {
    console.log("年份:", maybeDate.getFullYear());
    console.log("月份:", maybeDate.getMonth() + 1);  // getMonth() 返回 0-11
}

// 方法三：自定义类型守卫（type guard）——稍复杂的判断条件
// 判断一个 unknown 是否是 { name: string; age: number } 类型的对象
function isPerson(obj: unknown): obj is { name: string; age: number } {
    return (
        typeof obj === "object" &&
        obj !== null &&
        "name" in obj &&
        "age" in obj &&
        typeof (obj as any).name === "string" &&
        typeof (obj as any).age === "number"
    );
}

let unknownData: unknown = { name: "Bob", age: 30 };
if (isPerson(unknownData)) {
    // 在这个 if 块里，unknownData 会自动收窄为 { name: string; age: number }
    console.log(`${unknownData.name} 今年 ${unknownData.age} 岁`);
}

unknownData = { notAPerson: true };
if (!isPerson(unknownData)) {
    console.log("这不是一个人对象");
}

// ==========================================
// 四、真实场景：处理 API 返回的数据
// ==========================================

// 模拟从 API 拿到的数据——你完全不知道后端返回了什么
function processApiResponse(data: unknown): string {
    if (typeof data === "string") {
        return `API 返回了文本：${data}`;
    } else if (typeof data === "number") {
        return `API 返回了数字：${data}`;
    } else if (typeof data === "boolean") {
        return `API 返回了布尔值：${data ? "是" : "否"}`;
    } else if (Array.isArray(data)) {
        return `API 返回了一个数组，长度：${data.length}`;
    } else if (typeof data === "object" && data !== null) {
        // 安全地转成字符串展示（不想处理太复杂的嵌套对象）
        return `API 返回了一个对象，键：${Object.keys(data).join(", ")}`;
    }
    return "未知的返回类型";
}

console.log(processApiResponse("OK"));
console.log(processApiResponse(200));
console.log(processApiResponse(true));
console.log(processApiResponse([1, 2, 3]));
console.log(processApiResponse({ status: "success", code: 200 }));
console.log(processApiResponse(null));

// ==========================================
// 五、any vs unknown 总结
// ==========================================
// | 特性      | any              | unknown                  |
// |-----------|------------------|--------------------------|
// | 接受任何值 | 是               | 是                       |
// | 调用方法   | 可以（不安全）    | 不可以（必须先收窄）       |
// | 赋值给其他类型 | 可以（传染）  | 不可以（安全）            |
// | 读取属性   | 可以（不安全）    | 不可以（必须先收窄）       |
// | 类比 C++  | void*            | std::any（需 any_cast）   |
// | 使用建议   | 尽量避免         | 不知道类型时的首选        |
