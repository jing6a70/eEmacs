;;; use-multi-edit.el --- 批量多行编辑 -*- lexical-binding: t; -*-
;; 两个互补的入口, 分别覆盖两类批量编辑:
;;   C-c .  iedit        光标在符号上: 所有出现处同步编辑(增量高亮, 单覆盖层)
;;   C-c e  occur-edit   以光标处符号做 occur, 匹配行当普通文本改, 改动实时同步
;;                       回源 buffer; C-c C-c 只是退出编辑态

(use-package iedit
  :ensure t
  :custom
  ;; 关掉 iedit 自带的自动绑定: 它会把同一个键同时绑到 global / isearch / esc /
  ;; help 四个 keymap, 而 C-c . 在 esc-map(M-C-c)和 help-map(C-h C-c)里已被占用,
  ;; 自动绑定时会报 "starts with non-prefix key C-c".
  (iedit-toggle-key-default nil)
  :config
  (keymap-set global-map "C-c ." #'iedit-mode)
  ;; isearch 里也能直接进 iedit: C-M-s <正则> RET 后按 C-c .
  (keymap-set isearch-mode-map "C-c ." #'iedit-mode-from-isearch))

;; C/C++ 里 C-c . 默认是 c-set-style, 会盖掉上面的全局绑定, 这里改指向 iedit
;; (c-set-style 仍可用 M-x 调用).
(with-eval-after-load 'cc-mode
  (define-key c-mode-base-map (kbd "C-c .") #'iedit-mode))

;; occur-edit-mode 是内置的, 默认要两步(M-x occur, 切到 *Occur* 后按 e). 这里把
;; "用光标处符号做 occur + 直接进入可编辑状态"合成一个命令.
(defun my/occur-edit-symbol ()
  "List all occurrences of the symbol at point and edit them in place."
  (interactive)
  (let ((symbol (thing-at-point 'symbol t)))
    (unless symbol
      (user-error "No symbol at point"))
    (occur (concat "\\_<" (regexp-quote symbol) "\\_>"))
    (when-let* ((buf (get-buffer "*Occur*")))
      (with-current-buffer buf
        (when (derived-mode-p 'occur-mode)
          (occur-edit-mode)))
      (pop-to-buffer buf))))

(keymap-set global-map "C-c e" #'my/occur-edit-symbol)

(provide 'use-multi-edit)
;;; use-multi-edit.el ends here
