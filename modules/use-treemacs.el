;;; use-treemacs.el --- 左侧文件树 -*- lexical-binding: t; -*-
;; C-c t 开关侧栏(当前工程不在 workspace 时自动加入); C-c T 把当前工程挂进树里.
;; 工程清单以 project.el 为唯一来源, treemacs 只做展示:
;;   - 关闭 treemacs 自带的持久化, 免得多出第二份列表;
;;   - 打开 treemacs 时把 project.el 已知的工程补进 workspace;
;;   - 经 treemacs 打开的工程也登记进 project.el(dashboard 的 Projects 块读的就是它).

(require 'project)

;; treemacs 首次打开且 workspace 为空时会弹 "Project root:" 提示(默认当前目录).
;; 这条路径只在"不在任何工程里"时才走得到, 此时 project.el 也取不到根, 回调默认值
;; 同样是当前目录, 所以不再单独 advice 它.

(defun my/treemacs-remember-current-project ()
  "Register the current buffer's project in project.el."
  (when-let* ((pr (project-current)))
    (project-remember-project pr)))

(defun my/treemacs-sync-project-el ()
  "Add project.el's known projects to the treemacs workspace."
  (dolist (root (project-known-project-roots))
    (let ((path (treemacs-canonical-path root)))
      (unless (treemacs-is-path path :in-workspace)
        (ignore-errors
          (treemacs-do-add-project-to-workspace
           path (treemacs--filename path)))))))

(defun my/treemacs-add-current-project ()
  "Add the current project to project.el and show it in treemacs."
  (interactive)
  (require 'treemacs)
  (my/treemacs-remember-current-project)
  (treemacs-add-and-display-current-project))

(defun my/treemacs-toggle (&optional arg)
  "Toggle treemacs; add the current project first if it is missing.
The root comes from project.el (the git repo root), not `default-directory'."
  (interactive "P")
  (require 'treemacs)
  (let ((root (when-let* ((pr (project-current)))
                (treemacs-canonical-path (project-root pr)))))
    (cond
     ;; 已经显示 → 关掉(前缀参数照旧交给 treemacs 去切 workspace)
     ((eq (treemacs-current-visibility) 'visible)
      (treemacs arg))
     ;; 当前工程还不在 workspace 里则登记进 project.el, 再加进来并定位过去
     ((and root (not (treemacs-is-path root :in-workspace)))
      (my/treemacs-remember-current-project)
      (treemacs-add-and-display-current-project))
     (t (treemacs arg)))))

(use-package treemacs
  :ensure t
  :init
  ;; 工程列表统一由 project.el 保存, treemacs 不再自己持久化
  (setq treemacs-persist-file nil)
  :bind (("C-c t" . my/treemacs-toggle)
         ("C-c T" . my/treemacs-add-current-project))
  :config
  (setq treemacs-width 32)
  (treemacs-follow-mode t)        ; 光标所在文件自动定位
  (treemacs-filewatch-mode t)     ; 文件变动自动刷新
  (treemacs-git-mode 'deferred)   ; git 状态着色(需要 python3)
  (add-hook 'treemacs-post-buffer-init-hook #'my/treemacs-sync-project-el))

(provide 'use-treemacs)
;;; use-treemacs.el ends here
