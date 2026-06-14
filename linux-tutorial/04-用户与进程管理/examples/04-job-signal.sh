#!/bin/bash
# ============================================================
# 04-job-signal.sh - 前后台与信号示例脚本
# 配套章节：04-04-前后台与信号.md
# ============================================================

echo "============================================"
echo "  04-04 前后台与信号 示例"
echo "============================================"
echo ""

# -----------------------------------------------------------
# 一、信号类型速查
# -----------------------------------------------------------
echo "--- 1. 常用信号速查 ---"
echo "信号是 Linux 进程间通信的一种方式，就像给进程发通知。"
echo ""
echo "信号编号 | 信号名    | 默认行为     | 类比"
echo "--------|----------|-------------|------------------"
echo " 1      | SIGHUP   | 终止进程     | 挂断电话，通知进程重启"
echo " 2      | SIGINT   | 终止进程     | Ctrl+C，打断当前操作"
echo " 9      | SIGKILL  | 强制终止     | 直接拔电源，无法被忽略"
echo " 15     | SIGTERM  | 终止进程     | 发出关闭请求，可以被捕获"
echo " 18     | SIGCONT  | 继续运行     | 取消暂停"
echo " 19     | SIGSTOP  | 暂停进程     | 暂停，无法被忽略"
echo " 20     | SIGTSTP  | 暂停进程     | Ctrl+Z，暂停但可以忽略"
echo ""

echo "查看完整信号列表：kill -l"
echo ""

# -----------------------------------------------------------
# 二、查看 shell 的作业控制选项
# -----------------------------------------------------------
echo "--- 2. 作业控制概念 ---"
echo "正在运行 ./long_task.sh &"

# 我们创建一个后台任务来演示
cat > /tmp/long_task.sh << 'TASKEOF'
#!/bin/bash
echo "长任务启动了，PID: $$"
for i in {1..60}; do
    echo "  运行中... 第 $i 秒"
    sleep 1
done
echo "长任务正常结束。"
TASKEOF

chmod +x /tmp/long_task.sh

# 在后台启动这个任务
echo ""
echo "有 3 种方式启动后台任务："
echo "  1. command &       -- 在命令末尾加 &"
echo "  2. Ctrl+Z + bg     -- 先暂停，再放到后台继续"
echo "  3. nohup command & -- 忽略挂断信号，即使退出终端也继续运行"
echo ""

# -----------------------------------------------------------
# 三、演示：后台运行 &
# -----------------------------------------------------------
echo "--- 3. 演示：后台运行 & ---"
echo "启动后台任务："
/tmp/long_task.sh &
JOB_PID=$!
echo "后台任务 PID：$JOB_PID"
echo ""

echo "查看当前作业列表："
jobs
echo ""

echo "注意：后台任务的输出会和前台的输入混在一起。"
echo "建议：将后台任务的输出重定向到文件。"
echo "  ./long_task.sh > output.log 2>&1 &"
echo ""

# 等待后台任务结束或将其放到前台
echo "等待 3 秒，然后暂停后台任务..."
sleep 3

# 发送 SIGTSTP 信号模拟 Ctrl+Z 效果
kill -SIGTSTP $JOB_PID 2>/dev/null && echo "已向 PID $JOB_PID 发送 SIGTSTP 信号（模拟 Ctrl+Z）"
echo ""

echo "当前作业列表："
jobs
echo ""

# 让它在后台继续
echo "使用 bg 让暂停的作业继续在后台运行："
bg %1 2>/dev/null || echo "（bg 命令在脚本中可能无效，请在交互式终端中练习）"
echo ""

# 清理
echo "终止后台作业..."
kill -TERM $JOB_PID 2>/dev/null
sleep 1
# 如果还没死，强杀
kill -KILL $JOB_PID 2>/dev/null 2>&1
echo ""

# -----------------------------------------------------------
# 四、nohup 说明
# -----------------------------------------------------------
echo "--- 4. nohup -- 防挂断 ---"
echo "问题：你通过 SSH 登录服务器，启动了一个要跑很久的程序。"
echo "      如果你关闭 SSH 终端，程序也会跟着被终止。"
echo "      （因为终端发送 SIGHUP 信号给它的子进程）"
echo ""
echo "解决方案：nohup"
echo "  nohup ./long_task.sh &"
echo "  nohup ./long_task.sh > output.log 2>&1 &"
echo ""
echo "nohup 的意思是 'no hang up'，它让进程忽略 SIGHUP 信号。"
echo "这样即使你退出终端，进程也会继续运行。"
echo "输出默认写到 nohup.out 文件中。"
echo ""

