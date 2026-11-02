;;; use-undo-tree.el --- 撤销树 -*- lexical-binding: t; -*-
;; 把线性的 undo 历史保存成树: 撤销后继续编辑不会丢掉被撤销的分支,
;; C-x u 打开可视化界面在分支间切换. 撤销容量沿用 core/edit.el 的 undo-limit.

(use-package undo-tree
  :ensure t
  ;; global-undo-tree-mode 是 autoload 的全局 minor mode, 必须在 :init 里调用,
  ;; 否则要等首次用到 undo-tree 才生效, 之前的撤销仍走内置 undo.
  :init (global-undo-tree-mode 1)
  :custom
  ;; 该变量默认是 t: 每次保存文件都会在文件旁生成 .<文件名>.~undo-tree~.
  ;; 关掉后撤销历史只活在当前会话里, 不会往项目目录里写隐藏文件.
  (undo-tree-auto-save-history nil))

(provide 'use-undo-tree)
;;; use-undo-tree.el ends here
