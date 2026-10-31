;;; debug-dape.el --- dape 调试前端 (GDB via DAP) -*- lexical-binding: t; -*-
;; /core/debug-dape.el
;;
;; 只使用 dape (GNU ELPA): 走 Debug Adapter Protocol, 对 C/C++ 调用
;; `gdb --interpreter=dap' (需要 gdb >= 14.1). 远程调试用 `gdb-multiarch'
;; attach 到 gdbserver, 见 my/dape-remote.
;;
;; 安装: M-x package-install RET dape  (依赖 jsonrpc)
;;
;; 常用入口:
;;   C-c g g  本地调试 (自动从 Makefile 的 TARGET 猜程序)
;;   C-c g t  远程 attach 到 gdbserver (ARM 交叉调试)
;;
;;; Code:

(require 'dape nil t)

;;; 可选: 远程 / 交叉调试参数
(defcustom my/dape-remote-host "172.16.1.101"
  "gdbserver 所在主机的默认地址."
  :type 'string
  :group 'dape)

(defcustom my/dape-remote-port "1234"
  "gdbserver 的默认端口."
  :type 'string
  :group 'dape)

(defcustom my/dape-source-path-mapping
  '(("/home/jingpeng/Desktop/virtDisk" . "/home/jingpeng/Desktop/sgc"))
  "调试信息里的源码路径 -> 本机真实源码路径 的映射.
交叉编译在别的机器/目录里做时, DWARF 里记的是构建机的路径;
这里会翻译成 `set substitute-path', 通过 gdb 的 -ex 传进去.
设为 nil 则不映射."
  :type '(alist :key-type string :value-type string)
  :group 'dape)

(defcustom my/dape-solib-search-path nil
  "非 nil 时作为 `set solib-search-path' 传给 gdb.
例如交叉编译用的 Qt 库目录 /opt/qt-5.9.5-arm/lib."
  :type '(choice (const :tag "不设置" nil) string)
  :group 'dape)

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

(defun my/dape--read-program ()
  "读取并返回要调试的可执行文件路径."
  (let ((default (or (my/dape--guess-program)
                     (expand-file-name "a.out" default-directory))))
    (read-file-name "Program: " (file-name-directory default)
                    nil t (file-name-nondirectory default))))

;;; 本地调试
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

;;; 远程 / 交叉调试
;; GDB 15 的 DAP attach 支持 :target 参数, 内部执行 `target remote HOST:PORT',
;; 所以 dape 原生就能连 gdbserver, 不需要 gdb-mi.
(defun my/dape--remote-config (program host port)
  "构造 attach 到 HOST:PORT 上 gdbserver 的 dape 配置.
PROGRAM 是本地带调试符号的二进制 (应与目标上运行的完全一致)."
  (let ((ex-args
         (append
          (list "-ex" "set pagination off")
          (when my/dape-source-path-mapping
            (mapcan (lambda (m)
                      (list "-ex"
                            (format "set substitute-path %s %s" (car m) (cdr m))))
                    my/dape-source-path-mapping))
          (when my/dape-solib-search-path
            (list "-ex" (format "set solib-search-path %s"
                                my/dape-solib-search-path))))))
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
         (read-string "Target host: " my/dape-remote-host)
         (read-string "Port: " my/dape-remote-port)))
  (unless (featurep 'dape)
    (user-error "dape 未安装: M-x package-install RET dape"))
  (unless (and program (file-executable-p program))
    (user-error "%s 不存在或不可执行" program))
  (let* ((entry (my/dape--remote-config program host port))
         (key (car entry))
         (config (cdr entry)))
    (setf (alist-get key dape-configs) config)
    (dape (dape--config-eval key (copy-tree config)))))

;;; 会话默认值与快捷键
(when (featurep 'dape)

  ;; 右侧信息面板: 变量 / 栈 / 断点 / 线程.
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
