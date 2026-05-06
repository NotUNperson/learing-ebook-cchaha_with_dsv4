// ============================================================
// 02-strict-mode.ts —— strict 模式的"温和 bug"练习文件
// ============================================================
// 下面这些代码在不开启 strict 时可以编译通过，但运行时可能出错。
// 你的任务：开启 strict 后，修复所有被 strict 检查暴露出来的问题。

// ---- 练习 1：未标注类型的参数（noImplicitAny） ----
// 缺陷：参数 age 没有类型标注，编译器可能推断为 any
function isAdult(age) {
  return age >= 18;
}

// 这行调用完全不报错——但 string >= number 在 JS 里比较的结果很奇怪
console.log(isAdult("二十岁")); // 期望报错但没报

// ---- 练习 2：null 被悄悄传给了 string 类型的位置（strictNullChecks） ----
function getLastName(fullName: string): string {
  // 假设我们"期望" fullName 永远不为空
  const parts = fullName.split(" ");
  return parts[parts.length - 1];
}

// 调用方传了 null，运行时这里会崩溃：
// TypeError: Cannot read property 'split' of null
const maybeNull: string | null = Math.random() > 0.5 ? "张三 三" : null;
// 去掉下面这行的注释来复现 bug：
// console.log(getLastName(maybeNull));

// ---- 练习 3：类属性未初始化（strictPropertyInitialization） ----
class Student {
  name: string;   // 这个属性从来没有被赋值！在 strict 下会直接报错
  age: number;

  constructor(n: string, a: number) {
    // 故意"忘了"赋值。在 strict 下编译会报错：
    // Property 'name' has no initializer and is not definitely assigned in the constructor.
  }
}

const s = new Student("小明", 18);
console.log(s.name.toUpperCase()); // 运行时可能会出错

// ---- 练习 4：@ts-ignore 的反面教材 ----
// 下面的代码有类型错误，但注释压制了检查（你在实际项目中应该尽量少用）
function addNumbers(a: number, b: number): number {
  return a + b;
}

// @ts-ignore —— 这行应该报错，但被忽略了
// console.log(addNumbers("1", "2")); // 传入字符串!

// ---- 练习 5：综合——不安全的函数回调（strictFunctionTypes） ----
interface Pet {
  name: string;
}

interface Dog extends Pet {
  breed: string; // 狗有品种
}

// 一个期望处理"所有宠物"的函数
function walkPet(pet: Pet): void {
  console.log(`正在遛 ${pet.name}`);
}

// 一个只能处理"狗"的函数（它需要 breed 信息）
function walkDog(dog: Dog): void {
  console.log(`正在遛 ${dog.name}（品种：${dog.breed}）`);
}

// 如果把 walkDog 赋值给一个期望 walkPet 类型的变量——会有类型安全问题
// （在 strictFunctionTypes 开启时会报错）
let walker: (pet: Pet) => void;
// walker = walkDog;  // 这行在 strictFunctionTypes 下会报错

export {};
