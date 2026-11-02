# 配置说明

本配置以 Emacs 内置功能为主，另用 `use-package` 引入第三方包，按用途分：

- 编辑：`magit`、`diff-hl`、`undo-tree`、`hungry-delete`、`iedit`
- 界面：`dashboard`、`treemacs`
- 补全：`vertico`、`orderless`、`marginalia`、`consult`、`embark`、`embark-consult`、`corfu`、`cape`
- 片段：`yasnippet`、`yasnippet-snippets`、`yasnippet-capf`
- 调试：`dape`
- LSP：`lsp-mode`、`lsp-ui`、`lsp-treemacs`、`consult-lsp`、`which-key`

（`magit-section` / `transient` / `with-editor` 等依赖随 magit 自动安装。）

当前已在 **GNU Emacs 31.1** 上验证。最低建议 Emacs 29：`modus-operandi-tinted` 主题分支、`pixel-scroll-precision-mode` 都依赖 29+。

## 目录结构

```text
~/.emacs.d/
├── early-init.el            # 最早执行: 关闭 UI、启动期 GC 调优
├── init.el                  # 入口: 目录设定、按序加载 core/modules/keybindings、启动 server
├── keybindings.el           # 个人快捷键(F2 / C-x C-b)
├── core/
│   ├── elpa.el              # 包源(GNU + MELPA)与 package 初始化
│   ├── view.el              # 界面与显示
│   ├── edit.el              # 编辑行为与 C/C++ 代码风格
│   ├── theme.el             # 主题加载与回退
│   └── suppress.el          # 字节编译告警收敛
├── modules/
│   ├── use-magit.el         # magit + diff-hl
│   ├── use-dape.el          # dape 调试(含 gdb-remote 远程 attach)
│   ├── use-dashboard.el     # 启动欢迎页(dashboard)
│   ├── use-treemacs.el      # 左侧文件树(treemacs)
│   ├── use-undo-tree.el     # 撤销树(undo-tree)
│   ├── use-hungry-delete.el # 连删空白(hungry-delete)
│   ├── use-multi-edit.el    # 批量多行编辑(iedit + occur-edit)
│   ├── use-vertico.el       # 补全框架(vertico/orderless/consult/embark)
│   ├── use-corfu.el         # 行内补全(corfu + cape)
│   ├── use-yasnippet.el     # 代码片段(yasnippet)
│   └── use-lspmode.el       # LSP 通用配置(lsp-mode/lsp-ui/lsp-treemacs)
└── docs/                    # 文档(config.md / project.md / magit.md / debug.md / multi-edit.md / undo-tree.md / corfu.md / yasnippet.md / lsp.md / quickstartguide.org)
```

## 启动流程

```text
early-init.el
  └─ init.el
       ├─ .config-auto.el          (存在则加载, 不存在静默跳过)
       ├─ core/elpa.el
       ├─ core/view.el
       ├─ core/edit.el
       ├─ core/theme.el
       ├─ core/suppress.el
       ├─ modules/use-magit.el     (my/local-modules)
       ├─ modules/use-dape.el
       ├─ modules/use-dashboard.el
       ├─ modules/use-treemacs.el
       ├─ modules/use-undo-tree.el
       ├─ modules/use-hungry-delete.el
       ├─ modules/use-multi-edit.el
       ├─ modules/use-vertico.el
       ├─ modules/use-corfu.el
       ├─ modules/use-yasnippet.el
       ├─ modules/use-lspmode.el
       ├─ keybindings.el
       └─ server-start / emacs-startup-hook
```

core 与 modules 都是数据驱动加载：core 见 `init.el` 中的 `mapc` 列表，modules 见 `my/local-modules`。
新增文件时只需在对应列表里加一项，无需改加载逻辑。

## early-init.el（最早执行）

| 内容 | 说明 |
|---|---|
| `gc-cons-threshold` → `most-positive-fixnum` | 启动阶段几乎不触发 GC，缩短启动时间；启动完成后恢复为 16MB |
| `menu-bar-mode` / `tool-bar-mode` / `scroll-bar-mode` 关闭 | 在首个 frame 创建前生效，避免启动时界面闪烁 |

