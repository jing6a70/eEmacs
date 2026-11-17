;;; suppress.el --- 包警告屏蔽 -*- lexical-binding: t; -*-
;; /core/suppress.el
;; 这里是针对elpa包的优化
;; 1. docstring 单行默认为超出80触发告警, 本配置修改为超过120列告警
;;    => defun函数中的介绍例如本配置的defun my/open-init-file () 的第二行
;;       函数介绍"open the init file"
;; 2. 关闭第三方包常见的编译误报:
;;    => not-unused -> 用 _ 变量时的告警(如 llama.el)
;;    => lexical    -> 宏展开后的"未使用词法变量"(如 diff-hl-flydiff.el)
;; 3. 跳过 project 0.12.0(GNU ELPA, eglot 1.26 的依赖)的 JIT native 编译:
;;    它引用了 Emacs 30 才有的 `Buffer-menu-show-internal' 与 `customize-dirlocals',
;;    在 29.x 上后台编译会刷两条 "Warning (comp)"。包内有 .elc, 跳过 native 编译
;;    (退化为字节码)不影响功能; 运行期的变量缺失由 core/compat.el 补。
;;    升到 Emacs 30 或 project 上游适配 29 以后可以删掉这段。
;;; Code:

;; comp.el 里定义; 先声明一下, 字节编译时不报 free variable
(defvar native-comp-jit-compilation-deny-list)

(when (version<= "28.1" emacs-version)
  (setq byte-compile-docstring-max-column 120)
  (setq byte-compile-warnings '(not not-unused lexical)))

(when (and (version< emacs-version "30")
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (with-eval-after-load 'comp
    (add-to-list 'native-comp-jit-compilation-deny-list "/project\\.el\\'")))

(provide 'suppress)
;;; suppress.el ends here
