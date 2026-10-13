# 配置选项说明

本配置**只使用 Emacs 原生内置功能**,不依赖任何第三方包。建议 Emacs 29+(`repeat-mode` 需 28+,`pixel-scroll-precision-mode` 需 29+,modus 主题需 28+)。

# 目录结构

```text
~/.emacs.d/
├── init.el               # 入口:设定目录、按序加载 core、启用内置主题
├── core/
│   ├── base-ui.el       # 界面与显示
│   ├── base-edit.el     # 编辑行为
│   └── custom-file.el   # custom-file 管理(M-x customize 的写入位置)
└── ...
```

---

# core/base-ui.el

**界面与显示**

| 选项                                                             | 说明                                                |
| ---------------------------------------------------------------- | --------------------------------------------------- |
| `(menu-bar-mode -1)` `(tool-bar-mode -1)` `(scroll-bar-mode -1)` | 关闭菜单栏 / 工具栏 / 滚动条,极简界面               |
| `inhibit-splash-screen t`                                        | 跳过启动画面                                        |
| `cursor-type 'bar`                                               | 条形光标(默认方块)                                  |
| `global-display-line-numbers-mode`                               | 所有缓冲区显示行号                                  |
| `column-number-mode`                                             | mode-line 同时显示 `行号:列号`                      |
| `use-dialog-box nil`                                             | 禁用 GUI 弹窗,一切交互走 minibuffer                 |
| `initial-buffer-choice nil`                                      | 命令行带文件参数启动时只打开文件,不附加 `*scratch*` |
| `winner-mode`                                                    | `C-c <left>` / `C-c <right>` 撤销 / 重做窗口布局    |
| `pixel-scroll-precision-mode`                                    | 像素级平滑滚动(替代逐行滚动)                        |
| `global-auto-revert-mode`                                        | 文件被外部程序(git、脚本等)修改后,缓冲区自动刷新    |
| `windmove-default-keybindings`                                   | `Shift + 方向键` 在窗口间移动焦点                   |

# core/base-edit.el

**编辑行为**

| 选项                                          | 说明                                                                |
| --------------------------------------------- | ------------------------------------------------------------------- |
| `make-backup-files nil`                       | 不生成 `file~` 备份文件                                             |
| `electric-pair-mode`                          | 输入 `(` 自动补 `)`,适用于括号/引号/方括号等                        |
| `show-paren-mode`                             | 光标在括号旁时高亮匹配的另一半                                      |
| `delete-selection-mode`                       | 选中区域后直接输入即覆盖(与现代编辑器一致)                          |
| `indent-tabs-mode nil`、`tab-width 4`         | 缩进只用空格,Tab 宽度 4                                             |
| `c-basic-offset 4`、`c-default-style "linux"` | C/C++ 采用 linux 内核风格,缩进 4                                    |
| `byte-compile-docstring-max-column 120`       | 字节编译时放宽 docstring 长度限制,减少无谓警告                      |
| `recentf-mode`                                | 最近文件列表(`M-x recentf-open-files`)                              |
| `save-place-mode`                             | 重新打开文件时回到上次的光标位置                                    |
| `savehist-mode`                               | 持久化 minibuffer / `M-x` 命令历史,重启不丢                         |
| `repeat-mode`                                 | 重复命令无需重复前缀键(Emacs 28+)。例如 `C-x u` 后再按 `u` 继续撤销 |

# core/custom-file.el

**custom-file 管理**

| 内容                                         | 说明                                                                                                                |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `custom-file` → `~/.emacs.d/.config-auto.el` | `M-x customize-*` 系列的自动写入被定向到该独立文件(已被 .gitignore 忽略),不会污染 init.el。文件不存在时首次自动创建 |

---

## 常用按键速查

| 按键                         | 功能                |
| ---------------------------- | ------------------- |
| `C-x u`(可连按 `u`)          | 撤销(repeat-mode)   |
| `C-c <left>` / `C-c <right>` | 撤销 / 重做窗口布局 |
| `Shift + ↑↓←→`               | 切换窗口焦点        |
| `C-x C-b`                    | 缓冲区列表          |
| `C-x C-f` / `C-x C-s`        | 打开 / 保存文件     |

## 恢复默认行为

所有选项都在 `core/base-ui.el` 和 `core/base-edit.el` 中,逐条独立。不想要某项功能,注释掉对应行重启 Emacs 即可。
