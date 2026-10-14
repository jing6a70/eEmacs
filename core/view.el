;;; view.el --- 界面与显示 -*- lexical-binding: t; -*-
;; /core/view.el

;;; Code:

;; 关闭菜单栏,工具栏,滚动条,启动欢迎页 | *scratch* 留空
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
(setq initial-scratch-message nil)

;; 关闭响铃
(setq ring-bell-function 'ignore)

;; 设置竖线光标|非活动窗口不显示|不闪烁
(setq-default cursor-type 'bar)
(setq cursor-in-non-selected-windows nil)
(blink-cursor-mode -1)

;; 光标近边缘后滚动 | 边缘保留2行
(setq scroll-conservatively 101)
(setq scroll-margin 2)

;; 显示列号, 当前函数名
(column-number-mode 1)
(which-function-mode 1)


;; 撤销/重做布局 | Shift+方向键切窗口
(winner-mode 1)
(windmove-default-keybindings)


;; 使用minibuffer | 禁用 GUI 弹窗
(setq use-dialog-box nil)

;; 文件自动重载
(global-auto-revert-mode 1)
(setq auto-revert-avoid-polling t)
(setq auto-revert-verbose t)

;; 全局显示行号
(when (version<= "26.1" emacs-version)
  (global-display-line-numbers-mode t))

;; 原生垂直补全 | M-x 不列内部命令
(when (version<= "28.1" emacs-version)
  (fido-vertical-mode 1)
  (setq read-extended-command-predicate
        #'command-completion-default-include-p))
        
;; 像素级平滑滚动
(when (version<= "29.1" emacs-version)
  (pixel-scroll-precision-mode 1))
  
(provide 'view)
;;; view.el ends here
