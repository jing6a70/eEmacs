;;; e-golang-mode.el --- Go development via LSP (gopls) -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'use-lspmode)

;; Custom elisp language module for Go. Same pattern as e-clang-mode:
;; lsp-mode infra is shared (use-lspmode.el), this file only adds the
;; go-specific major mode hook and the gopls executable path.
;;
;; Install once:
;;   go install golang.org/x/tools/gopls@latest
;; Binary lands in $HOME/go/bin, added to exec-path below.

;; Make gopls visible to Emacs (go tool installs to ~/go/bin).
(my/add-exec-path "~/go/bin")

(use-package go-mode
  :ensure t
  :defer t)

(use-package lsp-mode
  ;; Deferred: gopls starts only when a go buffer is visited.
  ;; Per-buffer server check that warns instead of aborting (helper
  ;; lives in use-lspmode.el; an error in :config would fire for every
  ;; language when lsp-mode loads).
  :hook (go-mode
         . (lambda ()
             (my/lsp-deferred-with-server
              "gopls" "go install golang.org/x/tools/gopls@latest"))))

(provide 'e-golang-mode)
;;; e-golang-mode.el ends here
