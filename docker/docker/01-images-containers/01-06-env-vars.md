# 01-06 环境变量与容器配置

## 本节你会学到什么

- 掌握用 `-e` 参数向容器传递环境变量
- 学会用 `--env-file` 批量管理环境变量
- 理解为什么环境变量是容器配置的最佳实践
- 学会查看容器内的环境变量，验证配置是否生效

---

## 同一套代码，不同的配置

想象你是一个连锁餐厅的老板。你有一套标准化的餐厅运营流程（代码），但每家分店的实际运营参数（配置）不同：

- 北京路店：咖啡 25 元，营业时间 8:00-22:00
- 南京路店：咖啡 28 元，营业时间 7:30-23:00
- 深圳湾店：咖啡 30 元，营业时间 9:00-24:00

你不能为每家店单独写一套运营流程——那样太蠢了。正确做法是：**用同一套流程，每家店用不同的参数表（环境变量）来驱动**。

容器也是同样的道理。同一个 MySQL 镜像，可以跑出完全不同的实例——只需要改变传入的环境变量。

---

## 为什么要用环境变量？

常见的错误做法：把配置写死在容器里。

比如你构建了一个 Node.js 应用的 Docker 镜像，数据库连接字符串直接写在代码里：

```javascript
// 错误做法：硬编码
const dbUrl = "mysql://root:password123@localhost:3306/mydb";
```

问题是：开发环境的数据库地址和密码，跟测试环境、生产环境都不一样。你难道为每个环境重新构建一个镜像？太麻烦了，而且违背了"一次构建，到处运行"的原则。

正确做法：通过环境变量传入配置：

```javascript
// 正确做法：从环境变量读取
const dbUrl = process.env.DATABASE_URL;
```

这样同一个镜像，在不同环境通过不同的环境变量启动就行了。

类比：你的餐厅运营流程手册写着"咖啡价格见附录 A"。附录 A 不是印在手册里的，而是每家店开业前单独发一张价格表（环境变量）。流程一样，价格不同。

---

## -e 传参：单个环境变量

```bash
docker run -d --name mysql-dev \
  -e MYSQL_ROOT_PASSWORD=dev-pass-123 \
  -e MYSQL_DATABASE=myapp_dev \
  mysql:8
```

每个 `-e 变量名=变量值` 传入一个环境变量。

常用的官方镜像环境变量举例：

| 镜像 | 常用环境变量 | 作用 |
|------|-------------|------|
| mysql | MYSQL_ROOT_PASSWORD | root 密码（必填） |
| mysql | MYSQL_DATABASE | 启动时自动创建的数据库 |
| mysql | MYSQL_USER / MYSQL_PASSWORD | 创建普通用户 |
| postgres | POSTGRES_PASSWORD | 超级用户密码 |
| postgres | POSTGRES_DB | 启动时自动创建的数据库 |
| redis | REDIS_PASSWORD | 设置访问密码 |
| mongo | MONGO_INITDB_ROOT_USERNAME | 初始 root 用户名 |
| mongo | MONGO_INITDB_ROOT_PASSWORD | 初始 root 密码 |
| nginx | 没有强制要求的环境变量 | Nginx 主要通过挂载配置文件 |

注意：不是所有镜像都用环境变量配置。具体查看镜像的 Docker Hub 页面文档。

---

## 验证环境变量是否生效

```bash
# 启动一个带环境变量的容器
docker run -d --name my-mysql \
  -e MYSQL_ROOT_PASSWORD=test123 \
  -e MYSQL_DATABASE=mydb \
  mysql:8

# 查看容器内的环境变量
docker exec my-mysql env
# 输出里能看到：
# MYSQL_ROOT_PASSWORD=test123
# MYSQL_DATABASE=mydb

# 或者单独查某个变量
docker exec my-mysql printenv MYSQL_ROOT_PASSWORD
# 输出：test123
```

---

## --env-file：批量管理环境变量

当环境变量很多时，一个个写 `-e` 会让命令变得非常长。用 `--env-file` 把它们放到文件里：

创建文件 `mysql.env`：

```
MYSQL_ROOT_PASSWORD=my-secret-pw
MYSQL_DATABASE=myapp
MYSQL_USER=myuser
MYSQL_PASSWORD=userpass
TZ=Asia/Shanghai
```

然后：

```bash
docker run -d --name mysql-dev \
  --env-file ./mysql.env \
  mysql:8
```

注意：
- 每行一个变量，格式为 `变量名=值`
- 不需要引号包裹值（除非值本身包含引号）
- 空行和以 `#` 开头的行为注释
- 可以用多个 `--env-file` 加载多个文件，后面的会覆盖前面同名的

好处：
- 命令更短，更整洁
- env 文件可以加入 `.gitignore`，避免密码上传到代码仓库
- 不同环境可以用不同的 env 文件（`dev.env`、`prod.env`）

环境变量本身**不是**机密存储方案——任何能 `docker exec` 到容器里的人都能看到它们。真正敏感的信息应该用 Docker Secrets 或外部密钥管理服务（这是我们后面进阶章节会讲的内容）。

---

## 安全提醒：别把密码写在命令行里

```bash
# 不安全：密码会留在 shell 历史记录里
docker run -e MYSQL_ROOT_PASSWORD=SuperSecret123 mysql:8

# 你的 shell 历史记录（~/.bash_history）里会有这条命令
# 任何能看到你历史记录的人都能看到密码
```

安全做法：

```bash
# 方法 1：从文件读取
docker run --env-file ./mysql.env mysql:8

# 方法 2：提示输入（适合临时操作）
read -s MYSQL_PWD
docker run -e MYSQL_ROOT_PASSWORD=$MYSQL_PWD mysql:8

# 方法 3：docker compose 引用 .env（后续章节会讲）
```

---

## 动手试试

1. 创建环境变量文件并启动 MySQL：

```bash
# 创建 env 文件
cat > mysql.env << 'EOF'
MYSQL_ROOT_PASSWORD=learn123
MYSQL_DATABASE=testdb
MYSQL_USER=testuser
MYSQL_PASSWORD=testpass
EOF

# 用 env 文件启动 MySQL
docker run -d --name env-mysql --env-file ./mysql.env mysql:8

# 验证环境变量
docker exec env-mysql env | grep MYSQL
```

2. 验证数据库确实被创建了：

```bash
# 等 MySQL 启动完成（大概 15-30 秒）
# 然后进入容器连接数据库
docker exec -it env-mysql mysql -u root -plearn123

# 在 MySQL 提示符下执行：
SHOW DATABASES;
# 应该能看到 testdb

# 退出
EXIT;
```

3. 对比：用 `-e` 逐个传参启动另一个 MySQL：

```bash
docker run -d --name env-mysql2 \
  -e MYSQL_ROOT_PASSWORD=learn456 \
  -e MYSQL_DATABASE=otherdb \
  mysql:8

# 验证它们确实有不同的配置
docker exec env-mysql2 env | grep MYSQL
```

4. 清理：

```bash
docker rm -f env-mysql env-mysql2
rm mysql.env
```

---

## 本节小结

`-e` 和 `--env-file` 让你用同一套镜像适配不同环境——就像同一套餐厅运营流程，每个分店用不同的价格表和营业时间。环境变量是容器化应用配置的标准做法。

---

## 下一节预告

容器跑起来了，但万一出问题了怎么办？怎么看它有没有报错？怎么看它是怎么配置的？下一节讲 `docker logs` 和 `docker inspect`——你的容器诊断工具包。
