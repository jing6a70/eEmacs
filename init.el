;;; init.el --- 启动入口 -*- lexical-binding: t; -*-
;; /init.el
;;
;; ┌─┐┌─┐┬─┐┌─┐┌─┐  ┌─┐┬ ┬┌─┐┬  ┌─┐┌─┐
;; ├─┘├┤ ├┬┘├┤ ├┤   ├─┤│ │├─┤│  ├┤ └─┐
;; ┴  └─┘┴└─└  └─┘  ┴ ┴└─┘┴ ┴┴─┘└─┘└─┘
;;         A P E X   E M A C S

;;; Code:

;; 设置user-emacs-directory
(setq user-emacs-directory
      (file-name-as-directory
       (file-truename (file-name-directory (or load-file-name buffer-file-name)))))

;; 注册core子目录
(defconst core-dir (expand-file-name "core" user-emacs-directory))
;; 加载core子目录配置
(load (expand-file-name "custom-file.el" core-dir) nil t)
(load (expand-file-name "base-ui.el"   core-dir) nil t)
(load (expand-file-name "base-edit.el" core-dir) nil t)
(load (expand-file-name "coding-style-linux.el" core-dir) nil t)

;; 启动emacs server => 如果发现systemd已启动则跳过
(require 'server)
(unless (or noninteractive
            (daemonp)
            (server-running-p))
  (server-start))

;; 设置CG阀值=16M
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

;; 加载按键绑定配置
(load (expand-file-name "keybindings.el" user-emacs-directory) nil t)

(provide 'init)
;;; init.el ends here
