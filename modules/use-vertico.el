;;; use-vertico.el --- 补全框架(vertico 全家桶) -*- lexical-binding: t; -*-
;; 分工: vertico 管候选列表, orderless 管匹配, marginalia 加旁注,
;; consult 提供搜索/跳转, embark 对当前候选执行动作.
;; 注意: 启用本模块后不能再开 fido-mode / fido-vertical-mode / icomplete-mode,
;; 否则会抢同一个 minibuffer 显示层(core/view.el 里的 fido 已移除).

(use-package vertico
  :ensure t
  :init (vertico-mode 1)
  :custom
  (vertico-count 13)            ; 一次显示 13 个候选
  (vertico-cycle t)             ; 到末尾后回头循环
  :config
  ;; vertico-directory 是随包分发的扩展(不在 vertico.el 里, 也没有 autoload),
  ;; 不显式 require 的话按 DEL 会报 void-function.
  (require 'vertico-directory)
  ;; DEL 删到目录名的最后一个字符时整段删掉, 而不是一格一格退
  (keymap-set vertico-map "DEL" #'vertico-directory-delete-char)
  (keymap-set vertico-map "M-DEL" #'vertico-directory-delete-word)
  ;; 在 ~/ 下补全时, 别让 shadow 目录前缀串进候选
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy))

;; 匹配引擎: 空格分隔、任意顺序, 例如 "conf init" 能匹配 "init-config.el"
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; 候选右侧的旁注: M-x 显示命令的简介, 文件名显示大小/权限
(use-package marginalia
  :ensure t
  :init (marginalia-mode 1))

;; 搜索与跳转
(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer)     ; 缓冲 + 书签 + 最近文件
         ("M-y" . consult-yank-pop)     ; 带预览的 kill-ring
         ("M-g g" . consult-goto-line)
         ("M-g m" . consult-mark)
         ("M-g i" . consult-imenu)
         ;; C-s 保留给 isearch: docs/multi-edit.md 里的 "C-s → C-c s" 依赖它
         ("M-s l" . consult-line)
         ("M-s r" . consult-ripgrep)    ; 需要 ripgrep(rg)
         :map minibuffer-local-map
         ("M-r" . consult-history)))

;; 对光标处的候选执行动作(复制/删除/重命名/批量标记等)
(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         ;; M-. 留给 xref-find-definitions, 写 C/C++ 时要跳定义
         ("C-;" . embark-dwim))
  :init (setq prefix-help-command #'embark-prefix-help-command))

;; 让 embark 的 collect 缓冲区支持 consult 的实时预览
(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; minibuffer 历史沿用 core/edit.el 里的 savehist-mode, 这里不重复开启
(setq read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      completion-ignore-case t)

(provide 'use-vertico)
;;; use-vertico.el ends here
