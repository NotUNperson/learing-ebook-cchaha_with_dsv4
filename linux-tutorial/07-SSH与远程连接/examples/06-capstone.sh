#!/bin/bash
# ========================================
# 06-capstone.sh — tmux 会话保持演示脚本
# ========================================
# 功能：演示 tmux 的安装、会话管理、
#        窗口/窗格操作、常用快捷键速查、
#        以及一个自动恢复会话的配置脚本
# 用法：./06-capstone.sh [--setup] [--demo]
# ========================================

echo "==========================================="
echo "  tmux 终端复用器 — 综合演示"
echo "==========================================="
echo ""

# --------------------------------------------------
# 一、检查 tmux 是否安装
# --------------------------------------------------
echo "--- 1. 检查 tmux 安装状态 ---"
echo ""

if command -v tmux &>/dev/null; then
    TMUX_VERSION=$(tmux -V)
    echo "tmux 已安装：$TMUX_VERSION"
    echo "可执行文件：$(which tmux)"
else
    echo "tmux 未安装。"
    echo ""
    echo "安装方法："
    echo "  Ubuntu/Debian: sudo apt install tmux"
    echo "  CentOS/RHEL:   sudo yum install tmux"
    echo "  Fedora:        sudo dnf install tmux"
    echo "  Arch:          sudo pacman -S tmux"
    echo "  macOS:         brew install tmux"
fi

echo ""

# --------------------------------------------------
# 二、tmux 是什么 — 概念说明
# --------------------------------------------------
echo "--- 2. tmux 是什么？---"
echo ""

cat << 'EOF'
tmux 的全称是 Terminal Multiplexer（终端复用器）。

类比：云端桌面 / 永不关机的电脑

普通 SSH：
  你登录 → 工作 → 退出（或网络断开）→ 工作全部丢失
  就像你把所有文件放在临时桌面上，下班时全清空了

使用 tmux 后：
  你登录 → 启动 tmux 会话 → 在里面工作 → 网络断开！
  → 重新 SSH 登录 → 重新连接 tmux 会话 → 一切都在！
  就像你把工作放在云端桌面上，随时从任何设备接续

tmux 的核心能力：
  1. 会话保持（session persistence）
     断开 SSH 后工作状态不丢失，重新连接后一切照旧

  2. 多窗口/多窗格（windows / panes）
     一个 SSH 连接里同时看多个终端，无需开多个 SSH 窗口

  3. 会话共享（session sharing）
     两个人同时连接同一个 tmux 会话，看到同样的屏幕
     （结对编程 / 远程协助的神器）

tmux 的层级结构：
  Session（会话）
    └── Window（窗口，类似浏览器标签页）
          └── Pane（窗格，窗口内的分屏）

类比：
  Session = 一栋房子
  Windows = 房子里的不同房间（客厅、书房、卧室）
  Panes   = 一个房间里的不同区域（可以同时做多件事）
EOF

echo ""

# --------------------------------------------------
# 三、基本操作演示
# --------------------------------------------------
echo "--- 3. tmux 基本操作 ---"
echo ""

cat << 'EOF'
==================== 会话管理 ====================

  tmux new -s mysession
      创建新会话，名称叫 mysession
      类比：租了一间新的云端办公室

  tmux ls
      列出所有活动会话
      类比：看看你有哪些办公室还在用

  tmux attach -t mysession
  tmux a -t mysession
      重新连接（attach）到已有的 mysession 会话
      类比：刷卡回到你的办公室

  tmux kill-session -t mysession
      彻底关闭一个会话
      类比：退租这个办公室

  Ctrl+B  d
      从当前会话中"脱离"（detach），会话在后台继续运行
      类比：锁门离开办公室，灯还亮着，东西还在

==================== 窗口管理 ====================

  Ctrl+B  c
      在当前会话中创建新窗口
      类比：在你的房子里多开一个房间

  Ctrl+B  n
      切换到下一个窗口 (next)
  Ctrl+B  p
      切换到上一个窗口 (previous)
  Ctrl+B  数字键
      直接跳到第 N 个窗口

  Ctrl+B  &
      关闭当前窗口（需要确认）

  Ctrl+B  ,
      重命名当前窗口

