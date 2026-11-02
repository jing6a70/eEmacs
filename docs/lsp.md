# LSP 手册

> 配置在 `modules/use-lspmode.el`：只放所有语言共用的部分。
> 具体语言（clangd / gopls / pyright …）的 mode hook 与 server 参数放在各自的语言文件里。

## 1. 架构

```text
modules/use-lspmode.el      ← 通用: lsp-mode / lsp-ui / lsp-treemacs / consult-lsp
        ↑ 提供 my/lsp-deferred-with-server、my/add-exec-path
e-clang-mode.el             ← 语言: 什么时候启动 clangd、传什么参数
```

好处是“一个语言坏了不影响别的语言”：某个 server 没装时只打印一条警告，不会阻断其它语言的 LSP。

## 2. 键位

| 键 | 命令 | 作用 |
| --- | --- | --- |
| `C-c l s` | `lsp-treemacs-symbols` | 符号树（当前文件的函数/类/变量） |
| `C-c l i` | `lsp-ui-imenu` | imenu 形式浏览符号（双击跳转） |
| `C-c l d` | `consult-lsp-diagnostics` | 诊断列表，带预览，`RET` 跳转 |
| `M-9` | `lsp-treemacs-errors-list` | 错误树（按文件分组） |

`C-c s` **不要**占用：那是 iedit 的开关（见 [multi-edit.md](multi-edit.md)）。

lsp-mode 自己还有一套命令，默认前缀是 `s-l`（Super 键，GUI 下可用）：`s-l r` 重命名、`s-l a` code action、`s-l g g` 跳定义等。也可以直接 `M-x lsp-…`。

`lsp-keymap-prefix` 已改成 **`C-c L`**（默认的 `s-l` 在 Linux 桌面上常被“锁屏”快捷键占用）。`which-key` 已装并开启，按 `C-c L` 会列出后续按键。

### 跳转与引用

前提是 clangd 已经接管当前 buffer（`C-c l s` 能列出符号就说明连上了），并且工程里最好有 `compile_commands.json`：

```sh
cd ~/Desktop/sgc/GreenPulse
qmake GreenPulse.pro          # qmake 工程先出 Makefile
bear -- make -j"$(nproc)"     # 生成 compile_commands.json(或 compiledb make)
```

clangd 首次会建后台索引（`~/.cache/clangd/index`），大工程要等几秒到几分钟，索引建好后跨文件引用才完整。

| 想做什么 | 键 | 说明 |
| --- | --- | --- |
| 跳到定义 | `M-.` 或 `C-c L g g` | xref / lsp 都能用；`M-,` 跳回来 |
| 跳到声明 | `C-c L g d` | 头文件里的声明 |
| 跳到实现 | `C-c L g i` | 接口 → 实现 |
| 跳到类型定义 | `C-c L g t` | |
| **头文件 ↔ 源文件** | `C-c l .` | 优先用 clangd 的 `switchSourceHeader`；没起 LSP 时退回 `ff-find-other-file`（按文件名配对） |
| 找函数引用 | `M-?` 或 `C-c l r` 或 `C-c L g r` | 结果在 `*xref*` 里，`RET` 跳、`n`/`p` 上下、`q` 关闭 |
| 工程内按名字搜符号 | `C-c L g a` | `workspace/symbol`，输入 `Car` 之类的片段即可 |
| 调用层级 | `C-c L g h` | `lsp-treemacs-call-hierarchy` |
| 文件内符号 | `C-c l s` / `C-c l i` | 树 / imenu |

几个实用提醒：

- `M-.` 是 xref 的入口，lsp-mode 会把自己注册成 xref 后端，所以不用记 `C-c L g g`；
- 头文件切换依赖命名约定（`Foo.h` ↔ `Foo.cpp`）；文件不在同一目录时 clangd 的 `switchSourceHeader` 更准，它按索引找；
- 引用搜不到，八成是索引还没建完或 `compile_commands.json` 缺失（此时 clangd 只能按单文件猜）；
- `C-c L` 下还有 `s` 重命名、`a` code action、`r` 重命名等，按了之后看 which-key 提示。

## 3. 关键配置

