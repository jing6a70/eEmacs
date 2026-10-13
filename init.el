;;; -*- lexical-binding: t; -*-
;; init.el
;; ┌─┐┌─┐┬─┐┌─┐┌─┐  ┌─┐┬ ┬┌─┐┬  ┌─┐┌─┐
;; ├─┘├┤ ├┬┘├┤ ├┤   ├─┤│ │├─┤│  ├┤ └─┐
;; ┴  └─┘┴└─└  └─┘  ┴ ┴└─┘┴ ┴┴─┘└─┘└─┘
;;       A P E X     E M A C S   (minimal base)
;;
;; Commentary: Initial load file for Emacs. Loads on every Emacs start.
;; Pure built-in setup: no third-party packages.

;; Set key variable { user-emacs-directory } => ~/.emacs.d/
(if (boundp 'load-file-name)
    (setq user-emacs-directory (file-name-as-directory (file-name-directory load-file-name)))
  (setq user-emacs-directory (file-name-as-directory "~/.emacs.d/")))

;; Set { core-dir } folder path
(defvar core-dir (expand-file-name "core" user-emacs-directory))

;; Load base editor setup (UI, indentation, built-in quality-of-life modes)
(load (expand-file-name "use-common-emacs.el" core-dir) t t)

;; Load custom-config (keeps `M-x customize' writes in a separate file)
(load (expand-file-name "custom-config.el" core-dir) t t)

;; Built-in dark theme (Emacs 28+; alternatives: modus-operandi, wombat, deeper-blue)
(load-theme 'modus-vivendi t)
