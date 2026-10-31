;;; use-dape.el --- dape 配置 -*- lexical-binding: t; -*-

(use-package dape
  :ensure t
  :config
  (keymap-set global-map "C-c g" dape-global-map)
  (setq dape-buffer-window-arrangement 'right)
  (when-let* ((cfg (assq 'gdb dape-configs)))
    (setcdr cfg (plist-put (cdr cfg) 'defer-launch-attach t)))
  (dape-breakpoint-global-mode 1))

(provide 'use-dape)