| 变量 | 值 | 说明 |
| --- | --- | --- |
| `lsp-completion-provider` | `:capf` | 把补全暴露成 CAPF 给 corfu。**不要设成 `:none`**，那会让 corfu 收不到 LSP 候选 |
| `lsp-diagnostics-provider` | `:flymake` | 用内置 flymake（没装 flycheck） |
| `lsp-enable-snippet` | `t` | 服务端下发的片段交给 yasnippet 展开 |
| `lsp-idle-delay` | `0.5` | 停手 0.5 秒后才做检查，省 CPU |
| `lsp-enable-on-type-formatting` | `nil` | 边打边格式化容易顿；需要时再开 |
| `lsp-auto-guess-root` | `t` | 靠 `.git`/`compile_commands.json` 自动推工程根 |
| `read-process-output-max` | 1MB | 提高与 server 的管道吞吐（默认 4KB 偏小） |
| `lsp-keep-workspace-alive` | `nil` | 最后一个 buffer 关闭后收掉 workspace |

`lsp-ui` 那边：doc 用 childframe（仅 GUI 生效）、sideline 显示 hover/code action/diagnostics、headerline 显示面包屑。

## 4. 自动弹符号面板

打开 LSP 后会自动弹出 `lsp-treemacs-symbols`，实现是：

```text
lsp-after-initialize-hook
  └─ my/lsp-auto-open-symbols
       └─ my/lsp--symbols-retry (最多 3 次, 每次等 3 秒 idle)
            └─ lsp-request-async "textDocument/documentSymbol"
                 ├─ 有结果 → lsp-treemacs-symbols
                 └─ 无结果 → 继续重试
```

要点：

- 用**异步**请求（`lsp-request-async`），clangd 冷启动时不会卡住 UI；
- 记住发起时的 buffer，避免 idle 时当前 buffer 已经换成 dashboard/magit 导致面板空；
- 不想被自动弹窗打扰：`(setq my/lsp-auto-symbols-p nil)`。

## 5. 接入一个新语言

C/C++ 已经由 `modules/use-clangd.el` 接好（`c-mode` / `c++-mode` / `objc-mode`），clangd 装在 `PATH` 里就会自动启动。

其它语言照同样的模式，在各自的语言文件里写：

```elisp
(defun my/gopls-start ()
  (my/lsp-deferred-with-server "gopls" "安装: go install golang.org/x/tools/gopls@latest"))

(add-hook 'go-mode-hook #'my/gopls-start)
```

`my/lsp-deferred-with-server` 的行为：server 在 PATH 里就 `lsp-deferred`，否则在 `*Warnings*` 里留一条带安装提示的记录，不报错、不阻断。

server 装在用户目录（`~/go/bin`、`~/.local/npm-global/bin`）时，用 `my/add-exec-path` 把它加进 `exec-path` 和 `$PATH`：

```elisp
(my/add-exec-path "~/go/bin")
```

## 6. 常见问题

| 现象 | 原因 / 解决 |
| --- | --- |
| 打开文件没反应 | 该语言没把 `lsp-deferred` 挂到 mode hook（C/C++ 由 `use-clangd.el` 负责）；或 server 不在 PATH（看 `*Warnings*`） |
| 补全时不显示参数 | 参数/签名走 **eldoc（echo area）**，由 `lsp-signature-auto-activate` 在输入 `(` `,` 时触发；corfu 弹窗只显示候选与文档摘要。先确认 `C-c l s` 能列出符号，说明 LSP 已连上 |
| `which-key` 相关报错 | 没装 which-key（Emacs 29 不内置）；本配置已 `:ensure t` |
| 补全里没有 LSP 候选 | `lsp-completion-provider` 被改成 `:none` 了 |
| `C-c l s` 之类按不出来 | 你改过 `lsp-keymap-prefix` 成 `C-c l`，把我们的前缀 map 覆盖了；改成 `s-l` 或 `C-c L` |
| 符号面板空 | clangd 还在建索引；等几秒重开，或 `M-x lsp-treemacs-symbols` |
| 断言/跳转是旧代码 | clangd 缓存了 `compile_commands.json`，改完构建后 `M-x lsp-workspace-restart` |

## 7. 一页速记

```text
符号: C-c l s（树）  C-c l i（imenu）   诊断: C-c l d / M-9
改名/代码动作: s-l r / s-l a          定义: s-l g g
开关自动符号面板: my/lsp-auto-symbols-p
接语言: (my/lsp-deferred-with-server "clangd" "安装提示")
路径: (my/add-exec-path "~/go/bin")
```
