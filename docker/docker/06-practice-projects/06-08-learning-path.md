# 06-08 学习路线与进阶资源

## 本节你会学到什么

- 看清从 Docker 到 Kubernetes 的完整路线图，知道自己现在站在哪个位置
- 了解 Docker Swarm 的定位：它还没死，但只在特定场景下有用
- 建立 Service Mesh 的初步认知，知道它解决什么问题
- 获取推荐书籍、在线资源、社区，知道下一步该学什么、去哪学
- 了解如何参与开源容器项目，把学习成果转化为实际贡献

---

本书到这里，你已经完整掌握了 Docker 的核心知识体系：

```
00 导论：为什么我们需要容器
01 镜像与容器：docker run 背后的魔法
02 Dockerfile：把自己的应用打包
03 镜像管理：registry、标签、分发
04 网络与存储：容器间通信和数据持久化
05 Docker Compose：编排多容器应用
06 实战项目：从开发到 CI/CD 的全流程
```

但这只是起点。容器生态像一棵大树，Docker 是树干。树干之上，长出 Kubernetes、Service Mesh、Serverless 等枝干。下面我帮你理清路线。

---

## 路线图：从 Docker 出发的三条岔路

当你掌握了单机容器操作后，摆在面前的有三条路：

```
                      Docker（你已经在这里）
                      /      |        \
                     /       |         \
            Kubernetes    Swarm     Serverless
           （容器编排）  （轻量编排）（无服务器）
              /    \
             /      \
      Service Mesh   GitOps
      （服务网格）   （声明式部署）
```

**路径一：Kubernetes（绝大多数人的选择）**

Kubernetes 解决了 Docker 的最大短板——**多台机器的容器管理**。Docker 在单机上很强，但你的应用要跑在 20 台服务器上，容器需要跨机器调度、负载均衡、自动扩缩容、滚动更新——这些 Docker 自己做不到，Kubernetes 就是为解决这些而生的。

如果你只能选一条路，选这条路。

**路径二：Docker Swarm（适合小团队、简单场景）**

Swarm 是 Docker 内置的集群管理工具。它的优势是**零学习成本**——你不需要学新的概念，用 docker-compose 文件改几个参数就能部署到多台机器。适合 3-5 台服务器、不需要复杂调度逻辑的小团队。

它适合谁？假设你开了一家小餐厅，只有 3 个灶台、5 个厨师，一个领班就能安排得明明白白。Swarm 就是那个领班——简单直接，不需要一个庞大的中央厨房管理系统（Kubernetes）。

**路径三：Serverless / Fargate（追求零运维）**

如果你不想管服务器、不想管集群、不想管扩缩容，只想把容器丢上去跑就行，AWS Fargate、Google Cloud Run 就是你的选择。你把镜像推上去，云平台帮你处理剩下的一切——按调用次数或 CPU/内存使用量计费。

---

## Kubernetes 入门路线（4-6 个月）

不要一上来就装 Kubernetes。它的安装和配置极其复杂，新手很容易在环境搭建阶段就放弃。正确的顺序是：

### 第一阶段：概念理解（2-3 周）

先用 Minikube 或 kind 在本地跑一个单节点 K8s 集群，理解以下核心概念：

- **Pod**：K8s 的最小调度单元。一个 Pod 里可以有一个或多个容器。为什么要有 Pod？因为有时候两个容器需要共享网络和存储（比如一个 Web 容器 + 一个日志收集 sidecar）。Pod 就是它们的"同宿舍"。
- **Deployment**：管理 Pod 的生命周期。你声明"我要 3 个副本"，Deployment 保证不管哪个 Pod 挂了，总数始终是 3。类比：你请了 3 个收银员，不管谁请假，店里始终有 3 个人在岗。
- **Service**：给 Pod 提供稳定的访问入口。Pod 会销毁重建，IP 会变，Service 提供一个不变的虚拟 IP 和 DNS 名称。类比：外卖平台上的"店铺页面"地址不变，但背后做菜的厨师可以换班。
- **Ingress**：把外部流量路由到 Service。就是 K8s 世界的 Nginx 反向代理。
- **ConfigMap / Secret**：配置管理。比环境变量更结构化，支持热更新。

### 第二阶段：动手实践（4-6 周）

用 K3s 在 2-3 台树莓派或云服务器上搭一个真实集群，部署你之前写的全栈应用（06-03 那个 Express + React + PostgreSQL + Redis 项目）。

```bash
# K8s 化后的目录结构
k8s/
  deployment.yaml    # 定义 Pod 模板和副本数
  service.yaml       # 定义服务入口
  ingress.yaml       # 定义外部访问规则
  configmap.yaml     # 非敏感配置
  secret.yaml        # 数据库密码等敏感信息
  pvc.yaml           # 持久化存储卷
```

### 第三阶段：生产技能（2-3 个月）

- **Helm**：K8s 的包管理器。把一堆 YAML 打包成 chart，一键部署、升级、回滚。
- **GitOps（ArgoCD / Flux）**：Git 仓库是唯一真相来源。改了 Git 里的配置，集群自动同步。
- **监控（Prometheus + Grafana）**：知道你的 Pod 吃了多少内存、请求延迟多少毫秒。
- **日志（Loki 或 ELK）**：所有 Pod 的日志集中收集、索引、搜索。
- **Service Mesh（Istio / Linkerd）**：见下文。

---

## Docker Swarm 简介：它还没死

很多人说 Swarm 死了，其实没有。Docker Swarm 适合的场景非常明确：

