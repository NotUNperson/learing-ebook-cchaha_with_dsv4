# 02 strict 模式：给你的代码系上"安全带"

## 本节你会学到什么

- 理解 TypeScript 的 strict 模式为什么是"代码世界的安全带"
- 逐个认识 strict 模式下的 7 个子选项，重点掌握 strictNullChecks、noImplicitAny、strictFunctionTypes
- 能解释每个子选项阻止了哪一类常见 bug
- 学会在看懂 strict 报错后如何正确修复，而不是简单地"关掉它"
- 养成"新项目必开 strict"的习惯

## 正文

### 1. 安全带的故事

你有没有听过这样的话："我不系安全带，反正我开车很小心。"听起来有道理吗？统计告诉我们：绝大多数车祸都不是司机"不小心"造成的，而是被别人的失误、天气、路况等不可控因素波及。安全带的意义在于：它不会帮你避免车祸，但能在车祸发生时大幅降低伤害。

TypeScript 的 strict 模式就是代码世界的安全带。你可能会想："我写代码很小心啊，类型都标注了，不可能出 bug。"但实际项目中的 bug 往往不是"你没写类型"，而是"你以为某个变量一定有值，但它偏偏是 null"；或者"你以为你已经检查了所有分支，但漏了一个 case"。strict 模式不会阻止你写出有逻辑错误的代码，但它会在编译时就拦住那些"一眼就能看出来不对劲"的危险操作。

开启 strict 非常简单——在 tsconfig.json 里加一行：

```json
{
  "compilerOptions": {
    "strict": true
  }
}
```

这一行等于同时开启了 7 个独立的检查开关。我们逐个来看。

### 2. strictNullChecks：null 和 undefined 的"禁入令"

这是 strict 模式中最重要、最能减少 bug 的子选项。

```typescript
// strictNullChecks 关闭时的行为：
let name: string;
name = null;        // 完全不报错！
name = "张三";
console.log(name.length);  // 这行没问题

name = null;
console.log(name.length);  // 运行时爆炸！TypeError: Cannot read property 'length' of null
```

这段代码在没有 strictNullChecks 的情况下编译通过，运行时却报错了。把 null 赋值给一个 string 类型的变量——这本身就说不通。null 不是字符串，就好比你不能说"我的年龄是'没有'"。

开启 strictNullChecks 后：

```typescript
let name: string;
name = null;  // 编译错误！Type 'null' is not assignable to type 'string'.

// 正确的做法：如果你真的想让 name 可能为 null，必须明确声明
let name: string | null = null;  // 显式告诉 TypeScript："name 可能是 null"
if (name !== null) {
  console.log(name.length);  // 安全了！TypeScript 知道这里 name 一定不是 null
}
```

你可以把 strictNullChecks 理解为：TypeScript 强制你在"可能为空"的表达式中做一个"安全检查"。这就好比进入工地必须戴安全帽——你知道头顶上可能掉东西下来，所以才要保护自己。

### 3. noImplicitAny：不许偷懒不做类型标注

如果你不写类型标注，TypeScript 有时会"帮"你推断为 `any` 类型。any 就像一个万能插座——什么都能插，但随时可能短路。

```typescript
// noImplicitAny 关闭时的行为：
function greet(name) {   // 没写类型标注，name 被暗中推断为 any
  console.log("你好，" + name.toUpperCase());
}

greet(42);  // 编译不报错！运行时：name.toUpperCase is not a function
```

TypeScript 的设计初衷是帮你做类型检查，但如果函数参数偷偷被推断成 `any`，类型检查就形同虚设了。就像你请了一个保安，但他对所有进门的陌生人都说"请进"——这个保安形同虚设。

开启 noImplicitAny 后：

```typescript
function greet(name) {  // 编译错误！Parameter 'name' implicitly has an 'any' type.
  console.log("你好，" + name.toUpperCase());
}

// 必须明确标注类型
function greet(name: string) {
  console.log("你好，" + name.toUpperCase());
}
```

### 4. strictFunctionTypes：函数类型的"防伪标识"

这个选项检查函数参数类型的兼容性，防止你用"看起来很像但实际不兼容"的函数来赋值。这个概念稍微抽象，我们用一个比喻：