## init.el（入口）

| 内容 | 说明 |
|---|---|
| `user-emacs-directory` | 取 `init.el` 实际所在目录（`file-truename`），配置目录可整体搬到任意位置 |
| `custom-file` → `.config-auto.el` | `M-x customize-*` 的写入定向到独立文件（已 gitignore），不污染 `init.el`；存在则 `load ... 'noerror` |
| 加载顺序 | core → modules → keybindings，见上方流程图 |
| `my/local-modules` | `(use-magit use-dape use-dashboard use-treemacs use-undo-tree use-hungry-delete use-multi-edit use-vertico use-yasnippet use-corfu use-lspmode)`，用 `require ... 'noerror` 加载，出错不中断启动 |
| `server-start` | `noninteractive` / `daemonp` / 已有 server 时跳过，其余情况启动 Emacs server |
| `emacs-startup-hook` | 启动完成后把 `gc-cons-threshold` 恢复为 16MB |

## core/elpa.el（包管理）

| 内容 | 说明 |
|---|---|
| 包源 | GNU ELPA（`https://elpa.gnu.org/packages/`）+ MELPA（`https://melpa.org/packages/`），追加到 `package-archives` 末尾 |
| `package-initialize` | 仅在 Emacs < 29 时显式调用；29+ 依赖启动时默认的包激活 |
| 自动安装 | 各模块的 `use-package ... :ensure t`：包缺失时从上述源安装到 `elpa/` |

## core/view.el（界面与显示）

| 选项 | 说明 |
|---|---|
| `menu-bar-mode` / `tool-bar-mode` / `scroll-bar-mode` 关闭 | 极简界面 |
| `inhibit-splash-screen t`、`initial-scratch-message nil` | 跳过启动画面，`*scratch*` 留空 |
| `ring-bell-function 'ignore` | 关闭响铃 |
| `cursor-type 'bar`、`cursor-in-non-selected-windows nil`、`blink-cursor-mode -1` | 竖线光标、非活动窗口不显示光标、不闪烁 |
| `scroll-conservatively 101`、`scroll-margin 2` | 光标接近边缘时提前滚动，边缘保留 2 行 |
| `column-number-mode`、`which-function-mode` | mode-line 显示 `行号:列号` 和当前函数名 |
| `winner-mode`、`windmove-default-keybindings` | `C-c <left>` / `C-c <right>` 撤销/重做窗口布局；`Shift + 方向键` 切换窗口 |
| `use-dialog-box nil` | 禁用 GUI 弹窗，交互走 minibuffer |
| `global-auto-revert-mode` | 文件被外部修改后自动重载；`auto-revert-avoid-polling t`、`auto-revert-verbose t` |
| `global-display-line-numbers-mode` | 全局行号（Emacs 26.1+） |
| `read-extended-command-predicate` | `M-x` 不列内部命令（Emacs 28.1+）；补全界面本身交给 `modules/use-vertico.el`，这里不再开 fido |
| `pixel-scroll-precision-mode` | 像素级平滑滚动（Emacs 29.1+） |

## core/edit.el（编辑行为）

| 选项 | 说明 |
|---|---|
| `make-backup-files nil` | 不生成 `file~` 备份 |
| `require-final-newline t` | 保存时保证文件以换行结尾 |
| `prefer-coding-system 'utf-8` | 统一 UTF-8 |
| `delete-by-moving-to-trash t` | 删除文件移入系统回收站 |
| `electric-pair-mode`、`show-paren-mode` | 自动补配对括号、高亮匹配括号 |
| `delete-selection-mode` | 选中后直接输入即覆盖 |
| `recentf-mode`、`save-place-mode`、`savehist-mode` | 最近文件、恢复光标位置、持久化 minibuffer / `M-x` 历史 |
| `undo-limit` / `undo-strong-limit` / `undo-outer-limit` | 800000 / 1200000 / 48000000，加大撤销历史 |
| `dired-dwim-target t` | 两个 dired 窗口之间直接复制/移动 |
| `repeat-mode` | 重复命令免前缀键（Emacs 28.1+） |
| `c-default-style "linux"`、`indent-tabs-mode nil`、`tab-width 4`、`c-basic-offset 4` | C/C++ 采用 Linux 内核风格，缩进 4 个空格 |

