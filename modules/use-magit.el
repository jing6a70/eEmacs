;;; use-magit.el --- Magit configuration -*- lexical-binding: t; -*-
;; ~/.emacs.d/modules/use-magit.el

(use-package magit
  :ensure t
  ;; Keys:
  ;;   C-x g    -> open the Magit status buffer
  ;;   C-x M-g  -> popup with all Magit commands
  :bind (("C-x g"   . magit-status)
         ("C-x M-g" . magit-dispatch))
  :config
  ;; ---------- Display ----------
  ;; Show status in the whole frame; restore previous layout on close.
  (setq magit-display-buffer-function
        #'magit-display-buffer-fullframe-status-v1
        magit-bury-buffer-function
        #'magit-restore-window-configuration-and-bury-buffer)

  ;; ---------- Diff ----------
  ;; Word-level highlighting inside every hunk, not just the current one.
  (setq magit-diff-refine-hunk 'all)

  ;; ---------- Comfort ----------
  ;; Save file buffers automatically; no prompt on commit.
  (setq magit-save-repository-buffers 'dontask)
  ;; Show the author avatar in revision buffers.
  (setq magit-revision-show-gravatars t)

  ;; ---------- Commit messages ----------
  ;; Conventional 50/72 rule for commit messages.
  (setq git-commit-summary-max-length 50
        git-commit-fill-column        72)

  ;; ---------- Performance ----------
  ;; Skip background refresh of the status buffer; refresh on demand.
  ;; (Recommended for large repositories, see the Magit manual.)
  (setq magit-refresh-status-buffer nil))

;; ---------- Third-party integrations ----------
;; Top-level on purpose: these must not wait for magit to load. The old
;; nesting inside magit's :config (magit is lazy-loaded via C-x g) meant
;; diff-hl and the C-x G binding only activated after the first magit
;; call of a session.

;; diff-hl: show git changes in the fringe, restored by Magit refreshes.
(use-package diff-hl
  :ensure t
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode t)
  (setq diff-hl-show-staged-changes t)
  ;; Terminal: use the margin instead of the fringe (right side).
  (unless (display-graphic-p)
    (setq diff-hl-side 'right)
    (diff-hl-margin-mode)))

;; forge: GitHub/GitLab/Gitea/Forgejo integration from inside Magit
;; (issues and pull requests from the status buffer).
;; First use: run `M-x forge-pull' in a project to set it up.
(use-package forge
  :ensure t
  :after magit)

;; git-timemachine: step through the history of the current file.
(use-package git-timemachine
  :ensure t
  :bind ("C-x G" . git-timemachine))

;; git-link: copy a browser URL to the current line on the remote.
(use-package git-link
  :ensure t)

(provide 'use-magit)
;;; use-magit.el ends here
