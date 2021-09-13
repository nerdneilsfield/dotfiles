;;; ~/.doom.d/+prog.el -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; COMPANY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! company
  (setq company-idle-delay 0.2))


(use-package! company-tabnine
  :init (add-to-list 'company-backends #'company-tabnine)
  ;; (require 'company-tabnine)
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FLYCHECK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar cspell-base-program "cspell")
(defvar cspell-config-file-path (concat "'" (expand-file-name  "~/Dotfiles/misc/apps/.cspell.json") "'"))
(defvar cspell-args (string-join `("--config" ,cspell-config-file-path) " "))
(defun cspell-check-buffer ()
  (interactive)
  (if cspell-base-program
      (let* ((file-name (concat "'" (file-name-nondirectory (buffer-file-name)) "'"))
             (command (string-join `(,cspell-base-program ,cspell-args ,file-name) " ")))
        (compilation-start command 'grep-mode))
    (message "Cannot find cspell, please install with `npm install -g csepll`")
    ))

(defun cspell-check-directory ()
  (interactive)
  (if cspell-base-program
      (let* ((project-root (doom-project-root))
             (default-directory
               (if (string-match-p "av/detection" project-root)
                   (expand-file-name "~/av")
                 project-root))
             (command (string-join `("git diff --name-only origin/develop | xargs -I{}" ,cspell-base-program ,cspell-args "'{}'") " ")))
        (compilation-start command 'grep-mode))
    (message "Cannot find cspell, please install with `npm install -g csepll`")))

;; (use-package! wucuo
;;   :defer t
;;   :init
;;   (add-hook! (js2-mode rjsx-mode go-mode c-mode c++-mode) #'wucuo-start))


(after! flycheck
  (setq-default flycheck-disabled-checkers
                '(
                  javascript-jshint handlebars
                  json-jsonlist json-python-json
                  c/c++-clang c/c++-cppcheck c/c++-gcc
                  python-pylint python-flake8 python-pycompile
                  ))

  ;; customize flycheck temp file prefix
  (setq-default flycheck-temp-prefix ".flycheck")

  ;; ======================== JS & TS ========================
  (flycheck-add-mode 'typescript-tslint 'web-mode)
  (after! tide
    (flycheck-add-next-checker 'javascript-eslint '(t . javascript-tide) 'append)
    (flycheck-add-next-checker 'javascript-eslint '(t . jsx-tide) 'append)
    (flycheck-add-next-checker 'typescript-tslint '(t .  typescript-tide) 'append)
    (flycheck-add-next-checker 'javascript-eslint '(t . tsx-tide) 'append))

  ;; ======================== Python ========================
  (require 'flycheck-mypy)

  ;; ======================== CC ========================
  (require 'flycheck-google-cpplint)
  (setq flycheck-c/c++-googlelint-executable "cpplint")
  (flycheck-add-next-checker 'c/c++-gcc '(t . c/c++-googlelint))

  (setq flycheck-c/c++-gcc-executable "gcc-9"
        flycheck-gcc-include-path '("/usr/local/inclue"))

  (add-hook! c++-mode-hook
    (setq flycheck-gcc-language-standard "c++17"
          flycheck-clang-language-standard "c++17"))
  )

(defun disable-flycheck-mode ()
  (flycheck-mode -1))
;; (add-hook! (emacs-lisp-mode) 'disable-flycheck-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package! bazel-mode
  :defer t
  :init
  (add-to-list 'auto-mode-alist '("BUILD\\(\\.bazel\\)?\\'" . bazel-mode))
  (add-to-list 'auto-mode-alist '("WORKSPACE\\'" . bazel-mode)) )

(add-to-list 'auto-mode-alist '("\\.inl\\'" . +cc-c-c++-objc-mode))
(add-to-list 'auto-mode-alist '("\\.inc\\'" . +cc-c-c++-objc-mode))

(after! cc-mode
  (c-add-style
   "my-cc" '("user"
             (c-basic-offset . 2)
             (c-offsets-alist
              . ((innamespace . 0)
                 (access-label . -)
                 (case-label . 0)
                 (member-init-intro . +)
                 (topmost-intro . 0)
                 (arglist-cont-nonempty . +)))))
  (setq c-default-style "my-cc")

  (setq-default c-basic-offset 2))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PYTHON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (define-derived-mode asl-mode
;;   python-mode "ARGO Schema Language Mode"
;;   "Major mode for asl file."
;;   (flycheck-mode -1))
;; (add-to-list 'auto-mode-alist '("\\.asl\\'" . asl-mode))

;; (after! python
;;   (setq python-indent-offset 4
;;         python-shell-interpreter "python3"
;;         pippel-python-command "python3"
;;         importmagic-python-interpreter "python3"
;;         flycheck-python-pylint-executable "pylint"
;;         flycheck-python-flake8-executable "flake8")

;;   ;; if you use pyton2, then you could comment the following 2 lines
;;   ;; (setq python-shell-interpreter "python2"
;;   ;;       python-shell-interpreter-args "-i")

;;   ;; ignore some linting info
;;   (if (featurep! :tools lsp)
;;       (setq lsp-pyls-plugins-pycodestyle-ignore '("E501")
;;             lsp-pyls-plugins-pylint-args [ "--errors-only" ]))
;;   )


;; (after! lsp-python-ms
;;   (setq lsp-python-ms-python-executable-cmd "python3"))


;; (use-package! py-isort
;;   :defer t
;;   :init
;;   (setq python-sort-imports-on-save t)
;;   (defun +python/python-sort-imports ()
;;     (interactive)
;;     (when (and python-sort-imports-on-save
;;                (derived-mode-p 'python-mode))
;;       (py-isort-before-save)))
;;   (add-hook! 'python-mode-hook
;;     (add-hook 'before-save-hook #'+python/python-sort-imports nil t))
;;   )


;; (use-package! importmagic
;;   :defer t
;;   :hook (python-mode . importmagic-mode)
;;   :commands (importmagic-fix-imports importmagic-fix-symbol-at-point)
;;   :config
;;   (dolist (func '(importmagic-fix-imports importmagic-fix-symbol-at-point))
;;     (advice-add func :before #'revert-buffer-no-confirm)))


;; (after! pipenv
;;   (setq pipenv-with-projectile t)
;;   ;; Override pipenv--clean-response to trim color codes
;;   (defun pipenv--clean-response (response)
;;     "Clean up RESPONSE from shell command."
;;     (replace-regexp-in-string "\n\\[0m$" "" (s-chomp response)))

;;   ;; restart flycheck-mode after env activate and deactivate
;;   (dolist (func '(pipenv-activate pipenv-deactivate))
;;     (advice-add func :after #'reset-flycheck)))

;; ;; TEMP: add conda env
;; (add-hook! python-mode
;;   (setq conda-env-home-directory (expand-file-name "~/.conda")))

;; (after! conda
;;   (when IS-LINUX
;;     ;; Ubuntu anaconda
;;     (setq conda-anaconda-home "~/anaconda3"))

;;   ;; restart flycheck-mode after env activate and deactivate
;;   (dolist (func '(conda-env-activate conda-env-deactivate))
;;     (advice-add func :after #'reset-flycheck)))


;; ;; For pytest-mode
;; (set-evil-initial-state! '(comint-mode) 'normal)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JS, WEB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package! indium
;;   :defer t)


;; (use-package! import-js
;;   :defer t
;;   :init
;;   (add-hook! (js2-mode rjsx-mode) (run-import-js))
;;   (add-hook! (js2-mode rjsx-mode)
;;     (add-hook 'after-save-hook #'import-js-fix nil t)))
;; (advice-add '+javascript|cleanup-tide-processes :after 'kill-import-js)


;; (after! web-mode
;;   (web-mode-toggle-current-element-highlight)
;;   (web-mode-dom-errors-show))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (after! go-mode
;;   (add-hook! go-mode (setq indent-tabs-mode nil))
;;   (add-hook! go-mode #'lsp))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSP & DAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun toggle-lsp-ui-doc ()
  (interactive)
  (if lsp-ui-doc-mode
      (progn
        (lsp-ui-doc-mode -1)
        (lsp-ui-doc--hide-frame))
    (lsp-ui-doc-mode 1)))

(defun my-lsp-mode-hook ()
  ;; disable lsp-highlight-symbol
  ;; (setq lsp-highlight-symbol-at-point nil)

  ;; toggle off lsp-ui-doc by default
  ;; (toggle-lsp-ui-doc)
  )
;; (add-hook 'lsp-ui-mode-hook #'my-lsp-mode-hook)

(after! lsp-mode
  (setq lsp-use-native-json t
        lsp-print-io nil)
  (dolist (dir '("[/\\\\]\\.ccls-cache$"
                 "[/\\\\]\\.mypy_cache$"
                 "[/\\\\]\\.pytest_cache$"
                 "[/\\\\]\\.cache$"
                 "[/\\\\]\\.clwb$"
                 "[/\\\\]_build$"
                 "[/\\\\]__pycache__$"
                 "[/\\\\]bazel-bin$"
                 "[/\\\\]bazel-code$"
                 "[/\\\\]bazel-genfiles$"
                 "[/\\\\]bazel-out$"
                 "[/\\\\]bazel-testlogs$"
                 "[/\\\\]third_party$"
                 "[/\\\\]third-party$"
                 ))
    (push dir lsp-file-watch-ignored))
  )

(after! lsp-ui
  (setq lsp-ui-sideline-enable nil
        lsp-ui-doc-include-signature t)

  ;; set lsp-ui-doc position
  ;; (setq lsp-ui-doc-position 'at-point)
  )


(defun +my/dap-start ()
  (interactive)
  (dap-mode 1)
  (call-interactively #'dap-debug))

(add-hook! dap-mode-hook ((dap-tooltip-mode 1) (tooltip-mode 1)))

(after! dap-mode
 (add-hook 'dap-stopped-hook
           (lambda (arg) (call-interactively #'dap-hydra))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEBUG & RUN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! quickrun
  (quickrun-add-command "c++/c17"
    '((:command . "clang++-9")
      (:exec    . ("%c -std=c++17 %o -o %e %s"
                   "%e %a"))
      (:remove  . ("%e")))
    :default "c++"))


;;;;;;;;;;;;;;;
;; CTAGS
;;;;;;;;;;;;;;;;;
(use-package citre
  :defer t
  :init
  ;; This is needed in `:init' block for lazy load to work.
  (require 'citre-config)
  ;; Bind your frequently used commands.  Alternatively, you can define them
  ;; in `citre-mode-map' so you can only use them when `citre-mode' is enabled.
  (global-set-key (kbd "C-x c j") 'citre-jump)
  (global-set-key (kbd "C-x c J") 'citre-jump-back)
  (global-set-key (kbd "C-x c p") 'citre-ace-peek)
  (global-set-key (kbd "C-x c u") 'citre-update-this-tags-file)
  :config
  (setq
   ;; Set these if readtags/ctags is not in your path.
   citre-readtags-program "/usr/local/bin/readtags"
   citre-ctags-program "/usr/local/bin/ctags"
   ;; Set this if you use project management plugin like projectile.  It's
   ;; used for things like displaying paths relatively, see its docstring.
   citre-project-root-function #'projectile-project-root
   ;; Set this if you want to always use one location to create a tags file.
   citre-default-create-tags-file-location 'global-cache
   ;; See the "Create tags file" section above to know these options
   citre-use-project-root-when-creating-tags t
   citre-prompt-language-for-ctags-command t
   ;; By default, when you open any file, and a tags file can be found for it,
   ;; `citre-mode' is automatically enabled.  If you only want this to work for
   ;; certain modes (like `prog-mode'), set it like this.
   citre-auto-enable-citre-mode-modes '(prog-mode)))
