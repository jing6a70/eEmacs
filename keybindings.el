;;; keybindings.el --- 个人快捷键 -*- lexical-binding: t; -*-
;; /keybindings.el

;;; Code:

;; ---------- 配置文件 ----------
;; F2 打开配置文件
(defun my/open-init-file ()
  "Open the init file."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(global-set-key (kbd "<f2>") #'my/open-init-file)

;; F5 重新加载配置
(defun my/reload-init-file ()
  "Reload the init file."
  (interactive)
  (load-file user-init-file)
  (message "Config reloaded."))

(global-set-key (kbd "<f5>") #'my/reload-init-file)

;; ---------- 缓冲区 ----------
;; C-x C-b 使用 ibuffer 替代默认 buffer-menu
(global-set-key (kbd "C-x C-b") #'ibuffer)

(provide 'keybindings)
;;; keybindings.el ends here
