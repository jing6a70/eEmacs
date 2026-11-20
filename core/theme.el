;;; theme.el --- 主题加载 -*- lexical-binding: t; -*-
;; /core/theme.el

;;; Code:

;; 加载主题: 低版本 Emacs 回退到 tsdh-dark;
;; 高版本优先 modus-operandi-tinted, 失败则同样回退到 tsdh-dark
(if (< emacs-major-version 29)
    (load-theme 'tsdh-dark t)
  (unless (ignore-errors (load-theme 'modus-operandi-tinted t))
    (message "ApexInfo: modus-operandi-tinted theme not found. Falling back to tsdh-dark.")
    (load-theme 'tsdh-dark t)))

(provide 'theme)
;;; theme.el ends here
