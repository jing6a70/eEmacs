;;; use-lspmode.el --- LSP 通用配置 -*- lexical-binding: t; -*-
;; 只放所有语言共用的部分: lsp-mode, lsp-ui, lsp-treemacs, consult-lsp.
;; 具体语言(clangd / gopls / pyright ...)的 mode hook 与 server 参数放各自的语言文件.

;; lsp-enable-which-key-integration 依赖 which-key; Emacs 29 还没内置(30 才内置)
(use-package which-key
  :ensure t
  :init (which-key-mode 1))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . lsp-enable-which-key-integration)
  :init
  (setq lsp-keep-workspace-alive nil
        lsp-enable-indentation t
        lsp-enable-on-type-formatting nil  ; 边打边格式化容易顿, 需要时再开
        lsp-auto-guess-root t
        lsp-enable-snippet t               ; 服务端片段交给 yasnippet 展开
        lsp-modeline-diagnostics-enable t
        lsp-idle-delay 0.5
        lsp-completion-provider :capf      ; 给 corfu 用的 CAPF, 不要改成 :none
        lsp-diagnostics-provider :flymake  ; Emacs 29 内置 flymake
        lsp-keymap-prefix "C-c L"          ; 默认 s-l 在 Linux 桌面常被锁屏占用
        read-process-output-max (* 1024 1024)))

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode)
  :init
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-use-childframe t        ; 仅 GUI 有效
        lsp-ui-doc-use-webkit nil
        lsp-ui-doc-delay 0.3
        lsp-ui-doc-include-signature t
        lsp-ui-doc-position 'bottom
        lsp-eldoc-enable-hover nil
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-hover t
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-ignore-duplicate t
        lsp-headerline-breadcrumb-enable t))

;; 键位全部放在顶层: 这些命令都带 autoload, 按键时才真正加载对应包,
;; 不会因为 :after 把 :bind 一起推迟到 lsp-mode 启动之后.
(keymap-set global-map "M-9" #'lsp-treemacs-errors-list)
(keymap-set global-map "C-c l s" #'lsp-treemacs-symbols)   ; C-c s 是 iedit, 不能占
(keymap-set global-map "C-c l i" #'lsp-ui-imenu)
(keymap-set global-map "C-c l d" #'consult-lsp-diagnostics)
(keymap-set global-map "C-c l r" #'xref-find-references)
(keymap-set global-map "C-c l ." #'my/lsp-switch-header)

(defun my/lsp-switch-header ()
  "Switch between the C/C++ header and its source file.
Uses clangd's switchSourceHeader when LSP is active, otherwise
falls back to `ff-find-other-file' (purely filename based)."
  (interactive)
  (if (and (bound-and-true-p lsp-mode) (lsp-workspaces))
      (progn (require 'lsp-clangd)
             (lsp-clangd-find-other-file))
    (require 'find-file)
    (ff-find-other-file)))

(use-package consult-lsp
  :ensure t
  :after lsp-mode)

(use-package lsp-treemacs
  :ensure t
  :after lsp-mode
  :hook (lsp-mode . lsp-treemacs-sync-mode)   ; 缓冲区切换时刷新符号树
  :config
  (with-eval-after-load 'lsp-ui-imenu
    (define-key lsp-ui-imenu-mode-map (kbd "<double-mouse-1>") #'lsp-ui-imenu--visit)))

;; 打开 LSP 后自动弹出符号面板; 不想被弹窗打扰就设成 nil
(defvar my/lsp-auto-symbols-p t
  "Non-nil means open the lsp-treemacs symbols panel after LSP starts.")

(defun my/lsp-auto-open-symbols ()
  "Open the symbols panel for the buffer that just started LSP."
  (when my/lsp-auto-symbols-p
    (my/lsp--symbols-retry (current-buffer) 3)))

(defun my/lsp--symbols-retry (buf n)
  "Ask BUF's server for symbols, retrying up to N times while it is cold.
Uses an asynchronous request so a cold clangd never blocks the UI."
  (when (> n 0)
    (run-with-idle-timer
     3 nil
     (lambda ()
       (when (buffer-live-p buf)
         (with-current-buffer buf
           (when (bound-and-true-p lsp-mode)
             (lsp-request-async
              "textDocument/documentSymbol"
              (list :textDocument (lsp--text-document-identifier))
              (lambda (syms)
                (if syms
                    (with-current-buffer buf (lsp-treemacs-symbols))
                  (my/lsp--symbols-retry buf (1- n))))))))))))

(add-hook 'lsp-after-initialize-hook #'my/lsp-auto-open-symbols)

;; 语言文件共用: 把用户级 bin 目录(如 ~/go/bin)加进 exec-path 和 $PATH
(defun my/add-exec-path (dir)
  "Prepend user bin DIR to `exec-path' and the $PATH environment."
  (setq dir (expand-file-name dir))
  (when (and (file-directory-p dir)
             (not (member dir exec-path)))
    (setq exec-path (cons dir exec-path))
    (setenv "PATH" (concat dir path-separator (getenv "PATH")))))

;; 语言文件共用: 只有 server 存在时才启动 LSP, 免得一个语言装不上就报错
(defun my/lsp-deferred-with-server (server install-hint)
  "Call `lsp-deferred' when SERVER is in PATH; otherwise warn.
INSTALL-HINT is shown in the *Warnings* buffer message."
  (if (executable-find server)
      (lsp-deferred)
    (display-warning
     'lsp
     (format "%s not found in PATH; LSP disabled for this buffer.\n  %s"
             server install-hint))))

(provide 'use-lspmode)
;;; use-lspmode.el ends here
