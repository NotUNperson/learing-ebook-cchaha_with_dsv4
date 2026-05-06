/**
 * 05-class-basics.ts
 * 主题：类的基本语法——class、constructor、this、new、访问修饰符
 *
 * 本节演示 TypeScript 的 class 定义方式，
 * 与 C++ 的 class 进行对比，帮助 C++ 程序员快速上手。
 */

// ==================== 最简单的类 ====================

/**
 * 遥控器类
 *
 * 对比 C++ 的关键差异：
 * 1. 类型写在属性名后面（brand: string），不是前面（string brand）
 * 2. 构造函数叫 constructor，不是类名
 * 3. 类结尾不需要分号
 * 4. 默认访问级别是 public（C++ 默认是 private）
 */
class RemoteControl {
    // 属性声明：直接写属性名、冒号、类型
    brand: string;
    powerOn: boolean;

    // 构造函数：用 constructor 关键字，不是类名
    // 当 new RemoteControl("索尼") 时自动执行
    constructor(brand: string) {
        // this 指向当前新创建的实例
        // this.brand 是属性，brand 是参数
        this.brand = brand;
        this.powerOn = false;  // 出厂默认关机
    }

    // 方法：不需要 function 关键字
    // 类内部的函数叫"方法"，写法上和普通函数几乎一样
    pressPower(): void {
        this.powerOn = !this.powerOn;  // 切换开关状态
        const status = this.powerOn ? "开机" : "关机";
        console.log(`${this.brand} 遥控器：${status}`);
    }
}

// 创建实例（对象）
// new 关键字触发构造函数，和 C++ 一样
// 和 C++ 不一样的是：TypeScript 自动垃圾回收，不需要 delete
const myRemote = new RemoteControl("索尼");
myRemote.pressPower();  // 索尼 遥控器：开机
myRemote.pressPower();  // 索尼 遥控器：关机

const yourRemote = new RemoteControl("松下");
yourRemote.pressPower();  // 松下 遥控器：开机


// ==================== 访问修饰符 ====================

/**
 * 自动贩卖机类——演示三种访问修饰符
 *
 * public    ：任何人都可以访问（默认）
 * private   ：只有本类内部可以访问
 * protected ：本类和子类可以访问（下节会涉及继承）
 *
 * 生活类比：贩卖机的前面板（public）、内部压缩机（private）、
 *          维修接口（protected）
 */
class VendingMachine {
    // public：外部可以直接读写
    public brand: string;

    // private：只有这个类内部的方法可以访问
    private internalTemp: number;

    // protected：这个类和子类的方法可以访问
    protected serialNumber: string;

    constructor(brand: string, serial: string) {
        this.brand = brand;
        this.internalTemp = 4;       // 默认 4 度（冷藏温度）
        this.serialNumber = serial;  // 序列号不对外公开
    }

    // public 方法：任何人都可以调用
    public dispense(): string {
        this.cool();  // 内部可以调用 private 方法
        return `${this.brand} 贩卖机：商品已出货`;
    }

    // private 方法：只有内部可以用
    // 外部不能调用 machine.cool()
    private cool(): void {
        console.log(`  冷却系统运行，当前温度：${this.internalTemp}°C`);
    }

    // protected 方法：子类可以访问
    protected getSerial(): string {
        return this.serialNumber;
    }
}

const machine = new VendingMachine("可口可乐", "SN2024-001");
console.log(machine.brand);    // "可口可乐" —— public，OK
console.log(machine.dispense()); // 正常出货

// 下面的代码会报编译错误（你可以取消注释试试）：
// machine.internalTemp = 10;  // 错误：private 不能外部访问
// console.log(machine.serialNumber);  // 错误：protected 不能外部访问
// machine.cool();             // 错误：private 不能外部访问


// ==================== 计算器类——更多方法示例 ====================

/**
 * 计算器类
 * 演示 private 属性的典型用法：内部状态不对外暴露
 */
class Calculator {
    // private 属性：结果保存在内部，外部不能直接修改
    private result: number = 0;

