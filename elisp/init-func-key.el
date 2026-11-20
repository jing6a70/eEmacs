;;; init-func-key.el --- Global key bindings for custom functions -*- lexical-binding: t; -*-
;; Bind open-init-file to the <f2> key
(global-set-key (kbd "<f2>") 'open-init-file)

(global-set-key (kbd "<f5>") 'open-e2macs-man)

(global-set-key (kbd "<f6>") 'my/cmake-update-compile-commands)  ; refresh compile_commands.json


(provide 'init-func-key)
;;; init-func-key.el ends here
