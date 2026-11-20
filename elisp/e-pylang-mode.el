;;; e-pylang-mode.el --- Python development via LSP (pyright) -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'use-lspmode)

;; Custom elisp language module for Python. Same pattern as e-clang-mode:
;; shared lsp-mode infra; this file adds the python-mode hook and the
;; pyright server path.
;;
;; pyright (by Microsoft) is used instead of pylsp because it installs
;; through npm the same way bash-language-server does, with no system
;; python packages required:
;;   npm install -g --prefix ~/.local/npm-global pyright
;; The npm package ships both `pyright' (CLI) and `pyright-langserver'.
;;
;; NOTE: pylsp (python plugin ecosystem) is the alternative if you close
;; to community defaults; on Archlinux install `python-pylsp' then set
;; lsp-pylsp-executable accordingly. Only one backend is needed.

;; Make the server binary visible to Emacs on any machine
;; (shared npm prefix with bash-language-server).
(my/add-exec-path "~/.local/npm-global/bin")

(use-package lsp-mode
  ;; Deferred: pyright starts only when a python buffer is visited.
  ;; Per-buffer server check that warns instead of aborting (helper
  ;; lives in use-lspmode.el; an error in :config would fire for every
  ;; language when lsp-mode loads).
  :hook (python-mode
         . (lambda ()
             (my/lsp-deferred-with-server
              "pyright-langserver"
              "npm install -g --prefix ~/.local/npm-global pyright"))))

;; lsp-mode's built-in pyright client picks up `pyright-langserver'
;; automatically once it is on `exec-path'.
(setq lsp-pyright-multi-root-matching t)

(provide 'e-pylang-mode)
;;; e-pylang-mode.el ends here
