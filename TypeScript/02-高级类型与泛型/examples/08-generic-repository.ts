// ============================================================
// 08 综合练习：泛型数据仓库 — 示例代码
// 综合运用泛型、约束、keyof、索引访问、映射类型、交叉类型
// 构建一个类型安全的完整 Repository 模式
// ============================================================

// -------------------- 1. 基础约束：所有可存储的数据必须有 id --------------------
interface Identifiable {
  id: number;
}

// -------------------- 2. 业务数据接口 --------------------
// 用户
interface User extends Identifiable {
  name: string;
  email: string;
  age: number;
}

// 商品
interface Product extends Identifiable {
  name: string;
  price: number;
  category: string;
}

// 任务
interface Task extends Identifiable {
  title: string;
  completed: boolean;
  priority: "low" | "medium" | "high";
}

// -------------------- 3. 泛型仓库类 Repository<T> --------------------
// T extends Identifiable —— 约束 T 必须有 id 属性
class Repository<T extends Identifiable> {
  // 内部用数组存储数据（在实际项目中，这里可以是数据库操作）
  private items: T[] = [];

  // ----- 3.1 添加记录 -----
  // 参数和返回值都是 T 类型，保持完整的类型信息
  add(item: T): T {
    // 检查是否已存在相同 id 的记录
    const existing = this.findById(item.id);
    if (existing) {
      throw new Error(`id 为 ${item.id} 的记录已存在`);
    }
    this.items.push(item);
    return item;
  }

  // ----- 3.2 按 ID 查找 -----
  // 返回 T | undefined（可能找不到，返回 undefined）
  findById(id: number): T | undefined {
    return this.items.find((item) => item.id === id);
  }

  // ----- 3.3 按任意属性查找 -----
  // K extends keyof T：K 只能是 T 的键名
  // T[K]：value 的类型必须和属性对应——传 "name" 必须配 string，传 "price" 必须配 number
  findBy<K extends keyof T>(key: K, value: T[K]): T[] {
    return this.items.filter((item) => item[key] === value);
  }

  // ----- 3.4 按 ID 删除 -----
  // 返回 boolean 表示是否成功删除
  remove(id: number): boolean {
    const index = this.items.findIndex((item) => item.id === id);
    if (index === -1) return false;
    this.items.splice(index, 1);
    return true;
  }

  // ----- 3.5 按 ID 更新（部分更新）-----
  // Partial<T>：changes 里只需要传要修改的字段
  // 这得益于映射类型：Partial<T> 把所有属性变成可选
  update(id: number, changes: Partial<T>): T | undefined {
    const item = this.findById(id);
    if (!item) return undefined;

    // 用 Object.assign 把 changes 合并到原对象上
    // Partial<T> 保证了 changes 里每个字段的类型都正确
    const updatedItem = Object.assign(item, changes);
    return updatedItem;
  }

  // ----- 3.6 获取所有记录 -----
  getAll(): T[] {
    return [...this.items]; // 返回副本，防止外部直接修改内部数组
  }

  // ----- 3.7 获取记录总数 -----
  get count(): number {
    return this.items.length;
  }
}

// -------------------- 4. 测试：User 仓库 --------------------
console.log("========== 用户仓库测试 ==========");

const userRepo = new Repository<User>();

// 添加用户
userRepo.add({ id: 1, name: "张三", email: "zhangsan@test.com", age: 25 });
userRepo.add({ id: 2, name: "李四", email: "lisi@test.com", age: 30 });
userRepo.add({ id: 3, name: "王五", email: "wangwu@test.com", age: 28 });

console.log("所有用户:", userRepo.getAll());

// 按 ID 查找
const user = userRepo.findById(2);
console.log("ID=2 的用户:", user);

// 按属性查找：K extends keyof User，value: T[K]
// 编译器保证 key 和 value 类型匹配
const usersByAge = userRepo.findBy("age", 28);
console.log("25 岁的用户:", usersByAge);

// 类型安全：下面这行会编译报错
// userRepo.findBy("age", "28");     // 错误！age 是 number，"28" 是 string
// userRepo.findBy("nickname", "");  // 错误！nickname 不是 User 的属性

