;;; use-clangd.el --- C/C++ 的 LSP(clangd) -*- lexical-binding: t; -*-
;; 只负责在 C/C++ 缓冲区里启动 clangd; 通用设置都在 modules/use-lspmode.el.
;; clangd 不在 PATH 时只在 *Warnings* 里提示, 不阻断打开文件.

(defun my/clangd-start ()
  "Start clangd for the current C/C++ buffer if it is installed."
  (my/lsp-deferred-with-server "clangd" "安装: sudo apt install clangd"))

(add-hook 'c-mode-hook #'my/clangd-start)
(add-hook 'c++-mode-hook #'my/clangd-start)
(add-hook 'objc-mode-hook #'my/clangd-start)

(provide 'use-clangd)
;;; use-clangd.el ends here
