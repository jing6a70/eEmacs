;;; -*- lexical-binding: t; -*-
;; Quick-open config helpers
(defun open-init-file ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun open-e2macs-man ()
  (interactive)
  (find-file "~/.emacs.d/README.md"))


;; One-key update of compile_commands.json (run cmake in the build dir;
;; clangd picks it up via --compile-commands-dir=build, no symlink needed)
(defun my/cmake-update-compile-commands ()
  "Run cmake in the project's build directory to refresh compile_commands.json."
  (interactive)
  (let* ((root (or (locate-dominating-file default-directory "CMakeLists.txt")
                   (user-error "No CMakeLists.txt found, not in a CMake project")))
         (build-dir (expand-file-name "build" root)))
    (unless (file-exists-p build-dir)
      (make-directory build-dir))
    (message "running cmake ...")
    (let ((default-directory build-dir)
          (ret (call-process (executable-find "cmake") nil "*cmake-output*" nil
                             "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" "..")))
      (if (zerop ret)
          (if (file-exists-p (expand-file-name "compile_commands.json" build-dir))
              (message "compile_commands.json updated in build/ -> clangd will pick it up")
            (message "cmake finished, but no compile_commands.json produced"))
        (message "cmake failed (exit %d), see *cmake-output*" ret)))))

(provide 'init-func-def)