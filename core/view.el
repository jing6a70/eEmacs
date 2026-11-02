;;; view.el --- 界面与显示 -*- lexical-binding: t; -*-
;; /core/view.el

;;; Code:

;; 启动欢迎页关闭 | *scratch* 留空
;; (菜单栏/工具栏/滚动条在 early-init.el 里已经关掉, 这里不再重复)
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

;; M-x 不列内部命令 | 补全界面交给 modules/use-vertico.el, 这里不再开 fido
(when (version<= "28.1" emacs-version)
  (setq read-extended-command-predicate
        #'command-completion-default-include-p))
        
;; 像素级平滑滚动
(when (version<= "29.1" emacs-version)
  (pixel-scroll-precision-mode 1))
  
(provide 'view)
;;; view.el ends here
