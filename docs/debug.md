# dape 调试（modules/use-dape.el）

配置就一行：

```elisp
(use-package dape
  :ensure t)
```

所有操作都用 `M-x`。

| 操作 | 命令 |
|---|---|
| 启动 | `M-x dape`，输入 `gdb :program "./demo"` 回车 |
| 断点开关 | `M-x dape-breakpoint-toggle` |
| 继续 / 下一步 / 步入 / 步出 | `M-x dape-continue` / `dape-next` / `dape-step-in` / `dape-step-out` |
| 暂停 / 重启 / 退出 | `M-x dape-pause` / `dape-restart` / `dape-quit` |
| 变量、栈、断点面板 | `M-x dape-info` |
| REPL | `M-x dape-repl` |
| 求值 / 监视 | `M-x dape-evaluate-expression` / `dape-watch-dwim` |

默认行为（dape 原生，未改）：

- 信息面板在**左侧**（`dape-buffer-window-arrangement` 默认 `'left`），
  想放右侧：`M-x customize-variable RET dape-buffer-window-arrangement`；
- 断点的边缘点击/显示需要 `M-x dape-breakpoint-global-mode`（或
  `M-x dape-breakpoint-mode` 只对当前 buffer 生效）；
- 启动时下发的断点可能不生效（GDB bug 32090，程序直接跑完）：先
  `M-x dape-pause` 暂停，再下断点；想彻底解决可在配置里加
  `defer-launch-attach t`。

dape 走 DAP，不依赖也不共用内置 gdb-mi；需要 MI 专属能力（core dump 等）
时手动 `M-x gdb`。
