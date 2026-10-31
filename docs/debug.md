# GDB 调试（core/debug.el）

基于 Emacs 内置的 **GUD + gdb-mi**，不依赖第三方包。前置条件：

- 系统装有 `gdb`（`gdb --version` 能跑）；
- 程序用 `-g` 编译，最好再关掉优化（`-O0`），否则变量可能被优化掉。

## 快速开始

1. 打开要调试的源码，例如 `~/Desktop/c-debug-demo/main.c`；
2. `C-c d g`（或 `M-x gdb`），在 minibuffer 输入：

   ```text
   gdb -i=mi ./demo
   ```

3. 自动进入多窗口布局：源码 / `*Locals*` / `*Stack Frames*` / `*Breakpoints*` / `*Input/output*`；
4. `C-c d b` 在当前行打断点，`C-c d r` 运行，`C-c d n` 单步，`C-c d p` 打印表达式。

## 默认行为

| 设置 | 说明 |
|---|---|
| `gdb-many-windows t` | 启动即多窗口布局（`C-c d m` 可切换） |
| `gdb-show-main t` | 启动后直接停在 `main` 并显示源码 |
| `gdb-restore-window-configuration-after-quit t` | 退出调试后恢复原来的窗口布局 |
| `gdb-delete-out-of-scope t` | 变量离开作用域后从 `*locals of ...*` 移除 |
| `gdb-debuginfod-enable-setting nil` | 不询问也不下载 debuginfod 的源码/调试信息 |
| `gud-tooltip-mode 1` | 鼠标悬停显示变量值（仅 GUI） |

## 快捷键（`C-c d` 前缀）

| 按键 | 作用 |
|---|---|
| `C-c d g` | 启动 gdb |
| `C-c d b` / `C-c d B` | 当前行 打断点 / 删断点 |
| `C-c d t` | 当前行 打临时断点 |
| `C-c d r` | 从头运行 |
| `C-c d c` | 继续运行 |
| `C-c d n` / `C-c d s` | 单步跳过 / 单步进入（源码级） |
| `C-c d o` / `C-c d i` | 单步跳过 / 进入（指令级） |
| `C-c d f` | 运行到当前函数返回 |
| `C-c d u` | 运行到当前行 |
| `C-c d p` | 打印光标处的表达式 |
| `C-c d w` | 监视光标处的表达式 |
| `C-c d j` | 回到当前执行点（刷新源码窗口） |
| `C-c d m` | 切换多窗口布局 |
| `C-c d R` | 恢复窗口布局 |

> `gud-break` / `gud-next` 这些命令是 gdb 会话启动时才由 gdb-mi 定义的，所以
> 没有会话时按 `C-c d b` 会提示“还没有 GDB 会话”，而不是报 `void-function`。

## 多文件工程

多文件调试不需要额外配置，关键是知道四个入口：

| 想做的事 | 操作 |
|---|---|
| 程序停在别的文件里 | 不用操作，多窗口布局的源码窗口会自动切过去 |
| 看调用栈里另一帧的代码 | 在 `*stack frames of ...*` 里 `RET` 选帧，源码随之跨文件跳转 |
| 在另一文件里打断点 | 打开该文件，光标放到行上 `C-c d b`；或在 `*gud-...*` 里 `break file.c:行号` |
| 跳到已有断点 | 在 `*breakpoints of ...*` 里 `RET` |
| 想翻别的源码文件 | `C-x b` / `C-x C-b`（ibuffer），只换当前窗口的 buffer，布局不变 |
| 翻走之后回到断点处 | `C-c d j`（`gud-refresh`） |

配合 `M-x compile`（Makefile 用 `-g -O0`）和 `C-c d g` 就能覆盖“改代码 → 编译 → 打断点 → 单步”的整条链路。
示例工程：`~/Desktop/c-debug-demo`（main.c / score.c / stats.c，跨文件调用栈）。

## 备注

- GDB 命令可以直接在 `*gud-demo*`（名字随程序而变）缓冲区输入，例如条件断点
  `break score_find if strcmp(name, "carol") == 0`；
- 程序输出在 `*input/output of demo*`，GDB 交互在 `*gud-demo*`；
- 想看汇编/寄存器：`M-x gdb-display-disassembly-buffer`、`M-x gdb-display-registers-buffer`；
- 配套练习工程：`~/Desktop/c-debug-demo`（含一个空指针崩溃和一个求平均值的 bug）。
