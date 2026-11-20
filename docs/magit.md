# magit 使用手册

> 配置在 `modules/use-magit.el`, magit 20261013(MELPA), 依赖 `magit-section`,
> `transient`, `with-editor`. 本文记录日常用法, 键位以 magit 界面底部提示为准.

## 1. 使用方式

| 入口               | 说明                                              |
| ------------------ | ------------------------------------------------- |
| `C-x g`            | 打开当前仓库的 magit-status(在仓库内任意文件里按) |
| `C-x M-g`          | magit-dispatch, 命令面板, 列出所有 magit 命令     |
| `M-x magit-status` | 不在仓库文件里时, 手动选一个仓库目录              |

magit 的按键是 **transient** 形式: 按一个前缀键后, 窗口底部会列出这一层还能按哪些键;
再按第二层键才真正执行.`C-g` 取消当前 transient, `q` 关闭 magit 缓冲区.

status 缓冲区里 `TAB` 展开/折叠区块, `RET` 访问光标处的东西(文件, 提交, 分支).

## 2. 常用键位

### 刷新与浏览

| 键    | 作用        | 键    | 作用              |
| ----- | ----------- | ----- | ----------------- |
| `g`   | 刷新 status | `q`   | 关闭 magit 缓冲区 |
| `TAB` | 展开/折叠   | `RET` | 访问光标处对象    |

### 暂存与提交

| 键            | 作用                                          |
| ------------- | --------------------------------------------- |
| `s`           | 暂存光标处的 hunk 或文件(`magit-stage-files`) |
| `u`           | 取消暂存(`magit-unstage-files`)               |
| `S`           | 暂存所有已修改文件(`magit-stage-modified`)    |
| `U`           | 全部取消暂存(`magit-unstage-all`)             |
| `c c`         | 提交(`commit`)                                |
| `c a`         | 修补上一次提交(`amend`)                       |
| `c e`         | 继续上一次提交(`extend`)                      |
| `c f` / `c s` | fixup / squash 到某次提交                     |

### 查看历史与差异

| 键                          | 作用                      |
| --------------------------- | ------------------------- |
| `l l`                       | 当前分支的提交历史        |
| `l L`                       | 指定分支/引用的历史       |
| `d d`                       | 光标处/整个工作区的差异   |
| `d s` / `d u`               | 只看已暂存 / 未暂存的差异 |
| `M-x magit-log-buffer-file` | 当前文件的历史            |
| `M-x magit-blame`           | 逐行标注是谁改的(blame)   |

### 分支与远程

| 键    | 作用                                          |
| ----- | --------------------------------------------- |
| `b b` | 切换分支(checkout)                            |
| `b c` | 新建分支                                      |
| `b d` | 删除分支                                      |
| `f`   | fetch                                         |
| `F`   | pull                                          |
| `P`   | push(`P p` 推到指定远端, `P u` 设置 upstream) |

### 合并, 变基, stash

| 键    | 作用                     |
| ----- | ------------------------ |
| `m`   | merge                    |
| `r`   | rebase(`r i` 交互式变基) |
| `z z` | stash 当前改动           |
| `z p` | pop stash                |
| `z a` | apply stash(保留 stash)  |
| `A`   | cherry-pick              |
| `t`   | tag                      |

### 危险操作(会改历史或丢数据)

| 键                  | 作用                          |
| ------------------- | ----------------------------- |
| `x`                 | 重置(`magit-reset-quickly`)   |
| `k`                 | 删除光标处对象(分支/stash 等) |
| `M-x magit-discard` | 丢弃光标处的改动              |

## 3. 配置项

| 设置                                                                   | 效果                                                           |
| ---------------------------------------------------------------------- | -------------------------------------------------------------- |
| `C-x g` / `C-x M-g`                                                    | 分别绑定 `magit-status` 和 `magit-dispatch`                    |
| `magit-display-buffer-function` = `fullframe-status-v1`                | status 及命令缓冲区用整屏显示                                  |
| `magit-bury-buffer-function` = `restore-window-configuration-and-bury` | `q` 关闭后恢复原来的窗口布局                                   |
| `magit-diff-refine-hunk 'all`                                          | diff 里做词级高亮, 而不只是行级                                |
| `magit-save-repository-buffers 'dontask`                               | 执行 git 操作前自动保存仓库内改过的 buffer, 不询问             |
| `magit-revision-show-gravatars t`                                      | log 里显示提交者头像(仅图形界面)                               |
| `git-commit-summary-max-length 50`                                     | 提交标题超过 50 列会标黄提醒                                   |
| `git-commit-fill-column 72`                                            | 提交正文按 72 列折行                                           |
| `magit-refresh-status-buffer nil`                                      | 执行 git 命令后**不自动**刷新 status(大仓库省时间), 要手动 `g` |
| `diff-hl` 集成                                                         | fringe/margin 里标记未提交改动; 终端下改用右侧 margin          |

## 4. 常见流程

### 提交与暂存

