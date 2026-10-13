;;; custom-config.el --- manage the custom-file -*- lexical-binding: t; -*-
;; core/custom-config.el

;; Only manages custom-file logic; inherits user-emacs-directory from init.el
(setq custom-file (expand-file-name ".config-auto.el" user-emacs-directory))

;; Ensure the containing directory exists
(make-directory (file-name-directory custom-file) t)

;; Load custom-file
(when (file-exists-p custom-file)
  (load custom-file t t))

;; Create an empty file on first run
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))

(provide 'custom-config)
;;; custom-config.el ends here
