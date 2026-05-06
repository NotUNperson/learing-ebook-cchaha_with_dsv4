/**
 * 08-weather-cli.ts
 * 综合练习：命令行天气查询工具
 *
 * 这个程序用到了前七节的所有知识点：
 *   第 1 节：ts-node 运行
 *   第 2 节：事件循环（fetch 的异步本质）
 *   第 3 节：Promise（fetch 返回 Promise）
 *   第 4 节：async/await（主流程用 await 等待网络请求）
 *   第 5 节：模块（可拆分为多个文件，这里为演示方便放在一个文件）
 *   第 6 节：全局 API（console、fetch、JSON）
 *   第 7 节：错误处理（try/catch 优雅降级）
 *
 * 运行方式：
 *   ts-node 08-weather-cli.ts 北京
 *   ts-node 08-weather-cli.ts 上海
 *   ts-node 08-weather-cli.ts 杭州
 *
 * 天气数据来源：Open-Meteo（免费，无需 API Key，无需注册）
 * 文档：https://open-meteo.com/
 */

// ============================================================
// 第一部分：类型定义（相当于"图纸"）
// ============================================================

/**
 * 先定义好 API 返回数据的形状。
 * 虽然运行时接口会被擦除，但 TypeScript 编译时会帮你检查：
 *   - 字段名打错了吗？
 *   - 访问了不存在的字段吗？
 *   - 类型对得上吗？
 */

// Open-Meteo API 返回的顶层结构
interface WeatherApiResponse {
  latitude: number;
  longitude: number;
  generationtime_ms: number;
  utc_offset_seconds: number;
  timezone: string;
  timezone_abbreviation: string;
  elevation: number;
  current_weather: CurrentWeather;
}

// current_weather 字段的结构
interface CurrentWeather {
  temperature: number;    // 温度（摄氏度）
  windspeed: number;      // 风速（公里/小时）
  winddirection: number;  // 风向（角度）
  weathercode: number;    // 天气代码（WMO 标准编码）
  time: string;           // 观测时间（ISO 8601 格式）
}

// 我们最终展示给用户的数据（简化版，只取关心的字段）
interface WeatherDisplay {
  city: string;
  temperature: number;
  windspeed: number;
  winddirection: number;
  weatherDescription: string;
  observationTime: string;
}

// ============================================================
// 第二部分：天气码映射（查表转换）
// ============================================================

/**
 * Open-Meteo 使用 WMO 天气代码（数字编码）
 * 我们把代码映射成中文描述，方便展示
 *
 * Record<number, string> 是 TS 的工具类型，
 * 表示"key 是 number，value 是 string 的对象"
 */

function getWeatherDescription(code: number): string {
  // 天气码对照表（WMO 标准）
  const weatherMap: Record<number, string> = {
    0:  "晴天",
    1:  "少云",
    2:  "多云",
    3:  "阴天",
    45: "有雾",
    48: "雾凇",
    51: "小毛毛雨",
    53: "毛毛雨",
    55: "大毛毛雨",
    56: "冻毛毛雨",
    57: "冻毛毛雨（大）",
    61: "小雨",
    63: "中雨",
    65: "大雨",
    66: "冻雨",
    67: "冻雨（大）",
    71: "小雪",
    73: "中雪",
    75: "大雪",
    77: "雪粒",
    80: "阵雨",
    81: "中等阵雨",
    82: "大阵雨",
    85: "小阵雪",
    86: "大阵雪",
    95: "雷暴",
    96: "雷暴伴小冰雹",
    99: "雷暴伴大冰雹",
  };

  // ?? 是空值合并运算符：如果 weatherMap[code] 是 undefined，就用右边的兜底值
  return weatherMap[code] ?? `未知天气（代码: ${code}）`;
}

// ============================================================
// 第三部分：城市坐标映射
// ============================================================

/**
 * Open-Meteo 需要经纬度坐标，不能直接传城市名。
 * 这里做一个简单的城市名 → 坐标的映射表。
 *
 * 注意：这不完整，真实项目会用一个"地理编码（Geocoding）"API
 * 把城市名自动转成坐标。这里为了演示简洁，手动维护一个表。
 */

interface Coordinates {
  lat: number;
  lon: number;
}

