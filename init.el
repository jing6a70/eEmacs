;;; -*- lexical-binding: t; -*-
;; init.el
;; ┌─┐┌─┐┬─┐┌─┐┌─┐  ┌─┐┬ ┬┌─┐┬  ┌─┐┌─┐
;; ├─┘├┤ ├┬┘├┤ ├┤   ├─┤│ │├─┤│  ├┤ └─┐
;; ┴  └─┘┴└─└  └─┘  ┴ ┴└─┘┴ ┴┴─┘└─┘└─┘
;;       A P E X     E M A C S
;;
;; Commentary: Initial load file for Emacs. Loads on every Emacs start.

;; Set key variable { user-emacs-directory } => ~/.emacs.d/
(if (boundp 'load-file-name)
    (setq user-emacs-directory (file-name-as-directory (file-name-directory load-file-name)))
  (setq user-emacs-directory (file-name-as-directory "~/.emacs.d/")))

;; Set { core-dir } and { view-dir } folder paths
(defvar core-dir (expand-file-name "core" user-emacs-directory))
(defvar view-dir (expand-file-name "view" user-emacs-directory))

;; Load base editor setup
(load (expand-file-name "use-common-emacs.el" core-dir) t t)

;; Load package sources (see with C-h v package-archives)
(load (expand-file-name "package-sources.el" core-dir) t t)
(package-initialize) ;; start the package manager
;; Load custom-config
(load (expand-file-name "custom-config.el" core-dir) t t)
;; Load font setup (icon font for treemacs / doom-modeline)
(load (expand-file-name "use-fonts.el" view-dir) t t)
;; Load theme
(load (expand-file-name "use-theme.el" view-dir) t t)


;; Load each USE config
(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
(defvar my/local-modules
  '(use-vertico        ;; completion UI framework
    ;; use-corfu       ;; buffer completion (Corfu, instead of company) — off for now
    use-lspmode        ;; LSP core setup (generic, no language inside)
    use-treemacs       ;; left side file tree
    use-magit          ;; git client
    use-orgmode        ;; org file support
    use-yasnippet      ;; code snippets
    use-hungry-delete  ;; remove extra spaces fast
    use-undo-tree      ;; C-x u visual undo tree
    use-which-key      ;; key hint popup
    use-spell          ;; traditional flyspell spell check (aspell/hunspell)
    use-multi-edit     ;; multi-line editing: multiple-cursors + iedit + expand-region
    ))
(dolist (module my/local-modules)
  (require module nil 'noerror))

;; Custom functions and key bindings
(add-to-list 'load-path (expand-file-name "elisp" user-emacs-directory))
(require 'init-func-def)
(require 'init-func-key)
;; Language files (custom elisp, LSP based; need use-lspmode above)
(require 'e-clang-mode)
(require 'e-bash-mode)          ;; shell scripts via bash-language-server
(require 'e-golang-mode)        ;; go via gopls
(require 'e-pylang-mode)        ;; python via pyright