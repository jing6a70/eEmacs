;;; package-sources.el --- Package archive configuration -*- lexical-binding: t; -*-
;; core/package-sources.el

;; Domestic (CN) ELPA mirror sources
(require 'package)

(setq package-archives
      '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
        ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

;; Domestic mirror: skip/allow unsigned package checks
(setq package-check-signature nil)

;; Package cache directory: under user-emacs-directory (~/.emacs.d)
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))
