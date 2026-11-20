# Eglot 手册（LSP）

> 配置在 `modules/use-eglot.el`：只放所有语言共用的部分。
> 具体语言（clangd / gopls / pyright …）的 mode hook 与 server 参数放在各自的语言文件里。

本配置的 LSP 客户端是 **GNU ELPA 的 Eglot 1.26**（`use-eglot.el` 会检查版本，缺了自动装，
装完重启一次），不再安装 `lsp-mode` / `lsp-ui` / `lsp-treemacs` / `consult-lsp` 那一套：
诊断走 flymake、文档/签名走 eldoc、跳转走 xref、补全走 CAPF（交给 corfu）。

> **为什么不用 Emacs 29.3 内置的 eglot 1.15？**
> 内置 1.15 依赖 jsonrpc 1.0.16 的私有接口（`jsonrpc--request-continuations` 等），
> 而 `dape` 要求 ELPA 的 `jsonrpc >= 1.0.25`：新版把该接口改了名，并把
> `:events-buffer-scrollback-size` 标成 deprecated。两代 jsonrpc 不能共存，
> 混用时启动会看到 `‘:events-buffer-scrollback-size’ deprecated` 和
> `jsonrpc--request-continuations is not known to be defined` 两条告警，
> Eglot 的 modeline 还会因 `void-function` 报错。
> Eglot 1.26 与 jsonrpc 1.0.30 是同一代，配套安装即解决。
> 副作用：会连带把内置的 `eldoc` / `flymake` / `project` / `xref` / `refactor`
> 换成 GNU ELPA 版本；`project 0.12.0` 有个只影响 Emacs 29 的上游 bug，
> 由 `core/compat.el` 补掉（见 [config.md](config.md#corecompatel跨版本补丁)）。

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

### 日常短键：`C-c .` / `C-c ,` / `C-c f`

| 键 | 命令 | 作用 |
| --- | --- | --- |
| `C-c .` | `xref-find-definitions` | 跳到定义（同 `M-.`；C/C++ 里覆盖 cc-mode 默认的 `c-set-style`） |
| `C-c ,` | `xref-go-back` | 跳回上一个位置（同 `M-,`） |
| `C-c f` | `xref-find-references` | 找引用（同 `M-?`） |

`M-.` / `M-,` 保留为 xref 默认键，和上面三个等价。

### 查看：`C-c l` 前缀

| 键 | 命令 | 作用 |
| --- | --- | --- |
| `C-c l s` | `consult-imenu` | 当前文件的函数/类/变量，带预览 |
| `C-c l d` | `consult-flymake` | 诊断列表，带预览，`RET` 跳转 |
| `C-c l i` | `eglot-inlay-hints-mode` | inlay hints 开关（参数名/推导类型） |
| `C-c l r` | `xref-find-references` | 找引用 |
| `C-c l .` / `F4` | `my/eglot-switch-header` | 头文件 ↔ 源文件；优先 clangd 的 `switchSourceHeader`，没接管时退回 `ff-find-other-file`（按文件名配对）。`F4` 只在 C/C++/ObjC buffer 里生效 |
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
| `refactor-confirmation` | 默认 `'((t . maybe-summary))` | server 主动改文件（`workspace/applyEdit`）时的确认策略；`eglot-confirm-server-*` 在 1.26 里都是它的 obsolete 别名，**不要再单独 setq**（会多一条 defvaralias 告警） |
| `eglot-events-buffer-config` | 默认 `(:size 2000000 :format full)` | 通信日志上限 2MB，`C-c L e` 打开 |
| `read-process-output-max` | 1MB | 提高与 server 的管道吞吐（默认 4KB 偏小） |

Eglot 自己会把"周边设施"接上：接管 buffer 时自动开 `flymake-mode`、`eldoc-mode`、
`eglot-inlay-hints-mode`、`eglot-semantic-tokens-mode`，挂
`completion-at-point-functions`、`xref-backend-functions` 和 imenu。
想自己接管某项（比如另配诊断前端），往 `eglot-stay-out-of` 里加对应符号。

## 4. 补全 / 诊断 / 文档

| 想做什么 | 走哪条路 | 说明 |
| --- | --- | --- |
| 代码补全 | corfu（CAPF） | `eglot-completion-at-point` 以深度 0 挂在 `completion-at-point-functions`，cape 的 file(80) / dabbrev(90) 排在它后面，所以 LSP 候选优先 |
| 片段 | yasnippet | 服务端下发的 snippet 由 Eglot 调 `yas-expand-snippet` 展开；`yasnippet-capf`（50）管本地片段候选 |
| 诊断（波浪线/边缘标记） | flymake | 内置；`M-x flymake-show-buffer-diagnostics` 看当前文件 |
| 诊断列表 | `C-c l d` / `M-9` | `consult-flymake` 带预览；`M-9` 是工程级 |
| 签名/悬停文档 | eldoc | 输入 `(` `,` 时自动在 **echo area** 显示；`C-c L h` 开完整文档 |
| inlay hints | `C-c l i` | 参数名和推导类型以小字画在代码里（Eglot 默认开，大文件卡就关掉） |
| 语义高亮 | 自动 | `eglot-semantic-tokens-mode` 随接管自动开；clangd 支持，颜色更准 |

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

Eglot 的 `eglot-server-programs` 自带常见语言（c/c++ → clangd→ccls、go → gopls、
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
`use-clangd.el` 里给 clangd 显式加了 `--background-index`，它按 `compile_commands.json` 建的是**工程级**索引：
`M-.` / `C-c f` / `C-c L g a` / `F4` 都能跳到**没打开过**的文件。

但**补全**（corfu 弹窗）仍然是 **per-buffer** 的：Eglot 只在你打开的那个 buffer 里附着 clangd，
不存在"打开项目就把所有文件都加载/补全"这回事。也就是说：项目一开，clangd 后台把索引建好，
跳转立刻可用；补全则要等你打开那个文件（第一次打开时会复用同一个 clangd，不会重复启动）。

| 想做什么 | 键 | 说明 |
| --- | --- | --- |
| 跳到定义 | `M-.` 或 `C-c .` 或 `C-c L g g` | xref / Eglot 都能用；`M-,`（或 `C-c ,`）跳回来 |
| 跳到声明 | `C-c L g d` | 头文件里的声明 |
| 跳到实现 | `C-c L g i` | 接口 → 实现 |
| 跳到类型定义 | `C-c L g t` | |
| 头文件 ↔ 源文件 | `F4` 或 `C-c l .` | 优先用 clangd 的 `switchSourceHeader`；没起 LSP 时退回 `ff-find-other-file` |
| 找函数引用 | `M-?` 或 `C-c f` 或 `C-c L g r` | 结果在 `*xref*` 里，`RET` 跳、`n`/`p` 上下、`q` 关闭 |
| 工程内按名字搜符号 | `C-c L g a` | `xref-find-apropos`（`workspace/symbol`） |
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
| 启动时看到 `‘:events-buffer-scrollback-size’ deprecated` 或 `jsonrpc--request-continuations ... not known to be defined` | 用的是内置 eglot 1.15 + 新版 jsonrpc，版本不匹配；装 GNU ELPA 的 `eglot`（≥1.26）后重启（见文首说明） |
| `defvaralias: Overwriting value of ‘eglot-confirm-server-edits’` | 配置里给 `eglot-confirm-server-*` 赋过值；改用 `refactor-confirmation`，或直接删掉那条 `setq` |
| 启动时 `Warning (comp): project.el … Buffer-menu-show-internal / customize-dirlocals not known` | project 0.12.0 在 Emacs 29 上引用了 30 才有的符号，是 native-comp 编它的告警（不影响运行）；`core/suppress.el` 已在 29.x 上跳过 project.el 的 JIT native 编译 |
| `C-x p b` 报 `void-variable Buffer-menu-show-internal` | project 0.12.0 在 Emacs 29 上的上游 bug；`core/compat.el` 已补，若删掉它请保留补丁 |
| `F4` 好像要 `.h` 和 `.cpp` 都打开才能切 | 不用。clangd 索引就绪时 `switchSourceHeader` 直接返回目标文件；索引没好或没连 LSP 时，`my/cc--find-counterpart` 按同名文件在**当前目录/整个工程**里找，找不到才报错，不会再弹目录选择 |
| `M-.` 和 `M-,` 看起来都在 .c/.h 之间跳 | 两者不是一回事：`M-.`（`xref-find-definitions`）跳 clangd 认为的定义（声明在头文件、实现在 .cpp 时落点由 clangd 索引决定，可能落在头文件），`M-,`（`xref-go-back`）回到跳转前的位置；短键 `C-c .` / `C-c ,` 与它们等价。按文件名配对切换用 `F4` |
| `which-key` 相关报错 | 没装 which-key（Emacs 29 不内置）；本配置已 `:ensure t` |
| 符号/引用是旧代码 | clangd 缓存了 `compile_commands.json`，重新生成后 `C-c L R` 重连 |

## 8. 一页速记

```text
符号: C-c l s（consult-imenu）       诊断: C-c l d（带预览） / M-9（工程级）
改名/code action/格式化: C-c L r / C-c L a / C-c L f
跳转: C-c . 定义   C-c , 返回   C-c f 引用 (M-. M-? M-, 同效)
声明/实现/类型: C-c L g d / g i / g t      工程搜符号: C-c L g a
头文件切换: F4（或 C-c l .）  inlay hints: C-c l i
断线重连: C-c L R          通信日志: C-c L e
接语言: (my/eglot-ensure-with-server "gopls" "安装提示")
路径: (my/add-exec-path "~/go/bin")
```