## core/theme.el（主题）

| 版本 | 行为 |
|---|---|
| Emacs ≥ 29 | 优先 `modus-operandi-tinted`；加载失败时提示并以 `tsdh-dark` 回退 |
| Emacs < 29 | 直接 `tsdh-dark` |

`.config-auto.el` 中 `custom-enabled-themes` 记录为 `(modus-operandi-tinted)`，与上述首选一致。
切换主题请用 `M-x customize-themes`（会写回 `.config-auto.el`），不要手改 `init.el`。

## core/suppress.el（告警收敛）

仅对 Emacs 28.1+ 生效：

| 选项 | 说明 |
|---|---|
| `byte-compile-docstring-max-column 120` | docstring 超过 120 列才告警（默认 80） |
| `byte-compile-warnings '(not not-unused lexical)` | 关闭 `_` 前缀变量的 `not-unused` 告警与宏展开产生的 `lexical` 误报，其余保持默认 |

## modules/use-magit.el（magit + diff-hl）

| 内容 | 说明 |
|---|---|
| `use-package magit :ensure t` | 延迟加载，首次按 `C-x g` / `C-x M-g` 时触发 autoload |
| `magit-display-buffer-function` / `magit-bury-buffer-function` | status 全屏显示，退出时恢复原窗口布局 |
| `magit-diff-refine-hunk 'all` | diff 行内精修 |
| `magit-save-repository-buffers 'dontask` | 刷新前保存仓库内缓冲区，不询问 |
| `magit-revision-show-gravatars t` | 提交记录显示头像 |
| `git-commit-summary-max-length 50`、`git-commit-fill-column 72` | 提交信息摘要 50 列、正文 72 列折行 |
| `magit-refresh-status-buffer nil` | 刷新时不重建 status 缓冲区 |
| `diff-hl` | 全局 `global-diff-hl-mode` + `diff-hl-flydiff-mode`，`diff-hl-show-staged-changes t`；终端环境（`display-graphic-p` 为 nil）改用右侧边栏 + `diff-hl-margin-mode` |

magit 的日常用法（暂存、提交、rebase、log 等）见 [magit.md](magit.md)。

## modules/use-dape.el（调试）

| 内容 | 说明 |
|---|---|
| `dape-configs` 中 `gdb` | 追加 `defer-launch-attach t`，启动/附加延后到真正需要时 |
| `dape-buffer-window-arrangement 'right` | 调试面板显示在右侧 |
| `gdb-remote` 配置 | `gdb-multiarch --interpreter=dap`，`:request "attach"`，`:target "host:port"` |
| `my/dape-remote` | 交互式选择本地程序、目标主机（默认 `172.16.1.101`）、端口（默认 `1234`），组装成 `gdb-remote` 配置后调用 `dape` |
| `C-c d` 前缀键 | 见下表 |

`C-c d` 下绑定的调试键：

| 键 | 功能 | 键 | 功能 |
|---|---|---|---|
| `d` | `dape`（本地启动） | `a` | `my/dape-remote`（远程 attach） |
| `c` | continue | `n` | next |
| `s` | step in | `f` | step out |
| `u` | until | `r` | restart |
| `P` | pause | `b` | 断点开关 |
| `e` | 条件断点 | `l` | log 断点 |
| `p` | 求值表达式 | `w` | watch（DWIM） |
| `i` | info | `x` | memory |
| `q` | quit | `k` | kill |
| `R` | repl | | |
| `<` | 栈帧上移 | `>` | 栈帧下移 |

注意：`my/dape-remote` 用 `read-file-name ... mustmatch=t` 选本地程序，**必须选已存在的文件**，不支持手输不存在的路径。

调试用法（gdbserver、Qt Creator、断点、内存查看等）见 [debug.md](debug.md)。

## modules/use-dashboard.el（启动欢迎页）

