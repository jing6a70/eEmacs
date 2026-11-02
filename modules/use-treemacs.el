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
  "Toggle treemacs, making sure the current project is in the workspace.
The root comes from project.el, so the VC root (e.g. the directory
containing .git) wins over the current buffer's directory.  The
workspace may already contain projects restored from
`treemacs-persist-file'; in that case the current project is added
before the tree is shown, instead of just showing the old tree."
  (interactive "P")
  (require 'treemacs)
  (let ((root (when-let* ((pr (project-current)))
                (treemacs-canonical-path (project-root pr)))))
    (cond
     ;; 已经显示 → 关掉(前缀参数照旧交给 treemacs 去切 workspace)
     ((eq (treemacs-current-visibility) 'visible)
      (treemacs arg))
     ;; 当前工程还不在 workspace 里 → 加进来并定位过去
     ((and root (not (treemacs-is-path root :in-workspace)))
      (treemacs-add-and-display-current-project))
     (t (treemacs arg)))))

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
