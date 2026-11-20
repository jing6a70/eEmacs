;;; use-lspmode.el --- generic LSP setup (works for any language) -*- lexical-binding: t; -*-
(require 'cl-lib)



;; ~/.emacs.d/modules/use-lsp.el
;;
;; Core parts shared by all language files (e-clang-mode.el,
;; e-golang-mode.el, ...): lsp-mode, lsp-ui, lsp-treemacs, consult-lsp.
;; Each language file sets its own major mode hooks and server args.
;; This file never names a language.

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook
  (lsp-mode . lsp-enable-which-key-integration)
  :init
  ;; Speed tuning (safe to set here)
  (setq lsp-keep-workspace-alive nil
        lsp-enable-indentation t
        lsp-enable-on-type-formatting t
        lsp-auto-guess-root t
        lsp-enable-snippet t  ; yasnippet is on; allow LSP snippets
        lsp-modeline-diagnostics-enable t
        lsp-idle-delay 0.5  ; wait 0.5s before running checks
        lsp-completion-provider :capf
        lsp-diagnostics-provider :flymake)  ; flycheck not installed; make the fallback explicit

  ;; Global speed tuning
  (setq read-process-output-max (* 1024 1024)))

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode)
  :init
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-use-childframe t     ; Emacs 29+
        lsp-ui-doc-use-webkit nil
        lsp-ui-doc-delay 0.3
        lsp-ui-doc-include-signature t
        lsp-ui-doc-position 'bottom
        lsp-eldoc-enable-hover nil
        lsp-ui-imenu-window-width 30
        lsp-ui-imenu-window-fix-width t
        lsp-ui-imenu-auto-refresh t
        lsp-ui-imenu-colors '("#61afef" "#98c379")  ; soft blue + green

        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-hover t
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-ignore-duplicate t
        lsp-headerline-breadcrumb-enable t))


;; vertico lsp
(use-package consult-lsp
  :ensure t
  :after lsp-mode)

(use-package lsp-treemacs
  :ensure t
  :after lsp-mode  ; loads on demand; treemacs must be there first
  :commands (lsp-treemacs-errors-list
             lsp-treemacs-symbols
             lsp-treemacs-call-hierarchy
             my/lsp-auto-open-symbols)
  :hook (lsp-mode . lsp-treemacs-sync-mode)  ; refresh symbols when buffer changes
  ;; Same key style as magit/treemacs: :bind (set once at startup,
  ;; the command stays lazy-loaded)
  ;;   M-9   -> error list / C-c s -> symbols / C-c i -> imenu
  :bind
  (("M-9"   . lsp-treemacs-errors-list)
   ("C-c s" . lsp-treemacs-symbols)
   ("C-c i" . lsp-ui-imenu))
  :init
  ;; Open the symbols panel on its own.
  ;; Note: when the idle timer runs, the current buffer is not always the
  ;; buffer that started lsp (the user may have moved to a dashboard or
  ;; magit). Calling lsp-treemacs-symbols in that buffer makes an empty panel.
  ;; So we keep the buffer by hand, and retry up to 3 times while clangd
  ;; is still cold (index not ready, no symbols yet).
  (defun my/lsp-auto-open-symbols ()
    "Open the lsp-treemacs symbols panel on a sane buffer, with retry."
    (let ((buf (current-buffer)))
      (my/lsp--symbols-retry buf 3)))

  (defun my/lsp--symbols-retry (buf n)
    "Wait for the lsp server in BUF and open the symbols panel.
Retry up to N times while clangd is cold and reports no symbols."
    (when (> n 0)
      (run-with-idle-timer
       3 nil
       (lambda ()
         (when (buffer-live-p buf)
           (with-current-buffer buf
             (let ((syms (and (bound-and-true-p lsp-mode)
                              (condition-case nil
                                  (lsp-request "textDocument/documentSymbol"
                                               (list :textDocument
                                                     (lsp--text-document-identifier)))
                                (error nil)))))
               (if syms
                   (lsp-treemacs-symbols)
                 (my/lsp--symbols-retry buf (1- n))))))))))
  (add-hook 'lsp-after-initialize-hook #'my/lsp-auto-open-symbols)
  ;; lsp-ui-imenu: double click to jump; refresh when the buffer changes
  ;; (a one-off define-key stays here, since the target map belongs to
  ;;  lsp-ui-imenu and can only be read after it loads)
  (with-eval-after-load 'lsp-ui-imenu
    (define-key lsp-ui-imenu-mode-map (kbd "<double-mouse-1>") #'lsp-ui-imenu--visit)))


;; Shared PATH helper for the language files: prepend a user bin dir
;; (e.g. ~/.local/npm-global/bin or ~/go/bin) to `exec-path' and $PATH,
;; so lsp-mode finds servers installed without root/sudo.
(defun my/add-exec-path (dir)
  "Prepend user bin DIR to `exec-path' and the $PATH environment."
  (setq dir (expand-file-name dir))
  (when (and (file-directory-p dir)
             (not (member dir exec-path)))
    (setq exec-path (cons dir exec-path))
    (setenv "PATH" (concat dir path-separator (getenv "PATH")))))

;; Shared helper for the language files (e-clang-mode.el, e-bash-mode.el,
;; ...): start LSP only when the server binary exists. A missing server
;; shows a *Warnings* entry instead of aborting. (The old pattern —
;; (user-error ...) inside use-package's :config — ran when lsp-mode
;; first loaded, i.e. for EVERY language at once, so one missing server
;; broke LSP startup for unrelated buffers.)
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