| 内容 | 说明 |
|---|---|
| `use-package dashboard :ensure t` | 从 MELPA 安装，启动时显示欢迎页 |
| `dashboard-items` | 最近工程 10 / 最近文件 5 / 书签 3 |
| `dashboard-projects-backend 'project-el` | 工程列表复用 project.el 的 `project-list-file`（Emacs ≤30 是 `~/.emacs.d/projects`，31 起改名 `projects.eld`；它由 project.el 自动生成、内容是本机绝对路径，**已 gitignore，按机器各自维护**），与 `C-x p p`、treemacs 的 `C-c t` / `C-c T` 共用同一份历史；也可 `M-x project-remember-projects-under` 批量登记 |
| `dashboard-startup-banner 'logo`、`dashboard-center-content t` | 显示 Emacs logo，内容居中 |
| `dashboard-setup-startup-hook` | 仅在**不带文件参数**启动时生效（`emacs foo.c` 不会显示欢迎页） |

工程区块要显示内容，需先让工程进入历史：在工程里执行 `M-x project-remember-project`，
或 `M-x project-remember-projects-under RET ~/Desktop RET`。欢迎页里按 `p` 跳到工程区块、`r` 跳到最近文件区块。

## modules/use-treemacs.el（左侧文件树）

| 内容 | 说明 |
|---|---|
| `C-c t` | 开关侧栏；当前工程不在 workspace 里时，先登记进 project.el 再加进树并定位过去（`my/treemacs-toggle`，走 project.el 的 `.git` 根，不弹目录选择） |
| `C-c T` | `my/treemacs-add-current-project`：先把当前工程登记进 project.el，再 `treemacs-add-and-display-current-project`（projectile → project.el → 当前目录） |
| 延迟加载 | `use-package ... :bind`，首次按键才真正加载 treemacs |
| `treemacs-width 32` | 侧栏宽度 32 列 |
| `treemacs-follow-mode` | 光标移动时在树中定位当前文件 |
| `treemacs-filewatch-mode` | 文件系统变动后自动刷新 |
| `treemacs-git-mode 'deferred` | git 状态着色；deferred 变体需要 `python3` |
| 首次打开 | 只有直接 `M-x treemacs`（空 workspace）才会弹 `Project root:`，默认值是当前目录；`C-c t` / `C-c T` 走的是「先取 project.el 工程根再加树」，不会遇到这个提示，因此**不再**对 `treemacs--read-first-project-path` 做 advice |
| 工程清单 | **以 project.el 为唯一来源**，treemacs 只做展示：`treemacs-persist-file` 设为 `nil` 关闭自带持久化；打开侧栏时 `treemacs-post-buffer-init-hook` 把 `project-known-project-roots` 里还没有的工程补进 workspace；dashboard 的 Projects 块读的也是这份列表 |

图标默认为内置简易图标；想要 VS Code 那种文件类型图标，可安装 `treemacs-nerd-icons` 并执行
`(treemacs-load-theme "nerd-icons")`，前提是系统已安装 Nerd Font。

工程管理与侧栏的完整操作见 [project.md](project.md)。

## modules/use-undo-tree.el（撤销树）

| 内容 | 说明 |
|---|---|
| `use-package undo-tree :ensure t` | 从 MELPA 安装；把线性的 undo 历史组织成树，撤销后继续编辑不会丢掉被撤销的分支 |
| `:init (global-undo-tree-mode 1)` | `global-undo-tree-mode` 是 autoload 的**全局** minor mode；use-package 在没有 `:defer` / `:bind` 时启动即 `require`，写 `:config` 同样会执行，放 `:init` 只是让它更早接管、不依赖加载时机 |
| `undo-tree-auto-save-history` → `nil` | 该变量**默认为 `t`**，会在每个保存过的文件旁生成 `.文件名.~undo-tree~`；置 nil 后撤销历史只存在于当前会话 |
| 撤销容量 | `undo-tree-mode` 会按 `undo-tree-limit` / `undo-tree-strong-limit` / `undo-tree-outer-limit`（默认 80M / 120M / 360M）覆盖当前 buffer 的 `undo-limit` 等，因此 `core/edit.el` 里的 `undo-limit 800000` 在开启后基本不再起作用 |
| 模式行 | lighter 默认为 ` Undo-Tree`，想缩短可加 `(setq undo-tree-mode-lighter " UT")` |

