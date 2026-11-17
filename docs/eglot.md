# Eglot 手册（LSP）

> 配置在 `modules/use-eglot.el`：只放所有语言共用的部分。
> 具体语言（clangd / gopls / pyright …）的 mode hook 与 server 参数放在各自的语言文件里。

Emacs 29 起 **Eglot 是内置包**（`eglot.el`，`M-x eglot` 即用），所以本配置不再安装
`lsp-mode` / `lsp-ui` / `lsp-treemacs` / `consult-lsp` 那一套：能用内置的就用内置的，
诊断走 flymake、文档/签名走 eldoc、跳转走 xref、补全走 CAPF（交给 corfu）。

## 1. 架构

```text
modules/use-eglot.el        ← 通用: eglot 选项、C-c L / C-c l 键位
        ↑ 提供 my/eglot-ensure-with-server、my/add-exec-path
modules/use-clangd.el       ← 语言: 什么时候启动 clangd、传什么参数
```

好处是"一个语言坏了不影响别的语言"：某个 server 没装时只打印一条警告，不会阻断其它语言的 LSP。

## 2. 键位

### 操作：`C-c L` 前缀

| 键 | 命令 | 作用 |
| --- | --- | --- |
| `C-c L r` | `eglot-rename` | 改名（会提示新名字） |
| `C-c L a` | `eglot-code-actions` | code action：修错、重构、import |
| `C-c L o` | `eglot-code-action-organize-imports` | 整理 include |
| `C-c L f` | `eglot-format-buffer` | 格式化整个 buffer |
| `C-c L h` | `eldoc-doc-buffer` | 光标处符号的文档（独立 buffer） |
| `C-c L e` | `eglot-events-buffer` | 与 server 的通信日志（排错用） |
| `C-c L s` | `eglot-shutdown` | 断开当前 server |
| `C-c L R` | `eglot-reconnect` | 重连（改了 `compile_commands.json` 后用） |

`C-c L g` 是跳转子前缀：

| 键 | 命令 | 作用 |
| --- | --- | --- |
| `C-c L g g` | `xref-find-definitions` | 跳到定义 |
| `C-c L g d` | `eglot-find-declaration` | 跳到声明（头文件里那一行） |
| `C-c L g i` | `eglot-find-implementation` | 接口 → 实现 |
| `C-c L g t` | `eglot-find-typeDefinition` | 跳到类型定义 |
| `C-c L g r` | `xref-find-references` | 找引用 |
| `C-c L g a` | `xref-find-apropos` | 工程内按名字搜符号（`workspace/symbol`），输入 `Car` 之类片段即可 |

### 查看：`C-c l` 前缀

| 键 | 命令 | 作用 |
| --- | --- | --- |
| `C-c l s` | `consult-imenu` | 当前文件的函数/类/变量，带预览 |
| `C-c l d` | `consult-flymake` | 诊断列表，带预览，`RET` 跳转 |
| `C-c l i` | `eglot-inlay-hints-mode` | inlay hints 开关（参数名/推导类型） |
| `C-c l r` | `xref-find-references` | 找引用 |
| `C-c l .` | `my/eglot-switch-header` | 头文件 ↔ 源文件；clangd 没接管时退回 `ff-find-other-file`（按文件名配对） |
| `M-9` | `flymake-show-project-diagnostics` | 工程级错误列表（按文件分组） |

`C-c s` **不要**占用：那是 iedit 的开关（见 [multi-edit.md](multi-edit.md)）。
`M-.` / `M-?` / `M-,` 仍是 xref 的默认键：Eglot 把自己注册成 xref 后端后，这三个键直接可用。

### 和 lsp-mode 时代的对应关系

| 以前 | 现在 |
| --- | --- |
| `C-c l s` `lsp-treemacs-symbols` | `C-c l s` `consult-imenu` |
| `C-c l i` `lsp-ui-imenu` | 同上（`consult-imenu` 已经够用，`i` 改给 inlay hints） |
| `C-c l d` `consult-lsp-diagnostics` | `C-c l d` `consult-flymake` |
| `M-9` `lsp-treemacs-errors-list` | `M-9` `flymake-show-project-diagnostics` |
| `lsp-workspace-restart` | `C-c L R` `eglot-reconnect` |
| `lsp-describe-session` | `C-c L e` `eglot-events-buffer` |

