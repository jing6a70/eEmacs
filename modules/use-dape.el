;;; use-dape.el --- dape 配置 -*- lexical-binding: t; -*-

(use-package dape
  :ensure t
  :config
  (when-let* ((cfg (assq 'gdb dape-configs)))
    (setcdr cfg (plist-put (cdr cfg) 'defer-launch-attach t)))
  (setq dape-buffer-window-arrangement 'right)
  (dolist (k '(("c" . dape-continue)
               ("n" . dape-next)
               ("s" . dape-step-in)
               ("f" . dape-step-out)
               ("u" . dape-until)
               ("r" . dape-restart)
               ("b" . dape-breakpoint-toggle)
               ("p" . dape-evaluate-expression)
               ("w" . dape-watch-dwim)
               ("x" . dape-memory)
               ("R" . dape-repl)))
    (keymap-set dape-info-parent-mode-map (car k) (cdr k)))
  (keymap-set global-map "C-c d"
    (with-no-warnings
      (let ((map (make-sparse-keymap)))
        (keymap-set map "d" #'dape)
        (keymap-set map "c" #'dape-continue)
        (keymap-set map "n" #'dape-next)
        (keymap-set map "s" #'dape-step-in)
        (keymap-set map "f" #'dape-step-out)
        (keymap-set map "u" #'dape-until)
        (keymap-set map "r" #'dape-restart)
        (keymap-set map "b" #'dape-breakpoint-toggle)
        (keymap-set map "l" #'dape-breakpoint-log)
        (keymap-set map "p" #'dape-evaluate-expression)
        (keymap-set map "w" #'dape-watch-dwim)
        (keymap-set map "i" #'dape-info)
        (keymap-set map "x" #'dape-memory)
        (keymap-set map "q" #'dape-quit)
        (keymap-set map "k" #'dape-kill)
        (keymap-set map "R" #'dape-repl)
        (keymap-set map "<" #'dape-stack-select-up)
        (keymap-set map ">" #'dape-stack-select-down)
        map))))

(provide 'use-dape)
