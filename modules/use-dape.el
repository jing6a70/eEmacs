;;; use-dape.el --- dape 配置 -*- lexical-binding: t; -*-

(use-package dape
  :ensure t
  :config
  (when-let* ((cfg (assq 'gdb dape-configs)))
    (setcdr cfg (plist-put (cdr cfg) 'defer-launch-attach t)))
  (setq dape-buffer-window-arrangement 'right)
  
  (add-to-list 'dape-configs
               '(gdb-remote
                 modes (c-mode c-ts-mode c++-mode c++-ts-mode)
                 command "gdb-multiarch"
                 command-args
                 ("--interpreter=dap")
                 :request "attach"))
  
  (defun my/dape-remote (program host port)
    (interactive
     (list (read-file-name "Local program: " default-directory nil t)
           (read-string "Target host: " "172.16.1.101")
           (read-string "Port: " "1234")))
    (let ((dape-command (cons 'gdb-remote
                              (list :program program
                                    :target (format "%s:%s" host port)))))
      (call-interactively #'dape)))
  
  (keymap-set global-map "C-c d"
    (with-no-warnings
      (let ((map (make-sparse-keymap)))
        (keymap-set map "d" #'dape)
        (keymap-set map "a" #'my/dape-remote)
        (keymap-set map "c" #'dape-continue)
        (keymap-set map "n" #'dape-next)
        (keymap-set map "s" #'dape-step-in)
        (keymap-set map "f" #'dape-step-out)
        (keymap-set map "u" #'dape-until)
        (keymap-set map "r" #'dape-restart)
        (keymap-set map "P" #'dape-pause)
        (keymap-set map "b" #'dape-breakpoint-toggle)
        (keymap-set map "e" #'dape-breakpoint-expression)
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
