;;; use-treemacs.el --- Treemacs project tree configuration -*- lexical-binding: t; -*-

;; Treemacs: tree-style project/file explorer on the left.
;; Not opened automatically at startup; lazy-loaded, invoked via keys
;; (C-x t t / M-0).

(use-package treemacs
  :ensure t
  :defer t
  :init
  ;; Key bindings:
  ;;   M-0        -> jump to the treemacs window
  ;;   C-x t t    -> toggle treemacs
  ;;   C-x t 1    -> treemacs takes up the whole frame
  ;;   C-x t B    -> add a bookmark to treemacs
  ;;   C-x t C-t  -> find file; C-x t M-t -> find tag
  :bind
  ((:map global-map
         ("M-0"       . treemacs-select-window)
         ("C-x t 1"   . treemacs-delete-other-windows)
         ("C-x t t"   . treemacs)
         ("C-x t B"   . treemacs-bookmark)
         ("C-x t C-t" . treemacs-find-file)
         ("C-x t M-t" . treemacs-find-tag))
   (:map treemacs-mode-map
         ;; "}" wider, "{" narrower
         ("C-x }" . treemacs-increase-width)
         ("C-x {" . treemacs-decrease-width)))

  :config
  ;; ---------- Window layout ----------
  (setq treemacs-position       'left                   ; tree on the left side
        treemacs-width          35                      ; default width (columns)
        treemacs-width-increment 5                      ; width adjustment step
        treemacs-width-is-initially-locked nil            ; keep width draggable
        treemacs-display-in-side-window     t           ; use a side-window
        treemacs-is-never-other-window      nil
        treemacs-no-delete-other-windows    t           ; keep treemacs alive

        window-resize-pixelwise t)                      ; pixel-precise mouse resize

  ;; ---------- Behavior ----------
  (setq treemacs-follow-after-init               t      ; follow the current file on open
        treemacs-expand-after-init               t
        treemacs-file-follow-delay               0.2    ; file follow delay (seconds)
        treemacs-tag-follow-delay                1.5    ; tag follow delay (seconds)
        treemacs-recenter-distance               0.1
        treemacs-recenter-after-file-follow      nil
        treemacs-recenter-after-tag-follow       nil
        treemacs-recenter-after-project-jump     'always
        treemacs-recenter-after-project-expand   'on-distance
        treemacs-select-when-already-in-treemacs 'stay  ; stay put if already inside
        treemacs-move-forward-on-expand          nil
        treemacs-goto-tag-strategy               'refetch-index
        treemacs-missing-project-action          'ask   ; ask when project dir vanished
        treemacs-collapse-dirs                   3      ; collapse single-child chains

        treemacs-sorting                         'alphabetic-asc
        treemacs-space-between-root-nodes        t
        treemacs-show-cursor                     nil)

  ;; ---------- File display ----------
  (setq treemacs-show-hidden-files          t           ; show dotfiles
        treemacs-file-name-transformer      #'identity
        treemacs-directory-name-transformer #'identity
        treemacs-indentation                2
        treemacs-indentation-string         " "
        treemacs-no-png-images              nil         ; use PNG icons
        treemacs-eldoc-display              'simple

        ;; -- File watching & git performance --
        treemacs-file-event-delay           2000        ; file event debounce (ms)
        treemacs-deferred-git-apply-delay   0.5         ; deferred git apply delay (s)
        treemacs-max-git-entries            5000        ; max git entries per project
        treemacs-silent-refresh             nil

        ;; -- Persistence (kept in .cache so it doesn't pollute the config dir) --
        treemacs-persist-file
        (expand-file-name ".cache/treemacs-persist" user-emacs-directory))

  ;; ---------- Icon theme ----------
  ;; GUI: fancy, colorful nerd icons; still fall back to PNG icons in TUI.
  (when (display-graphic-p)
    (require 'treemacs-nerd-icons)
    (setq treemacs-no-png-images t)     ; disable builtin pngs, use nerd-icons
    (treemacs-load-theme "nerd-icons"))

  ;; Follow the projectile project of the current buffer (built-in mode,
  ;; replaces the old custom auto-add-project hook). Home dir never followed.
  (treemacs-project-follow-mode 1)

  ;; ---------- Minor modes ----------
  (treemacs-follow-mode t)                ; follow the current buffer's file
  (treemacs-filewatch-mode t)             ; auto-refresh on external changes
  (treemacs-fringe-indicator-mode 'always) ; fringe git-change indicators
  (treemacs-hide-gitignored-files-mode t) ; hide gitignored files

  ;; ---------- Git integration ----------
  ;; Use 'deferred (async, smooth UI, full git state) with python3,
  ;; otherwise fall back to 'simple.
  (let ((has-git    (executable-find "git"))
        (has-python (executable-find "python3")))
    (cond
     ((and has-git has-python) (treemacs-git-mode 'deferred))
     (has-git                  (treemacs-git-mode 'simple)))))

;; Treemacs icons in dired
(use-package treemacs-icons-dired
  :ensure t
  :hook (dired-mode . treemacs-icons-dired-mode))

;; Magit integration
(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

;; Projectile project management (primary project library; project.el
;; stays available through its built-in C-x p prefix).
(use-package projectile
  :ensure t
  :bind
  ;; Doom-style prefix: C-c p opens the full projectile menu.
  ;; Pick the most-used commands explicitly below that menu.
  ("C-c p" . projectile-command-map)
  :custom
  ;; Use the existing vertico stack for completions.
  (projectile-completion-system 'vertico)
  ;; Native indexing is fastest for big repos; fall back hybrid when
  ;; the machine lacks tools (usual on ubuntu 18.04).
  (projectile-indexing-method 'hybrid)
  (projectile-enable-caching t)
  ;; Keep home and the .emacs.d config from being treated as projects.
  (projectile-ignored-projects '("~/" "~/.emacs.d/"))
  :config
  (projectile-mode +1))

;; Treemacs + Projectile integration
(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile)
  ;; Replace the custom auto-add hook with the built-in
  ;; `treemacs-project-follow-mode': treemacs follows the projectile
  ;; project of the current file automatically. Home directory is not
  ;; followed by default (`treemacs-project-follow-into-home' stays nil).
  ;; The ignore list was moved into the projectile block above.
  )

(provide 'use-treemacs)
;;; use-treemacs.el ends here
