;;; custom-file.el --- custom-file 管理 -*- lexical-binding: t; -*-
;; /core/custom-file.el

;;; Code:

;; 将 M-x customize 的写入定向到独立文件
(setq custom-file (expand-file-name ".config-auto.el" user-emacs-directory))

;; 存在则加载,不存在静默忽略
(load custom-file 'noerror)

(provide 'custom-file)
;;; custom-file.el ends here
