;;; use-yasnippet.el -*- lexical-binding: t; -*-
;; yasnippet: code snippet support for Emacs
(use-package yasnippet
  :ensure t
  :bind
  ("C-c y" . yas-insert-snippet)  ; snippet insert via vertico fuzzy search
  :config
  (add-to-list 'yas-snippet-dirs (expand-file-name "snippets" user-emacs-directory))
  (yas-global-mode t))


(provide 'use-yasnippet)
;;; use-yasnippet.el ends here
