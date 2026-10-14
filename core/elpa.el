;;; elpa.el --- ELPA 包管理 -*- lexical-binding: t; -*-
;; /core/elpa.el

;;; Code:

;; 配置包仓库
(require 'package)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; 初始化package
(when (version< emacs-version "29")
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
  (require 'use-package))

(provide 'elpa)
;;; elpa.el ends here
