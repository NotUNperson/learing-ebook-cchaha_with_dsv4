/**
 * 09-student-system.ts
 * 主题：综合练习——学生成绩管理系统
 *
 * 本文件综合运用前八节学到的所有知识：
 * - 函数签名（参数类型 + 返回值类型）
 * - 可选参数、默认参数、剩余参数
 * - 箭头函数
 * - 函数重载（简单示例）
 * - 类的基本语法、构造函数、this、访问修饰符
 * - 构造函数参数属性（简写）、readonly
 * - interface 接口定义对象形状
 * - interface 的嵌套、扩展
 *
 * 设计理念：
 * - interface 描述"数据实体"（Student、ScoreRecord）
 * - class 封装"业务逻辑"（Course、GradeSystem）
 * - 函数处理"计算和转换"
 */

// ==================== 数据接口定义 ====================

/**
 * 学生接口
 * 使用 interface 而不是 type，因为 Student 是一个"实体"概念
 * readonly id：学号创建后不可修改
 */
interface Student {
    readonly id: string;     // 学号——唯一标识，readonly
    name: string;            // 姓名
    age: number;             // 年龄
    grade: string;           // 班级，如 "高三(1)班"
    contact?: string;        // 可选属性：联系方式（电话或邮箱）
}

/**
 * 成绩记录接口
 * 描述一个学生在某门课程中的成绩
 */
interface ScoreRecord {
    studentId: string;       // 学生 ID
    courseName: string;      // 课程名称
    score: number;           // 分数，范围 0-100
}

/**
 * 课程统计接口
 * 描述一门课程的整体成绩状况
 */
interface CourseStats {
    courseName: string;      // 课程名
    average: number;         // 平均分
    highest: number;         // 最高分
    lowest: number;          // 最低分
    passRate: number;        // 及格率（百分比，0-100）
}

/**
 * 排名条目接口
 * 用于排名列表中的数据项
 */
interface RankEntry {
    name: string;            // 学生姓名
    average: number;         // 加权平均分
}


// ==================== Course 类 ====================

/**
 * 课程类
 * 管理课程的基本信息、选课学生、成绩录入和统计
 *
 * 应用的知识点：
 * - 构造函数参数属性（public readonly name, public readonly credit）
 * - 剩余参数（addStudents 方法）
 * - 箭头函数（getStats 中的 reduce、filter、map）
 * - private 成员（students 和 scores 不对外暴露）
 */
class Course {
    // 选课学生的 ID 列表（private：外部不能直接修改）
    private students: string[] = [];

    // 成绩记录列表（private：外部不能直接修改）
    private scores: ScoreRecord[] = [];

    /**
     * 构造函数
     * 使用参数属性简写：
     * - public readonly name：课程名，外部可读但不可改
     * - public readonly credit：学分，默认 2 学分
     */
    constructor(
        public readonly name: string,
        public readonly credit: number = 2
    ) {
        // 空函数体——参数属性已自动完成声明和赋值
    }

    /**
     * 批量添加选课学生
     * 使用剩余参数（...studentIds）接收任意数量的学生 ID
     * 演示了剩余参数在实际项目中的应用
     */
    addStudents(...studentIds: string[]): void {
        for (const id of studentIds) {
            // 避免重复添加
            if (!this.students.includes(id)) {
                this.students.push(id);
                console.log(`  学生 ${id} 已加入课程「${this.name}」`);
            }
        }
    }

    /**
     * 录入/更新学生的成绩
     * @param studentId 学生 ID
     * @param score 分数（0-100）
     * @returns 是否成功录入
     *
     * 演示了：参数类型标注、返回值类型标注、安全检查
     */
    setScore(studentId: string, score: number): boolean {
        // 检查学生是否选修了本课程
        if (!this.students.includes(studentId)) {
            console.log(`  错误：学生 ${studentId} 未选修课程「${this.name}」`);
            return false;
        }

        // 检查分数范围
        if (score < 0 || score > 100) {
            console.log(`  错误：分数 ${score} 不在 0-100 范围内`);
            return false;
        }

        // 查找是否已有成绩记录（支持覆盖）
        const existingIndex = this.scores.findIndex(
            s => s.studentId === studentId
        );

        const record: ScoreRecord = {
            studentId,
            courseName: this.name,
            score
        };

        if (existingIndex >= 0) {
            // 更新已有成绩
            this.scores[existingIndex] = record;
            console.log(`  更新：学生 ${studentId} 在「${this.name}」的成绩为 ${score} 分`);
        } else {
            // 添加新成绩
            this.scores.push(record);
            console.log(`  录入：学生 ${studentId} 在「${this.name}」获得 ${score} 分`);
        }

        return true;
    }

