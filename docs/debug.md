# dape 调试（modules/use-dape.el）

```elisp
(use-package dape
  :ensure t
  :config
  (when-let* ((cfg (assq 'gdb dape-configs)))
    (setcdr cfg (plist-put (cdr cfg) 'defer-launch-attach t)))
  (setq dape-buffer-window-arrangement 'right)
  (keymap-set global-map "C-c d" ...))
```

按键按 gdb 原生命令的字母来，`C-c d d` 进入调试。

| 键 | gdb 命令 | 作用 |
|---|---|---|
| `C-c d d` | `run` | 启动调试（minibuffer 里输入 `gdb :program "..."`） |
| `C-c d c` | `continue` | 继续 |
| `C-c d n` | `next` | 单步跳过 |
| `C-c d s` | `step` | 单步（步入） |
| `C-c d f` | `finish` | 运行到函数返回（步出） |
| `C-c d u` | `until` | 运行到当前行之后 |
| `C-c d r` | `run`(重启) | 重跑会话 |
| `C-c d b` | `break` | 断点开关 |
| `C-c d l` | — | log 断点（dape 扩展） |
| `C-c d p` | `print` | 求值表达式 |
| `C-c d w` | `watch` | 监视变量 |
| `C-c d i` | `info` | 信息面板（变量/栈/断点） |
| `C-c d x` | `examine` | 查看内存 |
| `C-c d q` / `k` | `quit` / `kill` | 退出 / 杀掉会话 |
| `C-c d R` | — | dape REPL |
| `C-c d <` / `>` | `up` / `down` | 切换栈帧 |

dape 自带的 `C-x C-a` 前缀仍然可用；`M-x` 也行。

## 信息面板里的单键（类似 magit）

`*dape-info-*` 面板是 `special-mode` 只读缓冲区，配置里给它们绑了单键，
不用 `C-c d` 前缀：

| 键 | 作用 | 键 | 作用 |
|---|---|---|---|
| `c` | 继续 | `n` | 下一步 |
| `s` | 步入 | `f` | 步出 |
| `u` | until | `r` | 重启 |
| `b` | 断点开关 | `p` | 求值 |
| `w` | watch | `x` | 看内存 |
| `R` | REPL | `TAB` | 切换面板 |

`RET` 在面板行上跳转（栈帧/断点/源码行）。`*dape-repl*` 里不走单键，直接输入
dape 命令词：`continue`、`next`、`step`、`out`、`stack`、`breakpoints`、`quit` 等。

源码缓冲区里没有单键（会抢正常输入），仍然用 `C-c d` 前缀。

## 注意

- 右侧面板：`dape-buffer-window-arrangement` 设为 `'right`，源码在左；
- 配置里设置了 `defer-launch-attach t`：GDB 的 DAP 收到 launch 会先跑程序，
  断点随后下发会被以 `notStopped` 拒绝（GDB bug 32090）。删掉它断点会失效；
- 启动命令注意引号闭合，例如 `gdb :program "~/Desktop/c-debug-demo/build/demo"`，
  漏掉结尾 `"` 会被静默忽略并回退到默认 `a.out`；
- 点 fringe 上的断点圆圈需要 `M-x dape-breakpoint-global-mode`。
