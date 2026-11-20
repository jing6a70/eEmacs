# yasnippet 片段手册

> 配置在 `modules/use-yasnippet.el`：`yasnippet` + `yasnippet-snippets`(MELPA)。
> 行内候选由 `modules/use-corfu.el` 里的 `yasnippet-capf` 提供。

## 1. 加载方式

```elisp
(use-package yasnippet
  :ensure t
  :demand t                       ; 必须：否则 :bind 会把包推迟到首次按键
  :bind ("C-c y" . yas-insert-snippet)
  :config (yas-global-mode 1))
```

`:demand t` 不是可选优化。`use-package` 只要看到 `:bind` 就会把加载推迟到第一次按键，那样 `(yas-global-mode 1)` 永远不执行，片段功能等于没开（`C-c y` 能按出列表，但片段不会被加载）。

## 2. 片段放在哪

| 目录 | 用途 |
| --- | --- |
| `~/.emacs.d/snippets/` | 你自己的片段，**这是 `yas-snippet-dirs` 的默认值** |
| `elpa/yasnippet-snippets-*/snippets/` | `yasnippet-snippets` 提供的现成片段，随包更新 |

目录结构按 major-mode 分层：

```text
~/.emacs.d/snippets/
├── c++-mode/
│   └── for
└── text-mode/
    └── date
```

`c++-mode/for` 的内容：

```text
# -*- mode: snippet -*-
# name: for
# key: for
# --
for (int ${1:i} = 0; $1 < ${2:n}; $1++) {
    $0
}
```

`$1`…`$n` 是占位符，`$0` 是最终停留位置，`${1:默认值}` 带默认文本。

## 3. 键位

| 键 | 作用 | 生效范围 |
| --- | --- | --- |
| `C-c y` | `yas-insert-snippet`：用 vertico + orderless 按名字挑片段 | 全局 |
| `TAB` | 跳到下一个占位符 | 片段展开期间 |
| `S-TAB` | 回到上一个占位符 | 片段展开期间 |
| `DEL` | 清空当前字段 | 片段展开期间 |
| `C-d` | 跳过并清空当前字段 | 片段展开期间 |
| `C-g` | 放弃整个片段 | 片段展开期间 |

注意 `TAB` 只在**片段已展开**时归 yasnippet；平时 `TAB` 仍是缩进，没有和 corfu 抢。

想按触发词自动展开（例如输入 `for` 后按 TAB 展开），需要手工绑 `yas-expand`，并且只在 `yas-minor-mode` 的 keymap 里绑，别动全局 TAB。

## 4. 现成片段库

`yasnippet-snippets` 装上后自动挂进 `yas-snippet-dirs`，覆盖 C/C++、Python、JS、Ruby、sh 等几十种语言，常用的 `for`、`if`、`main`、`#include`、`class` 都有。

不想用它就删掉模块里那段 `use-package yasnippet-snippets`，只保留自己的 `snippets/`。

## 5. 与 corfu 的关系

```text
corfu 弹窗 ← 候选来自 completion-at-point-functions
                        ↑
                  yasnippet-capf（深度 50）
```

也就是说：打字时片段和 LSP 补全**混在同一个弹窗**里，候选旁会有 `snippet` 标记；`C-c y` 则是独立的“按名字选片段”入口，两条路都可用。

## 6. 常见问题

| 现象 | 原因 / 解决 |
| --- | --- |
| `C-c y` 列表是空的 | `yasnippet-snippets` 没加载，或 `snippets/` 里确实没有片段 |
| 改了 `snippets/` 里的文件没生效 | `M-x yas-reload-all` 重新加载 |
| 片段展开后 TAB 不跳字段 | 光标不在片段内（看看有没有 `yas--` 的 overlay） |
| 片段里缩进乱 | 在片段文件里加 `# expand-env: ((yas-indent-line 'fixed))`，或把 `yas-indent-line` 设为 `nil` |
| `yas-global-mode` 是 nil | 忘了 `:demand t`，或者启动时报错中断了加载 |

## 7. 一页速记

```text
选片段: C-c y（vertico/orderless 按名字筛）
字段: TAB 下一个   S-TAB 上一个   DEL 清空   C-d 跳过   C-g 放弃
目录: ~/.emacs.d/snippets/<mode>/<name>（默认值，不用额外配置）
现成片段: yasnippet-snippets
和 corfu: 片段候选由 yasnippet-capf 提供，混在同一个弹窗里
```
