;;; use-hungry-delete.el --- 连删空白 -*- lexical-binding: t; -*-
;; 一次删掉光标前/后的整段连续空白(空格、Tab、换行都算), 没空白时退化为删一个
;; 字符. 等价于 cc-mode 里的 hungry delete, 但作用于所有 mode.

(use-package hungry-delete
  :ensure t
  ;; use-package 在没有 :defer / :bind 时会启动即 require, 所以这里的 :config 一定
  ;; 会执行; 若以后加了 :defer 之类, 需要把这句挪到 :init 才不会失效.
  :config
  (global-hungry-delete-mode 1))

(provide 'use-hungry-delete)
;;; use-hungry-delete.el ends here
