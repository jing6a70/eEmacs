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

;; 这两个变量定义在 core/debug.el (gdb-mi 的远程调试也用), 这里只声明以免编译告警
(defvar my/gdb-remote-host)
(defvar my/gdb-remote-port)
(defvar my/gdb-source-path-mapping)
(defvar my/gdb-solib-search-path)

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


;;; 远程 / 交叉调试: dape 原生 attach 到 gdbserver
;; GDB 15 的 DAP attach 支持 :target 参数, 内部执行 `target remote HOST:PORT';
;; 所以不需要 gdb-mi 也能调远程, 只要本地有带符号的二进制.
(defun my/dape--remote-config (program host port)
  "构造 attach 到 HOST:PORT 上 gdbserver 的 dape 配置.
PROGRAM 是本地带调试符号的二进制 (应与目标上运行的完全一致)."
  (let ((ex-args
         (append
          (list "-ex" "set pagination off")
          (when my/gdb-source-path-mapping
            (mapcan (lambda (m)
                      (list "-ex"
                            (format "set substitute-path %s %s" (car m) (cdr m))))
                    my/gdb-source-path-mapping))
          (when my/gdb-solib-search-path
            (list "-ex" (format "set solib-search-path %s"
                                my/gdb-solib-search-path))))))
    `(gdb-remote
      modes (c-mode c-ts-mode c++-mode c++-ts-mode)
      command "gdb-multiarch"
      command-args ("--interpreter=dap" ,@ex-args)
      :request "attach"
      :program ,program
      :target ,(format "%s:%s" host port))))

(defun my/dape-remote (&optional program host port)
  "用 dape + gdb-multiarch attach 到远程 gdbserver 调试.
PROGRAM 用本地那份与目标一致的二进制; HOST:PORT 是 gdbserver 地址."
  (interactive
   (list (read-file-name "Local program with symbols: " nil nil t)
         (read-string "Target host: " my/gdb-remote-host)
         (read-string "Port: " my/gdb-remote-port)))
  (unless (featurep 'dape)
    (user-error "dape 未安装: M-x package-install RET dape"))
  (unless (and program (file-executable-p program))
    (user-error "%s 不存在或不可执行" program))
  (let* ((entry (my/dape--remote-config program host port))
         (key (car entry))
         (config (cdr entry)))
    (setf (alist-get key dape-configs) config)
    (dape (dape--config-eval key (copy-tree config)))))

(when (featurep 'dape)

  ;; 右侧信息面板: 变量 / 栈 / 断点 / 线程, 比 gdb-mi 的 6 窗格清爽.
  ;; 想复刻 gdb-mi 的布局可改成 'gud, 或用 C-c g l 切换.
  (setq dape-buffer-window-arrangement 'right)

  ;; GDB 的 DAP 在收到 launch 请求时就会把程序跑起来, 之后 dape 再下发
  ;; setBreakpoints 会被 GDB 以 "notStopped" 拒绝, 表现就是"断点形同虚设,
  ;; 程序一路跑完". 让 dape 把 launch 推迟到 configurationDone 之后,
  ;; 断点才能真正生效 (dape 文档里的 defer-launch-attach, 对应 GDB bug 32090).
  (when-let* ((gdb-config (assq 'gdb dape-configs)))
    (setcdr gdb-config
            (plist-put (cdr gdb-config) 'defer-launch-attach t)))

  ;; 源码缓冲区里直接显示断点
  (dape-breakpoint-global-mode 1)

  (defvar my/dape-map
    (let ((map (make-sparse-keymap)))
      ;; 启动
      (define-key map (kbd "g") #'my/dape-start)
      ;; 远程: attach 到目标上的 gdbserver
      (define-key map (kbd "t") #'my/dape-remote)
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
      ;; 重跑: 会话结束后也能用 (复用上次配置, 见 dape-restart)
      (define-key map (kbd "r") #'dape-restart)
      (define-key map (kbd "f") #'dape-restart-frame)
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
