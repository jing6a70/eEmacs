;;; e-bash-mode.el --- Shell development via LSP (bash-language-server) -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'use-lspmode)

;; Custom elisp language module for shell scripts (sh/bash/zsh buffers).
;; Uses the generic lsp-mode infra; install the server binary once:
;;   npm install -g --prefix ~/.local/npm-global bash-language-server
;; PATH is extended below so lsp-mode can find it (no root npm install
;; is needed).

;; Make the server binary visible to Emacs on any machine
;; (npm global prefix lives outside the default PATH).
(my/add-exec-path "~/.local/npm-global/bin")

(use-package lsp-mode
  ;; Shell / bash buffers enter bash-language-server deferred.
  ;; Per-buffer server check that warns instead of aborting (helper
  ;; lives in use-lspmode.el; an error in :config would fire for every
  ;; language when lsp-mode loads).
  :hook (sh-mode
         . (lambda ()
             (my/lsp-deferred-with-server
              "bash-language-server"
              "npm install -g --prefix ~/.local/npm-global bash-language-server"))))

(provide 'e-bash-mode)
;;; e-bash-mode.el ends here
