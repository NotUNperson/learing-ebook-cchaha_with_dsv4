// ============================================================
// messy-code.ts —— 故意写得风格不统一的代码，供 ESLint + Prettier 练习
// ============================================================

var     oldVariable   = "我在用 var, 缩进也很乱"   ;

function    add(a:number,b:number):number{
return a+b
}

// 未使用的变量（ESLint 应该报告）
const unusedVariable = "没人用到我";

// 缩进混乱、空格不一致
const obj =       {
name:  "张三"  ,
age:  20  ,
city:"北京"
};

// 双引号和单引号混用
let greeting = "你好"
let farewell = '再见'

// console.log 在 ESLint 配置中被设为 warn 级别
console.log(add(1,2))
console.log(  obj  .  name  )

// 使用 let 但变量从未被重新赋值（prefer-const 规则应报告）
let shouldBeConst = "这个变量应该用 const 声明";

export {};
