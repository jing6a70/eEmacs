;;; compat.el --- 依赖包与内置库的跨版本补丁 -*- lexical-binding: t; -*-
;; /core/compat.el
;; 只放"第三方包比内置库新"时需要的补丁, 每条都要写清楚来由和失效条件.

;; 1. project 0.12.0(GNU ELPA, eglot 1.26 的依赖)在 Emacs 29 上会读
;;    `Buffer-menu-show-internal' —— 这个变量 Emacs 30 的 buff-menu.el 才有.
;;    不补的话 `C-x p b'(project-list-buffers) 直接报 void-variable.
;;    30+ 有自己的定义(缺省值同为 nil), 所以只在 29 及更早补.
(when (version< emacs-version "30")
  (defvar Buffer-menu-show-internal nil
    "Compat declaration for project.el on Emacs < 30."))

(provide 'compat)
;;; compat.el ends here
