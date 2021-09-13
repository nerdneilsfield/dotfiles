;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(load! "lisp/misc")
(load! "lisp/ui")
(load! "lisp/prog")
(load! "lisp/text")
(load! "lisp/bindings")
;; (load! "lisp/os")

(setq doom-scratch-buffer-major-mode 'emacs-lisp-mode)

(setq-default fill-column 100
              delete-trailing-lines t)

;; Delete the selection when pasting
(delete-selection-mode 1)

;; disable risky local variables warning
(advice-add 'risky-local-variable-p :override #'ignore)
