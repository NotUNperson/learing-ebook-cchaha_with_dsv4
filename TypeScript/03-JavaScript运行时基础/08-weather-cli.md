# 8. 综合练习：命令行天气查询工具

## 本节你会学到什么

- 把前七节学到的所有知识串成一个完整的小项目
- 设计 API 响应的 TypeScript 接口（类型定义）
- 用 fetch + async/await 调用免费天气 API
- 解析 JSON 响应并做类型安全的数据提取
- 用 try/catch 做错误处理和优雅降级
- 从命令行参数读取用户输入（process.argv）

## 正文

### 我们要做什么

这一节不是学新知识，而是**组装**。你已经有了所有零件——类型定义、Promise、async/await、模块、fetch、JSON 解析、错误处理。现在我们要把它们组装成一个能真正运行的小工具：**命令行天气查询**。

你在终端输入：

```bash
ts-node 08-weather-cli.ts 北京
```

程序输出：

```
正在查询 北京 的天气...

北京 当前天气：
  温度：18 度
  天气：晴
  湿度：45%
  风速：12 km/h
```

### 整体架构

这个小程序分五层：

1. **类型定义层** —— 定义 API 返回数据的 TypeScript 接口
2. **数据获取层** —— 用 fetch 调 API，拿到原始 JSON
3. **数据解析层** —— 把 JSON 映射到 TypeScript 接口，提取需要的字段
4. **展示层** —— 把数据格式化成人类友好的文字
5. **主流程层** —— async/await 把这些步骤串起来，加 try/catch

就像盖房子：地基（类型定义）打好，水电管道（fetch）铺好，墙壁（解析）砌好，然后装修（展示），最后搬进去住（主流程）。

### 选择天气 API

真实项目中你要挑一个天气 API。有几种选择：

- **Open-Meteo**（免费，无需注册，无需 API Key）：基于开源数据，返回 JSON，好上手 —— 这是我们本节使用的。
- **OpenWeatherMap**：需要注册获取 API Key，免费额度有限。
- **和风天气**：国内服务，有中文文档。

Open-Meteo 的接口格式：

```
请求：https://api.open-meteo.com/v1/forecast?latitude=39.9042&longitude=116.4074&current_weather=true
```

返回的数据长这样：

```json
{
  "latitude": 39.9,
  "longitude": 116.4,
  "current_weather": {
    "temperature": 18.5,
    "windspeed": 12.3,
    "weathercode": 1,
    "time": "2024-01-15T10:00"
  }
}
```

注意 `weathercode` 是数字编码。Open-Meteo 的天气码对照：
- 0: 晴
- 1-3: 多云
- 45-48: 雾
- 51-67: 雨
- 71-77: 雪
- 80-99: 阵雨/雷暴

我们需要把这个数字转成中文描述，这正好练习"查表转换"。

### 类型定义 —— 先画图纸

拿到 JSON 样本后，第一件事是用 TypeScript 接口描述它的形状：

```typescript
// API 返回的顶层结构
interface WeatherApiResponse {
  latitude: number;
  longitude: number;
  current_weather: CurrentWeather;
}

// 当前天气
interface CurrentWeather {
  temperature: number;
  windspeed: number;
  winddirection: number;
  weathercode: number;
  time: string;
}

// 我们最终要展示的数据（简化版，只取关心的字段）
interface WeatherDisplay {
  city: string;
  temperature: number;
  windspeed: number;
  weatherDescription: string;
}
```

这些接口就像是拿到的"图纸"——告诉 TypeScript（和所有读代码的人）数据长什么样。虽然接口在运行时会被擦除，但编译阶段它们保证了你不写错字段名（打错字 IDE 立刻提示）。

### 天气码转换 —— 查表映射

```typescript
function getWeatherDescription(code: number): string {
  const weatherMap: Record<number, string> = {
    0: "晴天",
    1: "少云",
    2: "多云",
    3: "阴天",
    45: "有雾",
    48: "雾凇",
    51: "小毛毛雨",
    53: "毛毛雨",
    55: "大毛毛雨",
    61: "小雨",
    63: "中雨",
    65: "大雨",
    71: "小雪",
    73: "中雪",
    75: "大雪",
    80: "阵雨",
    81: "中等阵雨",
    82: "大阵雨",
    95: "雷暴",
    96: "雷暴伴小冰雹",
    99: "雷暴伴大冰雹",
  };
  return weatherMap[code] ?? `未知天气（码: ${code}）`;
}
```

这里 `Record<number, string>` 是 TS 的内置工具类型，表示"key 是 number、value 是 string 的对象"。`??` 是空值合并运算符——如果 `weatherMap[code]` 是 undefined，就用右边的兜底值。

### 城市坐标映射

Open-Meteo 需要经纬度，不是城市名。我们做一个简单的城市-坐标映射表：

