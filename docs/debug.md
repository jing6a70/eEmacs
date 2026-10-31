# dape 调试（modules/use-dape.el）

配置只有十几行：装包、把 `C-c g` 绑到 dape 自带的 `dape-global-map`。
其余命令都用 `M-x`。

前置：`M-x package-install RET dape`（依赖 `jsonrpc`，Emacs 29.3 已内置），
`gdb >= 14.1`，程序用 `-g -O0` 编译。

## 用法

`C-c g d`（或 `M-x dape`），minibuffer 里输入配置名和参数后回车：

```text
gdb :program "./demo"
```

| 键 | 作用 |
|---|---|
| `C-c g d` | 启动调试（`dape`） |
| `C-c g b` / `B` | 断点开关 / 删除全部断点 |
| `C-c g e` / `F` | 条件断点 / 函数断点 |
| `C-c g c` / `n` / `s` / `o` / `u` | 继续 / 下一步 / 步入 / 步出 / 运行到行 |
| `C-c g p` | 暂停 |
| `C-c g r` / `f` | 重启会话 / 重启当前帧 |
| `C-c g i` / `R` / `M` | 信息面板 / REPL / 反汇编 |
| `C-c g x` / `w` | 求值 / 监视 |
| `C-c g q` / `K` | 退出 / 杀掉会话 |
| `C-c g ?` | dape 菜单 |

断点以 overlay 显示在源码里；变量、栈、断点、线程在 `C-c g i` 打开的面板里。
布局默认左侧源码 + 右侧面板（`dape-buffer-window-arrangement 'right`）。

## 说明

- 配置里设置了 `defer-launch-attach t`：GDB 的 DAP 收到 launch 会立刻启动程序，
  断点随后下发会被以 `notStopped` 拒绝（GDB bug 32090），推迟 launch 才生效；
- dape 走 DAP，不依赖也不共用内置 gdb-mi；需要 MI 专属能力（core dump 等）
  时手动 `M-x gdb`，本配置不提供 `C-c d` 前缀；
- `*dape-repl*` 里可以直接输入 dape 命令（`continue`、`next`、`stack`、
  `breakpoints`、`restart`、`quit` 等），其它输入会发给调试器。
