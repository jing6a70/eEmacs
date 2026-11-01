# dape 调试手册

> 配置在 `modules/use-dape.el`, dape 来自 GNU ELPA(Emacs 29.3 自带 `jsonrpc`).

## 1. 使用方式

### 本地启动(launch)

```text
C-c d d        ; = M-x dape
```

minibuffer 输入:

```text
gdb : program "./build/demo"
```

回车, 程序由 gdb 启动. 相对路径按 dape 的 cwd 解析(项目根或当前 buffer 目录).

### 远程 ARM(attach 到 gdbserver)

设备上:

```sh
cd /opt/QtMc && gdbserver :1234 ./GreenPulse-V6.7.1
```

本地:

```text
C-c d a     → 选本地 GreenPulse-V6.7.1 → host 回车 → port 回车 → 确认
```

成功后 `*dape-repl*` 显示 `* Attached .../GreenPulse-V6.7.1 *`, 程序停在 attach 点.

要点:

- 本地必须装 `gdb-multiarch`(普通 `gdb` 只支持 x86_64);
- **本地二进制必须和设备上运行的那份一致**(比对 md5), 否则行号/栈会整体偏移;
- 一个 gdbserver 只能连一个客户端.

## 2. 键位(`C-c d` 前缀)

| 键              | 作用                | 键              | 作用             |
| --------------- | ------------------- | --------------- | ---------------- |
| `C-c d d`       | 本地启动            | `C-c d a`       | 远程 attach      |
| `C-c d c`       | 继续                | `C-c d n`       | 单步跳过(next) |
| `C-c d s`       | 单步步入(step)    | `C-c d f`       | 步出(finish)   |
| `C-c d u`       | 运行到当前行之后    | `C-c d r`       | 重跑会话         |
| `C-c d P`       | 暂停/中断运行       | `C-c d b`       | 断点开关         |
| `C-c d e`       | 条件断点(当前行)  | `C-c d l`       | log 断点         |
| `C-c d p`       | 求值表达式          | `C-c d w`       | watch 变量       |
| `C-c d i`       | 信息面板            | `C-c d x`       | 查看内存         |
| `C-c d R`       | dape REPL           | `C-c d q` / `k` | 退出 / 杀掉      |
| `C-c d <` / `>` | 切换栈帧(up/down) |                 |                  |

- dape 自带的 `C-x C-a` 前缀一直可用;
- 执行过 dape 命令后会出现 `Repeat with d, p, c, n ...` 提示, 那是 `repeat-mode`,
  直接用单键即可, 注意它用的是 dape 原生 keymap(`p`=暂停, `x`=求值), 和
  `C-c d` 表略有差异.

## 3. 断点

| 操作             | 方式                                                  |
| ---------------- | ----------------------------------------------------- |
| 普通断点         | 源码行 `C-c d b`                                      |
| 条件断点         | 源码行 `C-c d e`, 输入 `ch == 1`; 空输入 = 删除       |
| 命中次数条件     | `M-x dape-breakpoint-hits`, 输入次数                  |
| log 断点(不停) | `C-c d l`                                             |
| 查看/禁用/删除   | `C-c d i` → Breakpoints 面板(`y/n` 状态, Hits 计数) |

**关键规则: 必须先停住才能下/改断点.**

程序运行中下断点, GDB 的 DAP 会拒绝:

```text
* Failed to set breakpoints in xxx.cpp; notStopped *
```

左边行首的 `B` 只是 dape 的标记, 实际没进 GDB. 正确顺序:

```text
C-c d P  →  C-c d b  →  C-c d c
```

## 4. 运行控制

- `C-c d c` 继续; `C-c d n/s/f/u` 单步; `C-c d P` 暂停;
- 远程 attach 模式下 **`run` 无效**, 想从头跑只能设备上重起 gdbserver;
- 断点命中后, `C-c d <` / `>` 在调用栈里上下切换, Scope/求值都跟随选中帧.

## 5. 查看数据

