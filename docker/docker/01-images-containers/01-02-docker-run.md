# 01-02 docker run 详解 —— 用"开餐厅"理解容器参数

## 本节你会学到什么

- 掌握 `docker run` 最常用的六个参数：`-d`、`--name`、`--rm`、`-p`、`-e`、`-v`
- 用"开餐厅"类比理解容器的创建、命名、后台运行、清理
- 学会区分前台运行和后台运行
- 理解一次 `docker run` 到底创建了什么

---

## 开一家餐厅

我们开一家餐厅来理解 `docker run` 的各种参数。

假设你是一个餐饮连锁老板。你想开一家新店：

- `docker run` = **开一家新店**。你会基于一个"餐厅模板"（镜像）来装修和运营。
- `--name` = **给店起名字**。"北京路分店"还是"南京路分店"？不自己取的话，系统会随机分配一个名字。
- `-d` = **店铺在后台运营**。你自己不待在店里当前台，而是交给店长管理，你做别的事。
- `--rm` = **快闪店**。店一旦关门（停止），立刻拆除，不留痕迹。
- `-p` = **店门口对外营业的通道**。顾客从哪个门（端口）进来？
- `-e` = **店内的菜单/价格设置**。每家店可以有不同的配置（环境变量）。
- `-v` = **仓库**。店里的数据存在一个外部仓库里，店拆了数据还在。

下面我们一个一个详细讲。

---

## 最简形式：不带任何参数

```bash
docker run nginx
```

运行后，你的终端会被 Nginx 的日志"霸占"——光标一直在闪，你没法输入新命令。这是因为容器在**前台运行**，把你的终端当成了它的控制台。

按 `Ctrl + C` 可以停止容器。

---

## -d：后台运行（Detached mode）

```bash
docker run -d nginx
```

`-d` 是 detached 的缩写。意思是：让容器在后台运行，把终端还给我。

这就像你开了一家店，但你不想亲自站柜台（不想终端被霸占），而是请了一个店长（后台进程）来管。你继续忙别的事情。

运行后会输出一个长字符串——这是容器的 ID：

```
a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
```

---

## --name：给容器起名字

```bash
docker run -d --name my-nginx nginx
```

如果不指定 `--name`，Docker 会给容器随机分配一个两个单词组成的名字，比如 `inspiring_mirzakhani` 或 `brave_kepler`。虽然够可爱，但不好记。

指定名字后，后续操作可以直接用名字代替 ID：

```bash
# 用名字操作，比用 ID 方便多了
docker stop my-nginx
docker start my-nginx
docker logs my-nginx
```

就像你不会叫你的餐厅"编号 4215 号店"，你会叫它"北京路分店"——好记、好找。

---

## --rm：自动清理

```bash
docker run --rm -d --name temp-nginx nginx
```

`--rm` 意思是：当容器停止运行后，自动删除它。

适合：
- 临时测试用的容器
- 跑完就扔的一次性任务

不适合：
- 需要保留数据的容器（除非数据存在 volume 里）
- 需要反复启动停止的容器

就像快闪店：开一个月，到期自动拆除，不留任何东西。省得你事后还得惦记着去清理。

---

## -p：端口映射

```bash
docker run -d --name web -p 8080:80 nginx
```

`-p 宿主端口:容器端口` 把宿主机（你的电脑）的端口和容器内部的端口绑在一起。这样你访问 `http://localhost:8080` 就能到达容器里的 80 端口（Nginx 的默认端口）。

类比：你的餐厅（容器）内部有一个后厨入口（80 端口），但顾客（外部用户）不能直接进后厨。你需要一个前门（8080 端口），让顾客从前门进，自动引导到后厨。

端口映射的详细内容见第 5 节——那里有更深入的讲解。

---

## -e：环境变量

```bash
docker run -d --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  -e MYSQL_DATABASE=myapp \
  mysql:8
```

`-e` 把环境变量传入容器。很多官方镜像通过环境变量来配置——比如 MySQL 镜像需要用 `MYSQL_ROOT_PASSWORD` 来设置 root 密码。

类比：每家分店的菜单价格（环境变量）可能不一样——北京路店的咖啡定 25 块，南京路店定 28 块。环境变量让同一个镜像可以跑出不同的配置。

环境变量的详细内容见第 6 节。

---

## -v：数据卷挂载

```bash
docker run -d --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  -v mysql-data:/var/lib/mysql \
  mysql:8
```

`-v mysql-data:/var/lib/mysql` 创建了一个叫 `mysql-data` 的数据卷，挂载到容器内的 `/var/lib/mysql`（MySQL 存放数据文件的目录）。

为什么要这样做？因为默认情况下，容器删除后，容器内所有数据都会消失。把数据存到卷里，就像把餐厅的贵重食材和账本放在一个外部的保险仓库——哪天餐厅拆了，这些东西还在，新店可以接着用。

类比：你的餐厅（容器）每天的收入（数据）不放在店里，而是每天晚上送去银行金库（数据卷）。万一店铺被拆了，钱还在金库里。

---

## 综合示例：一条命令看清所有参数

```bash
docker run -d \
  --name my-web-app \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e DATABASE_URL=postgres://localhost/myapp \
  --rm \
  node:18-alpine \
  node -e "console.log('App started!'); setInterval(() => console.log('Running...'), 5000)"
```

这条命令做了这些事：
- `-d`：后台运行
- `--name my-web-app`：取名 my-web-app
- `-p 3000:3000`：映射 3000 端口
- `-e`：设置两个环境变量
- `--rm`：停止后自动删除
- `node:18-alpine`：基于 Node 18 的 alpine 镜像
- 最后那段是容器内要执行的命令

---

## 动手试试

1. 运行以下三条命令，观察差异：

```bash
# 前台运行——终端被"霸占"，按 Ctrl+C 停止
docker run --rm nginx

# 后台运行——终端还给你
docker run -d --name test-nginx nginx

# 查看容器状态
docker ps
```

2. 停止并清理：

```bash
docker stop test-nginx
docker rm test-nginx
```

3. 挑战：用一条 `docker run` 命令启动一个 MySQL 容器，要求：
   - 后台运行（`-d`）
   - 取名 `learn-mysql`（`--name`）
   - 设置 root 密码为 `learn123`（`-e`）
   - 使用 MySQL 8 镜像
   - （提示：参考上面 MySQL 的例子）

完成后，用 `docker stop learn-mysql && docker rm learn-mysql` 清理掉。

---

## 本节小结

`docker run` 就是开餐厅——`-d` 让店长帮你看店，`--name` 给店挂牌子，`--rm` 是快闪店到期拆，`-p` 是开前门迎客，`-e` 是调菜单价格，`-v` 是把钱存银行金库。

---

## 下一节预告

容器跑起来了，怎么让它停下来？怎么重新启动？怎么彻底删除？下一节讲容器的生命周期管理——docker stop、start、restart、rm 的完整操作。
