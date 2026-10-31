;;; debug.el --- GDB 调试支持 (GUD / gdb-mi) -*- lexical-binding: t; -*-
;; /core/debug.el
;;
;; 只使用 Emacs 内置的 GUD + gdb-mi, 不依赖第三方包.
;; 前置条件: 系统已安装 gdb, 程序用 -g 编译 (参考 ~/Desktop/c-debug-demo/Makefile).
;;
;; 快速开始: C-c d g => 输入 "gdb -i=mi ./demo"
;; 默认布局: 左源码 | 右列 局部变量 + 调用栈 (C-c d l 随时重新整理)
;; 其余缓冲区 (gud / 断点 / 线程 / 程序输出) 用 C-c d G/L/S/K/T/I 按需弹出.
;;
;;; Code:

(require 'gdb-mi)

;;; 会话默认值
;; gdb-mi 的 *内部* 多窗口开关要保持 t, 源码窗口跟随、缓冲区创建都依赖它;
;; 实际窗口布局由下面的 my/gdb-layout 精简.
(setq gdb-many-windows t)
;; 启动后直接停在 main, 并显示源码
(setq gdb-show-main t)
;; 调试结束/退出后恢复进入调试前的窗口布局
(setq gdb-restore-window-configuration-after-quit t)
;; 变量离开作用域后从 *locals* 中移除, 保持列表干净
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

;;; 精简布局
;; 默认 6 窗格 (gud/source/locals/io/stack/breakpoints) 在终端里太挤,
;; 这里只保留: 源码 | 局部变量 | 调用栈.
(defun my/gdb-layout ()
  "把当前 GDB 会话整理成 \"左源码 + 右列(局部变量/调用栈)\" 的三窗格布局."
  (interactive)
  (unless (bound-and-true-p gud-comint-buffer)
    (user-error "还没有 GDB 会话: 先按 C-c d g (M-x gdb) 启动调试"))
  (gdb-get-buffer-create 'gdb-locals-buffer)
  (gdb-get-buffer-create 'gdb-stack-buffer)
  (let* ((source-buffer (or (gdb-get-source-buffer) gud-comint-buffer))
         (source-window (or (get-buffer-window source-buffer) (selected-window))))
    (select-window source-window)
    (set-window-dedicated-p source-window nil)
    (delete-other-windows)
    (switch-to-buffer source-buffer)
    ;; 右侧留一列: 宽度取屏宽的 30%, 限制在 24~48 列之间
    (let* ((side-width (max 24 (min 48 (floor (* 0.30 (window-total-width))))))
           (side (split-window-right (- side-width)))
           (stack-height (/ (window-height) 2)))
      (select-window side)
      (gdb-set-window-buffer (gdb-locals-buffer-name))
      ;; 右列下半部分放调用栈
      (gdb-set-window-buffer (gdb-stack-buffer-name) nil
                             (split-window-below stack-height))
      (select-window source-window)
      ;; 让 gdb-mi 知道源码显示在哪, 后续单步/断点会自动切到该窗口
      (setq gdb-source-window-list (list source-window)))))

(defvar my/gdb--keep-default-layout nil
  "非 nil 时保留 gdb-mi 默认 6 窗格布局 (C-c d m 切回默认布局时使用).")

(defun my/gdb-trim-after-setup (&rest _)
  "gdb-mi 摆好默认窗口后, 换成精简的三窗格布局.
不能 advice `gdb' 的原因: 窗口是会话启动过程中异步搭建的,
`gdb' 命令返回时 gdb-setup-windows 还没跑."
  (unless (or my/gdb--keep-default-layout
              gdb-default-window-configuration-file)
    (ignore-errors (my/gdb-layout))))

(advice-add 'gdb-setup-windows :after #'my/gdb-trim-after-setup)

;; C-c d m 想切回 gdb-mi 默认的 6 窗格时, 别被上面的 advice 又裁掉
(advice-add 'gdb-many-windows :around
            (lambda (orig &rest args)
              (let ((my/gdb--keep-default-layout t))
                (apply orig args))))

(defun my/gdb-show-gud ()
  "显示 *gud* 命令缓冲区, 用来直接敲 GDB 命令 (如 break file.c:42)."
  (interactive)
  (if (bound-and-true-p gud-comint-buffer)
      (pop-to-buffer gud-comint-buffer)
    (user-error "还没有 GDB 会话: 先按 C-c d g 启动调试")))

;;; 快捷键: C-c d 前缀
(defvar my/debug-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "g") #'gdb)
    (define-key map (kbd "l") #'my/gdb-layout)
    (define-key map (kbd "m") #'gdb-many-windows)
    (define-key map (kbd "R") #'gdb-restore-windows)
    ;; 在别的文件里翻代码后, 一键把源码窗口拉回当前执行点
    (define-key map (kbd "j") #'gud-refresh)
    ;; 按需弹出被精简掉的缓冲区
    (define-key map (kbd "G") #'my/gdb-show-gud)
    (define-key map (kbd "L") #'gdb-display-locals-buffer)
    (define-key map (kbd "S") #'gdb-display-stack-buffer)
    (define-key map (kbd "K") #'gdb-display-breakpoints-buffer)
    (define-key map (kbd "T") #'gdb-display-threads-buffer)
    (define-key map (kbd "I") #'gdb-display-io-buffer)
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
