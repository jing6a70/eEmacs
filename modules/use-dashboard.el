;;; use-dashboard.el --- 启动欢迎页 -*- lexical-binding: t; -*-
;; 启动时显示: 最近工程 + 最近文件 + 书签
;; 工程列表来自 project.el 的 project-list-file, 与 C-x p p 共用同一份历史

(use-package dashboard
  :ensure t
  :init
  (setq dashboard-items '((projects  . 10)
                          (recents   . 5)
                          (bookmarks . 3))
        ;; 用 project.el 作为工程来源(默认值, 显式写出便于以后对照)
        dashboard-projects-backend 'project-el
        dashboard-startup-banner 'logo
        dashboard-center-content t)
  :config
  (dashboard-setup-startup-hook))

(provide 'use-dashboard)
;;; use-dashboard.el ends here
