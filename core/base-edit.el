;;; base-edit.el --- Editing behavior settings -*- lexical-binding: t; -*-
;;; Code:
;; No automatic backup files.
(setq make-backup-files nil)

;; Automatic bracket pairing + show matching parens everywhere
;; (used to be elisp-only via a mode hook).
(electric-pair-mode t)
(show-paren-mode t)

;; Indentation: 4 spaces, no real tabs.
(setq-default indent-tabs-mode nil) ;; Space-only indentation by default
(setq c-basic-offset 4)             ;; C/C++ indent width of 4
(setq c-default-style "linux")     ;; Use the 'linux' style
(setq-default tab-width 4)         ;; Tab width of 4

;; Allow longer docstrings in byte-compiled files.
(setq byte-compile-docstring-max-column 120)

;; ---------- Quality of life (built-ins) ----------
(recentf-mode 1)                   ; recent files list
(save-place-mode 1)                ; reopen files at the last cursor position
