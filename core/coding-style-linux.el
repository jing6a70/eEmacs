;;; coding-style-linux.el --- C/C++ 代码风格 -*- lexical-binding: t; -*-
;; /core/coding-style-linux.el

;;; Code:

;; C/C++使用linux风格 | 缩进使用空格填充
(setq c-default-style "linux")
(setq-default indent-tabs-mode nil)

;; Tab 宽度为 4 空格 | C/C++ 缩进 4 个空格
(setq-default tab-width 4)
(setq c-basic-offset 4)

(provide 'coding-style-linux)
;;; coding-style-linux.el ends here
