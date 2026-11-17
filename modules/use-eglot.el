;;; use-eglot.el --- Eglot(LSP 客户端)通用配置 -*- lexical-binding: t; -*-
;; Eglot 用 GNU ELPA 的 1.26, 不用 Emacs 29.3 内置的 1.15:
;;   内置 1.15 读的是 jsonrpc 1.0.16 的私有接口, 而 dape 需要 ELPA 的
;;   jsonrpc >= 1.0.25 —— 新 jsonrpc 把 `jsonrpc--request-continuations'
;;   改了名, 还废弃了 `:events-buffer-scrollback-size'; 两者混用时启动会看到
;;   "deprecated" 和 "not known to be defined" 两条告警, 且 eglot 的 modeline
;;   会因 void-function 报错. eglot 1.26 和 jsonrpc 1.0.30 是同一代, 配套.
;; 新机器首次启动会自动装(需要网络); 装完重启一次生效.
;; 这里只放所有语言共用的部分: 全局选项、键位、以及语言文件共用的工具函数.
;; 具体语言(clangd / gopls / pyright ...)的 mode hook 与 server 参数放各自的语言文件.

;; 与 server 的管道吞吐; 默认 4KB 对流式 JSON-RPC 偏小
(setq read-process-output-max (* 1024 1024))

;; C-c L / C-c l 这些前缀按下去会列出后续按键, 不用背
(use-package which-key
  :ensure t
  :init (which-key-mode 1))

