# Projectile 使用指南

> 主力项目管理（Do this config 的标准方案）。与 Emacs 内置 project.el 分工：projectile 用 `C-c p` 前缀作为主力；project.el 的 `C-x p` 前缀保留不变（生态标准，随时可用）。两者可共存。

## 快速开始

所有功能都在 `C-c p` 前缀下，按下后 `C-h` / `which-key` 会弹出完整菜单。

### 每日高频

| 键 | 功能 |
|---|---|
| `C-c p f` | 项目内找文件（frecency 排序） |
| `C-c p p` | 切换项目 |
| `C-c p t` | **`.h ↔ .c/.cpp` 互跳**（toggle-between-impl-and-test） |
| `C-c p k` | 关闭本项目的所有 buffer |
| `C-c p d` | 项目内任意目录 Dired |
| `C-c p D` | 项目根 Dired |
| `C-c p a` | 找"另一个文件"（`main.go → main_test.go` 之类，dwim 匹配） |

### 搜索

前缀 `C-c p s`：

| 键 | 功能 |
|---|---|
| `C-c p s s` | 项目内搜索（默认选 grep，可切换 ripgrep） |
| `C-c p s r` | ripgrep 搜索（推荐装 ripgrep） |
| `C-c p s g` | 强制走 grep |
| `C-c p s t` | 项目内搜索 TODO |
| `C-c p s x` | 项目内查找引用（`?` 是同义的别名，光标下 word） |

### 替换

| 键 | 功能 |
|---|---|
| `C-c p r` | 项目内交互式替换 |
| `C-c p R` | 项目内替换（preview/review 模式） |
| `C-c p u` | 替换反悔 |

### 编译 / 测试 / 任务

前缀 `C-c p c`（底层在项目根执行）：

| 键 | 功能 |
|---|---|
| `C-c p c i` | install（如 npm install 等，依项目类型） |
| `C-c p c c` | 编译项目 |
| `C-c p c t` | 测试项目 |
| `C-c p c r` | 运行项目 |
| `C-c p c o` | 配置项目（cmake 等） |
| `C-c p x r` | 运行（run） |
| `C-c p x t` | 运行 term |
| `C-c p c x` | 运行 Make/npm/justfile 任务（列菜单） |

For C/C++ with CMake：`C-c p c i` 会依据 projectile 项目类型设置 CMakeLists.txt。

### 缓冲与项目管理

| 键 | 功能 |
|---|---|
| `C-c p b` | 在项目内切换 buffer |
| `C-c p e` | 最近使用的文件（recentf） |
| `C-c p j` | **按后缀匹配找文件**（文件类型筛选，如只看 `.h`） |
| `C-c p C` | 项目内**已修改文件**列表（配合 git 状态） |
| `C-c p v` | git-statusatz（Magit VC） |
| `C-c p W` | 切换 git worktree |
| `C-c p w s` | 保存项目 session（窗口布局+buffer） |
| `C-c p w r` | 恢复项目 session |

### 其他

| 键 | 功能 |
|---|---|
| `C-c p z` | 缓存当前文件 |
| `C-c p i` | 让缓存失效 |
| `C-c p E` | 编辑项目 `.dir-locals.el` |
| `C-c p A` | 手动添加一个已知项目 |

---

## 项目根识别

向上扫描标记文件（任何一步命中即停）：

```
.git / .hg / .svn          (VC 标记)
.projectile                (projectile 标记)
pom.xml / build.gradle
package.json / requirements.txt / Cargo.toml / go.mod
mix.exs / pubspec.yaml ...
```

`~/` 和 `~/.emacs.d/` 已在忽略列表 (`projectile-ignored-projects`)。想添加其他排除目录：

```elisp
(add-to-list 'projectile-ignored-projects "勾选路径")
```

其他常用命令（全局，不带前缀）：

| 命令 | 功能 |
|---|---|
| `M-x projectile-discover-projects-in-search-path` | 从系统 search-path 中一次性发现项目 |
| `M-x projectile-remove-known-project` | 从已知列表删除项目 |
| `M-x projectile-invalidate-cache` | 缓存无效化（一致性问题后用） |

## 配置摘要（modules/use-treemacs.el）

```elisp
(use-package projectile
  :bind ("C-c p" . projectile-command-map)   ; Doom 风格前缀
  :custom
  (projectile-completion-system 'vertico)    ; 用 vertico
  (projectile-indexing-method 'hybrid)       ; 高性能 + 兼容性
  (projectile-enable-caching t)
  (projectile-ignored-projects '("~/"
                                 "~/.emacs.d/")))
```

缓存文件默认在 `~/.emacs.d` 下（gitignore 已排除），如需搬位置可自行设 `projectile-cache-file` 和 `projectile-known-projects-file`。

## 与 Treemacs / Magit / Forge 的联动

- Treemacs 打开后跟随当前 projectile 项目（follow mode），项目切换时更新
- Magit/Forge 通过 projectile 找项目根；配合 `C-x g` 工作顺畅

## 备忘

- 项目目录不再用到时 `M-x projectile-remove-known-project` 移除
- `projectile-known-projects-file` 的数据匯全会保存到 `~/.emacs.d/projectile-bookmarks.eld`（gitignore）
- 不需要 C-x p 去用 project.el —— 但两套都能用，coexist 干净

## 与 project.el 的对比速查

| 维度 | projectile（本配置主力） | project.el（内置备用） |
|---|---|---|
| 前缀 | `C-c p` | `C-x p` |
| 最低版本 | 28.1+（旧版 2.x 可用 26） | 26+ 内置 |
| 找文件 | frecency + 缓存 | 实时 find |
| impl/test 互跳 | ✅ `.h ↔ .c(.cpp)` | ❌ |
| 项目任务 | ✅ Makefile/npm/justfile | ❌ |
| git worktree | ✅ `C-c p W` | ✅ |
| dir-locals 集成 | ✅ | ✅ 更全（`project-vc-ignores`） |