`C-/`（undo）、`M-_`（redo）、`C-x u`（可视化界面，在分支间切换）由 undo-tree 接管。
想跨会话保存撤销历史，把 `undo-tree-auto-save-history` 设回 `t`，并给 `.gitignore` 补 `.*.~undo-tree~`（或用 `undo-tree-history-directory-alist` 集中存放）。

可视化界面的按键、`q` 与 `C-q` 的区别、容量设置的完整说明见 [undo-tree.md](undo-tree.md)。

## modules/use-hungry-delete.el（连删空白）

| 内容 | 说明 |
|---|---|
| `use-package hungry-delete :ensure t` | 从 MELPA 安装；把 cc-mode 的 hungry delete 抽成通用 minor mode |
| `:config (global-hungry-delete-mode 1)` | 全局开启。因为没写 `:defer` / `:bind`，use-package 启动即 `require`，`:config` 必然执行；一旦以后加了 `:defer`，这句得挪到 `:init` |
| 删除行为 | 光标前/后有连续空白（`hungry-delete-chars-to-skip`，默认空格、Tab、换行、回车、换页）时一次删掉整段，否则退化为删一个字符 |
| 与选区 | 有选区时优先删/杀选区，与 `core/edit.el` 的 `delete-selection-mode` 兼容；矩形标记时走原生删除 |
| 跳过的 mode | `hungry-delete-except-modes` 默认 `help-mode` / `calc-mode` / `minibuffer-inactive-mode` |
| 词间空白 | `hungry-delete-join-reluctantly` 设为 `t` 后，删掉两词之间的空白会保留一个空格，避免把 `foo bar` 粘成 `foobar` |
| 模式行 | lighter 为 ` h`，几乎不占地方 |
| 兼容性 | 2021 年的版本，源码用了 27.1 起废弃的 `seq-contains`（只在 `hungry-delete-join-reluctantly` 非 nil 时执行），编译有警告但不影响默认配置 |

按键无需额外绑定：`DEL` / `C-d` 等通过 `[remap delete-backward-char]`、`[remap delete-forward-char]`、
`[remap delete-char]` 接管，`c-mode` 的 `c-electric-backspace` / `c-electric-delete-forward` 也在其中。

## modules/use-multi-edit.el（批量多行编辑）

两类互补的批量编辑：`iedit` 管“同一个词到处改”，`occur-edit` 管“每行改的内容不一样”。

| 内容 | 说明 |
|---|---|
| `use-package iedit :ensure t` | 从 MELPA 安装；`iedit-toggle-key-default` 置 `nil` 关掉自带的自动绑定（它会把同一个键同时绑进 global / isearch / esc / help，`C-c .` 落在 `M-C-c`、`C-h C-c` 上会撞车），改由模块自己绑 |
| `C-c s`（`iedit-mode`） | 光标在符号上按一次，该符号所有出现处同步高亮，改一处全部跟着改；有选区时以选区内容为模式。再按一次退出 |
| `C-c s`（isearch 中） | 在 `C-M-s` / `C-r` 搜索后直接按 `C-c s`，以当前搜索串进入 iedit，可批量改正则匹配；也绕开了 `thing-at-point` 的词边界（`sh-mode` 这类 `.` 算符号的模式里，光标取词会连 `.x` 一起带上，本路径不受影响） |
| `M-C-c` / `C-h C-c` | 不绑定：`esc-map` 上 `M-C-c` 是 `exit-recursive-edit`、`help-map` 上 `C-h C-c` 是 `describe-copying`；重放上次改名用 `M-x iedit-execute-last-modification` |
| 键位选择 | `C-c s` 在 `c-mode` / `c++-mode` / `org-mode` / `sh-mode` / `emacs-lisp-mode` 里都未被占用（已实测），不需要再按 mode 覆盖 |
| `iedit-execute-last-modification` | 记住上一次的批量改名，可在另一个 buffer 里直接重放（适合跨文件改名） |
| `C-c e`（`my/occur-edit-symbol`） | 以光标处符号做 `occur`（`\_<…\_>` 词边界匹配），弹出 `*Occur*` 并直接进入 `occur-edit-mode`；等价于 `M-x occur` 后按 `e`，少一次窗口切换 |
| occur-edit 的写回语义 | Emacs 29 起是**实时联动**：在 `*Occur*` 里改一行，源 buffer 立刻同步；`C-c C-c`（`occur-cease-edit`）只是退出编辑态回到普通 `occur-mode`，再按 `e` 可回去继续 |
| 限制 | occur 条目不能新增（插入换行会被丢弃）；源 buffer 只读时只在回显区提示、不会修改；`occur` 复用同一个 `*Occur*` buffer |

