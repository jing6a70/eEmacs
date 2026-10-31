;;; use-dape.el --- dape 调试前端 (GDB via DAP) -*- lexical-binding: t; -*-
;; /modules/use-dape.el
;;
;; 第三方包 dape (GNU ELPA): DAP 客户端, 对 C/C++ 调 `gdb --interpreter=dap'
;; (需要 gdb >= 14.1). 远程调试用 `gdb-multiarch' attach 到 gdbserver.
;;
;;   C-c g g   本地调试 (自动从 Makefile 的 TARGET 猜程序)
;;   C-c g t   远程 attach 到 gdbserver (ARM 交叉调试)
;;
;;; Code:

(require 'dape nil t)

;;; 远程 / 交叉调试参数
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

;;; 工具函数
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

(defun my/dape-start (&optional program)
  "启动 dape 调试当前工程的可执行文件 PROGRAM.
默认取 Makefile 的 TARGET (例如 ./demo), 没有则用当前目录的 a.out."
  (interactive (list (my/dape--read-program)))
  (unless (and program (file-executable-p program))
    (user-error "%s 不存在或不可执行: 先 M-x compile" program))
  ;; `dape-command' 是 dape 官方的 "预填 minibuffer" 变量
  (let ((dape-command (cons 'gdb (list :program program
                                       :cwd (file-name-directory program)))))
    (call-interactively #'dape)))

(defun my/dape-layout-toggle ()
  "在右侧面板 ('right) 和 gdb-mi 风格 ('gud) 之间切换 dape 布局.
布局在下次启动会话时生效."
  (interactive)
  (setq dape-buffer-window-arrangement
        (if (eq dape-buffer-window-arrangement 'right) 'gud 'right))
  (message "dape 布局: %s (下次启动生效)" dape-buffer-window-arrangement))

;; GDB 15 的 DAP attach 支持 :target 参数, 内部执行 `target remote HOST:PORT',
;; 所以 dape 原生就能连 gdbserver, 不需要额外的调试前端.
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
  (unless (and program (file-executable-p program))
    (user-error "%s 不存在或不可执行" program))
  (let* ((entry (my/dape--remote-config program host port))
         (key (car entry))
         (config (cdr entry)))
    (setf (alist-get key dape-configs) config)
    (dape (dape--config-eval key (copy-tree config)))))

;;; C-c g 前缀键
(defvar my/dape-map
  (make-sparse-keymap)
  "dape 调试前缀键 C-c g 对应的 keymap.")

(use-package dape
  :ensure t
  :bind (:map my/dape-map
              ;; 启动
              ("g" . my/dape-start)
              ("t" . my/dape-remote)
              ;; 断点
              ("b" . dape-breakpoint-toggle)
              ("B" . dape-breakpoint-remove-at-point)
              ;; 执行控制
              ("c" . dape-continue)
              ("n" . dape-next)
              ("s" . dape-step-in)
              ("o" . dape-step-out)
              ("u" . dape-until)
              ("p" . dape-pause)
              ;; 重跑
              ("r" . dape-restart)
              ("f" . dape-restart-frame)
              ;; 查看
              ("e" . dape-evaluate-expression)
              ("w" . dape-watch-dwim)
              ("i" . dape-info)
              ("R" . dape-repl)
              ("d" . dape-disassemble)
              ;; 布局与会话
              ("l" . my/dape-layout-toggle)
              ("m" . dape-many-windows)
              ("q" . dape-quit)
              ("k" . dape-kill)
              ("?" . dape-menu))
  :config
  ;; 右侧信息面板: 变量 / 栈 / 断点 / 线程
  ;; 想复刻 gdb-mi 布局可改成 'gud, 或用 C-c g l 切换
  (setq dape-buffer-window-arrangement 'right)
  ;; GDB 的 DAP 收到 launch 就启动程序, 之后下发 setBreakpoints 会被以
  ;; "notStopped" 拒绝, 断点等于失效 (GDB bug 32090). 让 launch 推迟到
  ;; configurationDone 之后, 断点才会在启动时生效.
  (when-let* ((gdb-config (assq 'gdb dape-configs)))
    (setcdr gdb-config
            (plist-put (cdr gdb-config) 'defer-launch-attach t)))
  ;; 源码缓冲区里直接显示断点
  (dape-breakpoint-global-mode 1))

;; 前缀键绑定到 keymap 对象本身 (use-package 的 :bind-keymap 只绑符号,
;; lookup-key 拿到的是符号而不是 keymap, 这里显式绑对象)
(global-set-key (kbd "C-c g") my/dape-map)

(provide 'use-dape)
;;; use-dape.el ends here
