# Go 与 Python LSP（e-golang-mode / e-pylang-mode）

## 概览

两个语言模块沿用 e-clang-mode 的模式：

| 文件 | 语言 | 服务器 |
|---|---|---|
| `elisp/e-golang-mode.el` | Go | gopls |
| `elisp/e-pylang-mode.el` | Python | pyright（微软官方，npm 分发） |

通用核心（`M-9` / `C-c s` / `C-c i` 等）由 `use-lspmode.el` 提供，两者与 C/C++、Shell 完全一致。

## 快捷键（全语言通用）

| 键 | 操作 |
|---|---|
| `M-9` | 错误列表 |
| `C-c s` | 符号树 |
| `C-c i` | 大纲视图 |
| `M-.` | 跳转定义 |
| `M-?` | 查找引用 |
| `C-c l r` | 重命名（gopls: 变量/函数/类型 都支持） |
| `C-c l a` | code action（快速修复） |

---

## Go 安装（每台机器一次性执行）

```bash
go install golang.org/x/tools/gopls@latest
```

二进制会落在 `~/go/bin/gopls`，`e-golang-mode.el` 会在加载时把该目录加进 `exec-path`，所以无需手动 export PATH。

### 触发文件

`go-mode` 由 go-mode 包提供，lsp-mode 官方 `lsp-install-server` 也不会装它——本配置显式 `use-package go-mode :ensure t`。

### 验证方法

1. 建个项目或打开现有 `main.go`。
2. 等底栏出现 `LSP :: gopls`；首次启动后台索引几秒。
3. 输入 `fmt.` 应当弹出 `Printf` 等代码补全。

---

## Python 安装（每台机器一次性执行）

```bash
npm install -g --prefix ~/.local/npm-global pyright
```

和 bash-language-server 共用同一个用户 npm prefix（无需 root）。`e-pylang-mode.el` 同样会自动把 npm bin 目录加进 `exec-path`。

### 为什么不用 pylsp？

- pyright 由微软发布，npm 安装最省事（跨发行版一致，Arch/Ubuntu 都一样）。
- `python-pylsp`、`pylsp` 需要系统 Python 包管理（Arch 上还要 pacman，18.04 需要 pip），略复杂。

如果您坚持 pylsp (社区风格插件更多)，可以：
1. `sudo pacman -S python-pylsp`（arch）
2. 把 `e-pylang-mode.el` 中 hook 的 server 改为 `lsp-pylsp`

### 验证方法

1. 打开任意 `.py` 文件，敲入 `import os` 回车后第二行输入 `os.p`，补全弹出。
2. `M-9` 查看类型错误提示（pyright 独有的类型推定警告）。
3. 未配置的类型提示（typing）同样支持。

---

## 依赖清单（README 快速参考）

| 工具 | 来源 | 用于 |
|---|---|---|
| go | 系统 | go-mode 编译 |
| gopls | `go install` | Go LSP |
| pyright | `npm install -g --prefix` | Python LSP |
| node / npm | 系统 | pyright & bash-language-server 运行时 |
