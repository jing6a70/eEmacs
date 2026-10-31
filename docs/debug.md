# dape 调试（modules/use-dape.el）

```elisp
(use-package dape
  :ensure t
  :config
  (defvar my/dape-map
    (with-no-warnings
      (let ((map (make-sparse-keymap)))
        (keymap-set map "s" #'dape)
        (keymap-set map "c" #'dape-continue)
        (keymap-set map "u" #'dape-until)
        (keymap-set map "b" #'dape-breakpoint-toggle)
        (keymap-set map "l" #'dape-breakpoint-log)
        (keymap-set map "r" #'dape-repl)
        (keymap-set map "x" #'dape-evaluate-expression)
        (keymap-set map "<" #'dape-stack-select-up)
        (keymap-set map ">" #'dape-stack-select-down)
        map)))
  (keymap-set global-map "C-c d" my/dape-map))
```

| 键 | 作用 |
|---|---|
| `C-c d s` | 启动调试 |
| `C-c d c` | 继续 |
| `C-c d u` | 运行到当前行 |
| `C-c d b` | 断点开关 |
| `C-c d l` | log 断点 |
| `C-c d r` | REPL |
| `C-c d x` | 求值表达式 |
| `C-c d <` / `C-c d >` | 向上 / 向下切换栈帧 |

其余操作用 `M-x`：`dape-next`、`dape-step-in`、`dape-step-out`、`dape-pause`、
`dape-restart`、`dape-info`、`dape-quit` 等。

dape 自己的 `C-x C-a` 默认前缀仍然可用（`dape-key-prefix`）。

## 注意

- 默认信息面板在左侧（`dape-buffer-window-arrangement` 默认 `'left`）；
- 点 fringe 断点圆圈要 `M-x dape-breakpoint-global-mode`；
- 启动时下的断点可能不生效（GDB bug 32090，程序直接跑完）：先 `M-x dape-pause`
  暂停再下断点。