==================== 窗格管理 ====================

  Ctrl+B  %       左右分屏（创建一个左右并列的新窗格）
  Ctrl+B  "       上下分屏（创建一个上下排列的新窗格）

  Ctrl+B  方向键   切换到相邻窗格
  Ctrl+B  o        切换到下一个窗格

  Ctrl+B  x        关闭当前窗格（需要确认）
  Ctrl+B  z        当前窗格全屏 / 恢复

  Ctrl+B  按住不放 + 方向键  调整窗格大小

==================== 其他常用 ====================

  Ctrl+B  [       进入复制模式（可以滚动查看历史输出）
                  在复制模式中：vi 风格 hjkl 移动，q 退出
                  PageUp/PageDown 也能用

  Ctrl+B  ?       显示所有快捷键（救命键！按 q 退出帮助）

  tmux source-file ~/.tmux.conf
                  重新加载 tmux 配置文件
EOF

echo ""

# --------------------------------------------------
# 四、常用快捷键表格
# --------------------------------------------------
echo "--- 4. 常用快捷键速查表 ---"
echo ""

cat << 'EOF'
所有快捷键都需要先按 前缀键 Ctrl+B，松开后再按后面的键。

==================== 会话级 (Session) ====================
+-----------------+------------------------------+
| 快捷键          | 作用                         |
+-----------------+------------------------------+
| Ctrl+B  d       | 脱离会话（会话继续后台运行）  |
| Ctrl+B  :       | 进入命令模式                  |
| Ctrl+B  s       | 列出并切换会话                |
| Ctrl+B  $       | 重命名当前会话                |
+-----------------+------------------------------+

==================== 窗口级 (Window) ====================
+-----------------+------------------------------+
| 快捷键          | 作用                         |
+-----------------+------------------------------+
| Ctrl+B  c       | 创建新窗口                   |
| Ctrl+B  n       | 下一个窗口                   |
| Ctrl+B  p       | 上一个窗口                   |
| Ctrl+B  0~9     | 跳到第 N 个窗口              |
| Ctrl+B  &       | 关闭窗口（需确认）           |
| Ctrl+B  ,       | 重命名窗口                   |
| Ctrl+B  w       | 列出所有窗口                 |
| Ctrl+B  f       | 按名称查找窗口               |
+-----------------+------------------------------+

==================== 窗格级 (Pane) ====================
+-----------------+------------------------------+
| 快捷键          | 作用                         |
+-----------------+------------------------------+
| Ctrl+B  %       | 垂直分屏（左右分）           |
| Ctrl+B  "       | 水平分屏（上下分）           |
| Ctrl+B  方向键  | 切换到相邻窗格               |
| Ctrl+B  o       | 切换到下一窗格               |
| Ctrl+B  ;       | 切换到上一个活动窗格         |
| Ctrl+B  x       | 关闭窗格（需确认）           |
| Ctrl+B  z       | 窗格全屏 / 恢复             |
| Ctrl+B  !       | 将窗格提升为独立窗口         |
| Ctrl+B  空格    | 切换窗格布局                 |
| Ctrl+B  {       | 向前交换窗格位置             |
| Ctrl+B  }       | 向后交换窗格位置             |
| Ctrl+B  Ctrl+方向键 | 调整窗格大小（按住Ctrl） |
| Ctrl+B  Alt+方向键  | 调整窗格大小（按住Alt）   |
+-----------------+------------------------------+

==================== 复制模式 (Copy Mode) ====================
+-----------------+------------------------------+
| 快捷键          | 作用                         |
+-----------------+------------------------------+
| Ctrl+B  [       | 进入复制模式                 |
| (复制模式中)    |                              |
|   Space         | 开始选择                     |
|   Enter         | 复制选中文本并退出           |
|   q             | 退出复制模式                 |
|   hjkl          | 移动光标（vi 风格）          |
|   / 搜索词      | 向下搜索                     |
|   ? 搜索词      | 向上搜索                     |
|   g             | 跳到历史最开头               |
|   G             | 跳到历史最末尾               |
+-----------------+------------------------------+

==================== 其他 ====================
+-----------------+------------------------------+
| 快捷键          | 作用                         |
+-----------------+------------------------------+
| Ctrl+B  ?       | 显示所有快捷键（救命键！）   |
| Ctrl+B  t       | 显示大钟表（有趣！）         |
| Ctrl+B  :       | 进入 tmux 命令模式           |
+-----------------+------------------------------+

命令模式中常用命令：
  :new -s NAME    创建新会话
  :kill-session   关闭当前会话
  :source-file ~/.tmux.conf  重载配置
EOF

echo ""

# --------------------------------------------------
# 五、生产场景：tmux 实战工作流
# --------------------------------------------------
echo "--- 5. tmux 实战工作流 ---"
echo ""

cat << 'EOF'
场景：你在远程服务器上运行长时间任务

======== 没有 tmux 的灾难 ========
  ssh user@server
  ./long_running_script.sh
  # ... 脚本跑了 30 分钟 ...
  # 你的笔记本没电了，或 WiFi 断了
  # 连接中断！脚本被杀死！一切从头开始...

======== 使用 tmux 的正确姿势 ========

  1. SSH 登录服务器：
     ssh user@server

  2. 创建或进入工作会话：
     tmux new -s deploy
     # 或如果已有会话：tmux a -t deploy

  3. 在 tmux 中运行你的任务：
     ./deploy_to_production.sh

  4. 放心地断开（主动或被动）：
     a) 主动：Ctrl+B 然后按 d
     b) 被动：关掉终端、盖笔记本、网络断了

  5. 重新连接（可能几小时后）：
     ssh user@server
     tmux a -t deploy
     # 一切都在！脚本的输出完整保留！

