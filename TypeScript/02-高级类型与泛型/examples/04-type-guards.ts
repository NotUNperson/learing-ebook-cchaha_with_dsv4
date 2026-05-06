// ============================================================
// 04 类型守卫 — 示例代码
// 演示 typeof、instanceof、自定义类型谓词、in 操作符
// ============================================================

// -------------------- 1. typeof 类型守卫 --------------------
// 最基础的类型守卫，用于区分 JS 的原始类型
function processValue(value: string | number): string {
  if (typeof value === "string") {
    // TS 自动收窄：在这个 if 块里，value 一定是 string
    return value.toUpperCase(); // 调用 string 专有方法
  } else {
    // 在这个 else 块里，value 一定是 number
    return value.toFixed(2); // 调用 number 专有方法
  }
}

console.log("处理字符串:", processValue("hello"));   // "HELLO"
console.log("处理数字:", processValue(3.14159));     // "3.14"

// typeof 还常用来处理可选参数
function greet(name?: string): string {
  if (typeof name === "undefined") {
    return "你好，陌生人！";
  }
  return `你好，${name}！`;
}

console.log(greet());           // "你好，陌生人！"
console.log(greet("小明"));     // "你好，小明！"

// 注意：typeof 能区分的类型有限
// "string" | "number" | "bigint" | "boolean" | "symbol" | "undefined" | "object" | "function"

// -------------------- 2. instanceof 类型守卫 --------------------
// 用于判断一个对象是否是某个类的实例（检查原型链）
class Cat {
  name: string;
  constructor(name: string) {
    this.name = name;
  }
  meow(): string {
    return `${this.name}: 喵~喵~`;
  }
  scratch(): string {
    return `${this.name} 在挠沙发`;
  }
}

class Dog {
  name: string;
  constructor(name: string) {
    this.name = name;
  }
  bark(): string {
    return `${this.name}: 汪!汪!`;
  }
  fetch(): string {
    return `${this.name} 捡回了球`;
  }
}

// 宠物可能是猫也可能是狗
type Pet = Cat | Dog;

function interactWithPet(pet: Pet): string {
  if (pet instanceof Cat) {
    // TS 收窄为 Cat，可以安全调用 Cat 的方法
    return pet.meow();
  } else {
    // TS 收窄为 Dog，可以安全调用 Dog 的方法
    return pet.bark();
  }
}

const tom = new Cat("Tom");
const spike = new Dog("Spike");

console.log("\n--- 宠物互动 ---");
console.log(interactWithPet(tom));    // "Tom: 喵~喵~"
console.log(interactWithPet(spike));  // "Spike: 汪!汪!"

// -------------------- 3. in 操作符：检查属性是否存在 --------------------
// 区分两个类型别名（interface/type），它们在运行时不存在
// 所以不能用 instanceof，但可以用 in 检查属性

type Circle = {
  kind: "circle";   // 字面量类型，帮助区分
  radius: number;
};

type Rectangle = {
  kind: "rectangle"; // 字面量类型，帮助区分
  width: number;
  height: number;
};

type Triangle = {
  kind: "triangle";
  base: number;
  height: number;
};

type Shape = Circle | Rectangle | Triangle;

// 方式 A：用 "radius" 或 "width" 属性来区分
function getAreaWithIn(shape: Shape): number {
  if ("radius" in shape) {
    // 只有 Circle 有 radius
    return Math.PI * shape.radius ** 2;
  } else if ("width" in shape) {
    // Rectangle 有 width（Triangle 没有）
    return shape.width * shape.height;
  } else {
    // 剩下的只能是 Triangle
    return (shape.base * shape.height) / 2;
  }
}

// 方式 B：用 kind 属性（可辨识联合，discriminated union）——更推荐
function getArea(shape: Shape): number {
  switch (shape.kind) {
    case "circle":
      return Math.PI * shape.radius ** 2;
    case "rectangle":
      return shape.width * shape.height;
    case "triangle":
      return (shape.base * shape.height) / 2;
    // 不需要 default——如果以后有人加了新 shape，没有 case 的话 TS 会报错
  }
}

const myCircle: Circle = { kind: "circle", radius: 5 };
const myRect: Rectangle = { kind: "rectangle", width: 4, height: 6 };
const myTri: Triangle = { kind: "triangle", base: 3, height: 4 };

console.log("\n--- 形状面积 ---");
console.log("圆的面积:", getArea(myCircle).toFixed(2));      // 78.54
console.log("矩形面积:", getArea(myRect));                    // 24
console.log("三角形面积:", getArea(myTri));                   // 6

// -------------------- 4. 自定义类型谓词：x is SomeType --------------------
// 当类型不是 class 时，instanceof 没法用
// 自定义类型守卫函数可以解决这个问题

interface Bird {
  fly(): string;
  wingspan: number; // 翼展（米）
}

interface Fish {
  swim(): string;
  gills: boolean;   // 是否有鳃
}

type Animal = Bird | Fish;

// 类型谓词返回值：animal is Bird
// 告诉 TS："如果这个函数返回 true，那么 animal 就是 Bird 类型"
function isBird(animal: Animal): animal is Bird {
  // 运行时检查：只有 Bird 有 wingspan 属性
  return "wingspan" in animal;
}

function interact(animal: Animal): void {
  if (isBird(animal)) {
    // TS 把 animal 收窄为 Bird
    console.log(`一只翼展 ${animal.wingspan} 米的鸟在${animal.fly()}`);
  } else {
    // TS 把 animal 收窄为 Fish
    console.log(`一条${animal.gills ? "有鳃" : "无鳃"}的鱼在${animal.swim()}`);
  }
}

const eagle: Bird = {
  wingspan: 2.3,
  fly() { return "翱翔天际"; },
};

const shark: Fish = {
  gills: true,
  swim() { return "深海遨游"; },
};

console.log("\n--- 动物互动 ---");
interact(eagle); // 一只翼展 2.3 米的鸟在翱翔天际
interact(shark); // 一条有鳃的鱼在深海遨游

// -------------------- 5. 类型谓词的陷阱 --------------------
// 自定义类型谓词给你权力，也给你责任——你必须保证运行时判断是正确的！
// 如果写错了，TS 不会帮你检查

// ❌ 错误示例（不要这样写）：
// function isFish(animal: Animal): animal is Fish {
//   return true; // 总是返回 true——TS 不会阻止，但这显然是错的
// }

// ✅ 正确做法：
function isFish(animal: Animal): animal is Fish {
  // 用 Fish 独有的属性来区分
  return "gills" in animal;
}

// -------------------- 6. 对比 C++ --------------------
// C++ 使用 dynamic_cast + 虚函数：
//
// class Animal { virtual ~Animal() = default; };
// class Cat : public Animal { void meow() {} };
// void handle(Animal* a) {
//   if (Cat* c = dynamic_cast<Cat*>(a)) { c->meow(); }
// }
//
// 相同点：运行时判断实际类型
// 不同点：
//   - C++ 依赖继承体系（虚函数 + RTTI）
//   - TS 基于结构类型（有某个属性就行，不需要类继承）
//   - TS 的类型谓词同时在编译期和运行时生效，C++ 的 dynamic_cast 只影响运行时

// ============================================================
// 动手试试答案：
//   type Shape = ... （如上）
//   function getArea(shape: Shape): number {
//     switch (shape.kind) { ... }  // 用 kind 做可辨识联合
//   }
// ============================================================
