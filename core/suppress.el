;;; suppress.el --- 包警告屏蔽 -*- lexical-binding: t; -*-
;; /core/suppress.el
;; 这里是针对elpa包的优化
;; 1. docstring 单行默认为超出80触发告警, 本配置修改为超过120列告警
;;    => defun函数中的介绍例如本配置的defun my/open-init-file () 的第二行
;;       函数介绍"open the init file" 
;; 2. 关闭第三方包常见的编译误报:
;;    => not-unused -> 用 _ 变量时的告警(如 llama.el)
;;    => lexical    -> 宏展开后的"未使用词法变量"(如 diff-hl-flydiff.el)
;;; Code:

(when (version<= "28.1" emacs-version)
  (setq byte-compile-docstring-max-column 120)
  (setq byte-compile-warnings '(not not-unused lexical)))

(provide 'suppress)
;;; edit.el ends here
