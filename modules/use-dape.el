;;; use-dape.el --- dape 配置 -*- lexical-binding: t; -*-

(use-package dape
  :ensure t
  :config
  (when-let* ((cfg (assq 'gdb dape-configs)))
    (setcdr cfg (plist-put (cdr cfg) 'defer-launch-attach t)))
  (setq dape-buffer-window-arrangement 'right)
  (keymap-set global-map "C-c d"
    (with-no-warnings
      (let ((map (make-sparse-keymap)))
        (keymap-set map "s" #'dape)
        (keymap-set map "c" #'dape-continue)
        (keymap-set map "n" #'dape-next)
        (keymap-set map "i" #'dape-step-in)
        (keymap-set map "o" #'dape-step-out)
        (keymap-set map "u" #'dape-until)
        (keymap-set map "b" #'dape-breakpoint-toggle)
        (keymap-set map "l" #'dape-breakpoint-log)
        (keymap-set map "r" #'dape-repl)
        (keymap-set map "x" #'dape-evaluate-expression)
        (keymap-set map "w" #'dape-watch-dwim)
        (keymap-set map "<" #'dape-stack-select-up)
        (keymap-set map ">" #'dape-stack-select-down)
        map))))

(provide 'use-dape)