const cityCoordinates: Record<string, Coordinates> = {
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
  "天津": { lat: 39.3434, lon: 117.3616 },
  "苏州": { lat: 31.2990, lon: 120.5853 },
  "长沙": { lat: 28.2282, lon: 112.9388 },
  "郑州": { lat: 34.7466, lon: 113.6254 },
  "济南": { lat: 36.6512, lon: 117.1201 },
  "青岛": { lat: 36.0671, lon: 120.3826 },
  "大连": { lat: 38.9140, lon: 121.6147 },
  "厦门": { lat: 24.4798, lon: 118.0894 },
  "福州": { lat: 26.0745, lon: 119.2965 },
  "昆明": { lat: 25.0389, lon: 102.7183 },
};

// 风向角度转方位描述
function getWindDirection(degree: number): string {
  const directions: string[] = [
    "北", "北东北", "东北", "东东北",
    "东", "东东南", "东南", "南东南",
    "南", "南西南", "西南", "西西南",
    "西", "西西北", "西北", "北西北",
  ];
  // 每 22.5 度一个方向
  const index: number = Math.round(degree / 22.5) % 16;
  return directions[index];
}

// ============================================================
// 第四部分：核心查询函数
// ============================================================

/**
 * 查询指定城市的天气
 * 这是整个程序的核心，综合运用了 async/await、fetch、JSON 解析、错误处理
 *
 * @param cityName 城市名（必须在 cityCoordinates 中有定义）
 * @returns 格式化后的天气展示数据
 * @throws 如果 API 请求失败或城市不支持
 */
async function queryWeather(cityName: string): Promise<WeatherDisplay> {
  // 1. 查城市坐标
  const coords: Coordinates | undefined = cityCoordinates[cityName];
  if (!coords) {
    throw new Error(
      `不支持的城市 "${cityName}"。支持的城市：${Object.keys(cityCoordinates).join("、")}`
    );
  }

  // 2. 构造 API 请求 URL
  //    只请求 current_weather，跳过其他不需要的数据（减少传输量）
  const url: string = [
    "https://api.open-meteo.com/v1/forecast",
    `?latitude=${coords.lat}`,
    `&longitude=${coords.lon}`,
    "&current_weather=true",
    "&timezone=Asia%2FShanghai", // 时区设为上海/北京时间
  ].join("");

  console.log(`正在查询 ${cityName}（${coords.lat}, ${coords.lon}）的天气...`);

  // 3. 发起 HTTP GET 请求
  //    fetch 返回 Promise<Response>，用 await 等待结果
  const response: Response = await fetch(url);

  // 4. 检查 HTTP 状态码
  //    response.ok 为 true 当且仅当状态码在 200-299 之间
  if (!response.ok) {
    throw new Error(`天气 API 请求失败，HTTP 状态码：${response.status}`);
  }

  // 5. 解析 JSON 响应体
  //    response.json() 也是异步的（需要读取整个响应体），所以也要 await
  //    用 as 做类型断言，告诉 TS "我确信数据长这样"
  const rawData: WeatherApiResponse = await response.json() as WeatherApiResponse;

  // 6. 提取并转换数据
  const cw: CurrentWeather = rawData.current_weather;

  const display: WeatherDisplay = {
    city: cityName,
    temperature: cw.temperature,
    windspeed: cw.windspeed,
    winddirection: cw.winddirection,
    weatherDescription: getWeatherDescription(cw.weathercode),
    observationTime: cw.time,
  };

  return display;
}

// ============================================================
// 第五部分：展示函数
// ============================================================

/**
 * 把天气数据格式化成漂亮的终端输出
 *
 * @param weather 天气展示数据
 */
