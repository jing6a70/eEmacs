;;; early-init.el --- 最早启动设置 -*- lexical-binding: t; -*-
;; /early-init.el

;;; Code:


;; 启动阶段拉高 GC 阈值 => init.el启动完成后恢复
(setq gc-cons-threshold most-positive-fixnum)

;; 提前关闭 UI,避免启动时界面闪烁
(menu-bar-mode -1)

;; 关闭滚动条
(scroll-bar-mode -1)

;; 关闭工具栏
(tool-bar-mode -1)

;; 字体: 英文等宽用 Fira Code, 中文用 Noto Sans CJK SC
;; (130 = 13pt, 想改字号就调这里; 装字体见同目录的 initmint.sh)
(set-face-attribute 'default nil :family "Fira Code" :height 130)
(dolist (script '(han cjk-misc bopomofo))
  (set-fontset-font t script (font-spec :family "Noto Sans CJK SC")))

(provide 'early-init)
;;; early-init.el ends here
