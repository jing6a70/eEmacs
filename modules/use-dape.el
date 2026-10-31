;;; use-dape.el --- dape 调试配置 -*- lexical-binding: t; -*-
;; /modules/use-dape.el
;;
;; 只做三件事: 装 dape、把 C-c g 绑到 dape 自带的 keymap、给 ARM 目标
;; 加一个远程 attach 配置. 其余命令一律用 M-x.
;;
;; C-c g d 启动, C-c g b 断点, C-c g c 继续, C-c g i 信息面板, C-c g ? 菜单.

;;; Code:

(use-package dape
  :ensure t
  :config
  ;; C-c g 直接用 dape 自带的 dape-global-map (d 启动/b 断点/c 继续/i 面板)
  (keymap-set global-map "C-c g" dape-global-map)
  ;; 右侧信息面板, 源码在左; 想换回 gdb-mi 风格就用 M-x dape-many-windows
  (setq dape-buffer-window-arrangement 'right)

  ;; GDB 的 DAP 收到 launch 就启动程序, 之后下发的断点会被以 "notStopped"
  ;; 拒绝 (GDB bug 32090). 推迟 launch, 断点才会在启动时生效.
  (when-let* ((cfg (assq 'gdb dape-configs)))
    (setcdr cfg (plist-put (cdr cfg) 'defer-launch-attach t)))

  ;; 源码缓冲区里显示断点
  (dape-breakpoint-global-mode 1)

  ;; ARM 目标: gdbserver + gdb-multiarch. 换机器只改 :program 和 :target.
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
;;; use-dape.el ends here
