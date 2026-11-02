# corfu 行内补全手册

> 配置在 `modules/use-corfu.el`：`corfu`(MELPA) + `cape`(MELPA) + `yasnippet-capf`(MELPA)。
> minibuffer 的补全不归它管，那是 `modules/use-vertico.el` 的职责。

## 1. 分工

| 包 | 负责什么 |
| --- | --- |
| `corfu` | 缓冲区内（行内）的补全弹窗，只做显示和按键处理 |
| `cape` | 给 `completion-at-point-functions` 补上 LSP 之外的后备候选：`cape-file`(路径)、`cape-dabbrev`(缓冲区里的词) |
| `yasnippet-capf` | 把 yasnippet 的片段作为候选塞进同一个弹窗（**cape 没有 yasnippet 后端**） |
| `vertico` | 独立的一套，只管 minibuffer（`M-x`、`C-x b`、`C-c y` 选片段等） |

## 2. 什么时候弹

```elisp
(setq corfu-auto t            ; 输入时自动弹
      corfu-auto-delay 0.3    ; 停 0.3 秒
      corfu-auto-prefix 2)    ; 至少 2 个字符才弹
```

`corfu-auto-prefix` 不要设成 1：那样每敲一个字符都会向 clangd 发一次补全请求，大工程会明显卡。

不想自动弹就 `(setq corfu-auto nil)`，改用 `M-x completion-at-point` 或 `C-M-i` 手动触发。

## 3. 弹窗可见时的按键

| 键 | 命令 | 作用 |
| --- | --- | --- |
| `TAB` | `corfu-complete` | 补全公共前缀；唯一候选时直接插入 |
| `RET` | `corfu-insert` | 插入当前选中候选 |
| `↓` / `↑` | `corfu-next` / `corfu-previous` | 上下移动（`M-n` / `M-p` 同效） |
| `C-g` | `corfu-quit` | 关闭弹窗 |
| `M-h` | `corfu-info-documentation` | 看当前候选的文档 |
| `M-g` | `corfu-info-location` | 跳到候选定义处 |
| `M-SPC` | `corfu-insert-separator` | 插入分隔符（如路径里的 `/`） |
| `C-M-i` | `corfu-expand` | 手动展开 |

`corfu-popupinfo-mode` 已开启：候选旁边会显示文档摘要，多等一小会儿才出现。

## 4. 候选从哪来（CAPF 顺序）

`completion-at-point-functions` 按深度从小到大依次尝试，谁的候选先命中就先用谁：

| 深度 | 来源 | 说明 |
| --- | --- | --- |
| 0 | `lsp-completion-at-point` | 只在 LSP 启动后存在（`lsp-completion-provider :capf`） |
| 50 | `yasnippet-capf` | 片段 |
| 80 | `cape-file` | 路径（`#include "…"`、`open(…)` 时有用） |
| 90 | `cape-dabbrev` | 缓冲区里出现过的词，最后的兜底 |

这三个后备只挂在 `prog-mode` / `text-mode` / `org-mode` 里，由 `my/corfu-add-backends` 负责。

## 5. 常见问题

| 现象 | 原因 / 解决 |
| --- | --- |
| 完全不弹窗 | 只打了 1 个字符（`corfu-auto-prefix 2`）；或 `global-corfu-mode` 没开；或当前没有 CAPF 来源 |
| C/C++ 里没候选 | clangd 没启动（LSP 未接管该 buffer），此时只剩 cape 的路径/dabbrev |
| 弹窗卡顿 | 把 `corfu-auto-prefix` 提到 3、`corfu-auto-delay` 提到 0.5；或临时 `(setq corfu-auto nil)` |
| 文件路径候选太吵 | 从 `my/corfu-add-backends` 里去掉 `cape-file` 那一行 |
| 想确认 CAPF 顺序 | `M-: completion-at-point-functions`，列表里第一项是 ASCII 的 `t` 属正常（表示“还要跑全局值”），实际执行顺序可用 `C-h v` 之外的跑一遍确认 |
| 和 vertico 冲突吗 | 不冲突：vertico 管 `completing-read`（minibuffer），corfu 管 buffer 内的 `completion-in-region` |

## 6. 一页速记

```text
自动弹: 停 0.3s 且 ≥2 字符
TAB 补前缀   RET 插入   ↑↓/M-n M-p 选   C-g 关   M-h 文档   M-g 跳定义
顺序: LSP(0) → 片段(50) → 路径(80) → dabbrev(90)
手动: M-x completion-at-point / C-M-i
```
