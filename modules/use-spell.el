;;; use-spell.el --- Traditional spell checking with flyspell -*- lexical-binding: t; -*-
(require 'cl-lib)

;; Traditional spell checking, like Doom Emacs's `:checkers (spell
;; +flyspell)' setup. Uses the built-in flyspell/ispeak stack:
;;  - Program modes: comments and strings only (flyspell-prog-mode).
;;  - Text/org modes: whole buffer (flyspell-mode).
;;  - aspell is prefered, hunspell as alternative (the binary does the
;;    real work; no C module or unusual Emacs version is needed, so this
;;    runs the same on Ubuntu 18.04 with Emacs 26).
;; Keys:
;;   M-$        -> fix word at point (need aspell/hunspell + dictionary)
;;   C-; n/a    -> use M-x flyspell-correct-words etc. if recommended
;;
;; Install on Archlinux:  sudo pacman -S aspell aspell-en
;; Install on Ubuntu:     sudo apt install aspell aspell-en

(defun my/spell-check-setup ()
  "Set up traditional flyspell spell checking."
  ;; Pick the backend binary: aspell first, hunspell second.
  ;; aspell is faster with Emacs and has better suggestion handling.
  (let* ((checker (or (executable-find "aspell")
                      (executable-find "hunspell")))
         (name (when checker (file-name-nondirectory checker))))
    (cond
     ;; Prefer aspell: UTF8, good suggestions, fast ispell style.
     ((equal name "aspell")
      (setq ispell-program-name "aspell"
            ispell-extra-args '("--sug-mode=ultra")))
     ;; Fall back to hunspell (need an explicit dictionary name).
     ((equal name "hunspell")
      (setq ispell-program-name "hunspell"
            ispell-dictionary "en_US"
            ispell-extra-args nil))
     ;; No backend binary: enable nothing. With the hooks still added,
     ;; every M-$ / on-the-fly check would raise ispell errors instead
     ;; (install notes at the top of this file).
     (t
      (message "use-spell: no aspell/hunspell found; spell checking disabled this session")))
    (when checker
      ;; Code modes: check comments and strings, not code identifiers.
      (add-hook 'prog-mode-hook #'flyspell-prog-mode)
      ;; Text modes (org, markdown, commit messages): check the buffer.
      (add-hook 'text-mode-hook #'flyspell-mode))))

;; Turn spell checking on after the init is done.  Use `after-init-hook'
;; (not `emacs-startup-hook'): it runs before files given on the command
;; line are visited, so the first buffer gets spell checking too.
(add-hook 'after-init-hook #'my/spell-check-setup)


(provide 'use-spell)
;;; use-spell.el ends here
