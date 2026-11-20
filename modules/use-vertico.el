;;; use-vertico.el --- Modern completion suite (Vertico stack) -*- lexical-binding: t; -*-

;; 1. Vertico - the core vertical completion UI
(use-package vertico
  :ensure t
  :init
  (vertico-mode)
  :custom
  (vertico-count 13)           ; show 13 candidates at once
  (vertico-cycle t)            ; wrap around when cycling
  :config
  ;; Nice default from most configs: with Backspace in the minibuffer,
  ;; go up one directory level instead of deleting char by char.
  ;; (:config already runs after vertico loads — no extra wrap needed.)
  (define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word))

;; 2. Orderless - core filtering engine (must-have)
;; Type "conf init" to match "init-config.el": space-separated, any order.
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; 3. Marginalia - annotations on the side of candidate lists
;; Shows docs next to M-x commands, size/perms next to files.
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

;; 4. Consult - enhanced search and jump (perfect Ivy/Swiper replacement)
(use-package consult
  :ensure t
  :bind (;; rebinding common keys
         ("C-s" . consult-line)          ; better isearch: search per line
         ("C-x b" . consult-buffer)      ; buffers + bookmarks + recent files
         ("M-y" . consult-yank-pop)      ; kill ring history with preview
         ("M-g g" . consult-goto-line)   ; jump to line
         ("M-g m" . consult-mark)        ; jump to marks
         ("M-g i" . consult-imenu)       ; jump to defuns/variables
         ("M-s r" . consult-ripgrep)     ; global search (needs ripgrep)
         :map minibuffer-local-map
         ("M-s" . consult-history)       ; browse command history
         ("M-r" . consult-history)))

;; 5. Embark - the "context menu" of Emacs (power tool)
;; Press C-. on any candidate at point for actions (copy/delete/rename...).
(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ; trigger actions
   ("M-." . embark-dwim))       ; smart jump
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

;; 6. embark-consult: lets embark actions (C-.) work on consult
;; candidates/buffers, with live preview inside embark collect mode.
(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; 7. Helper: persist minibuffer history
(use-package savehist
  :init
  (savehist-mode 1))

;; 8. Helper: nicer native completion behavior
(setq read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      completion-ignore-case t)


(provide 'use-vertico)
;;; use-vertico.el ends here
