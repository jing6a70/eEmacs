;;; base-ui.el --- 界面与显示 -*- lexical-binding: t; -*-
;; /core/base-ui.el

;;; Code:

;; 关闭菜单栏
(menu-bar-mode -1)

;; mode-line 显示列号
(column-number-mode 1)

;; 关闭滚动条
(scroll-bar-mode -1)

;; 关闭响铃
(setq ring-bell-function 'ignore)

;; C-c <left>/<right> 撤销/重做窗口布局
(winner-mode 1)

;; 光标接近边缘即提前滚动,减少跳屏
(setq scroll-conservatively 101)

;; 光标距边缘保留 2 行
(setq scroll-margin 2)

;; mode-line 显示当前函数名
(which-function-mode 1)

;; 禁用 GUI 弹窗,交互一律走 minibuffer
(setq use-dialog-box nil)

;; 光标默认为竖线
(setq-default cursor-type 'bar)

;; 非活动窗口不显示光标
(setq cursor-in-non-selected-windows nil)

;; 关闭光标闪烁
(blink-cursor-mode -1)

;; 关闭启动欢迎画面
(setq inhibit-splash-screen t)

;; *scratch* 留空,不显示提示语
(setq initial-scratch-message nil)

;; 关闭工具栏
(tool-bar-mode -1)

;; Shift + 方向键在窗口间移动
(windmove-default-keybindings)

;; 文件被外部改动时自动重载
(global-auto-revert-mode 1)

;; ---------- Emacs 26.1+ ----------

;; 全局显示行号
(when (version<= "26.1" emacs-version)
  (global-display-line-numbers-mode t))

;; ---------- Emacs 28.1+ ----------

;; 垂直补全 UI(原生,类似 vertico;Emacs 28+)
(when (version<= "28.1" emacs-version)
  (fido-vertical-mode 1))

;; M-x 不列出内部命令(Emacs 28+)
(when (version<= "28.1" emacs-version)
  (setq read-extended-command-predicate #'command-completion-default-include-p))

;; ---------- Emacs 29.1+ ----------

;; 像素级平滑滚动(Emacs 29+)
(when (version<= "29.1" emacs-version)
  (pixel-scroll-precision-mode 1))

(provide 'base-ui)
;;; base-ui.el ends here