模板：tmux 工作流脚本

  #!/bin/bash
  # 连接到远程服务器并自动进入 tmux 会话
  SESSION_NAME="work_$(date +%Y%m%d)"

  ssh user@server -t "
      tmux has-session -t $SESSION_NAME 2>/dev/null &&
      tmux attach -t $SESSION_NAME ||
      tmux new -s $SESSION_NAME
  "

  # -t 强制分配伪终端（tmux 需要）
  # 先检查会话是否存在，存在则 attach，不存在则 new
EOF

echo ""

# --------------------------------------------------
# 六、tmux 配置建议
# --------------------------------------------------
echo "--- 6. 推荐的 ~/.tmux.conf 配置 ---"
echo ""

cat << 'EOF'
创建 ~/.tmux.conf 文件，让 tmux 更好用：

  # ========================================
  # ~/.tmux.conf — tmux 配置文件
  # ========================================

  # 把前缀键从 Ctrl+B 改为 Ctrl+A
  # （很多人觉得 Ctrl+A 比 Ctrl+B 好按，因为 A 在 B 旁边更顺手）
  # set -g prefix C-a
  # unbind C-b
  # bind C-a send-prefix

  # 启用鼠标支持
  # （可以用鼠标点击切换窗格、调整窗格大小、滚动）
  set -g mouse on

  # 窗口编号从 1 开始（而不是 0）
  set -g base-index 1
  setw -g pane-base-index 1

  # 减少按 Escape 的等待时间
  set -sg escape-time 10

  # 增大历史回滚行数
  set -g history-limit 50000

  # 启用 256 色显示
  set -g default-terminal "screen-256color"

  # 状态栏美化
  set -g status-bg colour235
  set -g status-fg white

  # 左右分屏用 |（管道符）而不是 %
  bind | split-window -h
  # 上下分屏用 -（减号）而不是 "
  bind - split-window -v

  # 用 vi 风格键在窗格间移动
  bind h select-pane -L
  bind j select-pane -D
  bind k select-pane -U
  bind l select-pane -R

修改后重载配置：
  tmux source-file ~/.tmux.conf
  # 或在 tmux 中按 Ctrl+B :source-file ~/.tmux.conf
EOF

echo ""

# --------------------------------------------------
# 七、tmux + SSH 自动连接脚本
# --------------------------------------------------
echo "--- 7. 自动连接脚本生成 ---"
echo ""

AUTO_SCRIPT="/tmp/tmux_auto_connect_$$.sh"

cat > "$AUTO_SCRIPT" << 'SCRIPTEOF'
#!/bin/bash
# ========================================
# tmux-auto-connect.sh
# 自动 SSH 到远程并 attach 或创建 tmux 会话
# ========================================
# 用法：
#   ./tmux-auto-connect.sh user@host [session-name]
# 示例：
#   ./tmux-auto-connect.sh deploy@prod-server
#   ./tmux-auto-connect.sh deploy@prod-server logs
# ========================================

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "用法：$0 <user@host> [session-name]"
    echo "示例：$0 deploy@10.0.0.50"
    echo "      $0 deploy@10.0.0.50 monitoring"
    exit 2