假设你家门口贴了一张招工启事："招聘清洁工，要求会用吸尘器"。有人来应聘，他说："我什么都会用——吸尘器、电钻、挖掘机、核磁共振仪"。你会觉得他"超出要求"了，似乎没问题。但如果反过来——你招聘一个"什么都会用的人"，结果找来的工人只会用吸尘器，那你就不能让他去操作挖掘机了。

在 TypeScript 里：

```typescript
// 一个处理"所有动物"的方法（包括狗）
type AnimalHandler = (animal: { name: string }) => void;

// 一个只处理"狗"的方法
type DogHandler = (dog: { name: string; breed: string }) => void;

// strictFunctionTypes 开启时，以下赋值会报错：
const handler: AnimalHandler = function(animal: { name: string }) {
  console.log(animal.name);
};

// 如果你把 DogHandler 赋值给 AnimalHandler，参数方向是"反的"
const dogHandler: DogHandler = function(dog: { name: string; breed: string }) {
  console.log(dog.breed);
};
const animalHandler: AnimalHandler = dogHandler;
// 错误！DogHandler 需要 breed 属性，但 AnimalHandler 调用时不一定提供
```

这个检查阻止了一种经典的反变位置类型安全问题。

### 5. 其他四个子选项速览

strict 模式还包含这四个检查项，每一个都是"精准打击某一类 bug"：

| 子选项 | 它阻止什么 | 类比 |
|--------|-----------|------|
| `strictBindCallApply` | 检查 `.bind()`、`.call()`、`.apply()` 的参数类型是否正确 | 你打电话叫外卖，不能把"送餐地址"填成"电话号码" |
| `strictPropertyInitialization` | 类的属性必须在构造函数中初始化，不能"悬空" | 买房子必须要有门牌号，不能是"待定" |
| `noImplicitThis` | 禁止隐式 any 类型的 this | 你不能在街上随便拉个人就说"你欠我钱"，你得先确认他是谁 |
| `alwaysStrict` | 生成的 JS 代码自动加上 `"use strict"` | 自动帮你锁门，不需要每次手动检查 |

### 6. 这些检查之间有关联吗？

是的。它们共同构建了一个"防御网"。举个例子：如果你关了 strictNullChecks 但开着 noImplicitAny，你仍然可能把 null 传进一个明确标注了 string 参数的函数。每个子选项守护的是不同类型检查的一个侧门，只有全部打开，防御网才是完整的。

这就是为什么 TypeScript 官方推荐直接设置 `"strict": true`，而不是挑着开。单个子选项就像单只手套——防了一只手，另一只照样会受伤。

### 7. 已有项目遇到 strict 报错怎么办？

如果你在一个旧项目上开启 strict，可能会看到几十甚至几百个报错。别慌，也别急着关掉 strict。正确的做法是：

1. 逐个子选项开启——先开 `noImplicitAny`，修完报错；再开 `strictNullChecks`，修完报错
2. 修复而不是 suppress——尽量修复代码逻辑，而不是加 `// @ts-ignore` 或者 `as any`
3. 如果某个文件实在改不动，用 `tsconfig.json` 的 `exclude` 先把它排除出去，等有空再修

记住：每次你用 `as any` 绕过一个 strict 检查，就相当于你把安全带解开了"一小会儿"——出问题的时候，这一小会儿可能就是事故发生的那一瞬。

## 动手试试

打开 `examples/02-strict-mode.ts`，里面有一段"关闭 strict 也能编译通过但运行会崩溃"的代码。请完成以下步骤：

1. 先在不开启 strict 的模式下编译运行，观察是否报错
2. 在 `tsconfig.json` 中设置 `"strict": true`，重新编译，观察哪些地方被 strict 拦住了
3. 修复所有被 strict 检查暴露出来的问题，让代码既通过编译，又不会在运行时崩溃

提示：`examples/02-strict-mode.ts` 故意设计了几个常见的"温和 bug"——函数参数没写类型、可能为 null 的值没有检查、对象属性没初始化。看看你能否全部找出来并修复。

## 本节小结

strict 模式就像安全带：它不能保证你不出事故，但能在事故发生前（编译时）就拦住那些"一眼就能看出来的危险操作"——关闭它省的不是时间，是省掉了你发现 bug 的机会。

## 下一节预告

学会了 tsconfig 的基本配置和 strict 模式，接下来我们要解决一个工程化中的"审美灾难"——深不见底的 `../../../` 路径地狱，用路径别名来还你一片清爽。
