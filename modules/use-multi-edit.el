;;; use-multi-edit.el --- 批量多行编辑 -*- lexical-binding: t; -*-
;; 两个互补的入口, 分别覆盖两类批量编辑:
;;   C-;   iedit        选中当前符号/选区, 所有出现处同步编辑(增量高亮, 单覆盖层)
;;   C-c e occur-edit   以光标处符号做 occur, 把匹配行当普通文本改, 改动实时同步
;;                      回源 buffer; C-c C-c 只是退出编辑态

(use-package iedit
  :ensure t)
;; C-; 不用手动绑: iedit 加载时会调 iedit-update-key-bindings, 按
;; iedit-toggle-key-default(默认 C-;)绑定 iedit-mode.

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