fi

REMOTE="$1"
SESSION_NAME="${2:-main}"

echo "连接到 $REMOTE，会话：$SESSION_NAME"
echo "如果会话已存在会自动 attach，否则创建新会话"
echo ""

# -t 分配伪终端（tmux 必须）
# 先尝试 attach，失败则创建新会话
ssh -t "$REMOTE" "
    if tmux has-session -t '$SESSION_NAME' 2>/dev/null; then
        echo '>>> 已有会话 $SESSION_NAME，重新连接...'
        tmux attach -t '$SESSION_NAME'
    else
        echo '>>> 创建新会话 $SESSION_NAME...'
        tmux new -s '$SESSION_NAME'
    fi
"
SCRIPTEOF

chmod +x "$AUTO_SCRIPT"
echo "自动连接脚本已生成：$AUTO_SCRIPT"
echo ""
echo "使用方法："
echo "  $AUTO_SCRIPT user@your-server"
echo "  $AUTO_SCRIPT user@your-server mysession"
echo ""

# --------------------------------------------------
# 八、tmux vs screen 简单对比
# --------------------------------------------------
echo "--- 8. tmux vs screen ---"
echo ""

cat << 'EOF'
GNU Screen 是 tmux 的前辈，功能类似。目前 tmux 是主流选择。

+------------+---------------+----------------+
| 特性       | tmux          | GNU Screen     |
+------------+---------------+----------------+
| 开发活跃度 | 活跃          | 较少更新       |
| 配置文件   | ~/.tmux.conf  | ~/.screenrc    |
| 窗格分屏   | 原生支持      | 需要补丁       |
| 状态栏     | 更灵活美观    | 较基础         |
| 会话共享   | 原生支持      | 支持(multiuser)|
| 学习曲线   | 中等          | 中等           |
+------------+---------------+----------------+

除非你在维护 legacy 系统只能用 screen，否则选 tmux。
EOF

echo ""

# --------------------------------------------------
# 九、常见问题
# --------------------------------------------------
echo "--- 9. 常见问题与解决 ---"
echo ""

cat << 'EOF'
Q1: tmux ls 显示 "no server running on ..."
A1: 这是正常的。说明当前没有任何 tmux 会话在运行。
    启动一个新会话即可：tmux new -s mysession

Q2: 快捷键 Ctrl+B 没反应？
A2: 先确认你没有"多按"了。正确的按法是：
    按住 Ctrl，点一下 B，松开，再按后面的键。
    不是 Ctrl+B 和其他键同时按住。

Q3: tmux 中鼠标滚轮不能滚动？
A3: 在 ~/.tmux.conf 中加：set -g mouse on
    或在不改配置的情况下，按 Ctrl+B [ 进入复制模式再滚动

Q4: 复制 tmux 里的内容到系统剪贴板？
A4: 这取决于你的环境。Linux 桌面通常需要 xclip 辅助：
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -sel clip -i"
    macOS 替换 xclip 为 pbcopy

Q5: tmux 里的颜色不好看？
A5: 在 ~/.tmux.conf 中加：
    set -g default-terminal "screen-256color"
    同时确保你的终端模拟器支持 256 色
EOF

echo ""
echo "==========================================="
echo "  动手练习建议"
echo "==========================================="
echo ""
echo "  1. 安装 tmux：sudo apt install tmux"
echo "  2. 创建第一个会话：tmux new -s test"
echo "  3. 在会话中分屏：Ctrl+B %（左右分），Ctrl+B \"（上下分）"
echo "  4. 在各个窗格中运行不同命令（如 top、htop、watch date）"
echo "  5. Ctrl+B d 脱离会话，然后 tmux a -t test 重新连接"
echo "  6. 创建 ~/.tmux.conf，至少启用鼠标支持"
echo "  7. SSH 到远程服务器并重复以上步骤，体验"断线重连""
echo "  8. 在两个终端 attach 同一个会话，观察同步效果"
echo "  9. 练习快捷键：建窗口(c)、切换窗口(n/p)、关闭窗口(&)"
echo "  10. 在远程 tmux 中运行一个循环脚本，断开重连看它还在跑"
