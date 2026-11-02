;;; use-treemacs.el --- 左侧文件树 -*- lexical-binding: t; -*-
;; C-c t 开关侧栏(当前工程不在 workspace 时自动加入); C-c T 把当前工程挂进树里.
;; 工程清单以 project.el 为唯一来源, treemacs 只做展示:
;;   - 关闭 treemacs 自带的持久化, 免得多出第二份列表;
;;   - 打开 treemacs 时把 project.el 已知的工程补进 workspace;
;;   - 经 treemacs 打开的工程也登记进 project.el(dashboard 的 Projects 块读的就是它).

(require 'project)

;; 关掉 treemacs 自己的 workspace 持久化, 免得和 project.el 的列表各自演化.
(setq treemacs-persist-file nil)

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

(defun my/treemacs-remember-current-project ()
  "Register the current buffer's project with project.el."
  (when-let* ((pr (project-current)))
    (project-remember-project pr)))

(defun my/treemacs-sync-project-el ()
  "Add every project known to project.el into the treemacs workspace."
  (dolist (root (project-known-project-roots))
    (let ((path (treemacs-canonical-path root)))
      (unless (treemacs-is-path path :in-workspace)
        (ignore-errors
          (treemacs-do-add-project-to-workspace
           path (treemacs--filename path)))))))

(defun my/treemacs-add-current-project ()
  "Add the current project to both project.el and treemacs."
  (interactive)
  (require 'treemacs)
  (my/treemacs-remember-current-project)
  (treemacs-add-and-display-current-project))

(defun my/treemacs-toggle (&optional arg)
  "Toggle treemacs, making sure the current project is in the workspace.
The root comes from project.el, so the VC root (e.g. the directory
containing .git) wins over the current buffer's directory."
  (interactive "P")
  (require 'treemacs)
  (let ((root (when-let* ((pr (project-current)))
                (treemacs-canonical-path (project-root pr)))))
    (cond
     ;; 已经显示 → 关掉(前缀参数照旧交给 treemacs 去切 workspace)
     ((eq (treemacs-current-visibility) 'visible)
      (treemacs arg))
     ;; 当前工程还不在 workspace 里 → 登记进 project.el, 再加进来并定位过去
     ((and root (not (treemacs-is-path root :in-workspace)))
      (my/treemacs-remember-current-project)
      (treemacs-add-and-display-current-project))
     (t (treemacs arg)))))

(use-package treemacs
  :ensure t
  :bind (("C-c t" . my/treemacs-toggle)
         ("C-c T" . my/treemacs-add-current-project))
  :config
  (setq treemacs-width 32)
  (treemacs-follow-mode t)        ; 光标所在文件自动定位
  (treemacs-filewatch-mode t)     ; 文件变动自动刷新
  (treemacs-git-mode 'deferred)   ; git 状态着色(需要 python3)
  (add-hook 'treemacs-post-buffer-init-hook #'my/treemacs-sync-project-el)
  (advice-add 'treemacs--read-first-project-path
              :override #'my/treemacs--read-first-project-path))

(provide 'use-treemacs)
;;; use-treemacs.el ends here
