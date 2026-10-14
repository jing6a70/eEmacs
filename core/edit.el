;;; edit.el --- 编辑行为 -*- lexical-binding: t; -*-
;; /core/edit.el

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

;; Emacs 28.1+ 专属设置
(when (version<= "28.1" emacs-version)
  ;; 重复命令免前缀键
  (repeat-mode 1)
  ;; docstring 单行超过 120 列才告警(默认 80)
  (setq byte-compile-docstring-max-column 120))

;; C/C++使用linux风格 | 缩进使用空格填充
(setq c-default-style "linux")
(setq-default indent-tabs-mode nil)

;; Tab 宽度为 4 空格 | C/C++ 缩进 4 个空格
(setq-default tab-width 4)
(setq c-basic-offset 4)

(provide 'edit)
;;; edit.el ends here
