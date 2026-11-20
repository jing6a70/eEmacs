# undo-tree 撤销树手册

> 配置在 `modules/use-undo-tree.el`；`undo-tree` 0.8.2 来自 MELPA，本机 Emacs 29.3
> 实测可用。

## 1. 为什么用树

内置的 undo 是**一条线**：撤销几步之后再输入新内容，被撤销的那些“未来”就永久丢了。
`undo-tree` 把历史存成**树**，撤销后继续编辑只是多长出一条分支，原来的分支仍然在，
`C-x u` 可以在分支之间来回切换，把丢掉的改动找回来。

## 2. 日常操作

| 键      | 命令                     | 作用                     |
| ------- | ------------------------ | ------------------------ |
| `C-/`   | `undo-tree-undo`         | 撤销（同 `C-_`）         |
| `M-_`   | `undo-tree-redo`         | 重做（同 `C-?`）         |
| `C-x u` | `undo-tree-visualize`    | 打开可视化界面           |

`undo-tree` 只接管按键，不改变“撤销是一条命令”的语义；`C-/` 连按就是沿着一路往回走。

## 3. 可视化界面（`C-x u`）

弹出独立的 buffer（名字是 `" *undo-tree*"`，前面带一个空格，不会挤到 buffer 列表顶部），
画出整棵历史树。节点用字符标记：`x` 当前所在节点、`s` 文件“已保存/未修改”对应的节点、
`o` 其余节点；当前节点另有 `undo-tree-visualizer-current-face` 高亮。
导航是**实时生效**的：在树里按方向键，父 buffer 的内容当场就变。

| 键              | 作用                              |
| --------------- | --------------------------------- |
| `p` / `↑`       | 撤销（往回走）                    |
| `n` / `↓`       | 重做（往前走）                    |
| `f` / `→`       | 切到右边的分支                    |
| `b` / `←`       | 切到左边的分支                    |
| `M-{` / `M-}`   | 跳到上一个/下一个“有意义”的节点   |
| `d`             | 开/关 diff 预览（会多一个窗口）   |
| `t`             | 显示/隐藏节点时间戳               |
| `s`             | 选择模式（从多个节点里挑状态）    |
| `,` `.` `<` `>` | 树太宽时横向滚动                  |
| `q`             | **退出，保留你停在的那个状态**    |
| `C-q`           | **退出，并恢复到打开可视化之前**  |

两个容易困惑的点：

- **`C-g` 不会退出**，它只是中断当前命令；退出用 `q`。
- 注意力回到父 buffer 后，只要一输入内容，`before-change-functions` 里挂的
  `undo-tree-kill-visualizer` 就会自动关掉可视化界面，不用手动收拾。

## 4. 配置要点（`modules/use-undo-tree.el`）

| 项                                          | 现状与说明                                                       |
| ------------------------------------------- | ---------------------------------------------------------------- |
| `global-undo-tree-mode`                     | 写在 `:init` 里，启动就全局接管撤销                             |
| `undo-tree-auto-save-history` → `nil`       | 该变量**默认是 `t`**：默认会在每个保存过的文件旁生成 `.文件名.~undo-tree~`。置 nil 后历史只活在当前会话 |
| `undo-tree-limit` 等                        | 见下节，会覆盖 `core/edit.el` 的 `undo-limit` 设置               |
| `undo-tree-mode-lighter`                    | 默认 ` Undo-Tree`，嫌长可 `(setq undo-tree-mode-lighter " UT")`  |

### 关于撤销容量

`undo-tree-mode` 开启时会对当前 buffer 做：

```elisp
(set (make-local-variable 'undo-limit) (max undo-limit undo-tree-limit))
```

所以 `core/edit.el` 里设的 `undo-limit 800000` 在开启后**基本不再起作用**，
实际生效的是：

| 变量                       | 默认值    |
| -------------------------- | --------- |
| `undo-tree-limit`          | 80000000  |
| `undo-tree-strong-limit`   | 120000000 |
| `undo-tree-outer-limit`    | 360000000 |

想自己控制，就在模块的 `:custom` 里设这三个值；设 `undo-tree-limit` 为 `nil`
等于“永不丢弃历史”，官方文档明确警告可能吃满内存。

### 想跨会话保留历史

```elisp
(setq undo-tree-auto-save-history t)
```

同时给 `.gitignore` 补 `.*.~undo-tree~`（或用 `undo-tree-history-directory-alist`
把历史文件集中到某个目录）。本配置默认**关着**，因为隐藏文件会弄脏工程目录。

## 5. 常见问题速查

| 现象                                   | 原因 / 解决                                                         |
| -------------------------------------- | ------------------------------------------------------------------- |
| 保存文件后旁边多出 `.xxx.~undo-tree~`  | `undo-tree-auto-save-history` 是 `t`（默认值）；本配置已设为 nil    |
| 重启 Emacs 后撤销历史没了              | 正常，默认不落盘；要保留就按上一节开启                              |
| `C-/` 能撤销的步数和预期不符           | 容量由 `undo-tree-limit` 等决定，`undo-limit` 被覆盖                |
| `C-x u` 说 `No undo information`       | 当前 buffer 没有 undo 记录（只读 buffer、`with-temp-buffer` 里 `buffer-undo-list` 为 `t`） |
| 可视化界面按 `C-g` 关不掉              | 用 `q`；`C-g` 只是中断当前命令                                      |
| 想丢掉刚才在树里乱走的结果             | 还没退出就按 `C-q`（`undo-tree-visualizer-abort`）                  |
| 升级 Emacs 后 undo 相关报错            | 0.8.2 是 2022 年的版本，先从这个模块排查，必要时从 `my/local-modules` 移除 |

## 6. 与其他配置的关系

- `core/edit.el` 的 `undo-limit` / `undo-strong-limit` / `undo-outer-limit` 被上表的
  `undo-tree-*` 覆盖，改容量请改后者；
- `hungry-delete`、`iedit` 的批量修改都是普通编辑，正常进撤销历史，`C-/` 可以整批回退；
- 只是局部（buffer 级）的 minor mode，不参与 `global-undo-tree-mode` 的 buffer
  （例如自身设置了 `buffer-undo-list` 为 `t` 的临时 buffer）不受影响。

## 7. 一页速记

```text
撤销: C-/   重做: M-_   树: C-x u
树里: p/n 上下走   f/b 切分支   M-{ M-} 跳节点   d diff   t 时间戳
退出: q 保留当前状态           C-q 回到打开前
配置: auto-save 关闭(默认 t 会生成 .xxx.~undo-tree~)
容量: undo-tree-limit 80M / strong 120M / outer 360M（覆盖 edit.el 的 undo-limit）
```
