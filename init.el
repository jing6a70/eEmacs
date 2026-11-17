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

;; 将 M-x customize 的写入定向到独立文件 
(setq custom-file (expand-file-name ".config-auto.el" user-emacs-directory))
(load custom-file 'noerror) ;; 存在则加载, 不存在静默忽略

;; 注册core子目录
(defconst core-dir (expand-file-name "core" user-emacs-directory))

;; 加载core子目录配置
(mapc (lambda (module)
        (load (expand-file-name module core-dir) nil t))
      '("elpa" "view" "edit" "theme" "suppress"))

;; 注册modules子目录
(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))

;; 模块加载列表
(defvar my/local-modules
  '(use-magit use-dape use-dashboard use-treemacs use-undo-tree use-hungry-delete
    use-multi-edit use-vertico use-yasnippet use-corfu use-eglot use-clangd))

(dolist (module my/local-modules)
  (require module nil 'noerror))


;; 加载按键绑定配置
(load (expand-file-name "keybindings.el" user-emacs-directory) nil t)

;; 启动emacs server => 如果发现systemd已启动则跳过
(require 'server)
(unless (or noninteractive
            (daemonp)
            (server-running-p))
  (server-start))

;; 设置GC阀值=16M
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

(provide 'init)
;;; init.el ends here
