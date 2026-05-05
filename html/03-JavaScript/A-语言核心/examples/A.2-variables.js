/**
 * A.2 变量声明 -- 示例代码
 *
 * 运行方式：在终端执行
 *   node A.2-variables.js
 */

// ============================================================
// 1. let -- 可变变量（推荐默认使用）
// ============================================================

let age = 25;
console.log("初始年龄:", age);   // 25

age = 26;                        // 可以重新赋值
console.log("修改后年龄:", age);  // 26

// 可以先声明，后赋值
let name;
name = "小明";
console.log("名字:", name);      // "小明"

// let 有块作用域：{} 内部声明的变量，外部访问不到
{
    let blockVar = "我在块里";
    console.log("块内部:", blockVar);  // 可以访问
}
// console.log(blockVar);  // 这里会报错！blockVar 在块外不可见

// ============================================================
// 2. const -- 常量
// ============================================================

const PI = 3.14159;
console.log("圆周率:", PI);
// PI = 3.14;  // 这行会报错！TypeError: Assignment to constant variable.

const birthYear = 2000;
console.log("出生年份:", birthYear);
// birthYear = 2001;  // 也会报错！

// const 的重要陷阱：对象的内容可以改，但引用不能改
const person = { name: "小明", age: 20 };
console.log("初始对象:", person);

person.age = 21;         // 可以改！修改对象内部的属性
person.city = "北京";    // 甚至可以新增属性
console.log("修改后对象:", person);  // { name: '小明', age: 21, city: '北京' }

// person = { name: "小红" };  // 报错！不能把 person 指向新对象

// ============================================================
// 3. var -- 老式声明（了解即可，不推荐使用）
// ============================================================

// var 没有块作用域
{
    var blockVar2 = "我可以逃出块！";
}
console.log("var 逃出块作用域:", blockVar2);  // 能访问到！

// var 的变量提升
console.log("提升前访问:", hoistedVar);  // undefined（不报错，因为变量被"提升"了）
var hoistedVar = 10;
console.log("提升后访问:", hoistedVar);   // 10

// 对比：let 不会这样
// console.log(notHoisted);  // 报错！ReferenceError
// let notHoisted = 5;

// ============================================================
// 4. 命名规则和惯例
// ============================================================

// 大小写敏感
let apple = "苹果";
let Apple = "苹果公司";
let APPLE = "APPLE";
console.log("三个不同变量:", apple, Apple, APPLE);

// 驼峰命名法（camelCase）-- JS 的主流风格
let userName = "张三";
let userAge = 25;
let isLoggedIn = false;
let getUserInfo = function() { return userName; };

// 全大写+下划线 -- 用于真正的常量（配置值等）
const MAX_SIZE = 100;
const API_BASE_URL = "https://api.example.com";

// 布尔值常用 is/has 开头
let isLoading = true;
let hasError = false;

console.log("\n变量命名示例:");
console.log("用户名:", userName);
console.log("最大尺寸:", MAX_SIZE);
console.log("是否加载中:", isLoading);

// ============================================================
// 小结：
// - 默认用 const，需要改值时用 let
// - 忘记 var（除非维护老代码）
// - let/const 有块作用域，{} 外无法访问
// - 命名用驼峰法：userName, getUserInfo
// ============================================================