两者都不依赖 overlay 堆叠，比 multiple-cursors 在 `flycheck` / `company` 场景下更稳。
列/矩形编辑仍走内置的 `C-x SPC` + `C-x r t`，按行套用同一操作走 `C-x C-k r`（`apply-macro-to-region-lines`），都不需要装包。

按键冲突提醒：`C-c .` 在 `c-mode` 里是 `c-set-style`、在 `org-mode` 里是 `org-time-stamp`，正因为这个才换成了 `C-c s`（实测各模式均空闲）。`C-;` 也早已释放。

完整的用法、范围控制与常见坑见 [multi-edit.md](multi-edit.md)。

## modules/use-vertico.el（补全框架）

| 内容 | 说明 |
|---|---|
| `vertico` | 竖直候选列表，`vertico-count 13`、`vertico-cycle t`；`C-x` 前缀下用 `vertico-directory-*` 处理目录名（DEL 整段删目录、`M-DEL` 删一段词） |
| `orderless` | 匹配引擎：空格分隔、任意顺序，`"conf init"` 可匹配 `init-config.el`；文件类补全改用 `basic partial-completion`，因为路径上用 orderless 会乱 |
| `marginalia` | 候选右侧旁注：`M-x` 显示命令简介，文件名显示大小/权限 |
| `consult` | `C-x b` 缓冲/书签/最近文件、`C-s` 行内搜索、`M-s r` ripgrep、`M-y` kill-ring 预览、`M-g g/m/i` 行号/标记/imenu |
| `embark` | `C-.` 对当前候选执行动作（复制、删除、重命名、批量标记）；`C-;` 是 `embark-dwim` |
| `embark-consult` | 让 `embark-collect` 缓冲区支持 consult 的实时预览 |

两点说明：

- **不再启用 fido**：`core/view.el` 里的 `fido-vertical-mode` 已移除，`fido`/`icomplete` 与 vertico 抢同一个 minibuffer，不能共存；`read-extended-command-predicate` 保留。
- **`C-s` 给了 `consult-line`**：更快的行内搜索；isearch 仍可用 `C-M-s`（正则）或 `C-r`（反向）进入，`docs/multi-edit.md` 里 `搜索 → C-c s 进 iedit` 的流程改从这两个键进。`M-.` 留给 `xref-find-definitions`，`embark-dwim` 放到了已释放的 `C-;`。

`vertico-directory` 是随 vertico 分发的扩展（不在 `vertico.el` 里、也没有 autoload），模块里显式 `(require 'vertico-directory)`，否则按 `DEL` 会报 `void-function`。

## modules/use-corfu.el（行内补全）

| 内容 | 说明 |
|---|---|
| `corfu` | 缓冲区内补全弹窗；`corfu-auto t`、`corfu-auto-delay 0.3`、`corfu-auto-prefix 2`（设 1 会在每个字符上都打一次 LSP 请求）、`corfu-cycle t`，并开 `corfu-popupinfo-mode` |
| `cape` | LSP 之外的后备候选：`cape-file`(80) 补路径、`cape-dabbrev`(90) 补词；按 CAPF 深度排在 LSP（0）之后 |
| `yasnippet-capf` | 片段候选（50）。**cape 没有 yasnippet 后端**，不要写 `cape-yasnippet` |
| 作用范围 | 以上后备只挂在 `prog-mode` / `text-mode` / `org-mode` 里 |
| TAB | 没有改 `tab-always-indent`：TAB 仍是缩进，弹窗靠 `corfu-auto` 自动弹出 |

完整说明见 [corfu.md](corfu.md)。

## modules/use-yasnippet.el（代码片段）

