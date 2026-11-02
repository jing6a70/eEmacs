;;; use-corfu.el --- 行内补全(corfu + cape) -*- lexical-binding: t; -*-
;; corfu 负责缓冲区内的补全弹窗, cape 提供 LSP 之外的后备候选(dabbrev/路径).
;; 片段候选由 yasnippet-capf 提供 —— cape 本身没有 yasnippet 后端.

(use-package corfu
  :ensure t
  :init (global-corfu-mode 1)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.3)
  (corfu-auto-prefix 2)         ; 设 1 会在每敲一个字符时都打一次 clangd
  (corfu-cycle t)
  :config
  (corfu-popupinfo-mode 1))     ; 候选旁边显示文档

(use-package cape
  :ensure t
  :after corfu
  :config
  ;; 后备候选按深度排在 LSP 之后: 片段 50 -> 路径 80 -> dabbrev 90
  (defun my/corfu-add-backends ()
    "Add non-LSP completion backends to the current buffer."
    (add-hook 'completion-at-point-functions #'yasnippet-capf 50 t)
    (add-hook 'completion-at-point-functions #'cape-file 80 t)
    (add-hook 'completion-at-point-functions #'cape-dabbrev 90 t))
  (add-hook 'prog-mode-hook #'my/corfu-add-backends)
  (add-hook 'text-mode-hook #'my/corfu-add-backends)
  (add-hook 'org-mode-hook #'my/corfu-add-backends))

;; 片段候选: 提供 autoload 的 CAPF 函数, 由上一步挂进 completion-at-point-functions
(use-package yasnippet-capf
  :ensure t
  :after yasnippet)

(provide 'use-corfu)
;;; use-corfu.el ends here
