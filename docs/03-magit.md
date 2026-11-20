# Magit 快捷键

## 概览

Magit 是纯个性化 Elisp 的 Git 客户端。通过 `C-x g` 打开状态视图。

## 主命令

| 键 | 操作 |
|---|---|
| `C-x g` | 打开 Magit status 缓冲 |
| `C-x M-g` | 弹出 Magit 所有命令菜单 |
| `C-c M-g` | 选择文件操作 (若 magit-mode 激活) |

## 状态缓冲区 (整个 Magit 工作流)

| 键 | 操作 |
|---|---|
| `g` | 刷新状态缓冲 |
| `TAB` | 延迟当前分支或 hunk |
| `s` | 暂存点处的 hunk/文件 |
| `u` | 取消暂存点处的 hunk/文件 |
| `k` / `C-k` | 丢弃 hunk / 文件（小心！不可恢复） |
| `c c` | 创建提交（在弹出菜单后直接创建） |
| `c e` | 修改上一个提交（`--amend`） |
| `A` | 交互式 rebase |
| `P` | 推送到远程 (e.g. `p` 推去 origin) |
| `F` | 拉取远程更改 |
| `!` | 打开 Git 命令面板 |
| `q` | 关闭状态缓冲 |

## 补遗

| 键 | 操作 |
|---|---|
| `b b` | 切换分支 |
| `l l` | 打开提交日志 |
| `z z` | magit 内置暂存区 (stash) 操作 |

## Diff / 变更部分

| 键 | 操作 |
|---|---|
| `+` | 扩展当前部分 |
| `-` | 缩减当前部分 |
| `s` / `S` | 单单暂存 hunk / 暂存整个文件 |
| `C-x 4 a` | 输入新的 change buffer |

## 解决解决冲突

1. 打开项目任意文件，按 `C-x g` 打开 Magit。
2. Magit 的 Unmerged 部分显示冲突文件。
3. 对文件按 `e` 进入 **ediff**（三方编辑：base / yours / theirs）；
   或按 `TAB` 展开文件直接用 Emacs 的冲突查看 (`smerge-mode` 自动激活)。
4. 解决冲突时：
   - `C-c ^ u` 保留你的部分
   - `C-c ^ l` 保留他们的部分
   - `C-c ^ b` 保留基准部分
   - `C-c ^ a` 保留双方
   - 然后 `M-x smerge-solve-exact`（某些冲突的猜测功能）
5. 全部处理后按 `s` 暂存所有 stale 文件然后 `c c` 进行 **merge commit**。

## 子命令

| 命令 | 操作 |
|---|---|
| `M-x magit-file-dispatch` | 文件级 git 操作（blame、log） |
| `M-x magit-blame` | 在当前缓冲内逐行标记修改作者 |
| `C-x G` | git-timemachine（单文件逐步回溯；设置在 `use-magit.el`） |

## Forge 集成（Forgejo / 自建 GitLab）

在使用 Magit 前，需要设置一次 Forgejo/Forge 后端：

```
M-x forge-pull
```

它会建立 issue/PR 跟踪。Follow-up issues / PR可以打开自 Forge Forge 状态栏。

## 常用组合

- 推送并拉取 commit: `C-x g` → 暂存 → `c c` → 输入提示 → `P p`
- 查看当前历史：`C-x g` → `l L`（列出所有提交）→ `RET` 显示 diff
- 重置到修改前：`C-x g` → `C-u M-k` (由过滤项挑选) → `M-x magit-reset-hard`

## 故障排除

- **状态缓冲被卡住**：`g` 刷新，.or `M-x magit-greenkill`。
- **冲突文件被删除**：`M-x magit-checkout-ref RET HEAD` — 使用谨慎
