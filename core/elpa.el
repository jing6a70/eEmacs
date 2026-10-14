;;; elpa.el --- ELPA 包管理 -*- lexical-binding: t; -*-
;; /core/elpa.el

;;; Code:

;; 配置包仓库
(require 'package)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; 初始化 package(29+ 由 Emacs 自动处理)
(when (version< emacs-version "29")
  (package-initialize)
  ;; 旧版本无内置 use-package, 首次运行时尝试自动安装
  (unless (package-installed-p 'use-package)
    (condition-case err
        (progn
          (package-refresh-contents)
          (package-install 'use-package))
      (error (message "use-package 安装失败(请检查网络/归档): %S" err))))
  (require 'use-package nil 'noerror))

(provide 'elpa)
;;; elpa.el ends here
