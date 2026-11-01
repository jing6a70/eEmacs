;;; use-treemacs.el --- 左侧文件树 -*- lexical-binding: t; -*-
;; C-c t 开关侧栏; C-c T 把当前工程挂进树里并打开侧栏

(require 'project)

;; treemacs 首次打开(空 workspace)会提示 "Project root:", 默认值原本是
;; 当前目录, 在工程子目录里按回车就会把子目录当成工程. 这里改为默认取
;; project.el 识别的工程根; 不在工程里时退回当前目录.
(defun my/treemacs--read-first-project-path ()
  "Read the first project, defaulting to the current project root."
  (when (treemacs-workspace->is-empty?)
    (file-truename
     (read-directory-name
      "Project root: "
      (if-let* ((pr (project-current)))
          (project-root pr)
        default-directory)))))

(use-package treemacs
  :ensure t
  :bind (("C-c t" . treemacs)
         ("C-c T" . treemacs-add-and-display-current-project))
  :config
  (setq treemacs-width 32)
  (treemacs-follow-mode t)        ; 光标所在文件自动定位
  (treemacs-filewatch-mode t)     ; 文件变动自动刷新
  (treemacs-git-mode 'deferred)   ; git 状态着色(需要 python3)
  (advice-add 'treemacs--read-first-project-path
              :override #'my/treemacs--read-first-project-path))

(provide 'use-treemacs)
;;; use-treemacs.el ends here
