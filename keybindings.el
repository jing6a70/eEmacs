;;; keybindings.el --- 个人快捷键 -*- lexical-binding: t; -*-
;; /keybindings.el

;;; Code:

;; F2 打开配置文件
(defun my/open-init-file ()
  "Open the init file."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

;; F5 重新加载配置
(defun my/reload-init-file ()
  "Reload the init file."
  (interactive)
  (load-file user-init-file)
  (message "Config reloaded."))

;; F2 / F5 绑定
(global-set-key (kbd "<f2>") #'my/open-init-file)

(global-set-key (kbd "<f5>") #'my/reload-init-file)

;; C-x C-b 使用 ibuffer 替代默认 buffer-menu
(global-set-key (kbd "C-x C-b") #'ibuffer)

(provide 'keybindings)
;;; keybindings.el ends here
