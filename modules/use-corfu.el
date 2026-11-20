;;; use-corfu.el --- Corfu + Cape modern completion stack -*- lexical-binding: t; -*-
;; ~/.emacs.d/modules/use-corfu.el
;; Corfu + Cape: modern in-buffer completion stack
;; Incremental debugging: Corfu+LSP first; add Cape once basics are solid.

;;; Corfu: in-buffer completion popup
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.3)
  (corfu-auto-prefix 1)
  :init
  (global-corfu-mode 1))

;;; Cape: dabbrev (fallback) + yasnippet (delayed)
(use-package cape
  :ensure t
  :after corfu
  :config
  ;; dabbrev — plain fallback, active immediately
  (defun my/cape-dabbrev-setup ()
    (add-hook 'completion-at-point-functions #'cape-dabbrev 90 t))
  (dolist (hook '(prog-mode-hook text-mode-hook org-mode-hook))
    (add-hook hook #'my/cape-dabbrev-setup))
  ;; yasnippet — added only after yasnippet loads (load order is later)
  (with-eval-after-load 'yasnippet
    (defun my/cape-yasnippet-setup ()
      (add-hook 'completion-at-point-functions #'cape-yasnippet 50 t))
    (dolist (hook '(prog-mode-hook text-mode-hook org-mode-hook))
      (add-hook hook #'my/cape-yasnippet-setup))))

(provide 'use-corfu)
;;; use-corfu.el ends here
