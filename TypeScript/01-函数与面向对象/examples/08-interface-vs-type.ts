/**
 * 08-interface-vs-type.ts
 * 主题：interface vs type 别名——各自的特点、何时用哪个
 *
 * 本节全面对比 interface 和 type，展示它们各自的优势，
 * 帮助你在实际项目中做出正确选择。
 */

// ==================== 共同点：两者都能描述对象形状 ====================

/**
 * 用 type 描述用户
 */
type UserWithType = {
    name: string;
    age: number;
    email: string;
};

/**
 * 用 interface 描述用户
 * 在这个场景下，type 和 interface 完全可以互换
 */
interface UserWithInterface {
    name: string;
    age: number;
    email: string;
}

// 两者使用方式完全一样
const user1: UserWithType = { name: "张三", age: 20, email: "zhangsan@test.com" };
const user2: UserWithInterface = { name: "李四", age: 22, email: "lisi@test.com" };

console.log("user1 (type):", user1.name);
console.log("user2 (interface):", user2.name);


// ==================== type 独有的能力 ====================

/**
 * 1. 基本类型的别名
 * interface 不能做这个——它只能描述对象形状
 */
type MyString = string;
type MyNumber = number;
type MyBoolean = boolean;

const username: MyString = "hello";
const count: MyNumber = 42;

console.log("基本类型别名:", username, count);


/**
 * 2. 联合类型（Union Types）
 * type 可以把多个类型"或"在一起
 * interface 做不到——它不是对象形状
 */
type Status = "success" | "error" | "pending" | "idle";
type StringOrNumber = string | number;

function handleStatus(s: Status): void {
    console.log("当前状态:", s);
}

handleStatus("success");  // OK
handleStatus("idle");     // OK
// handleStatus("unknown"); // 错误！"unknown" 不在 Status 联合类型中


/**
 * 3. 元组类型（Tuple Types）
 * 固定长度的数组，每个位置有特定类型
 */
type Point2D = [number, number];
type Point3D = [number, number, number];
type ApiResult = [number, string];  // [状态码, 消息]

const p2: Point2D = [100, 200];
const p3: Point3D = [10, 20, 30];
const result: ApiResult = [200, "OK"];

console.log("2D 坐标:", p2);
console.log("3D 坐标:", p3);
console.log("API 结果:", result);


/**
 * 4. 函数类型签名
 * type 写函数签名更简洁直观
 */
type MathOperation = (a: number, b: number) => number;

const addOp: MathOperation = (a, b) => a + b;
const multiplyOp: MathOperation = (a, b) => a * b;

console.log("addOp(3, 7) =", addOp(3, 7));
console.log("multiplyOp(4, 5) =", multiplyOp(4, 5));


/**
 * 5. 交叉类型（Intersection Types）
 * 把两个类型"与"在一起
 */
type HasName = { name: string };
type HasAge = { age: number };
type Person = HasName & HasAge;  // 同时有 name 和 age

const person: Person = { name: "王五", age: 30 };
console.log(`${person.name}, ${person.age} 岁`);


// ==================== interface 独有的能力：声明合并 ====================

/**
 * 声明合并（Declaration Merging）
 *
 * 同一作用域内多次声明同名 interface，
 * TypeScript 会把它们"合并"成一个更大的接口。
 *
 * type 做不到这一点——重复定义会直接报错。
 *
 * 生活类比：
 * - interface = 便利贴：可以分多次贴，信息会自动合并
 * - type      = 铅笔写：擦了重写，旧的会被覆盖
 */

// 第一次声明
interface MergedUser {
    name: string;
}

// 第二次声明（同名！）——不会报错，而是合并
interface MergedUser {
    age: number;
}

// 第三次声明——继续合并
interface MergedUser {
    email: string;
}

// 使用时：三个属性都存在
const mergedUser: MergedUser = {
    name: "赵六",
    age: 28,
    email: "zhaoliu@test.com"
};