    // 加法：修改内部结果
    public add(n: number): void {
        this.result += n;
    }

    // 减法
    public subtract(n: number): void {
        this.result -= n;
    }

    // 乘法
    public multiply(n: number): void {
        this.result *= n;
    }

    // 除法（带除零保护）
    public divide(n: number): boolean {
        if (n === 0) {
            console.log("错误：除数不能为零");
            return false;
        }
        this.result /= n;
        return true;
    }

    // 获取当前结果（只读访问 private 属性）
    public getResult(): number {
        return this.result;
    }

    // 清零
    public reset(): void {
        this.result = 0;
        console.log("计算器已清零");
    }
}

// 使用计算器
const calc = new Calculator();
calc.add(10);
calc.multiply(3);          // 10 * 3 = 30
calc.subtract(5);          // 30 - 5 = 25
calc.divide(5);            // 25 / 5 = 5
console.log("计算结果:", calc.getResult());  // 5

// calc.result = 100;  // 错误！result 是 private 的


// ==================== 银行账户类（动手试试答案参考） ====================

/**
 * 银行账户类
 * - ownerName: public，账户持有人姓名
 * - balance: private，余额不能直接被外部修改
 * - accountNumber: private，账号（内部使用）
 */
class BankAccount {
    public ownerName: string;
    private balance: number;       // 余额——private，只能通过方法操作
    private accountNumber: string; // 账号——private

    constructor(ownerName: string, accountNumber: string) {
        this.ownerName = ownerName;
        this.balance = 0;  // 新账户余额为 0
        this.accountNumber = accountNumber;
    }

    // 存款：增加余额
    public deposit(amount: number): void {
        if (amount <= 0) {
            console.log("存款金额必须大于 0");
            return;
        }
        this.balance += amount;
        console.log(
            `${this.ownerName} 存款 ${amount} 元，当前余额：${this.balance} 元`
        );
    }

    // 取款：减少余额，余额不足时返回 false
    public withdraw(amount: number): boolean {
        if (amount <= 0) {
            console.log("取款金额必须大于 0");
            return false;
        }
        if (amount > this.balance) {
            console.log(
                `${this.ownerName} 取款失败：余额不足（当前余额：${this.balance} 元）`
            );
            return false;
        }
        this.balance -= amount;
        console.log(
            `${this.ownerName} 取款 ${amount} 元，当前余额：${this.balance} 元`
        );
        return true;
    }

    // 查询余额：只读访问 private 属性
    public getBalance(): number {
        return this.balance;
    }

    // 获取账号（提供受控的读访问）
    public getAccountNumber(): string {
        // 只显示后 4 位，保护隐私
        return "****" + this.accountNumber.slice(-4);
    }
}

// 创建两个账户并测试
console.log("\n=== 银行账户测试 ===");
const aliceAccount = new BankAccount("Alice", "6222021234567890");
const bobAccount = new BankAccount("Bob", "6222020987654321");

aliceAccount.deposit(1000);    // Alice 存入 1000
bobAccount.deposit(500);       // Bob 存入 500

console.log(`Alice 余额: ${aliceAccount.getBalance()} 元`);
console.log(`Bob 余额: ${bobAccount.getBalance()} 元`);

// 转账：Alice → Bob（200 元）
console.log("\n--- 转账：Alice → Bob 200 元 ---");
const withdrawOk = aliceAccount.withdraw(200);
if (withdrawOk) {
    bobAccount.deposit(200);
}

console.log(`转账后 Alice 余额: ${aliceAccount.getBalance()} 元`);
console.log(`转账后 Bob 余额: ${bobAccount.getBalance()} 元`);

// 尝试超额取款
console.log("\n--- 尝试超额取款 ---");
aliceAccount.withdraw(9999);

// 查看账号（隐私保护）
console.log(`Alice 账号: ${aliceAccount.getAccountNumber()}`);

// 错误访问尝试（编译时会报错）：
// console.log(aliceAccount.balance);  // 错误：private
