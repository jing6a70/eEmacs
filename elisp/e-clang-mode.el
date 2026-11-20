;;; e-clang-mode.el --- C/C++ language support via LSP (clangd) -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'use-lspmode)

;; Language module: everything a language needs in one file.
;; Enable LSP for its major modes with :hook; put server/args tuning in
;; :config. The generic lsp-mode infra (ui, treemacs, which-key, keys)
;; lives in use-lspmode.el, so a new language file stays tiny.

;; Key bindings are project-wide (use-lspmode.el):
;;   M-9 -> error list, C-c s -> symbols, C-c i -> imenu, <f6> -> cmake db

;; ---- Extension pattern ----
;; To add another language, create e.g. e-golang-mode.el / e-pylang-mode.el /
;; javalang-mode.el following this same shape, put them here in elisp/
;; and require them in init.el, and install the server binary
;; (gopls / pylsp / jdtls). Example skeleton:
;;
;;   ;;; e-golang-mode.el --- Go via LSP -*- lexical-binding: t; -*-
;;   (require 'cl-lib)
;;   (require 'use-lspmode)
;;
;;   (use-package lsp-mode
;;     :hook (go-mode
;;            . (lambda ()
;;                (my/lsp-deferred-with-server
;;                 "gopls" "go install golang.org/x/tools/gopls@latest")))
;;     :config
;;     ;; go-specific tuning here
;;     )
;;
;;   (provide 'e-golang-mode)
;;   ;;; e-golang-mode.el ends here

(use-package lsp-mode
  ;; Deferred: start clangd only when a c/c++ buffer gets visited.
  ;; The server check is per buffer and only warns on failure: an
  ;; error raised in :config would run when lsp-mode loads — for every
  ;; language at once — and break unrelated buffers (helper lives in
  ;; use-lspmode.el).
  :hook ((c-mode c++-mode)
         . (lambda ()
             (my/lsp-deferred-with-server
              "clangd" "install clangd (Arch: pacman -S clang; Ubuntu: apt install clangd)"))))

;; clangd tuning — set eagerly so lsp-mode picks it up on first load.
;; No --compile-commands-dir: clangd walks parent dirs (and their
;; build/ subdirs) by itself, which also covers projects that name the
;; build dir differently (build-debug/, out/, ...). <f6> writes
;; build/compile_commands.json via cmake.
(setq lsp-clients-clangd-executable "clangd"
      lsp-clients-clangd-args '("-j=4"
                                "--background-index"
                                "--pch-storage=memory"
                                "--header-insertion=never"))

(provide 'e-clang-mode)
;;; e-clang-mode.el ends here
