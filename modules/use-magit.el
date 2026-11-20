;;; use-magit.el --- Magit configuration -*- lexical-binding: t; -*-
;; ~/.emacs.d/modules/use-magit.el

(use-package magit
  :ensure t
  :bind (("C-x g"   . magit-status)
         ("C-x M-g" . magit-dispatch))
  :config
  (setq magit-display-buffer-function
        #'magit-display-buffer-fullframe-status-v1
        magit-bury-buffer-function
        #'magit-restore-window-configuration-and-bury-buffer)

  (setq magit-diff-refine-hunk 'all)

  (setq magit-save-repository-buffers 'dontask)
  (setq magit-revision-show-gravatars t)

  (setq git-commit-summary-max-length 50
        git-commit-fill-column        72)

  (setq magit-refresh-status-buffer nil))



(use-package diff-hl
  :ensure t
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode t)
  (setq diff-hl-show-staged-changes t)
  (unless (display-graphic-p)
    (setq diff-hl-side 'right)
    (diff-hl-margin-mode)))

(provide 'use-magit)
;;; use-magit.el ends here
