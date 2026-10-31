# dape 调试（modules/use-dape.el）

只用 [dape](https://elpa.gnu.org/packages/dape.html)（GNU ELPA）这一个第三方包，走
Debug Adapter Protocol，对 C/C++ 调用 `gdb --interpreter=dap`。

前置条件：

- `dape` 已安装（依赖 `jsonrpc`）：`M-x package-install RET dape`；
- `gdb >= 14.1`（DAP 支持）；远程 ARM 目标另需 `gdb-multiarch`；
- 程序用 `-g` 编译，最好 `-O0`。

> 配置里已经**不再提供 gdb-mi 的 `C-c d` 前缀**。需要 MI 能力时可以手动
> `M-x gdb`，但日常调试统一走 `C-c g`。

## 快速开始（本地）

1. 打开源码，或直接在工程根目录；
2. `C-c g g` → 自动从 Makefile 的 `TARGET` 猜出可执行文件并预填
   `gdb :program "..."`，回车即可；
3. 程序停在启动处，之后用 `C-c g b` 打断点、`C-c g c` 继续。

## 快捷键（`C-c g` 前缀）

| 按键 | 作用 |
|---|---|
| `C-c g g` | 本地启动（自动猜程序） |
| `C-c g t` | 远程 attach 到 gdbserver（见下文） |
| `C-c g b` / `B` | 当前行 断点开关 / 删除 |
| `C-c g c` / `n` / `s` / `o` / `u` | 继续 / 单步跳过 / 步入 / 步出 / 运行到当前行 |
| `C-c g p` | 暂停 |
| `C-c g r` / `f` | 重跑整个会话 / 重跑到当前帧（会话结束后也能用） |
| `C-c g e` / `w` | 求值表达式 / 监视光标处表达式 |
| `C-c g i` / `R` / `d` | 信息面板 / REPL / 反汇编 |
| `C-c g l` | 布局在 `'right`（右侧面板）和 `'gud`（gdb-mi 风格）之间切换 |
| `C-c g m` | dape 多窗口布局开关 |
| `C-c g q` / `k` | 结束会话 / 杀掉会话 |
| `C-c g ?` | dape 菜单 |

布局默认是右侧信息面板（变量/栈/断点/线程）+ 左侧源码；`C-c g l` 可切回
gdb-mi 的那种布局（下次启动生效）。

## 断点

- 源码里光标放目标行，`C-c g b`；`C-c g B` 删除；断点会在源码里画 overlay；
- 条件断点：`M-x dape-breakpoint-expression`（当前行 + 表达式）；
- 断点/线程/栈都在 `C-c g i` 打开的信息面板里，回车可跳转；
- 下断点前建议先确保会话停着（`C-c g p`），否则要等程序停下来才生效。

## 重跑

- `C-c g r`（`dape-restart`）：复用上次配置重启；
- `C-c g f`：只重跑到当前帧；
- 也可以在 `*dape-repl*` 里敲 `restart`。

## 远程 / ARM 交叉调试（gdbserver）

GDB 15 的 DAP `attach` 请求支持 `:target` 参数，内部执行 `target remote`，
所以 dape **原生**就能连 gdbserver，不需要额外脚本。

### 准备

- 本地装 `gdb-multiarch`（本机 `/usr/bin/gdb` 只支持 x86_64）：

  ```sh
  sudo apt install gdb-multiarch
  ```

- 目标上启动 gdbserver（armhf）：

  ```sh
  gdbserver :1234 /opt/QtMc/GreenPulse
  # 或 attach 已运行的进程
  gdbserver --attach :1234 $(pidof GreenPulse)
  ```

- 确认 PC 能连：`nc -z 172.16.1.101 1234`。

### 用 dape 连

1. `C-c g t` → 选本地那份**和目标完全一致**的二进制；
2. 回车确认 host/port（默认 `172.16.1.101:1234`）；
3. dape 用 `gdb-multiarch --interpreter=dap` 起会话，发 `attach`（`:target`），
   等价于 `target remote`；`my/dape-source-path-mapping` /
   `my/dape-solib-search-path` 会被翻译成 `-ex "set ..."` 一起带进去；
4. `C-c g c` 继续，`C-c g b` 断点。

### 变量

| 变量 | 说明 |
|---|---|
| `my/dape-remote-host` | 默认 `172.16.1.101` |
| `my/dape-remote-port` | 默认 `1234` |
| `my/dape-source-path-mapping` | DWARF 里的构建机路径 → 本机源码路径 |
| `my/dape-solib-search-path` | 可选，`set solib-search-path`（追 Qt 库时用） |

### 四个坑

- **一定用设备上那份二进制做符号**：本地构建产物和设备镜像里的可能不是同一次构建
  （md5 不同），用错文件行号/栈会整体偏移：

  ```sh
  scp xrd@172.16.1.101:/opt/QtMc/GreenPulse <build>/Src/GreenPulse-device
  ```

- **源码路径映射**：这个二进制的 DWARF 里写着 `/home/jingpeng/Desktop/virtDisk/...`，
  实际源码在 `/home/jingpeng/Desktop/sgc`，映射放在 `my/dape-source-path-mapping`；
- 一个 gdbserver 只能被一个客户端连接，连之前先确认设备上没有别的 gdb 会话；
- `gdbserver` 必须和目标 ABI 匹配（armhf/hard-float）；普通 `gdbserver :1234 ./prog`
  在 gdb 断开后会退出，所以远程重跑通常要去设备上重起 gdbserver。

## 多文件工程

| 想做的事 | 操作 |
|---|---|
| 停在别的文件 | 不用管，源码窗口会自动切过去 |
| 看别的栈帧 | `C-c g i` 打开信息面板，栈帧里回车 |
| 在别的文件打断点 | 打开该文件，`C-c g b` |
| 翻别的源码 | `C-x b` / `C-x C-b`（ibuffer） |
| 会话结束后重跑 | `C-c g r` |

示例工程：`~/Desktop/c-debug-demo`（main.c / score.c / stats.c，跨文件调用栈）。

## 备注

- `*dape-repl*` 里可用的命令：`debug, next, continue, pause, step, out, up, down,
  threads, stack, modules, sources, breakpoints, scope, watch, eval, restart,
  kill, disconnect, quit`；其它输入会直接发给调试器；
- 程序输出在 REPL，变量/栈/断点面板用 `C-c g i`；
- 想看汇编/寄存器：`C-c g d`（反汇编），寄存器在信息面板里。