| 功能               | 操作                           |
| ------------------ | ------------------------------ |
| 暂存当前 hunk/文件 | `s`                            |
| 取消暂存           | `u`                            |
| 暂存所有修改       | `S`                            |
| 提交               | `c c`, 写 message 后 `C-c C-c` |
| 修补上一次提交     | `c a`                          |
| 继续上一次提交     | `c e`                          |
| 放弃本次提交       | 提交缓冲区里 `C-c C-k`         |

### 历史与差异

| 功能              | 操作                                  |
| ----------------- | ------------------------------------- |
| 当前分支历史      | `l l`                                 |
| 指定分支/引用历史 | `l L`                                 |
| 某个文件的历史    | 打开文件, `M-x magit-log-buffer-file` |
| 逐行看谁改的      | `M-x magit-blame`                     |
| 某次提交改了什么  | `l l` → 提交上 `RET` → `d d`          |
| 已暂存/未暂存差异 | `d s` / `d u`                         |

### 分支

| 功能     | 操作  |
| -------- | ----- |
| 切换分支 | `b b` |
| 新建分支 | `b c` |
| 删除分支 | `b d` |

### 从其他分支取文件/目录

| 功能                 | 操作                                                       |
| -------------------- | ---------------------------------------------------------- |
| 取当前文件           | 文件里 `C-c M-g` → `, c` → 选分支/提交 → 回车              |
| 取任意文件或整个目录 | `M-x magit-file-checkout` → 选 rev → TAB 选文件或目录      |
| 等价 git 命令        | `!` 运行 `git checkout <rev> -- <path>`                    |
| 只覆盖工作区, 不暂存 | `!` 运行 `git restore --source=<rev> --worktree -- <path>` |

注意: `git checkout rev -- path` 会**同时更新暂存区**, 取回后直接 `c c` 提交即可;
操作会覆盖工作区里的同名文件, 未提交的改动会丢失, 先提交或 `z z` stash.

### 只合并某个目录

Git 没有"只合并子目录"的直接命令, 两种变通做法:

