// ============================================================
// 03 泛型接口与泛型类 — 示例代码
// 演示 interface Box<T>、class Stack<T>、泛型接口继承
// ============================================================

// -------------------- 1. 泛型接口：Box<T> --------------------
// 定义一个通用的"盒子"接口，T 代表盒子里装的东西的类型
interface Box<T> {
  content: T;              // 盒子里当前装的东西
  put(item: T): void;      // 往盒子里放东西
  take(): T;               // 从盒子里取东西
}

// 实现一个数字盒子——Box<number>，T 被替换为 number
const numberBox: Box<number> = {
  content: 0,
  put(item: number): void {
    this.content = item;
    console.log(`放入数字: ${item}`);
  },
  take(): number {
    const item = this.content;
    console.log(`取出数字: ${item}`);
    return item;
  },
};

numberBox.put(42);
const n = numberBox.take();
console.log("取出的值:", n); // 42

// 实现一个字符串盒子——Box<string>，T 被替换为 string
const stringBox: Box<string> = {
  content: "",
  put(item: string): void {
    this.content = item;
    console.log(`放入字符串: "${item}"`);
  },
  take(): string {
    const item = this.content;
    console.log(`取出字符串: "${item}"`);
    return item;
  },
};

stringBox.put("TypeScript 真有趣");
stringBox.take();

// -------------------- 2. 泛型类：Stack<T> --------------------
// 栈——后进先出（LIFO），像一叠盘子
class Stack<T> {
  // 私有属性，用数组保存栈中元素
  private items: T[] = [];

  // 压栈：往顶部加一个元素
  push(item: T): void {
    this.items.push(item);
  }

  // 弹栈：从顶部移除并返回元素；栈空时返回 undefined
  pop(): T | undefined {
    return this.items.pop();
  }

  // 窥视：看一眼顶部元素但不移除
  peek(): T | undefined {
    return this.items[this.items.length - 1];
  }

  // getter：获取栈的大小（调用时不需要括号，像属性一样）
  get size(): number {
    return this.items.length;
  }

  // 判断栈是否为空
  get isEmpty(): boolean {
    return this.items.length === 0;
  }
}

// 测试数字栈
console.log("\n--- 数字栈 ---");
const numberStack = new Stack<number>();
numberStack.push(10);
numberStack.push(20);
numberStack.push(30);
console.log("大小:", numberStack.size);  // 3
console.log("栈顶:", numberStack.peek()); // 30
console.log("弹出:", numberStack.pop());  // 30
console.log("弹出:", numberStack.pop());  // 20
console.log("弹出:", numberStack.pop());  // 10
console.log("是否为空:", numberStack.isEmpty); // true

// 测试字符串栈
console.log("\n--- 字符串栈 ---");
const stringStack = new Stack<string>();
stringStack.push("春");
stringStack.push("夏");
stringStack.push("秋");
stringStack.push("冬");
console.log("大小:", stringStack.size);   // 4
console.log("栈顶:", stringStack.peek());  // "冬"
while (!stringStack.isEmpty) {
  console.log("弹出:", stringStack.pop());
}
// 弹出顺序：冬 -> 秋 -> 夏 -> 春（后进先出）

// stringStack.push(123); // 编译错误！Stack<string> 的 push 只接受 string

// -------------------- 3. 泛型接口继承 --------------------
// 带锁的盒子——扩展 Box，添加锁相关功能
interface SafeBox<T> extends Box<T> {
  isLocked: boolean;
  lock(): void;
  unlock(code: string): boolean;
}

// 实现一个带锁的字符串盒子
const safeBox: SafeBox<string> = {
  content: "秘密文件",
  isLocked: true,

  put(item: string): void {
    if (!this.isLocked) {
      this.content = item;
      console.log(`存入: ${item}`);
    } else {
      console.log("盒子已上锁，无法放入！");
    }
  },

  take(): string {
    if (!this.isLocked) {
      console.log(`取出: ${this.content}`);
      return this.content;
    }
    console.log("盒子已上锁，无法取出！");
    return "";
  },

  lock(): void {
    this.isLocked = true;
    console.log("盒子已上锁");
  },

  unlock(code: string): boolean {
    if (code === "1234") {
      this.isLocked = false;
      console.log("盒子已解锁");
      return true;
    }
    console.log("密码错误！");
    return false;
  },
};

safeBox.take();           // 盒子已上锁，无法取出！
safeBox.unlock("1234");   // 盒子已解锁
safeBox.take();            // 取出: 秘密文件

// -------------------- 4. Result<T> 模式 --------------------
// 统一的"操作结果"类型，成功则带数据，失败则带错误信息
interface Result<T> {
  success: boolean;
  data?: T;        // 成功时的数据，失败时为 undefined
  error?: string;  // 失败时的错误信息，成功时为 undefined
}

// 模拟一个可能失败的 JSON 解析函数
function safeParseJSON<T>(json: string): Result<T> {
  try {
    const data = JSON.parse(json) as T;
    return { success: true, data };
  } catch (e) {
    return { success: false, error: String(e) };
  }
}

const result1 = safeParseJSON<{ name: string; age: number }>(
  '{"name": "张三", "age": 25}'
);
if (result1.success && result1.data) {
  console.log(`\n解析成功：${result1.data.name}, ${result1.data.age}岁`);
}

const result2 = safeParseJSON<{ name: string }>("这不是 JSON");
console.log("解析失败:", result2.error);

// ============================================================
// 动手试试答案（Queue<T> 实现）：
// class Queue<T> {
//   private items: T[] = [];
//   enqueue(item: T): void { this.items.push(item); }
//   dequeue(): T | undefined { return this.items.shift(); }
//   peek(): T | undefined { return this.items[0]; }
//   get size(): number { return this.items.length; }
// }
// ============================================================
