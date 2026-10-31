;;; debug.el --- GDB 调试支持 (GUD / gdb-mi) -*- lexical-binding: t; -*-
;; /core/debug.el
;;
;; 只使用 Emacs 内置的 GUD + gdb-mi, 不依赖第三方包.
;; 前置条件: 系统已安装 gdb, 程序用 -g 编译 (参考 ~/Desktop/c-debug-demo/Makefile).
;;
;; 快速开始: 在源码缓冲区按 C-c d g => 输入 "gdb -i=mi ./demo"
;; 进入会话后: C-c d b 下断点, C-c d r 运行, C-c d n 单步,
;;             C-c d p 打印表达式, C-c d w 监视变量, C-c d m 切换多窗口布局.
;;
;;; Code:

(require 'gdb-mi)

;;; 界面
;; 多窗口布局: 源码 | 局部变量 | 调用栈 | 线程 | 断点 | IO
(setq gdb-many-windows t)
;; 启动后直接停在 main, 并显示源码
(setq gdb-show-main t)
;; 调试结束/退出后恢复进入调试前的窗口布局
(setq gdb-restore-window-configuration-after-quit t)
;; 变量离开作用域后从 *Locals* 中移除, 保持列表干净
(setq gdb-delete-out-of-scope t)

;; GDB 14+ 默认在每次会话开始时询问是否启用 debuginfod 下载源码/调试信息,
;; 这里默认关闭, 避免每次启动都要回答 y/n (需要时可在 *gud* 里执行
;; "set debuginfod enabled on")
(setq gdb-debuginfod-enable-setting nil)

;; 鼠标悬停显示变量/表达式值 (终端下无效果, 不影响使用)
(gud-tooltip-mode 1)

;;; 会话命令包装
;; gdb-mi 在 `gdb' 函数内部才用 gud-def 定义 gud-break / gud-next 等命令,
;; 会话启动前直接按键会报 "void-function". 这里统一给一句可读的提示.
(defun my/gud-call (command)
  "在 GDB 会话中执行调试命令 COMMAND."
  (unless (fboundp command)
    (user-error "还没有 GDB 会话: 先按 C-c d g (M-x gdb) 启动调试"))
  (call-interactively command))

;;; 快捷键: C-c d 前缀
(defvar my/debug-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "g") #'gdb)
    (define-key map (kbd "m") #'gdb-many-windows)
    (define-key map (kbd "R") #'gdb-restore-windows)
    ;; 在别的文件里翻代码后, 一键把源码窗口拉回当前执行点
    (define-key map (kbd "j") #'gud-refresh)
    map)
  "调试前缀键 C-c d 对应的 keymap.")

;; 会话内命令: 键位 => (命令 . 说明)
(dolist (spec '(("b" gud-break    "当前行打断点")
                ("B" gud-remove   "删除当前行断点")
                ("t" gud-tbreak   "当前行打临时断点")
                ("c" gud-cont     "继续运行")
                ("r" gud-run      "从头运行")
                ("n" gud-next     "单步跳过 (源码级)")
                ("s" gud-step     "单步进入 (源码级)")
                ("o" gud-nexti    "单步跳过 (指令级)")
                ("i" gud-stepi    "单步进入 (指令级)")
                ("f" gud-finish   "运行到当前函数返回")
                ("u" gud-until    "运行到当前行")
                ("p" gud-print    "打印光标处的表达式")
                ("w" gud-watch    "监视光标处的表达式")))
  (define-key my/debug-map
              (kbd (car spec))
              `(lambda () (interactive) (my/gud-call ',(nth 1 spec)))))

(global-set-key (kbd "C-c d") my/debug-map)

(provide 'debug)
;;; debug.el ends here