| 内容 | 说明 |
|---|---|
| `C-c y` | `yas-insert-snippet`，用 vertico + orderless 按名字挑片段 |
| `yas-snippet-dirs` | 默认值本来就是 `~/.emacs.d/snippets/`，模块只负责把目录建出来，不重复追加 |
| `yasnippet-snippets` | 现成片段库（C/C++/Python/JS 等），加载时自动挂进 `yas-snippet-dirs` |
| `:demand t` | 必须写：`:bind` 会把包推迟到首次按键，那样 `yas-global-mode` 启动时根本不会执行 |
| `yas-global-mode` | 全局开启；没把 TAB 给 `yas-expand`，避免和缩进/corfu 抢键 |

片段目录结构、字段跳转键与自定义写法见 [yasnippet.md](yasnippet.md)。

## modules/use-lspmode.el（LSP 通用配置）

| 内容 | 说明 |
|---|---|
| `lsp-mode` | `:commands (lsp lsp-deferred)`；`lsp-completion-provider :capf`（给 corfu）、`lsp-diagnostics-provider :flymake`、`lsp-enable-snippet t`（由 yasnippet 展开服务端片段）、`read-process-output-max` 1MB |
| `which-key` | `lsp-enable-which-key-integration` 依赖它；Emacs 29 未内置（30 才内置），所以显式安装并 `which-key-mode` |
| `lsp-ui` | doc 用 childframe（仅 GUI）、sideline 显示 hover/actions/diagnostics、headerline 面包屑 |
| `C-c l s` / `C-c l i` / `C-c l d` | `lsp-treemacs-symbols` / `lsp-ui-imenu` / `consult-lsp-diagnostics`；`M-9` 是 `lsp-treemacs-errors-list`。**`C-c s` 仍是 iedit，不要占用** |
| 自动弹符号面板 | `lsp-after-initialize-hook` 触发，用 `my/lsp-auto-symbols-p` 开关控制；请求走 `lsp-request-async`（同步会卡 UI），clangd 冷启动时最多重试 3 次 |
| 语言文件共用 | `my/add-exec-path`（往 `exec-path`/$PATH 前插用户 bin 目录）、`my/lsp-deferred-with-server`（server 不在 PATH 时只报警告，不阻断） |

各语言的 mode hook 与 server 参数不放在这里，由语言文件（如 `e-clang-mode.el`）调用 `my/lsp-deferred-with-server`。

完整说明见 [lsp.md](lsp.md)。

## keybindings.el（个人快捷键）

| 按键 | 功能 |
|---|---|
| `F2` | 打开 `init.el` |
| `C-x C-b` | `ibuffer`（替代默认 `buffer-menu`） |

## 版本相关行为

| 版本门槛 | 受影响项 |
|---|---|
| Emacs < 29 | `core/elpa.el` 显式 `package-initialize`；`core/theme.el` 直接使用 `tsdh-dark` |
| Emacs ≥ 29 | 依赖默认包激活；优先 `modus-operandi-tinted` |
| Emacs 28.1+ | `read-extended-command-predicate`、`repeat-mode`、`core/suppress.el` 整体生效 |
| Emacs 26.1+ | `global-display-line-numbers-mode` |
| Emacs 29.1+ | `pixel-scroll-precision-mode` |

版本判断使用 `version<=` / `emacs-major-version`，低版本自动跳过对应功能，不会报错。

## 常用按键速查

| 按键 | 功能 |
|---|---|
| `F2` | 打开 `init.el` |
| `C-x C-b` | `ibuffer` 缓冲区列表 |
| `C-x g` / `C-x M-g` | magit-status / magit-dispatch |
| `C-c d` | dape 调试前缀键（见上文） |
| `C-x u`（可连按 `u`） | 撤销（repeat-mode） |
| `C-c <left>` / `C-c <right>` | 撤销 / 重做窗口布局 |
| `Shift + ↑↓←→` | 切换窗口焦点 |

## 恢复默认行为

所有选项按文件、逐条独立。不想要某项功能，注释掉对应行重启 Emacs 即可。
`M-x customize-*` 写入的 `.config-auto.el` 已被 gitignore，可随时删除让它重新生成。
