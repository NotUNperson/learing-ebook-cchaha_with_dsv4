// ============================================================
// A.17 对象操作 示例代码
// 运行方式：node examples/A.17-object-ops.js
// ============================================================

console.log("========== A.17 对象操作 ==========\n");

// ----------------------------------------------------------
// 1. 属性的增删改查（CRUD）
// ----------------------------------------------------------
console.log("1. 属性的增删改查：");

const obj = { name: "张三", age: 20 };
console.log("  初始对象:", obj);

// 增——属性不存在就创建
obj.job = "学生";
console.log("  添加 job 后:", obj);  // { name: '张三', age: 20, job: '学生' }

// 改——属性存在就覆盖
obj.name = "李四";
console.log("  修改 name 后:", obj);  // { name: '李四', age: 20, job: '学生' }

// 查——点号和方括号
console.log("  查询 name:", obj.name);
console.log("  查询 age:", obj["age"]);

// 删——delete 运算符
delete obj.age;
console.log("  删除 age 后:", obj);  // { name: '李四', job: '学生' }

// ----------------------------------------------------------
// 2. 判断属性是否存在——in vs hasOwnProperty
// ----------------------------------------------------------
console.log("\n2. 判断属性是否存在：");

const user = { name: "王五", score: undefined };
console.log("  对象:", user);

// in 运算符：检查自身 + 原型链
console.log('  "name" in user:', "name" in user);       // true
console.log('  "score" in user:', "score" in user);     // true（属性存在，值是 undefined）
console.log('  "height" in user:', "height" in user);   // false

// hasOwnProperty：只检查自身属性（不查原型链）
console.log('  user.hasOwnProperty("name"):', user.hasOwnProperty("name"));   // true
console.log('  user.hasOwnProperty("score"):', user.hasOwnProperty("score")); // true

// 陷阱：不能只靠"值与 undefined 比较"来判断属性是否存在
console.log("  score !== undefined:", user.score !== undefined);  // false！
// 虽然 false 但属性确实存在——值是 undefined 不等于属性不存在

// 最佳实践：用 in 或 hasOwnProperty
if ("score" in user) {
    console.log("  user 有 score 属性，值是:", user.score);
}

// ----------------------------------------------------------
// 3. Object.keys() / Object.values() / Object.entries()
// ----------------------------------------------------------
console.log("\n3. Object.keys/values/entries：");

const employee = {
    name: "赵六",
    position: "工程师",
    salary: 15000,
};

console.log("  对象:", employee);

// Object.keys() ——获取所有键（返回数组）
const keys = Object.keys(employee);
console.log("  keys():", keys);            // ["name", "position", "salary"]

// Object.values() ——获取所有值（返回数组）
const values = Object.values(employee);
console.log("  values():", values);        // ["赵六", "工程师", 15000]

// Object.entries() ——获取键值对数组（二维数组）
const entries = Object.entries(employee);
console.log("  entries():", entries);
// [["name","赵六"], ["position","工程师"], ["salary",15000]]

// entries 配合 for...of 和解构——遍历对象最优雅的方式
console.log("  遍历输出：");
for (const [key, value] of Object.entries(employee)) {
    console.log(`    ${key} => ${value}`);
}

// 常见应用：将对象转为可过滤、可映射的数组
const allKeys = Object.keys(employee)
    .filter(k => k !== "salary")   // 过滤掉 salary 键
    .map(k => k.toUpperCase());     // 转为大写
console.log("  过滤+映射后的键:", allKeys);  // ["NAME", "POSITION"]

// ----------------------------------------------------------
// 4. 可选链（Optional Chaining） ?.
// ----------------------------------------------------------
console.log("\n4. 可选链 ?.：");

// 场景：一个嵌套很深的对象，但某些层可能不存在
const data1 = {
    user: {
        profile: {
            city: "北京",
        },
    },
};

const data2 = {
    user: null,  // user 这一层就不存在（没用有意义的值）
};

// 传统方式：层层检查，又臭又长
function getCityOld(data) {
    if (data && data.user && data.user.profile && data.user.profile.city) {
        return data.user.profile.city;
    }
    return "未知";
}

// 可选链方式：一行搞定
function getCityNew(data) {
    return data?.user?.profile?.city ?? "未知";
}

console.log("  完整数据：");
console.log("    老办法:", getCityOld(data1));   // "北京"
console.log("    可选链:", getCityNew(data1));   // "北京"

console.log("  残缺数据（user 层为 null）：");
console.log("    老办法:", getCityOld(data2));   // "未知"
console.log("    可选链:", getCityNew(data2));   // "未知"，没有报错！

// 可选链用于方法调用
const obj1 = { greet() { return "你好"; } };
const obj2 = {};  // 没有 greet 方法

console.log('  obj1?.greet?.():', obj1?.greet?.());  // "你好"
console.log('  obj2?.greet?.():', obj2?.greet?.());  // undefined，不报错！

// 可选链用于数组索引
const arr = [10, 20, 30];
console.log("  arr?.[1]:", arr?.[1]);    // 20
console.log("  arr?.[99]:", arr?.[99]);  // undefined，不报错

// ----------------------------------------------------------
// 5. 计算属性名 [表达式]
// ----------------------------------------------------------
console.log("\n5. 计算属性名：");

const prefix = "user_";
const id = 42;

const userData = {
    [prefix + id]: "张三",               // 属性名 = "user_42"
    [prefix + "name"]: "李四",           // 属性名 = "user_name"
    [`${prefix}score_${id}`]: 95,        // 属性名 = "user_score_42"
    [id > 10 ? "adult" : "child"]: true, // 属性名 = "adult"
};

console.log("  对象:", userData);
console.log("  user_42:", userData.user_42);       // "张三"
console.log("  user_name:", userData.user_name);   // "李四"
console.log("  user_score_42:", userData.user_score_42); // 95
console.log("  adult:", userData.adult);           // true

// 使用场景：把一系列动态键值装入对象
function makeCache() {
    const cache = {};
    return {
        set(key, value) {
            cache[key] = value;  // 动态属性赋值
        },
        get(key) {
            return cache[key];
        },
    };
}

const cache = makeCache();
cache.set("page:home", "<html>...</html>");
cache.set("page:about", "<html>...</html>");
console.log('  cache.get("page:home"):', cache.get("page:home"));

console.log("\n========== 对象操作 演示结束 ==========");
