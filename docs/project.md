# project.el 与 treemacs 使用手册

> 配置在 `modules/use-treemacs.el`(treemacs 20251226, MELPA), 工程识别用 Emacs 内置
> `project.el`. treemacs 依赖 `dash` `s` `ace-window` `pfuture` `hydra` `ht` `cfrs`.
> 工程列表与 dashboard 的 Projects 区块共用 `project-list-file`.
> 日常只需记住两个入口: `C-c t` 开关侧栏, `C-x p` 管工程.

## 1. 使用方式

| 入口     | 命令                                    | 说明                                                |
| -------- | --------------------------------------- | --------------------------------------------------- |
| `C-c t`  | `my/treemacs-toggle`                    | 开关左侧文件树; 空 workspace 时自动加入当前工程根   |
| `C-c T`  | `treemacs-add-and-display-current-project` | 把当前工程挂进树里并打开侧栏                     |
| `C-x p p`| `project-switch-project`                | 从历史工程里选一个, 再选要执行的操作                |
| `C-x p f`| `project-find-file`                     | 在当前工程内找文件                                  |
| 欢迎页    | dashboard 的 Projects 区块, 按 `p`      | 启动页里直接进入工程列表                            |

工程根由 `project.el` 判定: 从当前文件的目录逐级向上找 `.git` / `.hg` / `.svn` 等
版本控制标记, 找到即仓库根. 所以从 `cproject/src/main.c` 里按 `C-c t`,
得到的是 `cproject`, 不是 `src`.

首次打开且 workspace 为空时, `C-c t` 走 `my/treemacs-toggle` 直接加入当前工程,
**不会**再弹 `Project root:`; 只有直接 `M-x treemacs` 时才会走到那个提示.

## 2. project.el 键位(`C-x p` 前缀)

| 键           | 命令                              | 说明                         |
| ------------ | --------------------------------- | ---------------------------- |
| `C-x p f`    | `project-find-file`               | 工程内找文件                 |
| `C-x p b`    | `project-switch-to-buffer`        | 切到工程内 buffer            |
| `C-x p d`    | `project-find-dir`                | 工程内找目录                 |
| `C-x p D`    | `project-dired`                   | 在工程根打开 dired           |
| `C-x p g`    | `project-find-regexp`             | 全工程正则搜索               |
| `C-x p G`    | `project-or-external-find-regexp` | 连外部根一起搜               |
| `C-x p r`    | `project-query-replace-regexp`    | 全工程正则替换               |
| `C-x p c`    | `project-compile`                 | 在工程根执行编译             |
| `C-x p s`    | `project-shell`                   | 工程根开 shell               |
| `C-x p e`    | `project-eshell`                  | 工程根开 eshell              |
| `C-x p !`    | `project-shell-command`           | 工程根执行一条命令           |
| `C-x p &`    | `project-async-shell-command`     | 同上, 异步                   |
| `C-x p v`    | `project-vc-dir`                  | 工程根的 vc-dir              |
| `C-x p k`    | `project-kill-buffers`            | 关闭工程内所有 buffer        |
| `C-x p x`    | `project-execute-extended-command`| 在工程根执行 `M-x` 命令      |
| `C-x p C-b`  | `project-list-buffers`            | 工程内 buffer 列表           |
| `C-x p p`    | `project-switch-project`          | 切换/选择工程                |

`C-x p p` 选完工程后会弹一个 dispatch: `f` 找文件, `r` 正则搜索, `d` 找目录,
`v` vc-dir, `e` eshell, `o` 任意命令.

## 3. 工程识别与历史

### 识别规则

| 规则              | 说明                                                             |
| ----------------- | ---------------------------------------------------------------- |
| 版本控制根        | 向上找 `.git` / `.hg` / `.svn` / `.bzr` 等, 找到即根              |
| 额外标记          | `project-vc-extra-root-markers` 里的文件名也可作为根(默认 nil)    |
| 不在工程内        | `(project-current)` 返回 `nil`                                    |

没有 git 的目录默认不算工程. 想让 `CMakeLists.txt` 也能当根, 二选一:

```elisp
;; 全局: 所有含 CMakeLists.txt 的目录都视为工程根(注意子目录会抢根)
(with-eval-after-load 'project
  (setq project-vc-extra-root-markers '("CMakeLists.txt")))
```

