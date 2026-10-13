;;; base-ui.el --- UI and display settings -*- lexical-binding: t; -*-
;;; Code:
;; Minimalist UI: disable menu bar, toolbar, scrollbar.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; No splash screen, bar cursor by default.
(setq inhibit-splash-screen t)
(setq-default cursor-type 'bar)

;; Show line numbers.
(global-display-line-numbers-mode t)

;; Disable GUI dialogs; route everything through the minibuffer.
(setq use-dialog-box nil)

;; Opening files on the command line: keep only the file buffers,
;; do not split with *scratch* (nil = file argument wins).
(setq initial-buffer-choice nil)

;; ---------- Quality of life (built-ins) ----------
(winner-mode 1)                   ; C-c <left>/<right> undo window layouts
(pixel-scroll-precision-mode 1)   ; smooth pixel-level scrolling (Emacs 29+)
