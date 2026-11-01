;;; use-treemacs.el --- 左侧文件树 -*- lexical-binding: t; -*-
;; C-c t 开关侧栏(空 workspace 时自动加入当前工程); C-c T 重新定位当前工程

(require 'project)

;; treemacs 首次打开(空 workspace)默认会弹 "Project root:" 让选目录, 默认值
;; 是当前目录, 在 src/ 里回车就会把子目录当成工程. 这里改成默认取 project.el
;; 的工程根(优先 .git 等版本控制根), 不在工程里时再用当前目录.
(defun my/treemacs--read-first-project-path ()
  "Read the first project, defaulting to the current project root."
  (when (treemacs-workspace->is-empty?)
    (file-truename
     (read-directory-name
      "Project root: "
      (if-let* ((pr (project-current)))
          (project-root pr)
        default-directory)))))

(defun my/treemacs-toggle (&optional arg)
  "Toggle treemacs; on an empty workspace add the current project root.
The root comes from project.el, so the VC root (e.g. the directory
containing .git) wins over the current buffer's directory."
  (interactive "P")
  (require 'treemacs)
  (if (treemacs-workspace->is-empty?)
      (treemacs-add-and-display-current-project)
    (treemacs arg)))

(use-package treemacs
  :ensure t
  :bind (("C-c t" . my/treemacs-toggle)
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
