# A.23 Set 与 Map

## 本节你会学到什么

- `Set` ——值唯一的集合，自动去重，就像数学中的集合
- `Map` ——键值对集合，键可以是**任意类型**（对象当键都行）
- Set 和 Map 的常用操作：add、delete、has、size、遍历
- `WeakSet` / `WeakMap` ——弱引用版本，了解即可
- 和数组/普通对象的对比——什么时候该用哪个

## 正文

### Set——自动去重的集合

**生活类比**：一个班级的点名册。同一个学生不会出现在点名册上两次——重复的名字会被自动忽略。Set 就是这样的点名册。

```javascript
const set = new Set();

set.add(1);
set.add(2);
set.add(2);  // 重复的 2——自动忽略
set.add(3);

console.log(set);         // Set { 1, 2, 3 }
console.log(set.size);    // 3  （不是 4！）

console.log(set.has(2));  // true
console.log(set.has(5));  // false

set.delete(2);
console.log(set.has(2));  // false
```

Set 的常用 API：

| 方法 | 说明 |
|------|------|
| `add(value)` | 添加元素，返回 Set 自身（支持链式调用）|
| `delete(value)` | 删除元素，返回布尔值 |
| `has(value)` | 判断是否存在 |
| `clear()` | 清空所有元素 |
| `size` | 元素个数（属性，不是方法）|

### Set 遍历

Set 保持插入顺序，可以用 `forEach` 或 `for...of`：

```javascript
const colors = new Set(["红", "绿", "蓝"]);

for (const color of colors) {
    console.log(color);  // "红" "绿" "蓝"
}

colors.forEach((value, alsoValue, set) => {
    console.log(value);  // 注意：key 和 value 相同（Set 只有值）
});
```

### Set 的实用场景——去重

```javascript
const arr = [1, 2, 2, 3, 3, 3, 4];
const unique = [...new Set(arr)];
console.log(unique);  // [1, 2, 3, 4]  ——一行去重！
```

### Map——键可以是任意类型的字典

普通对象的键只能是字符串或 Symbol。如果你用数字，它会被转成字符串：

```javascript
const obj = {};
obj[1] = "一";
obj["1"] = "壹";  // 覆盖了上面的！因为 1 被转成了 "1"
console.log(obj[1]); // "壹"
```

Map 没有这个限制。键可以是任意类型——数字、字符串、对象、函数都行，并且用它原本的类型来判断相等：

```javascript
const map = new Map();

map.set(1, "数字1");
map.set("1", "字符串1");  // 不覆盖！1 和 "1" 是不同的键
map.set(true, "布尔值");
map.set({ id: 1 }, "用对象当键！");

console.log(map.get(1));         // "数字1"
console.log(map.get("1"));       // "字符串1"
console.log(map.size);           // 4
```

Map 的关键特性：它是**按插入顺序迭代**的。普通对象的键的顺序在 ES2015 以后大部分情况下也稳定，但 Map 明确保证了这一点。

### Map 常用 API

| 方法 | 说明 |
|------|------|
| `set(key, value)` | 设置键值对，返回 Map 自身（链式调用）|
| `get(key)` | 获取值，不存在返回 undefined |
| `delete(key)` | 删除键值对 |
| `has(key)` | 判断键是否存在 |
| `clear()` | 清空 |
| `size` | 键值对数量 |

### Map 遍历——比对象更优雅

```javascript
const userRoles = new Map([
    ["张三", "管理员"],
    ["李四", "编辑"],
    ["王五", "读者"],
]);

// for...of 直接遍历键值对
for (const [user, role] of userRoles) {
    console.log(`${user}: ${role}`);
}

// 也可以分别遍历键和值
console.log([...userRoles.keys()]);    // ["张三", "李四", "王五"]
console.log([...userRoles.values()]);  // ["管理员", "编辑", "读者"]
console.log([...userRoles.entries()]); // [["张三","管理员"], ...]
```

### WeakSet / WeakMap——了解即可

它们的"弱"指的是对元素的引用是"弱引用"——如果元素对象在其他地方没有被引用了，垃圾回收就会把它收走，WeakSet/WeakMap 中对应的条目也会消失。

- `WeakSet`：只能存对象，不能遍历
- `WeakMap`：键只能是对象，不能遍历

它们的典型场景是存储与对象关联的"附加数据"，而不妨碍对象被垃圾回收。

### 选型对比

| 需求 | 使用 | 原因 |
|------|------|------|
| 有序列表，按索引访问 | 数组 `[]` | 数组专为索引访问优化 |
| 需要去重的列表 | Set | 自动去重 |
| 字符串键的键值对 | 普通对象 `{}` | 足够用，语法简单 |
| 非字符串键（对象/数字等） | Map | 普通对象会强制转换键 |
| 需要知道键值对数量 | Map | `size` 属性，对象要用 `Object.keys().length` |
| 需要按插入顺序迭代 | Map | 明确保证顺序 |
| 频繁增删键值对 | Map | 对增删操作做了优化 |

## 与 C 语言的对比

C 语言没有内置的集合/字典数据结构。你需要自己用哈希表或红黑树实现。JS 把 Set/Map 内置到语言中，且 API 设计统一——add/delete/has/size——不用关心底层哈希冲突和扩容这些细节。这也意味着 JS 程序员可以把精力放在业务逻辑上，而不是造轮子。

## 动手试试

1. 创建一个有重复元素的数组，用 Set 去重
2. 用 Map 做一个简单的"用户积分表"，用户名（字符串）作为键，积分作为值
3. 试试用对象作为 Map 的键，验证用同样内容的不同对象是否算不同的键

## 本节小结

- Set 自动去重，提供 add/delete/has/size，可遍历，去重常用 `[...new Set(arr)]`
- Map 键可以是任意类型，提供 set/get/delete/has/size，严格按插入顺序迭代
- WeakSet/WeakMap 是弱引用版本，不阻止垃圾回收，不能遍历
- 字符串键的简单场景用普通对象；非字符串键、需要顺序/频繁增删用 Map；去重用 Set

## 下一节预告

A.24 错误处理——程序总会出错，关键是如何优雅地处理。try/catch/finally 和自定义 Error 类。
