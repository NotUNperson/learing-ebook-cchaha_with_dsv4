// ============================================================
// A.23 Set 与 Map 示例代码
// 运行方式：node examples/A.23-set-map.js
// ============================================================

console.log("========== A.23 Set 与 Map ==========\n");

// ----------------------------------------------------------
// 1. Set 基本操作——自动去重的集合
// ----------------------------------------------------------
console.log("1. Set 基本操作：");

const set = new Set();

// add——添加元素，返回 Set 自身（支持链式调用）
set.add(1).add(2).add(2).add(3);  // 第二个 2 被自动忽略
console.log("  set:", set);            // Set { 1, 2, 3 }
console.log("  set.size:", set.size);  // 3（不是 4！）

// has——判断元素是否存在
console.log("  has(2):", set.has(2));   // true
console.log("  has(5):", set.has(5));   // false

// delete——删除元素，返回 boolean
console.log("  delete(2):", set.delete(2)); // true（删除成功）
console.log("  delete(5):", set.delete(5)); // false（5 不存在）
console.log("  删除后:", set);            // Set { 1, 3 }

// clear——清空
const temp = new Set([1, 2, 3]);
temp.clear();
console.log("  clear 后:", temp, "size:", temp.size); // Set {} 0

// ----------------------------------------------------------
// 2. Set 的创建与遍历
// ----------------------------------------------------------
console.log("\n2. Set 创建与遍历：");

// 从数组创建 Set
const fruits = new Set(["苹果", "香蕉", "橘子", "香蕉"]); // 重复"香蕉"被去重
console.log("  fruits:", fruits);

// for...of 遍历
console.log("  for...of 遍历：");
for (const fruit of fruits) {
    console.log(`    - ${fruit}`);
}

// forEach 遍历（注意：Set 的 key 和 value 相同）
console.log("  forEach 遍历：");
fruits.forEach((value, alsoValue, theSet) => {
    console.log(`    value=${value}, alsoValue=${alsoValue}`); // 两个参数值相同
});

// 转回数组
const fruitArray = [...fruits];
console.log("  转回数组:", fruitArray);

// ----------------------------------------------------------
// 3. Set 实用场景——数组去重
// ----------------------------------------------------------
console.log("\n3. Set 去重：");

const numbers = [1, 2, 2, 3, 3, 3, 4, 5, 5];
const unique = [...new Set(numbers)];
console.log("  原数组:", numbers);
console.log("  去重后:", unique);  // [1, 2, 3, 4, 5]

// Set 也可以用于字符串去重
const word = "hello world";
const uniqueChars = [...new Set(word)].join("");
console.log(`  字符串去重: "${word}" -> "${uniqueChars}"`);

// ----------------------------------------------------------
// 4. Map 基本操作——键可以是任意类型
// ----------------------------------------------------------
console.log("\n4. Map 基本操作：");

const map = new Map();

// set(key, value)——设置键值对，返回 Map 自身（支持链式调用）
map.set("name", "张三");
map.set(1, "数字1");
map.set("1", "字符串1");  // 不覆盖！1 和 "1" 是不同的键
map.set(true, "布尔值");

// 关键特性：用对象作为键！
const objKey = { id: 1 };
map.set(objKey, "用对象作为键的值");

console.log("  map.size:", map.size);           // 5

// get(key)——获取值
console.log('  get("name"):', map.get("name")); // "张三"
console.log("  get(1):", map.get(1));           // "数字1"
console.log('  get("1"):', map.get("1"));       // "字符串1"
console.log("  get(objKey):", map.get(objKey)); // "用对象作为键的值"

// 不同的对象是不同的键
const anotherObj = { id: 1 };  // 内容和 objKey 相同，但是不同的对象
console.log("  get(anotherObj):", map.get(anotherObj)); // undefined！

// has / delete
console.log('  has("name"):', map.has("name"));     // true
map.delete("name");
console.log('  delete 后 has("name"):', map.has("name")); // false

// ----------------------------------------------------------
// 5. 普通对象 vs Map——键类型的差异
// ----------------------------------------------------------
console.log("\n5. 普通对象 vs Map 键类型差异：");

// 普通对象：所有键都被转为字符串
const plainObj = {};
plainObj[1] = "数字";
plainObj["1"] = "字符串";  // 覆盖了！因为 1 被转成 "1"
plainObj[true] = "布尔";
console.log("  普通对象:", plainObj);  // { '1': '字符串', 'true': '布尔' }

// Map：保持原始类型
const map2 = new Map();
map2.set(1, "数字");
map2.set("1", "字符串");  // 不覆盖！
map2.set(true, "布尔");
console.log("  Map 遍历：");
for (const [key, value] of map2) {
    console.log(`    ${typeof key} ${String(key)} => ${value}`);
}

// ----------------------------------------------------------
// 6. Map 遍历方式
// ----------------------------------------------------------
console.log("\n6. Map 遍历：");

const scores = new Map([
    ["语文", 85],
    ["数学", 92],
    ["英语", 78],
]);

// for...of 直接遍历
console.log("  for...of 遍历：");
for (const [subject, score] of scores) {
    console.log(`    ${subject}: ${score} 分`);
}

// keys()——遍历键
console.log("  keys():", [...scores.keys()]);

// values()——遍历值
console.log("  values():", [...scores.values()]);

// entries()——遍历键值对
console.log("  entries():", [...scores.entries()]);

// 计算总分（Map 配合数组方法）
const totalScore = [...scores.values()].reduce((sum, s) => sum + s, 0);
console.log(`  总分: ${totalScore}`);

// ----------------------------------------------------------
// 7. WeakSet / WeakMap——弱引用版本
// ----------------------------------------------------------
console.log("\n7. WeakMap 示例（弱引用——了解即可）：");

// WeakMap：键必须是对象，值可以是任意类型
const weakMap = new WeakMap();

let user1 = { name: "张三" };
let user2 = { name: "李四" };

weakMap.set(user1, { lastLogin: "2024-01-01" });
weakMap.set(user2, { lastLogin: "2024-01-02" });

console.log("  weakMap.get(user1):", weakMap.get(user1));
console.log("  weakMap.has(user1):", weakMap.has(user1));

// 当对象没有被别处引用时，可以被垃圾回收
// WeakMap 中的对应条目也会被自动清除
// （在代码中演示不了垃圾回收，因为引用还在）

// ----------------------------------------------------------
// 8. 数据结构选型对比
// ----------------------------------------------------------
console.log("\n8. 数据结构选型总结：");

const testArray = [3, 1, 4, 1, 5, 9, 2, 6];
const testSet = new Set(testArray);
const testMap = new Map(Object.entries({ a: 1, b: 2, c: 3 }));

console.log("  数组: 有序，按索引访问，允许重复——适合列表");
console.log(`    例: ${testArray}`);
console.log("  Set: 唯一值集合，自动去重——适合去重/成员检测");
console.log(`    例: ${[...testSet]}`);
console.log("  Map: 任意类型键，严格插入顺序——适合字典/缓存");
console.log(`    例: ${[...testMap]}`);

// 性能对比说明（注释形式）
// - Set.has() 比 Array.includes() 快得多（O(1) vs O(n)）
// - Map 的增删查找都是 O(1)，比对象适合高频增删场景

console.log("\n========== Set 与 Map 演示结束 ==========");