```elisp
;; 只对某个工程生效: 工程根放 .dir-locals.el
((nil . ((project-vc-extra-root-markers . ("CMakeLists.txt")))))
```

### 验证与调试

```elisp
M-: (project-root (project-current)) RET
;; => "~/Desktop/cproject/"
```

不在工程里时 `project-current` 为 nil, 直接套 `project-root` 会报错;
脚本里建议用 `(when-let* ((pr (project-current))) (project-root pr))`.

### 工程历史

| 操作                     | 命令 / 变量                                               |
| ------------------------ | --------------------------------------------------------- |
| 历史文件                 | `project-list-file` → `~/.emacs.d/projects.eld`           |
| 记住当前工程             | `M-x project-remember-project`                            |
| 批量扫描某目录           | `M-x project-remember-projects-under RET ~/Desktop RET`(`C-u` 递归) |
| 从历史删除               | `M-x project-forget-project` / `project-forget-projects-under` |
| 读取历史列表             | `(project-known-project-roots)`                           |

每次通过 `C-x p p` 选中工程, 或使用工程内命令时, 都会把该工程移到列表最前(最近使用优先).

## 4. treemacs 键位

### 文件与节点

| 键          | 作用                                                  |
| ----------- | ----------------------------------------------------- |
| `TAB`       | 展开 / 折叠节点                                       |
| `RET` / `l` | 打开文件或目录                                        |
| `o`         | 打开方式子菜单: `o v` 垂直分屏, `o h` 水平, `o o` 不分屏, `o c` 打开后关侧栏 |
| `n` / `p`   | 下一行 / 上一行                                       |
| `M-n` / `M-p` | 下一个 / 上一个同级节点                             |
| `u`         | 跳到父节点                                            |
| `g` / `r`   | 刷新                                                  |
| `q`         | 关闭侧栏窗口(`treemacs-quit`)                          |
| `Q`         | 关闭 treemacs buffer                                  |
| `w` / `<` / `>` | 设置 / 减小 / 增大宽度                            |
| `=`         | 侧栏宽度适配窗口                                      |
| `?`         | 键位帮助(hydra)                                       |
| `y`         | 复制路径子菜单: `y a` 绝对, `y r` 相对, `y n` 文件名, `y f` 复制文件 |
| `d` / `R`   | 删除 / 重命名文件(危险操作)                            |
| `cf` / `cd` | 新建文件 / 新建目录                                   |
| `m`         | 移动文件                                              |
| `M-!`       | 在工程根执行 shell 命令                                |
| `C-j` / `C-k` | 下一个 / 上一个工程                                 |
| `M-up` / `M-down` | 上移 / 下移工程                                 |

### 工程与 workspace(`C-c C-p` / `C-c C-w`)

| 键              | 作用                                |
| --------------- | ----------------------------------- |
| `C-c C-p a`     | 添加工程                            |
| `C-c C-p d`     | 移除光标处工程(光标放在工程根节点上) |
| `C-c C-p r`     | 重命名工程                          |
| `C-c C-p c c`   | 折叠当前工程                        |
| `C-c C-p c o`   | 折叠其他工程                        |
| `C-c C-p c a`   | 折叠所有工程                        |
| `C-c C-w a`     | 新建 workspace                      |
| `C-c C-w d`     | 删除 workspace                      |
| `C-c C-w r`     | 重命名 workspace                    |
| `C-c C-w s`     | 切换 workspace                      |
| `C-c C-w n`     | 下一个 workspace                    |
| `C-c C-w e`     | 编辑 workspace(修改根目录)          |

### 显示开关(`t` 前缀)

| 键    | 作用                                        |
| ----- | ------------------------------------------- |
| `t f` | `treemacs-follow-mode`: 跟随当前文件        |
| `t a` | `treemacs-filewatch-mode`: 文件变动刷新     |
| `t g` | `treemacs-git-mode`: git 状态着色开关       |
| `t i` | 隐藏 .gitignore 忽略的文件                  |
| `t h` | 显示 / 隐藏点文件                           |
| `t w` | 固定宽度开关                                |
| `t v` | fringe 指示器                               |
| `t d` | 显示提交级别的 diff                         |

本配置默认已开 `t f` `t a`, 并以 `deferred` 模式开 `t g`(需要 `python3`).

## 5. 常见流程

### 打开并浏览工程

1. 在工程内任意文件按 `C-c t` → 侧栏以工程根打开
2. `TAB` 展开, `RET` 打开, `q` 关闭侧栏
3. 想回到工程根: 侧栏里按 `u` 逐级上跳, 或 `M-H` / `M-L` 切换根

