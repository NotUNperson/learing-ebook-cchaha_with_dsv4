# 04-09 综合练习：WordPress + MySQL 双容器应用

## 本节你会学到什么

- 将自定义网络和 Named Volume 组合起来搭建真实应用
- 理解容器间通过自定义网络实现 DNS 服务发现
- 掌握 WordPress + MySQL 的标准 Docker 部署方式
- 验证数据持久化和网络通信的完整链路

---

恭喜你一路杀到模块四的最后一节！前面你分别学了网络和存储，现在我们来把它们揉在一起，做一套真正能跑的博客系统：**WordPress + MySQL**。

---

## 整体架构

```
          浏览器
            |
       localhost:8080
            |
     +------+-------+
     |   WordPress   |  (wordpress 容器)
     |   :80         |
     +------+-------+
            |
       wp-network (自定义 bridge)
            |
     +------+-------+
     |   MySQL       |  (db 容器)
     |   :3306       |
     +------+-------+
            |
     wp-db-data (Named Volume)
     /var/lib/mysql
```

- WordPress 和 MySQL 通过自定义网络 `wp-network` 通信，WordPress 用容器名 `db` 就能找到 MySQL
- MySQL 的数据存在 Named Volume `wp-db-data` 里，容器删了数据不丢

---

## 分步部署

### 第一步：创建自定义网络

```bash
$ docker network create wp-network
```

这个网络自带了 DNS 解析，所以 WordPress 容器里可以直接用 `db` 这个名字连 MySQL，不用记 IP。

### 第二步：创建数据卷

```bash
$ docker volume create wp-db-data
```

也可以不预先创建，Docker 会在启动 MySQL 时自动创建。但显式创建能让你对卷的名字有掌控。

### 第三步：启动 MySQL

```bash
$ docker run -d \
  --name db \
  --network wp-network \
  -v wp-db-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=somewordpress \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=wordpress \
  mysql:8.0
```

细读一下各参数：
- `--network wp-network`：连入自定义网络
- `-v wp-db-data:/var/lib/mysql`：数据持久化
- MySQL 环境变量：创建数据库和用户，WordPress 会用到

### 第四步：启动 WordPress

```bash
$ docker run -d \
  --name wordpress \
  --network wp-network \
  -p 8080:80 \
  -e WORDPRESS_DB_HOST=db:3306 \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=wordpress \
  -e WORDPRESS_DB_NAME=wordpress \
  wordpress:latest
```

注意 `WORDPRESS_DB_HOST=db:3306` —— 直接用了容器名 `db`，这就是自定义网络 DNS 的神奇之处。如果用默认 bridge，你只能写成 `172.x.x.x:3306`，而且下次 IP 可能就变了。

### 第五步：验证

浏览器打开 `http://localhost:8080`，你应该看到 WordPress 安装界面。选择语言，设置站点名称和管理员账户，你的博客就上线了。

---

## 用脚本一键部署

每次都手动打这四步太烦了，写个脚本：

**examples/04-09/setup.sh**

```bash
#!/bin/bash
set -e

echo "=== 创建网络和卷 ==="
docker network create wp-network 2>/dev/null || true
docker volume create wp-db-data 2>/dev/null || true

echo "=== 启动 MySQL ==="
docker run -d \
  --name db \
  --network wp-network \
  -v wp-db-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=somewordpress \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=wordpress \
  mysql:8.0

echo "=== 等待 MySQL 就绪 ==="
until docker exec db mysqladmin ping -h localhost --silent; do
  echo "  等待 MySQL 启动..."
  sleep 2
done

echo "=== 启动 WordPress ==="
docker run -d \
  --name wordpress \
  --network wp-network \
  -p 8080:80 \
  -e WORDPRESS_DB_HOST=db:3306 \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=wordpress \
  -e WORDPRESS_DB_NAME=wordpress \
  wordpress:latest

echo "=== 完成！ ==="
echo "WordPress: http://localhost:8080"
echo ""
echo "查看日志: docker logs wordpress"
echo "停止服务: docker stop wordpress db"
echo "清理:     docker rm -f wordpress db"
```

**examples/04-09/teardown.sh**

```bash
#!/bin/bash
echo "=== 停止并删除容器 ==="
docker rm -f wordpress db 2>/dev/null || true

echo ""
echo "=== 容器已删除 ==="
echo "以下资源未被删除："
echo "  网络: docker network ls | grep wp-network"
echo "  卷:   docker volume ls | grep wp-db-data"
echo ""
echo "如需彻底清理，手动执行:"
echo "  docker network rm wp-network"
echo "  docker volume rm wp-db-data"
```

---

## 验证数据持久化

部署好 WordPress 之后，登录后台，发一篇测试文章。然后：

```bash
# 删掉容器
$ docker rm -f wordpress db

# 卷还在！
$ docker volume ls | grep wp-db-data
local     wp-db-data

# 重新启动（用 setup.sh 或手动启动）
$ docker run -d \
  --name db \
  --network wp-network \
  -v wp-db-data:/var/lib/mysql \
  ...  (其余参数同上)

$ docker run -d \
  --name wordpress \
  --network wp-network \
  ...

# 浏览器打开，你的文章还在！
```

这就是 Volume 的威力——容器死了，数据活着，像凤凰一样涅槃重生。

---

## 动手试试

1. 运行 `setup.sh`，部署 WordPress + MySQL
2. 登录 WordPress 后台，发一篇测试文章
3. 运行 `docker rm -f wordpress db` 删掉两个容器
4. 重新运行 `setup.sh`，检查数据是否还在
5. 额外挑战：不删卷，只删 WordPress 容器，然后升级 WordPress 镜像版本重新启动——能不能做到"无缝升级"？

---

## 本节小结

自定义网络让容器用名字找到彼此，Named Volume 让数据跨越容器生命周期——网络+存储的组合是 Docker 应用架构的基石。

---

## 下一节预告

手动打 `docker run` 命令管理两个容器就够累了，如果是五个、十个呢？下一模块我们进入 Docker Compose 的世界——一个 YAML 文件搞定一切。