| 方案                                      | 操作                                                                                                               |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| 覆盖式(简单, 无合并历史)                  | `M-x magit-file-checkout` 选分支 + 目录, 然后 `c c` 提交; 或 `!` 运行 `git checkout <branch> -- <dir>`             |
| 真合并(生成 merge commit, 只保留目录改动) | 1. `m` → `n`(Merge but don't commit) 选分支; 2. `!` 运行 `git checkout HEAD -- . ':(exclude)<dir>'`; 3. `c c` 提交 |

注意:

- 方案一只覆盖目录里对端存在的文件, 双方都改过时**不会冲突**, 直接覆盖;
- 方案二在目录外恢复成 HEAD 版本, 目录内保留三方合并结果; 目录外若有冲突要先解决;
- 两种都会丢失工作区未提交的改动, 先提交或 `z z` stash;
- `:(exclude)` 需要 git 1.9+, 也可以写成 `:!dir`.

### 远程: 带 tag 拉取到本地

| 功能                       | 操作                                                 |
| -------------------------- | ---------------------------------------------------- |
| fetch 所有 tag             | `f` → `-t`(打开 `--tags`) → `a`(所有远端) 或 `p`/`u` |
| fetch 指定远端             | `f` → `-t` → `e`(elsewhere)                          |
| pull(默认会带上可达的 tag) | `F` → `p`/`u`                                        |
| 强制显式 `--tags`          | `!` 执行 `git pull --tags`                           |

### 远程: 带 tag push 到远程

| 功能                            | 操作                                   |
| ------------------------------- | -------------------------------------- |
| push 所有 tag                   | `P` → `t`(`magit-push-tags`)           |
| push 时带 `--tags`              | `P` → `-T`(打开 `--tags`) → `p`        |
| push 当前分支并包含相关附注 tag | `P` → `-t`(打开 `--follow-tags`) → `p` |
| push 单个 tag                   | `P` → `T`(`magit-push-tag`)            |
| 其他远端                        | `P` → `e`(elsewhere)                   |

### stash

| 功能            | 操作  |
| --------------- | ----- |
| 保存当前改动    | `z z` |
| 取回并删除      | `z p` |
| 取回但保留      | `z a` |
| 查看 stash 列表 | `z l` |

### 冲突处理

| 功能        | 操作                                     |
| ----------- | ---------------------------------------- |
| merge 冲突  | 编辑冲突文件 → `s` 标记解决 → `c c` 完成 |
| rebase 冲突 | 编辑冲突文件 → `s` → `r` 菜单里 continue |

## 5. 提交信息模板

### 格式

- 中文
```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- 英文
```text
<类型>[可选 范围]: <描述>

[可选 正文]

[可选 脚注]
```

- 标题: <类型>[可选 范围]: <描述>
- 正文: [可选 正文]
- 脚注: [可选 脚注]



### 规则

1. 标题部分: 一行讲完, 祈使句直接说重点(不要超过80字符)
2. 正文部分: 
   - [推荐]当前有那些影响?
   - [推荐]说明为什么要修改?
   - [推荐]修改了那些? 
   - [可选]具体有什么用? 
   - [可选]注释说明修改后有那些影响? 
   - [可选]以及后续需要注意什么?

3. 脚注部分: 
   - [可选]Fixes: 3a2f1c0d4e5b ("net: add skb_segment() helper") 
     说明: 多分支使用项: 从id为3a2f1c0d4e5b的分支上发现bug. 这个是提交标题: ("net ...")
   - [可选]Reported-by: xxx <xxx's mail@example.com> 
     说明: 致谢, 是xxx发现的bug并报告的
   - [推荐]Signed-off-by: yourname <yourmail@example.com>
     说明: 你的签名


- 类型说明
| type     | 说明                                                      |
|----------|-----------------------------------------------------------|
| feat     | 新增功能(规范强制要求)                                    |
| fix      | 修复Bug(规范强制要求)                                     |
| perf     | 性能优化                                                  |
| style    | 代码格式调整(缩进,空格,分号等), 无逻辑修改                |
| refactor | 代码重构(既非新增功能, 也非修复Bug)                       |
| build    | 修改构建系统或外部依赖(例如C语言的cmake make xmake qmake) |
| docs     | 仅修改文档(包含README)                                    |
| chore    | 杂项维护, 不涉及业务代码或测试                            |
| test     | 添加或修改测试用例                                        |
| revert   | 回滚之前的某次提交(在部分社区约定中列出)                  |
| ci       | 修改持续集成(CI)配置或脚本                                |

### 示例

```text
net: fix use-after-free in skb_segment()

skb_segment() frees the original skb while a clone still references
it, leading to a use-after-free when the clone is released later.

Keep the original skb alive until all clones are freed.

Fixes: 3a2f1c0d4e5b ("net: add skb_segment() helper")
Reported-by: Alice <alice@example.com>
Signed-off-by: Bob <bob@example.com>
```

### 示例(中文)

```text
net: 修复 skb_segment() 中的释放后使用

skb_segment() 释放了原始 skb, 但仍有克隆引用它, 导致之后
释放克隆时出现释放后使用.

保持原始 skb 存活, 直到所有克隆都被释放.

Fixes: 3a2f1c0d4e5b ("net: add skb_segment() helper")
Reported-by: Alice <alice@example.com>
Signed-off-by: Bob <bob@example.com>
```



### 设置模板文件

```sh
cat > ~/.gitmessage <<'EOF'
# <子系统>: <50 列内, 祈使句, 不加句号>
#
# 为什么改:
# 影响:
#
# Fixes:
# Reported-by:
# Signed-off-by:
EOF
git config --global commit.template ~/.gitmessage
```

### 在 magit 里用

- `c c` 打开提交缓冲区, 模板会自动带入;
- `C-c C-c` 提交, `C-c C-k` 放弃;
- 提交菜单里 `-s` 开关可加 `Signed-off-by`;
- 标题超过 50 列会标黄(`git-commit-summary-max-length 50`);
- 正文按 72 列折行(`git-commit-fill-column 72`).

## 6. 注意事项

- **transient 是两段式**: 前缀键只是打开菜单, 真正执行的是第二层键; 不确定就 `C-g` 退出.
- **提交缓冲区**里 `C-c C-c` 提交, `C-c C-k` 取消; 标题超过 50 列会有颜色提示.
- **自动保存**: `dontask` 表示 git 操作前会把你改过的仓库内 buffer 自动保存, 不会问你.
- **status 不自动刷新**: 因为设了 `magit-refresh-status-buffer nil`, 提交/暂存后想看到最新状态要按 `g`.
- **凭据**: push/pull 走 ssh key 或 credential helper; 失败时看 `*magit-process*` 缓冲区里的 git 输出.
- **头像**只在图形界面显示, 终端里忽略即可.
- **大仓库**性能: 已经关了 status 自动刷新; 还慢可以再 `M-x magit-status` 时只拉当前目录, 或减少 diff 精化.
- **forge**: `.config-auto.el` 里虽选了 forge 包, 但 `use-magit.el` 没有配置它, `C-x g` 里不会出现 pull request/issue 功能.

## 7. 常见问题速查

| 现象               | 原因 / 解决                                                   |
| ------------------ | ------------------------------------------------------------- |
| 按键没反应         | 还没按完两层键, 或光标不在对应 section; `C-g` 重来            |
| 提交后 status 没变 | `magit-refresh-status-buffer nil`; 按 `g`                     |
| push 卡住/失败     | 凭据或网络; 看 `*magit-process*`                              |
| 标题标黄           | 超过 `git-commit-summary-max-length` 50 列                    |
| 提交信息中文乱码   | 一般不会, 仓库需 UTF-8; 检查 `git config i18n.commitEncoding` |
| 大仓库 status 慢   | 手动 `g`, 或关掉 diff 精化                                    |
| 误按 `x` / `k`     | 前者重置, 后者删除对象, 操作前先看底部提示                    |
| 想丢弃某处改动     | `M-x magit-discard`, 不要在 hunk 上乱按 `k`                   |

## 8. 一页速记

```text
C-x g 打开 status C-x M-g 命令面板
s 暂存 u 取消 c c 提交 c a 修补 S/U 全部暂存/取消
l l 历史 d d 差异 b b 切分支 b c 新建
f fetch F pull P push z z stash z p pop
g 刷新 q 退出 C-g 取消当前菜单
```