(unless (package-installed-p 'eglot '(1 26))
  (condition-case err
      (progn
        (package-refresh-contents)
        (let ((desc (cadr (assq 'eglot package-archive-contents))))
          (when desc (package-install desc)))
        (display-warning
         'eglot
         "已安装 GNU ELPA 的 eglot 1.26, 重启 Emacs 后生效(内置 1.15 与 jsonrpc 1.0.30 不兼容)"))
    (error (display-warning
            'eglot (format "GNU ELPA 的 eglot 1.26 安装失败: %S" err)))))

(use-package eglot
  :ensure nil                        ; 版本由上面的检查保证, 不走 :ensure
  :commands (eglot eglot-ensure)
  :init
  (setq eglot-autoshutdown t               ; 最后一个被接管的 buffer 关掉就收 server
        eglot-send-changes-idle-time 0.5   ; 停手 0.5 秒才把改动发给 server
        eglot-extend-to-xref t))           ; 顺着 xref 进工程外的文件也接管
;; server 主动改文件(Rename/applyEdit)的确认由 refactor-confirmation 控制,
;; eglot 1.26 里 eglot-confirm-server-* 都是指向它的 obsolete 别名, 别再单独 setq,
;; 否则加载时会多一条 defvaralias 告警.

;; 不 require eglot, 但下面的函数用得到它; 声明一下让字节编译安静
(declare-function eglot-managed-p "eglot")
(declare-function eglot-current-server "eglot")
(declare-function eglot--TextDocumentIdentifier "eglot")
(declare-function eglot-uri-to-path "eglot" (uri))
(declare-function jsonrpc-request "jsonrpc" (server method params &rest args))

;;; 头文件 <-> 源文件
;; Eglot 不带 clangd 的 switchSourceHeader, 直接用 jsonrpc 请求;
;; 不是 clangd 接管的 buffer 就退回按文件名配对的 ff-find-other-file.
(defun my/eglot-switch-header ()
  "Switch between the C/C++ header and its source file.
Uses clangd's switchSourceHeader when Eglot manages the buffer,
otherwise falls back to `ff-find-other-file' (purely filename based)."
  (interactive)
  (let ((path (when (eglot-managed-p)
                (ignore-errors
                  ;; clangd 的扩展方法参数就是 TextDocumentIdentifier 本身,
                  ;; 不像标准方法那样再包一层 :textDocument
                  (jsonrpc-request (eglot-current-server)
                                   :textDocument/switchSourceHeader
                                   (eglot--TextDocumentIdentifier))))))
    ;; clangd 正常回绝对路径, 万一回 file:// URI 也认
    (when (and (stringp path) (string-prefix-p "file://" path))
      (setq path (eglot-uri-to-path path)))
    (if (and (stringp path) (not (string-empty-p path)))
        (find-file path)
      (require 'find-file)
      (call-interactively #'ff-find-other-file))))

;;; 键位
;; 前缀沿用原 lsp-mode 时代的两套: `C-c L` 是"对代码做操作", `C-c l` 是"看东西".
;; 命令都带 autoload(eglot 及 Emacs 内置), 或由 consult 提供, 不按键就不增加启动时间.

;; F4: C/C++/ObjC 里的"源文件 <-> 头文件"切换(以前 C-c l . 的常用键).
;; 不用全局绑定, 免得在非 C 系 buffer 里按 F4 报错.
(defun my/cc-bind-f4 ()
  "Bind F4 to `my/eglot-switch-header' in the current C-like buffer."
  (keymap-local-set "<f4>" #'my/eglot-switch-header))
(add-hook 'c-mode-common-hook #'my/cc-bind-f4)

(defvar my/eglot-keymap
  (define-keymap
    "r" 'eglot-rename                      ; 改名(会提示新名字)
    "a" 'eglot-code-actions                ; code action: 修错/重构
    "o" 'eglot-code-action-organize-imports
    "f" 'eglot-format-buffer               ; 格式化整个 buffer
    "h" 'eldoc-doc-buffer                  ; 光标处符号的文档
    "e" 'eglot-events-buffer               ; 与 server 的通信日志(排错用)
    "s" 'eglot-shutdown                    ; 断开当前 server
    "R" 'eglot-reconnect                   ; 重连(改了 compile_commands.json 后用)
    "g" (define-keymap
          "g" 'xref-find-definitions
          "d" 'eglot-find-declaration
          "i" 'eglot-find-implementation
          "t" 'eglot-find-typeDefinition
          "r" 'xref-find-references))
  "`C-c L' 前缀: Eglot 操作类命令.")

(defvar my/eglot-view-keymap
  (define-keymap
    "s" 'consult-imenu                     ; 当前文件符号, 带预览
    "d" 'consult-flymake                   ; 诊断列表, 带预览
    "i" 'eglot-inlay-hints-mode            ; inlay hints 开关(参数名/类型提示)
    "r" 'xref-find-references
    "." 'my/eglot-switch-header)
  "`C-c l' 前缀: 查看类命令.")

(keymap-set global-map "C-c L" my/eglot-keymap)
(keymap-set global-map "C-c l" my/eglot-view-keymap)

;; 工程级错误列表(flymake 按文件分组, 相当于以前的 lsp-treemacs-errors-list)
(keymap-set global-map "M-9" 'flymake-show-project-diagnostics)

;; 工程内按名字搜符号(workspace/symbol)。常用, 单独放 C-c f, 不再挂在 C-c L g a 下
(keymap-set global-map "C-c f" 'xref-find-apropos)

;;; 语言文件共用的小工具

(defun my/add-exec-path (dir)
  "Prepend user bin DIR to `exec-path' and the $PATH environment."
  (setq dir (expand-file-name dir))
  (when (and (file-directory-p dir)
             (not (member dir exec-path)))
    (setq exec-path (cons dir exec-path))
    (setenv "PATH" (concat dir path-separator (getenv "PATH")))))

(defun my/eglot-ensure-with-server (server install-hint)
  "Start Eglot when SERVER is in PATH; otherwise warn with INSTALL-HINT.
Keeps one missing language server from breaking the others."
  (if (executable-find server)
      (eglot-ensure)
    (display-warning
     'eglot
     (format "%s not found in PATH; LSP disabled for this buffer.\n  %s"
             server install-hint))))

(provide 'use-eglot)
;;; use-eglot.el ends here
