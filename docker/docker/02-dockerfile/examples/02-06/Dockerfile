# 展示 CMD 与 ENTRYPOINT 的区别

# 案例一：只有 CMD（默认命令，可被 docker run 后面参数覆盖）
FROM alpine:3.20 AS demo-cmd
CMD ["echo", "我是默认的CMD"]

# 案例二：只有 ENTRYPOINT（固定入口，不可被覆盖）
FROM alpine:3.20 AS demo-entrypoint
ENTRYPOINT ["echo", "我是固定的ENTRYPOINT"]

# 案例三：CMD + ENTRYPOINT 组合（黄金搭档）
FROM alpine:3.20 AS demo-combo
ENTRYPOINT ["echo", "前缀"]
CMD ["我是默认后缀"]

# 案例四：shell 形式 vs exec 形式对比
# shell 形式（进程不是 PID 1，信号处理有问题）
# CMD echo hello world

# exec 形式（推荐，进程是 PID 1，能正确接收信号）
# CMD ["echo", "hello", "world"]

# 案例五：实用例子——可配置端口的 HTTP 服务器
FROM python:3.12-alpine AS demo-practical
ENTRYPOINT ["python", "-m", "http.server"]
CMD ["8000"]

# 构建和测试命令：
# docker build --target demo-cmd -t demo-cmd .
# docker run demo-cmd               → 输出: 我是默认的CMD
# docker run demo-cmd echo 覆盖了   → 输出: 覆盖了
#
# docker build --target demo-entrypoint -t demo-ep .
# docker run demo-ep                → 输出: 我是固定的ENTRYPOINT
# docker run demo-ep 你好           → 输出: 我是固定的ENTRYPOINT 你好
#
# docker build --target demo-combo -t demo-combo .
# docker run demo-combo             → 输出: 前缀 我是默认后缀
# docker run demo-combo 覆盖了      → 输出: 前缀 覆盖了
#
# docker build --target demo-practical -t demo-practical .
# docker run -p 8000:8000 demo-practical           → 默认8000端口
# docker run -p 9090:9090 demo-practical 9090      → 覆盖为9090端口