// 更新部分字段：Partial<User>，只需传要改的
const updated = userRepo.update(1, { name: "张三丰", age: 26 });
console.log("更新后用户 1:", updated);

// 删除
const removed = userRepo.remove(3);
console.log("删除 id=3:", removed ? "成功" : "失败");
console.log("删除后所有用户:", userRepo.getAll());
console.log("用户总数:", userRepo.count);

// -------------------- 5. 测试：Product 仓库 --------------------
console.log("\n========== 商品仓库测试 ==========");

const productRepo = new Repository<Product>();

productRepo.add({ id: 101, name: "机械键盘", price: 399, category: "电脑外设" });
productRepo.add({ id: 102, name: "蓝牙耳机", price: 299, category: "音频设备" });
productRepo.add({ id: 103, name: "无线鼠标", price: 149, category: "电脑外设" });

// 按 category 查找所有电脑外设
const peripherals = productRepo.findBy("category", "电脑外设");
console.log('分类为"电脑外设"的商品:', peripherals);

// 更新价格
productRepo.update(101, { price: 359 });
console.log("降价后:", productRepo.findById(101));

// 类型安全的查找
const cheapProducts = productRepo.findBy("price", 149);
console.log("价格为 149 的商品:", cheapProducts);

// Product 仓库不能用 User 的字段来查
// productRepo.findBy("age", 25); // 编译错误！Product 没有 age

// -------------------- 6. 测试：Task 仓库 --------------------
console.log("\n========== 任务仓库测试 ==========");

const taskRepo = new Repository<Task>();

taskRepo.add({ id: 1, title: "完成 TypeScript 学习", completed: false, priority: "high" });
taskRepo.add({ id: 2, title: "写周报", completed: false, priority: "medium" });
taskRepo.add({ id: 3, title: "浇花", completed: true, priority: "low" });

// 查找所有未完成任务
const uncompleted = taskRepo.findBy("completed", false);
console.log("未完成任务:", uncompleted.map((t) => t.title));

// 按优先级查找
const highPriority = taskRepo.findBy("priority", "high");
console.log("高优先级任务:", highPriority.map((t) => t.title));

// 完成一条任务——只改 completed，不改其他字段
taskRepo.update(1, { completed: true });
console.log("完成任务 1 后:", taskRepo.findById(1));

// 删除已完成任务
taskRepo.remove(3);
console.log("删除浇花任务后剩余:", taskRepo.getAll().map((t) => `${t.title} (${t.completed ? "已完成" : "未完成"})`));

// -------------------- 7. 跨仓库类型安全演示 --------------------
console.log("\n========== 跨仓库类型安全 ==========");

// 你不能往 User 仓库里塞 Product
// userRepo.add({ id: 4, name: "手机", price: 999 }); // 编译错误！缺少 email 和 age

// 你也不能把 User 类型的变量传到 Product 仓库
// productRepo.add(userRepo.findById(1)!); // 编译错误！User 不满足 Product 的约束

// 每个仓库严格管控自己的类型，这就是泛型的威力
const allUsers = userRepo.getAll();
const allProducts = productRepo.getAll();

console.log("用户仓库有", userRepo.count, "条记录");
console.log("商品仓库有", productRepo.count, "条记录");
console.log("任务仓库有", taskRepo.count, "条记录");

// -------------------- 8. 知识点回顾 --------------------
// 本示例涵盖了全部 7 节的知识：
//
// 第 1 节：泛型函数 —— Repository 内部的 filter、find 等方法使用了泛型
// 第 2 节：泛型约束 —— T extends Identifiable，K extends keyof T
// 第 3 节：泛型类 —— class Repository<T>
// 第 4 节：类型守卫 —— findById 内部其实有隐式守卫（返回值 T | undefined）
// 第 5 节：交叉类型 —— Item extends Identifiable 可视为交叉的约束
// 第 6 节：keyof + 索引访问 —— findBy<K extends keyof T>(key: K, value: T[K])
// 第 7 节：映射类型 —— update(id, changes: Partial<T>)

// ============================================================
// 动手试试答案：请参考上面 Task 仓库的测试代码
// ============================================================
