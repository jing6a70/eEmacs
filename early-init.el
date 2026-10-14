;;; early-init.el --- 最早启动设置 -*- lexical-binding: t; -*-
;; /early-init.el

;;; Code:


;; 配置包仓库 => 在 package.el 初始化前生效
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; 启动阶段拉高 GC 阈值 => init.el启动完成后恢复
(setq gc-cons-threshold most-positive-fixnum)

;; 提前关闭 UI,避免启动时界面闪烁
(menu-bar-mode -1)

;; 关闭滚动条
(scroll-bar-mode -1)

;; 关闭工具栏
(tool-bar-mode -1)

(provide 'early-init)
;;; early-init.el ends here
