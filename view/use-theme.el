;;; use-theme.el --- UI themes and modeline -*- lexical-binding: t; -*-

;; Theme UI Settings for the whole Emacs interface
(use-package doom-themes
  :ensure t
  :init (load-theme 'doom-city-lights t)
  :config
  ;; Official doom-themes extras for org and treemacs faces.
  (doom-themes-org-config)
  (with-eval-after-load 'treemacs
    (doom-themes-treemacs-config)))

;; Modern modeline for GUI sessions (git status, icons, LSP feedback).
(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 32)
  (doom-modeline-icon (display-graphic-p))
  (doom-modeline-enable-word-count t)
  (doom-modeline-buffer-encoding nil))

(provide 'use-theme)
;;; use-theme.el ends here
