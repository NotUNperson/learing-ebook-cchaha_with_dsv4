/**
 * 06-readonly-constructor.ts
 * 主题：构造函数参数属性（简写语法）与 readonly 属性修饰符
 *
 * 本节演示两个 TypeScript 独有的便捷特性：
 * 1. 构造函数参数属性——在参数上直接加修饰符，同时声明并初始化属性
 * 2. readonly——让属性在创建后不可修改
 *
 * 对比 C++ 的初始化列表和 const 成员。
 */

// ==================== 传统写法 vs 简写 ====================

/**
 * 传统写法（上一节的方式）
 * 三行属性声明 + 三行赋值 = 六行
 */
class StudentOld {
    name: string;
    age: number;
    grade: string;

    constructor(name: string, age: number, grade: string) {
        this.name = name;
        this.age = age;
        this.grade = grade;
    }
}

/**
 * 参数属性简写（Parameter Properties）
 * 在构造函数参数前加 public/private/protected，
 * TypeScript 自动帮你完成属性声明和赋值。
 *
 * 三行搞定！而且意图更明确：
 * 一眼就知道这个类有三个 public 属性，构造时需要传入。
 */
class Student {
    constructor(
        public name: string,
        public age: number,
        public grade: string
    ) {
        // 构造函数体可以是空的！
        // TypeScript 自动做了：
        // 1. 声明 name: string 属性
        // 2. 声明 age: number 属性
        // 3. 把参数值赋给对应的属性
    }
}

// 两个类的使用方式完全一样
const s1 = new StudentOld("小红（旧写法）", 15, "初三(1)班");
const s2 = new Student("小明（简写）", 16, "高一(3)班");

console.log(s1.name, s1.age, s1.grade);
console.log(s2.name, s2.age, s2.grade);


// ==================== 不同访问修饰符的简写 ====================

/**
 * 银行账户——使用参数属性简写
 *
 * public ownerName: 外部可读
 * private balance: 外部不可访问，默认值为 0
 * protected accountId: 子类可访问
 *
 * 和 C++ 初始化列表的对比：
 * C++:  Student(string n, int a) : name(n), age(a) {}
 * TS:   constructor(public name: string, public age: number) {}
 *
 * TS 的所有信息（访问级别、名称、类型）集中在一处，更紧凑
 */
class BankAccount {
    constructor(
        public ownerName: string,        // public：外部可读
        private _balance: number = 0,    // private + 默认值
        protected accountId: string      // protected：子类可访问
    ) {
        // 函数体为空，所有属性已自动声明和赋值
    }

    // 存款
    deposit(amount: number): void {
        if (amount <= 0) return;
        this._balance += amount;
        console.log(`${this.ownerName} 存款 ${amount} 元`);
    }

    // 取款
    withdraw(amount: number): boolean {
        if (amount <= 0 || amount > this._balance) {
            console.log(`${this.ownerName} 取款失败：余额不足`);
            return false;
        }
        this._balance -= amount;
        console.log(`${this.ownerName} 取款 ${amount} 元`);
        return true;
    }

    // 查询余额（提供受控访问）
    get balance(): number {
        return this._balance;
    }
}

const acc = new BankAccount("Alice", 1000, "ACC-001");
console.log(acc.ownerName);   // "Alice" —— public OK
console.log(acc.balance);     // 1000 —— 通过 getter 访问
// acc._balance;   // 错误 —— private
// acc.accountId;  // 错误 —— protected


// ==================== readonly 修饰符 ====================

/**
 * 商品类——演示 readonly
 *
 * readonly 的语义：属性只能在声明时或构造函数中赋值，
 * 之后任何地方都不能修改。
 *
 * 对比 C++ 的 const 成员：
 * C++:  const string id;  // 必须用初始化列表赋值
 * TS:   readonly id: string;  // 声明或构造函数中赋值
 *
 * 和 C++ const 的区别：
 * - C++ const 成员只能用初始化列表初始化
 * - TS readonly 可以在声明时给值，也可以在构造函数中赋值
 * - C++ const 是真正的"不可变"（编译期常量语义更强）
 * - TS readonly 只在编译时检查（运行时仍然可以绕过，但强烈不推荐）
 */
class Product {
    // readonly 属性：创建后不能修改
    public readonly id: string;
    public readonly createdAt: Date;
    // 普通属性：可以随时修改
    public name: string;
    public price: number;

    constructor(id: string, name: string, price: number) {
        this.id = id;                   // readonly 只能在构造函数中赋值
        this.name = name;
        this.price = price;
        this.createdAt = new Date();    // 创建时间——之后不能改
    }

