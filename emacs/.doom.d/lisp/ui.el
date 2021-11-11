;;; ~/.doom.d/lisp/ui.el -*- lexical-binding: t; -*-
;;;

;;; private/my/+ui.el -*- lexical-binding: t; -*-

(load-theme 'doom-one-light t)

(when (display-graphic-p)
  (cond (IS-MAC
         (setq doom-font (font-spec :family "Iosevka Term Light" :size 16)
               doom-big-font (font-spec :family "Iosevka Term Light" :size 22)
               doom-modeline-height 32))
        (IS-LINUX
         (setq resolution-factor (eval (/ (x-display-pixel-height) 1080.0)))
         (setq doom-font (font-spec :family "Iosevka Term" :size (eval (round (* 14 resolution-factor))) :weight 'light)
               doom-big-font (font-spec :family "Iosevka Term" :size (eval (round (* 20 resolution-factor))))
               doom-modeline-height (eval (round (* 32 resolution-factor))))))

  ;; set initl screen size
  (setq initial-frame-alist
        '((width . 110)
          (height . 65))))

(setq doom-modeline-buffer-file-name-style 'relative-to-project)

(setq +workspaces-on-switch-project-behavior t)

(remove-hook 'doom-init-ui-hook #'blink-cursor-mode)


;; (setq display-line-numbers-type nil)
(require 'linum-relative)
