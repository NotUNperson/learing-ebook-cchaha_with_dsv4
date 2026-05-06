# 09 综合练习：学生成绩管理系统

## 本节你会学到什么

- 综合运用函数、类、接口构建一个小型管理系统
- 设计接口描述数据实体（Student、Course），用类实现业务逻辑
- 将选项参数、默认参数、剩余参数等特性融入实际场景
- 体会 TypeScript 类型系统如何在中等规模代码中发挥作用
- 培养"先设计类型，再写实现"的思维方式

## 正文

### 把学过的知识串起来

前面八节我们分别学了函数签名、参数变体、箭头函数、重载、类、参数属性、接口、type vs interface。每一节都是独立的"零件"，这节我们把零件组装起来，看看它们如何协同工作。

我们要做的系统很简单但五脏俱全：**一个学生成绩管理系统**，能添加学生、添加课程、录入成绩、计算总分和平均分、按成绩排名。

### 设计阶段：先想清楚"什么是什么"

在写代码之前，我们先想清楚这个系统里有哪些"东西"：

**1. 学生（Student）** —— 一个数据实体，不需要复杂的行为。用 interface 最合适。

```typescript
interface Student {
    readonly id: string;      // 学号——唯一且不可变
    name: string;             // 姓名
    age: number;              // 年龄
    grade: string;            // 班级
}
```

**2. 课程（Course）** —— 有自己的数据（课程名、学分），也有行为（添加学生、录入成绩）。用 class 最合适。

**3. 成绩记录** —— 一个学生在一门课中的成绩，用 interface 描述。

**4. 成绩管理系统（GradeSystem）** —— 管理所有学生、课程和成绩的核心类。

### 实现阶段：零件组装

**第一步：定义数据接口**

```typescript
// 成绩记录
interface ScoreRecord {
    studentId: string;
    courseName: string;
    score: number;  // 0-100
}

// 课程成绩汇总
interface CourseStats {
    courseName: string;
    average: number;
    highest: number;
    lowest: number;
    passRate: number;  // 及格率
}
```

**第二步：实现 Course 类**

Course 类需要管理课程基本信息、注册学生、录入成绩、计算统计。这里我们用上构造函数参数属性的简写：

```typescript
class Course {
    private students: string[] = [];        // 选课学生 ID 列表
    private scores: ScoreRecord[] = [];     // 成绩记录列表

    constructor(
        public readonly name: string,       // 课程名（readonly——创建后不可改）
        public readonly credit: number = 2  // 学分（默认 2 学分）
    ) {}

    // 剩余参数的实战应用：一次添加多个学生
    addStudents(...studentIds: string[]): void {
        for (const id of studentIds) {
            if (!this.students.includes(id)) {
                this.students.push(id);
            }
        }
    }

    // 录入成绩
    setScore(studentId: string, score: number): boolean {
        if (!this.students.includes(studentId)) {
            console.log(`学生 ${studentId} 未选修本课程`);
            return false;
        }
        if (score < 0 || score > 100) {
            console.log("成绩必须在 0-100 之间");
            return false;
        }

        // 如果已有成绩则更新，否则添加
        const existingIndex = this.scores.findIndex(s => s.studentId === studentId);
        const record: ScoreRecord = {
            studentId,
            courseName: this.name,
            score
        };

        if (existingIndex >= 0) {
            this.scores[existingIndex] = record;
        } else {
            this.scores.push(record);
        }
        return true;
    }

    // 计算课程统计——返回类型用之前定义的 CourseStats 接口
    getStats(): CourseStats {
        const allScores = this.scores.map(s => s.score);
        if (allScores.length === 0) {
            return {
                courseName: this.name,
                average: 0,
                highest: 0,
                lowest: 0,
                passRate: 0
            };
        }

        const total = allScores.reduce((sum, s) => sum + s, 0);
        const average = total / allScores.length;
        const highest = Math.max(...allScores);
        const lowest = Math.min(...allScores);
        const passCount = allScores.filter(s => s >= 60).length;
        const passRate = (passCount / allScores.length) * 100;

        return { courseName: this.name, average, highest, lowest, passRate };
    }

    // 获取学生在该课程的成绩
    getStudentScore(studentId: string): number | undefined {
        const record = this.scores.find(s => s.studentId === studentId);
        return record?.score;
    }
}
```