    // 改名：OK，name 不是 readonly
    updateName(newName: string): void {
        this.name = newName;
    }

    // 改价格：OK
    updatePrice(newPrice: number): void {
        if (newPrice > 0) {
            this.price = newPrice;
        }
    }

    // 下面的方法会报错（你可以取消注释试试）：
    // changeId(newId: string): void {
    //     this.id = newId;  // 错误！readonly 属性不能重新赋值
    // }
}

const p = new Product("P001", "机械键盘", 299);
console.log("商品:", p.id, p.name, p.price, "元");

p.updatePrice(259);  // 降价了
console.log("降价后:", p.price, "元");

// p.id = "P002";  // 错误！readonly 不能在外部修改

console.log("创建时间:", p.createdAt.toLocaleString());
// p.createdAt = new Date();  // 错误！readonly


// ==================== readonly + 参数属性 ====================

/**
 * readonly 也可以和构造函数参数属性组合使用
 * 这是声明"不可变的构造参数"的最简洁方式
 */
class User {
    constructor(
        public readonly id: number,       // 创建后 ID 不能改
        public name: string,              // 名字可以改
        public readonly registeredAt: Date // 注册时间不能改
    ) {
        // 空函数体 —— 三个属性已自动声明、赋值
    }

    rename(newName: string): void {
        this.name = newName;
        // this.id = 999;  // 错误！readonly
    }
}

const user = new User(1001, "张三", new Date());
console.log("用户:", user.id, user.name, user.registeredAt.toLocaleDateString());

user.rename("张三丰");
console.log("改名后:", user.name);  // 张三丰


// ==================== 不能使用简写的情况 ====================

class Person {
    public fullName: string;
    private birthYear: number;
    private phone: string;

    constructor(firstName: string, lastName: string, age: number, phone: string) {
        // 情况 1：属性值需要计算或转换
        // firstName + lastName → fullName，不能用简写
        this.fullName = `${lastName} ${firstName}`;

        // 情况 2：参数名和属性名不同
        // 参数是 age，属性是 birthYear——不同名，不能简写
        this.birthYear = new Date().getFullYear() - age;

        // 情况 3：需要验证
        // 手机号格式验证
        if (phone.length !== 11) {
            throw new Error("手机号必须是 11 位");
        }
        this.phone = phone;
    }

    introduce(): string {
        return `我叫${this.fullName}，出生于${this.birthYear}年`;
    }
}

const person = new Person("三", "张", 25, "13800138000");
console.log(person.introduce());


// ==================== 动手试试答案参考 ====================

/**
 * 使用参数属性 + readonly 重写的 BankAccount
 * 对比上一节的版本，代码量大幅减少
 */
class BetterBankAccount {
    constructor(
        public ownerName: string,            // public：外部可读
        public readonly accountNumber: string, // readonly：创建后不能改
        private _balance: number = 0          // private + 默认值
    ) {
        // 空函数体
    }

    // createdAt 不能从参数获取，所以用传统方式声明
    public readonly createdAt: Date = new Date();

    deposit(amount: number): void {
        if (amount <= 0) {
            console.log("存款金额必须大于 0");
            return;
        }
        this._balance += amount;
        console.log(`${this.ownerName} 存款 ${amount} 元，余额：${this._balance} 元`);
    }

    withdraw(amount: number): boolean {
        if (amount <= 0) {
            console.log("取款金额必须大于 0");
            return false;
        }
        if (amount > this._balance) {
            console.log(`${this.ownerName} 取款失败：余额不足`);
            return false;
        }
        this._balance -= amount;
        console.log(`${this.ownerName} 取款 ${amount} 元，余额：${this._balance} 元`);
        return true;
    }

    getBalance(): number {
        return this._balance;
    }
}

console.log("\n=== 改进版银行账户测试 ===");
const alice = new BetterBankAccount("Alice", "6222021234567890");
const bob = new BetterBankAccount("Bob", "6222020987654321", 500);

// Alice 创建时未传初始余额，所以是默认的 0
console.log(`Alice 余额: ${alice.getBalance()} 元`);
console.log(`Bob 余额: ${bob.getBalance()} 元`);
console.log(`Alice 账号: ${alice.accountNumber}`);
console.log(`账户创建于: ${alice.createdAt.toLocaleString()}`);

// 转账测试
alice.deposit(1000);
alice.withdraw(300);
bob.deposit(300);

console.log(`转账后 Alice 余额: ${alice.getBalance()} 元`);
console.log(`转账后 Bob 余额: ${bob.getBalance()} 元`);

// alice.accountNumber = "xxx";  // 错误：readonly 不能修改
