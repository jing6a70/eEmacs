;;; use-fonts.el --- Font and icon-font settings -*- lexical-binding: t; -*-
;; view/use-fonts.el
;;
;; Nerd Font families installed on this machine (list with
;;   fc-list : family | grep -i nerd):
;;   FantasqueSansM / MesloLGL / MesloLGM / MesloLGS,
;;   each in plain / Mono / Propo variants.

;; 1) Icon font — treemacs file tree and doom-modeline icons are drawn
;;    by nerd-icons from `nerd-icons-font-family'. Its default value
;;    "Symbols Nerd Font Mono" is NOT installed here, so the icons
;;    rendered as missing glyphs. Point it at an installed family.
;;    Always pick a *Mono* variant: only Mono variants keep the icon
;;    glyphs single-width, so mode-line icons are not clipped.
(setq nerd-icons-font-family "MesloLGS Nerd Font Mono")

;; 2) Default frame font — OPTIONAL. Uncomment to override the system
;;    default font (size is in 1/10 pt: 120 = 12pt). Prefer the Mono
;;    variant here too.
;; (when (display-graphic-p)
;;   (set-face-attribute 'default nil :font "MesloLGS Nerd Font Mono" :height 120)
;;   (add-to-list 'default-frame-alist '(font . "MesloLGS Nerd Font Mono")))

;;; use-fonts.el ends here
