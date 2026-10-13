;;; custom-file.el --- manage the custom-file -*- lexical-binding: t; -*-
;; core/custom-file.el
;;
;; 本文件负责管理 Emacs 的 =custom-file=,即 Customize 界面自动生成的
;; 用户自定义配置。通过将 =custom-file= 指向一个独立文件
;; (~/.emacs.d/.config-auto.el),可以避免 Customize 把自动生成的
;; 配置写入手写的 =init.el=,从而保持主配置干净、可控、易维护。
;;
;; 主要职责:
;; 1. 设置 =custom-file= 的位置(隐藏文件 =.config-auto.el=)
;; 2. 确保其所在目录存在(等价于 =mkdir -p=)
;; 3. 若文件已存在,则静默加载,不报错、不打印消息
;; 4. 若文件不存在,则创建一个空文件,防止后续加载报错
;; Code:

(setq custom-file (expand-file-name ".config-auto.el" user-emacs-directory))

(make-directory (file-name-directory custom-file) t)

(when (file-exists-p custom-file)
  (load custom-file t t))

(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))

(provide 'custom-config)
;;; custom-file.el ends here
