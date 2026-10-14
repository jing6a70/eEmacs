;;; base-edit.el --- 编辑行为 -*- lexical-binding: t; -*-
;; /core/base-edit.el

;;; Code:

;; 禁止生成 file~ 备份
(setq make-backup-files nil)

;; 两个 dired 窗口之间可直接复制/移动
(setq dired-dwim-target t)

;; 高亮匹配的括号
(show-paren-mode t)

;; 选中文本后直接输入即可替换
(delete-selection-mode 1)

;; 统一使用 UTF-8
(prefer-coding-system 'utf-8)

;; 保存时保证文件以换行结尾
(setq require-final-newline t)

;; 记录最近打开的文件
(recentf-mode 1)

;; 保存 minibuffer 历史
(savehist-mode 1)

;; 加大撤销历史
(setq undo-limit 800000
      undo-strong-limit 1200000
      undo-outer-limit 48000000)

;; 删除文件移入系统回收站,避免误删
(setq delete-by-moving-to-trash t)

;; 输入左括号自动补全右括号
(electric-pair-mode t)

;; 保存上次编辑时的光标位置
(save-place-mode 1)

;; 重复命令免前缀键
(when (version<= "28.1" emacs-version)
  (repeat-mode 1))

(provide 'base-edit)
;;; base-edit.el ends here
