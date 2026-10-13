;;; init.el --- 启动入口 -*- lexical-binding: t; -*-
;; /init.el
;;
;; ┌─┐┌─┐┬─┐┌─┐┌─┐  ┌─┐┬ ┬┌─┐┬  ┌─┐┌─┐
;; ├─┘├┤ ├┬┘├┤ ├┤   ├─┤│ │├─┤│  ├┤ └─┐
;; ┴  └─┘┴└─└  └─┘  ┴ ┴└─┘┴ ┴┴─┘└─┘└─┘
;;         A P E X   E M A C S

;;; Code:


;; 以本文件所在目录作为 user-emacs-directory
(if (boundp 'load-file-name)
    (setq user-emacs-directory (file-name-as-directory (file-name-directory load-file-name)))
  (setq user-emacs-directory (file-name-as-directory "~/.emacs.d/")))

;; core 子目录
(defvar core-dir (expand-file-name "core" user-emacs-directory))

;; 界面与显示
(load (expand-file-name "base-ui.el" core-dir) t t)

;; 编辑行为
(load (expand-file-name "base-edit.el" core-dir) t t)

;; C/C++ 代码风格(Linux)
(load (expand-file-name "coding-style-linux.el" core-dir) t t)

;; custom-file 管理
(load (expand-file-name "custom-file.el" core-dir) t t)

;; 个人快捷键(与 init.el 同级)
(load (expand-file-name "keybindings.el" user-emacs-directory) t t)

;; 启动 Emacs server,便于 emacsclient 连入(batch 模式自动跳过)
(when (and (fboundp 'server-start) (not noninteractive))
  (server-start))

;; 恢复 early-init.el 中拉高的 GC 阈值
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 64 1024 1024))))

;; ---------- Emacs 28.1+ ----------

;; 内置深色主题(Emacs 28+;可换 modus-operandi / wombat / deeper-blue)
(when (version<= "28.1" emacs-version)
  (load-theme 'modus-vivendi t))

;;; init.el ends here