# -----------------------------------------------------------
# 五、kill 命令详解
# -----------------------------------------------------------
echo "--- 5. kill 命令详解 ---"
echo "kill 的名字有误导性，它其实是 '发送信号'，不一定是 '杀死'。"
echo ""
echo "常用语法："
echo "  kill PID           -- 发送 SIGTERM（15），礼貌地请进程退出"
echo "  kill -9 PID        -- 发送 SIGKILL（9），强制立即杀死"
echo "  kill -2 PID        -- 发送 SIGINT（2），等于 Ctrl+C"
echo "  kill -1 PID        -- 发送 SIGHUP（1），挂断信号"
echo "  kill -15 PID       -- 发送 SIGTERM（15），与 kill PID 相同"
echo "  kill -STOP PID     -- 发送 SIGSTOP（19），暂停进程"
echo "  kill -CONT PID     -- 发送 SIGCONT（18），让暂停的进程继续"
echo "  killall 程序名     -- 给所有同名进程发送信号"
echo "  pkill 模式         -- 按名称/用户等模式匹配发送信号"
echo ""

echo "kill 的'杀人礼仪'三步走："
echo "  第1步：kill PID           （SIGTERM，给进程清理自己的机会）"
echo "  第2步：等几秒，检查进程还在不在"
echo "  第3步：如果还在，kill -9 PID （SIGKILL，直接毙掉）"
echo ""

# -----------------------------------------------------------
# 六、SIGTERM vs SIGKILL 对比
# -----------------------------------------------------------
echo "--- 6. SIGTERM vs SIGKILL -- 礼貌 vs 暴力 ---"

# 创建一个小测试程序来演示信号捕获
cat > /tmp/signal_test.sh << 'SIGEOF'
#!/bin/bash
# 这个脚本捕获 SIGTERM 信号，展示优雅退出
cleanup() {
    echo ""
    echo "收到 SIGTERM！正在保存数据并清理..."
    echo "数据已保存。"
    echo "清理完成，退出。"
    exit 0
}

# 设置信号处理器
trap cleanup SIGTERM

echo "信号测试程序已启动，PID: $$"
echo "你可以用以下命令测试："
echo "  kill -TERM $$   # 我会优雅退出"
echo "  kill -KILL $$   # 我会立即被杀死（无法捕获）"
echo ""

# 无限循环，等待信号
while true; do
    echo "  程序在运行... 等待信号中 (PID: $$)"
    sleep 2
done
SIGEOF

chmod +x /tmp/signal_test.sh

echo "演示："
echo "  1. 在一个终端运行：/tmp/signal_test.sh"
echo "  2. 在另一个终端运行：kill -TERM PID"
echo "     -> 程序会打印'收到 SIGTERM！正在保存数据并清理...'然后优雅退出"
echo "  3. 再次测试：kill -KILL PID"
echo "     -> 程序立即终止，来不及做任何清理"
echo ""
echo "这就是为什么说："
echo "  SIGTERM = 告诉餐厅'请最后一位客人吃完就关门'"
echo "  SIGKILL = 直接冲进餐厅把人撵出去，然后锁门"
echo ""

# -----------------------------------------------------------
# 七、disown 说明
# -----------------------------------------------------------
echo "--- 7. disown -- 放弃监护权 ---"
echo "场景：你启动了一个后台任务但忘了用 nohup。"
echo "      现在你退出终端，这个任务也会跟着消失。"
echo "      你还有补救的机会吗？"
echo ""
echo "有！用 disown："
echo "  Ctrl+Z              -- 先暂停它"
echo "  bg                   -- 放到后台继续运行"
echo "  disown -h %1        -- 放弃对这个作业的监护权"
echo "  然后你可以安全退出终端了"
echo ""
echo "disown 是把孩子从家庭户口本里踢出去："
echo "'从现在起你独立了，我退出也不影响你。'"
echo ""

# -----------------------------------------------------------
# 八、实用组合场景
# -----------------------------------------------------------
echo "--- 8. 实用组合场景 ---"
echo ""
echo "场景A - 你在 vim 里写代码，突然想回到终端看看："
echo "  Ctrl+Z  （vim 暂停，回到 bash）"
echo "  ... 干点别的事 ..."
echo "  fg      （回到 vim 继续写）"
echo ""
echo "场景B - SSH 断了，你的长任务怎么办？"
echo "  screen 或 tmux -- 这个后面章节会讲"
echo "  nohup ./long_task.sh > log.txt 2>&1 & -- 临时方案"
echo ""
echo "场景C - 批量杀进程："
echo "  pkill -f 'python.*app'    -- 杀所有命令行匹配这个模式的进程"
echo "  killall nginx             -- 杀所有名为 nginx 的进程"
echo ""

# 清理临时文件
rm -f /tmp/long_task.sh /tmp/signal_test.sh

echo "============================================"
echo "  示例脚本执行完毕"
echo "  请在交互式终端中练习 Ctrl+Z、fg、bg、"
echo "  jobs、kill 等命令！"
echo "============================================"
