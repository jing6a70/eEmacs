# Shell 脚本 LSP（e-bash-mode）

## 概览

编辑 `.sh` / `.bash` 文件时使用 bash-language-server，享受与 C/C++ 相同的 LSP 补全能力：

| 功能 | 状态 |
|---|---|
| 补全（内置命令/变量/路径） | ✅ |
| 跳转函数定义 | ✅（同一文件内） |
| ShellCheck 语法诊断 | ✅（需要 shellcheck 二进制） |
| 建议美化 (shellcheck pkg) | ✅ |
| 重命名 | 部分（bash 的 symbol 跟踪较弱） |

## 安装 server binary（一次）

无需 root 权限 — 使用用户 npm prefix：

```bash
npm install -g --prefix ~/.local/npm-global bash-language-server
```

配置（`elisp/e-bash-mode.el`）在加载时自动把 `~/.local/npm-global/bin` 加至 `exec-path`，无需 root install。

## 快捷键（与 C/C++ 同一套）

| 键 | 操作 |
|---|---|
| `M-9` | 错误列表 |
| `C-c s` | 符号（函数/变量） |
| `C-c i` | outline 视图 |
| `M-.` | 跳转函数定义 |
| `M-?` | 查找引用（仅当前文件内） |
| `C-c l a` | 代码动作（快速修复） |

## 建议安装 shellcheck（可选但推荐）

bash-language-server 会自动调用 shellcheck 进行诊断（如果安装了）。

```bash
# Archlinux
sudo pacman -S shellcheck
# Ubuntu 18.04
sudo apt install shellcheck
```

安装完 shellcheck 并在编辑 bash 脚本时按 `M-9`，即可看到语法/风格警告列表。

## 验证方法

1. 打开仓库里的 `sh/emacs-askpass.sh` 或任意 `.sh` 文件。
2. `echo $(date)` - 输入 `ls` 位置，等待自动补全。
3. 输入错的任何一项都会产生红波浪线（shellcheck 开启时）。