function displayWeather(weather: WeatherDisplay): void {
  // 根据温度给一些穿衣建议
  let suggestion: string;
  if (weather.temperature < 5) {
    suggestion = "非常冷，请穿厚羽绒服、围巾、手套";
  } else if (weather.temperature < 12) {
    suggestion = "较冷，建议穿厚外套或羽绒服";
  } else if (weather.temperature < 20) {
    suggestion = "凉爽，建议穿薄外套或夹克";
  } else if (weather.temperature < 28) {
    suggestion = "舒适，穿长袖或薄外套即可";
  } else if (weather.temperature < 35) {
    suggestion = "偏热，建议穿短袖、注意防晒";
  } else {
    suggestion = "非常热，注意防暑降温，多喝水";
  }

  // 分隔线让输出更清晰
  const divider: string = "=".repeat(40);

  console.log(divider);
  console.log(`  ${weather.city} 当前天气`);
  console.log(divider);
  console.log(`  温度：${weather.temperature} °C`);
  console.log(`  天气：${weather.weatherDescription}`);
  console.log(`  风速：${weather.windspeed} km/h  风向：${getWindDirection(weather.winddirection)}`);
  console.log(`  观测时间：${weather.observationTime}`);
  console.log(divider);
  console.log(`  穿衣建议：${suggestion}`);
  console.log(divider);
}

// ============================================================
// 第六部分：主流程 —— 把所有零件串起来
// ============================================================

/**
 * 程序入口函数
 *
 * 流程：
 *   1. 获取命令行参数（城市名）
 *   2. 查坐标
 *   3. 发请求
 *   4. 解 JSON
 *   5. 转描述
 *   6. 格式化输出
 *   7. 错误时友好降级
 */
async function main(): Promise<void> {
  try {
    // 1. 读取命令行参数
    //    process.argv 是一个字符串数组：
    //    process.argv[0] = node 可执行文件路径
    //    process.argv[1] = 当前脚本文件路径
    //    process.argv[2] = 第一个用户参数（城市名）
    //    所以用 .slice(2) 截取用户参数部分
    const args: string[] = process.argv.slice(2);

    // 如果没有提供城市名，打印使用说明
    if (args.length === 0) {
      console.log("=== 天气查询工具 ===");
      console.log("使用方法：ts-node 08-weather-cli.ts <城市名>");
      console.log("");
      console.log("支持的城市：");
      Object.keys(cityCoordinates).forEach((city) => {
        const c: Coordinates = cityCoordinates[city];
        console.log(`  ${city}（${c.lat}, ${c.lon}）`);
      });
      console.log("");
      console.log("示例：ts-node 08-weather-cli.ts 北京");
      return; // 直接返回，不继续走下面的逻辑
    }

    const cityName: string = args[0];

    // 2. 查询天气
    const weather: WeatherDisplay = await queryWeather(cityName);

    // 3. 展示结果
    displayWeather(weather);

  } catch (error) {
    // 7. 优雅降级：出错了不崩溃，给用户友好的提示
    const errMsg: string = error instanceof Error ? error.message : String(error);

    console.log("-----------------------------");
    console.log(`查询失败：${errMsg}`);
    console.log("请检查：");
    console.log("  1. 城市名是否在支持列表中");
    console.log("  2. 网络连接是否正常");
    console.log("  3. 稍后重试");
    console.log("-----------------------------");

    // 如果是开发环境，打印完整错误堆栈帮助调试
    if (process.env.NODE_ENV === "development") {
      if (error instanceof Error && error.stack) {
        console.log("\n[调试信息] 错误堆栈：");
        console.log(error.stack);
      }
    }
  }
}

// ============================================================
// 启动程序
// ============================================================

// 调用 main 函数，启动整个流程
main().then(() => {
  // 程序正常结束
  // 注意：如果有未关闭的异步操作（如定时器、连接），Node.js 可能不会自动退出
  // 这个小程序不需要显式 process.exit()，因为 fetch 之后没有挂起的异步任务
});

/**
 * 扩展练习建议：
 *
 * 1. 添加更多城市到 cityCoordinates 中
 * 2. 把温度低于 10 度时提示"较冷，注意保暖"
 * 3. 拆分成多个模块文件：
 *    - city-data.ts      （城市坐标表）
 *    - weather-code.ts   （天气码映射 + 风向转换）
 *    - weather-api.ts    （fetch 请求逻辑）
 *    - weather-display.ts（展示格式化逻辑）
 *    - main.ts           （主流程，import 以上模块）
 * 4. 用命令行参数支持指定语言（中/英）
 * 5. 添加未来几天天气预报（API 中有 daily forecast 数据）
 * 6. 用 fs 模块把查询结果保存到本地文件
 */
