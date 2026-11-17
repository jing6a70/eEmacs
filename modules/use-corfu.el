;;; use-corfu.el --- 行内补全(corfu + cape) -*- lexical-binding: t; -*-
;; corfu 负责缓冲区内的补全弹窗; cape 提供路径、dabbrev 等后备候选;
;; 片段候选由 yasnippet-capf 提供(cape 本身没有 yasnippet 后端).
;; orderless / vertico 的匹配设置统一在 use-vertico.el, 这里不重复.

(use-package corfu
  :ensure t
  :init (global-corfu-mode 1)           ; 全局开启
  :custom
  (corfu-auto t)                        ; 输入时自动弹
  (corfu-auto-delay 0.25)               ; 停 0.25 秒后弹(默认 0.2)
  (corfu-auto-prefix 2)                 ; 默认 3; 2 更早触发(请求更多), 只有 1 才是"每字符都发请求"
  (corfu-cycle t)                       ; 候选可循环
  (corfu-preselect 'prompt)             ; 预选输入本身, 配合 orderless 多段匹配更顺
  (corfu-preview-current nil)           ; 继续输入时不自动插入当前候选
  ;; 别设太短: 每个候选都要向 server(clangd hover)取一次文档, 0.2 秒会明显加负载
  (corfu-popupinfo-delay '(0.6 . 0.4))
  :config
  (corfu-popupinfo-mode 1))             ; 候选旁边显示文档

;; 后备后端: 片段(50) -> 路径(80) -> buffer 里的词(90), 数字越小越优先.
;; 函数放顶层, 由 cape 的 :config 挂 hook, 这样字节编译时不会报 "not known to be defined".
(defun my/corfu-add-backends ()
  "Add non-LSP completion backends to the current buffer."
  (add-hook 'completion-at-point-functions #'yasnippet-capf 50 t)
  (add-hook 'completion-at-point-functions #'cape-file 80 t)
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90 t))

(use-package cape
  :ensure t
  :after corfu
  :config
  (add-hook 'prog-mode-hook #'my/corfu-add-backends)
  (add-hook 'text-mode-hook #'my/corfu-add-backends)
  (add-hook 'org-mode-hook #'my/corfu-add-backends))

;; 片段候选: 提供带 autoload 的 CAPF 函数, 由 my/corfu-add-backends 挂进 buffer
(use-package yasnippet-capf
  :ensure t
  :after yasnippet)

(provide 'use-corfu)
;;; use-corfu.el ends here
