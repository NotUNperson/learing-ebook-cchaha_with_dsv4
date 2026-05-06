# 05 交叉类型

## 本节你会学到什么

- 理解交叉类型 `&`：把多个类型"拼"在一起，得到一个拥有所有属性的大类型
- 区分交叉类型 `&` 和联合类型 `|`——一个要"全都有"，一个要"满足其一"即可
- 用交叉类型组合多个接口，像搭积木一样构建复杂类型
- 理解属性冲突时 `&` 的行为
- 结合 C++ 的多重继承做对比

## 正文

### 生活类比：拼图

想象你面前有两张透明塑料片。一张上面画着圆形（代表"有半径"），另一张上面画着颜色（代表"有颜色"）。你把这两张塑料片叠在一起，透过两层看——你看到了一个**既有半径又有颜色**的图案。

这就是交叉类型 `&`。它把两个类型"叠加"成一个新类型，新类型**同时拥有**两个原类型的所有属性。

### 联合类型回顾

先快速回顾下联合类型 `|`。之前学过，`A | B` 表示"要么是 A，要么是 B"：

```typescript
type StringOrNumber = string | number;

let value: StringOrNumber;
value = "hello"; // OK
value = 42;      // OK
// 但你不能调用 value.toFixed()，因为 value 可能是 string
```

联合是"或"的关系。就像你去便利店，可以付现金**或者**扫码，二选一。

### 交叉类型：要"全都有"

交叉类型 `A & B` 表示"既是 A，又是 B"。必须同时满足两边的要求：

```typescript
type Person = { name: string };
type Employee = { employeeId: number; department: string };

// Person & Employee：必须同时有 name、employeeId 和 department
type EmployeePerson = Person & Employee;

const ep: EmployeePerson = {
  name: "张三",
  employeeId: 1001,
  department: "技术部",
}; // 三个属性缺一不可
```

就像拼图：一块拼图上有"姓名"这块碎片，另一块上有"工号"这块碎片，拼在一起才能看到完整的员工信息。

### 更形象的类比：应聘条件

你去应聘一家公司。JD（岗位描述）上写着：

1. 必须会写代码（`{ canCode: boolean }`）
2. 必须会英语（`{ englishLevel: string }`）

这两条要求就是两个类型。你这个人必须**同时满足**两条，才能拿到 offer。用 TypeScript 表示：

```typescript
type Coder = { canCode: boolean };
type EnglishSpeaker = { englishLevel: string };

type IdealCandidate = Coder & EnglishSpeaker;

const you: IdealCandidate = {
  canCode: true,
  englishLevel: "CET-6",
};
```

### 交叉类型在实际中的威力

交叉类型最常见的使用场景是**组合多个接口**，构建出越来越丰富的数据结构：

```typescript
interface Timestamped {
  createdAt: Date;
  updatedAt: Date;
}

interface SoftDeletable {
  isDeleted: boolean;
  deletedAt?: Date;
}

// 基础用户数据
interface UserData {
  id: number;
  name: string;
  email: string;
}

// 完整的数据库用户——把三块拼在一起
type FullUser = UserData & Timestamped & SoftDeletable;
// 新类型有：id, name, email, createdAt, updatedAt, isDeleted, deletedAt
```

这就好像乐高积木。你有三块积木——用户数据块、时间戳块、软删除块——把它们拼在一起就得到一个完整的"数据库用户"模型。哪天你不需要软删除了，把 `SoftDeletable` 拆掉就行，不影响其他积木。

### 属性冲突怎么办？

如果两个类型有同名但不同类型的属性，交叉后会怎样？

```typescript
type A = { value: string };
type B = { value: number };

// A & B 的 value 是 string & number
// string & number 不存在——这是一个 never 类型
type C = A & B;

// 你永远没法给 value 赋值，因为一个值不能同时是 string 又 number
```

对于基本类型的属性冲突，结果是 `never`（不可达类型）。但如果是复杂类型的冲突，可能会产生更微妙的结果。一般在实际项目中应当避免这种冲突，它通常意味着你的类型设计有问题。

### 交叉类型和接口继承的区别

这两种写法在很多时候结果一样，但出发点不同：

```typescript
// 写法 1：接口继承
interface Employee extends Person, HasSalary {}

// 写法 2：交叉类型
type Employee = Person & HasSalary;
```

**区别：**
- `interface extends` 可以做声明合并（同一个 interface 声明多次会合并），`type &` 不能
- 如果有属性冲突，`interface extends` 会直接报错，而交叉类型的错误可能更隐晦
- 对于匿名/临时类型组合，用 `&` 更方便；对于语义明确的实体，用 `extends` 更清晰

### 和 C++ 的对比

C++ 里最接近交叉类型的是多重继承：

```cpp
class Flyable {
public:
    void fly() { /* ... */ }
};

class Swimmable {
public:
    void swim() { /* ... */ }
};

// 多重继承：Duck 同时拥有 Flyable 和 Swimmable 的能力
class Duck : public Flyable, public Swimmable {};
```

**相同点：** 都是把多个"组件"组合成一个拥有全部功能的大类型。

**不同点：**
- C++ 多重继承组合的是**行为**（方法实现），TS 交叉类型组合的是**结构**（属性形状）
- C++ 多继承有著名的"菱形继承"问题（同一基类被继承两次），TS 交叉类型不存在这个问题——它只是类型层面的叠加
- TS 交叉类型是纯编译期概念，不生成运行时代码；C++ 继承会产生真实的 vtable 和内存布局
- C++ 没有联合类型的直接对应（`std::variant` 是最接近的，但更笨重），而 TS 的交叉和联合是类型系统的两大支柱，天然对称

## 动手试试

1. 定义三个接口：`CanWalk { walk(): string }`、`CanSwim { swim(): string }`、`CanFly { fly(): string }`
2. 用交叉类型创建一个 `SuperAnimal` 类型，同时拥有三种能力
3. 实现一个 `SuperAnimal` 对象（"超级鸭"），调用三个方法，打印各自返回的字符串
4. 试试定义一个 `type Mixed = string & number`，并尝试给它的变量赋值，看编译器报什么错

答案参考 `examples/05-intersection-types.ts`。

## 本节小结

交叉类型 `&` 像透明塑料片的叠加——把所有属性叠在一起，得到一个"什么都有"的新类型，是 TypeScript 里搭建复杂类型最基础的"乐高积木"。

## 下一节预告

有了交叉类型可以把类型拼在一起，但如果想从对象类型里"提取"出键名或值类型呢？下一节学 `keyof` 和索引访问类型。
