;;; -*- lexical-binding: t; -*-
(use-package which-key
  :ensure t
  :defer 0
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5))

(provide 'use-which-key)