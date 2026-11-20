;;; use-common-emacs.el --- Minimalist base configuration -*- lexical-binding: t; -*-
;;; Code:
;; Minimalist UI: disable menu bar, toolbar, scrollbar.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; No splash screen, bar cursor by default.
(setq inhibit-splash-screen t)
(setq-default cursor-type 'bar)


;; No automatic backup files.
(setq make-backup-files nil)

;; Show line numbers.
(global-display-line-numbers-mode t)

;; Automatic bracket pairing + show matching parens everywhere
;; (used to be elisp-only via a mode hook).
(electric-pair-mode t)
(show-paren-mode t)


;; Indentation: 4 spaces, no real tabs.
(setq-default indent-tabs-mode nil) ;; Space-only indentation by default
(setq c-basic-offset 4)             ;; C/C++ indent width of 4
(setq c-default-style "linux")      ;; Use the 'linux' style
(setq-default tab-width 4)          ;; Tab width of 4

;; Allow longer docstrings; avoids lsp-mode byte-compile warnings.
(setq byte-compile-docstring-max-column 120)

;; Disable GUI dialogs; route everything through the minibuffer.
(setq use-dialog-box nil)

;; Opening files on the command line: keep only the file buffers,
;; do not split with *scratch* (nil = file argument wins).
(setq initial-buffer-choice nil)

;; ---------- Quality of life (built-ins) ----------
(recentf-mode 1)                  ; recent files feed C-x b (consult-buffer)
(save-place-mode 1)               ; reopen files at the last cursor position
(winner-mode 1)                   ; C-c <left>/<right> undo window layouts
(pixel-scroll-precision-mode 1)   ; smooth pixel-level scrolling (Emacs 29+)
