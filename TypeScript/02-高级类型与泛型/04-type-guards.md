# 04 类型守卫

## 本节你会学到什么

- 理解"类型收窄"是什么：让 TypeScript 在特定代码块中"更精确地"知道变量类型
- 掌握 `typeof` 守卫：区分 string、number、boolean 等基本类型
- 掌握 `instanceof` 守卫：区分不同类的实例
- 学会写自定义类型谓词函数（返回值是 `x is SomeType`）
- 用 `in` 操作符判断属性是否存在，从而区分类型

## 正文

你走在路上看到一个包裹，你不知道里面是什么——可能是书，可能是衣服，也可能是零食。你拿起来掂一掂，听一听，如果是书，你知道它一定有页数；如果是衣服，你知道它一定有尺码。打开一看，确认是书，你就知道该怎么处理了：可以翻页，可以当枕头。

TypeScript 的类型防护就像是这个"判断-确认-处理"的过程。TypeScript 的变量有时是"联合类型"（比如 `string | number`），当你要调用一个只有其中一种类型才有的方法时，你必须先确认它"当前到底是什么类型"。这个确认的过程叫做**类型收窄**（narrowing），用来确认的代码就叫做**类型守卫**（type guard）。

### 类比：火车站闸机

火车站进站，闸机前的检票员看一眼你的身份证，确认"嗯，这是个成年人"（类型收窄），然后放行。不同的人群通过不同通道：成年人走普通闸机，带孩子的走人工通道，VIP 走贵宾通道。

TypeScript 里不同的"通道"就是代码的分支（`if/else`）。类型守卫帮助 TypeScript 确定每个分支里变量的确切类型。

### typeof 类型守卫

`typeof` 是最简单的类型守卫，用于区分 JavaScript 的基本类型：

```typescript
function processValue(value: string | number): string {
  if (typeof value === "string") {
    // 在这个 if 块里，TS 知道 value 一定是 string
    return value.toUpperCase();   // string 的方法，没问题
  } else {
    // 在这个 else 块里，TS 知道 value 一定是 number
    return value.toFixed(2);      // number 的方法，没问题
  }
}
```

进入 `if` 分支后，TypeScript 自动把 `value` 的类型从 `string | number` 收窄为 `string`。进入 `else` 分支后，再收窄为 `number`。

能用 `typeof` 区分的有：`"string"`、`"number"`、`"bigint"`、`"boolean"`、`"symbol"`、`"undefined"`、`"object"`、`"function"`。注意 `typeof null` 返回 `"object"`，这是一个历史遗留问题，TypeScript 对此有特殊处理。

### instanceof 类型守卫

当你要区分两个不同的**类**时，用 `instanceof`：

```typescript
class Cat {
  meow() { console.log("喵~"); }
}

class Dog {
  bark() { console.log("汪!"); }
}

function handlePet(pet: Cat | Dog): void {
  if (pet instanceof Cat) {
    pet.meow();   // TS 知道这里是 Cat
  } else {
    pet.bark();   // TS 知道这里是 Dog
  }
}
```

`instanceof` 检查的是原型链——"这个对象是由哪个构造函数创建的"。就像你发现一个动物的脚印是梅花状的，就能判断它是猫科动物。

### 自定义类型谓词：`x is SomeType`

`typeof` 和 `instanceof` 只能区分基本类型和类。当你要区分两个**接口**（interface）或**类型别名**（type alias）时，它们就不够用了——因为接口在运行时根本不存在，编译成 JavaScript 后什么都没有。

这时你需要自定义类型守卫。写法很特别：函数的返回值类型写成 `parameterName is SomeType`：

```typescript
interface Bird {
  fly(): void;
  wingspan: number;
}

interface Fish {
  swim(): void;
  gills: boolean;
}

// 关键：返回值类型是 "animal is Bird"
function isBird(animal: Bird | Fish): animal is Bird {
  // 运行时检查：只有 Bird 有 wingspan 属性
  return (animal as Bird).wingspan !== undefined;
}

function interact(animal: Bird | Fish): void {
  if (isBird(animal)) {
    // 这里 TS 知道 animal 是 Bird
    console.log(`翅膀展开有 ${animal.wingspan} 米`);
    animal.fly();
  } else {
    // 这里 TS 知道 animal 是 Fish
    animal.swim();
  }
}
```

`animal is Bird` 告诉 TypeScript："如果这个函数返回 `true`，那么传入的参数就是 `Bird` 类型"。这就像你拿出一张试纸检测水质，试纸变红，你就知道水里含有某种物质。

### in 操作符：检查属性是否存在

对于两个只差一两个属性的类型，可以直接用 `in`：

```typescript
type Circle = { radius: number; kind: "circle" };
type Rectangle = { width: number; height: number; kind: "rectangle" };

function getArea(shape: Circle | Rectangle): number {
  if ("radius" in shape) {
    // 只有 Circle 有 radius
    return Math.PI * shape.radius ** 2;
  } else {
    // 只有 Rectangle 有 width 和 height
    return shape.width * shape.height;
  }
}
```

### 为什么不直接用 any 然后暴力判断？

你可以这样写：

```typescript
function badApproach(value: any): void {
  if (typeof value === "string") { /* ... */ }
}
```

但用 `any` 意味着放弃了类型检查。万一你在 `if` 外面写了 `value.fly()`，编译器不会报错，但运行时可能崩溃。类型守卫让你在**保持类型安全**的前提下做运行时判断。

### 和 C++ 的对比

C++ 里类似的机制是 `dynamic_cast`（运行时类型转换）和 `typeid`：

```cpp
class Animal { virtual ~Animal() {} };
class Cat : public Animal { void meow() {} };

void handle(Animal* a) {
    if (Cat* c = dynamic_cast<Cat*>(a)) {
        c->meow();
    }
}
```

**相同点：** 都是通过运行时判断来确定实际类型，然后安全调用特定类型的方法。

**不同点：**
- C++ 的多态依赖**继承**（虚函数、RTTI），TS 的类型守卫基于**结构类型**（有没有某个属性/方法），不需要类继承
- C++ 的 `dynamic_cast` 只在运行时生效，TS 的类型守卫**同时在编译期和运行时都生效**——编译器会根据守卫结果收窄类型
- TypeScript 的类型谓词（`x is Type`）是纯编译期的概念，在输出的 JS 中函数签名是普通的 `boolean` 返回值，而 C++ 没有这种编译期"声明式"的类型收窄

## 动手试试

1. 定义一个联合类型 `type Shape = { kind: "circle"; radius: number } | { kind: "rectangle"; width: number; height: number }`
2. 写一个函数 `getArea(shape: Shape): number`，用 `kind` 属性作为类型守卫来计算面积
3. 分别传入 `{ kind: "circle", radius: 5 }` 和 `{ kind: "rectangle", width: 4, height: 6 }`，确认面积计算正确
4. 试试把 `kind` 改成其他值（如 `"triangle"`），看看 TypeScript 是否报错

答案参考 `examples/04-type-guards.ts`。

## 本节小结

类型守卫让你在运行时"问"TypeScript"这个东西现在到底是什么"，然后编译器帮你跟踪类型变化，就像火车站闸机根据票种引导你走正确的通道。

## 下一节预告

类型不仅可以判断和收窄，还可以组合。下一节我们学习交叉类型 `&`，把多个类型拼成一个更大的类型。
