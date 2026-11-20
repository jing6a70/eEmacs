# README

配置文档索引。

| 文件 | 内容 |
|---|---|
| `00-basics.md` | Emacs 基础操作（文件/光标/复削/搜索/窗口） |
| `01-lsp-cpp.md` | C/C++ LSP 补全（clangd）与符号面板 |
| `02-treemacs.md` | Treemacs 项目树快捷键与使用 |
| `03-magit.md` | Magit git 管理（status/diff/log/conflict） |
| `04-multi-line-editing.md` | 多行编辑（multiple-cursors / iedit / expand-region） |
| `05-misc-tools.md` | 其他工具（搜索、拼写检查、undo-tree 等总览） |
| `06-shell-lsp.md` | Shell 脚本 LSP（bash-language-server） |
| `07-go-python-lsp.md` | Go（gopls）与 Python（pyright）LSP |
| `08-projectile.md` | Projectile 项目管理（主力方案）与内置 project.el 对比 |

---

## 开发说明

- 本配置优先 projectile（`C-c p`），project.el 内置（`C-x p`）作为生态标准共存
- LSP 根识别链：projectile → project.el → cwd

