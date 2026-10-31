;;; debug-dape.el --- dape 调试前端 (GDB via DAP) -*- lexical-binding: t; -*-
;; /core/debug-dape.el
;;
;; dape 是 DAP (Debug Adapter Protocol) 客户端, 对 C/C++ 直接调用
;; `gdb --interpreter=dap' (需要 gdb >= 14.1, 本机 15.1 可用).
;; 和 core/debug.el 的 gdb-mi 并存, 互不干扰:
;;   C-c d ...  gdb-mi (MI 协议, 功能最全)
;;   C-c g ...  dape  (DAP 协议, 界面更接近 IDE)
;;
;; 安装: M-x package-install RET dape  (GNU ELPA, 依赖 jsonrpc)
;;
;;; Code:

(require 'dape nil t)

;;; 从工程里猜可执行文件
(defun my/dape--guess-program ()
  "在当前目录的 Makefile 里找 TARGET, 返回可执行文件的绝对路径."
  (let ((makefile (expand-file-name "Makefile" default-directory)))
    (when (file-exists-p makefile)
      (with-temp-buffer
        (insert-file-contents makefile)
        (goto-char (point-min))
        (when (re-search-forward
               "^TARGET[ \t]*[:+?]?=[ \t]*\\([^ \t\n#]+\\)" nil t)
          (expand-file-name (match-string 1) default-directory))))))

;; 没有 Makefile 时按常见惯例猜一个
(defun my/dape--read-program ()
  "读取并返回要调试的可执行文件路径."
  (let ((default (or (my/dape--guess-program)
                     (expand-file-name "a.out" default-directory))))
    (read-file-name "Program: " (file-name-directory default)
                    nil t (file-name-nondirectory default))))

(defun my/dape-start (&optional program)
  "启动 dape 调试当前工程的可执行文件 PROGRAM.
默认取 Makefile 的 TARGET (例如 ./demo), 没有则用当前目录的 a.out.
minibuffer 里会预填 `gdb :program ...', 回车确认即可开始."
  (interactive (list (my/dape--read-program)))
  (unless (featurep 'dape)
    (user-error "dape 未安装: M-x package-install RET dape"))
  (unless (and (file-exists-p program) (file-executable-p program))
    (user-error "%s 不存在或不可执行: 先 M-x compile" program))
  ;; `dape-command' 是 dape 官方的 "预填 minibuffer" 变量
  (let ((dape-command (cons 'gdb (list :program program
                                       :cwd (file-name-directory program)))))
    (call-interactively #'dape)))

(defun my/dape-layout-toggle ()
  "在右侧面板 ('right) 和 gdb-mi 风格 ('gud) 之间切换 dape 布局.
布局在下次启动会话时生效."
  (interactive)
  (unless (featurep 'dape)
    (user-error "dape 未安装: M-x package-install RET dape"))
  (setq dape-buffer-window-arrangement
        (if (eq dape-buffer-window-arrangement 'right) 'gud 'right))
  (message "dape 布局: %s (下次启动生效)" dape-buffer-window-arrangement))

(when (featurep 'dape)

  ;; 右侧信息面板: 变量 / 栈 / 断点 / 线程, 比 gdb-mi 的 6 窗格清爽.
  ;; 想复刻 gdb-mi 的布局可改成 'gud, 或用 C-c g l 切换.
  (setq dape-buffer-window-arrangement 'right)

  ;; 源码缓冲区里直接显示断点
  (dape-breakpoint-global-mode 1)

  (defvar my/dape-map
    (let ((map (make-sparse-keymap)))
      ;; 启动
      (define-key map (kbd "g") #'my/dape-start)
      ;; 断点
      (define-key map (kbd "b") #'dape-breakpoint-toggle)
      (define-key map (kbd "B") #'dape-breakpoint-remove-at-point)
      ;; 执行控制
      (define-key map (kbd "c") #'dape-continue)
      (define-key map (kbd "n") #'dape-next)
      (define-key map (kbd "s") #'dape-step-in)
      (define-key map (kbd "o") #'dape-step-out)
      (define-key map (kbd "u") #'dape-until)
      (define-key map (kbd "p") #'dape-pause)
      ;; 查看
      (define-key map (kbd "e") #'dape-evaluate-expression)
      (define-key map (kbd "w") #'dape-watch-dwim)
      (define-key map (kbd "i") #'dape-info)
      (define-key map (kbd "R") #'dape-repl)
      (define-key map (kbd "d") #'dape-disassemble)
      ;; 布局与会话
      (define-key map (kbd "l") #'my/dape-layout-toggle)
      (define-key map (kbd "m") #'dape-many-windows)
      (define-key map (kbd "q") #'dape-quit)
      (define-key map (kbd "k") #'dape-kill)
      (define-key map (kbd "?") #'dape-menu)
      map)
    "dape 调试前缀键 C-c g 对应的 keymap.")

  (global-set-key (kbd "C-c g") my/dape-map))

(provide 'debug-dape)
;;; debug-dape.el ends here