| 想看              | 方式                                                               |
| ----------------- | ------------------------------------------------------------------ |
| 变量/栈/断点/线程 | `C-c d i`, 右侧面板, `TAB` 切换, `RET` 跳转                        |
| 求值表达式        | `C-c d p`, 例如 `cm[0].ccok`, `globalGunStateMan()->getChargeAB()` |
| 监视表达式        | `C-c d w`, Watch 面板每次停下刷新                                  |
| 原始内存          | `C-c d x`, 输入 `&cm[0]` 之类; `C-x ]`/`C-x [` 翻页                |

`C-c d x` 的 hex 缓冲区**可写**: `C-x C-s` 会把改动写回目标内存, 危险, 只读时别按.

## 6. 手动调用 C++ 成员函数

1. 先停住(`C-c d P`);

2. 取对象地址:

   ```text
   p this        →  (对象名称 * const) 0xaae12210
   ```

3. 调用:

   ```text
   p ((对象名称 *)0xaae12210)->onSelectedGunId(1)
   ```

注意事项:

- 函数里**不能有会命中的断点**, 否则 gdb 会中止调用:
  `The program being debugged stopped while in a function called from GDB ... will be abandoned`;
  需要干净调用就先 `disable` 相关断点;
- 真正在设备上执行, 会有副作用(改状态, 切界面, 动串口/定时器), 可能死锁;
- 构造函数不能直接调用;
- 地址是 ASLR 后的, 进程重启就变.

## 7. 结束调试

| 操作                       | 效果                                     |
| -------------------------- | ---------------------------------------- |
| `C-c d k`                  | 杀远端进程 + 断开                        |
| `C-c d q`                  | 收尾并清 dape 缓冲区(同样走 terminate) |
| `M-x dape-disconnect-quit` | 只断开, 程序继续在设备上跑               |

`C-c d k` 依赖配置里的 `-ex "set confirm off"`: 否则 gdb 的 `kill` 会问
`Kill the program being debugged? (y or n)`, DAP 无法回答 → 请求超时 →
dape 只断开, 进程没杀. 旧会话里可以临时在 REPL 敲 `set confirm off` 再按.

日志 `Server exited with status 9` 是 jsonrpc 报告 gdb adapter 被 SIGKILL
(dape 关闭会话时强杀), 正常现象.

## 8. 常见问题速查

| 现象                                                               | 原因 / 解决                                           |
| ------------------------------------------------------------------ | ----------------------------------------------------- |
| `Failed to set breakpoints ...; notStopped`                        | 运行中下断点; 先 `C-c d P`                            |
| 断点形同虚设, 程序直接跑完                                         | launch 模式 GDB bug 32090; 靠 `defer-launch-attach t` |
| `Cannot execute this command while the selected thread is running` | 程序在跑; 要停下就 pause                              |
| `No source file named ...`                                         | 路径映射缺失, 或二进制与源码不匹配                    |
| `Undefined command: ""`                                            | REPL 里按了空回车, 忽略即可                           |
| `Evaluation ... will be abandoned`                                 | gdb 调函数期间命中断点; 先 disable 断点               |
| `Attached` 后设备界面冻住                                          | attach 停住了程序, `C-c d c` 才继续                   |
| 连不上 / Address already in use                                    | gdbserver 没起, 已被别人连, 或旧实例占端口            |
| `Server exited with status 9`                                      | adapter 被强杀, 正常                                  |
| 断点行号偏移                                                       | 本地二进制和设备上的不是同一次构建(对比 md5)        |

## 9. 一页速记

```text
启动: C-c d d  (本地)           C-c d a  (远程 ARM)
断点: C-c d b  条件: C-c d e    暂停: C-c d P
运行: c 继续  n 下一步  s 步入  f 步出  u until  r 重启
查看: i 面板  p 求值  w watch  x 内存  R REPL  < > 栈帧
结束: k 杀+断  q 清理          只断: M-x dape-disconnect-quit
```