    /**
     * 获取某学生在本课程的成绩
     * @returns 分数（number）或 undefined（未录入或未选课）
     *
     * 使用箭头函数 find 查找成绩记录
     * 使用可选链 ?. 安全访问可能不存在的属性
     */
    getStudentScore(studentId: string): number | undefined {
        const record = this.scores.find(s => s.studentId === studentId);
        return record?.score;  // 可选链：record 存在则返回 score，否则返回 undefined
    }

    /**
     * 获取课程成绩统计
     * @returns CourseStats 对象
     *
     * 演示了箭头函数在数组操作中的链式使用：
     * map → filter → reduce，一条龙处理
     */
    getStats(): CourseStats {
        // 提取所有成绩值
        const allScores = this.scores.map(s => s.score);

        // 如果还没有成绩，返回零值统计
        if (allScores.length === 0) {
            return {
                courseName: this.name,
                average: 0,
                highest: 0,
                lowest: 0,
                passRate: 0
            };
        }

        // 使用箭头函数进行各项计算
        // reduce 累加求总和
        const total = allScores.reduce((sum, s) => sum + s, 0);
        // 使用扩展运算符传入 Math.max/Min
        const average = total / allScores.length;
        const highest = Math.max(...allScores);
        const lowest = Math.min(...allScores);
        // filter 筛选及格成绩，计算及格率
        const passCount = allScores.filter(s => s >= 60).length;
        const passRate = (passCount / allScores.length) * 100;

        return {
            courseName: this.name,
            average: Math.round(average * 100) / 100,   // 保留两位小数
            highest,
            lowest,
            passRate: Math.round(passRate * 100) / 100
        };
    }

    /**
     * 获取选课学生数量
     */
    getStudentCount(): number {
        return this.students.length;
    }

    /**
     * 获取已有成绩的学生数量
     */
    getScoredCount(): number {
        return this.scores.length;
    }
}


// ==================== GradeSystem 类 ====================

/**
 * 成绩管理系统主控类
 *
 * 管理所有学生和课程的中央控制器，
 * 对外提供统一的接口来操作整个系统。
 *
 * 应用的知识点：
 * - private 成员封装内部状态（外界不能直接操作 Map）
 * - JavaScript 原生 Map 用于高效查找
 * - 箭头函数用于排序和转换
 */
class GradeSystem {
    // 学生字典：key = 学号，value = 学生对象
    // 使用 Map 而不是普通对象，因为 Map 在频繁增删时性能更好
    private students: Map<string, Student> = new Map();

    // 课程字典：key = 课程名，value = Course 实例
    private courses: Map<string, Course> = new Map();

    /**
     * 添加学生
     * 如果学号已存在则覆盖（更新信息）
     */
    addStudent(student: Student): void {
        const isNew = !this.students.has(student.id);
        this.students.set(student.id, student);
        if (isNew) {
            console.log(`添加学生：${student.name}（${student.id}）`);
        } else {
            console.log(`更新学生：${student.name}（${student.id}）`);
        }
    }

    /**
     * 添加课程到系统
     */
    addCourse(course: Course): void {
        this.courses.set(course.name, course);
        console.log(`添加课程：${course.name}（${course.credit} 学分）`);
    }

    /**
     * 获取某个学生
     */
    getStudent(studentId: string): Student | undefined {
        return this.students.get(studentId);
    }

    /**
     * 获取某门课程
     */
    getCourse(courseName: string): Course | undefined {
        return this.courses.get(courseName);
    }

    /**
     * 计算学生的加权平均分（按学分加权）
     *
     * 加权平均分的计算方式：
     * 每门课的成绩乘以该课程的学分，总和除以总学分
     *
     * 例如：数学（4学分）92分，英语（3学分）88分
     * 加权平均 = (92*4 + 88*3) / (4+3) = 90.3
     *
     * @param studentId 学生 ID
     * @returns 加权平均分（0-100）
     */
    getWeightedAverage(studentId: string): number {
        let totalWeightedScore = 0;  // 成绩乘以学分的总和
        let totalCredit = 0;         // 总学分

        // 遍历所有课程
        for (const course of this.courses.values()) {
            const score = course.getStudentScore(studentId);
            if (score !== undefined) {
                // 该生在这门课有成绩
                totalWeightedScore += score * course.credit;
                totalCredit += course.credit;
            }
        }

        // 如果一门课的成绩都没有，返回 0
        if (totalCredit === 0) return 0;

        // 四舍五入到两位小数
        return Math.round((totalWeightedScore / totalCredit) * 100) / 100;
    }

