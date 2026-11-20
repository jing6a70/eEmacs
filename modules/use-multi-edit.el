;;; use-multi-edit.el --- Multi-line editing (multiple-cursors + iedit) -*- lexical-binding: t; -*-
(require 'cl-lib)

;; Multi-line editing tools, both lazy-loaded, safe on Emacs 26:
;;
;;  multiple-cursors: edit N lines at once. One cursor per line and
;;  typing/deleting happens in every line at the same time.
;;
;;    C->        next line gets a cursor too (repeat for more lines)
;;    C-<        previous line gets a cursor
;;    C-c C->    mark all words like the one at point
;;
;;  iedit: edit every occurrence of the word at point at once. Best for
;;  renaming a plain-text word in one file (use LSP rename for real code
;;  symbols). Starts and stops with the same key.
;;
;;  expand-region: grow the active region: word -> symbol -> line...
;;  Handy before feeding a region to multiple-cursors or iedit.

;; Keys (with multiple-cursors active):
;;    C-g ends the multi-cursor session and returns to normal editing.

(use-package multiple-cursors
  :ensure t
  :bind
  (("C->"     . mc/mark-next-like-this)         ; add cursor on next same word / next line use with C-M-> etc
   ("C-<"     . mc/mark-previous-like-this)     ; add cursor on previous same word
   ("C-c C->" . mc/mark-all-like-this)          ; mark all words like this in the buffer
   ("C-c m a" . mc/edit-lines)                  ; cursor on every line in region
   ("C-S-<mouse-1>" . mc/add-cursor-on-click)) ; click places an extra cursor
  :commands (mc/mark-next-like-this mc/mark-previous-like-this
             mc/mark-all-like-this mc/add-cursor-on-click)
  :defer t)

(use-package iedit
  :ensure t
  ;; One key toggles; a second press ends the edit and restores the text.
  :bind ("C-c e" . iedit-mode)
  :commands (iedit-mode))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region)
  :commands (er/expand-region))

(provide 'use-multi-edit)
;;; use-multi-edit.el ends here
