/**
 * 07-interface.ts
 * 主题：接口 interface——描述对象形状
 *
 * 本节演示 TypeScript 接口的基本语法和用法，
 * 包括属性定义、可选属性、readonly 属性、嵌套接口，
 * 并与 C++ struct 进行对比。
 */

// ==================== 基本接口定义 ====================

/**
 * User 接口：描述一个用户对象应该有什么属性
 *
 * 对比 C++ struct:
 * struct User {
 *     string name;
 *     int age;
 *     string email;
 * };
 *
 * 关键区别：
 * 1. C++ 类型在前，TS 类型在冒号后
 * 2. C++ struct 在内存中真实存在，TS interface 编译后消失
 * 3. C++ 用分号结尾，TS 分号或逗号都可（推荐分号）
 */
interface User {
    name: string;
    age: number;
    email: string;
}

/**
 * 使用 interface 作为参数类型
 * 只要对象有 name、age、email 三个属性就能通过类型检查
 * 不管这个对象是从哪里来的
 */
function sendEmail(user: User, message: string): void {
    console.log(`发送邮件给 ${user.name}（${user.email}）：${message}`);
}

// 普通对象字面量——只要形状匹配就行
const alice: User = {
    name: "Alice",
    age: 25,
    email: "alice@example.com"
};

sendEmail(alice, "欢迎注册我们的平台！");


// ==================== 结构化类型（鸭式辩型） ====================

/**
 * TypeScript 的类型检查是"结构化"的：
 * 只看对象有没有需要的属性，不看对象来自哪里。
 *
 * 这叫"鸭式辩型"：如果它走起来像鸭子，叫起来像鸭子，那它就是鸭子。
 *
 * C++ 是"名义化"类型：你必须明确声明"我是 User 类型"才算数。
 * TS 是"结构化"类型：只要你有 name 属性，你就是 Named。
 */

interface Named {
    name: string;
}

function greet(entity: Named): void {
    console.log(`Hello, ${entity.name}!`);
}

// 不同的"物种"，但都有 name 属性——都能通过类型检查
greet({ name: "小王" });  // 普通对象

// 有额外属性的对象——先存到变量里再传，绕过对象字面量的严格检查
const oldZhang = { name: "老张", age: 50, job: "工程师" };
greet(oldZhang);  // 可以！只要结构兼容就行（结构化类型）

class Person {
    constructor(public name: string) {}
}
greet(new Person("赵六"));  // 类的实例也能用——因为它有 name 属性

// 甚至"动物"对象也行
const cat = { name: "咪咪", color: "橘色", age: 3 };
greet(cat);  // Hello, 咪咪！


// ==================== 可选属性 ====================

/**
 * UserProfile 接口：演示可选属性
 * 可选属性用 ? 标记——和函数参数的可选标记一样
 *
 * phone? 和 bio? 不是必须的，有就输出，没有就跳过
 *
 * 生活类比：简历上的"获奖经历"——有更好，没有也合格
 */
interface UserProfile {
    name: string;
    age: number;
    email: string;
    phone?: string;  // 可选：电话号码
    bio?: string;    // 可选：个人简介
}

function printProfile(profile: UserProfile): void {
    console.log(`\n=== ${profile.name} 的个人资料 ===`);
    console.log(`年龄：${profile.age}`);
    console.log(`邮箱：${profile.email}`);

    // 可选属性使用前要判断是否存在
    if (profile.phone) {
        console.log(`电话：${profile.phone}`);
    } else {
        console.log("电话：未填写");
    }

    if (profile.bio) {
        console.log(`简介：${profile.bio}`);
    }
}

// 完整填写
const profile1: UserProfile = {
    name: "韩梅梅",
    age: 23,
    email: "hanmeimei@example.com",
    phone: "13800138000",
    bio: "热爱编程的文艺青年"
};

// 部分省略——有 ? 标记的属性可以不填
const profile2: UserProfile = {
    name: "李雷",
    age: 24,
    email: "lilei@example.com"
};

printProfile(profile1);
printProfile(profile2);


// ==================== readonly 属性 ====================

/**
 * Product 接口：演示 readonly 属性
 * readonly 属性在对象创建后就不能修改
 *
 * 适用场景：ID、创建时间、序列号等"出生就决定了"的值
 */
interface Product {
    readonly id: string;     // 产品 ID——创建后永远不会变
    name: string;            // 名称——可以改
    price: number;           // 价格——可以改
}

const keyboard: Product = {
    id: "KB-001",
    name: "机械键盘",
    price: 299
};

console.log(`\n产品：${keyboard.id} - ${keyboard.name}，${keyboard.price} 元`);

// 修改非 readonly 属性——OK
keyboard.price = 259;
console.log(`降价后：${keyboard.price} 元`);

// 修改 readonly 属性——编译错误（你可以取消注释试试）：
// keyboard.id = "KB-002";  // 错误！readonly 属性不能赋值


// ==================== 嵌套接口 ====================

/**
 * 接口的属性可以是另一个接口
 * 这让我们能描述复杂的嵌套结构
 */

interface Address {
    province: string;  // 省
    city: string;      // 市
    street: string;    // 街道
    zipCode: string;   // 邮编
}

interface Employee {
    name: string;
    position: string;      // 职位
    salary: number;        // 月薪
    address: Address;      // 地址——使用另一个接口
    skills?: string[];     // 技能列表（可选）
}

function printEmployee(emp: Employee): void {
    console.log(`\n=== ${emp.name} 的员工信息 ===`);
    console.log(`职位：${emp.position}`);
    console.log(`月薪：${emp.salary} 元`);
    console.log(`地址：${emp.address.province} ${emp.address.city} ${emp.address.street}`);
    console.log(`邮编：${emp.address.zipCode}`);
    if (emp.skills && emp.skills.length > 0) {
        console.log(`技能：${emp.skills.join("、")}`);
    }
}

const zhangsan: Employee = {
    name: "张三",
    position: "高级前端工程师",
    salary: 25000,
    address: {
        province: "广东省",
        city: "深圳市",
        street: "南山区科技园路 100 号",
        zipCode: "518000"
    },
    skills: ["TypeScript", "React", "Node.js"]
};

printEmployee(zhangsan);


// ==================== 动手试试答案参考 ====================

/**
 * Book 接口：描述一本书
 */
interface Book {
    title: string;
    author: string;
    pages: number;
    readonly isbn: string;       // ISBN 号——创建后不能改
    publishedYear?: number;      // 出版年份——可选
}

/**
 * 打印书籍信息的函数
 * publishedYear 如果存在就打印，否则打印"未知"
 */
function printBookInfo(book: Book): void {
    console.log(`\n《${book.title}》`);
    console.log(`作者：${book.author}`);
    console.log(`页数：${book.pages}`);
    console.log(`ISBN：${book.isbn}`);

    if (book.publishedYear) {
        console.log(`出版年份：${book.publishedYear}`);
    } else {
        console.log("出版年份：未知");
    }
}

// 书 1：完整信息
const book1: Book = {
    title: "深入理解 TypeScript",
    author: "张三",
    pages: 450,
    isbn: "978-7-123-45678-9",
    publishedYear: 2023
};

// 书 2：不填出版年份
const book2: Book = {
    title: "JavaScript 高级程序设计",
    author: "李四",
    pages: 600,
    isbn: "978-7-987-65432-1"
};

printBookInfo(book1);
printBookInfo(book2);

// 尝试修改 ISBN——编译错误：
// book1.isbn = "xxx";  // 错误：Cannot assign to 'isbn' because it is a read-only property.