    /**
     * 学生成绩排名
     * 按加权平均分降序排列（分数高的在前面）
     *
     * @returns 排名列表，第一名在索引 0
     *
     * 演示了箭头函数用于排序：
     * b.average - a.average 实现降序（大的在前）
     */
    rankStudents(): RankEntry[] {
        const rankings: RankEntry[] = [];

        // 遍历所有学生，计算他们的加权平均分
        for (const student of this.students.values()) {
            const average = this.getWeightedAverage(student.id);
            rankings.push({ name: student.name, average });
        }

        // 使用箭头函数排序——简洁直观
        // b.average - a.average > 0 则 b 排在 a 前面（降序）
        rankings.sort((a, b) => b.average - a.average);

        return rankings;
    }

    /**
     * 查找加权平均分最高的学生
     * 使用 reduce 一行完成查找
     *
     * 演示了箭头函数 + reduce 的高阶用法：
     * 不是求和，而是"找到最大值"
     */
    findTopStudent(): RankEntry | null {
        const rankings = this.rankStudents();
        if (rankings.length === 0) return null;
        return rankings[0];  // 已排序，第一个就是最高的
    }

    /**
     * 生成学生的完整成绩报告
     *
     * @param studentId 学生 ID
     * @returns 格式化的成绩报告字符串
     *
     * 演示了：模板字符串、可选链、条件表达式
     */
    getStudentReport(studentId: string): string {
        const student = this.students.get(studentId);
        if (!student) {
            return `错误：未找到学号为 ${studentId} 的学生`;
        }

        // 计算排名
        const rankings = this.rankStudents();
        const rankIndex = rankings.findIndex(r => r.name === student.name);
        const rank = rankIndex >= 0 ? rankIndex + 1 : -1;

        // 构建报告
        let report = "";
        report += `========================================\n`;
        report += `  学生成绩报告\n`;
        report += `========================================\n`;
        report += `姓名：${student.name}\n`;
        report += `学号：${student.id}\n`;
        report += `班级：${student.grade}\n`;
        if (student.contact) {
            report += `联系方式：${student.contact}\n`;
        }
        report += `----------------------------------------\n`;
        report += `各科成绩：\n`;

        // 列出所有课程的成绩
        for (const course of this.courses.values()) {
            const score = course.getStudentScore(studentId);
            if (score !== undefined) {
                const status = score >= 90 ? "优秀" :
                               score >= 80 ? "良好" :
                               score >= 70 ? "中等" :
                               score >= 60 ? "及格" : "不及格";
                report += `  ${course.name}：${score} 分（${status}，${course.credit} 学分）\n`;
            }
        }

        report += `----------------------------------------\n`;
        const average = this.getWeightedAverage(studentId);
        report += `加权平均分：${average.toFixed(1)}\n`;
        report += `班级排名：第 ${rank} 名（共 ${rankings.length} 人）\n`;
        report += `========================================\n`;

        return report;
    }

    /**
     * 生成系统总览报告
     * 包括所有课程统计和排名
     */
    getSystemOverview(): string {
        let overview = "";
        overview += `\n`;
        overview += `############################################\n`;
        overview += `#       学生成绩管理系统 —— 总览报告        #\n`;
        overview += `############################################\n\n`;

        // 各课程统计
        overview += `--- 课程统计 ---\n`;
        for (const course of this.courses.values()) {
            const stats = course.getStats();
            overview += `${stats.courseName}（${course.credit} 学分）：\n`;
            overview += `  选课人数：${course.getStudentCount()}，`;
            overview += `已录入成绩：${course.getScoredCount()} 人\n`;
            overview += `  平均分：${stats.average.toFixed(1)}，`;
            overview += `最高分：${stats.highest}，`;
            overview += `最低分：${stats.lowest}，`;
            overview += `及格率：${stats.passRate.toFixed(1)}%\n\n`;
        }

        // 学生排名
        overview += `--- 学生排名（加权平均分）---\n`;
        const rankings = this.rankStudents();
        rankings.forEach((entry, index) => {
            const medal = index === 0 ? " [金牌]" :
                          index === 1 ? " [银牌]" :
                          index === 2 ? " [铜牌]" : "";
            overview += `第 ${index + 1} 名：${entry.name}，`;
            overview += `加权平均分：${entry.average.toFixed(1)}${medal}\n`;
        });

        return overview;
    }
}


