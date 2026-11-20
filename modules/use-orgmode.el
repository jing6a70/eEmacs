;;; use-orgmode.el --- Org mode setup (built-in on Emacs 29+) -*- lexical-binding: t; -*-
;; moduls/setup-orgmode.el


;; Org mode that comes with Emacs 29
;; Main parts: basic look, TODO words, Babel for many languages, shell setup
;; Adds latex display
;; Adds image display: jpg png svg...


(use-package org
  :pin gnu  ; use the Org Mode built into Emacs 29
  :defer t  ; load only when an Org file is opened; keeps startup fast
  :config
  ;; Basic Org display
  (setq org-startup-indented t  ; start with indented view
        org-todo-keywords '((sequence "TODO" "DOING" "DONE"))  ; TODO cycle
        org-todo-keyword-faces '(("DOING" . "blue"))  ; show DOING in blue
        org-src-fontify-natively t)  ; color code in source blocks

  ;; Org Babel: languages that can run code blocks
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)       ; run python blocks
     (shell . t)        ; run shell/bash blocks
     (js . t)           ; run javascript blocks
     (emacs-lisp . t))) ; run emacs-lisp blocks
  ;; Do not ask before running code blocks for these languages.
  ;; NOTE: shell blocks report their language as "sh"/"bash"/"zsh" —
  ;; never "shell" — so the old whitelist never matched and shell
  ;; blocks kept prompting for confirmation.
  (setq org-confirm-babel-evaluate
        (lambda (lang body)
          (not (member lang '("python" "sh" "bash" "zsh" "js")))))

  ;; Shell setup
  (setenv "SUDO_ASKPASS" (expand-file-name "sh/emacs-askpass.sh" user-emacs-directory))
  ;; Run bash babel blocks with -i. The old org-babel-shell-command
  ;; variable no longer exists in Emacs 31's org — the setq was silently
  ;; dead; the working equivalent is a default :cmdline header arg for
  ;; bash blocks.
  (setq org-babel-default-header-args:bash '((:cmdline . "-i")))

  ;; latex
  (setq org-latex-preview-default-process 'dvisvgm)
  ;; latex look and feel (match theme colors + good size)
  (setq org-latex-preview-appearance-options
        '(:foreground default          ; follow the theme's foreground color
                      :background "Transparent"    ; clear background looks natural
                      :scale 1.6                   ; 1.4~2.0 is a good range, set by screen DPI
                      :zoom 1.2
                      :page-width 0.85             ; formula width as page share
                      :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")))

  ;; Show all latex chips as preview when the file opens
  ;; (setq org-startup-with-latex-preview t)

  ;; Auto render mode (Emacs 29+)
  (when (fboundp 'org-latex-preview-auto-mode)
    (add-hook 'org-mode-hook #'org-latex-preview-auto-mode))

  ;; NOTE: org-display-inline-images / org-redisplay-inline-images are
  ;; FUNCTIONS in Emacs 31's org, not variables — setq on them did
  ;; nothing, so they were removed. The two variables below are the
  ;; real switches.
  (setq org-startup-with-inline-images t          ;; show images when file opens
        org-image-actual-width '(300))            ;; show at 300px; nil = real size

  (define-key org-mode-map (kbd "C-c C-x C-v") #'org-redisplay-inline-images))

;; Load Org modules by hand (makes Babel work even with lazy loading)
(provide 'use-orgmode)
;;; use-orgmode.el ends here
