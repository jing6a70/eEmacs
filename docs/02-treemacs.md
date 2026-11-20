# Treemacs 项目树

## 概览

Treemacs 提供左侧边栏文件树，适用于在项目中工作。它 **不会** 在启动时运行。通过按键 `C-x t t` 或 `M-0` 按需要打开。

## 打开 / 切换

| 键 | 操作 |
|---|---|
| `C-x t t` | 在当前窗口打开 Treemacs (toggle) |
| `M-0` | 跳转到 Treemacs 窗口 |
| `C-x t 1` | 将 Treemacs 放入整帧 |
| `C-x t B` | 将书签添加到 Treemacs 工作区 |
| `C-x t C-t` | 查找文件（从当前光标显示树） |
| `C-x t M-t` | 查找标签 |

## 基本导航

在 Treemacs 缓冲区内：

| 键 | 操作 |
|---|---|
| `RET` | 打开当前项目（或打开缓冲） |
| `TAB` | 延迟节点 |
| `M-n` / `M-p` | 跳转到上/下一个相同级别的项 |
| `h` | 递向上文件夹 |
| `L` | 递向下文件夹 |
| `w` | 显示窗口并跳出到 Treemacs 窗口 |
| `yf` | 复制当前文件（其他 y* 命令可复制/移动） |
| `C-x d` / `q` | 关闭 Treemacs (sr.) |

## Git 状态

- 文件树对修改文件（蓝）和未跟踪文件（黄）的修改带有颜色。
- 从 Magit 中暂存/提交后，树自动重新刷新。
- 当心：在 **终端** 时 PNG 图标备用。

## 跟踪文件（开启后）

Treemacs 使用 `treemacs-project-follow-mode`。在项目文本中跳转时，树会自动更新。你家目录和 `~/.emacs.d` 从未被跟踪（不受干扰）。

## 宽度调整

| 键 | 操作 |
|---|---|
| `C-x }` | Treemacs 窗口加宽 |
| `C-x {` | Treemacs 窗口缩窄 |

---

## 自定义之外注意

- 在 Treemacs 缓冲中键入 `C-x t M-t` 等命令。
- 关闭/清理 TUI 时会上下文绑定（`M-0`= winum 的窗口编号），行为可能不同。

## 故障排除

- **树是空的**：可能项目不在 workspace（跑 `M-x treemacs-projectile` 添加当前项目）。
- **颜色不显示 git 状态**：使用 `M-x treemacs-git-mode` 设为 `deferred`（含 python3）。