### 找文件, 搜索, 编译(不依赖 treemacs)

```
C-x p f     工程内找文件
C-x p g     全工程正则搜索
C-x p c     工程根编译
C-x p s     工程根 shell
```

### 添加 / 移除工程

- 加: 在工程文件里 `C-c T`, 或侧栏里 `C-c C-p a` 选目录
- 删: 光标放在工程根节点上按 `C-c C-p d`; 最后一个工程不能删

### 多个 workspace

```
C-c C-w a   新建 workspace(比如 "工作" / "个人")
C-c C-w s   切换
C-c C-w n   下一个
```

## 6. 配置项

| 配置                          | 值 / 位置                                          | 说明                             |
| ----------------------------- | -------------------------------------------------- | -------------------------------- |
| `C-c t`                       | `my/treemacs-toggle`                               | 空 workspace 时自动加工程根      |
| `C-c T`                       | `treemacs-add-and-display-current-project`         | 加当前工程                       |
| `treemacs-width`              | 32                                                 | 侧栏宽度                         |
| `treemacs-follow-mode`        | t                                                  | 光标移动时定位文件               |
| `treemacs-filewatch-mode`     | t                                                  | 文件系统变动自动刷新             |
| `treemacs-git-mode`           | `'deferred`                                        | git 状态着色, 需 python3         |
| `treemacs-persist-file`       | `~/.emacs.d/.cache/treemacs-persist`               | 工程/workspace 持久化(`.cache/` 已忽略) |
| `my/treemacs--read-first-project-path` | advice                                    | `Project root:` 默认值改为工程根 |

## 7. 常见问题速查

| 现象                              | 原因 / 处理                                                       |
| --------------------------------- | ----------------------------------------------------------------- |
| 打开后根节点是 `cproject/src`     | 首次空 workspace 时按了回车, 当前目录被当成工程. 用 `C-c T` 加正确根, 再把光标放到 `src` 根节点按 `C-c C-p d` 删掉; 现在 `C-c t` 已改为自动用工程根 |
| 每次都要删 `treemacs-persist`     | 不需要. 只有 workspace 一直为空才会反复询问; 正常用一次就有记录了  |
| 提示 `Project root:`              | 只有直接 `M-x treemacs` 且 workspace 为空时出现; 默认值已是工程根, 回车即可 |
| 工程没被识别                      | 目录没有 `.git`, 也没配 marker. `M-: (project-root (project-current))` 确认 |
| 刚 `git init` 但还不识别          | 有缓存: 交互式 2 秒, 后台最多 5 分钟; 稍等或重开 buffer           |
| 侧栏不跟随当前文件                | `t f` 打开 follow-mode; 文件变动不刷新按 `t a`                    |
| git 状态颜色不显示                | 需要 `python3`(deferred/extended); `t g` 检查, 或 `M-x treemacs-git-mode` 重选 |
| 侧栏消失                          | 再按 `C-c t`; buffer 还在的话会直接显示                           |
| 工程被移动/删除                   | 侧栏根节点上 `d` 移除, 再到新位置 `C-c T`; 历史里的僵尸可用 `M-x project-forget-zombie-projects` 清理 |
| 没有文件类型图标                  | 默认只有简易图标; 装 `treemacs-nerd-icons` + 系统 Nerd Font, 再 `(treemacs-load-theme "nerd-icons")` |
| `C-x p` 提示选择目录              | 当前 buffer 不在工程里; 先 `C-x p p` 选工程, 或在工程文件里操作    |

## 8. 一页速记

```text
C-c t          开关侧栏(空 workspace 时自动加当前工程)
C-c T          把当前工程挂进树里
C-x p f        工程内找文件
C-x p g        全工程正则搜索
C-x p c        工程根编译
C-x p p        切换/选择工程
C-x p k        关闭工程内 buffer

treemacs 里:
TAB / RET      展开 / 打开
o v / o h      垂直 / 水平分屏打开
n / p          上下移动
u              跳到父节点
g              刷新
t f / t a      跟随当前文件 / 文件监视
t g            git 状态着色
C-c C-p a / d  添加 / 移除工程
q              关闭侧栏
```

相关文档: [config.md](config.md) 总览, [magit.md](magit.md) 版本控制, [debug.md](debug.md) 调试.