```typescript
const cityCoordinates: Record<string, { lat: number; lon: number }> = {
  "北京": { lat: 39.9042, lon: 116.4074 },
  "上海": { lat: 31.2304, lon: 121.4737 },
  "广州": { lat: 23.1291, lon: 113.2644 },
  "深圳": { lat: 22.5431, lon: 114.0579 },
  "杭州": { lat: 30.2741, lon: 120.1551 },
  "成都": { lat: 30.5728, lon: 104.0668 },
  "武汉": { lat: 30.5928, lon: 114.3055 },
  "西安": { lat: 34.3416, lon: 108.9398 },
  "重庆": { lat: 29.4316, lon: 106.9123 },
  "南京": { lat: 32.0603, lon: 118.7969 },
};
```

这不是一个完整的城市列表，实际项目可能需要调一个地理编码 API（Geocoding）。但对我们这个小工具来说足够了——而且这正好展示 TypeScript 的 `Record` 工具类型用法。

### 主流程 —— 把所有零件串起来

```typescript
async function main(): Promise<void> {
  try {
    // 1. 读取命令行参数
    const args: string[] = process.argv.slice(2);
    if (args.length === 0) {
      console.log("使用方法：ts-node 08-weather-cli.ts <城市名>");
      return;
    }
    const cityName: string = args[0];

    // 2. 查坐标
    const coords = cityCoordinates[cityName];
    if (!coords) {
      console.log(`抱歉，暂不支持查询 ${cityName}。`);
      console.log(`支持的城市：${Object.keys(cityCoordinates).join("、")}`);
      return;
    }

    // 3. 构造 URL 并发请求
    console.log(`正在查询 ${cityName} 的天气...`);
    const url: string = `https://api.open-meteo.com/v1/forecast?latitude=${coords.lat}&longitude=${coords.lon}&current_weather=true`;

    // 4. fetch 请求
    const response: Response = await fetch(url);
    if (!response.ok) {
      throw new Error(`天气 API 返回错误：${response.status}`);
    }

    // 5. 解析 JSON
    const rawData: WeatherApiResponse = await response.json() as WeatherApiResponse;

    // 6. 提取数据
    const cw: CurrentWeather = rawData.current_weather;
    const display: WeatherDisplay = {
      city: cityName,
      temperature: cw.temperature,
      windspeed: cw.windspeed,
      weatherDescription: getWeatherDescription(cw.weathercode),
    };

    // 7. 展示
    console.log(`\n${display.city} 当前天气：`);
    console.log(`  温度：${display.temperature} 度`);
    console.log(`  天气：${display.weatherDescription}`);
    console.log(`  风速：${display.windspeed} km/h`);

  } catch (error) {
    // 优雅降级
    const errMsg: string = error instanceof Error ? error.message : String(error);
    console.log(`查询失败：${errMsg}`);
    console.log("请检查网络连接后重试。");
  }
}

main();
```

### 这个项目用到了什么

回顾这八节课，这个天气查询工具用到了：

| 前七节知识 | 在哪里用了 |
|-----------|----------|
| 第 1 节 TS 运行 | ts-node 执行，ts 编译 |
| 第 2 节 回调/事件循环 | fetch 底层的异步机制 |
| 第 3 节 Promise | fetch 返回 Promise，await 等待 |
| 第 4 节 async/await | main 函数整个是 async，await fetch |
| 第 5 节 模块 | （可扩展）把天气码映射、城市映射、fetch 逻辑各自拆文件 |
| 第 6 节 全局 API | `console.log`、`fetch`、`JSON` 解析 |
| 第 7 节 错误处理 | try/catch 包住整个流程，优雅降级兜底 |

## 动手试试

1. 运行程序：`ts-node 08-weather-cli.ts 北京`
2. 试试查一个不支持的城市名，看程序怎么处理（友好提示，不崩溃）。
3. 把城市坐标映射表加上你自己的城市。
4. 扩展：把天气描述的输出加上"体感温度"的提示（比如温度低于 10 度就提示"较冷，注意保暖"）。
5. 进阶挑战：把 main 函数拆成多个模块——`weather-api.ts`（发请求）、`weather-display.ts`（格式化输出）、`city-data.ts`（城市坐标表）、`weather-code.ts`（天气码映射），然后在 `main.ts` 中 import 它们。看能否体会模块化后代码组织更清晰。

## 本节小结

这个命令行天气查询工具把类型定义、fetch、async/await、JSON 解析、try/catch 优雅降级串成了一条完整的流水线——从用户输入城市名开始，经过查坐标、发请求、解 JSON、转描述、格式化输出，每一步都有 TypeScript 的类型保护，出错时有友好兜底。

## 下一节预告

恭喜！你已经完成了 JavaScript 运行时基础的八个模块。接下来你可以探索 Node.js 的文件系统（fs 模块，读写本地文件）、Express 后端框架（写 Web 服务器）、或者 TypeScript 的项目配置（tsconfig 深入、路径别名等）。无论选哪条路，你现在的基础已经足够坚实了。
