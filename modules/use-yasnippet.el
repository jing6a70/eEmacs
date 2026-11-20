;;; use-yasnippet.el --- 代码片段 -*- lexical-binding: t; -*-
;; yasnippet 负责展开片段, yasnippet-snippets 提供按 major-mode 分好的现成片段.
;; C-c y 用 vertico/orderless 按名字挑片段, 不占用 TAB(TAB 留给缩进和 corfu).

(use-package yasnippet
  :ensure t
  :demand t                       ; 启动就加载, 否则 yas-global-mode 永远不生效
  :bind ("C-c y" . yas-insert-snippet)
  :config
  ;; ~/.emacs.d/snippets 本来就是 yas-snippet-dirs 的默认值, 这里只补一个目录说明
  (make-directory (expand-file-name "snippets" user-emacs-directory) t)
  (yas-global-mode 1))

;; 现成片段库(C/C++/Python/JS/...), 加载时会自己挂到 yas-snippet-dirs
(use-package yasnippet-snippets
  :ensure t
  :after yasnippet
  :demand t)

(provide 'use-yasnippet)
;;; use-yasnippet.el ends here