console.log("合并后的接口:", mergedUser);

/**
 * 声明合并的实际用途：
 * 给第三方库的类型"打补丁"——不用改库的代码，
 * 在自己的文件中声明同名 interface 就能添加属性。
 */


// ==================== extends 对比 ====================

/**
 * interface 用 extends 继承
 */
interface Animal {
    name: string;
    age: number;
}

interface Dog extends Animal {
    breed: string;
    bark(): void;
}

const myDog: Dog = {
    name: "旺财",
    age: 3,
    breed: "金毛",
    bark() {
        console.log("汪汪！");
    }
};

myDog.bark();


/**
 * type 用交叉类型（&）实现类似效果
 */
type Cat = Animal & {
    color: string;
    meow(): void;
};

const myCat: Cat = {
    name: "咪咪",
    age: 2,
    color: "橘色",
    meow() {
        console.log("喵喵！");
    }
};

myCat.meow();


// ==================== 性能与错误提示差异 ====================

/**
 * interface 和 type 在错误消息中的表现不同
 *
 * interface 的错误通常更清晰：直接显示接口名
 * type 的错误可能展开为原始结构
 *
 * 这只是提示体验的差异，不影响运行时行为
 */


/**
 * class 使用 implements
 * interface 和 type（对象形状）都可以被 class 实现
 */

interface Flyable {
    fly(): void;
}

class Bird implements Flyable {
    fly(): void {
        console.log("鸟儿在飞翔");
    }
}

// type 如果有对象形状，也能 implements
type Swimmable = {
    swim(): void;
};

class Fish implements Swimmable {
    swim(): void {
        console.log("鱼儿在游泳");
    }
}

const bird = new Bird();
bird.fly();

const fish = new Fish();
fish.swim();


// ==================== 社区惯例与选择指南 ====================

/**
 * 选择指南：
 *
 * 优先用 interface：
 * - 描述对象形状（尤其是公开 API）
 * - 需要 extends / implements
 * - 可能需要声明合并
 *
 * 优先用 type：
 * - 联合类型、元组类型
 * - 基本类型别名
 * - 函数签名
 * - 映射类型、条件类型等高级类型
 *
 * 一句话：描述"东西"用 interface，做"类型组合"用 type
 */

// ==================== 动手试试答案参考 ====================

/**
 * HttpMethod 联合类型——只能用 type（联合类型）
 */
type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";

/**
 * RequestConfig 接口——描述对象形状
 * 注意：这里展示了声明合并
 */
// 第一次声明 RequestConfig
interface RequestConfig {
    url: string;
    method: HttpMethod;
    headers?: Record<string, string>;  // 可选的请求头
    timeout?: number;                   // 可选的超时时间
}

// 第二次声明同名接口——声明合并！会自动加上 retryCount 属性
interface RequestConfig {
    retryCount?: number;  // 合并后 RequestConfig 有了这个额外属性
}

/**
 * 执行请求的函数（模拟）
 */
function execute(config: RequestConfig): void {
    console.log("\n=== 请求信息 ===");
    console.log(`URL: ${config.url}`);
    console.log(`方法: ${config.method}`);
    console.log(`超时: ${config.timeout ?? "默认"}`);
    console.log(`重试: ${config.retryCount ?? "0"}`);
    if (config.headers) {
        console.log("请求头:", JSON.stringify(config.headers));
    }
}

// 创建符合合并后接口的对象
const reqConfig: RequestConfig = {
    url: "https://api.example.com/users",
    method: "GET",
    headers: { "Authorization": "Bearer xxxxx" },
    timeout: 5000,
    retryCount: 3  // 这个属性来自第二次声明（声明合并）
};

execute(reqConfig);

// 最小配置（所有可选属性都不填）
const minimalConfig: RequestConfig = {
    url: "https://api.example.com/ping",
    method: "POST"
};

execute(minimalConfig);