**第三步：实现 GradeSystem 主控类**

这个类管理学生和课程，提供统一的对外接口。

```typescript
class GradeSystem {
    private students: Map<string, Student> = new Map();
    private courses: Map<string, Course> = new Map();

    // 添加学生
    addStudent(student: Student): void {
        this.students.set(student.id, student);
    }

    // 添加课程
    addCourse(course: Course): void {
        this.courses.set(course.name, course);
    }

    // 获取学生的加权平均分（按学分加权）
    getWeightedAverage(studentId: string): number {
        let totalWeighted = 0;
        let totalCredit = 0;

        for (const course of this.courses.values()) {
            const score = course.getStudentScore(studentId);
            if (score !== undefined) {
                totalWeighted += score * course.credit;
                totalCredit += course.credit;
            }
        }

        return totalCredit > 0 ? totalWeighted / totalCredit : 0;
    }

    // 排名：按加权平均分降序排列
    rankStudents(): { name: string; average: number }[] {
        const rankings: { name: string; average: number }[] = [];

        for (const student of this.students.values()) {
            rankings.push({
                name: student.name,
                average: this.getWeightedAverage(student.id)
            });
        }

        // 用箭头函数排序——简洁直观
        rankings.sort((a, b) => b.average - a.average);
        return rankings;
    }
}
```

### 看看最终效果

把所有组件组合在一起：

```typescript
const system = new GradeSystem();

// 添加学生
system.addStudent({ id: "S001", name: "张三", age: 18, grade: "高三(1)班" });
system.addStudent({ id: "S002", name: "李四", age: 17, grade: "高三(1)班" });
system.addStudent({ id: "S003", name: "王五", age: 18, grade: "高三(2)班" });

// 添加课程
const math = new Course("数学", 4);
const english = new Course("英语", 3);
system.addCourse(math);
system.addCourse(english);

// 学生选课——用剩余参数一次添加多个
math.addStudents("S001", "S002", "S003");
english.addStudents("S001", "S002");

// 录入成绩
math.setScore("S001", 92);
math.setScore("S002", 78);
math.setScore("S003", 85);
english.setScore("S001", 88);
english.setScore("S002", 65);

// 查看排名
console.log("\n=== 成绩排名 ===");
const rank = system.rankStudents();
rank.forEach((item, index) => {
    console.log(`第 ${index + 1} 名：${item.name}，加权平均分：${item.average.toFixed(1)}`);
});
```

### 这个系统传递了什么学习信号？

这个例子虽小，但有几点值得注意：

1. **interface 描述数据，class 实现逻辑** —— 这是来自 C++ 的典型思维方式（struct + class），但在 TypeScript 中 interface 变成了纯类型层面的概念
2. **类型驱动开发** —— 先把 Student、ScoreRecord 这些接口定义好，再去写实现，代码结构更清晰
3. **小而美的组合** —— 每个类只做一件事（Course 管课程成绩，GradeSystem 管全局），组合起来却功能完整
4. **TypeScript 的底层仍是 JavaScript** —— Map、箭头函数这些来自 JavaScript 的工具在 TypeScript 里依然能用

## 动手试试

在示例代码的基础上，增加以下功能：

1. 添加一个新的 `Student` 属性 `contact?: string`（可选的联系方式），修改 interface
2. 给 `GradeSystem` 添加一个方法 `getStudentReport(studentId: string): string`，返回格式化的成绩报告（学生姓名、班级、各科成绩、加权平均分、排名）
3. 添加一门新课（比如"物理"，3 学分），给所有学生录入成绩，重新排名
4. 挑战：写一个 `findTopStudent` 方法，返回加权平均分最高的学生的 name 和 average（用箭头函数 + reduce）

## 本节小结

接口定义数据结构，类封装业务逻辑，函数处理计算——三者分工明确又紧密协作，这正是 TypeScript 面向对象编程的核心模式。

## 下一节预告

恭喜完成"函数与面向对象"章节！接下来你可以继续探索 TypeScript 的高级类型（泛型、条件类型、映射类型），或者开始用学到的知识写一个小项目——比如一个 Todo 应用或图书管理系统。
