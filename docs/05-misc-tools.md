# Misc 工具

> 其他模块快速参考（文件在 `modules/` + `elisp/`）。

---

## 编辑相关小工具

| 模块 | 功能 |
|---|---|
| `use-hungry-delete` | `C-d`/`C-DELETE` 连带删除同一类型的多余字符（一键删多空格等） |
| `use-undo-tree` | `C-x u` 打开可视化撤销树（H / L / p / q 操作） |
| `use-yasnippet` | `C-c y` 插入代码模板（yasnippet；模板目录 `./snippets/`） |
| `use-which-key` | 按键操作时底部自动弹出提示菜单 |

## 补全/搜索框架 (`use-vertico.el`)

| 键 | 操作 |
|---|---|
| `C-s` | consult-line（按行全文搜索） |
| `C-x b` | consult-buffer（预览 + 切换） |
| `M-y` | consult-yank-pop（剪贴板预览历史） |
| `M-g i` | consult-imenu（跳到函数定义） |
| `M-s r` | consult-ripgrep（项目全文 grep，需 ripgrep） |
| `M-.` / `C-.` | embark-dwim / embark-act(前操作列表) |

## Git 相关 (`use-magit.el`)

| 键 | 操作 |
|---|---|
| `C-x g` | 打开 magit status（见 `03-magit.md`） |
| `C-x G` | git-timemachine（单文件回溯观察历史） |

## 拼写检查 (`use-spell.el`)

- `M-$` 纠正光标处单词（Doom 风格的传统 flyspell）
- 依赖 aspell 或 hunspell + 英语词典

## 多行编辑 (`use-multi-edit.el`)

见 `04-multi-line-editing.md`。

## Modle line & 主题

- 主题：doom-tem-city-lights
- 模式栏颜色包含文件大小、分支名、LSP 状态等。

## 终端模式 (GUI 关闭时)

- `diff-hl` 主题切换 margin 人物。
- 字体：可用 fallback 到默认字体 when FiraCode 不存在。

## 配置文件的位置

| 文件 | 内容 |
|---|---|
| `init.el` | 总入口，加载所有模块 |
| `core/` | 基础设置 + 包源 + custom-file |
| `view/` | 主题 + 字体模型线 |
| `modules/use-*.el` | Github 下载的第三方包配置 |
| `elisp/e-*.el` | 自有语言模块（e- 前缀） |
| `elisp/init-func*.el` | 自定义函数和全局键位 |
| `docs/` | 本参考文档 |
| `snippets/` | yasnippet 代码模板 |
| `sh/` | 辅助 shell 脚本（例如 sudo askpass） |

## 外部依赖

| 工具 | 来源 | 用途 |
|---|---|---|
| `fyraCode Nerd Font` | `yay` | Treemacs / modeline 彩色图标 |
| `clangd` | 系统 | C/C++ LSP |
| `vscode CMake` 或 `cmake` | 系统 | 生成 compile_commands.json |
| `python3` | 系统 | treemacs git deferred 模式 |
| `hunspell-en_us` / `aspell-en` | 系统 | flyspell 拼写检查 |
| `rg` (ripgrep) | 系统 | `consult-ripgrep` 全文搜索 |
| `gopls` | `go install` | Go LSP (`e-golang-mode`) |
| `pyright` | npm（用户前缀） | Python LSP (`e-pylang-mode`) |
| `node` / `npm` | 系统 | pyright / bash-language-server 运行时 |
