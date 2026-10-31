;;; use-dape.el --- dape 配置 -*- lexical-binding: t; -*-

(use-package dape
  :ensure t
  :config
  (keymap-set global-map "C-c g" dape-global-map)
  (setq dape-buffer-window-arrangement 'right)
  (when-let* ((cfg (assq 'gdb dape-configs)))
    (setcdr cfg (plist-put (cdr cfg) 'defer-launch-attach t)))
  (dape-breakpoint-global-mode 1)
  (add-to-list 'dape-configs
               '(gdb-remote
                 modes (c-mode c-ts-mode c++-mode c++-ts-mode)
                 command "gdb-multiarch"
                 command-args
                 ("--interpreter=dap"
                  "-ex" "set substitute-path /home/jingpeng/Desktop/virtDisk /home/jingpeng/Desktop/sgc")
                 :request "attach"
                 :program "/home/jingpeng/Desktop/sgc/build-GreenPulse-xrdARM-Debug/Src/GreenPulse-device"
                 :target "172.16.1.101:1234")))

(provide 'use-dape)