## 3. 关键配置

| 变量 | 值 | 说明 |
| --- | --- | --- |
| `eglot-autoshutdown` | `t` | 最后一个被接管的 buffer 关掉就收 server，不常驻 |
| `eglot-send-changes-idle-time` | `0.5` | 停手 0.5 秒才把改动发给 server，省 CPU |
| `eglot-sync-connect` | `3`（默认） | 启动连接时最多阻塞 3 秒，超时转异步，不会卡死 |
| `eglot-extend-to-xref` | `t` | 顺着 xref 跳到工程外的文件时也接管 |
| `eglot-confirm-server-initiated-edits` | `'confirm` | server 主动改文件（`workspace/applyEdit`）前先确认 |
| `read-process-output-max` | 1MB | 提高与 server 的管道吞吐（默认 4KB 偏小） |

Eglot 内置的"周边设施"不需要我们再配：接管 buffer 时它自己会开 `flymake-mode`、
`eldoc-mode`、`eglot-inlay-hints-mode`，挂 `completion-at-point-functions`、
`xref-backend-functions` 和 imenu。
想自己接管某项（比如另配诊断前端），往 `eglot-stay-out-of` 里加对应符号。

## 4. 补全 / 诊断 / 文档

| 想做什么 | 走哪条路 | 说明 |
| --- | --- | --- |
| 代码补全 | corfu（CAPF） | `eglot-completion-at-point` 以深度 0 挂在 `completion-at-point-functions`，cape 的 file(80) / dabbrev(90) 排在它后面，所以 LSP 候选优先 |
| 片段 | yasnippet | 服务端下发的 snippet 由 Eglot 调 `yas-expand-snippet` 展开；`yasnippet-capf`（50）管本地片段候选 |
| 诊断（波浪线/边缘标记） | flymake | 内置；`M-x flymake-show-buffer-diagnostics` 看当前文件 |
| 诊断列表 | `C-c l d` / `M-9` | `consult-flymake` 带预览；`M-9` 是工程级 |
| 签名/悬停文档 | eldoc | 输入 `(` `,` 时自动在 **echo area** 显示；`C-c L h` 开完整文档 |
| inlay hints | `C-c l i` | 参数名和推导类型以小字画在代码里（Emacs 29.3 的 Eglot 默认开，大文件卡就关掉） |

corfu 的细节见 [corfu.md](corfu.md)。

## 5. 接入一个新语言

C/C++ 已经由 `modules/use-clangd.el` 接好（`c-mode` / `c++-mode` / `objc-mode`），clangd 装在 `PATH` 里就会自动启动。

其它语言照同样的模式，在各自的语言文件里写：

```elisp
(defun my/gopls-start ()
  (my/eglot-ensure-with-server "gopls" "安装: go install golang.org/x/tools/gopls@latest"))

(add-hook 'go-mode-hook #'my/gopls-start)
```

`my/eglot-ensure-with-server` 的行为：server 在 PATH 里就 `eglot-ensure`，否则在 `*Warnings*` 里留一条带安装提示的记录，不报错、不阻断。

server 装在用户目录（`~/go/bin`、`~/.local/npm-global/bin`）时，用 `my/add-exec-path` 把它加进 `exec-path` 和 `$PATH`：

```elisp
(my/add-exec-path "~/go/bin")
```

Emacs 29 的 `eglot-server-programs` 已经内置了常见语言（c/c++ → clangd→ccls、go → gopls、
python → pylsp、js/ts → typescript-language-server …），一般不用自己写。要换 server 或加参数：

```elisp
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode) . ("clangd" "--background-index" "--clang-tidy"))))
```

## 6. 编译数据库与索引

前提是 clangd 已经接管当前 buffer（`C-c l d` 或补全有反应就说明连上了），并且工程里最好有 `compile_commands.json`：