// ==================== 主程序：演示系统运行 ====================

console.log("======= 学生成绩管理系统 =======\n");

// 1. 创建系统实例
const system = new GradeSystem();

// 2. 添加学生
console.log("--- 添加学生 ---");
system.addStudent({
    id: "S001",
    name: "张三",
    age: 18,
    grade: "高三(1)班",
    contact: "zhangsan@school.edu"
});
system.addStudent({
    id: "S002",
    name: "李四",
    age: 17,
    grade: "高三(1)班",
    contact: "13812345678"
});
system.addStudent({
    id: "S003",
    name: "王五",
    age: 18,
    grade: "高三(2)班"
    // contact 可选，故意不填
});
system.addStudent({
    id: "S004",
    name: "赵六",
    age: 17,
    grade: "高三(2)班"
});

// 3. 添加课程
console.log("\n--- 添加课程 ---");
const math = new Course("数学", 4);      // 主科，4 学分
const english = new Course("英语", 3);   // 主科，3 学分
const physics = new Course("物理", 3);   // 理科，3 学分
const chinese = new Course("语文", 4);   // 主科，4 学分

system.addCourse(math);
system.addCourse(english);
system.addCourse(physics);
system.addCourse(chinese);

// 4. 学生选课（使用剩余参数批量操作）
console.log("\n--- 学生选课 ---");
console.log("数学课：");
math.addStudents("S001", "S002", "S003", "S004");  // 所有人选数学

console.log("英语课：");
english.addStudents("S001", "S002", "S003");       // 前三人选英语

console.log("物理课：");
physics.addStudents("S001", "S003", "S004");       // 理科生选物理

console.log("语文课：");
chinese.addStudents("S001", "S002", "S004");       // 除王五外选语文

// 5. 录入成绩
console.log("\n--- 录入成绩 ---");

// 数学成绩
math.setScore("S001", 92);
math.setScore("S002", 78);
math.setScore("S003", 85);
math.setScore("S004", 45);  // 不及格

// 英语成绩
english.setScore("S001", 88);
english.setScore("S002", 65);
english.setScore("S003", 91);

// 物理成绩
physics.setScore("S001", 95);
physics.setScore("S003", 72);
physics.setScore("S004", 60);

// 语文成绩
chinese.setScore("S001", 83);
chinese.setScore("S002", 90);
chinese.setScore("S004", 55);  // 不及格

// 6. 输出系统总览
console.log(system.getSystemOverview());

// 7. 输出个别学生的详细报告
console.log("\n" + system.getStudentReport("S001"));
console.log(system.getStudentReport("S002"));
console.log(system.getStudentReport("S004"));

// 8. 找出第一名
const topStudent = system.findTopStudent();
if (topStudent) {
    console.log(`\n全班第一名：${topStudent.name}，加权平均分：${topStudent.average.toFixed(1)}`);
}

// 9. 测试成绩更新（覆盖原有成绩）
console.log("\n--- 成绩更新 ---");
math.setScore("S004", 70);  // 赵六数学从 45 变成 70（补考通过）
console.log(`更新后赵六的数学成绩：${math.getStudentScore("S004")} 分`);

// 10. 测试错误情况
console.log("\n--- 错误测试 ---");
math.setScore("S999", 80);   // 学生未选课
english.setScore("S001", 150); // 分数超出范围

// 11. 课程统计演示
console.log("\n--- 课程统计 ---");
const mathStats = math.getStats();
console.log(`数学（${math.credit} 学分）：平均 ${mathStats.average.toFixed(1)}，最高 ${mathStats.highest}，最低 ${mathStats.lowest}，及格率 ${mathStats.passRate.toFixed(1)}%`);

const englishStats = english.getStats();
console.log(`英语（${english.credit} 学分）：平均 ${englishStats.average.toFixed(1)}，最高 ${englishStats.highest}，最低 ${englishStats.lowest}，及格率 ${englishStats.passRate.toFixed(1)}%`);

console.log("\n======= 系统演示结束 =======");
