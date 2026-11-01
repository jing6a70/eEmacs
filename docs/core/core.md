# core 目录说明

`core/` 下各文件的逐项说明已合并到 [../config.md](../config.md) 的 `core/*.el` 章节。
保留本文件仅用于兼容旧链接，请以 `config.md` 为准，避免两份文档各自演化后再次不一致。

| 文件 | 作用 |
|---|---|
| `elpa.el` | 包源（GNU + MELPA）与 `package` 初始化 |
| `view.el` | 界面与显示 |
| `edit.el` | 编辑行为与 C/C++ 代码风格 |
| `theme.el` | 主题加载与回退 |
| `suppress.el` | 字节编译告警收敛 |

加载顺序与数据驱动方式见 [../config.md](../config.md) 的「启动流程」。
