;;; early-init.el --- 最早启动设置 -*- lexical-binding: t; -*-
;; /early-init.el

;;; Code:


;; 启动阶段拉高 GC 阈值 => init.el启动完成后恢复
(setq gc-cons-threshold most-positive-fixnum)

;; 提前关闭 UI,避免启动时界面闪烁
(menu-bar-mode -1)

;; 关闭滚动条
(scroll-bar-mode -1)

;; 不使用第三方包,跳过启动时的包激活
(setq package-enable-at-startup nil)

;; 关闭工具栏
(tool-bar-mode -1)

;;; early-init.el ends here
