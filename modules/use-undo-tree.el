;;; use-undo-tree.el --- 撤销树 -*- lexical-binding: t; -*-

(use-package undo-tree
  :ensure t
  :init (global-undo-tree-mode 1)
  :custom
  (undo-tree-auto-save-history nil))

(provide 'use-undo-tree)
;;; use-undo-tree.el ends here