**用 Swarm 的条件：**
- 你的团队小于 10 人
- 服务器不超过 10 台
- 不需要精细的调度策略（比如"把数据库和缓存 Pod 放在不同物理机上"）
- 不想花 2 个月学 Kubernetes

**Swarm 的入门只需要 3 个命令：**

```bash
# 初始化集群（在 manager 节点上跑）
docker swarm init

# 其他节点加入集群
docker swarm join --token <token> <manager-ip>:2377

# 部署服务（直接用 compose 文件！）
docker stack deploy -c docker-compose.yml myapp
```

是的，你没看错——docker-compose.yml 文件加几行 deploy 配置，就能直接在 Swarm 集群上部署。

```yaml
# 给 compose 文件加 deploy 配置即可用于 Swarm
services:
  app:
    image: myapp:latest
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 256M
      restart_policy:
        condition: on-failure
```

总结：大团队、复杂需求 -> Kubernetes。小团队、简单需求 -> Swarm 轻松搞定。

---

## Service Mesh 概念入门

当你的微服务从 3 个变成 30 个甚至 300 个，两个新的问题出现了：

1. **服务间通信**：A 调用 B、B 调用 C、C 调用 D……网络故障、超时、重试、熔断怎么写？每个服务自己实现一遍吗？
2. **可观测性**：一个请求经过了 5 个服务，哪个环节慢了？怎么追踪？

Service Mesh 用一个 sidecar 代理（通常是 Envoy）接管所有服务间流量。应用代码不需要知道"怎么调用"、"怎么重试"、"怎么熔断"——sidecar 帮你做了。

**类比：** Service Mesh 就像公司前台。以前你要找张三，你得自己记住张三在几楼几室、他请假了没、他工位换了没。有了前台之后，你只需要说"我找张三"，前台负责查位置、拨分机、如果没人接告诉你稍等——所有路由逻辑对你是透明的。

**入门资源：**

- **Linkerd**：最轻量的 Service Mesh，15 分钟上手，适合入门
- **Istio**：功能最全，但复杂度也最高，适合大公司
- **Cilium**：基于 eBPF 的新一代网络方案，性能更高

建议从 Linkerd 开始，它的 [getting started 文档](https://linkerd.io/2.14/getting-started/) 写得很友好。

---

## 推荐资源

### 书籍

| 书名 | 适合场景 |
|------|---------|
| 《Docker 实践》（Docker in Practice） | 读完本书后的进阶，200+ 个小技巧 |
| 《Kubernetes in Action》 | K8s 入门圣经，Marko Luksa 著 |
| 《Kubernetes Patterns》 | K8s 设计模式，适合有一定经验的读者 |
| 《Istio in Action》 | Service Mesh 实战 |

### 在线资源

- **Play with Docker** (labs.play-with-docker.com)：浏览器里跑 Docker，无需本地安装
- **Katacoda** (已被 O'Reilly 收购，搜索 "Katacode Docker scenarios")：交互式 Docker 学习环境
- **Kubernetes 官方教程** (kubernetes.io/docs/tutorials/)：有中文版
- **CNCF Landscape** (landscape.cncf.io)：云原生全景图，帮你理解这个生态有多大

### 值得关注的项目与社区

- **Docker 官方 GitHub** (github.com/docker)
- **awesome-docker** (github.com/veggiemonk/awesome-docker)：Docker 资源大合集
- **CNCF** (cncf.io)：云原生计算基金会，Docker、Kubernetes、Prometheus 都在这里

---

## 如何参与开源容器项目

参与开源不一定要写代码。以下是一些入门途径：

**初级：文档贡献**
- 翻译英文文档为中文
- 修正文档中的拼写错误或过时信息
- 在 Docker、Kubernetes 项目的 GitHub 上找 `good first issue` 标签

**中级：测试与反馈**
- 下载 RC 版本提前测试，上报 bug
- 在 GitHub Issues 中帮助复现别人报告的问题

**高级：代码贡献**
- 从 `good first issue` 开始，找一两行代码的修改
- 阅读 CONTRIBUTING.md，了解代码规范
- 加入项目的 Slack/Discord 社区，先潜水观察再发言

**推荐起点项目：**
- **docker/cli**：Docker CLI 是用 Go 写的，代码结构清晰
- **containerd**：容器运行时的核心，业界标准
- **buildpacks**：不用写 Dockerfile 也能构建镜像，CNCF 孵化项目

---

## 动手试试

**目标：** 规划你自己的学习路线。

1. 拿出一张纸（或打开笔记软件），写下你当前的工作场景：是一个人开发还是团队协作？应用是单体还是微服务？部署在云上还是自建机房？
2. 对照本节的路线图，标注你当前所在的位置
3. 列出接下来 3 个月你想学的 3 件事（不要太多），并写出每件事预计花多少时间

例如：
```
当前：单机 Docker，个人项目
3个月目标：
  1. 学会 docker-compose 编排（2周）
  2. 本地搭建 Minikube + 部署全栈应用（4周）
  3. 学习 GitHub Actions CI/CD（2周）
```

预计耗时：5 分钟。

---

## 本节小结

Docker 是容器世界的"普通话"——学会了它，你在任何云平台、任何编排工具里都能写出标准的容器化应用。从 Docker 出发，选一条路（Kubernetes 是大道），稳扎稳打往前走，别急躁。

---

> 全书正文到此结束。感谢你一路读到这里。
>
> 容器技术更新很快，半年后的新版本可能会让书中的某些命令发生变化。保持学习的习惯，关注官方文档，多动手实践——这才是掌握容器技术的唯一捷径。
