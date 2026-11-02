;;; use-undo-tree.el --- 撤销树 -*- lexical-binding: t; -*-
;; 把线性的 undo 历史保存成树: 撤销后继续编辑不会丢掉被撤销的分支,
;; C-x u 打开可视化界面在分支间切换. 撤销容量沿用 core/edit.el 的 undo-limit.

(use-package undo-tree
  :ensure t
  ;; global-undo-tree-mode 是 autoload 的全局 minor mode. use-package 在没有
  ;; :defer / :bind 时本来就启动即 require, 放 :config 同样会执行; 这里放 :init
  ;; 只是让撤销树更早接管, 不依赖加载时机.
  :init (global-undo-tree-mode 1)
  :custom
  ;; 该变量默认是 t: 每次保存文件都会在文件旁生成 .<文件名>.~undo-tree~.
  ;; 关掉后撤销历史只活在当前会话里, 不会往项目目录里写隐藏文件.
  (undo-tree-auto-save-history nil))

(provide 'use-undo-tree)
;;; use-undo-tree.el ends here
