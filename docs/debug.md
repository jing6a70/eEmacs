# dape 调试（modules/use-dape.el）

配置只有十几行：装包、把 `C-c g` 绑到 dape 自带的 `dape-global-map`、
加一个 ARM 远程的 attach 配置。其余命令都用 `M-x`。

前置：dape 已安装（`M-x package-install RET dape`，依赖 `jsonrpc`），
`gdb >= 14.1`；调试 ARM 目标再装 `gdb-multiarch`。

## 用法

`C-c g d`（或 `M-x dape`），minibuffer 里输入配置名后回车，例如：

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

源码里断点会以 overlay 显示；变量、栈、断点、线程在 `C-c g i` 打开的面板里。
布局默认左侧源码 + 右侧面板（`dape-buffer-window-arrangement 'right`）。

## 远程 / ARM

配置里已经有一个 `gdb-remote`，用 `gdb-multiarch` attach 到 gdbserver：

```text
C-c g d → 输入 gdb-remote → 回车
```

它等价于：

```text
gdb-multiarch --interpreter=dap
  -ex "set substitute-path /home/jingpeng/Desktop/virtDisk /home/jingpeng/Desktop/sgc"
  attach :program <GreenPulse-device>  :target 172.16.1.101:1234
```

换目标/换二进制时，在启动那行后面追加覆盖即可，例如：

```text
gdb-remote :program "/other/bin" :target "192.168.1.10:1234"
```

多句 override 用空格分隔，`TAB` 可以补全配置名。

### 注意

- **用设备上那份二进制**做 `:program`（md5 要和目标一致），否则行号/栈会偏：

  ```sh
  scp xrd@172.16.1.101:/opt/QtMc/GreenPulse <build>/Src/GreenPulse-device
  ```

- 配置里那条 `-ex "set substitute-path ..."` 是因为该二进制的 DWARF 记的是
  构建机路径 `/home/jingpeng/Desktop/virtDisk`，实际源码在
  `/home/jingpeng/Desktop/sgc`；换工程就改这一行；
- 一个 gdbserver 只能被一个客户端连接；普通 `gdbserver :1234 ./prog`
  在 gdb 断开后会退出，重跑要去设备上重起；
- 配置里默认设置了 `defer-launch-attach t`：GDB 的 DAP 收到 launch 就启动程序，
  断点随后下发会被以 `notStopped` 拒绝（GDB bug 32090），推迟 launch 才生效。

## 备注

- dape 走 DAP，GDB 侧没有 MI 的 attach PID / core dump 等能力；需要时用内置
  `M-x gdb`（本配置不再提供 `C-c d` 前缀）；
- `*dape-repl*` 里可以直接输入 dape 命令（`continue`、`next`、`stack`、
  `breakpoints`、`restart`、`quit` 等），其它输入会发给调试器。
