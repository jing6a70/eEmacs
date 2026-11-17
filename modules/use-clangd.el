;;; use-clangd.el --- C/C++ 的 LSP(clangd, 走 Eglot) -*- lexical-binding: t; -*-
;; 只负责在 C/C++ 缓冲区里启动 clangd; 通用设置都在 modules/use-eglot.el.
;; clangd 在不在 `eglot-server-programs` 里? Emacs 29 已经默认把
;; c-mode / c++-mode 映射到 clangd(找不到再试 ccls), 所以这里不用再写 server 参数.
;; clangd 不在 PATH 时只在 *Warnings* 里提示, 不阻断打开文件.

;; `my/eglot-ensure-with-server' 在 use-eglot.el, 加载顺序在它之后
(declare-function my/eglot-ensure-with-server "use-eglot" (server install-hint))

(defun my/clangd-start ()
  "Start Eglot with clangd for the current C/C++ buffer if it is installed."
  (my/eglot-ensure-with-server "clangd" "安装: sudo apt install clangd"))

(add-hook 'c-mode-hook #'my/clangd-start)
(add-hook 'c++-mode-hook #'my/clangd-start)
(add-hook 'objc-mode-hook #'my/clangd-start)

(provide 'use-clangd)
;;; use-clangd.el ends here
