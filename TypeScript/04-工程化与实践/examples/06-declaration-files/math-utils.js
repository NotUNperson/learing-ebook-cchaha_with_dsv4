// math-utils.js —— 纯 JavaScript 的计算工具模块
// 这个文件没有任何类型信息，TypeScript 无法直接理解它

function add(a, b) {
  return a + b;
}

function subtract(a, b) {
  return a - b;
}

function multiply(a, b) {
  return a * b;
}

function divide(a, b) {
  if (b === 0) {
    throw new Error("除数不能为零");
  }
  return a / b;
}

// 获取数字数组的平均值
function average(numbers) {
  if (numbers.length === 0) {
    return 0;
  }
  const sum = numbers.reduce(function (acc, cur) {
    return acc + cur;
  }, 0);
  return sum / numbers.length;
}

// CommonJS 导出
module.exports = { add, subtract, multiply, divide, average };