```sh
cd ~/Desktop/sgc/GreenPulse
qmake GreenPulse.pro          # qmake 工程先出 Makefile
bear -- make -j"$(nproc)"     # 生成 compile_commands.json（或 compiledb make）
```

clangd 首次会建后台索引（`~/.cache/clangd/index`），大工程要等几秒到几分钟，索引建好后跨文件引用才完整。

| 想做什么 | 键 | 说明 |
| --- | --- | --- |
| 跳到定义 | `M-.` 或 `C-c L g g` | xref / Eglot 都能用；`M-,` 跳回来 |
| 跳到声明 | `C-c L g d` | 头文件里的声明 |
| 跳到实现 | `C-c L g i` | 接口 → 实现 |
| 跳到类型定义 | `C-c L g t` | |
| 头文件 ↔ 源文件 | `C-c l .` | 优先用 clangd 的 `switchSourceHeader`；没起 LSP 时退回 `ff-find-other-file` |
| 找函数引用 | `M-?` 或 `C-c l r` 或 `C-c L g r` | 结果在 `*xref*` 里，`RET` 跳、`n`/`p` 上下、`q` 关闭 |
| 工程内按名字搜符号 | `C-c L g a` | `workspace/symbol` |
| 文件内符号 | `C-c l s` | `consult-imenu` |

几个实用提醒：

- 头文件切换依赖命名约定（`Foo.h` ↔ `Foo.cpp`）；文件不在同一目录时 clangd 的 `switchSourceHeader` 更准，它按索引找；
- 引用搜不到，八成是索引还没建完或 `compile_commands.json` 缺失（此时 clangd 只能按单文件猜）；
- 断言/跳转是旧代码：clangd 缓存了编译参数，改完构建后 `C-c L R` 重连（或 `C-c L s` 断掉再开）；
- 想让某个工程用不同的 clangd 参数：工程根放 `.clangd`（clangd 自己的配置文件），比改 Emacs 配置干净。

## 7. 常见问题

| 现象 | 原因 / 解决 |
| --- | --- |
| 打开文件没反应 | 该语言没把 `eglot-ensure` 挂到 mode hook（C/C++ 由 `use-clangd.el` 负责）；或 server 不在 PATH（看 `*Warnings*`） |
| 提示 `No LSP server for ...` | 该 mode 不在 `eglot-server-programs` 里，或 server 没装。手动试 `M-x eglot` 看它猜什么命令，再用 `add-to-list` 补上 |
| 补全/诊断全都安静 | 先看 `C-c L e`（events buffer）里有没有握手/报错；`M-x eglot` 能连上说明是键位或 hook 的问题 |
| 补全时不显示参数 | 参数/签名走 **eldoc（echo area）**，不是 corfu 弹窗；确认 `(eldoc-mode 1)` 没被别的包抢走 |
| inlay hints 卡顿 | `C-c l i` 关掉；不想每次手动关就在 `eglot-managed-mode-hook` 里关 |
| 服务端一直 pending | 看 `M-x eglot-stderr-buffer`；clangd 版本太老（`clangd --version`，建议 14+） |
| 改了 server 参数不生效 | 写完后 `C-c L s` 断开再重开文件，或 `C-c L R` 重连 |
| `which-key` 相关报错 | 没装 which-key（Emacs 29 不内置）；本配置已 `:ensure t` |
| 符号/引用是旧代码 | clangd 缓存了 `compile_commands.json`，重新生成后 `C-c L R` 重连 |

## 8. 一页速记

```text
符号: C-c l s（consult-imenu）       诊断: C-c l d（带预览） / M-9（工程级）
改名/code action/格式化: C-c L r / C-c L a / C-c L f
跳转: M-. 定义   C-c L g d 声明   C-c L g i 实现   C-c L g t 类型   M-? 引用   C-c L g a 工程搜符号
头文件切换: C-c l .        inlay hints: C-c l i
断线重连: C-c L R          通信日志: C-c L e
接语言: (my/eglot-ensure-with-server "gopls" "安装提示")
路径: (my/add-exec-path "~/go/bin")
```
