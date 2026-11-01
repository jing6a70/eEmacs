;;; use-treemacs.el --- 左侧文件树 -*- lexical-binding: t; -*-
;; C-c t 开关侧栏; C-c T 把当前工程挂进树里并打开侧栏

(use-package treemacs
  :ensure t
  :bind (("C-c t" . treemacs)
         ("C-c T" . treemacs-add-and-display-current-project))
  :config
  (setq treemacs-width 32)
  (treemacs-follow-mode t)        ; 光标所在文件自动定位
  (treemacs-filewatch-mode t)     ; 文件变动自动刷新
  (treemacs-git-mode 'deferred))  ; git 状态着色(需要 python3)

(provide 'use-treemacs)
;;; use-treemacs.el ends here
