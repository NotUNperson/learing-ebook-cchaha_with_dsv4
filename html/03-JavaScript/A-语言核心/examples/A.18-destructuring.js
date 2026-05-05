// ============================================================
// A.18 解构与展开 示例代码
// 运行方式：node examples/A.18-destructuring.js
// ============================================================

console.log("========== A.18 解构与展开 ==========\n");

// ----------------------------------------------------------
// 1. 数组解构——按位置对应，一行"拆"出多个变量
// ----------------------------------------------------------
console.log("1. 数组解构：");

const colors = ["红", "绿", "蓝"];

// 传统方式：逐个索引访问
const r1 = colors[0];
const g1 = colors[1];
const b1 = colors[2];
console.log(`  传统方式: ${r1}, ${g1}, ${b1}`);

// 解构方式：一行搞定
const [r2, g2, b2] = colors;
console.log(`  解构方式: ${r2}, ${g2}, ${b2}`);

// ----------------------------------------------------------
// 2. 跳过元素、默认值、交换变量
// ----------------------------------------------------------
console.log("\n2. 跳过、默认值、交换：");

// 跳过中间元素——用空位
const [first, , third] = [10, 20, 30];
console.log(`  跳过中间: first=${first}, third=${third}`);  // 10, 30

// 默认值——取不到就用备选
const [x = 0, y = 0, z = 0] = [5];
console.log(`  默认值: x=${x}, y=${y}, z=${z}`);  // 5, 0, 0

// 交换变量——不需要临时变量！
let a = 1;
let b = 2;
console.log(`  交换前: a=${a}, b=${b}`);
[a, b] = [b, a];  // 右边创建临时数组，左边解构赋值
console.log(`  交换后: a=${a}, b=${b}`);

// ----------------------------------------------------------
// 3. 对象解构——按属性名对应
// ----------------------------------------------------------
console.log("\n3. 对象解构：");

const user = {
    name: "张三",
    age: 20,
    city: "北京",
    job: "学生",
};

// 从对象中"抽取"需要的属性
const { name, age } = user;
console.log(`  解构出: name=${name}, age=${age}`);
// city 和 job 没有被抽取，就忽略了

// 重命名——解构时换个变量名
const { name: userName, city: userCity } = user;
console.log(`  重命名: userName=${userName}, userCity=${userCity}`);
// console.log(name);  // 会报错！冒号左边是原名，右边是新变量名

// ----------------------------------------------------------
// 4. 对象解构默认值
// ----------------------------------------------------------
console.log("\n4. 对象解构默认值：");

// 对象中没有的属性，可以用默认值
const { score = 60, grade = "A" } = { score: 85 };
console.log(`  score=${score}（有值用值）, grade=${grade}（没值用默认）`);

// 默认值也适用于函数参数——非常实用的模式
function printUser({ name = "匿名", age = 0 } = {}) {
    console.log(`  用户: ${name}, ${age} 岁`);
}
printUser({ name: "李四", age: 25 });  // 正常传参
printUser({ name: "王五" });           // 不传 age，用默认值
printUser({});                          // 全用默认值

// ----------------------------------------------------------
// 5. 嵌套解构——深层结构的抽取
// ----------------------------------------------------------
console.log("\n5. 嵌套解构：");

const school = {
    name: "第一中学",
    location: {
        city: "北京",
        district: "海淀区",
        address: {
            street: "中关村大街",
            number: 100,
        },
    },
};

// 解构出深层属性
const {
    name: schoolName,
    location: {
        city,
        address: { street, number },
    },
} = school;

console.log(`  校名: ${schoolName}`);
console.log(`  城市: ${city}`);
console.log(`  街道: ${street} ${number} 号`);
// 注意：location 和 address 不会被创建为独立变量！

// ----------------------------------------------------------
// 6. 展开运算符 ... ——把数组/对象"摊开"
// ----------------------------------------------------------
console.log("\n6. 展开运算符：");

// 6.1 数组展开——合并、插入、拷贝
const arr1 = [1, 2, 3];
const arr2 = [4, 5, 6];

// 合并
const merged = [...arr1, ...arr2];
console.log(`  合并: [${merged}]`);  // [1,2,3,4,5,6]

// 在任意位置插入
const inserted = [0, ...arr1, 99, 100];
console.log(`  插入: [${inserted}]`); // [0,1,2,3,99,100]

// 浅拷贝
const copy = [...arr1];
copy[0] = 999;
console.log(`  原数组: [${arr1}], 拷贝: [${copy}]`);  // 拷贝独立

// 展开在函数调用中的应用——把数组元素作为独立参数
const nums = [3, 1, 4, 1, 5, 9];
console.log(`  最大值: ${Math.max(...nums)}`);  // 等价于 Math.max(3,1,4,1,5,9)

// 6.2 对象展开——基于旧对象创建新对象
const baseSettings = {
    theme: "light",
    fontSize: 14,
    showLineNumbers: true,
};

// 在 base 基础上覆盖个别属性
const userSettings = {
    ...baseSettings,
    theme: "dark",        // 覆盖 theme
    fontSize: 16,         // 覆盖 fontSize
    // showLineNumbers 保留原值
};
console.log("  基础设置:", baseSettings);
console.log("  用户设置:", userSettings);

// 对象展开是浅拷贝的证明
const original = {
    name: "test",
    data: { x: 1, y: 2 },  // data 是嵌套对象
};
const shallow = { ...original };
shallow.data.x = 999;  // 修改浅拷贝中嵌套对象的值
console.log(`  original.data.x = ${original.data.x}`); // 999，原对象也被影响了！
console.log("  （嵌套对象是引用，浅拷贝不递归复制）");

// ----------------------------------------------------------
// 7. 剩余模式 ...rest ——把剩下的收拢起来
// ----------------------------------------------------------
console.log("\n7. 剩余模式：");

// 数组剩余——取前两个，剩下的全装进 rest
const [head, ...tail] = [1, 2, 3, 4, 5];
console.log(`  head=${head}, tail=[${tail}]`);  // head=1, tail=[2,3,4,5]

// 对象剩余——取出 name，剩下的属性打包
const { name: n, ...rest } = { name: "赵六", age: 30, city: "上海", job: "经理" };
console.log(`  name=${n}, rest=`, rest);  // rest = { age: 30, city: '上海', job: '经理' }

// 剩余模式在函数参数中的应用——收集多余参数
function logAll(tag, ...messages) {
    console.log(`  [${tag}]`, messages.join(" | "));
}
logAll("INFO", "服务器启动", "端口 3000", "环境 production");
// tag = "INFO", messages = ["服务器启动", "端口 3000", "环境 production"]

console.log("\n========== 解构与展开 演示结束 ==========");
