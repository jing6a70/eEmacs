# C/C++ 开发功能（e-clang-mode）

## 概览

LSP（语言服务）由 `use-lspmode.el`（核心）+ `e-clang-mode.el`（C/C++ 专属）组成。打开任何 `.c`/`.h`/`.cpp` 文件时，clangd 自动启动（懒加载，打开时才启动）。

**前提**：`clangd` 必须在 PATH 中。项目的 `build/` 目录下需要 `compile_commands.json` 供 clangd 使用（按键 `F6` 生成，见下）。

## 基本快捷键（所有语言通用，定义在 `use-lspmode.el`）

| 键 | 操作 |
|---|---|
| `M-9` | 错误列表（`lsp-treemacs-errors-list`） |
| `C-c s` | 符号（函数/变量）树（`lsp-treemacs-symbols`） |
| `C-c i` | 用 lsp-ui imenu 打开文件大纲 |
| `M-.` | 跳转到定义 |
| `M-,` | 回到之前的暂停位置 |
| `M-?` | 查找引用 |
| `C-c l r` | 重命名符号 (lsp-rename) — **首选**用于源代码 |
| `C-c l a` | 在点处运行代码操作（快速修复；等待菜单） |

## C/C++ 相关命令（由 `e-clang-mode.el` 文件）

| 键 | 操作 |
|---|---|
| `<f6>` | 在项目的 `build/` 目录运行 cmake 并刷新 `compile_commands.json` (`my/cmake-update-compile-commands`) |
| — | clangd 标志已在 `e-clang-mode.el` 中配置：`-j=4`，后台索引，`--compile-commands-dir=build`，无头文件插入 |

## 工作流：如何获取补全

1. 打开 项目的 `CMakeLists.txt`（项目根目录必须有 `CMakeLists.txt`）。
2. 按键 `<f6>`（生成 `build/compile_commands.json`，clangd 会自动读取它）。
3. 首次打开需要一些时间 — clangd 会从头建立后台索引。
4. 代数完成后出现补全列表：
   - 停留片刻，输入内容，内联弹出。
   - 也注意 minibuffer 中的诊断信息。
5. 访问错误以 `M-9`。

## 符号面板行为（针对你在开发期间注意的问题）

- 符号面板自动打开（有 3 秒空闲重试，避免在 LSP 启动时无符号）。
- 如果你不再打开面板，你可以随时用 `C-c s` 手动重新打开。
- 面板追踪当前项目符号树，使用 C++ 中择优代码。

---

## 手动启动/停止

| 命令 | 操作 |
|---|---|
| `M-x lsp-workspace-shutdown` | 停止当前项目的 clangd |
| `M-x lsp-workspace-restart` | 重启 clangd（在修改 `.clangd` 配置后有用） |

## 故障排除

- **没有跳转定义**：`compile_commands.json` 未生成（运行 `<f6>`），或 clangd 在后台索引。
- **补全无法正常工作**：确保项目有工作的 CMake 设置和 `build/` 目录。
