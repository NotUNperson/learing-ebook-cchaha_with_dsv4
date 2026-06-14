# 07-01 Docker Desktop 磁盘空间回收

## 本节你会学到什么

- 理解 Docker Desktop 在 Windows 上的磁盘占用机制
- 掌握 `docker system prune` 系列命令清理无用数据
- 学会用 `diskpart compact vdisk` 压缩 VHDX 虚拟磁盘
- 建立定期清理磁盘空间的习惯

---

## 问题场景：C 盘怎么满了？

假设有一天，你兴冲冲地 `docker pull` 拉一个大镜像。网络不太好，拉到一半卡住了——Ctrl+C 取消。然后你重试，发现之前下载的 10 个 G 貌似不见了，又从头开始下。更气人的是，即使你把镜像删掉了，C 盘的可用空间也没有回来。

你心想："我明明 `docker image prune -a` 把没用的镜像删了啊？怎么磁盘空间还是被占了？"

这就好比你的衣柜。你把不穿的衣服扔掉了（`docker image prune`），衣柜里面确实腾出了空位。但衣柜本身是个充气帐篷——它在你塞满衣服的时候被撑大了，即使你把衣服拿走，帐篷的体积也不会缩小回去。你从外面看，它还是占满半个房间。

Docker Desktop 在 Windows 上的虚拟磁盘就是这种"充气帐篷"。

---

## 根因：VHDX 的"只膨胀不缩收"

Docker Desktop 在 Windows 上基于 WSL 2 运行。WSL 2 把 Linux 的文件系统存放在一个 **VHDX 虚拟磁盘文件**里。这个文件通常位于：

```
C:\Users\<用户名>\AppData\Local\Docker\wsl\data\ext4.vhdx
C:\Users\<用户名>\AppData\Local\Docker\wsl\disk\docker_data.vhdx
```

VHDX 格式有一个特性：**自动扩容，但不会自动缩容**。

用上面的衣柜类比：
- Docker 存储数据时，VHDX 会自动膨胀（充气）
- 你删掉镜像、容器后，VHDX 内部确实有空位了
- 但 VHDX 在 Windows 磁盘上占用的空间不会自动缩小（帐篷不回弹）
- "即使实际使用空间远低于最大值，系统仍会保留虚拟磁盘曾经达到的最大容量"

这和 Docker Desktop 本身无关，是 VHDX 格式的固有特性。

---

## 第一层清理：docker system prune

发现问题后，第一步当然是清掉 Docker 里确实没用的东西。这些命令你应该按顺序了解：

### 分项清理（推荐先试这个，可控）

```powershell
# 1. 删除所有未被容器使用的镜像
docker image prune -a -f

# 2. 删除所有已停止的容器（保留正在运行的）
docker container prune -f

# 3. 删除未被任何容器引用的卷
docker volume prune -f

# 4. 删除未被使用的自定义网络
docker network prune -f

# 5. 清理构建缓存
docker builder prune -f
```

### 一键清理（省事，但要注意）

```powershell
# 一条命令删除所有未使用的容器、网络、镜像和卷
docker system prune -a --volumes -f
```

### 查看当前磁盘使用情况

```powershell
docker system df
```

输出类似：
```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          15        3         7.2GB     5.1GB (70%)
Containers      3         1         1.2MB     500kB (41%)
Local Volumes   5         2         2.8GB     1.2GB (42%)
Build Cache     20        0         1.5GB     1.5GB (100%)
```

`RECLAIMABLE` 列告诉你执行 prune 后能回收多少空间。但请注意：**这部分空间只是"在 Docker 内部"被标记为可回收**，VHDX 文件在 Windows 磁盘上占用的空间不会因此缩小。

---

## 第二层清理：压缩 VHDX 虚拟磁盘（关键！）

如果 `docker system df` 已经显示没多少可回收的了，但 C 盘仍然紧张，就该对 VHDX 动手了。

### 完整步骤

**第 1 步：关闭所有 WSL**

打开 PowerShell（以管理员身份运行）：

```powershell
wsl --shutdown
```

这一步会关闭所有 WSL 发行版和 Docker Desktop。如果不关闭，VHDX 文件会被锁住，后面的压缩操作会失败。

**第 2 步：启动 diskpart**

```powershell
diskpart
```

执行后会弹出一个新的命令行窗口——diskpart 是 Windows 自带的磁盘管理工具。

**第 3 步：找到 VHDX 文件的实际路径**

Docker Desktop 的 VHDX 通常在这里：

```
C:\Users\你的用户名\AppData\Local\Docker\wsl\disk\docker_data.vhdx
```

如果你不确定，可以在文件资源管理器中直接搜索 `*.vhdx`，找到体积最大的那个，通常就是它。

**第 4 步：在 diskpart 中执行压缩**

在 diskpart 窗口中（注意路径替换成你的实际路径）：

```
select vdisk file="C:\Users\你的用户名\AppData\Local\Docker\wsl\disk\docker_data.vhdx"
```

按回车确认，diskpart 会提示已选中该虚拟磁盘。然后：

```
compact vdisk
```

等待进度跑完。时间长短取决于你的磁盘速度和 VHDX 文件大小，一般几分钟。

**第 5 步：退出 diskpart**

```
exit
```

**第 6 步：重新启动 Docker Desktop**

从开始菜单启动 Docker Desktop，一切恢复正常。

---

## 效果对比

根据实际案例（Windows 11 + Docker Desktop v4.34）：

| 操作 | 回收空间 |
|------|----------|
| `docker system prune` | 回收少量（Docker 内标记的空间） |
| `diskpart compact vdisk` | 回收了 20G（之前失败下载占的）+ 额外的 28G |
| **合计** | 约 **48G** |

差距非常明显。常规的 `docker prune` 只能清理逻辑上的垃圾数据，而 `diskpart compact` 是物理上把 VHDX 文件缩小回来。

---

## 预防：定期维护检查单

建议每 1-2 周做一次日常清理：

```
1. docker system df          → 查看空间占用
2. docker system prune -f    → 清理悬空资源（安全操作）
3. 每月一次：wsl --shutdown + diskpart compact vdisk
```

---

## 动手试试

1. 打开终端执行 `docker system df`，看看你目前的可回收空间有多少
2. 执行 `docker system prune -f`，再次运行 `docker system df` 对比变化
3. 如果你的 Docker Desktop 已经用了较长时间，到文件资源管理器中找到 `docker_data.vhdx` 文件，记下它的大小
4. （可选）按照本节步骤执行一次 `compact vdisk`，对比压缩前后 VHDX 文件的大小变化

---

## 本节小结

Docker Desktop 在 Windows 上的 VHDX 虚拟磁盘只会膨胀不会自动缩收，通过 `diskpart compact vdisk` 可以物理回收磁盘空间，这是普通 `docker prune` 做不到的。

---

## 下一节预告

光会清垃圾还不够，下一节我们来看看 Docker 的资源限制——怎样限制每个容器的 CPU 和内存，防止一个容器吃光整台机器。
