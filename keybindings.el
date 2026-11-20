;;; keybindings.el --- 个人快捷键 -*- lexical-binding: t; -*-
;; /keybindings.el

;;; Code:

;; F2 打开配置文件
(defun my/open-init-file ()
  "Open the init file."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(global-set-key (kbd "<f2>") #'my/open-init-file)

;; C-x C-b 使用 ibuffer 替代默认 buffer-menu
(global-set-key (kbd "C-x C-b") #'ibuffer)

(provide 'keybindings)
;;; keybindings.el ends here
