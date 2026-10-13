# 配置选项说明

本配置**只使用 Emacs 原生内置功能**,不依赖任何第三方包。建议 Emacs 29+(`repeat-mode` / `fido-vertical-mode` / `use-short-answers` 需 28+,`pixel-scroll-precision-mode` 需 29+,modus 主题需 28+)。

## 目录结构

```text
~/.emacs.d/
├── early-init.el            # 最早执行:跳过包激活、提前关 UI、启动期 GC 调优
├── init.el                  # 入口:设定目录、按序加载配置、启用内置主题
├── keybindings.el           # 个人快捷键(与 init.el 同级)
├── core/
│   ├── base-ui.el           # 界面与显示
│   ├── base-edit.el         # 编辑行为
│   ├── coding-style-linux.el# C/C++ 代码风格(Linux)
│   └── custom-file.el       # custom-file 管理(M-x customize 的写入位置)
└── docs/                    # 文档
```

---

## early-init.el(最早执行)

| 内容 | 说明 |
|---|---|
| `package-enable-at-startup nil` | 不使用第三方包,跳过启动时的包激活 |
| UI 关闭 | 在首个 frame 创建前关闭菜单栏/工具栏/滚动条,避免界面闪烁 |
| `gc-cons-threshold` 拉高 | 启动阶段放宽 GC,减少启动时间(init.el 结束时恢复为 64MB) |

## init.el(入口)

| 内容 | 说明 |
|---|---|
| `user-emacs-directory` | 以 init.el 实际所在目录为配置根目录,放在任意位置均可工作 |
| 加载顺序 | base-ui.el → base-edit.el → coding-style-linux.el → custom-file.el → keybindings.el |
| `load-theme 'modus-vivendi` | 内置深色主题(Emacs 28+)。可替换:`modus-operandi`、`wombat`、`deeper-blue`,`M-x customize-themes` 可预览全部内置主题 |
| `server-start` | 启动 Emacs server,可用 `emacsclient` 快速连入(batch 模式自动跳过) |
| `emacs-startup-hook` | 启动完成后把 GC 阈值恢复为 64MB |

## core/base-ui.el(界面与显示)

| 选项 | 说明 |
|---|---|
| `menu-bar-mode` / `tool-bar-mode` / `scroll-bar-mode` 关闭 | 极简界面 |
| `inhibit-splash-screen t` | 跳过启动画面 |
| `use-dialog-box nil` | 禁用 GUI 弹窗,交互走 minibuffer |
| `cursor-type 'bar` | 条形光标 |
| `cursor-in-non-selected-windows nil` | 非活动窗口不显示光标 |
| `blink-cursor-mode -1` | 关闭光标闪烁 |
| `initial-scratch-message nil` | `*scratch*` 留空 |
| `ring-bell-function 'ignore` | 关闭响铃 |
| `global-display-line-numbers-mode` | 显示行号 |
| `column-number-mode` | 显示 `行号:列号` |
| `which-function-mode` | mode-line 显示当前函数名 |
| `fido-vertical-mode` | 垂直补全 UI(原生版 vertico,Emacs 28+) |
| `read-extended-command-predicate` | `M-x` 不列出内部命令(Emacs 28+) |
| `winner-mode` | `C-c <left>` / `C-c <right>` 撤销 / 重做窗口布局 |
| `windmove-default-keybindings` | `Shift + 方向键` 切换窗口 |
| `pixel-scroll-precision-mode` | 像素级平滑滚动(`fboundp` 守卫,Emacs 29 以下跳过) |
| `scroll-conservatively 101`、`scroll-margin 2` | 提前滚动、边缘留白,减少跳屏 |
| `global-auto-revert-mode` | 文件被外部改动后自动重载 |

## core/base-edit.el(编辑行为)

| 选项 | 说明 |
|---|---|
| `make-backup-files nil` | 不生成 `file~` 备份(注意 `#file#` 自动保存默认仍开启) |
| `require-final-newline t` | 保存时保证文件以换行结尾 |
| `delete-by-moving-to-trash t` | 删除文件移入系统回收站 |
| `prefer-coding-system 'utf-8` | 统一 UTF-8 |
| `electric-pair-mode` | 自动补全配对括号 |
| `show-paren-mode` | 高亮匹配括号 |
| `delete-selection-mode` | 选中后直接输入即覆盖 |
| `byte-compile-docstring-max-column 120` | 放宽 docstring 列宽限制 |
| `use-short-answers t` | 提示用 `y/n` 代替 `yes/no`(Emacs 28+) |
| `undo-limit` / `undo-strong-limit` / `undo-outer-limit` | 加大撤销历史 |
| `recentf-mode` | 最近文件列表 |
| `save-place-mode` | 重开文件回到上次光标位置 |
| `savehist-mode` | 持久化 minibuffer / `M-x` 历史 |
| `repeat-mode` | 重复命令免前缀(Emacs 28+) |
| `dired-dwim-target t` | 两个 dired 窗口间直接复制/移动 |

## core/coding-style-linux.el(C/C++ 代码风格)

| 选项 | 说明 |
|---|---|
| `indent-tabs-mode nil`、`tab-width 4` | 缩进只用空格,Tab 宽度 4 |
| `c-basic-offset 4`、`c-default-style "linux"` | C/C++ 采用 Linux 内核风格,缩进 4 |

## core/custom-file.el(custom-file 管理)

| 内容 | 说明 |
|---|---|
| `custom-file` → `~/.emacs.d/.config-auto.el` | `M-x customize-*` 的自动写入定向到该独立文件(已 gitignore),不污染 init.el |

## keybindings.el(个人快捷键)

| 按键 | 功能 |
|---|---|
| `F2` | 打开 `init.el` |
| `F5` | 重新加载配置 |
| `C-x C-b` | `ibuffer`(替代默认 `buffer-menu`) |

---

## 常用按键速查

| 按键 | 功能 |
|---|---|
| `F2` / `F5` | 打开配置 / 重载配置 |
| `C-x C-b` | ibuffer 缓冲区列表 |
| `C-x u`(可连按 `u`) | 撤销(repeat-mode) |
| `C-c <left>` / `C-c <right>` | 撤销 / 重做窗口布局 |
| `Shift + ↑↓←→` | 切换窗口焦点 |

## 恢复默认行为

所有选项按文件、逐条独立。不想要某项功能,注释掉对应行重启 Emacs 即可。
